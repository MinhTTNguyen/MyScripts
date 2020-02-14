#!/usr/bin/perl -w

use strict;
use CGI qw/:standard/; 


my $transcriptome_data_file=param("file_name");
if ($transcriptome_data_file){$transcriptome_data_file=~s/\s/\?/g;}

my $organism=param("Organism");
if ($organism)
{
	$organism=~s/\s/\_/g;
	$organism=~s/\(/open_pr/g;
	$organism=~s/\)/close_pr/g;
}
my @selected_conditions=param("Conditions");
my $total_selected_condition=scalar(@selected_conditions);
if ($total_selected_condition>1)
{		    
	$selected_conditions[0]=~s/\s/\?/g;
	my $conditions=$selected_conditions[0];
	shift(@selected_conditions);
	
	foreach my $each_cond (@selected_conditions)
	{
		$each_cond=~s/\s/\?/g;
		$conditions=$conditions."=".$each_cond;
	}
	system("perl Automatic_RNA_seq_analysis_tool_create_PCAplot.pl $transcriptome_data_file $organism $conditions");
}else
{
	print header,
	      start_html,
	      font({-size => 3, -color => "red", -face => "Arial"},b("Please select at least two conditions")),
	      end_html;
}