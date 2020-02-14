#!/usr/bin/perl -w
use strict;
use CGI qw/:standard/;
no warnings "numeric";

my $transcriptome_data_path="/mnt/fpkm";
my $DESeq_table_folder="Temp";

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
# get data from form "Sort DESeq table"
my $unsorted_DESeq_file=param("DESeq_table_file");
my $DESeq_file_noFPKM_noAnnotation_file=param("DESeq_table_file_noFPKM");
my $sorted_column=param("Sort_column");
my $order=param("Sort_order");

my $organism=param("Organism");
my $samples_condition1=param("Condition1");
my $samples_condition2=param("Condition2");

my $add_FPKM=param("add_FPKM");
my $add_annotation=param("add_annotation");
my $FPKM_availability=param("FPKM_availability");
my $annotation_availability=param("ann_availability");
#---------------------------------------------------------------------------------------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------------------------------------------------------------------------------
# sort DESeq table
my $sorted_DESeq_file=substr($unsorted_DESeq_file,0,-4);
$sorted_DESeq_file=$sorted_DESeq_file."_sorted_by_".$sorted_column."_".$order.".txt";
open(Unsorted_file,"<$transcriptome_data_path/$DESeq_table_folder/$unsorted_DESeq_file") || die "Cannot open file $unsorted_DESeq_file";
open(Sorted_file,">$transcriptome_data_path/$DESeq_table_folder/$sorted_DESeq_file") || die "Cannot open file $sorted_DESeq_file";
my @DESeq_lines=<Unsorted_file>;
my $first_line=shift(@DESeq_lines);
chomp($first_line);

############################ get index of column selected to sort ######################################
my @first_row_cols=split(/\t/,$first_line);
my $selected_col_index=0;
my $first_row_col_index=0;
foreach my $first_row_col (@first_row_cols)
{
	if ($first_row_col eq $sorted_column)	{$selected_col_index=$first_row_col_index;}
	$first_row_col_index++;
}
############################ get index of column selected to sort ######################################


############################ create hash containing rows initiated by sorted col ######################################
my %hash_sortrow_displayedrow;
my @array_NA;
my @array_empty;
foreach my $line (@DESeq_lines)
{
	chomp($line);
	my @col_values=split(/\t/,$line);
	my $selected_col_value=$col_values[$selected_col_index];
	
	if ($selected_col_value)
	{
		if ($selected_col_value eq "NA")
		{
			push(@array_NA,$line);
		}else
		{
			if (($sorted_column eq "predicted_function") || ($sorted_column eq "predicted_secreted") || ($sorted_column eq "cazy_family") || ($sorted_column eq "cbm_of_interest") || ($sorted_column eq "best_mycoclap_hit_annot") || ($sorted_column eq "ipr_descriptions"))
			{
				$selected_col_value=lc($selected_col_value);
				my $hash_key=$selected_col_value."\t".$line;
				$hash_sortrow_displayedrow{$hash_key}=$line;
			}else
			{
				if ($sorted_column eq "id") {if ($selected_col_value=~/.*\_(\d*)/){$selected_col_value=$1;}}
				my $hash_key=$selected_col_value."\t".$line;
				$hash_sortrow_displayedrow{$hash_key}=$line;
			}
		}
	}else{push(@array_empty,$line);}
}
my @sorted_rows=keys(%hash_sortrow_displayedrow);

if (($sorted_column eq "predicted_function") || ($sorted_column eq "predicted_secreted") || ($sorted_column eq "num_tm_helices") || ($sorted_column eq "cazy_family") || ($sorted_column eq "cbm_of_interest") || ($sorted_column eq "best_mycoclap_hit_annot") || ($sorted_column eq "ipr_descriptions"))
{
	if ($order eq "Ascending"){@sorted_rows=sort{$a cmp $b} @sorted_rows;}
	else{@sorted_rows=sort{$b cmp $a} @sorted_rows;}
}else
{
	if ($order eq "Ascending"){@sorted_rows=sort{$a <=> $b} @sorted_rows;}
	else{@sorted_rows=sort{$b <=> $a} @sorted_rows;}
}

############################ create hash containing rows initiated by sorted col ######################################

############################ print sorted table to file ######################################
print Sorted_file "$first_line\n";
my @DESeq_colnames=split(/\t/,$first_line);
my @DESeq_table_rows;
my $DESeq_table_rows_index=0;
foreach my $sorted_row (@sorted_rows)
{
	my $display_row=$hash_sortrow_displayedrow{$sorted_row};
	print Sorted_file "$display_row\n";
	$DESeq_table_rows[$DESeq_table_rows_index]=$display_row;
	$DESeq_table_rows_index++;
}
############################ print sorted table to file ######################################
push(@DESeq_table_rows, @array_empty, @array_NA);
close(Unsorted_file);
close(Sorted_file);
#---------------------------------------------------------------------------------------------------------------------------------------------------------------

#====================================================================================================================================================
# create HTML code
print header,
	  start_html(-title => "Genozyme Transcriptome Data Analysis-DESeq table"),
	  h1({-style=>'Background: PaleTurquoise;height:30px;',-align => "left"}, font({-size => 3, -color => "black", -face => "Arial"},"Fold change analysis - DESeq table ($organism)")),
	  a({href=>"Automatic_RNA_seq_analysis_tool_home.pl"},"Back to home page"),
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
	  a({href=>"Prepare_BLAST2GO_input_data.pl"},"Download transcript sequences for running BLAST2GO"),
	  br, br;
print font({-size => 2, -color => "black", -face => "Arial"},b("Samples of condition 1:"), " $samples_condition1"),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",br,br,
      font({-size => 2, -color => "black", -face => "Arial"},b("Samples of condition 2:"), " $samples_condition2"),br,br;

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
 
print     hidden(-name => "DESeq_table_file", -value => "$unsorted_DESeq_file"),
	  hidden(-name => "DESeq_table_file_noFPKM", -value => "$DESeq_file_noFPKM_noAnnotation_file"),
	  hidden(-name => "Organism", -value => "$organism"),
	  hidden(-name => "Condition1", -value => "$samples_condition1"),
	  hidden(-name => "Condition2", -value => "$samples_condition2"),
	  hidden(-name => "add_FPKM", -value => "$add_FPKM"),
	  hidden(-name => "add_annotation", -value => "$add_annotation"),
	  hidden(-name => "FPKM_availability", -value => "$FPKM_availability"),
	  hidden(-name => "ann_availability", -value => "$annotation_availability");

print end_form;
#------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------
# Download table
print start_form(-name => "Download_DESeq_table", -method => "post", -action=>"Automatic_RNA_seq_analysis_tool_download_DESeq_table.pl"),
	  hidden(-name => "DESeq_table_file", -value => "$sorted_DESeq_file");

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
      hidden(-name => "Volcano_table_file", -value => "$DESeq_file_noFPKM_noAnnotation_file"),
      hidden(-name => "Organism", -value => "$organism"),
      #hidden(-name => "Condition1", -value => "$samples_condition1"),
      #hidden(-name => "Condition2", -value => "$samples_condition2"),
      submit(-name => "Create Volcano plot"),
      end_form;
#------------------------------------------------------------------------------------------------------------------------------------------------------

print end_html;
#====================================================================================================================================================