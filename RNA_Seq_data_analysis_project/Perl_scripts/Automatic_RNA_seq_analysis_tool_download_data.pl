#!/usr/bin/perl -w

use strict;
use Statistics::R;
use CGI qw/:standard/;
use DateTime;
no warnings "numeric";

my $dt = DateTime->now; #2014-02-28T23:19:22
$dt=~s/\-//g;
$dt=~s/\://g;
my $transcriptome_path="/mnt/fpkm";
my $transcriptome_path_R="/mnt/fpkm";

my $transcriptome_file=$ARGV[0];
$transcriptome_file=~s/\?/ /g;

my $transcriptome_data_type_folder=$ARGV[1];

my $selected_conditions=$ARGV[2];
$selected_conditions=~s/\?/ /g;

my $add_annotation=$ARGV[3];

my $Output_folder="Temp";

my $downloaded_file="";
my $annotation_folder="updated_initial_annotations_dec2013";


#----------------------------------------------------------------------------------------
# check if transcriptome data files contain # in the first line (if yes, R will not work)
# Readcount_file is FPKM_file in case the user select data type as "FPKM"

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
# get names of selected conditions in the FPKM/Read_count table
my $selected_columns="";
my @selected_conditions_array=split(/=/,$selected_conditions);
foreach my $each_selected_cond (@selected_conditions_array)
{
	my $code=$each_selected_cond;
	$code=~s/^\s*//;
	$code=~s/\s*$//;
	
	if ($selected_columns){$selected_columns=$selected_columns.',"'.$code.'"';}
	else{$selected_columns='"'.$code.'"';}
}
#----------------------------------------------------------------------------------------

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# add ID and length columns
open(Transciptome_file,"<$transcriptome_path/$transcriptome_data_type_folder/$transcriptome_file") || die "Cannot open file $transcriptome_file";
my @Transciptome_file_lines=<Transciptome_file>;
my $first_line=$Transciptome_file_lines[0];#Transcript_Id	Length	R0638	R0639	R0640	R0641	R0642
my @column_names=split(/\t/,$first_line);
my $transcriptID_col_label=shift(@column_names);
my $Length_col_label=shift(@column_names);
close(Transciptome_file);

$selected_columns='"'.$transcriptID_col_label.'","'.$Length_col_label.'",'.$selected_columns;
my $downloaded_column_labels=$selected_columns;

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

$R ->set('input_file',"$transcriptome_path_R\/$transcriptome_data_type_folder\/$transcriptome_file");
$R ->run('data_table <- read.table(file=input_file, header=TRUE, sep="\t")');
$R ->run("new_colnames <- c($first_line)");
$R ->run('colnames(data_table) <- new_colnames');

$R ->run("selected_conditions <-c($selected_columns)");
$R ->run('data_table_selected_cols <- subset(data_table, select=selected_conditions)');

my $fileout=substr($transcriptome_file,0,-4);
$fileout=$fileout."_".$dt.".csv";

$R ->set('output_file',"$transcriptome_path_R\/$Output_folder\/$fileout");
$R ->run("download_col_names <-c($downloaded_column_labels)");
$R ->run('write.table (data_table_selected_cols,file=output_file, quote=FALSE, sep="\t", dec = ".", col.names=download_col_names, row.names = FALSE)');

