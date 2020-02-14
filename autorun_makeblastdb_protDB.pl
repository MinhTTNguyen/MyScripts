# Friday, January 25, 2019
# auto-create protein database for each complete bacillus genome

#! /usr/perl/bin -w
use strict;
use Getopt::Long;


my $proteome_folder="";

GetOptions('in=s'=>\$proteome_folder);

if ($proteome_folder){print "\nStart processing...\n";}
else
{
	print "\n";
	print "Please input the folder containing the protein sequence data sets\n";
	print "perl autorun_makeblastdb --in <your_folder>\n";
	print "\n";
}

opendir(DIR,$proteome_folder) || die "Could not open folder $proteome_folder";
my @protein_files=readdir(DIR);
closedir(DIR);
chdir $proteome_folder;

foreach my $file (@protein_files)
{
	if (($file ne ".") and ($file ne ".."))
	{
		my $cmd = "makeblastdb -in $file -dbtype prot -out $file";
		system $cmd;
	}
}

print "done!\n";
