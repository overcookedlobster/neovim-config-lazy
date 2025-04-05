-- ~/.config/nvim/lua/plugins/tools.lua
-- Tools and utilities

return {
  -- Parrot.nvim - AI integration
  {
    "frankroeder/parrot.nvim",
    dependencies = {
      "ibhagwan/fzf-lua",
      "nvim-lua/plenary.nvim",
      "rcarriga/nvim-notify"
    },
    config = function()
      require("parrot").setup({
        providers = {
          anthropic = {
            api_key = os.getenv "ANTHROPIC_API_KEY",
            endpoint = "https://api.anthropic.com/v1/messages",
            topic_prompt = "You only respond with 3 to 4 words to summarize the past conversation.",
            topic = {
              model = "claude-3-haiku-20240307",
              params = { max_tokens = 32 },
            },
            params = {
              chat = { max_tokens = 4096 },
              command = { max_tokens = 4096 },
            },
          },
          -- ollama = {},
          xai = {
            api_key = os.getenv "XAI_API_KEY",
          },
          gemini = {
            api_key = os.getenv "GEMINI_API_KEY",
          },
          nvidia = {
            api_key = os.getenv "NVIDIA_API_KEY",
          },
          deepseek = {
            style = "openai",
            api_key = os.getenv "DEEPSEEK_API_KEY",
            endpoint = "https://api.deepseek.com/v1/chat/completions",
            models = {
              "deepseek-chat",      -- DeepSeek-V3
              "deepseek-reasoner",  -- DeepSeek-R1
            },
            -- parameters to summarize chat
            topic = {
              model = "deepseek-chat",
              params = { max_completion_tokens = 64 },
            },
            -- default parameters
            params = {
              chat = { temperature = 0.7, top_p = 1 },    -- using standard temperature
              command = { temperature = 0.7, top_p = 1 },
            },
          },
          igpt = {
            style = "openai",
            api_key = os.getenv "IGPT_API_KEY",
            endpoint = "http://localhost:8000/v1/chat/completions",
            models = {
              "gpt-4o",  -- DeepSeek-R1
            },
            -- parameters to summarize chat
            topic = {
              model = "gpt-4o",
              params = { max_completion_tokens = 64 },
            },
            -- default parameters
            params = {
              chat = { temperature = 0.7, top_p = 1 },    -- using standard temperature
              command = { temperature = 0.7, top_p = 1 },
            },
          }
        },

        cmd_prefix = "Prt",
        chat_conceal_model_params = false,
        user_input_ui = "buffer",
        toggle_target = "vsplit",
        online_model_selection = true,
        command_auto_select_response = true,

        hooks = {
          Complete = function(prt, params)
            local template = [[
            I have the following code from {{filename}}:

            ```{{filetype}}
            {{selection}}
            ```

            Please finish the code above carefully and logically.
            Respond just with the snippet of code that should be inserted."
            ]]
            local model_obj = prt.get_model "command"
            prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
          end,

          CompleteFullContext = function(prt, params)
            local template = [[
            I have the following code from {{filename}}:

            ```{{filetype}}
            {{filecontent}}
            ```

            Please look at the following section specifically:
            ```{{filetype}}
            {{selection}}
            ```

            Please finish the code above carefully and logically.
            Respond just with the snippet of code that should be inserted.
            ]]
            local model_obj = prt.get_model "command"
            prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
          end,

          CompleteMultiContext = function(prt, params)
            local template = [[
            I have the following code from {{filename}} and other realted files:

            ```{{filetype}}
            {{multifilecontent}}
            ```

            Please look at the following section specifically:
            ```{{filetype}}
            {{selection}}
            ```

            Please finish the code above carefully and logically.
            Respond just with the snippet of code that should be inserted.
            ]]
            local model_obj = prt.get_model "command"
            prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
          end,

          Explain = function(prt, params)
            local template = [[
            Your task is to take the code snippet from {{filename}} and explain it with gradually increasing complexity.
            Break down the code's functionality, purpose, and key components.
            The goal is to help the reader understand what the code does and how it works.

            ```{{filetype}}
            {{selection}}
            ```

            Use the markdown format with codeblocks and inline code. Explanation of the code above:
            ]]
            local model = prt.get_model "command"
            prt.logger.info("Explaining selection with model: " .. model.name)
            prt.Prompt(params, prt.ui.Target.new, model, nil, template)
          end,

          ExplainWithContext = function(prt, params)
            local template = [[
            Your task is to take the code snippet from {{filename}} and explain it with gradually increasing complexity.
            Break down the code's functionality, purpose, and key components.
            The goal is to help the reader understand what the code does and how it works.

            Below is the snippet to be mindful of.
            ```{{filetype}}
            {{selection}}
            ```

            Below is the full file content
            ```{{filetype}}
            {{filecontent}}
            ```

            Use the markdown format with codeblocks and inline code. Explanation of the code above:
            ]]
            local model = prt.get_model "command"
            prt.logger.info("Explaining selection with model: " .. model.name)
            prt.Prompt(params, prt.ui.Target.new, model, nil, template)
          end,

          FixBugs = function(prt, params)
            local template = [[
            You are an expert in {{filetype}}.
            Fix bugs in the below code from {{filename}} carefully and logically:
            Your task is to analyze the provided {{filetype}} code snippet, identify
            any bugs or errors present, and provide a corrected version of the code
            that resolves these issues. Explain the problems you found in the
            original code and how your fixes address them. The corrected code should
            be functional, efficient, and adhere to best practices in
            {{filetype}} programming.

            ```{{filetype}}
            {{selection}}
            ```

            Fixed code:
            ]]
            local model_obj = prt.get_model "command"
            prt.logger.info("Fixing bugs in selection with model: " .. model_obj.name)
            prt.Prompt(params, prt.ui.Target.new, model_obj, nil, template)
          end,

          Optimize = function(prt, params)
            local template = [[
            You are an expert in {{filetype}}.
            Your task is to analyze the provided {{filetype}} code snippet and
            suggest improvements to optimize its performance. Identify areas
            where the code can be made more efficient, faster, or less
            resource-intensive. Provide specific suggestions for optimization,
            along with explanations of how these changes can enhance the code's
            performance. The optimized code should maintain the same functionality
            as the original code while demonstrating improved efficiency.

            ```{{filetype}}
            {{selection}}
            ```

            Optimized code:
            ]]
            local model_obj = prt.get_model "command"
            prt.logger.info("Optimizing selection with model: " .. model_obj.name)
            prt.Prompt(params, prt.ui.Target.new, model_obj, nil, template)
          end,

          UnitTests = function(prt, params)
            local template = [[
            I have the following code from {{filename}}:

            ```{{filetype}}
            {{selection}}
            ```

            Please respond by writing table driven unit tests for the code above.
            ]]
            local model_obj = prt.get_model "command"
            prt.logger.info("Creating unit tests for selection with model: " .. model_obj.name)
            prt.Prompt(params, prt.ui.Target.enew, model_obj, nil, template)
          end,

          Debug = function(prt, params)
            local template = [[
            I want you to act as {{filetype}} expert.
            Review the following code, carefully examine it, and report potential
            bugs and edge cases alongside solutions to resolve them.
            Keep your explanation short and to the point:

            ```{{filetype}}
            {{selection}}
            ```
            ]]
            local model_obj = prt.get_model "command"
            prt.logger.info("Debugging selection with model: " .. model_obj.name)
            prt.Prompt(params, prt.ui.Target.enew, model_obj, nil, template)
          end,

          CommitMsg = function(prt, params)
            local futils = require "parrot.file_utils"
            if futils.find_git_root() == "" then
              prt.logger.warning "Not in a git repository"
              return
            else
              local template = [[
              I want you to act as a commit message generator. I will provide you
              with information about the task and the prefix for the task code, and
              I would like you to generate an appropriate commit message using the
              conventional commit format. Do not write any explanations or other
              words, just reply with the commit message.
              Start with a short headline as summary but then list the individual
              changes in more detail.

              Here are the changes that should be considered by this message:
              ]] .. vim.fn.system "git diff --no-color --no-ext-diff --staged"
              local model_obj = prt.get_model "command"
              prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
            end
          end,

          SpellCheck = function(prt, params)
            local chat_prompt = [[
            Your task is to take the text provided and rewrite it into a clear,
            grammatically correct version while preserving the original meaning
            as closely as possible. Correct any spelling mistakes, punctuation
            errors, verb tense issues, word choice problems, and other
            grammatical mistakes.
            ]]
            prt.ChatNew(params, chat_prompt)
          end,

          CodeConsultant = function(prt, params)
            local chat_prompt = [[
              Your task is to analyze the provided {{filetype}} code and suggest
              improvements to optimize its performance. Identify areas where the
              code can be made more efficient, faster, or less resource-intensive.
              Provide specific suggestions for optimization, along with explanations
              of how these changes can enhance the code's performance. The optimized
              code should maintain the same functionality as the original code while
              demonstrating improved efficiency.

              Here is the code
              ```{{filetype}}
              {{filecontent}}
              ```
            ]]
            prt.ChatNew(params, chat_prompt)
          end,

          ProofReader = function(prt, params)
            local chat_prompt = [[
            I want you to act as a proofreader. I will provide you with texts and
            I would like you to review them for any spelling, grammar, or
            punctuation errors. Once you have finished reviewing the text,
            provide me with any necessary corrections or suggestions to improve the
            text. Highlight the corrected fragments (if any) using markdown backticks.

            When you have done that subsequently provide me with a slightly better
            version of the text, but keep close to the original text.

            Finally provide me with an ideal version of the text.

            Whenever I provide you with text, you reply in this format directly:

            ## Corrected text:

            {corrected text, or say "NO_CORRECTIONS_NEEDED" instead if there are no corrections made}

            ## Slightly better text

            {slightly better text}

            ## Ideal text

            {ideal text}
            ]]
            prt.ChatNew(params, chat_prompt)
          end
        }
      })
    end,
  },

  -- Dispatch - Asynchronous build and test dispatcher
  {
    "tpope/vim-dispatch",
    cmd = { "Dispatch", "Make", "Focus", "Start" },
    init = function()
      -- Disable vim-dispatch's default key mappings
      vim.g.dispatch_no_maps = 1
    end,
  },

  -- Plenary - Lua utility functions
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },

}
