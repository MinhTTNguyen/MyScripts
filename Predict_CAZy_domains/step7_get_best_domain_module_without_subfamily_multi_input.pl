#! /usr/perl/bin -w
use strict;

=pod
print "\nInput folder containing files with best domain module (with subfamily): ";
my $folderin=<STDIN>;
chomp($folderin);

print "\nInput name of folder containing output files: ";
my $folderout=<STDIN>;
chomp($folderout);
=cut
my $folderin="/mnt/csfg-fs3/UserProfiles/tnguy/For_colleagues/Marcos/Nigri_CAZymes";
my $folderout="/mnt/csfg-fs3/UserProfiles/tnguy/For_colleagues/Marcos/Nigri_CAZymes_nosubfamily";
mkdir "$folderout";

opendir(DIR,"$folderin") || die "Cannot open folder $folderin";
my @files=readdir(DIR);

foreach my $filein (@files)
{
	unless (($filein eq ".") || ($filein eq ".."))
	{
		my $cmd="perl get_best_domain_module_without_subfamily_3cols.pl --filein $folderin/$filein --fileout $folderout/$filein";
		system $cmd;
	}
}
closedir(DIR);

