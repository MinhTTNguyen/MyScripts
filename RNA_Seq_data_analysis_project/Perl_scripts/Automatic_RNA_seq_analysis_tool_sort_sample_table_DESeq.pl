#!/usr/bin/perl -w
use strict;
use CGI qw/:standard/;
no warnings "numeric";

#================================================================================================================================================================
# get selected parameter from the table to filter
my $selected_organism=param("Sort_Organism");
my @first_row=param("Sort_First_row");
my @full_table=param("Sort_Full_table");
my @filtered_table=param("Sort_filtered_table");

my $selected_column=param("Sort_column");
my $order=param("Sort_order");

my @full_table_strains=param("Sort_Full_table_strains");
my @full_table_feedstocks=param("Sort_Full_table_feedstocks");
my @full_table_finals=param("Sort_Full_table_finals");
my @full_table_times=param("Sort_Full_table_times");
my @full_table_temps=param("Sort_Full_table_temps");

my $transcriptome_data_file=param("Sort_transcriptome_data_file");
#================================================================================================================================================================


#---------------------------------------------------------------------------------------------------------------------------------------------------------------
# sort table

######################## get index of the selected column ########################
my @first_row_no_checkbox=@first_row;
shift(@first_row_no_checkbox);
shift(@first_row_no_checkbox);

my $new_selected_column=$selected_column;
$new_selected_column=~s/\s*//g;
my $first_row_col_count=0;
my $selected_col_index="";
foreach my $first_row_col (@first_row_no_checkbox)
{
    $first_row_col=~s/\s*//g;
    if ($first_row_col eq $new_selected_column){$selected_col_index=$first_row_col_count;}
    $first_row_col_count++;
}
######################## get index of the selected column ########################


######################## create hash ########################
my %hash_sortrow_printrow; # sortrow=sorted_column_value and printed row; printrow = printed row
foreach my $row (@filtered_table)
{
    my @cols=split(/\t/,$row);
    pop(@cols);
    if (($selected_column eq "Time") || ($selected_column eq "Temperature"))
    {
        if ($cols[$selected_col_index]=~/^(\d*)/){$cols[$selected_col_index]=$1;}
        
    }
    my $key=$cols[$selected_col_index]."\t".$row;
    $key=lc($key);
    $hash_sortrow_printrow{$key}=$row;
}
######################## create hash ########################


######################## sort ########################
my @key_sort_rows=keys(%hash_sortrow_printrow);
if (($selected_column eq "Time") || ($selected_column eq "Temperature"))
{
    if ($order eq "Ascending") {@key_sort_rows=sort{$a <=> $b}@key_sort_rows;}
    else{@key_sort_rows=sort{$b <=> $a}@key_sort_rows;}
}else
{
    if ($order eq "Ascending") {@key_sort_rows=sort{$a cmp $b}@key_sort_rows;}
    else{@key_sort_rows=sort{$b cmp $a}@key_sort_rows;}
}
######################## sort ########################


######################## create sorted table ########################
my @sorted_table;
my $sorted_table_index=0;
foreach my $key_sort_row (@key_sort_rows)
{
    $sorted_table[$sorted_table_index] = $hash_sortrow_printrow{$key_sort_row};
    $sorted_table_index++;
}
######################## create sorted table ########################

#---------------------------------------------------------------------------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------
# create an array containg data to be displayed in the sample information table
my @checkbox_rows;
my $cb_row_count=0;
foreach my $sorted_table_row (@sorted_table)
{
	my @cols=split(/\t/,$sorted_table_row);
	my $colname_in_file=pop(@cols);
	$checkbox_rows[$cb_row_count]=$colname_in_file;
	
	$sorted_table[$cb_row_count]="";
	foreach my $col (@cols)
	{
		if ($sorted_table[$cb_row_count]){$sorted_table[$cb_row_count]=$sorted_table[$cb_row_count]."\t".$col;}
		else{$sorted_table[$cb_row_count]=$col;}
	}
	
	$cb_row_count++;
}
my @checkboxes_condition1=map(checkbox_group(-name=>"Condition_1", -value=>$_,  -onClick =>"Deselect_all_checkboxes(this,'Select_Deselect_all_Condition1')"),@checkbox_rows);
my @checkboxes_condition2=map(checkbox_group(-name=>"Condition_2", -value=>$_,  -onClick =>"Deselect_all_checkboxes(this,'Select_Deselect_all_Condition2')"),@checkbox_rows);
my $row_count=0;
foreach my $checkbox (@checkboxes_condition1)
{
	$sorted_table[$row_count]=$checkbox."\t".$checkboxes_condition2[$row_count]."\t".$sorted_table[$row_count];
	$row_count++;
}
my @rows=map(td([split(/\t/,$_)]), @sorted_table);
#--------------------------------------------------------------------------------



