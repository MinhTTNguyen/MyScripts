#!/usr/bin/perl -w
use strict;
use CGI qw/:standard/;
no warnings "numeric";

#================================================================================================================================================================
# get selected parameter from the table to filter
my $selected_organism=param("Filter_Organism");
my @first_row=param("Filter_First_row");
my @full_table=param("Filter_Full_table");

my @selected_strain_values=param("Filter_strain");
my @selected_feedstock_values=param("Filter_feedstock");
my @selected_final_values=param("Filter_final");
my @selected_time_values=param("Filter_time");
my @selected_temp_values=param("Filter_temp");

my @full_table_strains=param("Filter_Full_table_strains");
my @full_table_feedstocks=param("Filter_Full_table_feedstocks");
my @full_table_finals=param("Filter_Full_table_finals");
my @full_table_times=param("Filter_Full_table_times");
my @full_table_temps=param("Filter_Full_table_temps");

my $transcriptome_data_file=param("Filter_transcriptome_data_file");
#================================================================================================================================================================

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# filter table
my @filtered_table;
foreach my $row (@full_table)
{
    my @cols=split(/\t/,$row);
    pop(@cols); # delete column showing name of the sample in transctiptome data file; e.g., Avicel_R0011
    
    my $temp=pop(@cols);
    my $time=pop(@cols);
    my $final=pop(@cols);
    my $feedstock=pop(@cols);
    my $strain=pop(@cols);
    
    
    ###################### check temperature #######################
    my $temp_flag="";
    foreach my $selected_temp_value (@selected_temp_values)
    {
        if ($selected_temp_value eq "All") {$temp_flag=1;}
        if ($selected_temp_value eq $temp) {$temp_flag=1;}
    }
    ###################### check temperature #######################
    
    
    ###################### check timepoint #######################
    my $time_flag="";
    foreach my $selected_time_value (@selected_time_values)
    {
        if ($selected_time_value eq "All") {$time_flag=1;}
        if ($selected_time_value eq $time) {$time_flag=1;}
    }
    ###################### check timepoint #######################
    
    
    ###################### check final percent #######################
    my $final_flag="";
    foreach my $selected_final_value (@selected_final_values)
    {
        if ($selected_final_value eq "All") {$final_flag=1;}
        if ($selected_final_value eq $final) {$final_flag=1;}
    }
    ###################### check final percent #######################
    
    
    ###################### check feedstock #######################
    my $feedstock_flag="";
    foreach my $selected_feedstock_value (@selected_feedstock_values)
    {
        if ($selected_feedstock_value eq "All") {$feedstock_flag=1;}
        if ($selected_feedstock_value eq $feedstock) {$feedstock_flag=1;}
    }
    ###################### check feedstock #######################
    
    
    ###################### check strain ######################
    my $strain_flag="";
    foreach my $selected_strain_value (@selected_strain_values)
    {
        if ($selected_strain_value eq "All") {$strain_flag=1;}
        if ($selected_strain_value eq $strain) {$strain_flag=1;}
    }
    ###################### check strain ######################
    
    
    my $total_flag_point = $temp_flag + $time_flag + $final_flag + $feedstock_flag + $strain_flag;
    if ($total_flag_point)
    {
        if ($total_flag_point==5)
        {
            push(@filtered_table,$row);
        }
    }
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



#--------------------------------------------------------------------------------
# create an array containg data to be displayed in the sample information table
my @original_filtered_table=@filtered_table;
my @checkbox_rows;
my $cb_row_count=0;
foreach my $filtered_table_row (@filtered_table)
{
	my @cols=split(/\t/,$filtered_table_row);
	my $colname_in_file=pop(@cols);
	$checkbox_rows[$cb_row_count]=$colname_in_file;
	
	$filtered_table[$cb_row_count]="";
	foreach my $col (@cols)
	{
		if ($filtered_table[$cb_row_count]){$filtered_table[$cb_row_count]=$filtered_table[$cb_row_count]."\t".$col;}
		else{$filtered_table[$cb_row_count]=$col;}
	}
	
	$cb_row_count++;
}
my @checkboxes_condition1=map(checkbox_group(-name=>"Condition_1", -value=>$_,  -onClick =>"Deselect_all_checkboxes(this,'Select_Deselect_all_Condition1')"),@checkbox_rows);
my @checkboxes_condition2=map(checkbox_group(-name=>"Condition_2", -value=>$_,  -onClick =>"Deselect_all_checkboxes(this,'Select_Deselect_all_Condition2')"),@checkbox_rows);
my $row_count=0;
foreach my $checkbox (@checkboxes_condition1)
{
	$filtered_table[$row_count]=$checkbox."\t".$checkboxes_condition2[$row_count]."\t".$filtered_table[$row_count];
	$row_count++;
}
my @rows=map(td([split(/\t/,$_)]), @filtered_table);
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
my @sort_columns=@first_row;
shift(@sort_columns); # delete 'Select condition 1 samples' column
shift(@sort_columns); # delete 'Select condition 2 samples' column

print start_form (-name => "Sort sample table", -method => "post", -action => "Automatic_RNA_seq_analysis_tool_sort_sample_table_DESeq.pl"),
	  br,"&nbsp",
	  font({-face => "Arial", -size => 2},b("Sort table")),
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          font({-face => "Arial", -size => 2},b("Column")),"&nbsp&nbsp",
	  popup_menu(-name => "Sort_column", -values=>[@sort_columns]),
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          font({-face => "Arial", -size => 2},b("Order")),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          popup_menu(-name => "Sort_order", -values=>["Ascending", "Descending"]),
	  
	  hidden(-name => "Sort_Organism", -value => "$selected_organism"),
	  hidden(-name => "Sort_First_row", -values => [@first_row]),
	  hidden(-name => "Sort_Full_table", -values => [@full_table]),
	  hidden(-name => "Sort_filtered_table", -values => [@original_filtered_table]),
	  
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
