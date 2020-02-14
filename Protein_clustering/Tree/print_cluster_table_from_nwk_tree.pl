=pod
February 23rd 2015
This script is to read a phylogenetic tree (.nwk) and print out a table showing different subfamilies found from the tree
Input: .nwk file
Output:	ProID	Subfamily	Total_seq_in_subfamily	Color
Note: taxa that are not in any clusters should be in black color (#000000)
=cut

#! /usr/perl/bin -w
use strict;
use Getopt::Long;


my $filein_nwk="";
my $fileout="";


GetOptions('in=s'=>\$filein_nwk, 'out=s'=>\$fileout);


##############################################################################################
open(In,"<$filein_nwk") || die "Cannot open file $filein_nwk";
open(Out,">$fileout") || die "Cannot open file $fileout";
print Out "#ProtID\tSub\tTotalseq_in_sub\tColor\n";
my $flag_start=0;

my %hash_proID_sub;
my %hash_sub_color;
my %hash_color_count;
my %hash_color_sub;
my $line=0;
my $sub_count=0;
while (<In>)
{
	$line++;
	$_=~s/\s*$//;
	if ($flag_start)
	{
		if ($_=~/^\s+(.+)\[\&\!color\=(.+)\]/)#	'NP_464601.1/1-143'[&!color=#cc33ff]
		{
			
			my $protID=$1;
			my $color=$2;
			$protID=~s/^\s*//;$protID=~s/\s*$//;
			$color=~s/\s*//g;
			
			my $sub="";
			if ($color eq '#000000'){$sub="no_sub";}
			else
			{
				unless ($hash_color_sub{$color}){$sub_count++;$hash_color_sub{$color}=$sub_count;}
				$sub="sub".$hash_color_sub{$color};
			}
			
			$hash_color_count{$color}++;
			$hash_proID_sub{$protID}=$sub;
			$hash_sub_color{$sub}=$color;
		}elsif($_=~/^\s+\'(.+)\'/)
		{
			my $protID=$1;
			my $color='#000000';
			my $sub="no_sub";
			$hash_color_count{$color}++;
			$hash_proID_sub{$protID}=$sub;
			$hash_sub_color{$sub}=$color;
		}elsif($_=/^\;/){last;}
		else {print "Error (line ". __LINE__." ): taxa is not as described!!!\nLine $line: $_\n";exit;}
	}else{if ($_=~/taxlabels/){$flag_start=1;}}
}

while (my ($k_protID,$v_sub)=each (%hash_proID_sub))
{
	my $color=$hash_sub_color{$v_sub};
	my $total_seq_in_sub=$hash_color_count{$color};
	
	$k_protID=~s/\'//g;
	print Out "$k_protID\t$v_sub\t$total_seq_in_sub\t$color\n";
}
close(In);
close(Out);
##############################################################################################
