=pod
October 2nd 2015
This script is to combine hmmscan results from 2 sets of HMMs(dbCAN HMMs and from in-house HMMs), then sort the results according to the domain locations
=cut

#! /usr/perl/bin -w
use strict;

print "\nInput working directory: ";
my $path=<STDIN>;
chomp($path);

print "\nInput folder containing hmmscan results from dbCAN HMMs: ";
my $folderin_dbCAN=<STDIN>;
chomp($folderin_dbCAN);

print "\nInput folder containing hmmscan results from in-house HMMs: ";
my $folderin_newHMM=<STDIN>;
chomp($folderin_newHMM);

my $folderout="dbCANv6_CSFG";
mkdir "$path\/$folderout";

# Combine results from dbCAN and newHMMs
opendir(dbCAN,"$path\/$folderin_dbCAN") || die "Cannot open folder $folderin_dbCAN";
my @dbCAN_files=readdir(dbCAN);
foreach my $dbCANfile (@dbCAN_files)
{
	unless (($dbCANfile eq ".") || ($dbCANfile eq ".."))
	{
		my $newHMM_file=$dbCANfile;
		my $combine_file=$dbCANfile;
		$newHMM_file=~s/dbCAN/CSFG/;
		#$newHMM_file=~s/dbCAN/newHMM/;
		$combine_file=~s/\.fasta\.dbCAN.+$//;
		$combine_file=$combine_file.".csv";
		open(dbCANfile,"<$path\/$folderin_dbCAN\/$dbCANfile") || die "Cannot open file $path\/$folderin_dbCAN\/$dbCANfile";
		open(newHMM_file,"<$path\/$folderin_newHMM\/$newHMM_file") || die "Cannot open file $path\/$folderin_newHMM\/$newHMM_file";
		open(Out,">$path\/$folderout\/$combine_file") || die "Cannot open file $path\/$folderout\/$combine_file";
		my @hmmscan_results;
		my $headers="";
		while (<dbCANfile>)
		{
			chomp($_);
			if ($_=~/^Seq\_id/){$headers=$_;}
			else{push(@hmmscan_results,$_);}
		}
		while (<newHMM_file>)
		{
			chomp($_);
			unless ($_=~/^\Seq\_id/){push(@hmmscan_results,$_);}
		}
		# $headers=~s/^\#//;
		print Out "$headers\n";
		foreach my $line (@hmmscan_results)
		{
			my @columns=split(/\t/,$line);
			my $num_cols=scalar(@columns);
			if ($num_cols>2){print Out "$line\n";}
		}
		close(dbCANfile);
		close(newHMM_file);
		close(Out);
	}
}
closedir(dbCAN);
