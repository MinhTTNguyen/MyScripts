# Feb. 14, 2020
# Translate from CDs

#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $filein="";
my $fileout="";
my $fileout_report="";

GetOptions('in=s'=>\$filein, 'out=s'=>\$fileout, 'report=s'=>\$fileout_report);

my %hash_codon_table=("TTT"=>"Phe","TTC"=>"Phe","TTA"=>"Leu","TTG"=>"Leu","CTT"=>"Leu","CTC"=>"Leu","CTA"=>"Leu","CTG"=>"Leu",
					  "ATT"=>"Ile","ATC"=>"Ile","ATA"=>"Ile","ATG"=>"Met","GTT"=>"Val","GTC"=>"Val","GTA"=>"Val","GTG"=>"Val",
					  "TCT"=>"Ser","TCC"=>"Ser","TCA"=>"Ser","TCG"=>"Ser","CCT"=>"Pro","CCC"=>"Pro","CCA"=>"Pro","CCG"=>"Pro",
					  "ACT"=>"Thr","ACC"=>"Thr","ACA"=>"Thr","ACG"=>"Thr","GCT"=>"Ala","GCC"=>"Ala","GCA"=>"Ala","GCG"=>"Ala",
					  "TAT"=>"Tyr","TAC"=>"Tyr","CAT"=>"His","CAC"=>"His","CAA"=>"Gln","CAG"=>"Gln","AAT"=>"Asn","AAC"=>"Asn",
					  "AAA"=>"Lys","AAG"=>"Lys","GAT"=>"Asp","GAC"=>"Asp","GAA"=>"Glu","GAG"=>"Glu","TGT"=>"Cys","TGC"=>"Cys",
					  "TGG"=>"Trp","CGT"=>"Arg","CGC"=>"Arg","CGA"=>"Arg","CGG"=>"Arg","AGT"=>"Ser","AGC"=>"Ser","AGA"=>"Arg",
					  "AGG"=>"Arg","GGT"=>"Gly","GGC"=>"Gly","GGA"=>"Gly","GGG"=>"Gly","TAA"=>"*","TGA"=>"*","TAG"=>"*");
					  
my %hash_aa_1lettercode=("Phe"=>"F", "Leu"=>"L", "Ser"=>"S", "Tyr"=>"Y", "Cys"=>"C",
						 "Trp"=>"W", "Pro"=>"P", "His"=>"H", "Gln"=>"Q", "Arg"=>"R",
						 "Ile"=>"I", "Met"=>"M", "Thr"=>"T", "Asn"=>"N", "Lys"=>"K",
						 "Val"=>"V", "Ala"=>"A", "Asp"=>"D", "Glu"=>"E", "Gly"=>"G", "*"=>"*", "X"=>"X");

open(In,"<$filein") || die "\nCould not open input file $filein\n";
open(Out,">$fileout") || die "\nCould not open output file $fileout\n";
open(Report,">$fileout_report") || die "\nCould not open file report file: $fileout_report\n";
my $id="";
my $CDs="";
while (<In>)
{
	$_=~s/\s*$//;
	if ($_=~/^\>/)
	{
		if ($CDs)
		{
			$CDs=uc($CDs);
			my $CDs_len=length($CDs);
			my $CDs_len_mod_3=$CDs_len%3;
			my $new_CDs_len=$CDs_len-$CDs_len_mod_3;
			my $new_CDs=substr($CDs,0,$new_CDs_len);
			my $protein_seq=&Translate($id,$new_CDs);
			print Out ">$id\t$protein_seq\n";
			$id="";
			$CDs="";
		}
		$id=$_;
		$id=~s/^\>//;
	}else{$_=~s/\s*//g;$CDs=$CDs.$_;}
}
$CDs=uc($CDs);
my $CDs_len=length($CDs);
my $CDs_len_mod_3=$CDs_len%3;
my $new_CDs_len=$CDs_len-$CDs_len_mod_3;
my $new_CDs=substr($CDs,0,$new_CDs_len);
#print "\n$new_CDs\n"; exit;
my $protein_seq=&Translate($id,$new_CDs);
print Out ">$id\t$protein_seq\n";

close(In);
close(Out);
close(Report);
##############################################################################################
sub Translate
{
	my $id=$_[0];
	my $CDs_sequence=$_[1];
	#print "\n$CDs_sequence\n"; exit;
	my $len=length($CDs_sequence);
	my $translated_seq="";
	for (my $i=0;$i<$len;$i=$i+3)
	{
		my $codon=substr($CDs_sequence,$i,3);
		my $aa_3letter=$hash_codon_table{$codon};
		
		if ($aa_3letter)
		{
			my $aa_1letter=$hash_aa_1lettercode{$aa_3letter};
			if ($aa_1letter){$translated_seq=$translated_seq.$aa_1letter;}
			else{print "\nCould not find 1 letter code amino acid for this: $aa_3letter\n";exit;}
		}else
		{
			print Report "\nCould not find amino acid for this codon: $id\t$codon\n";
			$aa_3letter="X";
			my $aa_1letter=$hash_aa_1lettercode{$aa_3letter};
			if ($aa_1letter){$translated_seq=$translated_seq.$aa_1letter;}
			else{print "\nCould not find 1 letter code amino acid for this: $aa_3letter\n";exit;}
		}
	}
	$translated_seq=~s/\*$//;
	return($translated_seq);
}