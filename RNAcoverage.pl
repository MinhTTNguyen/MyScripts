#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $folderin="";
my $fileout="";

GetOptions('in=s'=>\$folderin,'out=s'=>\$fileout);
open (Out,">$fileout") || die "Cannot open file $fileout";;
print Out "#File\tHave RNA coveraga\n";
opendir(DIR,$folderin) || die "Cannot open file $folderin";
my @files=readdir(DIR);
foreach my $file (@files)
{
	if (($file eq ".") || ($file eq "..")){next;}
	else
	{
		#print "$file\n";
		open(In,"<$folderin/$file") || die "Cannot open file $folderin/$file";
		while (<In>)
		{
			$_=~s/\s*$//;
			#print "\n$file\t$_\n";
			if ($_=~/RNA\s*coverage/) #<br>RNA coverage based on GMAP alignments<p>
			{
				print Out "$file\t$_\n";
			}
		}
		close(In);
	}
	#exit;
}
closedir(DIR);
close(Out);