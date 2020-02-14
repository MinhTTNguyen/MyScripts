=pod
May 21, 2015
This script is to print out domain sequences of the cazy domain of interest
Input: 
1. FASTA file containing all protein sequences
2. List of CAZymes in the following format
#Seq_id	CAZy_module	CAZy_module (evalue, HMM coverage, domain_start, domain_end)
Pirrh0000387.0[+0]0-3675	CBM10 - CBM10	CBM10 (9.00E-10 , 94% , 43 , 80) - CBM10 (1.30E-10 , 94% , 88 , 125)
Pirrh0007581.0[+2]29-881	CE6	CE6 (2.60E-28 , 99% , 87 , 196)
=cut

#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $filein_fasta="";
my $filein_cazymes="";
my $selected_domain="";
my $fileout="";
GetOptions('filein_fasta=s'=>\$filein_fasta, 'filein_cazymes=s'=>\$filein_cazymes, 'selected_domain=s'=>\$selected_domain, 'fileout=s'=>\$fileout);

$selected_domain=~s/\s*//g;
#==========================================================================================================#
# read cazyme list and keep ids of proteins containing the domain of interest
open(CAZymes,"<$filein_cazymes") || die "Cannot open file $filein_cazymes";
my %hash_selected_id_cazy;
while (<CAZymes>)
{
	unless ($_=~/^\#/)
	{
		$_=~s/^\s*//;
		$_=~s/\s*$//;
		#print "\n$_\n";exit;
		my @columns=split(/\t/,$_);
		shift(@columns);
		shift(@columns);
		my $protid=$columns[0];
		my $cazy_module=$columns[2];
		$protid=~s/^\s*//;$protid=~s/\s*$//;
		$cazy_module=~s/^\s*//;$cazy_module=~s/\s*$//;
		#print "\n$protid\t$cazy_module\n";exit;
		#if ($protid=~/^jgi/)
		#{
		#	my @temps=split(/\|/,$protid);
		#	$protid=$temps[0]."|".$temps[1]."|".$temps[2];
		#}
		my @domains=split(/ - /,$cazy_module);
		foreach my $domain (@domains)
		{
			$domain=~s/\s*\(.+\)//;
			$domain=~s/\s*//g;
			if ($domain eq $selected_domain){$hash_selected_id_cazy{$protid}=$cazy_module;}
		}
	}
}
close(CAZymes);
#==========================================================================================================#



#==========================================================================================================#
open(FASTA,"<$filein_fasta") || die "Cannot open file $filein_fasta";
open(Out,">$fileout") || die "Cannot open file $filein_fasta";
my $id="";
my $seq="";
while (<FASTA>)
{
	$_=~s/^\s*//;$_=~s/\s*$//;
	if ($_=~/^\>/)
	{
		if ($seq)
		{
			$seq=uc($seq);
			my $cazy_module=$hash_selected_id_cazy{$id};
			$hash_selected_id_cazy{$id}="";
			if ($cazy_module){&print_domain_seq($id,$seq,$cazy_module);}
			$id="";$seq="";
		}
		$id=$_;
		$id=~s/^\>//;
		$id=~s/\s+.+$//;
		#if ($id=~/^(jgi\|.+\|\d+)\|.+$/){$id=$1;}
		#else
		#	{
		#		$id=~s/\s+.+$//;
				#print "Warning (".__LINE__.") Short ID for non-JGI ID format (from FASTA file): $id\n";
		#	}
	}else{$_=~s/\s*//g;$seq=$seq.$_;}
}
$seq=uc($seq);
my $cazy_module=$hash_selected_id_cazy{$id};
$hash_selected_id_cazy{$id}="";
if ($cazy_module){&print_domain_seq($id,$seq,$cazy_module);}
close(FASTA);
close(Out);
#==========================================================================================================#



#==========================================================================================================#
# print CAZymes whose sequences could not be found
while (my ($k, $v)=each (%hash_selected_id_cazy))
{
	if ($v){print "\nWarning (".__LINE__."): could not find sequence for this CAZyme: $k\n";}
}
#==========================================================================================================#


#==========================================================================================================#
sub print_domain_seq
{
	my $seq_id=$_[0];
	my $sequence=$_[1];
	my $module=$_[2];
	my @domains=split(/ - /,$module);
	foreach my $domain (@domains)
	{
		if ($domain=~/(.+)\s+\(.+\s*\,\s*\d+\%\s*\,\s*(\d+)\s*\,\s*(\d+)\)/)#CBM10 (9.00E-10 , 94% , 43 , 80)
		{
			my $domain_name=$1;
			my $start=$2;
			my $end=$3;
			if ($domain_name eq $selected_domain)
			{
				my $domain_len=($end-$start)+1;
				my $domain_seq=substr($sequence,$start-1,$domain_len);
				print Out ">$seq_id|$start-$end\n$domain_seq\n";
			}
		}else{print "\nError (line 143): domain location is not as described!\n$domain\n";exit;}
	}
}
#==========================================================================================================#
