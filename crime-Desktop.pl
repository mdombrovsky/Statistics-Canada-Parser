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
my $crimeFile = "Total_Crime.csv";
my $substanceFile="Substance_Cost.csv";
my @crimeDatabase;
my @substanceDatabase;
my $graphFileOut = "Substrance_and_Crime.pdf";
my $graphFileIn = "temp_file.csv";
my @tempArray;
my $startYear;
my $endYear;
my $province;
my @provinceNames=("Ontario","Quebec","Nova Scotia", "New Brunswick","Manitoba","British Columbia", "Prince Edward Island", "Saskatchewan", "Alberta", "Newfoundland and Labrador", "Northwest Territories", "Yukon", "Nunavut");
my $year;
my $substanceValue;
my @substanceValues;
my @crimesValues;
my $tempRowElement=0;
my $i=0;



###############################
#       OPEN FILE
###############################
if($#ARGV !=-1)
{
    print "Usage: parseFile.pl\n" or
    die "Print failure\n";
    exit;
}

open my $substanceDatabaseFile, '<:encoding(UTF-8)', $substanceFile
or die "Unable to open file: $substanceFile\n";

@substanceDatabase = <$substanceDatabaseFile>;

close $substanceDatabaseFile
or die "Unable to close: $substanceFile\n";



open my $crimeDatabaseFile, '<:encoding(UTF-8)', $crimeFile
or die "Unable to open file: $crimeFile\n";

@crimeDatabase = <$crimeDatabaseFile>;

close $crimeDatabaseFile
or die "Unable to close: $crimeFile\n";

print "Select year range from 1999 to 2017\n";

do{
    print "Enter first year: ";
    $startYear=<STDIN>;
    chomp $startYear;
}while(!($startYear>=1999&&$startYear<2017));


do{
    print "Enter last year: ";
    $endYear=<STDIN>;
    chomp $endYear;
}while(!($endYear>1999&&$endYear<=2017&&$endYear>$startYear));

for($i=0;$i<13;$i++)
{
    print "(".$i.") ".$provinceNames[$i]."\n";
}

do{
    print "Enter the number corresponding to your choice: ";
    $province=<STDIN>;
    chomp $province;
}while(!($province>=0 && $province<=12));


#Create temp file

push (@tempArray,"\"Year\",\"Scale\",\"Category\"");

foreach my $crimeRow(@crimeDatabase)
{
       if($csv->parse($crimeRow))
       {
           my @rowElements=$csv->fields();
           
           if($rowElements[2] eq $provinceNames[$province])
           {
               if($rowElements[0]>=$startYear && $rowElements[0]<=$endYear)
               {
                   my $crimeDiff=$rowElements[1]/50;
                   
                   push(@tempArray,"\"".$rowElements[0]."\",\"".$crimeDiff."\",\"Crime Rate\"");
               }
           }
           
   }
}

foreach my $substanceRow(@substanceDatabase)
{
    if($csv->parse($substanceRow))
    {

        my @rowElements=$csv->fields();
        
        if($rowElements[2] eq $provinceNames[$province])
        {
            if($rowElements[0]>=$startYear && $rowElements[0]<=$endYear)
            {
                push(@tempArray,"\"".$rowElements[0]."\",\"".$rowElements[1]."\",\"Substance Cost\"");
            }
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


$R->run(q`ggplot(data, aes(x=Year, y=Scale, colour=Category,group=Category)) + geom_line() +geom_point(size=1)+ggtitle("Crime Rate vs. Substance Cost")`);


# close down the PDF device
$R->run(q`dev.off()`);

# stops r from running
$R->stop();

unlink($graphFileIn);

system("open $graphFileOut");

#Subroutine to write to file
sub writeToFile{
    my $CPIFile = $_[1];
    my @inputArray = @{$_[0]};
    
    open(my $fh, '>',$CPIFile);
    foreach(@inputArray)
    {
        print $fh "$_\n";
    }
    close $fh;
}

