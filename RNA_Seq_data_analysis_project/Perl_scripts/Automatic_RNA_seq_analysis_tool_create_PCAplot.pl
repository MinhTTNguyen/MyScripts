#!/usr/bin/perl -w
use strict;
use Statistics::R;
#use CGI qw/:standard/;
use DateTime;

my $dt = DateTime->now; #2014-02-28T23:19:22
$dt=~s/\-//g;
$dt=~s/\://g;

my $transcriptome_path="/mnt/fpkm";
my $transcriptome_path_R="/mnt/fpkm";

my $transcriptome_file=$ARGV[0];
$transcriptome_file=~s/\?/ /g;

my $transcriptome_data_type_folder="Read_count";

my $organism=$ARGV[1];
$organism=~s/open_pr/\(/g;
$organism=~s/close_pr/\)/g;
$organism=~s/\_/ /g;

my $selected_conditions=$ARGV[2];
$selected_conditions=~s/\?/ /g;

my $Output_folder="Temp";

#----------------------------------------------------------------------------------------
# check if transcriptome data files contain # in the first line (if yes, R will not work)
open(Readcount_file,"<$transcriptome_path/$transcriptome_data_type_folder/$transcriptome_file") || die "Cannot open file $transcriptome_file";
my @Readcount_file_lines=<Readcount_file>;
close(Readcount_file);
my $first_file_line=shift(@Readcount_file_lines);
if ($first_file_line =~/\#/)
{
	unlink "$transcriptome_path/$transcriptome_data_type_folder/$transcriptome_file";
	open(New_transciptome_file,">$transcriptome_path/$transcriptome_data_type_folder/$transcriptome_file") || die "Cannot create file $transcriptome_file";
	$first_file_line=~s/\#/\_/g;
	print New_transciptome_file "$first_file_line";
	foreach my $each_line (@Readcount_file_lines){print New_transciptome_file "$each_line";}
	close(New_transciptome_file);
}
#----------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------
# get names of selected conditions in the Read_count table
my $selected_columns="";
my $displayed_column_labels="";

my @selected_conditions_array=split(/=/,$selected_conditions);
foreach my $each_selected_cond (@selected_conditions_array)
{
	my $code=$each_selected_cond;
	$code=~s/^\s*//;
	$code=~s/\s*$//;
	
	if ($selected_columns)
	{
		$selected_columns=$selected_columns.',"'.$code.'"';
		$displayed_column_labels=$displayed_column_labels.',"'.$each_selected_cond.'"';
	}
	else
	{
		$selected_columns='"'.$code.'"';
		$displayed_column_labels='"'.$each_selected_cond.'"';
	}
}
#----------------------------------------------------------------------------------------

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
open(Transciptome_file,"<$transcriptome_path/$transcriptome_data_type_folder/$transcriptome_file") || die "Cannot open file $transcriptome_file";
my @Transciptome_file_lines=<Transciptome_file>;
my $first_line=$Transciptome_file_lines[0];#Transcript_Id	Length	R0638	R0639	R0640	R0641	R0642
close(Transciptome_file);

$selected_columns=~s/\-/\_/g;
$selected_columns=~s/\#/\_/g;
$first_line=~s/\t/\"\,\"/g;
$first_line='"'.$first_line.'"';
$first_line=~s/\-/\_/g;
$first_line=~s/\"\s*/\"/g;
$first_line=~s/\s*\"/\"/g;
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#----------------------------------------------------------------------------------------
#create table containing data of selected conditions
my $R=Statistics::R ->new();
$R->start();

$R ->set('input_file',"$transcriptome_path_R/$transcriptome_data_type_folder/$transcriptome_file");
$R ->run('data_table <- read.table(file=input_file, header=TRUE, sep="\t")');
$R ->run("new_colnames <- c($first_line)");
$R ->run('colnames(data_table) <- new_colnames');

$R ->run("selected_conditions <-c($selected_columns)");
$R ->run('data_table_selected_cols <- subset(data_table, select=selected_conditions)');
$R ->run("displayed_conditions <-c($displayed_column_labels)");
$R ->run('colnames(data_table_selected_cols) <- displayed_conditions');


#create PCA plot
$R ->run('library("DESeq")');
$R ->run('data <- newCountDataSet(data_table_selected_cols, displayed_conditions)');
$R ->run('data <- estimateSizeFactors(data)');
$R ->run('sizeFactors(data)');
$R ->run('data <- estimateDispersions(data, method="blind", sharingMode="fit-only")');
$R ->run('dataBlind = estimateDispersions (data, method ="blind")');
$R ->run('vsdFull = varianceStabilizingTransformation(dataBlind)');

my $PCA_plot_file=substr($transcriptome_file,0,-4);
$PCA_plot_file=$PCA_plot_file."_PCA_plot_".$dt.".jpeg";

$R ->set('PCA_plot_file',"$transcriptome_path_R/$Output_folder/$PCA_plot_file");
$R ->run('jpeg(filename=PCA_plot_file, height=800,width=1000)');
$R ->run('plotPCA(vsdFull, intgroup=c("condition"))');

#$R ->run('title(main="test")');
$R ->run('dev.off()');
$R->stop();
#----------------------------------------------------------------------------------------

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# create HTML code
=pod
print ("Content-Type:application/x-download\n");
print "Content-Disposition: attachment; filename=$PCA_plot_file\n\n";
open FILE, "< $transcriptome_path/$Output_folder/$PCA_plot_file" or die "can't open : $!";
binmode FILE;
local $/ = \10240;
while (<FILE>){print $_;}
close FILE;
=cut

print "Content-type: image/jpeg\n\n";
open FILE, "< $transcriptome_path/$Output_folder/$PCA_plot_file" or die "can't open : $!";
#print "test";
while (<FILE>){print $_;}
close FILE;

unlink "$transcriptome_path/$Output_folder/$PCA_plot_file";

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


