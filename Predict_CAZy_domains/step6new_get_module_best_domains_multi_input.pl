#! /usr/perl/bin -w
use strict;

print "\nInput current directory: ";
my $path=<STDIN>;
chomp($path);

print "\nInput folder containing files with gene ids and their CAZy assignment: ";
my $folderin=<STDIN>;
chomp($folderin);

print "\nInput name of folder containing output files: ";
my $folderout=<STDIN>;
chomp($folderout);
mkdir "$path/$folderout";

opendir(DIR,"$path/$folderin") || die "Cannot open folder $folderin";
my @files=readdir(DIR);
#shift(@files);shift(@files);
foreach my $filein (@files)
{
	unless (($filein eq ".") || ($filein eq ".."))
	{
		my $cmd="perl step6new_get_module_best_domains_single_input.pl --path $path --filein $folderin/$filein --fileout $folderout/$filein";
		system $cmd;
	}
}
closedir(DIR);

