#!/usr/bin/perl

use POSIX;
use strict;
use warnings;
use feature qw(say);

my $domain = $ARGV[0];
my $warning = int($ARGV[1]);
my $critical = int($ARGV[2]);

my %month = (
	'Jan' => 1,
	'Feb' => 2,
	'Mar' => 3,
	'Apr' => 4,
	'May' => 5,
	'Jun' => 6,
	'Jul' => 7,
	'Aug' => 8,
	'Sep' => 9,
	'Oct' => 10,
	'Nov' => 11,
	'Dec' => 12
);

my %ERRORS = ('OK'=>0,'WARNING'=>1,'CRITICAL'=>2,'UNKNOWN'=>3);


#my $domain = 'semenushkin.ru';

my $rv = `/usr/bin/whois $domain`;

my($pyear,$pmon,$pday,$cyear,$cmon,$cday);
if($domain =~ /\.ru$/)
    {
	$rv =~ /paid-till:\s+(\d{4})\.(\d{2})\.(\d{2})/;
	($pyear,$pmon,$pday) = ((int($1)-1900),(int($2)-1),int($3));
	($cyear,$cmon,$cday) = ((localtime())[5],(localtime())[4],(localtime())[3]);
    }
if($domain =~ /\.com$/)
    {
	if($rv =~ /Expiration date:\s+(\d{2})\-(\d{2})\-(\d{4})/)
	    {
		($pyear,$pmon,$pday) = ((int($3)-1900),(int($2)-1),int($1));
		($cyear,$cmon,$cday) = ((localtime())[5],(localtime())[4],(localtime())[3]);
	    }
	if($rv =~ /Expiration Date:\s+(\d{4})\-(\d{2})\-(\d{2})/)
	    {
		($pyear,$pmon,$pday) = ((int($1)-1900),(int($2)-1),int($3));
		($cyear,$cmon,$cday) = ((localtime())[5],(localtime())[4],(localtime())[3]);
	    }
	if($rv =~ /Expiration Date:\s+(\d{4})\.(\d{2})\.(\d{2})/)
	    {
		($pyear,$pmon,$pday) = ((int($1)-1900),(int($2)-1),int($3));
		($cyear,$cmon,$cday) = ((localtime())[5],(localtime())[4],(localtime())[3]);
	    }
    }
if($domain =~ /\.pro$/)
    {
	$rv =~ /Expiration Date:(\d{2})\-(\w+)\-(\d{4})/;
	($pyear,$pmon,$pday) = ((int($3)-1900),($month{$2}-1),int($1));
	($cyear,$cmon,$cday) = ((localtime())[5],(localtime())[4],(localtime())[3]);
    }
if($domain =~ /\.net$/)
    {
	if($rv =~ /Expiration date:\s+(\d{2})\-(\d{2})\-(\d{4})\b/)
	    {
		($pyear,$pmon,$pday) = ((int($3)-1900),(int($2)-1),int($1));
		($cyear,$cmon,$cday) = ((localtime())[5],(localtime())[4],(localtime())[3]);
	    }
	if($rv =~ /Expiration Date:\s+(\d{4}).(\d{2}).(\d{2})/)
	    {
		($pyear,$pmon,$pday) = ((int($1)-1900),(int($2)-1),int($3));
		($cyear,$cmon,$cday) = ((localtime())[5],(localtime())[4],(localtime())[3]);
	    }
    }



my $paid_time = mktime(0,0,0,$pday,$pmon,$pyear);
my $current_time = mktime(0,0,0,$cday,$cmon,$cyear);

my $margin = $paid_time - $current_time;

my $countdown = $margin/86400;

if($warning < $countdown) {say "OK: $countdown days left";exit $ERRORS{'OK'};}
elsif(($critical < $countdown)&&($countdown < $warning)) {say "WARNING: $countdown days left";exit $ERRORS{'WARNING'};}
elsif($countdown < $critical) {say "CRITICAL: $countdown days left";exit $ERRORS{'CRITICAL'};}
else{say "UNKNOWN";exit $ERRORS{'UNKNOWN'};}

