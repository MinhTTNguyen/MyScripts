#! /usr/bin/perl -w
use strict;
use Getopt::Long;


#### Please check the cutoff values before running the program
my $protein_folder="";

GetOptions('in=s'=>\$protein_folder);

my $splits_hmmscan_out_dbCAN_folder=$protein_folder."_out_dbCANv6";
my $splits_hmmscan_tbout_dbCAN_folder=$protein_folder."_tbout_dbCANv6";
my $splits_hmmscan_out_newHMM_folder=$protein_folder."_out_CSFG";
my $splits_hmmscan_tbout_newHMM_folder=$protein_folder."_tbout_CSFG";

mkdir $splits_hmmscan_out_dbCAN_folder;
mkdir $splits_hmmscan_tbout_dbCAN_folder;
mkdir $splits_hmmscan_out_newHMM_folder;
mkdir $splits_hmmscan_tbout_newHMM_folder;

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
		
		my $fileout_dbCAN=$file.".dbCAN.out";
		my $filetbout_dbCAN=$file.".dbCAN.tbout";
		
		my $fileout_newHMM=$file.".CSFG.out";
		my $filetbout_newHMM=$file.".CSFG.tbout";
		
		my $cmd_dbCAN="hmmscan -o $splits_hmmscan_out_dbCAN_folder\/$fileout_dbCAN --tblout $splits_hmmscan_tbout_dbCAN_folder\/$filetbout_dbCAN -E 0.00001 --domE 0.00001 --cpu 20 dbCAN_HMMs_v6_noGH74_noCBM10_noCE1.txt $protein_folder\/$file";
		my $cmd_newHMM="hmmscan -o $splits_hmmscan_out_newHMM_folder\/$fileout_newHMM --tblout $splits_hmmscan_tbout_newHMM_folder\/$filetbout_newHMM -E 0.00001 --domE 0.00001 --cpu 20 GH74_CE1_CSFG_CBM10PF_HMMs.txt $protein_folder\/$file";
		
		system "$cmd_dbCAN";
		system "$cmd_newHMM";
		
		print "Running hmmscan on file $file_count: $file ............. done\n\n";
	}
}
closedir(DIR);
