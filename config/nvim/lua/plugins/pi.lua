return {
  {
    dir = "/Users/jgrau/src/pax/src/.pi/extensions/pax-nvim/nvim",
    name = "pax-nvim",
    config = function()
      require("pax-nvim").setup({
        mappings = { "<leader>p" },
      })
    end,
  },
}
