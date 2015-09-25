# CSV Utils

This is a collection of bash scripts for manipulating csv files. The best way to describe it is with
examples, so here goes. The following examples use the data from the test-data directory in this
repo. 

## Test data

### sales.csv

This is sales data for a fictional disney movie distributor with stores all around the world. The
first 10 rows look like this:

date     | location | film | format | amount
--------------------------------------------
20150908 | Tokyo  | 78 | mp4    | 16.99
20150909 | Tokyo  | 26 | mp4    | 15.99
20150901 | Berlin | 99 | BluRay | 15.99
20150912 | London | 93 | DVD    | 14.99
20150912 | Berlin | 51 | HDDVD  | 14.99
20150903 | London | 6  | VCR    | 15.99
20150918 | NYC    | 1  | VCR    | 17.99
20150930 | Tokyo  | 55 | VCR    | 17.99
20150913 | Berlin | 78 | DVD    | 16.99
20150917 | Tokyo  | 33 | BluRay | 16.99


### titles.csv

This is a list of all the movies that the same distributor sells, along with some additional data.
The first 10 rows look like this:

id | title                          | date     | studio                           | price
-----------------------------------------------------------------------------------------
58 | The Jungle Book 2              | 20030214 | DisneyToon Studios               | 14.99
88 | Winnie the Pooh                | 20110715 | Walt Disney                      | 17.99
9  | Fun and Fancy Free             | 19470927 | Walt Disney                      | 17.99
93 | Frankenweenie                  | 20121105 | Tim Burton[st 3]                 | 14.99
83 | Toy Story 3                    | 20100618 | Pixar Animation Studios          | 18.99
3  | Fantasia                       | 19401113 | Walt Disney                      | 15.99
51 | Recess: School's Out           | 20010216 | Walt Disney Television Animation | 14.99
50 | The Emperor's New Groove       | 20001215 | Walt Disney                      | 18.99
34 | The Nightmare Before Christmas | 19931029 | Touchstone Pictures [st 2]       | 18.99
69 | Bambi II                       | 20060207 | DisneyToon Studios               | 17.99

## Examples

### `table`

This is the most simple of all of the scripts. It lays things out in a neat table:

```
$ head -n 11 sales.csv | table
date      location  film  format  amount
20150908  Tokyo     78    mp4     16.99
20150909  Tokyo     26    mp4     15.99
20150901  Berlin    99    BluRay  15.99
20150912  London    93    DVD     14.99
20150912  Berlin    51    HDDVD   14.99
20150903  London    6     VCR     15.99
20150918  NYC       1     VCR     17.99
20150930  Tokyo     55    VCR     17.99
20150913  Berlin    78    DVD     16.99
20150917  Tokyo     33    BluRay  16.99
```

The remainder of these examples are all displayed using this script because it's easier to see
what's going on that way. If the `table` was removed from the end of any of these commands, then the
data would just look like a regular csv.
### `columns`

This is used to limit output to specific columns, renaming them if necessary:

```
$ head -n 11 sales.csv | columns date,film=film-id,amount=price | table
date      film-id  price
20150908  78       16.99
20150909  26       15.99
20150901  99       15.99
20150912  93       14.99
20150912  51       14.99
20150903  6        15.99
20150918  1        17.99
20150930  55       17.99
20150913  78       16.99
20150917  33       16.99
```

### `enrich`

This is where things get interesting. This script is used to enrich one csv using values from
another. In this case, we're going to add the extra info from titles.csv to each row in the sales
data from sales.csv. In SQL, this would be joining sales to titles where sales.film is equal to
title.id

```
$ head -n 11 sales.csv | enrich -l titles.csv -k id -d film | table
date      location  format  amount  titles_id  titles_title                     titles_date titles_studio                     titles_price
20150908  Tokyo     mp4     16.99   78         Up                               20090529     Pixar Animation Studios           16.99
20150909  Tokyo     mp4     15.99   26         The Great Mouse Detective        19860702     Walt Disney                       15.99
20150901  Berlin    BluRay  15.99   99         The Wind Rises                   20140221     Studio Ghibli                     15.99
20150912  London    DVD     14.99   93         Frankenweenie                    20121105     Tim Burton[st 3]                  14.99
20150912  Berlin    HDDVD   14.99   51         Recess: School's Out             20010216     Walt Disney Television Animation  14.99
20150903  London    VCR     15.99   6          Saludos Amigos                   19420824     Walt Disney                       15.99
20150918  NYC       VCR     17.99   1          Snow White and the Seven Dwarfs  19371221     Walt Disney                       17.99
20150930  Tokyo     VCR     17.99   55         Lilo & Stitch                    20020621     Walt Disney                       17.99
20150913  Berlin    DVD     16.99   78         Up                               20090529     Pixar Animation Studios           16.99
20150917  Tokyo     BluRay  16.99   33         Aladdin                          19921125     Walt Disney                       16.99
```

