=pod
August 28th 2014
This script is to print lengths of sequences from a FASTA input file
=cut

#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $file_fasta="";

GetOptions('in=s'=>\$file_fasta);

my $fileout=substr($file_fasta,0,-6);
$fileout=$fileout."_len_seq.txt";

##################################################################################################
open(In,"<$file_fasta") || die "Cannot open file $file_fasta";
open(Out,">$fileout") || die "Cannot open file $fileout";
print Out "#ID\tLength\tSequence\n";
my $id="";
my $seq="";
while (<In>)
{
	$_=~s/\s*$//;
	if ($_=~/^\>/)
	{
		if ($seq)
		{
			$seq=uc($seq);
			my $len=length($seq);
			$id=~s/\s*$//;
			print Out "$id\t$len\t$seq\n";
			#print Out "$id\t$len\n";
			$seq="";
			$id="";
		}
		
		$id=$_;
		$id=~s/^\>//;
	}else
	{
		$_=~s/\s*//g;
		$seq=$seq.$_;
	}
}
$seq=uc($seq);
my $len=length($seq);
$id=~s/\s*$//;
#print Out "$id\t$len\n";
print Out "$id\t$len\t$seq\n";
close(In);
close(Out);
##################################################################################################
