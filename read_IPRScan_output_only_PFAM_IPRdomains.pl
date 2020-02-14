# June 11th 2018
# Read TSV output file from InterProScan and print out information for each protein in 1 row
# ProteinId	Pfam	Interpro	TMHMM	Pathway	GO

#! /usr/bin/perl -w
use strict;
use Getopt::Long;

my $filein_iprscantsv="";
my $fileout="";

GetOptions("in=s"=>\$filein_iprscantsv,"out=s"=>\$fileout);




################################################################################################################
if (($filein_iprscantsv) and ($fileout)){print "\nProcessing\n";}
else
{
	print "\n";
	print "Usage: read tsv file from InterProscan output and print out pfam domains and InterPro domains, 1 protein per line\n";
	print "--in : tsv file from InterProscan output\n";
	print "--out: output file\n";
	print "\n";
}
################################################################################################################


################################################################################################################
open(In,"<$filein_iprscantsv") || die "Cannot open file $filein_iprscantsv";
open(Out,">$fileout") || die "Cannot open file $fileout";
my %hash_pfam;
my %hash_ipr;
my %hash_all_protids;
while (<In>)
{
	$_=~s/\s*$//;
	my @cols=split(/\t/,$_);
	my $protid=$cols[0];
	my $analysis=$cols[3];
	my $accession=$cols[4];
	my $desc=$cols[5];
	my $start=$cols[6];
	my $end=$cols[7];
	my $evalue=$cols[8];
	my $ipr_id=$cols[11];
	my $ipr_desc=$cols[12];
	
	$hash_all_protids{$protid}++;
	
	$protid=~s/\s*//g;
	$analysis=~s/\s*//g;
	if($analysis eq "Pfam")
	{
		my $new_pfam=$accession."(".$start."-".$end.",".$evalue."):".$desc;
		if ($hash_pfam{$protid}){$hash_pfam{$protid}=$hash_pfam{$protid}." | ".$new_pfam;}
		else{$hash_pfam{$protid}=$new_pfam;}
	}
	
	$ipr_id=~s/\s*//g;
	if ($ipr_id)
	{
		my $new_ipr=$ipr_id.":".$ipr_desc;
		if ($hash_ipr{$protid}){$hash_ipr{$protid}=$hash_ipr{$protid}."|".$new_ipr;}
		else{$hash_ipr{$protid}=$new_ipr;}
	}
}

########################################################################################################################################################

print Out "#ProteinID	Pfam(start-end,evalue)\tInterpro\n";
my @all_proids=keys(%hash_all_protids);
foreach my $each_protid (@all_proids)
{
	my $pfam_domains=$hash_pfam{$each_protid};
	my $interpro=$hash_ipr{$each_protid};
	my $interpro_nr=&Remove_duplicates($interpro);
	print Out "$each_protid\t$pfam_domains\t$interpro_nr\n";
}
close(In);
close(Out);
print "\ndone!\n";
################################################################################################################


################################################################################################################
sub Remove_duplicates
{
	my $x=$_[0];
	my @array_temp=split(/\|/,$x);
	my %hash_temp;
	foreach my $temp (@array_temp){$hash_temp{$temp}++;}
	my @array_temp_nr=keys(%hash_temp);
	my $y=join(" | ",@array_temp_nr);
}
################################################################################################################