$R->stop();
$downloaded_file=$fileout;
#----------------------------------------------------------------------------------------

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#$add_annotation
my $downloaded_annotation_file="";
if ($add_annotation eq "on")
{
	### get abbreviated name of the species from $transcriptome_file
	my $abbreviated_species_name="";
	if ($transcriptome_file=~/^(.+\dp\d)/){$abbreviated_species_name=$1;} #Acral2p4.no-rDNA.FPKM.csv
	else{print "Error: Cannot get abbreviated name of the species from transcriptome data file $transcriptome_file\n";exit;}
	
	### get name of files in the annotation folder
	opendir(ANN_FOLDER,"$transcriptome_path/$annotation_folder") || die "Cannot open annotation folder";
	my @annotation_files=readdir(ANN_FOLDER);
	@annotation_files=sort(@annotation_files);
	shift(@annotation_files);shift(@annotation_files);
	foreach my $annotation_file (@annotation_files)
	{
		if ($annotation_file=~/$abbreviated_species_name/){$downloaded_annotation_file=$annotation_file;}
	}
	closedir(ANN_FOLDER);
	if ($downloaded_annotation_file)
	{
		### create hash containing annotation information of the gene models
		my %hash_geneID_ann;
		open(ANN_FILE,"<$transcriptome_path/$annotation_folder/$downloaded_annotation_file") || die "Cannot open file $transcriptome_path/$annotation_folder/$downloaded_annotation_file";
		while(<ANN_FILE>)
		{
			chomp($_);
			my @ann_cols=split(/\t/,$_);
			my $gene_id=$ann_cols[0];
			
			unless($ann_cols[1]){$ann_cols[1]="NA";}
			unless($ann_cols[2]){$ann_cols[2]="NA";}
			unless($ann_cols[3]){$ann_cols[3]="NA";}
			unless($ann_cols[4]){$ann_cols[4]="NA";}
			unless($ann_cols[5]){$ann_cols[5]="NA";}
			unless($ann_cols[6]){$ann_cols[6]="NA";}
			unless($ann_cols[7]){$ann_cols[7]="NA";}
			unless($ann_cols[11]){$ann_cols[11]="NA";}
			unless($ann_cols[12]){$ann_cols[12]="NA";}
			
			my $annotation=$ann_cols[1]."\t".$ann_cols[2]."\t".$ann_cols[3]."\t".$ann_cols[4]."\t".$ann_cols[5]."\t".$ann_cols[6]."\t".$ann_cols[7]."\t".$ann_cols[11]."\t".$ann_cols[12];
			$hash_geneID_ann{$gene_id}=$annotation;
		}
		close(ANN_FILE);
	
		### create the output file $downloaded_file
		$downloaded_file=substr($downloaded_file,0,-4);
		$downloaded_file=$downloaded_file."_annotation.csv";
		open(DOWNLOAD_FILE,">$transcriptome_path/$Output_folder/$downloaded_file") || die "Cannot open file $downloaded_file";
		open(RNA_SEQ_FILE,"<$transcriptome_path/$Output_folder/$fileout") || die "Cannot open file $fileout";
		my $first_line_tag="";
		while (<RNA_SEQ_FILE>)
		{
			chomp($_);
			if ($first_line_tag)
			{
				my @RNA_seq_cols=split(/\t/,$_);
				my $geneID=$RNA_seq_cols[0];
				my $annotation=$hash_geneID_ann{$geneID};
				if ($annotation){print DOWNLOAD_FILE "$_\t$annotation\n";}
				else
				{
					$annotation="NA"."\t"."NA"."\t"."NA"."\t"."NA"."\t"."NA"."\t"."NA"."\t"."NA"."\t"."NA"."\t"."NA";
					print DOWNLOAD_FILE "$_\t$annotation\n";
				}
			}else
			{
				my $ann_colnames=$hash_geneID_ann{"gene_model_id"};
				print DOWNLOAD_FILE "$_\t$ann_colnames\n";
				$first_line_tag=1;
			}
		}
		close(RNA_SEQ_FILE);
		close(DOWNLOAD_FILE);
	}else
	{
		open(DOWNLOAD_FILE,">>$transcriptome_path/$Output_folder/$downloaded_file") || die "Cannot open file $downloaded_file";
		print DOWNLOAD_FILE '*** Annotation information of these gene models is not available';
		close(DOWNLOAD_FILE);
		
	}
}
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# create HTML code
print ("Content-Type:application/x-download\n");
print "Content-Disposition: attachment; filename=$downloaded_file\n\n";
open FILE, "< $transcriptome_path/$Output_folder/$downloaded_file" or die "can't open : $!";
binmode FILE;
local $/ = \10240;
while (<FILE>){print $_;}
close FILE;
if (($add_annotation eq "on") and ($downloaded_annotation_file)){unlink "$transcriptome_path/$Output_folder/$fileout";}
unlink "$transcriptome_path/$Output_folder/$downloaded_file";
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
