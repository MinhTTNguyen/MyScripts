# Extract sequences from all subfamilies
#! /usr/bin/perl -w
use strict;
use Getopt::Long;

my $filein="";
my $folderout="";

GetOptions('in=s'=>\$filein, 'out=s'=>\$folderout);
mkdir $folderout;

open(In, "<$filein") || die "Cannot open file $filein";
my $id="";
my $seq="";
while (<In>)
{
	$_=~s/^\s*//;$_=~s/\s*$//;
	if ($_=~/^\>/)
	{
		if ($seq)
		{
			if ($id=~/^\>(C\d+)\|/)
			{
				my $subfamily=$1;
				my $fileout=$subfamily.".fasta";
				open(Out, ">>$folderout/$fileout") || die "Cannot open file $folderout/$fileout";
				print Out "$id\n$seq\n";
				close(Out);
			}elsif (($id=~/^\>(no\_cluster)\|/) ||($id=~/^\>(nosub)\|/))
			{
				my $subfamily=$1;
				my $fileout=$subfamily.".fasta";
				open(Out, ">>$folderout/$fileout") || die "Cannot open file $fileout";
				print Out "$id\n$seq\n";
				close(Out);
			}else{print "\nError (line ".__LINE__."): cannot find subfamily information for this sequence: $id\n";exit;}
			$seq="";$id="";
		}
		$id=$_;
	}else{$_=~s/\s*//g;$seq=$seq.$_;}
}
if ($id=~/^\>(C\d+)\|/)
{
	my $subfamily=$1;
	my $fileout=$subfamily.".fasta";
	open(Out, ">>$folderout/$fileout") || die "Cannot open file $fileout";
	print Out "$id\n$seq\n";
	close(Out);
}elsif (($id=~/^\>(no\_cluster)\|/) ||($id=~/^\>(nosub)\|/))
{
	my $subfamily=$1;
	my $fileout=$subfamily.".fasta";
	open(Out, ">>$folderout/$fileout") || die "Cannot open file $fileout";
	print Out "$id\n$seq\n";
	close(Out);
}else{print "\nError (line ".__LINE__."): cannot find subfamily information for this sequence: $id\n";exit;}

close(In);
