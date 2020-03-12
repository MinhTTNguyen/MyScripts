#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $filein="";
my $fileout="";

GetOptions('in=s'=>\$filein,'out=s'=>\$fileout);

open(In,"<$filein") || die "Cannot oepn file $filein";
open(Out,">$fileout") || die "Cannot oepn file $fileout";

while (<In>)
{
	$_=~s/\s*$//;
	unless ($_){print Out "\n";next;}
	my @annotations=split(/ /,$_);
	my $cazy="";
	foreach my $each (@annotations)
	{
		if ($each=~/CAZY\:/)
		{
			$each=~s/\s*//g;
			$each=~s/CAZY\://;
			if ($cazy){$cazy=$cazy.";".$each;}
			else{$cazy=$each;}
		}
	}
	print Out "$cazy\n";
}
close(In);
close(Out);



