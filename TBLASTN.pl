=pod
August 27th 2015
This script is to convert output files from TBLASTN search into tabular format
This script can work with tblastn version 2.2.29+ and 2.2.31+
=cut


#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $folder_in="";

GetOptions('in=s'=>\$folder_in);

my $folder_out=$folder_in."_all_hits";
mkdir "$folder_out";



#----------------------------------------------------------------------------------------------------------------#
# Read tblastn output files and process them
#----------------------------------------------------------------------------------------------------------------#
opendir(DIR, "$folder_in") || die "Cannot open folder: $folder_in";
my @files=readdir(DIR);
closedir(DIR);
shift(@files);shift(@files);
foreach my $filein (@files)
{
	my $fileout=substr($filein,0,-4);
	$fileout=$fileout."_best_hit.txt";

	open(In,"<$folder_in/$filein") || die "Cannot open file $filein";
	open(Out,">$folder_out/$fileout") || die "Cannot open file $fileout";
	print Out "query\tquery_len\ttarget_id\ttarget_len\te_value\tid\tgap\tquery_cov\tquery_start\tquery_end\tFrame\ttarget_start\ttarget_end\n";
	
	my $query="";
	my $query_len="";
	my $target_id="";
	my $target_len="";
	my $e_value="";
	my $id="";
	my $gap="";
	my $query_start="";
	my $query_end="";
	my $target_start="";
	my $target_end="";
	my $query_cov="";
	my $frame="";
	
	
	while (<In>)
	{
		chomp($_);
		
		#Query= NRRL3_00001
		if ($_=~/^Query\=/)
		{
			if ($query)
			{
				if ($target_id)
				{
					if ($query_len>0) {$query_cov=($query_end-$query_start+1)/$query_len;}
					else {print "Error (line 75): query length <=0\n$query\t$query_len\t$target_id\t$target_len";exit;}
					print Out "$query\t$query_len\t$target_id\t$target_len\t$e_value\t$id\t$gap\t$query_cov\t$query_start\t$query_end\t$frame\t$target_start\t$target_end\n";
				}else {print Out "$query\t$query_len\tNo hits\n";}
			}
			
			$query="";
			$query_len="";
			$target_id="";
			$target_len="";
			$e_value="";
			$id="";
			$gap="";
			$query_start="";
			$query_end="";
			$target_start="";
			$target_end="";
			$query_cov="";
			$frame="";		
			
			if ($_=~/^Query\=\s*(.*)/){$query=$1;$query=~s/\s*//g;}
			else {print "Query is not as described!!!\n$_\n";}
		}
	
		#> scaffold_21
		#Length=462071
		if ($_=~/^\>\s*(.*)/)
		{
			my $target_id_temp=$1;
			if ($target_id)
			{
				if ($query_len>0) {$query_cov=($query_end-$query_start+1)/$query_len;}
				else {print "Error (line 111): query length <=0\n$query\t$query_len\t$target_id\t$target_len";exit;}
				print Out "$query\t$query_len\t$target_id\t$target_len\t$e_value\t$id\t$gap\t$query_cov\t$query_start\t$query_end\t$frame\t$target_start\t$target_end\n";
			}
			
			$target_id="";
			$target_len="";
			$e_value="";
			$id="";
			$query_start="";
			$query_end="";
			$target_start="";
			$target_end="";
			$query_cov="";
			$frame="";			
			
			$target_id=$target_id_temp;
		}
		
		#Length=462071 (same for either query or target
		if ($_=~/^Length\=(\d+)/)
		{
			my $temp=$1;
			if ($target_id) {$target_len=$temp;}
			else {$query_len=$temp;}
		}
		
		# Score =   423 bits (1087),  Expect(2) = 0.0, Method: Compositional matrix adjust.
		# Score =   450 bits (1158),  Expect = 6e-131, Method: Compositional matrix adjust.
		if ($_=~/.*\,\s*Expect\(*\d*\)*\s*\=\s*(.+)\,\s*Method\:/)
		{
			my $evalue_temp=$1;
			if ($e_value)
			{
				if ($query_len>0) {$query_cov=($query_end-$query_start+1)/$query_len;}
				else {print "Error (line 154): query length <=0\n$query\t$query_len\t$target_id\t$target_len";exit;}
				print Out "$query\t$query_len\t$target_id\t$target_len\t$e_value\t$id\t$gap\t$query_cov\t$query_start\t$query_end\t$frame\t$target_start\t$target_end\n";
			}
			
			$e_value="";
			$id="";
			$query_start="";
			$query_end="";
			$target_start="";
			$target_end="";
			$query_cov="";
			$frame="";
			$e_value=$evalue_temp;
		}
	
		# Identities = 444/1323 (34%), Positives = 661/1323 (50%), Gaps = 193/1323 (15%)
		if ($_=~/^\s*Identities\s*\=\s*\d*\/\d*\s*\(\d*\%\)\,/)
		{
			if ($_=~/^\s*Identities\s*\=\s*\d*\/\d*\s*\((\d*)\%\)\,.+Gaps\s*\=\s*\d*\/\d*\s*\((\d*)\%\)/)
			{
				$id=$1;$gap=$2;
			}else{print "Error (line 168): Line containing identity and gap information is not as described!\n$_\n";exit;}
		}
		
		# Frame = -2
		# Frame = +2
		if ($_=~/^\s*Frame\s*\=\s*([\-\+]\d+)/){$frame=$1;}
		
	
		#Query  3    EIEWTGARVRKTFLDFFAERGHSIVPSSSVVPHNDPTLLFTNAGMNQFKPIFLGTIGKTE  62
		#Sbjct  6    EHRWSAPRVRQAFLDFFSQKEHTIVPSSSVVPHNDPTLLFTNAGMNQFKPVFLGTVAQSD  65
		if ($_=~/^Query\s*(\d+)\s*.*\s+(\d+)/) 
		{	
			unless ($query_start){$query_start=$1;}
			$query_end=$2;
		}	
	
		if ($_=~/^Sbjct\s*(\d+)\s*.*\s+(\d+)/) 
		{	
			unless ($target_start){$target_start=$1;}
			$target_end=$2;
		}
	}
	if ($target_id)
	{
		if ($query_len>0) {$query_cov=($query_end-$query_start+1)/$query_len;}
		else {print "Error (line 208): query length <=0\n$query\t$query_len\t$target_id\t$target_len";exit;}
		print Out "$query\t$query_len\t$target_id\t$target_len\t$e_value\t$id\t$gap\t$query_cov\t$query_start\t$query_end\t$frame\t$target_start\t$target_end\n";
	}else {print Out "$query\t$query_len\tNo hits\n";}
	close(In);
	close(Out);
}
