#!/usr/bin/perl
#
#   Packages and modules
#
use strict;
use warnings;
use version;   our $VERSION = qv('5.16.0');   # This is the version of Perl to be used
use Text::CSV  1.32;   # We will be using the CSV module (version 1.32 or higher) to parse each line
use Statistics::R;

###############################
#       VARIABLES
###############################
my $csv = Text::CSV->new({ sep_char => "," });
my $carFile = "Vehicle_Cost.csv";
my $gasFile="Gas_Cost.csv";
my @carDatabase;
my @gasDatabase;
my $graphFileOut = "Gas_VS_Cars.pdf";
my $graphFileIn = "temp_file.csv";
my @tempArray;
my $startYear;
my $endYear;
my @finalArray;


###############################
#       OPEN FILE
###############################
if($#ARGV !=-1)
{
    print "Usage: parseFile.pl\n" or
    die "Print failure\n";
    exit;
}

open my $gasDatabaseFile, '<:encoding(UTF-8)', $gasFile
or die "Unable to open file: $gasFile\n";

@gasDatabase = <$gasDatabaseFile>;

close $gasDatabaseFile
or die "Unable to close: $gasFile\n";

open my $carDatabaseFile, '<:encoding(UTF-8)', $carFile
or die "Unable to open file: $carFile\n";

@carDatabase = <$carDatabaseFile>;

close $carDatabaseFile
or die "Unable to close: $carFile\n";

print "Price of passenger vehicles vs the price of gasoline in Canada\n\nSelect year range from 1949 to 2019\n";

do
{
    print "Enter first year: ";
    $startYear=<>;
    chomp $startYear;
}while(!($startYear >= 1949 && $startYear < 2019));

do
{
    print "Enter last year: ";
    $endYear=<>;
    chomp $endYear;
}while(!($endYear > 1949 && $endYear <= 2019 && $endYear > $startYear));

push (@tempArray,"\"Year\",\"Value\",\"Type\"");
#Create temp file
foreach my $carRow(@carDatabase)
{
     if($csv->parse($carRow))
     {
        my @rowElements=$csv->fields();
        
        if($rowElements[0] >= $startYear && $rowElements[0] <= $endYear)
        {
            push(@tempArray,"\"".$rowElements[0]."\",\"".$rowElements[1]."\",\"Car Cost\"");
        }
    }
}

foreach my $gasRow(@gasDatabase)
{
    if($csv->parse($gasRow))
    {
        my @rowElements=$csv->fields();
    
        if($rowElements[0] >= $startYear && $rowElements[0] <= $endYear)
        {
            push(@tempArray,"\"".$rowElements[0]."\",\"".$rowElements[1]."\",\"Gas Cost\"");
        }
    }
}

writeToFile(\@tempArray,$graphFileIn);

# Create a communication bridge with R and start R
my $R = Statistics::R->new();

# Set up the PDF file for plots
$R->run(qq`pdf("$graphFileOut" , paper="letter")`);

# Load the plotting library
$R->run(q`library(ggplot2)`);

$R->run(qq`data<-read.csv("$graphFileIn")`);

$R->run(q`ggplot(data, aes(x=Year, y=Value, colour=Type,group=Type)) + geom_line() +geom_point(size=1)+ggtitle("Cost of Passenger Car and Gasoline in Canada")`);

# close down the PDF device
$R->run(q`dev.off()`);

# stops r from running
$R->stop();

unlink($graphFileIn);

system("open $graphFileOut");

#Subroutine to write to file
sub writeToFile
{
    my $CPIFile = $_[1];
    my @inputArray = @{$_[0]};
    
    open(my $fh, '>',$CPIFile);
    foreach(@inputArray)
    {
        print $fh "$_\n";
    }
    close $fh;
    return;
}

