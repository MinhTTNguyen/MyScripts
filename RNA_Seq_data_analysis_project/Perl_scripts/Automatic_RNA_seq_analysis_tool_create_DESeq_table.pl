#!/usr/bin/perl -w

use strict;
use CGI qw/:standard/; 
use Statistics::R;
use DateTime;
no warnings "numeric";

my $dt = DateTime->now; #2014-02-28T23:19:22
$dt=~s/\-//g;
$dt=~s/\://g;

#====================================================================================================================================================
my $transcriptome_path="/mnt/fpkm";
my $transcriptome_path_R="/mnt/fpkm";

my $transcriptome_data_file=$ARGV[0];
$transcriptome_data_file=~s/\?/ /g;

my $transcriptome_data_type_folder="Read_count";

my $organism=$ARGV[1];
$organism=~s/open_pr/\(/g;
$organism=~s/close_pr/\)/g;
$organism=~s/\_/ /g;

my $condition_1=$ARGV[2];
$condition_1=~s/\?/ /g;
my $condition_2=$ARGV[3];
$condition_2=~s/\?/ /g;

my $add_FPKM=$ARGV[4];

my $add_annotation=$ARGV[5];

my $downloaded_DESeq_table_file="";
my $Output_folder="Temp";
my $annotation_folder="updated_initial_annotations_dec2013";
#====================================================================================================================================================

