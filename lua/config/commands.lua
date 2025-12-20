vim.api.nvim_create_user_command("TwigTemplate", function()
  local template_path = vim.fn.stdpath("config") .. "/templates/template.twig"

  if vim.fn.filereadable(template_path) == 0 then
    vim.notify("Twig template not found!", vim.log.levels.ERROR)
    return
  end

  -- Read the template
  local lines = vim.fn.readfile(template_path)

  -- Prepare dynamic replacements
  local filename = vim.fn.expand("%:t:r") -- filename without extension
  local date = os.date("%Y-%m-%d")
  -- current date

  -- Replace placeholders
  for i, line in ipairs(lines) do
    line = line:gsub("##filename##", filename)
    line = line:gsub("##date##", date)
    lines[i] = line
  end

  -- Insert into buffer at the top
  vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
end, { desc = "Insert Twig template into current buffer" })

vim.api.nvim_create_user_command("NewTwig", function()
  -- Ask what type of file
  local kind = vim.fn.input("Create (page/component)? [p/c]: ")
  kind = kind:lower()

  if kind == "p" then
    kind = "page"
  elseif kind == "c" then
    kind = "component"
  end

  if kind ~= "page" and kind ~= "component" then
    vim.notify("Invalid type. Must be 'page' (p) or 'component' (c).", vim.log.levels.ERROR)
    return
  end

  -- Ask for filename
  local filename_input = vim.fn.input("Enter filename (without extension): ")
  if filename_input == "" then
    vim.notify("Filename cannot be empty.", vim.log.levels.ERROR)
    return
  end

  local cwd = vim.fn.getcwd()
  local twig_path
  local scss_path
  local filename_for_template = filename_input

  if kind == "page" then
    twig_path = cwd .. "/templates/_pages/" .. filename_input .. ".twig"
    scss_path = cwd .. "/web/assets/css/_pages/_" .. filename_input .. ".scss"
  else
    -- Components: underscore prefix
    twig_path = cwd .. "/templates/_components/_" .. filename_input .. ".twig"
    scss_path = cwd .. "/web/assets/css/_components/_" .. filename_input .. ".scss"
  end

  -- Make sure directories exist
  vim.fn.mkdir(vim.fn.fnamemodify(twig_path, ":h"), "p")
  vim.fn.mkdir(vim.fn.fnamemodify(scss_path, ":h"), "p")

  -- Ensure Twig file exists on disk
  if vim.fn.filereadable(twig_path) == 0 then
    vim.fn.writefile({}, twig_path) -- create empty file
  end

  -- Open Twig file
  vim.cmd("edit " .. twig_path)
  vim.bo.modifiable = true

  -- Insert template content for pages only
  if kind == "page" then
    local template_path = vim.fn.stdpath("config") .. "/templates/template.twig"
    if vim.fn.filereadable(template_path) == 1 then
      local lines = vim.fn.readfile(template_path)
      local date = os.date("%Y-%m-%d")
      for i, line in ipairs(lines) do
        lines[i] = line:gsub("##filename##", filename_for_template):gsub("##date##", date)
      end
      vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
    end
  end

  -- Create SCSS file for both pages and components
  if vim.fn.filereadable(scss_path) == 0 then
    -- Path to global SCSS template
    local scss_template = vim.fn.stdpath("config") .. "/templates/template.scss"
    local scss_lines = {}

    if kind == "page" then
      if vim.fn.filereadable(scss_template) == 1 then
        -- Read template
        scss_lines = vim.fn.readfile(scss_template)
        -- Replace ##filename## with actual filename
        for i, line in ipairs(scss_lines) do
          scss_lines[i] = line:gsub("##filename##", filename_for_template)
        end
      else
        -- Fallback: minimal SCSS if template not found
        scss_lines = {
          "/* " .. filename_for_template .. ".scss */",
          "",
          "main." .. filename_for_template .. " {",
          "}",
          "",
        }
      end
    else
      -- Inline SCSS template for components
      scss_lines = {
        "/* " .. filename_for_template .. ".scss */",
        '@use "../variables" as v;',
        '@use "../utils" as u;',
        "",
        "section." .. filename_for_template .. " {",
        "}",
        "",
      }
    end

    -- Write new SCSS file
    vim.fn.writefile(scss_lines, scss_path)
    vim.notify("SCSS file created: " .. scss_path)
  end

  -- After creating the SCSS file
  local main_scss = cwd .. "/web/assets/css/styles.scss"
  if vim.fn.filereadable(main_scss) == 1 then
    local import_path
    local section_found = false
    if kind == "page" then
      import_path = "_pages/_" .. filename_for_template
    else
      import_path = "_components/_" .. filename_for_template
    end
    local import_line = string.format('@use "%s";', import_path)

    -- Read styles.scss
    local lines = vim.fn.readfile(main_scss)
    local exists = false
    for _, line in ipairs(lines) do
      if line == import_line then
        exists = true
        break
      end
    end

    if not exists then
      -- Find the last import in the correct section
      local insert_index = 0
      for i, line in ipairs(lines) do
        if kind == "page" and line:match('^@use "_pages/') then
          insert_index = i
        elseif kind == "component" and line:match('^@use "_components/') then
          insert_index = i
        end
      end

      -- If no section exists yet, append at the end
      if insert_index == 0 then
        table.insert(lines, "")
        table.insert(lines, import_line)
      else
        table.insert(lines, insert_index + 1, import_line)
      end

      vim.fn.writefile(lines, main_scss)
      vim.notify("Added @use to styles.scss: " .. import_path)
    end
  end

  local kind_cap = kind:gsub("^%l", string.upper)
  vim.notify(kind_cap .. " created: " .. twig_path)
end, { desc = "Create new Craft CMS Twig page/component scaffold" })
