-- ~/.config/nvim/lua/custom/twig-scanner.lua
local M = {}

M.classes = {}
M.ids = {}
M._timer = nil
M._interval = 30000
M._file_classes = {} -- per-file tracking
M._file_ids = {}

local function scan_file(file, relative)
  local ok, lines = pcall(vim.fn.readfile, file)
  if not ok then
    return {}, {}
  end

  local classes = {}
  local ids = {}

  for _, line in ipairs(lines) do
    for class_attr in line:gmatch("class=[\"']([^\"']+)[\"']") do
      for class in class_attr:gmatch("[%w_-]+") do
        classes[class] = true
      end
    end

    for id in line:gmatch("id=[\"']([^\"']+)[\"']") do
      -- Skip ids containing twig expressions
      if not id:match("{{") and not id:match("}}") then
        ids[id] = true
      end
    end
  end

  return classes, ids
end

local function rebuild_index()
  local classes = {}
  local ids = {}

  for relative, file_classes in pairs(M._file_classes) do
    for class in pairs(file_classes) do
      if not classes[class] then
        classes[class] = {}
      end
      classes[class][relative] = true
    end
  end

  for relative, file_ids in pairs(M._file_ids) do
    for id in pairs(file_ids) do
      if not ids[id] then
        ids[id] = {}
      end
      ids[id][relative] = true
    end
  end

  M.classes = classes
  M.ids = ids
end

local function full_scan()
  M._file_classes = {}
  M._file_ids = {}

  local cwd = vim.fn.getcwd()
  local twig_files = vim.fn.glob(cwd .. "/templates/**/*.twig", false, true)

  for _, file in ipairs(twig_files) do
    local relative = file:sub(#cwd + 2)
    local classes, ids = scan_file(file, relative)
    M._file_classes[relative] = classes
    M._file_ids[relative] = ids
  end

  rebuild_index()
end

function M.scan_single(filepath)
  local cwd = vim.fn.getcwd()
  local relative = filepath:sub(#cwd + 2)

  if not relative:match("^templates/") or not relative:match("%.twig$") then
    return
  end

  local classes, ids = scan_file(filepath, relative)
  M._file_classes[relative] = classes
  M._file_ids[relative] = ids
  rebuild_index()
end

function M.start()
  if M._timer then
    return
  end

  full_scan()

  -- Rescan on twig file save
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.twig",
    callback = function(event)
      M.scan_single(event.match)
    end,
  })

  M._timer = vim.uv.new_timer()
  M._timer:start(
    M._interval,
    M._interval,
    vim.schedule_wrap(function()
      full_scan()
    end)
  )
end

function M.stop()
  if M._timer then
    M._timer:stop()
    M._timer:close()
    M._timer = nil
  end
end

function M.rescan()
  full_scan()
  local class_count = vim.tbl_count(M.classes)
  local id_count = vim.tbl_count(M.ids)
  vim.notify(("Twig scanner: %d classes, %d ids"):format(class_count, id_count))
end

return M
