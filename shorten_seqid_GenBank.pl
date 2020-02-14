#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $filein="";
my $fileout="";

GetOptions('in=s'=>\$filein, 'out=s'=>\$fileout);

open(In,"<$filein") || die "Cannot open file $filein";
open(Out,">$fileout") || die "Cannot open file $fileout";
while (<In>)
{
	$_=~s/\s*$//;
	if ($_=~/^\>/)
	{
		$_=~s/\s+.+$//;
		print Out "$_\n";
	}else{print Out "$_\n";}
}
close(In);
close(Out);
