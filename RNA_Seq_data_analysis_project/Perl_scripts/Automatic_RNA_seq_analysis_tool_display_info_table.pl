#!/usr/bin/perl -w

use strict;
use CGI qw/:standard/;
no warnings "numeric";

my $transcriptome_data_path="/mnt/fpkm";
my $output_folder="Temp";
#========================================================================================================
# get name of the selected species and its species code
my $selected_organism=param("Organism"); # Aspergillus niger (ASPNI)
my $selected_species_code="";
if ($selected_organism=~/.+\((.+)\)/){$selected_species_code=$1;}
else{print "\nError: Species code is not found\n";exit;}
#========================================================================================================

#========================================================================================================
# read file containing the sample information table sent from Nadeeza
my @displayed_table;
my $row_count=0;
my @first_row_cols;
my $first_row="";
my %hash_strains;
my %hash_feedstocks;
my %hash_finals;
my %hash_times;
my %hash_temps;
open(Info_table_file,"<$transcriptome_data_path/Condition_codes_desc.txt") || die "Cannot open file Condition_codes_desc.txt";
while (<Info_table_file>)
{
	chomp($_);
	if ($_=~/^\#/)
	{
		$first_row=$_;
		$first_row=~s/CSFG Code/CSFG Sample Code/;
		$first_row=~s/Temp/Temperature/;
                
                #### remove columns "Species code" and "Organism"
                $first_row=~s/\tSpecies Code//;
                $first_row=~s/\tOrganism//;
                
		@first_row_cols=split(/\t/,$first_row);
                
		shift(@first_row_cols); # delete column "short sample code". e.g., R00451
	}else
	{
		if ($_=~/.*\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)/)
		{
			my $csfg_code=$1;
			my $species_code=$2;
			#my $organism=$3;
			my $strain=$4;
			my $feedstock=$5;
			my $final_percent=$6;
			my $time=$7;
			my $temp=$8;
                        
                        $csfg_code=~s/^\s*//;
                        $csfg_code=~s/\s*$//;
                        
			$species_code=~s/^\s*//;
                        $species_code=~s/\s*$//;
                        
			#$organism=~s/^\s*//;
                        #$organism=~s/\s*$//;
                        
			$strain=~s/^\s*//;
                        $strain=~s/\s*$//;
                        
			$feedstock=~s/^\s*//;
                        $feedstock=~s/\s*$//;
                        
			$final_percent=~s/^\s*//;
                        $final_percent=~s/\s*$//;
                        
			$time=~s/^\s*//;
                        $time=~s/\s*$//;
                        
			$temp=~s/^\s*//;
                        $temp=~s/\s*$//;
		
			unless ($csfg_code){$csfg_code='n/a';}
			unless ($species_code){$species_code='n/a';}
			#unless ($organism){$organism='n/a';}
			unless ($strain){$strain='n/a';}
			unless ($feedstock){$feedstock='n/a';}
			unless ($final_percent){$final_percent='n/a';}
			unless ($time){$time='n/a';}
			unless ($temp){$temp='n/a';}
		
			if ($strain=~/\?/){$strain=~s/\?/Delta/;}
			my $new_species_code=substr($species_code,0,5); #in some cases, the species code is THITE_CO, basically it is the same as THITE
			my $row=$csfg_code."\t".$strain."\t".$feedstock."\t".$final_percent."\t".$time."\t".$temp;
			if ($selected_species_code=~/$new_species_code/)
			{
				$displayed_table[$row_count]=$row; 
				
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
				$row_count++;
			}
		}
	}
}
@displayed_table=sort(@displayed_table);
my @new_displayed_table=map(td([split(/\t/,$_)]), @displayed_table);
close(Info_table_file);

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
#========================================================================================================

#========================================================================================================
# print table to file
my $transcriptome_info_file=$selected_species_code."_transcriptome_data_info.txt";
open(Out,">$transcriptome_data_path/$output_folder/$transcriptome_info_file") || die "Cannot open file $transcriptome_info_file";
$first_row=~s/^\#CSFG short code\t//;
print Out "$first_row\n";

foreach my $each_row (@displayed_table){print Out "$each_row\n";}
close(Out);
#========================================================================================================

#========================================================================================================
#create HTML code
print header,
	  start_html(-title => 'Genozyme Transcriptome Data Information'),
	  h1({-style=>'Background: PaleTurquoise;height:30px;',-align => "left"}, font({-size => 3, -color => "black", -face => "Arial"},"Genozyme Transcriptome Data Information for $selected_organism"));
print a({href=>"Automatic_RNA_seq_analysis_tool_home.pl"},"Back to home page");

print start_form (-name => "Filter info table", -method => "post", -action => "Automatic_RNA_seq_analysis_tool_filter_info_table.pl"),
	  br, font({-face => "Arial", -size => 2},b("Filter table")),
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          #br,br,
          #"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
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
	  hidden(-name => "filter_file_name", -value => "$transcriptome_info_file"),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
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
          font({-face => "Arial", -size => 2},b("Order")),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          popup_menu(-name => "Sort_order", -values=>["Ascending", "Descending"]),
	  hidden(-name => "Organism", -value => "$selected_organism"),
          hidden(-name => "sort_file_name", -value => "$transcriptome_info_file"),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
	  hidden(-name => "full_file_name", -value => "$transcriptome_info_file"),
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
          hidden(-name => "download_file_name", -value => "$transcriptome_info_file"),
	  end_form;
	  
print end_html;
#========================================================================================================