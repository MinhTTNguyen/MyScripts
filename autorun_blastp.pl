# Autorun BLASTP program
 
#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $folderin="";
my $folderout="";
my $query="";


GetOptions('in=s'=>\$folderin,'out=s'=>\$folderout,'query=s'=>\$query);

##################################################################################################################################################################
if (($folderin) and ($folderout) and ($query)){print "\nStart processing...\n";}
else
{
	print "\n";
	print "Usage: run blastp search against multiple protein databases\n";
	print "--in: input folder containing the protein database files\n";
	print "--out: output folder containing the blastp output files\n";
	print "--query: input fasta protein sequence file which will be used a query\n";
	print "\n";
}

##################################################################################################################################################################









##################################################################################################################################################################
# get list of protein databases
mkdir $folderout;
chdir $folderin;
opendir(DIR,"$folderin") || die "Could not open folder $folderin";
my @folderin_files=readdir(DIR);
my @files; #This array contain list of names of all protein sequence databases
foreach my $file (@folderin_files)
{
	if ($file=~/(.+)\.pin$/)
	{
		my $new_file=$1;
		push(@files,$new_file);
	}
}

###############################################################################################################################################################








###############################################################################################################################################################
# run blastp
my $filecount=0;
foreach my $file (@files)
{
	if (($file ne ".") and ($file ne ".."))
	{
		my $fileout=substr($file,0,-5);
		$fileout=$fileout."out";
		$filecount++;
		print "$filecount.$file:start...............................";
		my $cmd_blastp = "blastp -query $query -db $file -evalue 1E-10 -num_threads 20 -out $folderout/$fileout";
		system $cmd_blastp;
		print "finish\n";
	}
}
closedir(DIR);
print "done!\n";
###############################################################################################################################################################
