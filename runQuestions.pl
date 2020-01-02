#!/usr/bin/perl
#
#   Packages and modules
#
use strict;
use warnings;

my $input;
do
{
    print "\nChoose a Question:\n(1) How does the price of transportation change over time in certain Provinces?\n(2) How does the price of passenger vehicles compare to the price of gasoline in Canada for a given range of years?\n(3) What is the cost of education for a given range of years in certain provinces?\n(4) How does the increase in the price of alcohol, tobacco and marijuana affect the rate of crime for a certain province?\n(5) Exit the Program\nEnter the number corresponding to your choice: ";
    
    $input=<>;
    chomp $input;
    $input=~ s/^\s+|\s+$//g;
    
    print "\n";

    if($input==1)
    {
        system("perl transportation.pl");
    }
    elsif($input==2)
    {
        system("perl gasCars.pl");
    }
    elsif($input==3)
    {
        system("perl education.pl");
    }
    elsif($input==4)
    {
        system("perl crime.pl");
    }
}while($input!=5);

print "Thanks For Participating!\n";
