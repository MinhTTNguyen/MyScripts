#! /usr/bin/perl -w
use strict;
use Getopt::Long;


#### Please check the cutoff values before running the program
my $protein_folder="";
my $hmm_db="";
GetOptions('in=s'=>\$protein_folder,'hmm_db=s'=>\$hmm_db);

my $hmmscan_outfolder=$protein_folder."_out";
my $hmmscan_tboutfolder=$protein_folder."_tbout";

mkdir $hmmscan_outfolder;
mkdir $hmmscan_tboutfolder;

opendir(DIR,"$protein_folder") || die "Cannot open folder $protein_folder";
my @files=readdir(DIR);
my $total_files=scalar(@files);
$total_files=$total_files-2;
print "\nRunning hmmscan for $total_files protein files\n";
my $file_count=0;
foreach my $file (@files)
{
	if (($file eq ".") || ($file eq ".."))
	{
		print "No hmmscan runnning on file: $file\n";
	}
	else
	{
		$file_count++;
		print "Running hmmscan on file $file_count: $file ............. begin\n";
		
		my $fileout=$file.".out";
		my $filetbout=$file.".tbout";
		
		
		my $cmd="hmmscan -o $hmmscan_outfolder\/$fileout --tblout $hmmscan_tboutfolder\/$filetbout -E 0.00001 --domE 0.00001 --cpu 5 $hmm_db  $protein_folder\/$file";
		
		system "$cmd";
		
		print "Running hmmscan on file $file_count: $file ............. done\n\n";
	}
}
closedir(DIR);
