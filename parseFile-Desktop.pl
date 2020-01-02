#!/usr/bin/perl
#
#   Packages and modules
#
use strict;
use warnings;
use version;   our $VERSION = qv('5.16.0');   # This is the version of Perl to be used
use Text::CSV  1.32;   # We will be using the CSV module (version 1.32 or higher)
# to parse each line

###############################
#       VARIABLES
###############################

my $csv          = Text::CSV->new({ sep_char => "," });
my $CPIFile="CPI.csv";
my $crimeFile;
my @crimeDatabase;
my @CPIDatabase;
my @vehicleCost;
my @gasCost;
my @transportation;
my @alcoholCost;
my @educationCost;
my @totalCrime;

###############################
#       OPEN FILE
###############################

if($#ARGV !=1)
{
    print "Usage: parseFile.pl <cpi file> <crime file>\n" or
    die "Print failure\n";
    exit;
}
else
{
    $CPIFile=$ARGV[0];
    $crimeFile=$ARGV[1];
}

open my $crimeDatabaseFile, '<:encoding(UTF-8)', $crimeFile
or die "Unable to open file: $crimeFile\n";

@crimeDatabase = <$crimeDatabaseFile>;

close $crimeDatabaseFile
or die "Unable to close: $crimeFile\n";

open my $CPIDatabaseFile, '<:encoding(UTF-8)', $CPIFile
or die "Unable to open file: $CPIFile\n";

@CPIDatabase = <$CPIDatabaseFile>;

close $CPIDatabaseFile
or die "Unable to close: $CPIFile\n";

###############################
#       PARSE FILE
###############################


#Parse Crime file
foreach my $crimeDatabaseRow(@crimeDatabase)
{
    if($csv->parse($crimeDatabaseRow))
    {
        my @rowElements=$csv->fields();
        
        #Only parses provinces for the total crime
        if(!($rowElements[1] eq "Canada")&&($rowElements[3] eq "Total, all violations")&&($rowElements[4] eq "Rate per 100,000 population"))
        {
            if((substr $rowElements[1],0,length("Ontario")) eq "Ontario")
            {
                push(@totalCrime,"\"".$rowElements[0]."\",\"".$rowElements[11]."\",\""."Ontario\"");
            }
            elsif((substr $rowElements[1],0,length("Newfoundland and Labrador")) eq "Newfoundland and Labrador")
            {
                push(@totalCrime,"\"".$rowElements[0]."\",\"".$rowElements[11]."\",\""."Newfoundland and Labrador\"");
            }
            elsif((substr $rowElements[1],0,length("Prince Edward Island")) eq "Prince Edward Island")
            {
                push(@totalCrime,"\"".$rowElements[0]."\",\"".$rowElements[11]."\",\""."Prince Edward Island\"");
            }
            elsif((substr $rowElements[1],0,length("Nova Scotia")) eq "Nova Scotia")
            {
                push(@totalCrime,"\"".$rowElements[0]."\",\"".$rowElements[11]."\",\""."Nova Scotia\"");
            }
            elsif((substr $rowElements[1],0,length("New Brunswick")) eq "New Brunswick")
            {
                push(@totalCrime,"\"".$rowElements[0]."\",\"".$rowElements[11]."\",\""."New Brunswick\"");
            }
            elsif((substr $rowElements[1],0,length("Quebec")) eq "Quebec")
            {
                push(@totalCrime,"\"".$rowElements[0]."\",\"".$rowElements[11]."\",\""."Quebec\"");
            }
            elsif((substr $rowElements[1],0,length("Manitoba")) eq "Manitoba")
            {
                push(@totalCrime,"\"".$rowElements[0]."\",\"".$rowElements[11]."\",\""."Manitoba\"");
            }
            elsif((substr $rowElements[1],0,length("Saskatchewan")) eq "Saskatchewan")
            {
                push(@totalCrime,"\"".$rowElements[0]."\",\"".$rowElements[11]."\",\""."Saskatchewan"."\"");
            }
            elsif((substr $rowElements[1],0,length("Alberta")) eq "Alberta")
            {
                push(@totalCrime,"\"".$rowElements[0]."\",\"".$rowElements[11]."\",\""."Alberta"."\"");
            }
            elsif((substr $rowElements[1],0,length("British Columbia")) eq "British Columbia")
            {
                push(@totalCrime,"\"".$rowElements[0]."\",\"".$rowElements[11]."\",\""."British Columbia\"");
            }
            elsif((substr $rowElements[1],0,length("Yukon")) eq "Yukon")
            {
                push(@totalCrime,"\"".$rowElements[0]."\",\"".$rowElements[11]."\",\""."Yukon\"");
            }
            elsif((substr $rowElements[1],0,length("Northwest Territories")) eq "Northwest Territories")
            {
                push(@totalCrime,"\"".$rowElements[0]."\",\"".$rowElements[11]."\",\""."Northwest Territories\"");
            }
            elsif((substr $rowElements[1],0,length("Nunavut")) eq "Nunavut")
            {
                push(@totalCrime,"\"".$rowElements[0]."\",\"".$rowElements[11]."\",\""."Nunavut\"");
            }
        }
    }
}

#Parse CPI File
foreach my $CPIDatabaseRow(@CPIDatabase)
{
    if($csv->parse($CPIDatabaseRow))
    {
        my @rowElements=$csv->fields();
    
        #for the first of each month
        if((substr $rowElements[0],-2,2) eq "01")
        {
            
            #for all of canada
            if($rowElements[1] eq "Canada")
            {
                 #parse transportation
                if($rowElements[3] eq "Transportation")
                {
                    push(@transportation,"\"".(substr $rowElements[0],0,4)."\",\"$rowElements[10]\",\"Canada\"");
                }
                
                #passenger vehicles
                if($rowElements[3] eq "Purchase of passenger vehicles")
                {
                   push (@vehicleCost,"\"".(substr $rowElements[0],0,4)."\",\"$rowElements[10]\",\"Canada\"");
                }
                
                #gasoline
                if($rowElements[3] eq "Gasoline")
                {
                    push (@gasCost,"\"".(substr $rowElements[0],0,4)."\",\"$rowElements[10]\",\"Canada\"");
                }
            }
        
            #for each province
            else
            {
                #cost of alcohol...
                if($rowElements[3] eq "Alcoholic beverages, tobacco products and recreational cannabis")
                {
                    #Removes capital, keeps only province names
                    if($rowElements[1] eq "Whitehorse, Yukon")
                    {
                        $rowElements[1]="Yukon";
                    }
                    if($rowElements[1] eq "Yellowknife, Northwest Territories")
                    {
                        $rowElements[1]="Northwest Territories";
                    }
                    if($rowElements[1] eq "Iqaluit, Nunavut")
                    {
                        $rowElements[1]="Nunavut";
                    }
                    push (@alcoholCost,"\"".(substr $rowElements[0],0,4)."\",\"$rowElements[10]\",\"$rowElements[1]\"");
                }
                
                #education
                if($rowElements[3] eq "Education and reading")
                {
                    
                    #Removes capital, keeps only province names
                    if($rowElements[1] eq "Whitehorse, Yukon")
                    {
                        $rowElements[1]="Yukon";
                    }
                    if($rowElements[1] eq "Yellowknife, Northwest Territories")
                    {
                        $rowElements[1]="Northwest Territories";
                    }
                    if($rowElements[1] eq "Iqaluit, Nunavut")
                    {
                        $rowElements[1]="Nunavut";
                    }
                    push (@educationCost,"\"".(substr $rowElements[0],0,4)."\",\"$rowElements[10]\",\"$rowElements[1]\"");
                }
            }
        }
    }
}

#Creates several files
writeToFile(\@transportation,"Overall_Cost_of_Transportation.csv");
writeToFile(\@vehicleCost,"Vehicle_Cost.csv");
writeToFile(\@alcoholCost,"Substance_Cost.csv");
writeToFile(\@educationCost,"Education_Cost.csv");
writeToFile(\@totalCrime,"Total_Crime.csv");

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













