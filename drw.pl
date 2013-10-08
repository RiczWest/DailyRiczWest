#!/usr/bin/perl -w
# use strict;

use File::Copy;
use Time::Local;

$version = "0.9"; # IFTTT Twitter Triggers

# Set up the Base Directories and files
$ifttt            = "/Users/rwest/Dropbox/ifttt";           # Location of If This Then That
$ifttt_favourites = "$ifttt/favourites.txt";
$twitter          = "/Users/rwest/Dropbox/Public/Twitter";  # Location of Public Twitter directory
$templates        = "$twitter/templates";

# Subroutines

# Set up Date Strings
# Array of month strings for converting a month number in to a string
@month_text = qw( jan feb mar apr may jun jul aug sep oct nov dec );
# Get information for the day before this is invoked by subtracting seconds: 24h * 60m * 60s
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = (localtime(time - (24 * 60 * 60)));
$month = $month_text[$mon]; # Convert the month in to text from a number
$year += 1900;              # Perl Years are based from 1900, so we have to add this to get a real one

# Set up date based directories
$twitter_year = "$twitter/$year";                   # Twitter & Year directory
$twitter_year_month = "$twitter_year/$month";       # Twitter, Year & Month directory
# If the Twitter Year directory doesn't exist, make it
unless (-d $twitter_year)       { mkdir $twitter_year or die "Unable to create $twitter_year\n"};
unless (-d $twitter_year_month) { mkdir $twitter_year_month or die "Unable to create $twitter_year_month\n"};

# Assemble the String Date of form XX mon YEAR
$twitter_date = "$mday $month, $year";
print "DailyRiczWestDate : ", $twitter_date;

chdir("$twitter_year_month"); # Process in Year and Month directory under "Twitter"

# Assemble header
copy("$templates/header1.html", "header.html") or die "$templates/header1.html cannot be copied to $twitter_year_month";
open (HEADER, ">> header.html") or die ("Cannot Append to header.html - after header1.html");
print HEADER $twitter_date; close(HEADER);
system("cat $templates/header2.html >> header.html");
open (HEADER, ">> header.html") or die ("Cannot Append to header.html - after header2.html");
print HEADER $twitter_date; close(HEADER);
system("cat $templates/header3.html >> header.html");
open (HEADER, ">> header.html") or die ("Cannot Append to header.html - after header3.html");
print HEADER $version; close(HEADER);
system("cat $templates/header4.html >> header.html");

# Process Body
copy($ifttt_favourites, "favourites.html") or die "$ifttt_favourites cannot be copied to $twitter_year_month";

open(FAVOURITES,"< favourites.html") or die("Cannot Read favourites.html");
open(BODY,"> body.html")             or die("Cannot Write body.html");


while (<FAVOURITES>) {
    s/\*BR\*/<br>/;        # Replace *BR* with <br> because ifttt will not pass through <br>
    s/<blockquote\ class="twitter-tweet"><p>//; # Take out <blockquote ... >
    s/<\/blockquote>//;                         # Take out </blockquote>
    s/<\/p>.*<\/a>//;                           # Take out 2nd line of <blockquote> - it's in the "header"
    # Take out 2nd line & script from Twitter - not needed
    s/<script\ async\ src="\/\/platform\.twitter\.com\/widgets\.js"\ charset="utf-8"><\/script>//;
    print BODY;
}

close BODY; close FAVOURITES;

# Assemble Daily
system("cat header.html body.html $templates/footer.html > daily-$mday.html");
system("rm header.html favourites.html body.html");
$twodig_year = $year-2000;
system("mv $ifttt_favourites $ifttt/archive/favourites-$mday$month$twodig_year.txt");