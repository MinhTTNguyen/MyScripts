# 30th April 2012
# This script is to report the BLASTP result in tabular format as followed:
# Query	Query_length	Hit_ID	Target_length	E_value	%Id	%Si	%query_coverage	%target_coverage	Query_start	Target_start	Query_end	Target_end
# *new: Query sequences include those from Spoth2p4 and the collected AARSs
# *new: add query coverage and target coverage

# Modified on January 10th 2014: no important modification
# Modified on January 13th 2014: only print out the first hit

#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $folder_in="";

GetOptions('in=s'=>\$folder_in);

my $folder_out=$folder_in."_best_hit";
mkdir "$folder_out";
#chdir "$folder_out";
opendir(DIR, "$folder_in") || die "Cannot open folder: $folder_in";
my @files=readdir(DIR);
closedir(DIR);
my $count=0;
print "\n";
foreach my $filein (@files)
{
	unless (($filein eq ".") || ($filein eq ".."))
	{
		$count++;
		print "$count. $filein...";
		my $fileout=substr($filein,0,-6);
		$fileout=$fileout."_tabular.txt";

		open(In,"<$folder_in/$filein") || die "Cannot open file $filein";
		open(Out,">$folderout/$fileout") || die "Cannot open file $fileout";
		print Out "Query\tQuery_length\tTarget_ID\tTarget_length\tE_value\tIdentity\tSimilarity\tQuery_coverage\tTarget_coverage\tQuery_start\tTarget_start\tQuery_end\tTarget_end\n";
		my $query="";
		my $query_len="";
		my $target_id="";
		my $target_len="";
		my $e_value="";
		my $id="";
		my $si="";
		my $query_start="";
		my $query_end="";
		my $target_start="";
		my $target_end="";
		my $query_cov="";
		my $target_cov="";
		my %hash_query_print_status=();
		while (<In>)
		{
			chomp($_);
			#Query= sp|P50475|SYAC_RAT Alanine--tRNA ligase, cytoplasmic OS=Rattus norvegicus GN=Aars PE=1 SV=3
			# or Query= Spoth2p4_006882_Arg_cyt
			if ($_=~/^Query\=/)
			{
				if ($query)
				{
					if ($target_id)
					{
						if ($query_len>0) {$query_cov=($query_end-$query_start+1)/$query_len;}
						else {print "$query\t$query_len\t$target_id\t$target_len";exit;}
						if ($target_len>0){$target_cov=($target_end-$target_start+1)/$target_len;}
						else {print "$query\t$query_len\t$target_id\t$target_len";exit;}
						unless($hash_query_print_status{$query}){print Out "$query\t$query_len\t$target_id\t$target_len\t$e_value\t$id\t$si\t$query_cov\t$target_cov\t$query_start\t$target_start\t$query_end\t$target_end\n";$hash_query_print_status{$query}=1;}
					}else {unless($hash_query_print_status{$query}){print Out "$query\t$query_len\tNo hits\n";$hash_query_print_status{$query}=1;}}
				}
				$query="";
				$query_len="";
				$target_id="";
				$target_len="";
				$e_value="";
				$id="";
				$si="";
				$query_start="";
				$query_end="";
				$target_start="";
				$target_end="";
				$query_cov="";
				$target_cov="";
				if ($_=~/^Query\=\s*(.*)/){$query=$1;$query=~s/\s*//g;}
				else {print "Query is not as described!!!\n$_\n";}
			}
	
			#>Spoth2p4_011163
			#Length = 1118
			if ($_=~/^\>\s*(.*)/)
			{
				if ($target_id)
				{
					if ($query_len>0) {$query_cov=($query_end-$query_start+1)/$query_len;}
					else {print "$query\t$query_len\t$target_id\t$target_len";exit;}
					if ($target_len>0){$target_cov=($target_end-$target_start+1)/$target_len;}
					else {print "$query\t$query_len\t$target_id\t$target_len";exit;}
					unless($hash_query_print_status{$query}){print Out "$query\t$query_len\t$target_id\t$target_len\t$e_value\t$id\t$si\t$query_cov\t$target_cov\t$query_start\t$target_start\t$query_end\t$target_end\n";$hash_query_print_status{$query}=1;}
				}
				$target_id="";
				$target_len="";
				$e_value="";
				$id="";
				$si="";
				$query_start="";
				$query_end="";
				$target_start="";
				$target_end="";
				$query_cov="";
				$target_cov="";
			
				$target_id=$1;
				#print "Target ID: $target_id";exit;
			}
			#old BLASTP version
			#Query= Spoth2p4_006882_Arg_cyt
			#         (1176 letters) 
			# Below is the new version
			#Query= Spoth2p4_001239_Ala_cyt
			#Length=959
			#>Spoth2p4_011163
			#Length = 1118
			if ($_=~/^Length=(\d+)/)
			{
				my $temp=$1;
				if ($target_id) {$target_len=$temp;}
				else {$query_len=$temp;}
			}
		
			# Score =  512 bits (1318), Expect = e-145,   Method: Compositional matrix adjust. (old version)
			# Score = 1393 bits (3606),  Expect = 0.0, Method: Compositional matrix adjust. (new version)
			if ($_=~/.*\,\s*Expect\s*\=\s*(.*)\,\s*Method/)
			{
				if ($e_value)
				{
					if ($query_len>0) {$query_cov=($query_end-$query_start+1)/$query_len;}
					else {print "$query\t$query_len\t$target_id\t$target_len";exit;}
					if ($target_len>0){$target_cov=($target_end-$target_start+1)/$target_len;}
					else {print "$query\t$query_len\t$target_id\t$target_len";exit;}
					unless($hash_query_print_status{$query}){print Out "$query\t$query_len\t$target_id\t$target_len\t$e_value\t$id\t$si\t$query_cov\t$target_cov\t$query_start\t$target_start\t$query_end\t$target_end\n";$hash_query_print_status{$query}=1;}
				}
				$e_value="";
				$id="";
				$si="";
				$query_start="";
				$query_end="";
				$target_start="";
				$target_end="";
				$query_cov="";
				$target_cov="";
			
				$e_value=$1;
			}
	
			# Identities = 16/64 (25%), Positives = 26/64 (40%), Gaps = 6/64 (9%)
			# Identities = 10/19 (52%), Positives = 13/19 (68%)
			# new version:
			# Identities = 680/954 (72%), Positives = 799/954 (84%), Gaps = 3/954 (0%)
			if ($_=~/Identities\s*\=\s*.*\((.*)\%\)\,\s*Positives\s*\=\s*\d*\/\d*\s*\((\d*)\%\)/){$id=$1; $si=$2;}
		
			# Query: 90  LVAVGDHASKQMVKFAANINKESIVDVEGVVRKVNQKIGS-CTQQDVELHVQKIYVISLA 148
			# Sbjct: 68  FVSLGDGSSLAPLQALVQADDAKDLAVGAAVRLTGSWVSSPGVAQSHELHVSRVEVLGPS 127
			# new:
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
			else{print "$query\t$query_len\t$target_id\t$target_len";exit;}
			if ($target_len>0){$target_cov=($target_end-$target_start+1)/$target_len;}
			else {print "$query\t$query_len\t$target_id\t$target_len";exit;}
			unless($hash_query_print_status{$query}){print Out "$query\t$query_len\t$target_id\t$target_len\t$e_value\t$id\t$si\t$query_cov\t$target_cov\t$query_start\t$target_start\t$query_end\t$target_end\n";$hash_query_print_status{$query}=1;}
		}else {unless($hash_query_print_status{$query}){print Out "$query\t$query_len\tNo hits\n";$hash_query_print_status{$query}=1;}}
		close(In);
		close(Out);
		print "done\n";
	}
	#my @temp_arr=keys(%hash_query_print_status);
	#my $number_NRRL3=scalar(@temp_arr);
	#print "Number of NRRL3 query sequences: $number_NRRL3";
}