#----------------------------------------------------------------------------------------
# check if transcriptome data files contain # in the first line (if yes, R will not work)
open(Readcount_file,"<$transcriptome_path/$transcriptome_data_type_folder/$transcriptome_data_file") || die "Cannot open file $transcriptome_data_file";
my @Readcount_file_lines=<Readcount_file>;
close(Readcount_file);
my $first_file_line=shift(@Readcount_file_lines);
if ($first_file_line =~/\#/)
{
	unlink "$transcriptome_path/$transcriptome_data_type_folder/$transcriptome_data_file";
	open(New_transciptome_file,">$transcriptome_path/$transcriptome_data_type_folder/$transcriptome_data_file") || die "Cannot create file $transcriptome_data_file";
	$first_file_line=~s/\#/\_/g;
	print New_transciptome_file "$first_file_line";
	foreach my $each_line (@Readcount_file_lines){print New_transciptome_file "$each_line";}
	close(New_transciptome_file);
}
#----------------------------------------------------------------------------------------



#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# get names of the selected columns
my $selected_condition_1="";
my $selected_condition_2="";
my $DESeq_data_column_cond1="";
my $DESeq_data_column_cond2="";
my @samples;
my $sample_count=0;

my @cond1_samples=split(/=/,$condition_1);
my @cond2_samples=split(/=/,$condition_2);
my $cond1_sample_count=scalar(@cond1_samples);
my $cond2_sample_count=scalar(@cond2_samples);

if ($cond1_sample_count==1)
{	
	my $temp_selected_condition_1=$cond1_samples[0];
	$temp_selected_condition_1=~s/\-/\_/g;
	$temp_selected_condition_1=~s/^\s*//;
	$temp_selected_condition_1=~s/\s*$//;
	$selected_condition_1='"'.$temp_selected_condition_1.'","'.$temp_selected_condition_1.'","'.$temp_selected_condition_1.'"';
	$samples[$sample_count]=$temp_selected_condition_1;
	$sample_count++;
	$DESeq_data_column_cond1='"Condition1","Condition1","Condition1"';
}else
{
	foreach my $sample_cond1 (@cond1_samples)
	{
		$sample_cond1=~s/\-/\_/g;
		$sample_cond1=~s/^\s*//;
		$sample_cond1=~s/\s*$//;
		
		$samples[$sample_count]=$sample_cond1;
		$sample_count++;
		if ($selected_condition_1)
		{
			$selected_condition_1=$selected_condition_1.',"'.$sample_cond1.'"';
			$DESeq_data_column_cond1=$DESeq_data_column_cond1.',"Condition1"';
		}
		else
		{
			$selected_condition_1='"'.$sample_cond1.'"';
			$DESeq_data_column_cond1='"Condition1"';
		}
	}
}

if ($cond2_sample_count==1)
{	
	my $temp_selected_condition_2=$cond2_samples[0];
	$temp_selected_condition_2=~s/\-/\_/g;
	$temp_selected_condition_2=~s/^\s*//;
	$temp_selected_condition_2=~s/\s*$//;
	$selected_condition_2='"'.$temp_selected_condition_2.'","'.$temp_selected_condition_2.'","'.$temp_selected_condition_2.'"';
	$samples[$sample_count]=$temp_selected_condition_2;
	$sample_count++;
	$DESeq_data_column_cond2='"Condition2","Condition2","Condition2"';
}else
{
	foreach my $sample_cond2 (@cond2_samples)
	{
		$sample_cond2=~s/\-/\_/g;
		$sample_cond2=~s/^\s*//;
		$sample_cond2=~s/\s*$//;
		$samples[$sample_count]=$sample_cond2;
		$sample_count++;
		if ($selected_condition_2)
		{
			$selected_condition_2=$selected_condition_2.',"'.$sample_cond2.'"';
			$DESeq_data_column_cond2=$DESeq_data_column_cond2.',"Condition2"';
		}
		else
		{
			$selected_condition_2='"'.$sample_cond2.'"';
			$DESeq_data_column_cond2='"Condition2"';
		}
	}
}
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


#====================================================================================================================================================
# get the new column names which do not contain "-"
open(Transciptome_file,"<$transcriptome_path/$transcriptome_data_type_folder/$transcriptome_data_file") || die "Cannot open file $transcriptome_data_file";
my @Transciptome_file_lines=<Transciptome_file>;
my $first_line=$Transciptome_file_lines[0];#Transcript_Id	Length	R0638	R0639	R0640	R0641	R0642
my @column_labels=split(/\t/,$first_line);
shift(@column_labels);
$first_line=join("\t",@column_labels);
$first_line=~s/\t/\"\,\"/g;
$first_line='"'.$first_line.'"';
$first_line=~s/\-/\_/g;
$first_line=~s/\"\s*/\"/g;
$first_line=~s/\s*\"/\"/g;

close(Transciptome_file);
#====================================================================================================================================================


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
my $R = Statistics::R -> new();
$R ->start();

$R ->set('input_file',"$transcriptome_path_R/$transcriptome_data_type_folder/$transcriptome_data_file");
$R ->run('data_table <- read.table(file=input_file, header=TRUE, sep="\t", row.names=1)');
$R ->run("new_colnames <- c($first_line)");
$R ->run('colnames(data_table) <- new_colnames');
my $selected_samples=$selected_condition_1.','.$selected_condition_2;
$R ->run("selected_samples <-c($selected_samples)");
$R ->run('data_table_selected_cols <- subset(data_table, select=selected_samples)');
my $DESeq_data_table_cols=$DESeq_data_column_cond1.','.$DESeq_data_column_cond2;
$R ->run("DESeq_data_cols <-c($DESeq_data_table_cols)");
$R ->run('colnames(data_table_selected_cols) <- DESeq_data_cols');
$R ->run('rownames(data_table_selected_cols) <- rownames(data_table)');

my $DESeq_data_file=substr($transcriptome_data_file,0,-4);
$DESeq_data_file=$DESeq_data_file."_DESeq_data_".$dt.".txt";
$R ->set('DESeq_data_file',"$transcriptome_path_R/$Output_folder/$DESeq_data_file");
$R ->run('write.table(data_table_selected_cols, file=DESeq_data_file, sep="\t", row.names=TRUE, col.names=colnames(data_table_selected_cols), quote=F)');

$R ->run('DESeq_data_table <- read.table(file=DESeq_data_file, header=TRUE, sep="\t", row.names=1)');

$R ->run('library("DESeq")');
$R ->run('conditions <- colnames(DESeq_data_table)');
$R ->run('data <- newCountDataSet(DESeq_data_table, conditions)');
$R ->run('data <- estimateSizeFactors(data)');
$R ->run('sizeFactors(data)');
$R ->run('data=estimateDispersions(data,method="blind",sharingMode="fit-only")');
$R ->set('condition_1',"Condition1");
$R ->set('condition_2',"Condition2");
$R ->run('results=nbinomTest(data, condition_1, condition_2)');

my $DESeq_table_file=substr($transcriptome_data_file,0,-4);
$DESeq_table_file=$DESeq_table_file."_DESeq_table_".$dt.".txt";

$R ->set('DESeq_table_file',"$transcriptome_path_R/$Output_folder/$DESeq_table_file");
$R ->run('write.table(results, file=DESeq_table_file, sep="\t", row.names=FALSE, col.names=colnames(results), quote=F)');

$R ->stop();

open(DESeq_table,"<$transcriptome_path/$Output_folder/$DESeq_table_file") || die "Cannot open file $DESeq_table_file"; 
my @DESeq_table_rows=<DESeq_table>;
my $DESeq_first_line=shift(@DESeq_table_rows);
chomp($DESeq_first_line);
my @DESeq_colnames=split(/\t/,$DESeq_first_line);
close(DESeq_table);
$downloaded_DESeq_table_file=$DESeq_table_file;
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


#*****************************************************************************************************************************************************
# add FPKM values into the DESeq table
my $FPKM_availability="Available";
if ($add_FPKM eq "on")
{
	
	####### get name of the FPKM file
	my $abbreviated_species_name="";
	if ($transcriptome_data_file=~/^(.+\dp\d)/){$abbreviated_species_name=$1;}
	else{print "Error: Readcount file name is not as described!\n$transcriptome_data_file";exit;}

	my $selected_fpkm_file="";
	opendir(FPKM_DIR,"$transcriptome_path/FPKM") || die "Cannot open FPKM folder";
	my @fpkm_files=readdir(FPKM_DIR);
	@fpkm_files=sort(@fpkm_files);
	shift(@fpkm_files);shift(@fpkm_files);
	foreach my $fpkm_file (@fpkm_files)
	{
		if ($fpkm_file=~/$abbreviated_species_name/){$selected_fpkm_file=$fpkm_file;}
	}
	closedir(FPKM_DIR);
	###################
	
	if($selected_fpkm_file)
	{
		# Read file containing FPKM values and create a hash containing FPKM values of the selected samples for each transcript ID
		my %hash_id_FPKM;
	
		open(FPKM_file,"<$transcriptome_path/FPKM/$selected_fpkm_file") || die "Cannot open file $selected_fpkm_file";
		my @FPKM_lines=<FPKM_file>;
		my $first_FPKM_line=$FPKM_lines[0];
		$first_FPKM_line=~s/\-/\_/g;
		my @FPKM_col_names=split(/\t/,$first_FPKM_line);
		shift(@FPKM_lines);
	
		### get indices of selected samples in the @FPKM_col_names array
		my @array_sample_indices="";
		my $array_sample_indices_count=0;
		my $fpkm_index=0;
		#$selected_samples=~s/\"\,\"/=/g;
		#$selected_samples=~s/\"//g;
		#my @samples=split(/=/,$selected_samples);
		my $fpkm_colnames="";
		foreach my $FPKM_colname (@FPKM_col_names)
		{
			$FPKM_colname=~s/^\s*//;
			$FPKM_colname=~s/\s*$//;
			foreach my $sample (@samples)
			{
				if ($FPKM_colname eq $sample)
				{
					$array_sample_indices[$array_sample_indices_count]=$fpkm_index;
					$array_sample_indices_count++;
					
					if ($fpkm_colnames){$fpkm_colnames=$fpkm_colnames."\t".$sample.' (FPKM)';}
					else{$fpkm_colnames=$sample.' (FPKM)';}
				}
			}
			$fpkm_index++;
		}
		
		foreach my $FPKM_line (@FPKM_lines)
		{
			chomp($FPKM_line);
			my @FPKM_cols=split(/\t/,$FPKM_line);
			my $transcript_id=$FPKM_cols[0];
			foreach my $selected_fpkm_index (@array_sample_indices)
			{
				unless($FPKM_cols[$selected_fpkm_index]){$FPKM_cols[$selected_fpkm_index]="ZERO";}
				if ($hash_id_FPKM{$transcript_id}){$hash_id_FPKM{$transcript_id}=$hash_id_FPKM{$transcript_id}."\t".$FPKM_cols[$selected_fpkm_index];}
				else{$hash_id_FPKM{$transcript_id}=$FPKM_cols[$selected_fpkm_index];}
			}
		}
	
		my $DESeq_table_FPKM_file=substr($DESeq_table_file,0,-4);
		$DESeq_table_FPKM_file=$DESeq_table_FPKM_file."_FPKM.txt";
		$downloaded_DESeq_table_file=$DESeq_table_FPKM_file;
	
		#$DESeq_first_line=$DESeq_first_line."\t".$condition_1.' (FPKM)'."\t".$condition_2.' (FPKM)';
		$DESeq_first_line=$DESeq_first_line."\t".$fpkm_colnames;
		
		@DESeq_colnames=split(/\t/,$DESeq_first_line);
		
		my $DESeq_table_row_index=0;
		foreach my $DESeq_table_row (@DESeq_table_rows)
		{
			chomp($DESeq_table_row);
			chomp($DESeq_table_rows[$DESeq_table_row_index]);
			my @DESeq_table_row_values=split(/\t/,$DESeq_table_row);
			my $id=$DESeq_table_row_values[0];
			my $FPKM_values=$hash_id_FPKM{$id};
			if ($FPKM_values=~/ZERO/){$FPKM_values=~s/ZERO/0/g;}
			$DESeq_table_rows[$DESeq_table_row_index]=$DESeq_table_rows[$DESeq_table_row_index]."\t".$FPKM_values;
			$DESeq_table_row_index++;
		}
		close(FPKM_file);
	}else{$FPKM_availability="File containing FPKM values is not available";}
}
#*****************************************************************************************************************************************************


#*****************************************************************************************************************************************************
# add annotation information into the DESeq table
my $annotation_availability="Available";
if ($add_annotation eq "on")
{
	
	####### get name of the annotation file
	my $abbreviated_species_name="";
	if ($transcriptome_data_file=~/^(.+\dp\d)/){$abbreviated_species_name=$1;}
	else{print "Error: Readcount file name is not as described!\n$transcriptome_data_file";exit;}

	my $selected_annotation_file="";
	opendir(ANN_DIR,"$transcriptome_path/$annotation_folder") || die "Cannot open annotation folder";
	my @ann_files=readdir(ANN_DIR);
	@ann_files=sort(@ann_files);
	shift(@ann_files);shift(@ann_files);
	foreach my $ann_file (@ann_files)
	{
		if ($ann_file=~/$abbreviated_species_name/){$selected_annotation_file=$ann_file;}
	}
	closedir(ANN_DIR);
	###################
	
	if($selected_annotation_file)
	{
		### create hash containing annotation information of the gene models
		my %hash_geneID_ann;
		open(ANN_FILE,"<$transcriptome_path/$annotation_folder/$selected_annotation_file") || die "Cannot open file $selected_annotation_file";
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
	
		### create the output file
		$downloaded_DESeq_table_file=substr($downloaded_DESeq_table_file,0,-4);
		$downloaded_DESeq_table_file=$downloaded_DESeq_table_file."_annotation.txt";
		
		my $ann_colnames=$hash_geneID_ann{"gene_model_id"};
		$DESeq_first_line=$DESeq_first_line."\t$ann_colnames";
		@DESeq_colnames=split(/\t/,$DESeq_first_line);
		
		my $row_count=0;
		foreach my $DESeq_table_row (@DESeq_table_rows)
		{
			chomp($DESeq_table_row);
			chomp($DESeq_table_rows[$row_count]);
			my @RNA_seq_cols=split(/\t/,$DESeq_table_row);
			my $geneID=$RNA_seq_cols[0];
			my $annotation=$hash_geneID_ann{$geneID};
			if ($annotation){$DESeq_table_rows[$row_count]=$DESeq_table_rows[$row_count]."\t$annotation";}
			else
			{
				$annotation="NA"."\t"."NA"."\t"."NA"."\t"."NA"."\t"."NA"."\t"."NA"."\t"."NA"."\t"."NA"."\t"."NA";
				$DESeq_table_rows[$row_count]=$DESeq_table_rows[$row_count]."\t$annotation";
			}
			$row_count++;
		}
	}else{$annotation_availability="Annotation information is not available";}
}
#*****************************************************************************************************************************************************

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# print output file
if (($add_annotation eq "on") || ($add_FPKM eq "on"))
{
	open(Out,">$transcriptome_path/$Output_folder/$downloaded_DESeq_table_file") || die "Cannot open file $downloaded_DESeq_table_file";
	print Out "$DESeq_first_line\n";
	foreach my $output_row (@DESeq_table_rows){print Out "$output_row\n";}
	close(Out);
}
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#====================================================================================================================================================
# create HTML code
print header,
	  start_html(-title => "Genozyme Transcriptome Data Analysis-DESeq table"),
	  h1({-style=>'Background: PaleTurquoise;height:30px;',-align => "left"}, font({-size => 3, -color => "black", -face => "Arial"},"Fold change analysis - DESeq table ($organism)")),
	  a({href=>"Automatic_RNA_seq_analysis_tool_home.pl"},"Back to home page"),
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
	  a({href=>"Prepare_BLAST2GO_input_data.pl"},"Download transcript sequences for running BLAST2GO"),
	  br, br;
my $display_samples_cond1=$condition_1;
my $display_samples_cond2=$condition_2;
if ($display_samples_cond1=~/=/){$display_samples_cond1=~s/=/; /g;}
if ($display_samples_cond2=~/=/){$display_samples_cond2=~s/=/; /g;}

print font({-size => 2, -color => "black", -face => "Arial"},b("Samples of condition 1:"), " $display_samples_cond1"),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",br,br,
      font({-size => 2, -color => "black", -face => "Arial"},b("Samples of condition 2:"), " $display_samples_cond2"),br,br;

#------------------------------------------------------------------------------------------------------------------------------------------------------		     
# sort DESeq table
print start_form(-name => "Sort DESeq table", -method => "post", -action=> "Automatic_RNA_seq_analysis_tool_sort_DESeq_table.pl"),
	  font({-face => "Arial", -size => 2},b("Sort DESeq table")),
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          font({-face => "Arial", -size => 2},b("Column")),"&nbsp&nbsp",
	  popup_menu(-name => "Sort_column", -values=>[@DESeq_colnames]),
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          font({-face => "Arial", -size => 2},b("Order")),"&nbsp&nbsp",
          popup_menu(-name => "Sort_order", -values=>["Ascending", "Descending"]),
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
	  submit(-name => "Sort table"), br, br;
 
print     hidden(-name => "DESeq_table_file", -value => "$downloaded_DESeq_table_file"),
	  hidden(-name => "DESeq_table_file_noFPKM", -value => "$DESeq_table_file"),
	  hidden(-name => "Organism", -value => "$organism"),
	  hidden(-name => "Condition1", -value => "$display_samples_cond1"),
	  hidden(-name => "Condition2", -value => "$display_samples_cond2"),
	  hidden(-name => "add_FPKM", -value => "$add_FPKM"),
	  hidden(-name => "add_annotation", -value => "$add_annotation"),
	  hidden(-name => "FPKM_availability", -value => "$FPKM_availability"),
	  hidden(-name => "ann_availability", -value => "$annotation_availability");

print end_form;
#------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------
# Download table
print start_form(-name => "Download_DESeq_table", -method => "post", -action=>"Automatic_RNA_seq_analysis_tool_download_DESeq_table.pl"),
	  hidden(-name => "DESeq_table_file", -value => "$downloaded_DESeq_table_file");

#table
#print style('thead {cursor: pointer}');
print div ({-style=>"overflow: auto; height: 500px; width: 100%;"},
	  table({-style=>"width: 100%;", -class=>"tablesorter", -id=>"DESeq_table"},
            thead(Tr({-cellpadding=>"3", -cellspacing=>"1", -bgcolor=>"MistyRose", -align=>"left"}, th([@DESeq_colnames]))),
			tbody(Tr({-cellpadding=>"3", -cellspacing=>"1", -bgcolor=>"AliceBlue"},[map(td([split(/\t/,$_)]), @DESeq_table_rows)]))
		   ));
print font({-color=>"grey"},
      em(b("(pval: ")),
      em("p value for the statistical significance of the change; "),
      em(b("padj: ")),
      em("p value adjusted for multiple testing with the Benjamini-Hochberg procedure, which controls False Discovery Rate; "),
      em(b("baseMeanA, baseMeanB & baseMean: ")),
      em("mean normalized counts from condition A, B and both)")),br;
if (($add_FPKM eq "on") and ($FPKM_availability ne "Available")){print font({-color => "red"},em("*** $FPKM_availability")),br;}
if (($add_annotation eq "on") and ($annotation_availability ne "Available")){print font({-color => "red"},em("*** $annotation_availability")),br;}
print br,submit(-name => "Download DESeq table");
print end_form;
#------------------------------------------------------------------------------------------------------------------------------------------------------


#------------------------------------------------------------------------------------------------------------------------------------------------------
# Volcano plot
print start_form(-name => "Create Volcano plot", -method => "post", -action=>"Automatic_RNA_seq_analysis_tool_create_Volcano_plot_bridge.pl"),
      br,h2(font({-face => "Arial", -size => 3},"Create Volcano plot:")),
	  font({-size => 2, -color => "black", -face => "Arial"},"Select threshold for pval: "),
	  textfield(-name=>"pval_threshold", -default =>"0.05"), 
	  "&nbsp&nbsp",
      hidden(-name => "Volcano_table_file", -value => "$DESeq_table_file"),
	  hidden(-name => "Organism", -value => "$organism"),
	  #hidden(-name => "Condition1", -value => "$display_samples_cond1"),
	  #hidden(-name => "Condition2", -value => "$display_samples_cond1"),
	  submit(-name => "Create Volcano plot"),
      end_form;
#------------------------------------------------------------------------------------------------------------------------------------------------------

print end_html;
#====================================================================================================================================================