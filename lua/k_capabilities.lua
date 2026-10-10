-- What this editor can do with what the language server sends: Neovim's
-- own abilities, and those of a completion plugin if one is installed
-- (nvim-cmp through cmp-nvim-lsp, or blink.cmp). It is what lets
-- completions arrive as calls with their arguments to fill in.
local M = {}

function M.plugin()
  if pcall(require, "cmp_nvim_lsp") then
    return "cmp"
  end
  if pcall(require, "blink.cmp") then
    return "blink"
  end
  return nil
end

function M.get()
  local caps = vim.lsp.protocol.make_client_capabilities()
  local ok, cmp = pcall(require, "cmp_nvim_lsp")
  if ok then
    return cmp.default_capabilities(caps)
  end
  local has_blink, blink = pcall(require, "blink.cmp")
  if has_blink and blink.get_lsp_capabilities then
    return blink.get_lsp_capabilities(caps)
  end
  return caps
end

return M