#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Javascript
my $JSCRIPT=<<EOF;
	function Select_all_checkboxes(master,group)
	{ 
		var cbarray = document.getElementsByName(group); 
		for(var i = 0; i < cbarray.length; i++){ cbarray[i].checked = master.checked;} 
	}

	function Deselect_all_checkboxes(master,group)
	{ 
		var cbarray = document.getElementsByName(group); 
		for(var i = 0; i < cbarray.length; i++){ cbarray[i].checked = master.unchecked;} 
	}
EOF
	;
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



#================================================================================================================================================================
# create HTML code
print header,
	  start_html(-title => 'Genozyme Transcriptome Data Collection - Select condition(s)', -script=>$JSCRIPT),
	  h1({-style=>'Background: PaleTurquoise;height:30px;',-align => "left"}, font({-size => 3, -color => "black", -face => "Arial"},"Fold change analysis: Select transcriptome datasets ($selected_organism)"));
print a({href=>"Automatic_RNA_seq_analysis_tool_home.pl"},"Back to home page");
print h2(font({-face => "Arial", -size => 3},"Select condition(s):"));


################################################################ Filter form ################################################################
print start_form (-name => "Filter info table", -method => "post", -action => "Automatic_RNA_seq_analysis_tool_filter_sample_table_DESeq.pl"),
	  br,"&nbsp",
	  font({-face => "Arial", -size => 2},b("Filter table")),
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
	  font({-face => "Arial", -size => 2},b("Strain")),"&nbsp&nbsp&nbsp&nbsp&nbsp",
	  popup_menu(-name => "Filter_strain", -values=>[@full_table_strains], -multiple=>'true', -default=>"All"),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
	  font({-face => "Arial", -size => 2},b("Feedstock")),"&nbsp&nbsp",
	  popup_menu(-name => "Filter_feedstock", -values=>[@full_table_feedstocks], -multiple=>'true', -default=>"All"),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
	  font({-face => "Arial", -size => 2},b('Final%')),"&nbsp&nbsp",
	  popup_menu(-name => "Filter_final", -values=>[@full_table_finals], -multiple=>'true', -default=>"All"),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
	  font({-face => "Arial", -size => 2},b("Time")),"&nbsp&nbsp",
	  popup_menu(-name => "Filter_time", -values=>[@full_table_times], -multiple=>'true', -default=>"All"),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
	  font({-face => "Arial", -size => 2},b("Temperature")),"&nbsp&nbsp",
	  popup_menu(-name => "Filter_temp", -values=>[@full_table_temps], -multiple=>'true', -default=>"All"),
	  
          hidden(-name => "Filter_Organism", -value => "$selected_organism"),
	  hidden(-name => "Filter_First_row", -values => [@first_row]),
	  hidden(-name => "Filter_Full_table", -values => [@full_table]),
	  
	  hidden(-name => "Filter_Full_table_strains", -values => [@full_table_strains]),
	  hidden(-name => "Filter_Full_table_feedstocks", -values => [@full_table_feedstocks]),
	  hidden(-name => "Filter_Full_table_finals", -values => [@full_table_finals]),
	  hidden(-name => "Filter_Full_table_times", -values => [@full_table_times]),
	  hidden(-name => "Filter_Full_table_temps", -values => [@full_table_temps]),
          
          hidden(-name => "Filter_transcriptome_data_file", -value =>"$transcriptome_data_file"),
          
          "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
	  submit(-name => "Filter"),
          "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          font({-size=>3, color=>"grey"},em('(*** For multiple selections, please use Ctrl/Shift)')),
	  end_form;
