=pod
August 10th 2015
This script is to make the script "step1_read_hmmscan.pl" deal with multiple input files and print out corresponding output files
#! C:\Perl64\bin -w
=cut

#! /usr/perl/bin -w
use strict;

print "\nInput working directory: ";
my $path=<STDIN>;
chomp($path);

print "\nInput folder containing hmmscan output: ";
my $folderin=<STDIN>;
chomp($folderin);

print "\nInput file containing lengths of HMMs: ";
my $file_hmm_len=<STDIN>;
chomp($file_hmm_len);

#print "\nInput hmm fraction cutoff value (1-100): ";
#my $hmm_fraction_cutoff=<STDIN>;
#chomp($hmm_fraction_cutoff);

#print "\nInput cutoff evalue (e.g., 1E-10): ";
#my $evalue_cutoff=<STDIN>;
#chomp($evalue_cutoff);

print "\nInput folder containing tabular format files: ";
my $folderout=<STDIN>;
chomp($folderout);


mkdir "$path\/$folderout";
#---------------------------------------------------------------------------------------------

opendir(DIR,"$path\/$folderin") || die "Cannot open folder $path\/$folderin";
my @files=readdir(DIR);
#shift(@files);shift(@files);
closedir(DIR);
my $file_no=0;
foreach my $filein (@files)
{
	unless (($filein eq ".") || ($filein eq ".."))
	{
		my $fileout=substr($filein,0,-4);
		$fileout=$fileout.".txt";
		my $cmd="perl step1_read_hmmscan_dbCAN_cutoff.pl --path $path --filein $folderin\/$filein --file_hmm_len $file_hmm_len --fileout $folderout\/$fileout";
		$file_no++;
		print "File $file_no: begin... ";
		system $cmd;
		print "finished.\n";
	}
}