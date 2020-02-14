#!/usr/bin/perl -w
use strict;
use CGI qw/:standard/;
use DateTime;
no warnings "numeric";
my $dt = DateTime->now; #2014-02-28T23:19:22
$dt=~s/\-//g;
$dt=~s/\://g;

my $transcriptome_data_path="/mnt/fpkm";
my $info_table_folder="Temp";

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
# get data from form "Filter info table"
my $info_table_file=param("filter_file_name");
my @selected_strain_values=param("Filter_strain");
my @selected_feedstock_values=param("Filter_feedstock");
my @selected_final_values=param("Filter_final");
my @selected_time_values=param("Filter_time");
my @selected_temp_values=param("Filter_temp");
my $selected_organism=param("Filter_Organism");
#---------------------------------------------------------------------------------------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------------------------------------------------------------------------------
# filter table
open(Info_table,"<$transcriptome_data_path/$info_table_folder/$info_table_file") || die "Cannot open file $info_table_file";
my @table_lines=<Info_table>;
my $first_line=shift(@table_lines);
chomp($first_line);

my @displayed_table;
my $displayed_table_index=0;
my $filtered_table_file=substr($info_table_file,0,-4);
$filtered_table_file=$filtered_table_file."_filtered_".$dt.".txt";
open(Out,">$transcriptome_data_path/$info_table_folder/$filtered_table_file") || die "Cannot open file $filtered_table_file";
print Out "$first_line\n";
my %hash_strains;
my %hash_feedstocks;
my %hash_finals;
my %hash_times;
my %hash_temps;

foreach my $line (@table_lines)
{
    chomp($line);
    my @cols=split(/\t/,$line);
    my $temp=pop(@cols);
    my $time=pop(@cols);
    my $final=pop(@cols);
    my $feedstock=pop(@cols);
    my $strain=pop(@cols);
    
    my $strain_lc=lc($strain);
    my $strain_key=$strain_lc."=".$strain;
    $hash_strains{$strain_key}++;
    
    my $feedstock_lc=lc($feedstock);
    my $feedstock_key=$feedstock_lc."=".$feedstock;
    $hash_feedstocks{$feedstock_key}++;
                                
    my $final_lc=lc($final);
    my $final_key=$final_lc."=".$final;
    $hash_finals{$final_key}++;
                                
    my $time_key=$time;
    if ($time=~/^(\d*)/) {$time_key=$1."_".$time;}
    $hash_times{$time_key}++;
    
    my $temp_key=$temp;                            
    if ($temp=~/^(\d*)/) {$temp_key=$1."_".$temp;}
    $hash_temps{$temp_key}++;
    
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
            $displayed_table[$displayed_table_index]=$line;
            print Out "$line\n";
            $displayed_table_index++;
        }
    }  
}
close(Info_table);
close(Out);
my @new_displayed_table=map(td([split(/\t/,$_)]), @displayed_table);
my @first_row_cols=split(/\t/,$first_line);

my @strains=keys(%hash_strains);
@strains=sort(@strains);
map(($_=~s/^.*=//),@strains);
unshift(@strains,"All");

my @feedstocks=keys(%hash_feedstocks);
@feedstocks=sort(@feedstocks);
map(($_=~s/^.*=//),@feedstocks);
unshift(@feedstocks,"All");

my @finals=keys(%hash_finals);
@finals=sort(@finals);
map(($_=~s/^.*=//),@finals);
unshift(@finals,"All");

my @times=keys(%hash_times);
@times=sort{$a <=> $b}@times;
map(($_=~s/^\d*\_//),@times);
unshift(@times,"All");

my @temps=keys(%hash_temps);
@temps=sort{$a <=> $b}@temps;
map(($_=~s/^\d*\_//),@temps);
unshift(@temps,"All");
#---------------------------------------------------------------------------------------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------------------------------------------------------------------------------
# create HTML code
print header,
      start_html(-title => 'Genozyme Transcriptome Data Information'),
      h1({-style=>'Background: PaleTurquoise;height:30px;',-align => "left"}, font({-size => 3, -color => "black", -face => "Arial"},"Genozyme Transcriptome Data Information for $selected_organism"));
          
print a({href=>"Automatic_RNA_seq_analysis_tool_home.pl"},"Back to home page");

print start_form (-name => "Filter info table", -method => "post", -action => "Automatic_RNA_seq_analysis_tool_filter_info_table.pl"),
	  br, font({-face => "Arial", -size => 2},b("Filter table")),
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          
	  font({-face => "Arial", -size => 2},b("Strain")),"&nbsp&nbsp&nbsp&nbsp&nbsp",
	  popup_menu(-name => "Filter_strain", -values=>[@strains], -multiple=>'true', -default=>"All"),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
	  font({-face => "Arial", -size => 2},b("Feedstock")),"&nbsp&nbsp",
	  popup_menu(-name => "Filter_feedstock", -values=>[@feedstocks], -multiple=>'true', -default=>"All"),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
	  font({-face => "Arial", -size => 2},b('Final%')),"&nbsp&nbsp",
	  popup_menu(-name => "Filter_final", -values=>[@finals], -multiple=>'true', -default=>"All"),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
	  font({-face => "Arial", -size => 2},b("Time")),"&nbsp&nbsp",
	  popup_menu(-name => "Filter_time", -values=>[@times], -multiple=>'true', -default=>"All"),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
	  font({-face => "Arial", -size => 2},b("Temperature")),"&nbsp&nbsp",
	  popup_menu(-name => "Filter_temp", -values=>[@temps], -multiple=>'true', -default=>"All"),
	  hidden(-name => "filter_file_name", -value => "$info_table_file"),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          hidden(-name => "Filter_Organism", -value => "$selected_organism"),
	  submit(-name => "Filter"),
          "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          font({-size=>3, color=>"grey"},em('(*** For multiple selections, please use Ctrl/Shift)')),
	  end_form;

print start_form (-name => "Sort info table", -method => "post", -action => "Automatic_RNA_seq_analysis_tool_sort_info_table.pl"),
	  br, font({-face => "Arial", -size => 2},b("Sort table")),
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          font({-face => "Arial", -size => 2},b("Column")),"&nbsp&nbsp",
	  popup_menu(-name => "Sort_column", -values=>[@first_row_cols]),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          font({-face => "Arial", -size => 2},b("Order")),"&nbsp&nbsp",
          popup_menu(-name => "Sort_order", -values=>["Ascending", "Descending"]),
	  hidden(-name => "Organism", -value => "$selected_organism"),
          hidden(-name => "sort_file_name", -value => "$filtered_table_file"),"&nbsp&nbsp",
          hidden(-name => "full_file_name", -value => "$info_table_file"),"&nbsp&nbsp",
	  submit(-name => "Sort table"),
	  end_form;

print start_form (-name => "Download_info_table", -method => "post", -action => "Automatic_RNA_seq_analysis_tool_download_info_table.pl"),
      br,
      submit(-name => "Download table"),br,br,
      table({-style=>"width: 100%;"},
                thead(Tr({-cellpadding=>"3", -cellspacing=>"1", -bgcolor=>"MistyRose", -align=>"left"}, th([@first_row_cols]))),
		tbody(Tr({-cellpadding=>"3", -cellspacing=>"1", -bgcolor=>"AliceBlue"},[@new_displayed_table]))
	    ),
      br,em('(This table was updated on March 06, 2014)'),
      hidden(-name => "download_file_name", -value => "$filtered_table_file"),
      end_form;
	  
print end_html;
#---------------------------------------------------------------------------------------------------------------------------------------------------------------