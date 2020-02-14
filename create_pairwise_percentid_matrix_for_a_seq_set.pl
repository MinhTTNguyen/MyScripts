# October 6th 2017
# Create pairwise percent identity matrix for a set of sequences

#! /use/perl/bin -w
use strict;
use Getopt::Long;

my $filein="";
my $fileout="";
GetOptions('in=s'=>\$filein, 'out=s'=>\$fileout);


print "\n";
print "Usage: create pairwise percent of identity matrix for a set of protein sequences\n";
print "--in :input output file from script run_pairwise_aln.pl\n";
print "--out:pairwise percent of identity matrix\n";
print "\n";

my %hash_ids;
my %hash_pairwiseids;
open(In,"<$filein") || die "Cannot open file $filein";
while (<In>)
{
	$_=~s/\s*$//;
	my @cols=split(/\t/,$_);
	my $id1=$cols[0];
	my $id2=$cols[1];
	my $identity=$cols[2];
	my $key=$id1.";".$id2;
	my $reverse_key=$id2.";".$id1;
	$hash_pairwiseids{$key}=$identity;
	$hash_pairwiseids{$reverse_key}=$identity;
	$hash_ids{$id1}++;
	$hash_ids{$id2}++;
}
close(In);

open(Out,">$fileout") || die "Cannot open file $fileout";
my @all_ids=keys(%hash_ids);
foreach my $id (@all_ids)
{
	print Out "\t$id";
}
print Out "\n";

foreach my $id1 (@all_ids)
{
	print Out "$id1";
	foreach my $id2 (@all_ids)
	{
		my $percent_id="";
		if ($id1 eq $id2){$percent_id=100;}
		else
		{
			my $key=$id1.";".$id2;
			$percent_id=$hash_pairwiseids{$key};
		}
		print Out "\t$percent_id";
	}
	print Out "\n";
}
close(Out);
