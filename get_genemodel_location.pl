# October 11th 2017

#! /usr/perl/bin -w
use strict;
use Getopt::Long;


#my $filein_protids="/mnt/fs1/home/mnguyen/Research/Lysozyme/Sent_Annie_batch10_batch11/batch11_GH24_GH25_proteinIDs.txt";
#my $folderin_gff="/home/mnguyen/Research/Lysozyme/Fungi/Added_JGI_fungi_26Feb2018/GFF3_files";
#my $folderin_gff="/mnt/fs1/home/mnguyen/Research/JGI_Mycocosm/All_GFF_files/GeneCatalog";
#my $fileout="/mnt/fs1/home/mnguyen/Research/Lysozyme/Sent_Annie_batch10_batch11/batch11_GH24_GH25_proteinIDs_location.txt";


my $filein_protids="";
my $folderin_gff="";
my $fileout="";

GetOptions('in=s'=>\$filein_protids, 'gff=s'=>\$folderin_gff, 'out=s'=>\$fileout);


open(Out,">$fileout") || die "Cannot open file $fileout";
print Out "#Protid\tScaffold\tStrand\tGenemodel\tStartcodon\tStopcodon\tgff\n";
my %hash_species_protids;
my %hash_all_species;
open(ProtID,"<$filein_protids") || die "Cannot open file $filein_protids";
while (<ProtID>)
{
	$_=~s/\s*$//;$_=~s/^\s*//;
	my @id_elements=split(/\|/,$_);#jgi|Crycu1|367401
	my $species=$id_elements[1];
	my $protid=$id_elements[2];
	$species=~s/\s*//g;
	if ($species)
	{
		if ($hash_species_protids{$species}){$hash_species_protids{$species}=$hash_species_protids{$species}.";".$protid;}
		else{$hash_species_protids{$species}=$protid;}
		$hash_all_species{$species}++;
	}
}
close(ProtID);
my @all_species=keys(%hash_all_species);

opendir(GFF,$folderin_gff) || die "Cannot open folder $folderin_gff";
my @files_gff=readdir(GFF);
foreach my $file_gff (@files_gff)
{
	if (($file_gff ne ".") and ($file_gff ne ".."))
	{
		my $species="";
		foreach my $each_species (@all_species)
		{
			if ($file_gff=~/$each_species/){$species=$each_species;last;} # caution: in case there are 2 files: Pycco1662_1_GeneCatalog_genes_20140607.gff and Pycco1_GeneCatalog_genes_20140114.gff, either of them can be selected and could cause wrong result
		}
		if ($hash_species_protids{$species})
		{
			if ($file_gff=~/\.gff3$/){print "read gff3\t$file_gff\n";&Process_GFF3($file_gff,$species);}
			else{print "read gff\t$file_gff\n";&Process_GFF($file_gff,$species);}
			$hash_species_protids{$species}="";
		}
	}
}

close(Out);
closedir(GFF);

