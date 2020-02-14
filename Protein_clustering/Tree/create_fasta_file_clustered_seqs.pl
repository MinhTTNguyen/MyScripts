=pod
February 23rd 2015
This script is to read the "cluster tables" from nwk files and fasta files to:
- extract sequences from the clusters
- modify protein IDs so that they contain cluster information
=cut

#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $filein_cluster_table="";
my $filein_fasta="";
my $fileout="";

GetOptions('cluster=s'=>\$filein_cluster_table, 'fasta=s'=>\$filein_fasta, 'out=s'=>\$fileout);


###################################################################################################
# read information from cluster table
open(CLUSTER,"<$filein_cluster_table") || die "Cannot open file $filein_cluster_table";
my %hash_protID_sub;
while (<CLUSTER>)
{
	unless ($_=~/^\#/)
	{
		$_=~s/^\s*//;$_=~s/\s*$//;
		my @columns=split(/\t/,$_);
		my $protID=$columns[0];#CBM10-CBM10-CBM10-CBM63|Orpjo0002663_+0_0-1638|intervening/53-305
		my $sub=$columns[1];
		
		$protID=~s/\/\d+\-\d+$//;
		$hash_protID_sub{$protID}=$sub;
		
	}
}
close(CLUSTER);
###################################################################################################




###################################################################################################
open(In,"<$filein_fasta") || die "Cannot open file $filein_fasta";
open(Out,">$fileout") || die "Cannot open file $fileout";
my $id="";
my $seq="";
my %hash_id_seq;
while (<In>)
{
	$_=~s/^\s*//;$_=~s/\s*$//;
	if ($_=~/^\>/)
	{
		if ($seq)
		{
			$seq=uc($seq);
			my $sub=$hash_protID_sub{$id};
			if ($sub)
			{
				if ($sub!~/no\_sub/)
				{
					my $new_id=$sub."|".$id;
					print Out ">$new_id\n$seq\n";
				}
				delete($hash_protID_sub{$id});
			}else{$hash_id_seq{$id}=$seq;}
			$seq="";$id="";
		}
		
		$id=$_;
		$id=~s/^\>//;
		$id=~s/\s+.+$//;
		$id=~s/\/\d+\-\d+$//;
	}else{$_=~s/\s*//g;$seq=$seq.$_;}
}

$seq=uc($seq);
#print "\n$id\n";exit;
my $sub=$hash_protID_sub{$id};
if ($sub)
{
	if ($sub!~/no\_sub/)
	{
		my $new_id=$sub."|".$id;
		print Out ">$new_id\n$seq\n";
		delete($hash_protID_sub{$id});
	}
}else{$hash_id_seq{$id}=$seq;}
close(In);
###################################################################################################



###################################################################################################
# print out IDs that could not extract corresponding sequences
my @ids_noseq=keys(%hash_protID_sub);
my @seqs_not_printed=keys(%hash_id_seq);
my $num_ids_noseq=scalar(@ids_noseq);
if ($num_ids_noseq>0)
{
	foreach my $id_noseq (@ids_noseq)
	{
		foreach my $seq_not_printed (@seqs_not_printed)
		{
			if ($seq_not_printed=~/\Q$id_noseq\E/)
			{
				my $sub=$hash_protID_sub{$id_noseq};
				#print "\n$seq_not_printed\n$id_noseq\n$sub\n";exit;
				my $sequence=$hash_id_seq{$seq_not_printed};
				if ($sub!~/no\_sub/)
				{
					my $new_id=$sub."|".$seq_not_printed;
					print Out ">$new_id\n$sequence\n";
					delete($hash_protID_sub{$id_noseq});
				}
			}
		}
	}
}
my @ids_noseq_new=keys(%hash_protID_sub);
my $num_ids_noseq_new=scalar(@ids_noseq_new);
if ($num_ids_noseq_new>0)
{
	print "\nFollowings are IDs whose sequences were not found:\n";
	foreach my $id_noseq (@ids_noseq_new){print "$id_noseq\t$hash_protID_sub{$id_noseq}\n";}
}
###################################################################################################
close(Out);
