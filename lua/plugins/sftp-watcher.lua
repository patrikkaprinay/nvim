-- SFTP download/upload + remote browser via sw (sftp-watcher)

local function get_sw()
  local path = vim.fn.exepath("sw")
  if path == "" then
    path = vim.fn.expand("~/go/bin/sftp-watcher")
  end
  return path
end

-- gd/gu in explorer for quick download/upload
vim.api.nvim_create_autocmd("FileType", {
  pattern = "snacks_picker_list",
  callback = function(ev)
    local sw = get_sw()

    local function get_explorer_path()
      local picker = Snacks.picker.get({ source = "explorer" })[1]
      if not picker then return nil end
      local item = picker:current()
      if not item then return nil end
      return item._path or item.file
    end

    vim.keymap.set("n", "gd", function()
      local path = get_explorer_path()
      if not path then
        vim.notify("No file selected", vim.log.levels.WARN)
        return
      end
      vim.notify("SFTP ↓ " .. vim.fn.fnamemodify(path, ":."), vim.log.levels.INFO)
      vim.fn.jobstart({ sw, "get", path }, {
        on_exit = function(_, code)
          vim.schedule(function()
            if code == 0 then
              vim.notify("SFTP ↓ done: " .. vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)
            else
              vim.notify("SFTP download failed (exit " .. code .. ")", vim.log.levels.ERROR)
            end
          end)
        end,
      })
    end, { buffer = ev.buf, desc = "SFTP Download" })

    vim.keymap.set("n", "gu", function()
      local path = get_explorer_path()
      if not path then
        vim.notify("No file selected", vim.log.levels.WARN)
        return
      end
      vim.notify("SFTP ↑ " .. vim.fn.fnamemodify(path, ":."), vim.log.levels.INFO)
      vim.fn.jobstart({ sw, "put", path }, {
        on_exit = function(_, code)
          vim.schedule(function()
            if code == 0 then
              vim.notify("SFTP ↑ done: " .. vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)
            else
              vim.notify("SFTP upload failed (exit " .. code .. ")", vim.log.levels.ERROR)
            end
          end)
        end,
      })
    end, { buffer = ev.buf, desc = "SFTP Upload" })
  end,
})

-------------------------------------------------------------------------------
-- Remote file browser
-------------------------------------------------------------------------------

local browser = {}

-- Each node: { name, remote_path, is_dir, size, depth, expanded, children (nil = not loaded) }
browser.nodes = {}
browser.flat = {} -- flattened visible list
browser.cursor = 1
browser.buf = nil
browser.win = nil
browser.loading = false
browser.ns = vim.api.nvim_create_namespace("sftp_browser")

local function format_size(bytes)
  if bytes >= 1073741824 then
    return string.format("%.1f GB", bytes / 1073741824)
  elseif bytes >= 1048576 then
    return string.format("%.1f MB", bytes / 1048576)
  elseif bytes >= 1024 then
    return string.format("%.1f KB", bytes / 1024)
  else
    return bytes .. " B"
  end
end

function browser.flatten(nodes, depth, out)
  for _, node in ipairs(nodes) do
    node.depth = depth
    table.insert(out, node)
    if node.expanded and node.children then
      browser.flatten(node.children, depth + 1, out)
    end
  end
  return out
end

function browser.rebuild()
  browser.flat = browser.flatten(browser.nodes, 0, {})
  if browser.cursor > #browser.flat then
    browser.cursor = math.max(1, #browser.flat)
  end
  browser.render()
end

function browser.render()
  if not browser.buf or not vim.api.nvim_buf_is_valid(browser.buf) then return end

  local lines = {}
  local highlights = {}

  for i, node in ipairs(browser.flat) do
    local indent = string.rep("  ", node.depth)
    local icon, name
    if node.is_dir then
      if node.expanded then
        icon = "▼ "
      elseif node.children == nil then
        icon = "▶ "
      else
        icon = "▶ "
      end
      name = node.name .. "/"
    else
      icon = "  "
      name = node.name
    end

    local size_str = ""
    if not node.is_dir then
      size_str = "  " .. format_size(node.size)
    end

    local prefix = i == browser.cursor and "▸ " or "  "
    local line = prefix .. indent .. icon .. name .. size_str

    if node.loading then
      line = line .. "  ..."
    end

    table.insert(lines, line)

    -- Collect highlight info
    if i == browser.cursor then
      table.insert(highlights, { i, "CursorLine" })
    end
    if node.is_dir then
      table.insert(highlights, { i, "Directory", #prefix + #indent, #prefix + #indent + #icon + #name })
    end
  end

  if #lines == 0 then
    lines = { "  Loading..." }
  end

  vim.api.nvim_set_option_value("modifiable", true, { buf = browser.buf })
  vim.api.nvim_buf_set_lines(browser.buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = browser.buf })

  -- Apply highlights
  vim.api.nvim_buf_clear_namespace(browser.buf, browser.ns, 0, -1)
  for _, hl in ipairs(highlights) do
    if hl[3] then
      vim.api.nvim_buf_add_highlight(browser.buf, browser.ns, hl[2], hl[1] - 1, hl[3], hl[4])
    else
      vim.api.nvim_buf_add_highlight(browser.buf, browser.ns, hl[2], hl[1] - 1, 0, -1)
    end
  end
end

function browser.load_dir(remote_path, callback)
  local sw = get_sw()
  local stdout_parts = {}
  vim.fn.jobstart({ sw, "ls", remote_path }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(stdout_parts, line)
          end
        end
      end
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        if code ~= 0 then
          vim.notify("SFTP ls failed (exit " .. code .. ")", vim.log.levels.ERROR)
          callback(nil)
          return
        end
        local raw = table.concat(stdout_parts, "")
        local ok, entries = pcall(vim.json.decode, raw)
        if not ok or not entries then
          vim.notify("SFTP ls: failed to parse response", vim.log.levels.ERROR)
          callback(nil)
          return
        end
        -- Sort: dirs first, then alphabetical
        table.sort(entries, function(a, b)
          if a.is_dir ~= b.is_dir then return a.is_dir end
          return a.name < b.name
        end)
        local children = {}
        for _, e in ipairs(entries) do
          -- Skip hidden files
          if not vim.startswith(e.name, ".") then
            table.insert(children, {
              name = e.name,
              remote_path = remote_path .. "/" .. e.name,
              is_dir = e.is_dir,
              size = e.size or 0,
              depth = 0,
              expanded = false,
              children = nil,
            })
          end
        end
        callback(children)
      end)
    end,
  })