################################################################ Filter form ################################################################


################################################################ Sort form ################################################################
print start_form (-name => "Sort sample table", -method => "post", -action => "Automatic_RNA_seq_analysis_tool_sort_sample_table_DESeq.pl"),
	  br,"&nbsp",
	  font({-face => "Arial", -size => 2},b("Sort table")),
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          font({-face => "Arial", -size => 2},b("Column")),"&nbsp&nbsp",
	  popup_menu(-name => "Sort_column", -values=>[@first_row_no_checkbox]),
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          font({-face => "Arial", -size => 2},b("Order")),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          popup_menu(-name => "Sort_order", -values=>["Ascending", "Descending"]),
	  
	  hidden(-name => "Sort_Organism", -value => "$selected_organism"),
	  hidden(-name => "Sort_First_row", -values => [@first_row]),
	  hidden(-name => "Sort_Full_table", -values => [@full_table]),
	  hidden(-name => "Sort_filtered_table", -values => [@filtered_table]),
	  
	  hidden(-name => "Sort_Full_table_strains", -values => [@full_table_strains]),
	  hidden(-name => "Sort_Full_table_feedstocks", -values => [@full_table_feedstocks]),
	  hidden(-name => "Sort_Full_table_finals", -values => [@full_table_finals]),
	  hidden(-name => "Sort_Full_table_times", -values => [@full_table_times]),
	  hidden(-name => "Sort_Full_table_temps", -values => [@full_table_temps]),
	  
	  hidden(-name => "Sort_transcriptome_data_file", -value =>"$transcriptome_data_file"),
	  
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          submit(-name => "Sort table"),br, br,
	  end_form;
################################################################ Sort form ################################################################



################################################################ Create DESeq table form ################################################################
print start_form (-name => "Select condition", -method => "post", -action =>"Automatic_RNA_seq_analysis_tool_create_DESeq_table_bridge.pl"),
      font({-face => "Arial", -size => 2},
      radio_group(-name =>"Select_Deselect_all_Condition1", -value =>"Select All (Condition 1)", -onClick =>"Select_all_checkboxes(this,'Condition_1')"),
      "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
      "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
      radio_group(-name =>"Select_Deselect_all_Condition2", -value =>"Select All (Condition 2)", -onClick =>"Select_all_checkboxes(this,'Condition_2')"),
      br,br,
      radio_group(-name =>"Select_Deselect_all_Condition1", -value =>"Deselect All (Condition 1)", -onClick =>"Deselect_all_checkboxes(this,'Condition_1')"),
      "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
      "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
      radio_group(-name =>"Select_Deselect_all_Condition2", -value =>"Deselect All (Condition 2)", -onClick =>"Deselect_all_checkboxes(this,'Condition_2')")),
      br,br,
      table({-style=>"width: 100%;"},
	thead(Tr({-cellpadding=>"3", -cellspacing=>"1", -bgcolor=>"MistyRose", -align=>"left"}, th([@first_row]))),
	tbody(Tr({-cellpadding=>"3", -cellspacing=>"1", -bgcolor=>"AliceBlue"},[@rows]))),
      br, font({-color=>"red"},em("Note: If there are no replicates in each condition, this is not publishable data.")),
      br,br,
      b(font({-face => "Arial", -size => 2},checkbox(-name =>' Add annotation information into the DESeq table'))),br,br,
      b(font({-face => "Arial", -size => 2},checkbox(-name =>' Add FPKM values into the DESeq table'))),
      hidden(-name => "file_name", -value => "$transcriptome_data_file"),
      hidden(-name => "Organism", -value => "$selected_organism"),
      br, br, br, submit(-name => "Create DESeq table"),
      end_form;
################################################################ Create DESeq table form ################################################################


print end_html;	 
#================================================================================================================================================================
