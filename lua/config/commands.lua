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