#========================================================================================================================#
sub Process_GFF
{
	my $file=$_[0];
	my $species=$_[1];
	my @all_protids=split(/\;/,$hash_species_protids{$species});
	my %hash_protids;
	foreach my $protid (@all_protids){$hash_protids{$protid}++;}
	#while (my ($k, $v)=each (%hash_protids)){print "$k\t$v\n";}exit;
	
	open(GFF_file,"$folderin_gff/$file") || die "Cannot open file $file";
	my %hash_modelname_protid;
	my %hash_protid_genemodel;
	my %hash_protid_scaffold;
	my %hash_protid_strand;
	my %hash_protid_startcodon;
	my %hash_protid_stopcodon;
	while (<GFF_file>)
	{
		$_=~s/\s*$//;
		my @cols=split(/\t/,$_);
		my $scaffold=$cols[0];
		my $feature=$cols[2];
		my $start=$cols[3];
		my $end=$cols[4];
		my $strand=$cols[6];
		my $info=$cols[8];
		if ($feature eq "CDS")
		{
			if ($info=~/name\s*\"(.+)\"\;\s*protein[Ii]d\s*\=*(\d+)\;\s*(exonNumber\s*\d+)/)#name "estExt_fgenesh1_pg.C_1_t10003"; proteinId 445593; exonNumber 1
			{
				my $genemodel_name=$1;
				my $protein_id=$2;
				my $exon_number=$3;
				#print "\n$genemodel_name\t$protein_id\t$exon_number\n";exit;
				if ($hash_protids{$protein_id})
				{
					unless($hash_modelname_protid{$genemodel_name}){$hash_modelname_protid{$genemodel_name}=$protein_id;}
					unless($hash_protid_scaffold{$protein_id}){$hash_protid_scaffold{$protein_id}=$scaffold;}
					unless($hash_protid_strand{$protein_id}){$hash_protid_strand{$protein_id}=$strand;}
					my $exon=$exon_number."(".$start."..".$end.")";
					if ($hash_protid_genemodel{$protein_id}){$hash_protid_genemodel{$protein_id}=$hash_protid_genemodel{$protein_id}."-".$exon;}
					else{$hash_protid_genemodel{$protein_id}=$exon;}
				}
			}else{print "Error (line".__LINE__."): protein id information in gff file is not as described\n$info\n";exit;}
		}
		
		if ($feature eq "start_codon")
		{
			my $genemode_id=$info;
			$genemode_id=~s/^name\s*\"//;
			$genemode_id=~s/\".*$//;
			my $protein_id=$hash_modelname_protid{$genemode_id};
			$hash_protid_startcodon{$protein_id}=$start."..".$end;
		}
		
		if ($feature eq "stop_codon")
		{
			my $genemode_id=$info;
			$genemode_id=~s/^name\s*\"//;
			$genemode_id=~s/\".*$//;
			my $protein_id=$hash_modelname_protid{$genemode_id};
			$hash_protid_stopcodon{$protein_id}=$start."..".$end;
		}
		
	}
	foreach my $protid (@all_protids)
	{
		print Out "jgi\|$species\|$protid\t$hash_protid_scaffold{$protid}\t$hash_protid_strand{$protid}\t$hash_protid_genemodel{$protid}\t$hash_protid_startcodon{$protid}\t$hash_protid_stopcodon{$protid}\tgff\n";
	}
	close(GFF_file);
}
#========================================================================================================================#


#========================================================================================================================#
sub Process_GFF3
{
	my $file=$_[0];
	my $species=$_[1];
	#print "\n$file\n$species\n-$hash_species_protids{$species}-\n";
	my @all_protids=split(/\;/,$hash_species_protids{$species});
	my %hash_protids;
	foreach my $protid (@all_protids){$hash_protids{$protid}++;}
	open(GFF3_file,"$folderin_gff/$file") || die "Cannot open file $file";
	my %hash_protid_genemodel;
	my %hash_protid_scaffold;
	my %hash_protid_strand;
	my %hash_protid_startcodon;
	my %hash_protid_stopcodon;
	my $protein_id="";
	while (<GFF3_file>)
	{
		$_=~s/\s*$//;
		if ($_!~/^#/)
		{
			my @cols=split(/\t/,$_);
			my $scaffold=$cols[0];
			my $feature=$cols[2];
			my $start=$cols[3];
			my $end=$cols[4];
			my $strand=$cols[6];
			my $info=$cols[8];
			
			if ($feature eq "mRNA")
			{
				if ($info=~/protein[iI]d\s*\=*(\d+)/)#name "estExt_fgenesh1_pg.C_1_t10003"; proteinId 445593; exonNumber 1
				{
					$protein_id=$1;
					if ($hash_protids{$protein_id})
					{
						unless($hash_protid_scaffold{$protein_id}){$hash_protid_scaffold{$protein_id}=$scaffold;}
						unless($hash_protid_strand{$protein_id}){$hash_protid_strand{$protein_id}=$strand;}
						$hash_protid_startcodon{$protein_id}="No_info";
						$hash_protid_stopcodon{$protein_id}="No_info";
					}else{$protein_id="";}
				}else{print "Error (line".__LINE__."): protein id information in gff file is not as described\n$info\n";exit;}
			}
			
			if (($protein_id) and ($feature eq "CDS"))
			{
				my $exon_number=$info;#ID=CDS_1;Parent=mRNA_1
				$exon_number=~s/^\ID\=//;
				$exon_number=~s/\;.+$//;
				my $exon=$exon_number."(".$start."..".$end.")";
				if ($hash_protid_genemodel{$protein_id}){$hash_protid_genemodel{$protein_id}=$hash_protid_genemodel{$protein_id}."-".$exon;}
				else{$hash_protid_genemodel{$protein_id}=$exon;}
			}
		
		}
	}
	foreach my $protid (@all_protids)
	{
		print Out "jgi\|$species\|$protid\t$hash_protid_scaffold{$protid}\t$hash_protid_strand{$protid}\t$hash_protid_genemodel{$protid}\t$hash_protid_startcodon{$protid}\t$hash_protid_stopcodon{$protid}\tgff3\n";
	}
	close(GFF3_file);
}
#========================================================================================================================#
