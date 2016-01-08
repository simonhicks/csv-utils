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

function! csv#fileCols(a, b, c)
  let line = readfile(b:autocompleteFileName)[0]
  return split(line, g:csv_utils_field_seperator)
endfunction

function! csv#bufferCols(a, b, c)
  let line = getline(1)
  return split(line, g:csv_utils_field_seperator)
endfunction
