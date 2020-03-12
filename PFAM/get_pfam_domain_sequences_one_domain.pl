# March 27th 2019
# Read output result from pfamscan and full-length protein sequence file and print out sequences of domain of interest

#! /usr/perl/bin -w
use strict;
my $filein_fasta="/mnt/csfg-fs3/UserProfiles/tnguy/CSFG_JGI_fungi_12Mar2019/NRRL3_07789_05481/NRRL3_05481_fungal_ortholog_ids.fasta";
my $filein_pfamscan="/mnt/csfg-fs3/UserProfiles/tnguy/CSFG_JGI_fungi_12Mar2019/NRRL3_07789_05481/NRRL3_05481_fungal_ortholog_ids_pfamscan_v31.txt";
my $selected_domain="PF00122.19"; # pfam domain id
my $fileout=substr($filein_fasta,0,-6);
$fileout=$fileout."_".$selected_domain."_domainseq.fasta";
$selected_domain=~s/\s*//g;



#==========================================================================================================#
open(FASTA,"<$filein_fasta") || die "Cannot open file $filein_fasta";
my $id="";
my $seq="";
my %hash_fasta;
while (<FASTA>)
{
	$_=~s/^\s*//;$_=~s/\s*$//;
	if ($_=~/^\>/)
	{
		if ($seq)
		{
			$seq=uc($seq);
			$hash_fasta{$id}=$seq;
			$id="";$seq="";
		}
		$id=$_;
		$id=~s/^\>//;
	}else{$_=~s/\s*//g;$seq=$seq.$_;}
}
$seq=uc($seq);
$hash_fasta{$id}=$seq;
close(FASTA);
#==========================================================================================================#




#==========================================================================================================#
# read cazyme list and keep ids of proteins containing the domain of interest
open(PFAMSCAN,"<$filein_pfamscan") || die "Cannot open file $filein_pfamscan";
open(Out,">$fileout") || die "Cannot open file $filein_fasta";
my %hash_selected_id_cazy;
while (<PFAMSCAN>)
{
	unless ($_=~/^\#/)
	{
		$_=~s/^\s*//;
		$_=~s/\s*$//;
		
		unless($_){next;}
		
		$_=~s/\s+/\t/g;
		
		my @columns=split(/\t/,$_);
		my $protid=$columns[0];
		my $envelop_start=$columns[3];
		my $envelop_end=$columns[4];
		my $pfamid=$columns[5];
		#print "\n$pfamid\n";exit;
		if ($pfamid eq $selected_domain)
		{
			my $protein_seq=$hash_fasta{$protid};
			if ($protein_seq)
			{
				my $domain_len=$envelop_end-$envelop_start+1;
				my $domain_seq=substr($protein_seq,$envelop_start-1,$domain_len);
				my $domain_id=$protid."|".$envelop_start."-".$envelop_end;
				print Out ">$domain_id\n$domain_seq\n";
			}else{print "\nError: could not find protein sequence for this id: $protid\n";exit;}
		}
	}
}
close(PFAMSCAN);
close(Out);
#==========================================================================================================#
