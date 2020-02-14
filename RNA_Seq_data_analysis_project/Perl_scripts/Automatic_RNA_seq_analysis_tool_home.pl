#!/usr/bin/perl -w

use strict;
use CGI qw/:standard/; 

#====================================================================================
### read names of files in the FPKM folder
# Caution: Folders "FPKM" and "Read_count" should have the same files with the same names
my $transcriptome_data_path="/mnt/fpkm";
opendir(FPKM_folder,"$transcriptome_data_path\/FPKM") || die "Cannot open FPKM folder";
my @FPKM_files=readdir(FPKM_folder);
closedir(FPKM_folder);
@FPKM_files=sort(@FPKM_files);
shift(@FPKM_files);shift(@FPKM_files);

### Get full names of the species
# Assumption: The first 5 letter of the FPKM files display the species name codes
my $species_code_file="Species_codes_names.txt";
open(Species_code_file,"<$transcriptome_data_path\/$species_code_file") || die "Cannot open file containing species codes";
my %hash_species_codes;
while(<Species_code_file>)
{
	chomp($_);
	unless($_=~/^\#/)#   #Species Code	Organism
	{
		if ($_=~/(.+)\t(.+)/)#THELA	Thermomyces lanuginosus
		{
			my $code=$1;
			my $name=$2;
			$code=~s/\s*//g;
			$name=~s/^\s*//;
			$name=~s/\s*$//;
			$hash_species_codes{$code}=$name;
		}else{print "Error: species code line is not as described!\n$_";exit;}
	}
}
close(Species_code_file);

### Get full species names from FPKM file names
# Caution: If there is no code available for the file name, just print out the file name without the extension
my @organisms;
my $index=0;
foreach my $fpkm_file (@FPKM_files) # $fpkm_file=Acral2p4.no-rDNA.FPKM.csv || $fpkm_file=Pleos_PC15_2p4.no_rDNA.FPKM.csv
{
	if ($fpkm_file=~/^(.+\dp\d)/){$fpkm_file=$1;}
	else{print "Error: FPKM file name is not as described!\n$fpkm_file";exit;}
	my $code_from_fpkm_file=substr($fpkm_file,0,5);
	my $abbreviated_species_name=$fpkm_file;
	$code_from_fpkm_file=uc($code_from_fpkm_file);
	my $species_name=$hash_species_codes{$code_from_fpkm_file};
	if ($species_name)
	{
		$species_name=$species_name." (".$abbreviated_species_name.")";
	}else{$species_name="(".$abbreviated_species_name.")";}
	$organisms[$index]=$species_name;
	$index++;
}
@organisms=sort(@organisms);
#====================================================================================

#====================================================================================
# get list of species that will be displayed in the information page
my @info_org_list;
my $info_org_count=0;
while (my ($k_species_code, $v_species_name)= each(%hash_species_codes))
{
	$info_org_list[$info_org_count]=$v_species_name." ($k_species_code)";
	$info_org_count++;
}
@info_org_list=sort(@info_org_list);
#====================================================================================


print header,
	  start_html(-title => 'Genozyme Transcriptome Data Analysis - Select organism'),
	  h1({-style=>'Background: PaleTurquoise;height:30px;',-align => "left"}, font({-size => 3, -color => "black", -face => "Arial"},"Genozyme Transcriptome Data Analysis"));

#====================================================================================
# Organism selection form - Display sample information

print start_form (-name => "Display transcriptome ", -method => "get", -action=>"Automatic_RNA_seq_analysis_tool_display_info_table.pl"),
      h1(font({-face => "Arial", -size => 3, -color =>"Red"},"Information of all transcriptome profiles")),
	  h2(font({-face => "Arial", -size => 2},"Select organism:")),
	  popup_menu(-name => "Organism", -values=>[@info_org_list]),
	  submit(-name => "Select"),
	  br,br,br,hr,
	  end_form;
#====================================================================================

#====================================================================================
# Organism selection form -  Download
print start_form (-name => "Download RNA-Seq data", -method => "get", -action=>"Automatic_RNA_seq_analysis_tool_collect_data.pl"),
      h1(font({-face => "Arial", -size => 3, -color =>"Red"},"Download transcriptome data")),
	  h2(font({-face => "Arial", -size => 2},"Select organism:")),
	  popup_menu(-name => "Organism", -values=>[@organisms]),
	  submit(-name => "Select"),
	  br,br,br,hr,
	  end_form;
#====================================================================================


#====================================================================================
# Organism selection form - PCA
print start_form (-name => "PCA analysis", -method => "get", -action=>"Automatic_RNA_seq_analysis_tool_PCA_select_datasets.pl"),
      h1(font({-face => "Arial", -size => 3, -color =>"Red"},"Principle Component Analysis (PCA)")),
	  h2(font({-face => "Arial", -size => 2},"Select organism to analyze:")),
	  popup_menu(-name => "Organism", -values=>[@organisms]),
	  submit(-name => "Select"),
	  br,br,br,hr,
	  end_form;
#====================================================================================


#====================================================================================
# Organism selection form - Volcano analysis
print start_form (-name => "Fold change analysis", -method => "get", -action=>"Automatic_RNA_seq_analysis_tool_select_2_profiles.pl"),
      h1(font({-face => "Arial", -size => 3, -color =>"Red"},"Analyzing fold changes between two conditions")),
	  h2(font({-face => "Arial", -size => 2},"Select organism to analyze:")),
	  popup_menu(-name => "Organism", -values=>[@organisms]),
	  submit(-name => "Select"),
	  br,br,br,
	  a({href=>"Prepare_BLAST2GO_input_data.pl"},"Download transcript sequences for running BLAST2GO"),
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
	  a({href=>"http://www.blast2go.com/b2ghome"},"BLAST2GO"),
	  br,br,br,hr,
	  end_form;
#====================================================================================


print end_html;
