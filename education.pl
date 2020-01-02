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
my $educationFile = "Education_Cost.csv";
my @educationDatabase;
my $educationGraphFileOut = "Education_Cost.pdf";
my $educationGraphFileIn = "temp_edu_file.csv";
my @tempEducation;
my $startYear;
my $endYear;
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

open my $educationDatabaseFile, '<:encoding(UTF-8)', $educationFile
or die "Unable to open file: $educationFile\n";

@educationDatabase = <$educationDatabaseFile>;

close $educationDatabaseFile
or die "Unable to close: $educationFile\n";

print "Cost of education in certain provinces\n\nSelect year range from 1979 to 2019\n";

do
{
    print "Enter beginning year: ";
    $startYear=<>;
    chomp $startYear;
}while(!($startYear >= 1979 && $startYear < 2019));


do
{
    print "Enter end year: ";
    $endYear=<>;
    chomp $endYear;
}while(!($endYear > 1979 && $endYear <= 2019 && $endYear > $startYear));

for($i=0;$i<13;$i++)
{
    print "(".$i.") ".$provinceNames[$i]."\n";
}

do
{
    print "How many provinces do you wish to compare? (2-13): ";
    $numProvinces=<>;
    chomp $numProvinces;
}while(!($numProvinces>=2 && $numProvinces<=13));

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
            $provinces[$i]=<>;
            chomp $provinces[$i];
            
            if($provinces[$i]>=0 && $provinces[$i]<=13)
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
        }while($errorCheck eq 1);
    }
}

push (@tempEducation,"\"Year\",\"Value\",\"Province\"");
#Create temp file
foreach my $educationRow(@educationDatabase)
{
    if($csv->parse($educationRow))
    {
        my @rowElements=$csv->fields();

        if($rowElements[0] >= $startYear && $rowElements[0] <= $endYear)
        {
            for($i=0;$i<$numProvinces;$i++)
            {
                $currentProvince=$provinces[$i];
                if($rowElements[2] eq $provinceNames[$currentProvince])
                {
                    push (@tempEducation,"\"".$rowElements[0]."\",\"".$rowElements[1]."\",\"".$rowElements[2]."\"");
                }
            }
        }
    }
}

writeToFile(\@tempEducation,$educationGraphFileIn);

# Create a communication bridge with R and start R
my $R = Statistics::R->new();

# Set up the PDF file for plots
$R->run(qq`pdf("$educationGraphFileOut" , paper="letter")`);

# Load the plotting library
$R->run(q`library(ggplot2)`);


$R->run(qq`data<-read.csv("$educationGraphFileIn")`);

# plot the data as a line plot with each point outlined
$R->run(q`ggplot(data, aes(x=Year, y=Value, colour=Province,group=Province)) + geom_line() +geom_point(size=1)+ggtitle("Cost of Education")`);

# close down the PDF device
$R->run(q`dev.off()`);

# stops r from running
$R->stop();

unlink($educationGraphFileIn);

system("open $educationGraphFileOut");

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

