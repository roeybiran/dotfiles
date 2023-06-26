return {
  { "akinsho/toggleterm.nvim", version = "*", config = true },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      table.insert(opts.ensure_instsalled, "prettierd")
      table.insert(opts.ensure_instsalled, "stylua")
      table.insert(opts.ensure_instsalled, "shellcheck")
      table.insert(opts.ensure_instsalled, "shfmt")
    end,
  },
}
