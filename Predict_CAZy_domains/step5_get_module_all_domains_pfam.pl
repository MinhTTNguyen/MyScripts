=pod
December 1st 2014
This script is to read the manually checked tabular file format results from PFAM and create for each gene the domain organization as followed:
Ex: REMTH_00010	GH13(evalue, HMM_fraction)|GT5(-,-) - CBM12
|: domains found in overlapping regions
-: domains found in separate regions

Modified on 10th December 2014
Input only onle file containing combined results from PFAM and newHMMs
=cut

#! C:\Perl64\bin -w
use strict;
use Getopt::Long;

my $file_PFAM="/home/mnguyen/Research/A_nidulans/Workshop_09Aug2018/All_PFAM_from_InterProScan_Anidulans_09Aug2018_domain_sorted.txt";
my $fileout="/home/mnguyen/Research/A_nidulans/Workshop_09Aug2018/All_PFAM_from_InterProScan_Anidulans_09Aug2018_1prot_1row_all_domains.txt";

=cut

=pod
my $pathin="";
my $pathout="";
my $file_PFAM="";
my $fileout="";
GetOptions('pathin=s'=>\$pathin, 'file_PFAM=s'=>\$file_PFAM, 'pathout=s'=>\$pathout, 'fileout=s'=>\$fileout);
mkdir "$pathout";
=cut

my %hash_all_ids;

#############################################################################################################################
open(PFAM,"<$file_PFAM") || die "Cannot open file $file_PFAM";
my %hash_PFAM_info;
my %hash_PFAM_end;
while (<PFAM>)
{
	$_=~s/\s*$//;
	unless($_=~/^\#/)
	{
		##ProtID	md5 digest	Length	Analysis	Domain accession	Domain description	Start	Stop	Score	Status	Date	InterPro ID	InterPro decription	GO	Pathways
		my @cols=split(/\t/,$_);
		my $id=$cols[0];
		my $pfam_id=$cols[4];
		my $pfam_desc=$cols[5];
		my $evalue=$cols[8];
		my $start=$cols[6];
		my $end=$cols[7];
		
		$hash_all_ids{$id}++;
		
		if ($hash_PFAM_info{$id})
		{
			if ($hash_PFAM_end{$id}>$start)
			{
				$hash_PFAM_info{$id}=$hash_PFAM_info{$id}.' | '.$pfam_id." (".$evalue." , ".$start." , ".$end."):".$pfam_desc;
				if ($hash_PFAM_end{$id}<$end){$hash_PFAM_end{$id}=$end;}
			}else
			{
				$hash_PFAM_info{$id}=$hash_PFAM_info{$id}." - ".$pfam_id." (".$evalue." , ".$start." , ".$end."):".$pfam_desc;
				$hash_PFAM_end{$id}=$end;
			}
		}else
		{
			$hash_PFAM_info{$id}=$pfam_id." (".$evalue." , ".$start." , ".$end."):".$pfam_desc;
			$hash_PFAM_end{$id}=$end;
		}
	}
}
close(PFAM);
#############################################################################################################################


#############################################################################################################################
open(Out,">$fileout") || die "Cannot open file $fileout";
print Out "#Seqid\tCAZy\n";
while (my ($k_id,$v)=each(%hash_all_ids))
{
	my $PFAM_result=$hash_PFAM_info{$k_id};
	print Out "$k_id\t$PFAM_result\n";	
}
close(Out);
#############################################################################################################################