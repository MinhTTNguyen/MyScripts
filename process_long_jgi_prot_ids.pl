#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $filein="";
my $fileout="";

GetOptions('in=s'=>\$filein,'out=s'=>\$fileout);

open(In,"<$filein") || die "Could not open file $filein";
open(Out,">$fileout") || die "Could not open file $fileout";
while (<In>)
{
	$_=~s/\s*$//;
	if ($_=~/^jgi\|/)
	{
		my @temps=split(/\|/,$_);
		my $protid=$temps[0]."|".$temps[1]."|".$temps[2];
		print Out "$protid\n";
	}else{print Out "$_\n";}
}
close(In);
close(Out);