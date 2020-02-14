# November 30th 2018
# reading and extracting information of genome sequence data of bacillus genus from file NCBI_Genome_Bacillus_genus.txt

#! /usr/perl/bin -w
use strict;

my $filein="NCBI_Genome_Bacillus_genus.txt";
my $fileout="NCBI_Genome_Bacillus_genus_table.txt";


open(In,"<$filein") || die "Cannot open file $filein";
open(Out,">$fileout") || die "Cannot open file $fileout";
print Out "#Number\tSpecies name\tSpecies Description\tKingdom\tSubgroup\tAssembly count\tChromosome\tPlasmid\tDate\tID\tGenome url\n";
my $number="";
my $species="";
my $species_desc="";
my $kingdom="";
my $subgroup="";
my $num_assemblies="";
my $chr="";
my $plasmid="";
my $date="";
my $id="";
my $flag="";
#my $count=0;
my $previous_line="";
while (<In>)
{
	#$count++;
	$_=~s/\s*$//;
	#print "$count: $_\n";
	if ($_)
	{
		if ($_=~/^(\d+)\.$/){$number=$1;$flag=1;next;}
		if ($flag==1){$species=$_;$flag=2;next;}
		if ($flag==2)
		{
			if ($_=~/^Kingdom\:/){$flag=3;next;}
			else{$species_desc=$_;next;}
		}
		
		if ($flag==3){$kingdom=$_;$kingdom=~s/\;$//;$kingdom=~s/^\s*//;$flag=4;next;}
		if ($_=~/^Subgroup\:/){$flag=4;next;}
		if ($flag==4){$subgroup=$_;$subgroup=~s/^\s*//;$flag=5;next;}
		if ($_=~/^Sequence data\: genome assemblies\:/){$flag=5;next;}
		if ($flag==5){$num_assemblies=$_;$num_assemblies=~s/^\s*//;$flag=6;next;}
		if ($_=~/^Chromosome\:/){$flag=6;$previous_line=$_;next;}
		if (($flag==6) and ($previous_line=~/^Chromosome\:/)){$chr=$_;$chr=~s/^\s*//;$chr=~s/\;$//;$flag=7;next;}
		if ($_=~/^Plasmids\:/){$flag=7;$previous_line=$_;next;}
		if (($flag==7) and ($previous_line=~/^Plasmids\:/)){$plasmid=$_;$plasmid=~s/^\s*//;$plasmid=~s/\;$//;$flag=8;next;}
		if ($_=~/^Date\:/){$flag=8;next;}
		if ($flag==8){$date=$_;$date=~s/^\s*//;$date=~s/\;$//;$flag=9;next;}
		if ($_=~/^ID\:/){$flag=9;next;}
		if ($flag==9)
		{
			$id=$_;
			$id=~s/^\s*//;
			$id=~s/\;$//;
			$flag=0;
			my $url='https://www.ncbi.nlm.nih.gov/genome/genomes/'.$id;
			print Out "$number\t$species\t$species_desc\t$kingdom\t$subgroup\t$num_assemblies\t$chr\t$plasmid\t$date\t$id\t$url\n";
			$number="";
			$species="";
			$species_desc="";
			$kingdom="";
			$subgroup="";
			$num_assemblies="";
			$chr="";
			$plasmid="";
			$date="";
			$id="";
			$url="";
			$previous_line="";
		}
	}
}
close(In);
close(Out);

