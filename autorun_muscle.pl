# October 5th 2017
# autorun muscle

#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $folderin="";
my $folderout="";
GetOptions('folderin=s'=>\$folderin,'folderout=s'=>\$folderout);

#print "\nfolderout: $folderout\n";exit;

#############################################################################################################################
if (($folderin) and ($folderout)){print "\nProcessing...";}
else
{
	print "\n";
	print "Usage: run MSA using muscle for fasta file in input folder\n";
	print "--folderin: input folder containing fasta files\n";
	print "--folderout: output folder containing MSA profiles in fasta format\n";
	print "\n";
}
#############################################################################################################################

mkdir $folderout;
opendir(DIR,"$folderin") || die "Cannot open folder $folderin";
my @files=readdir(DIR);
foreach my $file (@files)
{
	if (($file ne ".") and ($file ne ".."))
	{
		my $fileout=$file;
		if ($file=~/\.fasta/){$fileout=substr($file,0,-6);}
		$fileout=$fileout."_muscle.fasta";
		my $cmd="muscle -in $folderin/$file -out $folderout/$fileout";
		system $cmd;
	}
}
closedir(DIR);
print "...finished\n";
