# March 05, 2018
# This script is to remove subfamily information from best CAZy domain module file

#! /usr/perl/bin -w
use strict;
use Getopt::Long;

#my $filein="/home/mnguyen/Research/Aspergillus_exoproteomes/JGI/CAZyme_id_list/test.txt";
#my $fileout="/home/mnguyen/Research/Aspergillus_exoproteomes/JGI/CAZyme_id_list/test.out";
my $filein="";
my $fileout="";
GetOptions('filein=s'=>\$filein, 'fileout=s'=>\$fileout);

open(In,"<$filein") || die "Cannot open file $filein";
open(Out,">$fileout")|| die "Cannot open file $fileout";
while (<In>)
{
	if ($_=~/^\#/){print Out $_;}
	else
	{
		chomp($_);
		my @cols=split(/\t/,$_);
		my $module=$cols[1];
		my @domains=split(/ - /,$module);
		my $new_domain_module="";
		foreach my $each_domain (@domains)
		{
			my $new_each_domain=$each_domain;
			if ($each_domain=~/^(.+)\_\d+/){$new_each_domain=$1;}
			
			if ($new_domain_module){$new_domain_module=$new_domain_module." - ".$new_each_domain;}
			else{$new_domain_module=$new_each_domain;}
		}

		my $module_with_detail=$cols[2];
		my @domains_with_detail=split(/ - /,$module_with_detail);
		my $new_domain_module_with_detail="";
		foreach my $domain_detail (@domains_with_detail)
		{
			my $new_domain_detail=$domain_detail;
			if ($domain_detail=~/^(.+)\_\d+\s*(\(.+\))/)
			{
				my $new_domain=$1.$2;
				$new_domain_detail=$new_domain;
			}
			if ($new_domain_module_with_detail){$new_domain_module_with_detail=$new_domain_module_with_detail." - ".$new_domain_detail;}
			else{$new_domain_module_with_detail=$new_domain_detail;}
			
		}

		if ($new_domain_module){print Out "$cols[0]\t$new_domain_module\t$new_domain_module_with_detail\n";}
		else{print Out "$cols[0]\t$cols[1]\t$cols[2]\n";}
		#if ($new_domain_module){print Out "$cols[0]\t$new_domain_module\n";}
		#else{print Out "$cols[0]\t$cols[1]\n";}
	}
}
close(In);
close(Out);