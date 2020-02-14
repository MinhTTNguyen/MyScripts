#! /usr/perl/bin -w
# shorten JGI protein ID
use strict;

my $filein="/mnt/fs1/home/mnguyen/Research/Lysozyme/Lysozyme_summary_21Feb2019/GH23/fungi.fasta";
my $fileout="/mnt/fs1/home/mnguyen/Research/Lysozyme/Lysozyme_summary_21Feb2019/GH23/fungi_shortID.fasta";

open(In,"<$filein") || die "Cannot open file $filein";
open(Out,">$fileout") || die "Cannot open file $fileout";
while (<In>)
{
	$_=~s/\s*$//;
	if ($_=~/^\>/)
	{
		my $newid=$_;
		if ($_=~/^>jgi/)
		{
			my @temps=split(/\|/,$_);
			$newid=$temps[0]."|".$temps[1]."|".$temps[2];
		}
		print Out "$newid\n";
	}else{print Out "$_\n";}
}
close(In);
close(Out);