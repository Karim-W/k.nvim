-- Buffer settings for k source files.
if vim.b.did_ftplugin_k then
  return
end
vim.b.did_ftplugin_k = true

local opt = vim.opt_local
opt.commentstring = "// %s"
opt.comments = "s1:/*,mb:*,ex:*/,://"
opt.expandtab = true
opt.shiftwidth = 4
opt.softtabstop = 4
opt.tabstop = 4
opt.autoindent = true
opt.smartindent = true
opt.formatoptions:remove("t")
opt.formatoptions:append("croql")
opt.suffixesadd = ".k"

-- Syntax from the tree-sitter grammar (parser/k.so and queries/k/ of this plugin).
local ok = pcall(vim.treesitter.start, 0, "k")
if ok then
  opt.foldmethod = "expr"
  opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  opt.foldlevel = 99
end
