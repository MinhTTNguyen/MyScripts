=pod
December 1st 2014
This script is to read the manually checked tabular file format results from PFAM and create for each gene the domain organization as followed:
Ex: REMTH_00010	GH13(evalue, HMM_fraction)|GT5(-,-) - CBM12
|: domains found in overlapping regions
-: domains found in separate regions

Modified on 10th December 2014
Input only onle file containing combined results from PFAM and newHMMs

Modified on December 20th 2017 so that the script can get PFAM domain module
=cut

#! /usr/perl/bin -w
use strict;
use Getopt::Long;
=pod
print "\nInput directory of input files: ";
my $pathin=<STDIN>;
chomp($pathin);

print "\nInput directory of output files: ";
my $pathout=<STDIN>;
chomp($pathout);

print "\nInput file containing PFAM results (PFAM + newHMMs)(location sorted): ";
my $file_PFAM=<STDIN>;
chomp($file_PFAM);

print "\nInput name of output file: ";
my $fileout=<STDIN>;
chomp($fileout);
=cut

my $pathin="";
my $pathout="";
my $file_PFAM="";
my $fileout="";
my $evalue_cutoff=1E-05;
GetOptions('pathin=s'=>\$pathin, 'file_PFAM=s'=>\$file_PFAM, 'pathout=s'=>\$pathout, 'fileout=s'=>\$fileout);
mkdir "$pathout";
my %hash_all_ids;

#############################################################################################################################
open(PFAM,"<$pathin/$file_PFAM") || die "Cannot open file $pathin/$file_PFAM";
my %hash_PFAM_info;
my %hash_PFAM_end;
while (<PFAM>)
{
	$_=~s/\s*$//;
	##Protein_ID	Analysis	Signature Accession	Signature Description	Start location	Stop location	e-value	Status	Date	InterPro accession	InterPro description	GO annotations	Pathways annotations
	unless($_=~/^\#/)
	{
		#InterPro: Anamu_P00001	Pfam	PF08385	Dynein heavy chain, N-terminal region 1	247	824	4.80E-95	T	06/11/2017	IPR013594	Dynein heavy chain, domain-1		
		#Pfamscan: seq id	alignment start	alignment end	envelope start	envelope end	hmm acc	hmm name	type	hmm start	hmm end	hmm length	bit score	E-value	significance	clan
		#AACD_12128	1                  54	437	53	438	PF00199.18	Catalase	Domain	2	382	383	543.9	1.90E-163	1	No_clan
		my @cols=split(/\t/,$_);
		my $id=$cols[0];
		my $pfam_id=$cols[5];
		my $evalue=$cols[12];
		my $start=$cols[3];
		my $end=$cols[4];
		
		if ($evalue<=$evalue_cutoff)
		{
			$hash_all_ids{$id}++;
			if ($hash_PFAM_info{$id})
			{
				if ($hash_PFAM_end{$id}>$start)
				{
					$hash_PFAM_info{$id}=$hash_PFAM_info{$id}.' | '.$pfam_id." (".$evalue." ,".$start." , ".$end.")";
					if ($hash_PFAM_end{$id}<$end){$hash_PFAM_end{$id}=$end;}
				}else
				{
					$hash_PFAM_info{$id}=$hash_PFAM_info{$id}." - ".$pfam_id." (".$evalue." , ".$start." , ".$end.")";
					$hash_PFAM_end{$id}=$end;
				}
			}else
			{
				$hash_PFAM_info{$id}=$pfam_id." (".$evalue." , ".$start." , ".$end.")";
				$hash_PFAM_end{$id}=$end;
			}
		}
	}
}
close(PFAM);
#############################################################################################################################


#############################################################################################################################
open(Out,">$pathout/$fileout") || die "Cannot open file $pathout/$fileout";
print Out "#Seqid\tPFAM_domains\n";
while (my ($k_id,$v)=each(%hash_all_ids))
{
	my $PFAM_result=$hash_PFAM_info{$k_id};
	print Out "$k_id\t$PFAM_result\n";
}
close(Out);
#############################################################################################################################