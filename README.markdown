tracker
=======

overview
--------

tracker is a tool to help track daily personal metrics.  each metric
is a count of something per day.  the point is to measure behaviors
that you are trying to increase (like excercise) or decrease (like
watching buffy the vampire slayer) so that you can see if you are
making progress toward that goal.

You cannot measure something without affecting it.  don't argue;
that's science.  personal decisions are probably outside the scope of
quantum mechanics, but lets not get caught up in details.

tracker keeps a repository of occurrences for each metric from which
it can generate a variety of reports.  tracker is like a spreadsheet
with a command line interface.


dependencies
------------

- nekovm
- gnuplot (for rendering graphs)


installation
------------

there are two options for installing tracker.

### standard install

download the nekovm installer from
[nekovm.org](http://nekovm.org/download).  once that's installed,
download tracker.n from
[here](https://s3.amazonaws.com/ianxm-tracker/tracker.n).  now
you can run with:

    > neko /path/to/tracker.n

on linux, setting an alias can save a few keystrokes.

to use the `graph` command you must have gnuplot installed and on your
system path.  be sure to install the full gnuplot package, which
includes the cairo libraries.


### haxelib install

install haxe from
[haxe.org](http://haxe.org/download).

then run

    > haxelib install tracker

to install tracker.

now you can run with:

    > haxelib run tracker

on linux, set an alias for convenience.
 
tutorial
--------

### modifying the repo

tracker has a command line interface similar to git's.  to begin using
it, you must initialize a repo.  by default tracker will create a repo
called '.tracker.db' in your home directory.  initialize it with:

    > tracker init
    creating repository: /home/ian/.tracker.db

if that didn't crash, I guess your installation is ok.

now lets put something in the repo:

    > tracker set pushups =50
    set pushups to 50 for 2012-02-26

that created a metric call 'pushups' and stored '50' in it for today
(2012-02-26).  the space between the `pushups` and `=50` is required.
values can have decimal parts and can be negative.

maybe you just did a few more.  lets update the repo:

    > tracker set pushups +5
    set pushups to 55 for 2012-02-26

that increased the existing value by 5.  a `-5` will decrease a
metric's value.  if you don't specify a date, `set` uses the current
day.  you can specify a date with the `-d` option:

    > tracker set =40 pushups -d 2012-02-20
    set pushups to 40 for 2012-02-20

that set '40' to the 'pushups' metric for feb 20th.  the order of
arguments doesn't matter except that the first argument must be the
command.  dates can be specified in either `YYYY-MM-DD` format, or as
`yesterday` or `today` or `today-N`, where `today-1` is the same as
`yesterday`.

    > tracker set pullups =10 -d yesterday
    set pullups to 10 for 2012-02-25

that created the 'pullups' metric and set its value to '10' for feb
25th (yesterday).

tracker also accepts date ranges.  the following will set all of the
days from feb 10th until the 15th (inclusive) to '4' for 'watchedtv':

    > tracker set watchedtv =4 -d 2012-02-10..2012-02-15
    set watchedtv to 4 for 2012-02-10
    set watchedtv to 4 for 2012-02-11
    set watchedtv to 4 for 2012-02-12
    set watchedtv to 4 for 2012-02-13
    set watchedtv to 4 for 2012-02-14
    set watchedtv to 4 for 2012-02-15

note: tracker doesn't care about units.  the '4' could mean 4 shows, or
could mean 4 hours.

lets say you didn't actually watch tv on the 12th.  you can delete
that entry with:

    > tracker rm watchedtv -d 2012-02-12
    removed watchedtv for 2012-02-12

if you left the date off, tracker would have tried to delete a
'watchedtv' entry for today (but there isn't one).  date ranges for
modifier commands (`set` and `rm`) default to `today`.

### reports

that's it for the commands that modify the repo.  now lets look at
some reporting.  

the `list` command lists all metrics stored in the repo and gives
their date ranges.

    > tracker list
     metric  count  first         last      days
    pushups     2 2012-02-20 to 2012-02-26     7
    pullups     1 2012-02-25 to 2012-02-25     1
    watchedtv   5 2012-02-10 to 2012-02-15     6

the `streaks` command lists runs of consecutive days with or without
occurrences.  the most recent information is at the top.

    > tracker streaks watchedtv
    duration: 17 days from 2012-02-10 to 2012-02-26
      off  11 days from 2012-02-16
       on   3 days from 2012-02-13
      off   1 day  from 2012-02-12
       on   2 days from 2012-02-10

since the date range isn't specified, tracker uses the full date range
of the data.  the full date range for report commands is from the
first occurrence to the current day.  all reports begin by specifying
the duration of the date range examined.

the `bursts` command is like the `streaks` command except that it sums
the values over the days of the streak, instead of just counting them.

this is the calendar view of the same data.  here you can easily see
the runs of on and off days that were listed by the `streaks` output.

    > tracker cal watchedtv
    duration: 29 days from 2012-02-01 to 2012-02-29
    
                 Feb 2012
      Su   Mo   Tu   We   Th   Fr   Sa
                      .    .    .    . 
       .    .    .    .    .    4    4 
       .    4    4    4    .    .    . 
       .    .    .    .    .    .    . 
       .    _    _    _ 

note: the underscores represent days in the future.

this is the calendar for both the 'pullups' and 'pushups' metrics.
listing multiple metrics will return occurrences of either.  values
for the same day will be summed.

    > tracker cal pullups pushups
    duration: 29 days from 2012-02-01 to 2012-02-29
    
                 Feb 2012
      Su   Mo   Tu   We   Th   Fr   Sa
                      .    .    .    . 
       .    .    .    .    .    .    . 
       .    .    .    .    .    .    . 
       .   40    .    .    .    .   10 
      55    _    _    _ 

the following is a log of all 'watchedtv' occurrences.  by default,
logs group occurrences by day, but they can also be grouped in larger
intervals.  the most recent information is at the top.

    > tracker log watchedtv
    duration: 17 days from 2012-02-10 to 2012-02-26
      2012-02-15: 4
      2012-02-14: 4
      2012-02-13: 4
      2012-02-11: 4
      2012-02-10: 4

note: logs, like all reports, can be constrained using date ranges.

this is a log where each entry lists the totals for that week.

    > tracker log watchedtv -by-week
    duration: 17 days from 2012-02-10 to 2012-02-26
      2012-02-12: 12
      2012-02-05: 8

so, on the week of the 12th, you spent 12 hours watching tv.  you
should pare that back.  in addition to `-by-week`, tracker provides
`-by-day`, `-by-month`, `-by-year`, and `-by-full`, which combines all
data into a single entry.

note: day logs omit gaps in data, but the other date groupings show
gaps as zero entries.

in the last example the values reported were sums of the metric
values.  that's the default, but tracker can also provide counts of
occurrences:

    > tracker log watchedtv -by-week -count
    duration: 17 days from 2012-02-10 to 2012-02-26
      2012-02-12: 3
      2012-02-05: 2

that last line says that you watched tv on three days of the week of
feb 12th.

you can also get averages of values.  here, tracker totals the values
(20 in this example) then divides by the number of weeks in the
interval (2), resulting in 5.

    > tracker log watchedtv -by-month -per-week
    duration: 17 days from 2012-02-10 to 2012-02-26
      2012-02: 5

that says you spent 5 hours per week watching tv in feb.

you can also get percentages of occurrences.  here, tracker counts the
occurrences, then divides by the number of days in the interval (7
again) then converts to a percent.

    > tracker log watchedtv -by-week -percent
    duration: 17 days from 2012-02-10 to 2012-02-26
      2012-02-12: 43
      2012-02-05: 29

that says that you watched tv on 43% of the days of the week of feb
12th.

the command below shows the highest and lowest values for each
interval.

    > tracker records pushups pullups
              duration: 7 days from 2012-02-20 to 2012-02-26
                        
          highest year: 2012 (105)
           lowest year: 2012 (105)
          current year: 2012 (105)
                        
         highest month: 2012-02 (105)
          lowest month: 2012-02 (105)
         current month: 2012-02 (105)
                        
          highest week: 2012-02-26 (55)
           lowest week: 2012-02-19 (50)
          current week: 2012-02-26 (55)
                        
           highest day: 2012-02-26 (55)
            lowest day: 2012-02-24 (0)
           current day: 2012-02-26 (55)
                        
     longest on streak:   2 days starting on 2012-02-25
    longest off streak:   4 days starting on 2012-02-21
        current streak:   2 days starting on 2012-02-25 (on)

that example shows totals, but the `-count`, `-per-week` and `-percent`
options are available here also.

### graphs

tracker can generate graphs with the help of gnuplot.  the `graph`
command will result in a graph popping up in gnuplot's native
plotter.

the graph command works the same way as the log command.  the
following command will produce a graph of average tv watching per
week.

    > tracker graph watchedtv -by-week

in addition to 'date grouping' and 'value type' options, the graph
type can be set.  the default is a line graph, but tracker can produce
bar and point graphs.  this command produces a graph of the same data,
but as a bar graph.

    > tracker graph watchedtv -by-week -bar

if an output filename is provided tracker will save the
graph to that file instead of popping up a graph window.  tracker
determines the image file type from the given filename.  the filename
must end in '.png' or '.svg'.  the following command will create a
graph image named 'out.png' in the current directory.

    > tracker graph watchedtv -by-week -bar -o example.png

this is the image that will be created:

![example graph](https://s3.amazonaws.com/ianxm-tracker/example.png)

tracker will draw graphs to the terminal as ascii art with the
`--ascii-graph` option.  the above graph looks like this when drawn to
the terminal.

                                 watchedtv per week
  
    12 +-----------+----------+-----------+-----------+----------+-----------+
       |                                  |   |                              |
       |                                  |   |                              |
    10 +                                  |   |                              +
       |                                  |   |                              |
       |                                  |   |                              |
     8 +                       +--+       |   |                              +
       |                       |  |       |   |                              |
     6 +                       |  |       |   |                              +
       |                       |  |       |   |                              |
       |                       |  |       |   |                              |
     4 +                       |  |       |   |                              +
       |                       |  |       |   |                              |
       |                       |  |       |   |                              |
     2 +                       |  |       |   |                              +
       |                       |  |       |   |                              |
       |                       |  |       |   |                              |
     0 +-----------+----------+-----------+-----------+----------+-----------+
              2012-01-29 2012-02-05  2012-02-12  2012-02-19 2012-02-26
                                        date


there are some examples of graphs generated by tracker from real data
at the bottom of this doc.

### tags

tracker has a little tagging support.  tags are shortcuts that let you
group metrics together so that they can be selected with one name.
for instance if you wanted to group pushups and pullups together, you
could tag them with 'workout'.

    > tracker addtag workout pushups pullups
    added tag 'workout' to 'pushups'
    added tag 'workout' to 'pullups'

then you can get the same records report from above with

    > tracker records workout
    ...

that's all for now.


reference
---------

    usage: tracker command [options] [metric [metric..]]

    commands:
      general:
        init           initialize a repository
        list           list existing metrics and date ranges
        undo           undo the last modify command used
        hist           list recently used modify commands
        help           show help

      modify repository:
        set SETVAL     set or increment a value
                       see SETVAL below
        rm             remove occurrences

      import/export:
        export         export data to csv format
                       this will write to stdout unless -o is given
        import FILE    import data from a csv file
                       with the columns: date,metric,value
                       read from stdin if FILE is '-'

      reporting:
        log            view log of occurrences
        cal            show calendar
        records        show high and low records
        streaks        show consecutive days with or without occurrences
        bursts         show sum of values for streaks
        graph          draw graph (requires gnuplot)

      tags:
        addtag TAG     tag given metrics with TAG
        rmtag TAG      untag given metrics with TAG
        listtags       list all tags

    options:
      general:
        -d RANGE       specify date range (see RANGE below)
        -o FILE        write graph image or csv export to a file
        -N             limit output to the last N items
                       this only affects 'streaks', 'bursts', 'log', 'hist'
        --all-metrics  select all existing metrics
        --repo FILE    specify a repository filename
        --ascii-graph  draw the graph in ascii art to the terminal
        --min VAL      min threshold to count as an occurrence
        -v, --version  show version
        -h, --help     show help

      date groupings for reports:
        (these are only used by the 'log' and 'graph' commands)
        -by-day        each day is separate (default)
        -by-week       group weeks together
        -by-month      group months together
        -by-year       group years together
        -by-full       group the full date range together

      values in reports:
        -total         total values (default)
        -count         count of occurrences
        -percent       percent of days with occurrences
        -per-day       average per day
        -per-week      average per week
        -per-month     average per month
        -per-year      average per year

      graphs:
        -line          draw a line graph (default)
        -bar           draw a bar graph
        -point         draw a point graph

    SETVAL:
      =N           set metrics to N
      +N           increment metrics by N
      -N           decrement metrics by N

    RANGE:
      DATE         only the specified date
      DATE..       days from the given date until today
      ..DATE       days from the start of the data to the specified date
      DATE..DATE   days between specified dates (inclusive)

    DATE:
      YYYY-MM-DD   specify a date
      today        specify day is today (default)
      yesterday    specify day is yesterday
      today-N      specify day is N days before today

    examples:
      > tracker init
                   initialize the default repository

      > tracker set -d yesterday jogging =2
                   set jogging occurrence to 2 for yesterday

      > tracker set -d today bikecommute +1
                   increase bikecommute metric by 1 for today

      > tracker rm bikecommute
                   remove bikecommute occurrence for today

      > tracker log -d 2012-01-01.. bikecommute
                   show a log of all bikecommute occurrences since jan 1, 2012 

      > tracker cal -d 2012-01-01.. wastedtime
                   show wastedtime calendars for each month from jan 2012
                   until the current month

example graphs
--------------

total bike miles per week as a line graph.  the spike was ragbrai.

    > tracker graph cycling -by-week

![example graph](https://s3.amazonaws.com/ianxm-tracker/cycling_per_week.png)


total bike miles per year as a bar graph.

    > tracker graph cycling -by-year -bar

![example graph](https://s3.amazonaws.com/ianxm-tracker/cycling_per_year.png)


commute cycling miles per month as a line graph.

    > tracker graph commute -by-month

![example graph](https://s3.amazonaws.com/ianxm-tracker/commute_per_month.png)


netflix rentals per month as a line graph.

    > tracker graph netflix -by-month

![example graph](https://s3.amazonaws.com/ianxm-tracker/netflix_per_month.png)


netflix rentals per week as a point graph.  in 2009 I switched to one disc at a time to cut back on the movies I was watching.  it doesn't look like it helped much.

    > tracker graph netflix -by-week -point

![example graph](https://s3.amazonaws.com/ianxm-tracker/netflix_per_week.png)
