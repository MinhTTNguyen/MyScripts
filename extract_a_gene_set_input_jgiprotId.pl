# December 1st 2011
# The input is a list of gene IDs
# Output: FASTA file containing the corresponding sequences
# This cript does not report IDs that are not found in the fasta file

#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $path2="";
my $path1="";
my $filein="";
my $fasta_file="";
my $species_code="";
GetOptions('path_fasta=s'=>\$path1,'path_IDlist=s'=>\$path2,'in=s'=>\$filein,'fasta_file=s'=>\$fasta_file,'species_code=s'=>\$species_code);

my $fileout=substr($filein,0,-4);
$fileout=$fileout.".fasta";

############################################################
open(Fasta_file,"<$path1/$fasta_file") || die "Cannot open file $path1/$fasta_file";
my %fasta;
my $fasta_key="";
my $seq="";

while (<Fasta_file>)
{
	my $fasta_line=$_;
	$fasta_line=~s/^\s*//;$fasta_line=~s/\s*$//;
	if ($fasta_line=~/^\>/)
	{
		if ($seq)
		{
			$seq=~s/\s*//g;
			$fasta{$fasta_key}=$seq;
			$seq="";
			$fasta_key="";
		}
		$fasta_key=$fasta_line;
		$fasta_key=~s/\>//;
		if ($fasta_key=~/^jgi\|/)
		{
			my @temp=split(/\|/,$fasta_key);
			$fasta_key=$temp[0]."|".$temp[1]."|".$temp[2];
		}
	}else{$seq=$seq.$fasta_line;}
}
$seq=~s/\s*//g;
$fasta{$fasta_key}=$seq;
close (Fasta_file);
################################################################



open(In,"<$path2/$filein")|| die "Cannot open file $filein";
open(Out,">$path2/$fileout")|| die "Cannot open file $fileout";
while (<In>)
{
	$_=~s/^\s*//;$_=~s/\s*$//;
	my $id="jgi|".$species_code."|".$_;
	my $sequence=$fasta{$id};
	if ($sequence){print Out ">$_\n$sequence\n";}
	else{print "\nWarning: (line ".__LINE__."): sequence not found for this ID: $id\n";}
}

close(In);
close(Out);
