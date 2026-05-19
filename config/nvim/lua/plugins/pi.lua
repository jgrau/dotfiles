local pax_nvim = vim.fn.expand("~/src/pax/src/.pi/extensions/pax-nvim/nvim")

if vim.fn.isdirectory(pax_nvim) == 0 then
  return {}
end

return {
  {
    dir = pax_nvim,
    name = "pax-nvim",
    config = function()
      require("pax-nvim").setup({
        mappings = { "<leader>p" },
      })
    end,
  },
}
