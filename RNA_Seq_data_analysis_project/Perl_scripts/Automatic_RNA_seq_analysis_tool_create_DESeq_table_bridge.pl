#!/usr/bin/perl -w

use strict;
use CGI qw/:standard/; 


my $transcriptome_data_file=param("file_name");
$transcriptome_data_file=~s/\s/\?/g;

my $organism=param("Organism");
$organism=~s/\s/\_/g;
$organism=~s/\(/open_pr/g;
$organism=~s/\)/close_pr/g;
	  
my $add_FPKM=param(' Add FPKM values into the DESeq table');
unless($add_FPKM){$add_FPKM='off';}

my $add_annotation=param(' Add annotation information into the DESeq table');
unless($add_annotation){$add_annotation='off';}

my @selected_condition1=param("Condition_1");
my @selected_condition2=param("Condition_2");
my $total_condi1=scalar(@selected_condition1);
my $total_condi2=scalar(@selected_condition2);
my $condition1_samples="";
my $condition2_samples="";
my $cond2_sample_flag="";
if ($total_condi1>0)
{
	if ($total_condi2>0)
	{
		my @double_selection;
		my $double_selection_count=0;
		foreach my $cond1 (@selected_condition1)
		{
			foreach my $cond2 (@selected_condition2)
			{
				if ($cond1 eq $cond2)
				{
					$double_selection[$double_selection_count]=$cond1;
					$double_selection_count++;
				}
				unless ($cond2_sample_flag)
				{
					$cond2=~s/\s/\?/g;
					if ($condition2_samples){$condition2_samples=$condition2_samples."=".$cond2;}
					else{$condition2_samples=$cond2;}
				}
			}
			$cond2_sample_flag++;
			$cond1=~s/\s/\?/g;
			if ($condition1_samples){$condition1_samples=$condition1_samples."=".$cond1;}
			else{$condition1_samples=$cond1;}
		}
		
		if ($double_selection_count>0)
		{
			print header,
				  start_html,
		          b("The following samples were selected in both conditions:"),br, br;
			foreach my $double_select_sample (@double_selection){print b("$double_select_sample"),br;}
			print br,b("Please, reselect your samples and make sure that no sample is selected twice in the two conditions.");
		    print end_html;
		}else
		{
			system("perl Automatic_RNA_seq_analysis_tool_create_DESeq_table.pl $transcriptome_data_file $organism $condition1_samples $condition2_samples $add_FPKM $add_annotation");
		}
	}else
	{
		print header,
	      start_html,
		  font({-size => 3, -color => "red", -face => "Arial"},b("You have not selected any sample for Condition 2. Please, select at least one sample for Condition 2.")),
		  end_html;
	}
}else
{
	print header,
	      start_html,
		  font({-size => 3, -color => "red", -face => "Arial"},b("You have not selected any sample for Condition 1. Please, select at least one sample for Condition 1.")),
		  end_html;
}
