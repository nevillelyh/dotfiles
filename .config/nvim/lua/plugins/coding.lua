return {
  { 'airblade/vim-gitgutter' },
  {
    'dense-analysis/ale',
    init = function()
      vim.g.ale_python_flake8_options = '--max-line-length=120'
    end,
  },
  {
    'junegunn/fzf',
    init = function()
      vim.g.fzf_action = {
        ['ctrl-t'] = 'tab split',
        ['ctrl-s'] = 'split',
        ['ctrl-v'] = 'vsplit',
      }
      vim.g.fzf_layout = {
        window = {
          width = 0.9,
          height = 0.6,
          relative = true,
          yoffset = 0.1,
        }
      }
      local fzf_git = ':FZF<CR>'
      local fzf_all = ':call fzf#run(fzf#wrap({"source": "find . -type f"}))<CR>'
      vim.api.nvim_set_keymap('n', '<A-o>', fzf_git, { silent = true, })
      vim.api.nvim_set_keymap('n', '<A-O>', fzf_all, { silent = true, })
    end,
  },
  {
    'kamykn/spelunker.vim',
    init = function()
      -- https://github.com/kamykn/spelunker.vim/issues/63
      vim.api.nvim_create_autocmd({'ColorScheme'}, {
        pattern = {'*'},
        callback = function()
          vim.cmd([[
            highlight SpelunkerSpellBad cterm=underline ctermfg=247 gui=underline guifg=#9e9e9e
            highlight SpelunkerComplexOrCompoundWord cterm=underline ctermfg=NONE gui=underline guifg=NONE
          ]])
        end,
      })
    end,
  },
  { 'tpope/vim-fugitive' },
}
