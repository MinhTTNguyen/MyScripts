#!/usr/bin/perl -w

use strict;
use CGI qw/:standard/;
no warnings "numeric";

my $transcriptome_data_path="/mnt/fpkm";
my $info_table_folder="Temp";

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
# get data from form "Sort info table"

my $info_table_file=param("sort_file_name");
my $full_table_file=param("full_file_name");
my $selected_organism=param("Organism");
my $selected_column=param("Sort_column");
my $order=param("Sort_order");
#---------------------------------------------------------------------------------------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------------------------------------------------------------------------------
my %hash_sortrow_printrow; # sortrow=sorted_column_value and printed row; printrow = printed row
open(Unsorted_info_file, "<$transcriptome_data_path/$info_table_folder/$info_table_file") or die "\nCannot open file $info_table_file\n";
my @rows=<Unsorted_info_file>;

######################## get index of the selected column ########################
my $first_line=shift(@rows);
chomp($first_line);
my @first_row_cols=split(/\t/,$first_line);
my $new_selected_column=$selected_column;
$new_selected_column=~s/\s*//g;
my $first_row_col_count=0;
my $selected_col_index="";
foreach my $first_row_col (@first_row_cols)
{
    $first_row_col=~s/\s*//g;
    if ($first_row_col eq $new_selected_column){$selected_col_index=$first_row_col_count;}
    $first_row_col_count++;
}
######################## get index of the selected column ########################



######################## create hash ########################
foreach my $row (@rows)
{
    chomp($row);
    my @cols=split(/\t/,$row);
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


######################## print to file ########################
my @displayed_table;
my $displayed_table_index=0;
my $sorted_file=substr($info_table_file,0,-4);
$sorted_file=$sorted_file."_sorted_by_".$new_selected_column."_".$order.".txt";
my $download_file=$sorted_file;
open(Out,">$transcriptome_data_path/$info_table_folder/$sorted_file") || die "\nCannot open file $sorted_file \n";
print Out "$first_line\n";

foreach my $key_sort_row (@key_sort_rows)
{
    $displayed_table[$displayed_table_index] = $hash_sortrow_printrow{$key_sort_row};
    print Out "$hash_sortrow_printrow{$key_sort_row}\n";
    $displayed_table_index++;
}
close(Unsorted_info_file);
close(Out);
######################## print to file ########################


######################## create hashes containing filtered values of columns ########################
open(Full_info_file, "<$transcriptome_data_path/$info_table_folder/$full_table_file") or die "\nCannot open file $full_table_file\n";
my %hash_strains;
my %hash_feedstocks;
my %hash_finals;
my %hash_times;
my %hash_temps;
my @full_table_lines=<Full_info_file>;
shift(@full_table_lines);
foreach my $full_table_line (@full_table_lines)
{
    chomp($full_table_line);
    my @full_table_row_values=split(/\t/,$full_table_line);
    my $temp=pop(@full_table_row_values);
    my $time=pop(@full_table_row_values);
    my $final_percent=pop(@full_table_row_values);
    my $feedstock=pop(@full_table_row_values);
    my $strain=pop(@full_table_row_values);
    
    my $strain_lc=lc($strain);
    $strain=$strain_lc."=".$strain;
    $hash_strains{$strain}++;
    
    my $feedstock_lc=lc($feedstock);
    $feedstock=$feedstock_lc."=".$feedstock;
    $hash_feedstocks{$feedstock}++;
                                
    my $final_percent_lc=lc($final_percent);
    $final_percent=$final_percent_lc."=".$final_percent;
    $hash_finals{$final_percent}++;
                                
    if ($time=~/^(\d*)/) {$time=$1."_".$time;}
    $hash_times{$time}++;
                                
    if ($temp=~/^(\d*)/) {$temp=$1."_".$temp;}
    $hash_temps{$temp}++;
}
close(Full_info_file);
######################## create hashes containing filtered values of columns ########################


my @new_displayed_table=map(td([split(/\t/,$_)]), @displayed_table);
@first_row_cols=split(/\t/,$first_line);

my @strains=keys(%hash_strains);
@strains=sort{$a cmp $b}@strains;
map(($_=~s/^.*=//),@strains);
unshift(@strains,"All");

my @feedstocks=keys(%hash_feedstocks);
@feedstocks=sort{$a cmp $b} @feedstocks;
map(($_=~s/^.*=//),@feedstocks);
unshift(@feedstocks,"All");

my @finals=keys(%hash_finals);
@finals=sort{$a cmp $b} @finals;
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
	  hidden(-name => "filter_file_name", -value => "$full_table_file"),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          hidden(-name => "Filter_Organism", -value => "$selected_organism"),
	  submit(-name => "Filter"),
          "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          font({-size=>3, color=>"grey"},em('(*** For multiple selections, please use Ctrl/Shift)')),
	  end_form;

print start_form (-name => "Sort info table", -method => "post", -action => "Automatic_RNA_seq_analysis_tool_sort_info_table.pl"),
	  br, font({-face => "Arial", -size => 2},b("Sort table")),
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          font({-face => "Arial", -size => 2},b("Column")),"&nbsp&nbsp",
	  popup_menu(-name => "Sort_column", -values=>[@first_row_cols], -default=>"$selected_column"),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          font({-face => "Arial", -size => 2},b("Order")),"&nbsp&nbsp",
          popup_menu(-name => "Sort_order", -values=>["Ascending", "Descending"], -default=>"$order"),
	  hidden(-name => "Organism", -value => "$selected_organism"),
          hidden(-name => "sort_file_name", -value => "$info_table_file"),"&nbsp&nbsp",
          hidden(-name => "full_file_name", -value => "$full_table_file"),
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
      hidden(-name => "download_file_name", -value => "$sorted_file"),
      end_form;
	  
print end_html;
#========================================================================================================