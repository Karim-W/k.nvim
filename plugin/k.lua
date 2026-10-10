-- k for Neovim: starts the language server for k buffers and sets a few
-- buffer-local keys when it attaches.
--
--   vim.g.k_command = "/path/to/k"     which compiler to run as `k lsp` (default: the one this plugin was installed with)
--   vim.g.k_format_on_save = true      run the formatter when a k file is written
--   vim.g.k_inlay_hints = true         show the types that declarations leave out
--   vim.g.k_no_default_keys = true     leave the keys below unmapped
--   vim.g.k_no_completion = true       do not turn on Neovim's own completion as you type
--                                      (it is turned on only when no completion plugin is installed)
if vim.g.loaded_k_plugin then
  return
end
vim.g.loaded_k_plugin = true

local group = vim.api.nvim_create_augroup("k_lang", { clear = true })

if vim.lsp.enable then
  vim.lsp.enable("k")
else
  -- Neovim before 0.11: start the server by hand
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "k",
    callback = function(args)
      local ok, install = pcall(require, "k_install")
      local k = vim.g.k_command or (ok and install.k) or "k"
      local root = vim.fs.dirname(vim.fs.find({ "k.mod", ".git" }, { upward = true, path = vim.api.nvim_buf_get_name(args.buf) })[1])
      vim.lsp.start({ name = "k", cmd = { k, "lsp" }, root_dir = root, capabilities = require("k_capabilities").get() })
    end,
  })
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "k" then
      return
    end
    local buf = args.buf
    if not vim.g.k_no_default_keys then
      local function map(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
      end
      map("gd", vim.lsp.buf.definition, "k: go to definition")
      map("K", vim.lsp.buf.hover, "k: show what this is")
      map("<leader>kf", function()
        vim.lsp.buf.format({ async = false })
      end, "k: format the file")
      map("<leader>ks", vim.lsp.buf.document_symbol, "k: the file's declarations")
      map("<leader>kr", vim.lsp.buf.references, "k: every use of this name")
      map("<leader>kn", vim.lsp.buf.rename, "k: rename this everywhere")
      map("<leader>ka", vim.lsp.buf.code_action, "k: fix what is wrong here")
      map("<leader>kw", vim.lsp.buf.workspace_symbol, "k: find a declaration in the program")
      map("<leader>kh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
      end, "k: show or hide the types that are left out")
      vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, { buffer = buf, desc = "k: the parameters of the call being typed" })
    end
    vim.bo[buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    -- Completion as you type. A completion plugin (nvim-cmp, blink.cmp) does
    -- that by itself; without one, Neovim's own is turned on (0.11 and
    -- later), and told to ask on every letter, not only after a `.`.
    if not vim.g.k_no_completion and not require("k_capabilities").plugin() and vim.lsp.completion and vim.lsp.completion.enable then
      local provider = client.server_capabilities.completionProvider
      if provider then
        local chars = {}
        for c in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"):gmatch(".") do
          chars[#chars + 1] = c
        end
        for _, c in ipairs(provider.triggerCharacters or {}) do
          chars[#chars + 1] = c
        end
        provider.triggerCharacters = chars
      end
      vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
      if not vim.o.completeopt:find("noselect") then
        vim.opt.completeopt = { "menuone", "noselect", "popup" }
      end
    end
    if vim.g.k_inlay_hints and vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(true, { bufnr = buf })
    end
    if vim.g.k_format_on_save then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        buffer = buf,
        callback = function()
          vim.lsp.buf.format({ async = false, timeout_ms = 3000 })
        end,
      })
    end
  end,
})
