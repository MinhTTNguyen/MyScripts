#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $filein="";
my $fileout="";
GetOptions("in=s"=>\$filein, "out=s"=>\$fileout);

############################################################################################################
print "\n";
print "Usage: read text file containing HMMs and extract lengths of the HMMs\n";
print "--in  : input file\n";
print "--out : output file\n";
print "\n";
############################################################################################################

open(In,"<$filein") || die "Cannot open file $filein";
open(Out,">$fileout") || die "Cannot open file $fileout";
while (<In>)
{
	$_=~s/\s*$//;
	#NAME  CBM11.hmm
	#LENG  163
	if ($_=~/^NAME\s+(.+)/){print Out "$1\t";}
	if ($_=~/^LENG\s+(\d+)/){print Out "$1\n";}
}
close(In);
close(Out);

print "done\n";
