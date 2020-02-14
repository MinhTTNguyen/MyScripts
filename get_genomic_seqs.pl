# October 12th 2017

#! /usr/perl/bin -w
use strict;
use Getopt::Long;

#my $filein="/mnt/fs1/home/mnguyen/Research/Lysozyme/Sent_Annie_batch10_batch11/batch11_GH24_GH25_proteinIDs_location.txt";
#my $fileout="/mnt/fs1/home/mnguyen/Research/Lysozyme/Sent_Annie_batch10_batch11/batch11_GH24_GH25_proteinIDs_genomic_seq.txt";
#my $foldergenome="/home/mnguyen/Research/Lysozyme/Fungi/GH25/Get_genomic_seqs/New_genomes";
#my $foldergenome="/home/mnguyen/Research/Lysozyme/Fungi/Added_JGI_fungi_26Feb2018/Genomes_new";
#my $foldergenome="/mnt/fs1/home/mnguyen/Research/JGI_Mycocosm/All_genome_files";

my $filein="";
my $fileout="";
my $foldergenome="";
GetOptions('gene_location=s'=>\$filein, 'genomic_seq=s'=>\$fileout, 'genomes=s'=>\$foldergenome);

open(In,"<$filein") || die "Cannot open file $filein";
my %hash_species_ids;
my %hash_id_genemodels;
my %hash_id_startcodon;
my %hash_species_scaffold;
my %hash_complement=("A" => "T",
					 "T" => "A",
					 "G" => "C",
					 "C" => "G",
					 "a" => "t",
					 "t" => "a",
					 "g" => "c",
					 "c" => "g",
					 "[" => "]",
					 "]" => "[");
					 
