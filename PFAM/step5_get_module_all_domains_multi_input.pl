# August 21st 2015

#! C:\Perl64\bin -w
use strict;

print "\nInput working directory: ";
my $path=<STDIN>;
chomp($path);

print "\nInput folder containing hmmscan results (domain locations are sorted): ";
my $folder_hmmscan=<STDIN>;
chomp($folder_hmmscan);

print "\nInput folder containing output files: ";
my $folderout=<STDIN>;
chomp($folderout);

opendir(HMMSCAN,"$path/$folder_hmmscan") || die "Cannot open folder $folder_hmmscan";
my @hmmscan_files=readdir(HMMSCAN);
#shift(@hmmscan_files);shift(@hmmscan_files);
foreach my $hmmscan_file (@hmmscan_files)
{
	unless (($hmmscan_file eq ".") || ($hmmscan_file eq ".."))
	{
		my $fileout=$hmmscan_file;
		$fileout=substr($fileout,0,-3);
		$fileout=$fileout."txt";
	
		my $cmd="perl step5_get_module_all_domains_single_input.pl --pathin $path/$folder_hmmscan --file_PFAM $hmmscan_file --pathout $path/$folderout --fileout $fileout";
		system $cmd;
	}
}
closedir(HMMSCAN);