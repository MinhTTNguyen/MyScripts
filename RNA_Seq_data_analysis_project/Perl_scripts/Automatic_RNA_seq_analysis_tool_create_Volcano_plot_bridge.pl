#!/usr/bin/perl -w

use strict;
use CGI qw/:standard/; 
use Statistics::R;


my $DEseq_table_file=param("Volcano_table_file");
if ($DEseq_table_file){$DEseq_table_file=~s/\s/\?/g;}

my $pval_threshold=param("pval_threshold");
my $organism=param("Organism");
if ($organism)
{
	$organism=~s/\s/\_/g;
	$organism=~s/\(/open_pr/g;
	$organism=~s/\)/close_pr/g;
}

#my $condition_1=param("Condition1");
#my $condition_2=param("Condition2");
#if ($condition_1){$condition_1=~s/\s/\?/g;}
#if ($condition_2){$condition_2=~s/\s/\?/g;}

if ($pval_threshold)
{
	#system("perl Automatic_RNA_seq_analysis_tool_create_Volcano_plot.pl $DEseq_table_file $pval_threshold $organism $condition_1 $condition_2");
	system("perl Automatic_RNA_seq_analysis_tool_create_Volcano_plot.pl $DEseq_table_file $pval_threshold $organism");
}else
{
	print header,
	      start_html,
		  font({-size => 3, -color => "red", -face => "Arial"},b("Please select a threshold for p-value")),
		  end_html;
}