That's a lot of data though, and now the headers aren't so great. Fortunately, `enrich` can also
selectively add columns and rename them using a similar syntax to `columns`. Lets enrich the sales
data with just the movie title and the studio that produced that movie.

```
$ head -n 11 sales.csv | enrich -l titles.csv -k id -d film -c title=movie-title,studio | table
date      location  format  amount  movie-title                      studio
20150908  Tokyo     mp4     16.99   Up                               Pixar Animation Studios
20150909  Tokyo     mp4     15.99   The Great Mouse Detective        Walt Disney
20150901  Berlin    BluRay  15.99   The Wind Rises                   Studio Ghibli
20150912  London    DVD     14.99   Frankenweenie                    Tim Burton[st 3]
20150912  Berlin    HDDVD   14.99   Recess: School's Out             Walt Disney Television Animation
20150903  London    VCR     15.99   Saludos Amigos                   Walt Disney
20150918  NYC       VCR     17.99   Snow White and the Seven Dwarfs  Walt Disney
20150930  Tokyo     VCR     17.99   Lilo & Stitch                    Walt Disney
20150913  Berlin    DVD     16.99   Up                               Pixar Animation Studios
20150917  Tokyo     BluRay  16.99   Aladdin                          Walt Disney
```

### `count-by`

Now that you've got some joined up data, you can start doing some simple analysis. You can use `count` by
to see which studio is selling the most movies.

```
$ cat test/sales.csv | enrich -l titles.csv -k id -d film -c title=movie-title,studio | count-by -g studio | table
studio                            count
                                  93
ImageMovers Digital[st 6]         208
Tim Burton[st 3]                  97
UTV Motion Pictures               119
DisneyToon Studios                1362
Yash Raj Films[st 5]              80
Touchstone Pictures [st 2]        92
Pixar Animation Studios           1371
Touchstone Pictures               217
Vanguard Animation                91
Skellington [st 3]                89
Studio Ghibli                     565
C.O.R.E.[st 4]                    106
Walt Disney Television Animation  311
Walt Disney                       5199
```

### `sum`

You also might want to look at the distribution of revenue between the different locations. You can
use `sum` to see the total sales of each location.

```
$ cat test/sales.csv | sum -g location -s amount | table
location  sum-of-amount
Tokyo     34840.6
Berlin    33544.4
London    33772.2
Paris     34341.9
NYC       34412.9
```

### `sort-by`

You can use `sort-by` to numerically sort this data to see which location is the most profitable.

```
$ cat test/sales.csv | sum -g location -s amount | sort-by -s sum-of-amount -d desc | table
location  sum-of-amount
Tokyo     34840.6
NYC       34412.9
Paris     34341.9
London    33772.2
Berlin    33544.4
```

### `filter`

`filter` is used to filter the rows based on some kind of condition. Lets say you're only
interested in the main Disney studios. You can use `filter` to filter results to only those rows
that include the word "Disney".

```
$ cat test/sales.csv | enrich -l titles.csv -k id -d film -c studio | count-by -g studio | filter -c 'studio~/.*Disney*./ | table
studio                            count
DisneyToon Studios                1362
Walt Disney Television Animation  311
Walt Disney                       5199
```

`filter` also supports other comparisons like ==, >=, >, <= and <. You can also remove the rows
which match the criteria by passing the `-n` flag.

```
$ cat test/sales.csv | enrich -l titles.csv -k id -d film -c studio | count-by -g studio | filter -c 'studio~/.*Disney*./ | table
studio                      count
                            93
ImageMovers Digital[st 6]   208
Tim Burton[st 3]            97
UTV Motion Pictures         119
Yash Raj Films[st 5]        80
Touchstone Pictures [st 2]  92
Pixar Animation Studios     1371
Touchstone Pictures         217
Vanguard Animation          91
Skellington [st 3]          89
Studio Ghibli               565
C.O.R.E.[st 4]              106
```

## Installation

These are just bash scripts, so all you have to do is clone this repo and add the bin folder to your
`$PATH` and you're ready to go!

## Warning

The vast majority of this is just awk, without anything particularly clever being done. None of
these scripts handle escapes or quoting or anything like that yet.

## TODO list

These are things I'm planning to do soon (roughly in order)

- change count-by to count and make it handle both group-by and count unique
- make the record separator configurable everywhere
- a script that lets you process csvs with a quote char or with escaped record separators in the
  values (by systematically changing the separator, and removing the quotes)
- multi column matches in enrich
- more visualisations (histogram, distribution, other?)
- pivot table
