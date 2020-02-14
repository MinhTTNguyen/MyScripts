# 27July 2017
# This file is to do pairwise alignment for a set of input protein sequences

#! /usr/perl/bin -w
use strict;
use Getopt::Long;
use Bio::Tools::Run::Alignment::Clustalw;
use Bio::Seq;
use Bio::SeqIO;
use Bio::SimpleAlign;


my $filein="";
my $fileout="";
my $temp_folder="";
GetOptions('in=s'=>\$filein, 'out=s'=>\$fileout, 'temp=s'=>\$temp_folder);

#####################################################################################################################
if (($filein) and ($fileout) and ($temp_folder)){print "\nRunning...\n";}
else
{
	print "\n";
	print "Usage : run pairwise alignment for the input protein sequences\n";
	print "--in  : input protein sequence file\n";
	print "--out : output file\n";
	print "--temp: temporary folder containing files generated during the processing time\n";
	print "\n";
}
####################################################################################################################





my %hash_fasta1=&Read_fasta($filein);
my %hash_fasta2=%hash_fasta1;

################################################################################
open(Out,">$fileout") || die "Cannot open file $fileout";
my %hash_pairwise;
my @seq_ids1=keys(%hash_fasta1);
my @seq_ids2=keys(%hash_fasta2);
foreach my $seq1 (@seq_ids1)
{
	foreach my $seq2 (@seq_ids2)
	{
		if ($seq1 ne $seq2)
		{
			my $pair=$seq1."|".$seq2;
			my $reverse_pair=$seq2."|".$seq1;
			unless ($hash_pairwise{$reverse_pair})
			{
				my $pairwise_id=&Pairwise_id($seq1, $seq2);
				$hash_pairwise{$pair}=$pairwise_id;
				$hash_pairwise{$reverse_pair}=$pairwise_id;
				print Out "$seq1\t$seq2\t$pairwise_id\n";
			}
		}
	}
}
print "done!\n";
################################################################################






################################################################################
sub Read_fasta
{
	my $filein=$_[0];
	my %hash_fasta;
	my $seq="";
	my $id="";
	open(In,"<$filein") || die "Cannot open file $filein";
	while (<In>)
	{
		$_=~s/\s*$//;
		if ($_=~/^\>/)
		{
			if ($seq)
			{
				$seq=uc($seq);
				$hash_fasta{$id}=$seq;
				$seq="";$id="";
			}
			$id=$_;
			$id=~s/^\>//;
		}else{$_=~s/\s*//g;$seq=$seq.$_;}
	}
	$seq=uc($seq);
	$hash_fasta{$id}=$seq;
	close(In);
	return(%hash_fasta);
}
################################################################################




######################################################################################
sub Pairwise_id
{
	my $sequence_1=$hash_fasta1{$_[0]};
	my $sequence_2=$hash_fasta2{$_[1]};
	mkdir "$temp_folder";
	############################################################
	# Performing pairwise alignment using BioPerl
	
	my $seq_obj1 = Bio::Seq -> new(-seq=>$sequence_1, -display_id => "first_seq");
	my $seq_obj2 = Bio::Seq -> new(-seq=>$sequence_2, -display_id => "second_seq");
	my $seqIO_obj = Bio::SeqIO -> new(-file => ">$temp_folder/temp.fasta", -format => 'fasta');
	$seqIO_obj->write_seq($seq_obj1);
	$seqIO_obj->write_seq($seq_obj2);

	my @params = ('matrix' => 'BLOSUM', 'type' => 'protein', 'outfile' => "$temp_folder/MSA_temp.fasta", 'output' => 'fasta');
	my $factory = Bio::Tools::Run::Alignment::Clustalw->new(@params);
	my $simple_aln_obj = $factory-> align("$temp_folder/temp.fasta", -format => 'fasta');
	my $pairwise_percent_identity=$simple_aln_obj->overall_percentage_identity;

	unlink("$temp_folder/MSA_temp.fasta");
	unlink("$temp_folder/temp.fasta");
	rmdir ($temp_folder);
	return($pairwise_percent_identity);
}
######################################################################################
