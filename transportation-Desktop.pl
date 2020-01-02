#!/usr/bin/perl
#
#   Packages and modules
#
use strict;
use warnings;
use version;   our $VERSION = qv('5.16.0');   # This is the version of Perl to be used
use Text::CSV  1.32;   # We will be using the CSV module (version 1.32 or higher)
use Statistics::R;
# to parse each line

###############################
#       VARIABLES
###############################
my $csv = Text::CSV->new({ sep_char => "," });
my $transportationFile = "Overall_Cost_of_Transportation.csv";
my @transportationDatabase;
my $transportationGraphFileOut = "Transportation_Cost.pdf";
my $transportationGraphFileIn = "temp_transportation_file.csv";
my @tempTransportation;
my $startYear;
my $endYear;
my $input;
my @provinceNames=("Ontario","Quebec","Nova Scotia", "New Brunswick","Manitoba","British Columbia", "Prince Edward Island", "Saskatchewan", "Alberta", "Newfoundland and Labrador", "Northwest Territories", "Yukon", "Nunavut");
my $i=0;
my $j=0;
my @provinces;
my $numProvinces;
my $currentProvince;
my $errorCheck=1;

###############################
#       OPEN FILE
###############################

if($#ARGV !=-1)
{
    print "Usage: parseFile.pl\n" or
    die "Print failure\n";
    exit;
}

open my $transportationDatabaseFile, '<:encoding(UTF-8)', $transportationFile
or die "Unable to open file: $transportationFile\n";

@transportationDatabase = <$transportationDatabaseFile>;

close $transportationDatabaseFile
or die "Unable to close: $transportationFile\n";

print "Select year range from 1979 to 2019\n";

do
{
    print "Enter beginning year: ";
    $startYear=<STDIN>;
    chomp $startYear;
}while(!($startYear >= 1979 && $startYear < 2019));


do
{
    print "Enter end year: ";
    $endYear=<STDIN>;
    chomp $endYear;
}while(!($endYear > 1799 && $endYear <= 2019 && $endYear > $startYear));


for($i=0;$i<13;$i++)
{
    print "(".$i.") ".$provinceNames[$i]."\n";
}

do
{
    print "How many provinces do you wish to compare? (2-13): ";
    $numProvinces=<STDIN>;
    chomp $numProvinces;
}while(!($numProvinces >= 2 && $numProvinces <= 13));

if($numProvinces==13)
{
    for($i=0;$i<13;$i++)
    {
        $provinces[$i]=$i;
    }
}

else
{
    for($i=0;$i<$numProvinces;$i++)
    {
        do
        {
            $errorCheck=1;
            print "Enter the number corresponding to province ".($i+1).": ";
            $provinces[$i]=<STDIN>;
            chomp $provinces[$i];
            
            if($provinces[$i] >= 0 && $provinces[$i] <= 13)
            {
                $errorCheck=0;
            }
            
            for($j=0;$j<$i;$j++)
            {
                if($provinces[$i] eq $provinces[$j])
                {
                    $errorCheck=1;
                }
            }
        }while($errorCheck eq 1)
    }
}

push (@tempTransportation,"\"Year\",\"Value\",\"Location\"");
#Create temp file
foreach my $transportationRow(@transportationDatabase)
{
    if($csv->parse($transportationRow))
    {
        my @rowElements=$csv->fields();
        
        if($rowElements[0] >= $startYear && $rowElements[0] <= $endYear)
        {
            for($i=0;$i<$numProvinces;$i++)
            {
                $currentProvince=$provinces[$i];
                if($rowElements[2] eq $provinceNames[$currentProvince])
                {
                    push (@tempTransportation,"\"".$rowElements[0]."\",\"".$rowElements[1]."\",\"".$rowElements[2]."\"");
                }
            }
        }
    }
}

writeToFile(\@tempTransportation,$transportationGraphFileIn);

# Create a communication bridge with R and start R
my $R = Statistics::R->new();

# Set up the PDF file for plots
$R->run(qq`pdf("$transportationGraphFileOut" , paper="letter")`);

# Load the plotting library
$R->run(q`library(ggplot2)`);

# read in data from a CSV file
$R->run(qq`data <- read.csv("$transportationGraphFileIn")`);

# plot the data as a line plot with each point outlined
$R->run(q`ggplot(data, aes(x=Year, y=Value,colour=Location,group=Location)) + geom_line() + geom_point(size=2) + ggtitle("Cost of Transportation") + ylab("Cost")`);
# close down the PDF device
$R->run(q`dev.off()`);

$R->stop();

unlink($transportationGraphFileIn);

system("open $transportationGraphFileOut");

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
}

