# June 18th 2018
# Change protein Ids in tree

#! /usr/bin/perl -w
use strict;

my $filein_tree="/mnt/data/bioinformatics/workingDirectories/mnguyen/CBM1/Mycocosm_18Mar2019_CBM1_proteins_CBM1domainseq_mafft.nwk";
my $filein_info_newid="/mnt/data/bioinformatics/workingDirectories/mnguyen/CBM1/DomainID_CAZyECIDunknown.txt";
#my $fileout="/home/mnguyen/Research/Lysozyme/GH25_all_15Dec2017/Fungi/12June2018/Fungi_GH25_fullseq_19June2018.nwk";
my $fileout="/mnt/data/bioinformatics/workingDirectories/mnguyen/CBM1/Mycocosm_18Mar2019_CBM1_proteins_CBM1domainseq_mafft_DomainID_CAZyECIDunknown.nwk";
#############################################################################################################
my %hash_oldid_newid;
open(Info_table,"<$filein_info_newid") || die "Cannot open file $filein_info_newid";
#open(Out,">$fileout") || die "Cannot open file $fileout";
while (<Info_table>)
{
	$_=~s/\r+\n+$//;
	if ($_!~/^#/)
	{
		my @cols=split(/\t/,$_);
		my $old_id=$cols[0];
		my $newid=$cols[1];
=pod
		my $new_cluster=$cols[1];
		my $gene_model=$cols[15];
		my $taxanomy=$cols[18];
		my $batch=$cols[20];
		$batch=~s/\s*//g;
		$taxanomy=~s/\s*//g;
		my $shorter_old_id=$old_id;
		if ($old_id=~/^.+\|(SP\_.+)/){$shorter_old_id=$1;}
		my $newid="";
		if ($batch){$newid="Cluster_".$new_cluster."|Model_".$gene_model."|Taxa_".$taxanomy."|".$batch."|".$shorter_old_id;}
		else{$newid="Cluster_".$new_cluster."|Model_".$gene_model."|Taxa_".$taxanomy."|".$shorter_old_id;}
=cut
		$hash_oldid_newid{$old_id}=$newid;
		#print Out "$_\t$newid\n";
	}#else{print Out "$_\tnewID\n";}
}
close(Info_table);
#close(Out);
#############################################################################################################



#############################################################################################################
open(Tree_In,"<$filein_tree") || die "Cannot open file $filein_tree";
open(Out,">$fileout") || die "Cannot open file $fileout";
while (<Tree_In>)
{
	$_=~s/\s*$//;
	if ($_=~/^(\s+\')(.+)(\'\[\&\!color\=.+)$/)
	{
		my $t1=$1;
		my $protid=$2;
		my $t3=$3;
		#print "\n$protid\n";exit;
		my $newid=$hash_oldid_newid{$protid};
		if ($newid){my $line=$t1.$newid.$t3;print Out "$line\n";}
		else{print "\nError: could not find new ID for this protein ID: $protid\n";exit;}
	}elsif($_=~/^\s+tree\s+tree\_1/)
	{
		my $tree=$_;
		my @arr_temp=split(/\'/,$tree);
		my $new_tree=shift(@arr_temp);
		foreach my $temp (@arr_temp)
		{
			#if (($temp=~/\|SP\_YES\|/)||($temp=~/\|SP\_NO\|/)||($temp=~/successfully\_produced/))
			if ($temp=~/\|/)
			{
				#if ($temp=~/^.+\|(SP\_.+)/){$temp=$1;}
				my $newid=$hash_oldid_newid{$temp};
				#print "\n$temp\n$newid\n";exit;
				unless ($newid){print "\nError: could not find new ID for this protein ID: $temp\n";exit;}
				$new_tree=$new_tree.$newid;
			}else{$new_tree=$new_tree.$temp;}
		}
		print Out "$new_tree";
	}else{print Out "$_\n";}
}
close(Tree_In);
close(Out);
#############################################################################################################
