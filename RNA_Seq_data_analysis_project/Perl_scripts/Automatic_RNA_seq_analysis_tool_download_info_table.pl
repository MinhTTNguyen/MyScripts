#!/usr/bin/perl -w

use strict;
use CGI qw/:standard/;

my $transcriptome_path="/mnt/fpkm";
my $Info_table_folder="Temp";
my $downloaded_info_table_file=param("download_file_name");


print ("Content-Type:application/x-download\n");
print "Content-Disposition: attachment; filename=$downloaded_info_table_file\n\n";
open(FILE,"<$transcriptome_path/$Info_table_folder/$downloaded_info_table_file") or die "can't open : $!";
binmode FILE;
local $/ = \10240;
while (<FILE>){print $_;}
close FILE;


