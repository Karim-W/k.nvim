# k.nvim — k for Neovim: syntax from the tree-sitter grammar, and the
# language server (`k lsp`) started for every k buffer.
#
#   make install    puts the plugin where Neovim loads it by itself
#
#   NVIM_DIR=...    where (default: ~/.local/share/nvim/site/pack/k/start/k)
#   TS=...          the tree-sitter-k checkout (default: ../tree-sitter-k)
#   K=...           the `k` the plugin is to run (default: $(PREFIX)/bin/k if
#                   it is there, else the `k` on PATH)
NVIM_DIR ?= $(HOME)/.local/share/nvim/site/pack/k/start/k
TS ?= ../tree-sitter-k
PREFIX ?= $(HOME)/.local
K ?= $(shell if [ -x "$(PREFIX)/bin/k" ]; then echo "$(PREFIX)/bin/k"; else command -v k; fi)

install:
	$(MAKE) -C $(TS)
	mkdir -p $(NVIM_DIR)/lua $(NVIM_DIR)/parser $(NVIM_DIR)/queries/k
	cp -R ftdetect ftplugin lsp plugin lua $(NVIM_DIR)/
	cp $(TS)/build/k.so $(NVIM_DIR)/parser/k.so
	cp $(TS)/queries/*.scm $(NVIM_DIR)/queries/k/
	@printf 'return { k = "%s" }\n' "$(K)" > $(NVIM_DIR)/lua/k_install.lua
	@echo "installed the Neovim plugin in $(NVIM_DIR) (it runs $(K))"

.PHONY: install
