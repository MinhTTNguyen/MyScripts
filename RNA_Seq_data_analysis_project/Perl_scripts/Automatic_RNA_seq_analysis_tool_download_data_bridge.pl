#!/usr/bin/perl -w

use strict;
use CGI qw/:standard/; 



my $transcriptome_data_file=param("file_name"); 
$transcriptome_data_file=~s/\s/\?/g;

my $data_type=param("data_type");
unless ($data_type=~/FPKM/)
{
	$data_type="Read_count";
	$transcriptome_data_file=substr($transcriptome_data_file,0,-8);#FPKM.csv
	$transcriptome_data_file=$transcriptome_data_file."counts.csv";
}

my $add_annotation=param(' Include annotation information');
unless($add_annotation){$add_annotation='off';}

my @selected_conditions=param("Conditions");
my $total_selected_condition=scalar(@selected_conditions);
if ($total_selected_condition>0)
{
	$selected_conditions[0]=~s/\s/\?/g;
	my $conditions=$selected_conditions[0];
	shift(@selected_conditions);
	foreach my $each_cond (@selected_conditions)
	{
		$each_cond=~s/\s/\?/g;
		$conditions=$conditions."=".$each_cond;
	}
	
	system("perl Automatic_RNA_seq_analysis_tool_download_data.pl $transcriptome_data_file $data_type $conditions $add_annotation");
	
}else
{
	print header,
	      start_html,
		  font({-size => 3, -color => "red", -face => "Arial"},b("Please select at least one condition")),
		  end_html;
}