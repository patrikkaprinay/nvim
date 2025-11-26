return {
  "ibhagwan/fzf-lua",
  opts = {
    -- global defaults
    files = {
      -- hidden = true, -- show dotfiles like .gitignore
      -- ignored = false,
      -- git icons/on may vary by your setup; not required for hidden
      -- To also show files ignored by .gitignore (including the .gitignore file itself):
      rg_opts = [[--color=never --files --hidden --no-ignore --follow --ignore-vcs -g "!node_modules"]],
      fd_opts = [[--color=never --type f --hidden --follow --exclude .git --exclude node_modules]],
    },
  },
}