end

function browser.preview_file(node)
  if node.is_dir then return end
  local sw = get_sw()
  vim.notify("Previewing " .. node.name .. "...", vim.log.levels.INFO)

  local stdout_parts = {}
  vim.fn.jobstart({ sw, "cat", node.remote_path }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then table.insert(stdout_parts, line) end
        end
      end
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        if code ~= 0 then
          vim.notify("Preview failed (exit " .. code .. ")", vim.log.levels.ERROR)
          return
        end
        local tmp_path = table.concat(stdout_parts, "")
        if tmp_path == "" then
          vim.notify("Preview failed: no temp path returned", vim.log.levels.ERROR)
          return
        end

        -- Open in a vertical split to the right of the browser
        vim.cmd("wincmd l")
        vim.cmd("edit " .. vim.fn.fnameescape(tmp_path))
        vim.api.nvim_set_option_value("modifiable", false, { buf = 0 })
        vim.api.nvim_set_option_value("readonly", true, { buf = 0 })
        vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = 0 })

        -- Jump back to browser window
        if browser.win and vim.api.nvim_win_is_valid(browser.win) then
          vim.api.nvim_set_current_win(browser.win)
        end
      end)
    end,
  })
end

function browser.download_file(node)
  local sw = get_sw()
  local name = node.name
  if node.is_dir then
    name = name .. "/"
  end
  vim.notify("SFTP ↓ " .. name, vim.log.levels.INFO)
  vim.fn.jobstart({ sw, "get", node.remote_path }, {
    on_exit = function(_, code)
      vim.schedule(function()
        if code == 0 then
          vim.notify("SFTP ↓ done: " .. name, vim.log.levels.INFO)
        else
          vim.notify("SFTP download failed (exit " .. code .. ")", vim.log.levels.ERROR)
        end
      end)
    end,
  })
end

function browser.toggle_or_expand()
  local node = browser.flat[browser.cursor]
  if not node then return end
  if not node.is_dir then return end

  if node.expanded then
    node.expanded = false
    browser.rebuild()
    return
  end

  if node.children then
    node.expanded = true
    browser.rebuild()
    return
  end

  -- Need to load children
  node.loading = true
  browser.render()
  browser.load_dir(node.remote_path, function(children)
    node.loading = false
    if children then
      node.children = children
      node.expanded = true
    end
    browser.rebuild()
  end)
end

