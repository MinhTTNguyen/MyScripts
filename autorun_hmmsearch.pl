# Autorun hmmsearch program
 
#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $folderin="";
my $folderout="";
my $folderout_seq="";
my $folderout_dom="";
my $hmm_file="";

GetOptions('in=s'=>\$folderin,'out=s'=>\$folderout,'tblout=s'=>\$folderout_seq,'domtblout=s'=>\$folderout_dom,'hmm=s'=>\$hmm_file);


##############################################################################################################################################
if ($folderin and $folderout and $folderout_seq and $folderout_dom and $hmm_file){print "\nStart processing...\n";}
else
{
	print "\n";
	print "Usage: run hmmsearch for a set of fasta file\n";
	print "--in        : folder containing input fasta file\n";
	print "--out       : folder containing output files from hmmsearch\n";
	print "--tblout    : folder containing output files from hmmsearch, parseable table of per-sequence hits to file\n";
	print "--domtblout : folder containing output files from hmmsearch, parseable table of per-domain hits to file\n";
	print "--hmm	   : hmm file\n";
	print "\n";
}
##############################################################################################################################################


mkdir $folderout;
mkdir $folderout_dom;
mkdir $folderout_seq;

opendir(DIR,"$folderin") || die "Could not open folder $folderin";
my @files=readdir(DIR);
my $filecount=0;
foreach my $file (@files)
{
	if (($file ne ".") and ($file ne ".."))
	{
		my $fileout=substr($file,0,-5);
		my $fileout_all=$fileout."out";
		my $fileout_domtbl=$fileout."domtblout";
		my $fileout_tbl=$fileout."tblout";
		$filecount++;
		print "$filecount.$file:start...............................";
		my $cmd = "hmmsearch -o $folderout/$fileout_all --domtblout $folderout_dom/$fileout_domtbl --tblout $folderout_seq/$fileout_tbl -E 1E-05 --domE 1E-05 --cpu 30 $hmm_file $folderin/$file";
		system $cmd;
		print "finish\n";
	}
}
closedir(DIR);
print "\ndone!\n";
