tracker
=======

overview
--------

tracker is a tool to help track daily personal metrics.  each metric
is a count of something per day.  the point is to measure behaviors to
know whether progress is being made in trying to increase a behavior
(ie. exercise) or decrease it (ie. watching buffy the vampire slayer).

tracker keeps a repository of occurrences for each metric, and can
generate a variety of reports from its data.  tracker is like a
command line interface to a spreadsheet.


dependencies
------------

- nekovm
- gnuplot (for rendering graphs)
- imagemagick (for displaying graphs better)


installation
------------

download the nekovm installer from
[nekovm.org](http://nekovm.org/download).  once that's installed,
download tracker.n from
[github](https://github.com/downloads/ianxm/tracker/tracker.n).  now
you can run with:

    > neko /path/to/tracker.n

on linux, I recommend setting an alias to shorten the command.


tutorial
--------

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
(2012-02-26).  the space between the 'pushups' and '=50' is important.
values can have decimal parts and can be negative.

maybe you just did a few more.  lets update the repo:

    > tracker set pushups +5
    set pushups to 55 for 2012-02-26

that increased the existing value by 5.  a '-5' will decrease the
metric's value.  if you don't specify a date, `set` uses the current
day.  you can specify a date with the `-d` option:

    > tracker set =40 pushups -d 2012-02-20
    set pushups to 40 for 2012-02-20

that set '40' to the 'pushups' metric for feb 20th.  the order of
arguments doesn't matter except that the first argument must be the
command.  dates must be specified in `YYYY-MM-DD` format, with two
exceptions: `today` and `yesterday` are valid dates.

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

tracker doesn't care about units.  the '4' could mean 4 shows, or
could mean 4 hours.  lets say you didn't actually watch tv on the
12th.  you can delete that entry with:

    > tracker rm watchedtv -d 2012-02-12
    removed watchedtv for 2012-02-12

the date is important on that one.  if you left the date off, it would
have tried to delete a 'watchedtv' entry for today (but there isn't
one).

that's it for the commands that modify the repo.  now lets look at
some reporting.  

    > tracker list
     metric  count  first         last      days
    pushups     2 2012-02-20 to 2012-02-26     7
    pullups     1 2012-02-25 to 2012-02-25     1
    watchedtv   5 2012-02-10 to 2012-02-15     6

the `list` command lists all metrics stored in the repo and gives
their date ranges.

    > tracker streaks watchedtv
    duration: 17 days from 2012-02-10 to 2012-02-26
       on   2 days from 2012-02-10
      off   1 day  from 2012-02-12
       on   3 days from 2012-02-13
      off  11 days from 2012-02-16

note: date ranges for modifier commands (`set` and `rm`) default to
`today`, but all other commands default to the full date range.  all
reports begin by specifying the full date range examined.

the `streaks` command lists runs of consecutive days with or without
occurrences.  the full date range is from the first occurrence to the
current day.

    > tracker cal watchedtv
    duration: 29 days from 2012-02-01 to 2012-02-29
    
                 Feb 2012
      Su   Mo   Tu   We   Th   Fr   Sa
                      .    .    .    . 
       .    .    .    .    .    4    4 
       .    4    4    4    .    .    . 
       .    .    .    .    .    .    . 
       .    _    _    _ 

this is the calendar view of the same data.  here you can easily see
the runs of on and off days that were listed by the `streaks` output.

note: the underscores represent days in the future.

    > tracker cal pullups pushups
    duration: 29 days from 2012-02-01 to 2012-02-29
    
                 Feb 2012
      Su   Mo   Tu   We   Th   Fr   Sa
                      .    .    .    . 
       .    .    .    .    .    .    . 
       .    .    .    .    .    .    . 
       .   40    .    .    .    .   10 
      55    _    _    _ 

this is the calendar for both the 'pullups' and 'pushups' metrics.
listing multiple metrics will return occurrences of either.

    > tracker log watchedtv
    duration: 17 days from 2012-02-10 to 2012-02-26
      2012-02-10: 4
      2012-02-11: 4
      2012-02-13: 4
      2012-02-14: 4
      2012-02-15: 4

note: logs, like all reports, can be constrained using date ranges.

this is a log of all 'watchedtv' occurrences.  by default, logs group
occurrences by day, but they can also be grouped in larger intervals.

    > tracker log watchedtv -week
    duration: 17 days from 2012-02-10 to 2012-02-26
      2012-02-05: 8
      2012-02-12: 12

this is a log where each entry lists the totals for that week.  so, on
the week of the 12th, you spent 12 hours watching tv.  you should pare
that back.  in addition to `-week`, tracker provides `-month`,
`-year`, and `-full`, which combines all data into a single entry.

in the last example, the values reported were sums of the metric
values.  that's the default, but tracker can also provide counts of
occurrences:

    > tracker log watchedtv -week -count
    duration: 17 days from 2012-02-10 to 2012-02-26
      2012-02-05: 2
      2012-02-12: 3

so, you watched tv on three days on the week of the 12th.

you can also get averages of values.  here, tracker totals the values,
then divides by the number of days in the interval (7 in this example,
since we're looking at weeks).

    > tracker log watchedtv -week -avg
    duration: 17 days from 2012-02-10 to 2012-02-26
      2012-02-05: 1.1
      2012-02-12: 1.7

that says you spent 1.7 hours per day watching tv on the week of the
12th.

you can also get percentages of occurrences.  here, tracker counts the
occurrences, then divides by the number of days in the interval (7
again) then converts to a percent.

    > tracker log watchedtv -week -percentage
    duration: 17 days from 2012-02-10 to 2012-02-26
      2012-02-05: 29
      2012-02-12: 43

that says that you watched tv on 43% of the days of the week of the
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

that example shows totals, but the `-count`, `-avg` and `-percent`
options are available here also.

that's all for now.  tracker will be able to generate graphs using
gnuplot but that's not done yet.


reference
---------

    usage: tracker command [options] [metric [metric..]]
    
        if no date range is specified, the range is all days. 
        if no metric is given, tracker will list all metrics found.
    
    commands:
      general:
        init           initialize a repository
        list           list existing metrics and date ranges
        help           show help
    
      modify repository:
        set            set or increment a value
                       see 'set command options' below
        rm             remove occurrences
    
      import/export:
        export         export data to csv format
                       this will write to stdout unless -o is given
        import FILE    import data from a csv file
                       with the columns: date,metric,value
    
      reporting:
        log            view log of occurrences
        cal            show calendar
        records        show high and low records
        streaks        show consecutive days with or without occurrences
        graph          draw graph (requires gnuplot)
      
    options:
      set command options:
        =N             set metrics to N
        +N             increment metrics by N
        -N             decrement metrics by N
    
      general:
        -d RANGE       specify date range (see RANGE below)
        -o FILE        write graph image to a file
        -N             limit output to the last N items
                       this only affects the 'streaks' and 'log' commands
        --all          select all existing metrics
        --repo FILE    specify a repository filename
        --min VAL      min threshold to count as an occurrence
        -v, --version  show version
        -h, --help     show help
    
      date groupings for reports:
        (these are only used by the 'log' and 'graph' commands)
        -day           each day is separate (default)
        -week          group weeks together
        -month         group months together
        -year          group years together
        -full          group the full date range together
    
      values in reports:
        -total         total values (default)
        -count         count of occurrences
        -avg           average values by duration
        -percent       show values as the percent of occurrence of duration
    
    RANGE:
      DATE         only the specified date
      DATE..       days from the given date until today
      ..DATE       days from the start of the data to the specified date
      DATE..DATE   days between specified dates (inclusive)
    
    DATE:
      YYYY-MM-DD   specify a date
      today        specify day is today (default)
      yesterday    specify day is yesterday