function browser.move(delta)
  browser.cursor = math.max(1, math.min(#browser.flat, browser.cursor + delta))
  browser.render()
  -- Keep cursor line centered-ish
  if browser.win and vim.api.nvim_win_is_valid(browser.win) then
    vim.api.nvim_win_set_cursor(browser.win, { browser.cursor, 0 })
  end
end

function browser.setup_keymaps()
  local buf = browser.buf
  local opts = { buffer = buf, nowait = true, silent = true }

  vim.keymap.set("n", "j", function() browser.move(1) end, opts)
  vim.keymap.set("n", "k", function() browser.move(-1) end, opts)
  vim.keymap.set("n", "<Down>", function() browser.move(1) end, opts)
  vim.keymap.set("n", "<Up>", function() browser.move(-1) end, opts)
  vim.keymap.set("n", "<C-d>", function() browser.move(10) end, opts)
  vim.keymap.set("n", "<C-u>", function() browser.move(-10) end, opts)
  vim.keymap.set("n", "l", function() browser.toggle_or_expand() end, opts)
  vim.keymap.set("n", "<Right>", function() browser.toggle_or_expand() end, opts)
  vim.keymap.set("n", "<CR>", function() browser.toggle_or_expand() end, opts)
  vim.keymap.set("n", "h", function()
    local node = browser.flat[browser.cursor]
    if node and node.is_dir and node.expanded then
      node.expanded = false
      browser.rebuild()
    end
  end, opts)
  vim.keymap.set("n", "<Left>", function()
    local node = browser.flat[browser.cursor]
    if node and node.is_dir and node.expanded then
      node.expanded = false
      browser.rebuild()
    end
  end, opts)
  vim.keymap.set("n", "p", function()
    local node = browser.flat[browser.cursor]
    if node then browser.preview_file(node) end
  end, opts)
  vim.keymap.set("n", "d", function()
    local node = browser.flat[browser.cursor]
    if node then browser.download_file(node) end
  end, opts)
  vim.keymap.set("n", "q", function()
    if browser.win and vim.api.nvim_win_is_valid(browser.win) then
      vim.api.nvim_win_close(browser.win, true)
    end
  end, opts)
  vim.keymap.set("n", "<Esc>", function()
    if browser.win and vim.api.nvim_win_is_valid(browser.win) then
      vim.api.nvim_win_close(browser.win, true)
    end
  end, opts)
end

function browser.open()
  -- Create buffer
  browser.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = browser.buf })
  vim.api.nvim_set_option_value("filetype", "sftp_browser", { buf = browser.buf })
  vim.api.nvim_set_option_value("modifiable", false, { buf = browser.buf })

  -- Open floating window
  local width = math.floor(vim.o.columns * 0.4)
  local height = math.floor(vim.o.lines * 0.7)
  local col = 2
  local row = math.floor((vim.o.lines - height) / 2)

  browser.win = vim.api.nvim_open_win(browser.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
    title = " SFTP Remote Browser ",
    title_pos = "center",
    footer = " j/k:nav  l/→:expand  h/←:collapse  p:preview  d:download  q:close ",
    footer_pos = "center",
  })

  vim.api.nvim_set_option_value("cursorline", true, { win = browser.win })
  vim.api.nvim_set_option_value("wrap", false, { win = browser.win })

  browser.nodes = {}
  browser.flat = {}
  browser.cursor = 1

  browser.setup_keymaps()

  -- Load root directory from config's remote_base
  -- We call `sw ls` with no args to list the remote_base
  browser.load_dir_root()
end

function browser.load_dir_root()
  local sw = get_sw()
  local stdout_parts = {}
  -- `sw ls` with no args lists the remote_base from config
  vim.fn.jobstart({ sw, "ls" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then table.insert(stdout_parts, line) end
        end
      end
    end,
    on_stderr = function(_, data)
      -- capture stderr for password prompts etc — ignore
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        if code ~= 0 then
          vim.notify("SFTP browser: failed to list remote directory", vim.log.levels.ERROR)
          return
        end
        local raw = table.concat(stdout_parts, "")
        local ok, entries = pcall(vim.json.decode, raw)
        if not ok or not entries then
          vim.notify("SFTP browser: failed to parse ls output", vim.log.levels.ERROR)
          return
        end
        table.sort(entries, function(a, b)
          if a.is_dir ~= b.is_dir then return a.is_dir end
          return a.name < b.name
        end)
        -- We need the remote_base to build paths. Read it from config.
        -- Since `sw ls` uses remote_base, child paths = remote_base/name
        -- We'll read the config to get remote_base
        browser.read_remote_base(function(remote_base)
          for _, e in ipairs(entries) do
            if not vim.startswith(e.name, ".") then
              table.insert(browser.nodes, {
                name = e.name,
                remote_path = remote_base .. "/" .. e.name,
                is_dir = e.is_dir,
                size = e.size or 0,
                depth = 0,
                expanded = false,
                children = nil,
              })
            end
          end
          browser.rebuild()
        end)
      end)
    end,
  })
end

function browser.read_remote_base(callback)
  -- Read remote_base from the yaml config
  local config_path = vim.fn.getcwd() .. "/.sftp-watcher.yaml"
  local lines = vim.fn.readfile(config_path)
  for _, line in ipairs(lines) do
    local base = line:match("^remote_base:%s*(.+)")
    if base then
      callback(base)
      return
    end
  end
  -- Fallback: try .vscode/sftp.json
  local sftp_path = vim.fn.getcwd() .. "/.vscode/sftp.json"
  if vim.fn.filereadable(sftp_path) == 1 then
    local content = table.concat(vim.fn.readfile(sftp_path), "")
    local ok, data = pcall(vim.json.decode, content)
    if ok and data and data.remotePath then
      callback(data.remotePath)
      return
    end
  end
  callback("/")
end

-- Plugin spec
return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>S",
      function()
        Snacks.terminal(get_sw(), {
          win = {
            position = "float",
            width = 0.6,
            height = 0.7,
            title = " SFTP Watcher ",
            title_pos = "center",
            border = "rounded",
          },
          interactive = true,
        })
      end,
      desc = "SFTP Watcher TUI",
    },
    {
      "<leader>sB",
      function()
        browser.open()
      end,
      desc = "SFTP Remote Browser",
    },
  },
}
