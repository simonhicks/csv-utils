command! -nargs=1 -complete=file -buffer CsvEnrich call csv#enrich(<f-args>)
command! -nargs=0 -buffer CsvColumns call csv#columns()
command! -nargs=0 -buffer CsvTable call csv#table()
command! -nargs=0 -buffer CsvCountBy call csv#countBy()
command! -nargs=0 -buffer CsvAggregate call csv#aggregate()
command! -nargs=0 -buffer CsvSortBy call csv#sortBy()
command! -nargs=0 -buffer CsvFilter call csv#filter()
command! -nargs=0 -buffer CsvDerive call csv#derive()
command! -nargs=1 -complete=file -buffer CsvKeep call csv#keep(<f-args>)
command! -nargs=0 -buffer CsvBarChart call csv#barChart()
