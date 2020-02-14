#!/usr/bin/perl -w

use strict;
use CGI qw/:standard/; 
use Statistics::R;
use DateTime;

my $dt = DateTime->now; #2014-02-28T23:19:22
$dt=~s/\-//g;
$dt=~s/\://g;

my $transcriptome_path="/mnt/fpkm";
my $transcriptome_path_R="/mnt/fpkm";
my $DESeq_table_folder="Temp";

my $DESeq_table_file=$ARGV[0];
$DESeq_table_file=~s/\?/ /g;

my $pval_threshold=$ARGV[1];
my $organism=$ARGV[2];
$organism=~s/open\_pr/\(/g;
$organism=~s/close\_pr/\)/g;
$organism=~s/\_/ /g;


#my $condition_1=$ARGV[3];
#my $condition_2=$ARGV[4];
#$condition_1=~s/\?/ /g;
#$condition_2=~s/\?/ /g;

#============================================================================================================================================
# R script for creating Volcano plot
my $R = Statistics::R -> new();
$R ->start();
$R ->run('library("DESeq")');
$R ->set('DESeq_table_file',"$transcriptome_path_R/$DESeq_table_folder/$DESeq_table_file");
$R ->run('DEseq_table <- read.table(file=DESeq_table_file, header=TRUE, sep="\t", dec=".", na.strings=c("NA", "#NAME?"), strip.white=TRUE, blank.lines.skip=TRUE)');
$R ->run('no_of_genes=nrow(DEseq_table)');
$R ->set('p_threshold',"$pval_threshold");
$R ->run('DEseq_table$threshold = ifelse(abs(DEseq_table$log2FoldChange) > 2 & DEseq_table$pval < p_threshold, "red","black")');
$R ->run('str(DEseq_table)');
$R ->run('library("RColorBrewer")');
$R ->run('library("ggplot2")');

my $Volcano_plot_file=substr($DESeq_table_file,0,-4);
$Volcano_plot_file=$Volcano_plot_file."_Volcano_plot_".$dt.".jpeg";

#if ($organism=~/^.+\((.+)\)/){$organism=$1;}
#$condition_1=~s/\;/ /g;
#$condition_2=~s/\;/ /g;

#$condition_1=~s/\,/ /g;
#$condition_2=~s/\,/ /g;

#my $plot_title="Volcano plot\n"."(".$organism.": ".$condition_1." vs ".$condition_2.")";
my $plot_title="$organism";
$R ->set('plot_title',"$plot_title");

$R ->set('Volcano_file',"$transcriptome_path_R/$DESeq_table_folder/$Volcano_plot_file");
$R ->run('jpeg(filename=Volcano_file,height=800,width=1000)');
$R ->run('g = ggplot(data=DEseq_table, aes(x=log2FoldChange, y=-log10(pval)))');
$R ->run('plot.final <- g + geom_point(data=DEseq_table, colour=DEseq_table$threshold, alpha=1.0, size=2.5) + theme(plot.title = element_text(size=20, colour="black"), axis.title=element_text(size=20, color="black"), axis.text=element_text(size=18), panel.background = element_rect(fill="white", colour="black")) + xlab("log2 (fold change)") +  ylab("-log10 (p value)") + ggtitle(plot_title)');
$R ->run('plot.final+scale_color_brewer(palette="Spectral")');
$R ->run('plot.final');
$R ->run('dev.off()');
$R ->stop();
#============================================================================================================================================

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# create HTML code

print "Content-type: image/jpeg\n\n";
#print "Content-Disposition: attachment; filename=$Volcano_plot_file\n\n";
open FILE, "< $transcriptome_path/$DESeq_table_folder/$Volcano_plot_file" or die "can't open : $!";
binmode FILE;
local $/ = \10240;
while (<FILE>){print $_;}
close FILE;
unlink "$transcriptome_path/$DESeq_table_folder/$Volcano_plot_file";
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++