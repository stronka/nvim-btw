local M = {}

local vim = vim

M.setup = function()
	vim.cmd([[
      autocmd BufWritePost *.tex silent !mkdir -p output && pdflatex --output-directory=output <afile>
      autocmd FileType tex setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
  ]])
end

return M
