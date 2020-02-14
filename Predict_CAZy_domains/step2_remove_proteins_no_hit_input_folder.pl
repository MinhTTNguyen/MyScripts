#! /usr/perl/bin -w
use strict;
use Getopt::Long;


my $folderin="";
my $folderout="";

GetOptions('in=s'=>\$folderin,'out=s'=>\$folderout);

mkdir $folderout;
opendir(DIR,"$folderin") || die "Could not open folder $folderin";
my @files=readdir(DIR);
foreach my $file (@files)
{
	if (($file ne ".") and ($file ne ".."))
	{
		open(In,"<$folderin/$file") || die "Could not open file $folderin/$file";
		open(Out,">$folderout/$file") || die "Could not open file $folderout/$file";
		while (<In>)
		{
			$_=~s/\s*$//;
			$_=~s/^\#//;
			my @cols=split(/\t/,$_);
			my $protid=$cols[0];
			my $num_cols=scalar(@cols);
			if ($num_cols>2)
			{
				if ($protid=~/^jgi\|/)
				{
					my @temps=split(/\|/,$protid);
					$protid=$temps[0]."|".$temps[1]."|".$temps[2];
				}
				shift(@cols);
				my $new_line_without_protid=join("\t",@cols);
				print Out "$protid\t$new_line_without_protid\n";
			}
		}
		close(In);
		close(Out);
	}
}
closedir(DIR);