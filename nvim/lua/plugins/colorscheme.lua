return {
	{
		"scottmckendry/cyberdream.nvim",
		lazy = false,
		priority = 1000,
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "cyberdream",
		},
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		init = function()
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "*",
				callback = function()
					vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "#0a0a1a" })
					vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "#0a0a1a" })
					vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "#0a0a1a" })
				end,
			})
		end,
	},
}
