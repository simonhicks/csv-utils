" TODO
" - make separator configurable
" - make Table view
" - make other commands
" - make all the commands explicitly pass in the configured seperator
" - make a (configurable) quote character
" - make it so the csv utils don't need to be in $PATH

let g:csv_utils_field_seperator = ","

" runs cmdStr with the contents of a:lines as STDIN and returns
" STDOUT as a List of lines.
function! s:pipeLinesToCommand(lines, cmdStr)
  let tmp = tempname()
  call writefile(a:lines, tmp)
  let output = system("cat ".tmp." | ".a:cmdStr)
  call system("rm ".tmp)
  return split(output, "\n")
endfunction

function! s:displayLines(lines)
  let pos = getpos('.')
  set noreadonly
  0,$d
  call append(0, a:lines)
  $d
  set readonly
  call setpos('.', pos)
endfunction

function! s:updateBufferWithCommand(cmd)
  let lines = getline(0, line("$"))
  call s:displayLines(s:pipeLinesToCommand(lines, a:cmd))
endfunction

function! csv#enrich(lookupFile)
  let b:autocompleteFileName = a:lookupFile
  call inputsave()
  let dataKey = input("Data key: ", '', 'customlist,csv#bufferCols')
  let lookupKey = input("Lookup key: ", '', 'customlist,csv#fileCols')
  call inputrestore()
  call s:updateBufferWithCommand("enrich -l ".fnamemodify(a:lookupFile, ':p')." -k ".lookupKey." -d ".dataKey)
endfunction

function! s:askColumnSpec()
  call inputsave()
  let columnSpec = ""
  let sep = ""
  let more = "true"
  while (more == "true")
    let col = input("Column: ", '', 'customlist,csv#bufferCols')
    if (col == "")
      let more = "false"
    else
      let columnSpec = columnSpec.sep.col
      let sep = ","
    endif
  endwhile
  call inputrestore()
  echom columnSpec
  return columnSpec
endfunction

function! csv#columns()
  call s:updateBufferWithCommand("columns ".s:askColumnSpec())
endfunction

function! csv#table()
  call s:updateBufferWithCommand("table")
endfunction

function! csv#countBy()
  call inputsave()
  let groupBy = input("Group by column: ", '', 'customlist,csv#bufferCols')
  let unique = input("Unique column: ", '', 'customlist,csv#bufferCols')
  call inputrestore()
  let opts = ""
  if (groupBy != "")
    let opts = opts."-g ".groupBy
  endif
  if (unique != "")
    let opts = opts."-u ".unique
  endif
  call s:updateBufferWithCommand("count-by ".opts)
endfunction

function! csv#aggregate()
  call inputsave()
  let aggregation = input("Aggregation: ", 'sum', 'customlist,csv#aggregations')
  let column = input("Column: ", '', 'customlist,csv#bufferCols')
  let groupBy = input("Group by column: ", '', 'customlist,csv#bufferCols')
  call inputrestore()
  let opts = ""
  if (groupBy != "")
    let opts = opts." -g ".groupBy
  endif
  if (column != "")
    let opts = opts." -c ".column
  endif
  if (aggregation != "")
    let opts = opts." -a ".aggregation
  endif
  call s:updateBufferWithCommand("aggregate ".opts)
endfunction

function! csv#sortBy()
  call inputsave()
  let column = input("Column: ", '', 'customlist,csv#bufferCols')
  let direction = input("Direction: ", 'ascending', 'customlist,csv#sortDirections')
  call inputrestore()
  let opts = ""
  if (column != "")
    let opts = opts." -c ".column
  endif
  if (direction == "descending")
    let opts = opts." -d desc"
  elseif (direction == "ascending")
    let opts = opts." -d asc"
  endif
  call s:updateBufferWithCommand("sort-by ".opts)
endfunction

function! csv#filter()
  call inputsave()
  let condition = input("Condition: ")
  let invert = input("Invert? ", 'no', 'customlist,csv#yes_no')
  call inputrestore()
  let opts = ""
  if (condition != "")
    let opts = opts." -c '".condition."'"
  endif
  if (invert == "yes")
    let opts = opts." -n"
  endif
  call s:updateBufferWithCommand("filter ".opts)
endfunction

function! csv#derive()
  call inputsave()
  let expr = input("Expression: ")
  let name = input("Column name: ")
  call inputrestore()
  call s:updateBufferWithCommand("derive -c ".name." -e '".expr."'")
endfunction

function! csv#keep(lookupFile)
  let b:autocompleteFileName = a:lookupFile
  call inputsave()
  let dataKey = input("Data key: ", '', 'customlist,csv#bufferCols')
  let lookupKey = input("Lookup key: ", '', 'customlist,csv#fileCols')
  let invert = input("Invert? ", 'no', 'customlist,csv#yes_no')
  call inputrestore()
  let opts = ""
  if (invert == "yes")
    let opts = opts." -n"
  endif
  call s:updateBufferWithCommand("keep -l ".fnamemodify(a:lookupFile, ':p')." -k ".lookupKey." -d ".dataKey.opts)
endfunction

function! s:bufferWidth()
  redir =>a
  exe "sil sign place buffer=".bufnr('')
  redir end
  let signlist = split(a, '\n')
  return winwidth(0) - &numberwidth - &foldcolumn - (len(signlist) > 2 ? 2 : 0)
endfunction

function! csv#barChart()
  call inputsave()
  let labelCol = input("Label column: ", '', 'customlist,csv#bufferCols')
  let valueCol = input("Value column: ", '', 'customlist,csv#bufferCols')
  call inputrestore()
  call s:updateBufferWithCommand("bar-chart -w ".s:bufferWidth()." -l ".labelCol." -c ".valueCol)
endfunction

function! csv#fileCols(a, b, c)
  let line = readfile(b:autocompleteFileName)[0]
  return split(line, g:csv_utils_field_seperator)
endfunction

function! csv#bufferCols(a, b, c)
  let line = getline(1)
  return split(line, g:csv_utils_field_seperator)
endfunction

function! csv#aggregations(a, b, c)
  return ['sum', 'min', 'max', 'mean']
endfunction

function! csv#sortDirections(a, b, c)
  return ['ascending', 'descending']
endfunction
