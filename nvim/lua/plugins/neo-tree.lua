return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    enable_git_status = true,
    git_status_async = true,
    sources = { "filesystem", "buffers", "git_status" },
    source_selector = {
      winbar = true,
      sources = {
        { source = "filesystem", display_name = " Files" },
        { source = "git_status", display_name = "󰊢 Git" },
      },
    },
    filtered_items = {
      visible = true,
      hide_dotfiles = false,
      hide_gitignored = false,
    },
    window = {
      width = 30,
    },
    filesystem = {
      use_libuv_file_watcher = true,
    },
    git_status = {
      symbols = {
        added     = "✚",
        modified  = "",
        deleted   = "✖",
        renamed   = "󰁕",
        untracked = "",
        ignored   = "",
        unstaged  = "󰄱",
        staged    = "",
        conflict  = "",
      },
    },
  },
}
