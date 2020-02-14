# July 30th 2018
# assemble all protein ids having the domain of interest from hmmsearch domtblout files

#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $folder_hmmsearch_domtbl="";
my $fileout="";
my $folder_fasta="";
GetOptions('in=s'=>\$folder_hmmsearch_domtbl,'out=s'=>\$fileout,'fasta=s'=>\$folder_fasta);


##########################################################################################################################################
if ($folder_hmmsearch_domtbl and $fileout and $folder_fasta){print "\nStart processing\n";}
else
{
	print "\n";
	print "Usage: read domtblout files from hmmsearch and extract IDs of all proteins containing domain of interest\n";
	print "--in   : folder containing output files from hmmsearch (domtblout) format\n";
	print "--out  : output file showing IDs of proteins containing domain of interest from hmmsearch\n";
	print "--fasta: folder containing protein sequence files which will be used to extract sequences of proteins containing domain of interest\n";
	print "\n";
}
##########################################################################################################################################



open(Out,">$fileout") || die "Cannot open file $fileout";
print Out "#Fasta_file\tProtID\tDomain_ID\tDomain_i_Evalue\thmm_from\thmm_to\tenv_from\tenv_to\tFullseq\tDomain_seq\n";
opendir(DIR,"$folder_hmmsearch_domtbl") || die "Cannot open folder $folder_hmmsearch_domtbl";
my @files=readdir(DIR);
foreach my $file (@files)
{
	if (($file ne ".") and ($file ne ".."))
	{
		my $fasta_file=substr($file,0,-9);
		$fasta_file=$fasta_file."fasta";
		
		
		################################################################################
		# Read fasta file and get protein sequences
		my %hash_fasta;
		open(FASTA,"<$folder_fasta/$fasta_file") || die "Cannot open file $folder_fasta/$fasta_file";
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
		################################################################################
		
		
		################################################################################
		# read hmmsearch domtblout files
		open(In,"<$folder_hmmsearch_domtbl/$file") || die "Cannot open file $folder_hmmsearch_domtbl/$file";
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
				unless($protein_seq){print "\nError: could not find protein sequence for this ID: $short_protid (File $fasta_file)\n";}
				my $domain_len=$env_to - $env_from + 1;
				my $domain_seq=substr($protein_seq,$env_from-1,$domain_len);
				print Out "$fasta_file\t$short_protid\t$domain_id\t$dom_evalue\t$hmm_from\t$hmm_to\t$env_from\t$env_to\t$protein_seq\t$domain_seq\n";
			}
		}
		close(In);
		################################################################################
	}
}
closedir(DIR);
close(Out);
print "done\n";
