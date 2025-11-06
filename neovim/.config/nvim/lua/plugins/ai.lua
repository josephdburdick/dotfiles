return {
  -- GPT-based AI assistance
  {
    "robitx/gp.nvim",
    config = function()
      local conf = {
        -- For customization, refer to Install > Configuration in the Documentation/Readme
        openai_api_key = os.getenv("OPENAI_API_KEY"),
      }
      require("gp").setup(conf)
    end,
  },

  -- Primary AI code completion (NeoCodeium)
  {
    "monkoose/neocodeium",
    event = "VeryLazy",
    opts = function()
      require("neocodeium").setup({
        silent = true,
        manual = false,    -- Enable automatic suggestions
        show_label = true, -- Show completion source in popup
        filetypes = {
          -- Disable for certain file types if needed
          -- help = false,
        },
      })
    end,
  },

  -- Alternative AI completion (Supermaven) - as fallback
  {
    "supermaven-inc/supermaven-nvim",
    event = "VeryLazy",
    opts = {
      keymaps = {
        accept_suggestion = "<C-A-m>", -- Alternative accept key
        clear_suggestion = "<C-A-c>",
        accept_word = "<C-A-w>",
      },
      log_level = "warn",                -- Reduce noise
      disable_keymaps = true,            -- We'll handle keymaps manually
      disable_inline_completion = false, -- Enable inline suggestions
      condition = function()
        -- Only enable if neocodeium is not available or fails
        return not require("neocodeium").get_status or require("neocodeium").get_status() ~= "suggest"
      end,
    },
  },

  -- Enhanced AI assistant with chat interface
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/nvim-cmp",
    },
    event = "VeryLazy",
    opts = {
      strategies = {
        chat = {
          adapter = "openai",
          keymaps = {
            close = { modes = { n = "q", i = "<C-c>" } },
            stop = { modes = { n = "<C-s>" } },
            send = { modes = { n = "<CR>", i = "<C-CR>" } },
          },
        },
        inline = {
          adapter = "openai",
        },
      },
      adapters = {
        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            env = {
              api_key = "OPENAI_API_KEY",
            },
            schema = {
              model = {
                default = "gpt-4o-mini", -- Use faster model for inline
              },
            },

          })
        end,
      },
    },
  },


  -- Better text object selection for AI context
  {
    "nvim-mini/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
        },
      }
    end,
  },
  -- Advanced AI coding assistant (Avante)
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false,       -- set this if you want to always pull the latest change
    opts = {
      provider = "openai", -- Use OpenAI instead of copilot
      providers = {
        openai = {
          endpoint = "https://api.openai.com/v1",
          model = "gpt-4o", -- Use the latest model
          timeout = 30000,  -- Timeout in milliseconds
          max_tokens = 4096,
          extra_request_body = {
            temperature = 0,
          },
        },
      },
      -- Cursor-like behavior
      behaviour = {
        auto_suggestions = false, -- Don't auto-suggest, wait for user trigger
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = true,
      },
      -- Enhanced UI
      highlights = {
        diff = {
          current = "DiffText",
          incoming = "DiffAdd",
        },
      },
      -- Mappings for sidebar and chat
      mappings = {
        sidebar = {
          close = { "<Esc>", "q" },
          switch_windows = "<Tab>",
          reverse_switch_windows = "<S-Tab>",
        },
        suggestion = {
          accept = "<M-l>", -- Alt+L for accepting suggestions
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "nvim-tree/nvim-web-devicons",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
