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
	$_=~s/^\#//;
	my @cols=split(/\t/,$_);
	my $protid=$cols[0];
	my $num_cols=scalar(@cols);
	if ($num_cols>2)
	{
		if ($protid=~/^jgi\|/)
		{
			my @temps=split(/\|/,$protid);
			$protid=$temps[0]."|".$temps[1]."|".$temps[2];
		}
		shift(@cols);
		my $new_line_without_protid=join("\t",@cols);
		print Out "$protid\t$new_line_without_protid\n";
	}
}
close(In);
close(Out);
