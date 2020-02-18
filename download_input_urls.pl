#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $filein="";
my $folderout="";

GetOptions('in=s'=>\$filein,'out=s'=>\$folderout);

mkdir ($folderout);

open(In,"<$filein") || die "Cannot open file $filein";
while (<In>)
{
	$_=~s/\s*$//;
	chdir $folderout;
	my $cmd="wget \"$_\"";
	#print "\n$cmd\n";exit;
	system $cmd;
}
close(In);