my %hash_all_species;
while (<In>)
{
	$_=~s/\s*$//;
	if ($_!~/^\#/)
	{
		my @cols=split(/\t/,$_);
		my $id=$cols[0];
		my $scaffold=$cols[1];
		my $model=$cols[1]."\t".$cols[2]."\t".$cols[3];
		my $startcodon=$cols[4];
		my $species=$id; #jgi|Thiar1|720585
		$species=~s/^jgi\|//;
		$species=~s/\|\d+//;
		if ($species)
		{
			if ($hash_species_ids{$species}){$hash_species_ids{$species}=$hash_species_ids{$species}.";".$id;}
			else{$hash_species_ids{$species}=$id;}

			$hash_id_genemodels{$id}=$model;
			$hash_id_startcodon{$id}=$startcodon;
		
			if ($hash_species_scaffold{$species}){$hash_species_scaffold{$species}=$hash_species_scaffold{$species}.";".$scaffold;}
			else{$hash_species_scaffold{$species}=$scaffold;}
			$hash_all_species{$species}++;
		}
	}
}
close(In);
my @all_species=keys(%hash_all_species);

open(Out,">$fileout") || die "Cannot open file $fileout";
opendir(DIR,"$foldergenome") || die "Cannot open folder $foldergenome";
my @files=readdir(DIR);
foreach my $file (@files)
{
	if (($file ne ".") and ($file ne ".."))
	{
		my $species="";
		foreach my $each_species (@all_species)
		{
			if ($file=~/$each_species/){$species=$each_species;last;}
			else
			{
				my $species_from_protid=$each_species;
				$species_from_protid=~s/[\d\_]*$//;
				my $species_from_filename="";
				if ($file=~/^(\w\w\w)\w*\_(\w\w).+$/)#Ilyonectria_sp.allmasked 
				{
					my $species_from_filename=$1.$2;
					if ($species_from_filename eq $species_from_protid){$species=$each_species;last;}
				}
				
				if ($file=~/^(\w\w\w)\w*\_(\w\w\w).+$/)#in case Trichophyton_verrucosum, abb: Triver
				{
					my $species_from_filename=$1.$2;
					if ($species_from_filename eq $species_from_protid){$species=$each_species;last;}
				}
			}
		}
		if ($hash_species_ids{$species})
		{
			print "\n$file\t$species\t$hash_species_scaffold{$species}\n";
			my @scaffolds=split(/\;/,$hash_species_scaffold{$species});
			my @protids=split(/\;/,$hash_species_ids{$species});
			$hash_species_ids{$species}="";#to make sure one sequence is printed out for one id
			my %hash_scaffold;
			foreach my $each_scaffold (@scaffolds){$hash_scaffold{$each_scaffold}++;}
			open(Genome,"<$foldergenome/$file") || die "Cannot open file $file";
			my $scaffold_id="";
			my $scaffold_seq="";
			my %hash_fasta;
			while (<Genome>)
			{
				$_=~s/\s*$//;
				if ($_=~/^\>/)
				{
					if ($scaffold_seq)
					{
						if ($hash_scaffold{$scaffold_id})
						{
							$scaffold_seq=~s/\s*//g;
							$scaffold_seq=uc($scaffold_seq);
							$hash_fasta{$scaffold_id}=$scaffold_seq;
						}
						$scaffold_seq="";
						$scaffold_id="";
					}
					$scaffold_id=$_;
					$scaffold_id=~s/^\>//;
					$scaffold_id=~s/\s*$//;
				}else{$scaffold_seq=$scaffold_seq.$_;}
			}
			if ($hash_scaffold{$scaffold_id})
			{
				$scaffold_seq=~s/\s*//g;
				$scaffold_seq=uc($scaffold_seq);
				$hash_fasta{$scaffold_id}=$scaffold_seq;
			}
			close(Genome);
			#while (my ($k, $v)=each (%hash_fasta)){print "\n$k\n$v";}exit;
			foreach my $protid (@protids)
			{
				my $genemodel_location=$hash_id_genemodels{$protid};
				#print "\n$genemodel_location\n";exit;
				my $temp=$genemodel_location;
				$temp=~s/\s*//g;

				if ($temp)
				{
					my @genemodel_elements=split(/\t/,$genemodel_location);
					my $sf_id=$genemodel_elements[0];
					my $strand=$genemodel_elements[1];
					my $model=$genemodel_elements[2];
					$model=~s/\s*//g;
					my @exons=split(/\-/,$model);
					my $sf_seq=$hash_fasta{$sf_id};
					my $start_codon_position=$hash_id_startcodon{$protid};
					#print "\n$start_codon_position\n";exit;
					#gene model from gff file (-)exonNumber 3(1749086..1749382)-exonNumber 2(1749455..1749585)-exonNumber 1(1749639..1749714)
					#gene model from gff3 file (-)exon_5249_1(109297..109648)-exon_5249_2(108745..109245)-exon_5249_3(108270..108683)
					if (($start_codon_position) and ($start_codon_position eq "No_info") and ($strand eq "-")) # check if this gene model is from gff3 file and on minus strand
					{
						@exons=reverse(@exons);
					}
					#################################################################################################
					# Get gene sequence
					my $first_exon=shift(@exons);
					my $intron_start=$first_exon;
					$intron_start=~s/.+\.\.//;
					$intron_start=~s/\)//;
					$intron_start++;
					my $intron_end="";
					my $gene_seq=&Get_exon_seq_plus_strand($first_exon,$sf_seq);
					my $num_remanin_exons=scalar(@exons);
					if ($num_remanin_exons>0)
					{
						foreach my $exon (@exons)
						{
							$intron_end=$exon;
							$intron_end=~s/.+\(//;
							$intron_end=~s/\.\..+//;
							$intron_end=$intron_end-1;
							my $intron_length=$intron_end - $intron_start+1;
							my $intron_seq=substr($sf_seq,$intron_start-1,$intron_length);
							$intron_seq=lc($intron_seq);
							$intron_start=$exon;
							$intron_start=~s/.+\.\.//;
							$intron_start=~s/\)//;
							$intron_start++;
							$intron_end="";
							my $exon_seq=&Get_exon_seq_plus_strand($exon,$sf_seq);
							$gene_seq=$gene_seq.$intron_seq.$exon_seq;
						}
					}
					#################################################################################################
					if ($strand eq "-"){$gene_seq=&Reverse_and_Complement($gene_seq);}
					my $start_codon=substr($gene_seq,1,3);
					my $stop_codon=substr($gene_seq,-4);
					$stop_codon=substr($stop_codon,0,3);
					print Out "$protid\t$start_codon\t$stop_codon\t$gene_seq\n";
				}else{print Out "$protid\n";} #some gene models were deleted by JGI. Ex: jgi|Copmic2|1805403, jgi|Copmic2|539542
			}
		}
	}
}
closedir(DIR);
close(Out);




#======================================================================================================================================================#
sub Get_exon_seq_plus_strand 
{
	my $exon_info=$_[0];
	my $scaffold_sequence=$_[1];
	my $begin=$exon_info;
	my $end=$exon_info;
	$begin=~s/^.+\(//;
	$begin=~s/\.\..+$//;
	$end=~s/^.+\.\.//;
	$end=~s/\)$//;
	my $length=$end - $begin +1;
	my $sequence=substr($scaffold_sequence,$begin-1,$length);
	$sequence="[".$sequence."]";
	return($sequence);
}
#======================================================================================================================================================#


#======================================================================================================================================================#
sub Reverse_and_Complement
{
	my $sequence=$_[0];
	my $seq_len=length($sequence);
	my $complement_seq="";
	for (my $i=0;$i<$seq_len;$i++)
	{
		my $nucleotide=substr($sequence,$i,1);
		my $complement_nu=$hash_complement{$nucleotide};
		$complement_seq=$complement_seq.$complement_nu;
	}
	my $reverse_seq=reverse($complement_seq);
	return($reverse_seq);
}
#======================================================================================================================================================#
