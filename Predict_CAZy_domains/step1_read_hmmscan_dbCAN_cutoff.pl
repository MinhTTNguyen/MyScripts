=pod
November 17th 2014
This script is to read file output from hmmscan and print out another file in tabular format:
Query	Family	Evalue	HMM_fraction	HMM_start	HMM_stop	HMM_length	query_domain_start	query_domain_stop

# Modified on Nov 18th 2014
Add HMM len and query len so that curators can see the domain matching regions on the query sequence

# Modified on 26 July 2017
Use dbCAN cutoff values since these parameters were optimized when developing dbCAN
if alignment length > 80aa, e<1E-05; otherwise, E<1E-03
=cut

#! /usr/perl/bin -w
use strict;
use Getopt::Long;


my $path="";
my $filein="";
my $file_hmm_len="";
my $fileout="";
GetOptions('path=s'=>\$path, 'filein=s'=>\$filein, 'file_hmm_len=s'=>\$file_hmm_len, 'fileout=s'=>\$fileout);

my $hmm_fraction_cutoff=30;
my $evalue_cutoff_1=1E-05;
my $evalue_cutoff_2=1E-03;




################################################################################################################
if (($path) and ($filein) and ($file_hmm_len) and ($fileout)){print "\nStart processing...\n";}
else
{
	print "\n";
	print "Usage: read output file from hmmscan (.out) and print out results in tabular format\n";
	print "--path         : working directory containing the input and output files\n";
	print "--filein       : input file\n";
	print "--fileout      : output file\n";
	print "--file_hmm_len : file providing lengths of the HMMs\n";
	print "\n";
}
################################################################################################################







################################################################################################################
# read file containing lengths of HMM models
open(LEN,"<$path\/$file_hmm_len") || die "Cannot open file $file_hmm_len";
my %hash_hmm_len;
while (<LEN>)
{
	chomp($_);
	if ($_=~/(.+)\t(.+)/)
	{
		my $family=$1;
		my $len=$2;
		$family=~s/\s*//g;
		$len=~s/\s*//g;
		$hash_hmm_len{$family}=$len;
		#print "$family\t$len\n";
	}
	else {print "Error: line in file $file_hmm_len is not as described!\n$_\n";exit;}
}
close(LEN);
#exit;
################################################################################################################




################################################################################################################
open(In,"<$path\/$filein") || die "Cannot open file $filein";
open(Out,">$path\/$fileout") || die "Cannot open file $fileout";
print Out "Seq_id\tCAZy_family\tEvalue\tHMM_fraction\tHMM_from\tHMM_to\tHMM_len\tDomain_from\tDomain_to\tSeq_len\n";
my $seq_id="";
my $cazy_family="";
my $hmm_len="";
my $seq_len="";
while (<In>)
{
	chomp($_);
	
	# Query:       NRRL3_00161  [L=254]
	if ($_=~/^Query\:\s*(.+)\s+\[L\=(\d+)\]/){$seq_id=$1;$seq_len=$2;$cazy_family="";$hmm_len="";}
	
	#   [No hits detected that satisfy reporting thresholds]
	#if ($_=~/\s*\[No hits detected that satisfy reporting thresholds\]/) {print Out "$seq_id\tNo hit\n";}
	
	#>> AA3_fungi.hmm
	if ($_=~/\>\>/)
	{
		my $hmm_name_desc=$'; #E.g. "AA3_fungi.hmm" or "GT2_Cellulose_synt  Cellulose synthase"
		#print "-$hmm_name_desc-\n";
		$hmm_name_desc=~s/^\s*//;
		$hmm_name_desc=~s/\s+.*$//;
		#print "-$hmm_name_desc-\n";exit;
		unless($hmm_name_desc=~/\.hmm/){$hmm_name_desc=$hmm_name_desc.".hmm";}
		$cazy_family=$hmm_name_desc;
		$cazy_family=~s/\s*//g;
		$hmm_len=$hash_hmm_len{$cazy_family};
		unless($hmm_len){print "Error: cannot find HMM length of this family: $cazy_family\n";exit;}
	}
	
	#	1 !   32.4   0.0   1.1e-11   6.5e-11      74     135 .]     497     566 ..     431     566 .. 0.89
	#   1 !   31.7   3.2   5.3e-11   3.7e-09       2      99 ..     414     519 ..     413     533 .. 0.82
	if ($_=~/^\s+\d+\s*[\!\?]\s+[\d\.\-]*\s+[\d\.\-]*\s+[\d\.e\-]*\s+([\d\.e\-]*)\s+(\d+)\s+(\d+)\s*[\[\]\.]+\s+(\d+)\s+(\d+)\s*[\[\]\.]+\s+(\d+)\s+(\d+)\s*[\[\]\.]+\s*[\d\.]+/)
	{
		my $ievalue=$1;
		my $hmm_from=$2;
		my $hmm_to=$3;
		my $ali_from=$4;
		my $ali_to=$5;
		my $env_from=$6;
		my $env_to=$7;
		
		
		my $hmm_fraction="";
		if ($hmm_len)
		{
			$hmm_fraction=(($hmm_to-$hmm_from+1)/$hmm_len)*100;
			if ($hmm_fraction=~/\./)
			{
				my $int_fraction=$hmm_fraction;
				$int_fraction=~s/\..+$//;
				
				my $decimal=$hmm_fraction;
				$decimal=~s/^\d//;
				$decimal="0".$decimal;
				
				if ($decimal>=0.5){$hmm_fraction=$int_fraction+1;}
				else{$hmm_fraction=$int_fraction;}
			}
		}else{print "Error: Cannot find length of this HMM: $cazy_family\n";exit;}
		
		my $ali_len=$ali_to-$ali_from+1;
		#print "\n$ali_from\t$ali_to\t$ali_len\n";exit;
		if ($hmm_fraction>$hmm_fraction_cutoff)
		{
			if ($ali_len>80)
			{
				if ($ievalue<$evalue_cutoff_1){print Out "$seq_id\t$cazy_family\t$ievalue\t$hmm_fraction\%\t$hmm_from\t$hmm_to\t$hmm_len\t$env_from\t$env_to\t$seq_len\n";}
				#else {print Out "$seq_id\tdid not pass the thresholds\n";}
			}else
			{
				if ($ievalue<$evalue_cutoff_2){print Out "$seq_id\t$cazy_family\t$ievalue\t$hmm_fraction\%\t$hmm_from\t$hmm_to\t$hmm_len\t$env_from\t$env_to\t$seq_len\n";}
				#else {print Out "$seq_id\tdid not pass the thresholds\n";}
			}
		}
	}
}
close(In);
close(Out);
print "done\n";
################################################################################################################
