command! -nargs=1 -complete=file -buffer Enrich call csv#enrich(<f-args>)
