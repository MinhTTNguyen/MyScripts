#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $filein="";
my $fileout="";

GetOptions('in=s'=>\$filein,'out=s'=>\$fileout);

my %hash_seq;
open(In,"<$filein") || die "Cannot open file $filein";
open(Out,">$fileout") || die "Cannot open file $fileout";
my $id="";
my $seq="";
while (<In>)
{
	$_=~s/^\s*//;
	$_=~s/\s*$//;
	if ($_=~/^\>/)
	{
		if ($seq)
		{
			$seq=uc($seq);
			$seq=~s/\*$//;
			if ($hash_seq{$seq}){$hash_seq{$seq}=$hash_seq{$seq}.";".$id;}
			else{$hash_seq{$seq}=$id;}
			$id="";
			$seq="";
		}
		$id=$_;
		$id=~s/^\>//;
	}else{$_=~s/\s*//g;$seq=$seq.$_;}
}

$seq=uc($seq);
if ($hash_seq{$seq}){$hash_seq{$seq}=$hash_seq{$seq}.";".$id;}
else{$hash_seq{$seq}=$id;}
$id="";$seq="";

while (my ($k, $v)=each(%hash_seq))
{
	print Out ">$v\n$k\n";
}
close(In);
close(Out);
