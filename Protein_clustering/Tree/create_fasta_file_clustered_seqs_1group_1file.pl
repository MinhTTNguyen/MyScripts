=pod
February 23rd 2015
This script is to read the "cluster tables" from nwk files and fasta files to:
- extract sequences from the clusters
- modify protein IDs so that they contain cluster information
=cut

#! /usr/perl/bin -w
use strict;
#use Getopt::Long;

my $filein_cluster_table="/mnt/csfg-fs3/UserProfiles/tnguy/CAZyme_prediction/No_CAZy_domain_shortname/CBM1/2CLANS_newsub/Store_old_subs/sub40_sub1_muscle_cluster_table.txt";
my $filein_fasta="/mnt/csfg-fs3/UserProfiles/tnguy/CAZyme_prediction/No_CAZy_domain_shortname/CBM1/2CLANS_newsub/Store_old_subs/sub40_sub1.fasta";
my $folderout="/mnt/csfg-fs3/UserProfiles/tnguy/CAZyme_prediction/No_CAZy_domain_shortname/CBM1/2CLANS_newsub/Store_old_subs/sub40_sub1";
mkdir $folderout;
#GetOptions('in_clusters=s'=>\$filein_cluster_table, 'in_fasta=s'=>\$filein_fasta, 'out=s'=>\$folderout);

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
		my $protID=$columns[0];
		my $sub=$columns[1];
		#$protID=~s/\/\d+\-\d+$//;
		#$protID=~s/\|\d+\-\d+$//;
		$protID=~s/\/\d+\-\d+$//;
		$hash_protID_sub{$protID}=$sub;
	}
}
close(CLUSTER);
###################################################################################################




###################################################################################################
open(In,"<$filein_fasta") || die "Cannot open file $filein_fasta";
my $id="";
my $seq="";
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
				$hash_protID_sub{$id}="";
				unless ($sub eq "no_group")
				{
					
					my $new_id=$sub."|".$id;
					my $fileout=$sub.".fasta";
					open(Out,">>$folderout/$fileout") || die "Cannot open file $fileout";
					print Out ">$new_id\n$seq\n";
					close(Out);
				}
			}
			$seq="";
		}
		$id=$_;
		$id=~s/^\>//;
		$id=~s/\s*//g;
		$id=~s/\/\d+\-\d+$//;
	}else{$_=~s/\s*//g;$seq=$seq.$_;}
}

$seq=uc($seq);
my $sub=$hash_protID_sub{$id};
if ($sub)
{
	$hash_protID_sub{$id}="";
	unless ($sub eq "no_group")
	{
		my $new_id=$sub."|".$id;
		my $fileout=$sub.".fasta";
		open(Out,">>$folderout/$fileout") || die "Cannot open file $fileout";
		print Out ">$new_id\n$seq\n";
		close(Out);
	}
}
close(In);
###################################################################################################


###################################################################################################
# print out ids that their sequences could not be found
while (my ($k, $v)= each (%hash_protID_sub))
{
	if ($v){print "Warning: could not find sequence for this IDs $k\n";}
}