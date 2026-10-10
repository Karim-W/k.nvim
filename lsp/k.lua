-- The k language server, for Neovim 0.11 and later (`vim.lsp.enable("k")`).
local ok, install = pcall(require, "k_install")
local k = vim.g.k_command or (ok and install.k) or "k"

return {
  cmd = { k, "lsp" },
  filetypes = { "k" },
  root_markers = { "k.mod", ".git" },
  capabilities = require("k_capabilities").get(),
}
