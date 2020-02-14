#!/usr/bin/perl -w

use strict;
use CGI qw/:standard/;

my $transcriptome_path="/mnt/fpkm";
my $DESeq_table_folder="Temp";
my $downloaded_DESeq_table_file=param("DESeq_table_file");


print ("Content-Type:application/x-download\n");
print "Content-Disposition: attachment; filename=$downloaded_DESeq_table_file\n\n";
open(FILE,"<$transcriptome_path/$DESeq_table_folder/$downloaded_DESeq_table_file") or die "can't open : $!";
binmode FILE;
local $/ = \10240;
while (<FILE>){print $_;}
close FILE;
#unlink "$transcriptome_path\\$DESeq_table_folder\\$downloaded_DESeq_table_file";

