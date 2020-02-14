# Tuesday, 16 July 2019
# Extract full-length and domain sequences from hmmsearch output file (*.domtblout)
#
#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $filein_hmmsearch="";
my $filein_fasta="";
my $fileout="";

GetOptions('filein_hmmsearch=s'=>\$filein_hmmsearch,'filein_fasta=s'=>\$filein_fasta,'fileout=s'=>\$fileout);


###################################################################################################################################
if (($filein_hmmsearch) and ($filein_fasta) and ($fileout)){print "\nRunning...\n";}
else
{
	print "\n";
	print "Usage: read hmmsearch output file (*.domtblout) and protein sequence file, then get the full-length and domain sequences\n";
	print "perl get_domain_full_seqs_from_hmmsearch_domtblout.pl --filein_hmmsearch --filein_fasta --fileout\n";
	print "--filein_hmmsearch: hmmsearch output file (*.domtblout)\n";
	print "--filein_fasta    : fasta file containing all protein sequences\n";
	print "--fileout         : output file\n";
	print "\n";
}
###################################################################################################################################





##################################################################################################################################
## Read fasta file and get protein sequences
my %hash_fasta;
open(FASTA,"<$filein_fasta") || die "Cannot open file $filein_fasta";
my $seq="";
my $id="";
while (<FASTA>)
{
	$_=~s/\s*$//;
        if ($_=~/^\>/)
        {
        	if ($seq)
                {
                	$seq=uc($seq);
                       	$hash_fasta{$id}=$seq;
                        $id="";
                       	$seq="";
                }
               	$id=$_;
                $id=~s/^\>//;
               	$id=~s/\s+.+$//;
                if ($id=~/^jgi/)
                {
                	my @temp=split(/\|/,$id);
                       	$id=$temp[0]."|".$temp[1]."|".$temp[2];
                }
	}else{$_=~s/\s*//g;$seq=$seq.$_;}
}
close(FASTA);
$seq=uc($seq);$hash_fasta{$id}=$seq;$id="";$seq="";
####################################################################################################################################





####################################################################################################################################
# read hmmsearch domtblout files
open(In,"<$filein_hmmsearch") || die "Cannot open file $filein_hmmsearch";
open(Out,">$fileout") || die "Cannot open file $fileout"; 
print Out "#Fasta_file\tProteinID\tDomain_ID\tDomain_evalue\thmm_from\thmm_to\tenv_from\tenv_to\tFull-seq\tDomain_seq\n";
while (<In>)
{
	if($_!~/^\#/)
	{	
		my @cols=split(/\s+/,$_);
		my $protid=$cols[0];
		my $domain_id=$cols[4];
		my $dom_evalue=$cols[12];
		my $hmm_from=$cols[15];
		my $hmm_to=$cols[16];
		my $env_from=$cols[19];
		my $env_to=$cols[20];
		my $short_protid=$protid;
		$short_protid=~s/^\s+.+$//;
		if ($short_protid=~/^jgi/)
		{
			my @temp=split(/\|/,$protid);
			$short_protid=$temp[0]."|".$temp[1]."|".$temp[2];
		}
		my $protein_seq=$hash_fasta{$short_protid};
		unless($protein_seq){print "\nError: could not find protein sequence for this ID: $short_protid (File $filein_fasta\n";}
		my $domain_len=$env_to - $env_from + 1;
		my $domain_seq=substr($protein_seq,$env_from-1,$domain_len);
		print Out "$filein_fasta\t$short_protid\t$domain_id\t$dom_evalue\t$hmm_from\t$hmm_to\t$env_from\t$env_to\t$protein_seq\t$domain_seq\n";
	}
}
close(In);
####################################################################################################################################








