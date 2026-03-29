-- noice.nvim
-- github https://github.com/folke/noice.nvim
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>sn", "", desc = "+[N]oice" },
    { "<leader>snl", function() require("noice").cmd("last") end, desc = "[L]ast message" },
    { "<leader>snh", function() require("noice").cmd("history") end, desc = "[H]istory" },
    { "<leader>sne", function() require("noice").cmd("errors") end, desc = "[E]rrors" },
    { "<leader>snt", function() require("noice").cmd("pick") end, desc = "[T]elescope browse" },
    { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "[D]ismiss all" },
  },
  opts = {
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      },
    },
    views = {
      mini = {
        timeout = 3000, -- default for most messages
        reverse = false,
      },
    },
    routes = {
      -- skip "written" messages
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "written",
        },
        opts = { skip = true },
      },
      -- skip search count messages
      {
        filter = {
          event = "msg_show",
          kind = "search_count",
        },
        opts = { skip = true },
      },
      -- errors stay longer (8s)
      {
        filter = { error = true },
        view = "mini",
        opts = { timeout = 8000 },
      },
      -- warnings stay a bit longer (5s)
      {
        filter = { warning = true },
        view = "mini",
        opts = { timeout = 5000 },
      },
    },
    presets = {
      bottom_search = true,
      long_message_to_split = true,
      lsp_doc_border = true,
    },
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
}
