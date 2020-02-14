#!/usr/bin/perl -w
use strict;
use CGI qw/:standard/;
no warnings "numeric";


#========================================================================================================
# get the conditions of the selected species
# Assumption: all $selected_organism contain the name of abbreviated species name in parentheses ()
my $transcriptome_data_path="/mnt/fpkm";
my $selected_organism=param("Organism"); 
my $transcriptome_data_file="";
my $abbreviated_species_name="";
if ($selected_organism=~/.*\((.+)\)/){$abbreviated_species_name=$1;}
else{print "Error: Cannot get the abbreviated species name\n$selected_organism\n";exit;}

## get name of the FPKM file
opendir(FPKM_folder, "$transcriptome_data_path/FPKM") || die "Cannot open FPKM folder";
my @FPKM_files=readdir(FPKM_folder);
@FPKM_files=sort(@FPKM_files);
shift(@FPKM_files);shift(@FPKM_files);
foreach my $fpkm_file (@FPKM_files)
{
	if ($fpkm_file=~/$abbreviated_species_name/){$transcriptome_data_file=$fpkm_file;}
}
closedir(FPKM_folder);

## get the list of conditions from the FPKM file
open(FPKM_file,"<$transcriptome_data_path/FPKM/$transcriptome_data_file") || die "Cannot open FPKM file\n";
my @FPKM_file_lines=<FPKM_file>;
my $first_line=$FPKM_file_lines[0];#Transcript_Id	Length	R0638	R0639	R0640	R0641
my @coded_conditions=split(/\t/,$first_line);
shift(@coded_conditions);shift(@coded_conditions); # discard Transcript_Id	Length
close(FPKM_file);

## decode conditions
my $Condition_code_file="Condition_codes_desc.txt";
my %hash_condition_code;
open(Condition_code,"<$transcriptome_data_path/$Condition_code_file") || die "Cannot open file $Condition_code_file";
my $first_displayed_table_row="";
while(<Condition_code>)
{
	chomp($_);
	if($_=~/^\#/) ##CSFG short code	CSFG Code	Species Code	Organism	Strain	Feedstock	Final %	Time	Temp
	{
		$first_displayed_table_row=$_;
		$first_displayed_table_row=~s/\#CSFG\s*short\s*code\t//;
		$first_displayed_table_row=~s/\tSpecies\s*Code//;
		$first_displayed_table_row=~s/\tOrganism//;
		
		$first_displayed_table_row=~s/CSFG\s*Code/CSFG Sample Code/;
		$first_displayed_table_row=~s/Temp/Temperature/;
	}
	else
	{
		if ($_=~/(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)/) #R0002	SPOTH	ATCC	Sporotrichum thermophile		barley	2	21h	45
		{
			my $short_code=$1;
			my $long_code=$2;
			#my $species_code=$3;
			#my $org=$4;
			my $strain=$5;
			my $feedstock=$6;
			my $final_percent=$7;
			my $time=$8;
			my $temperature=$9;
			
			$short_code=~s/^\s*//;
                        $short_code=~s/\s*$//;
                        
			$long_code=~s/^\s*//;
                        $long_code=~s/\s*$//;
			
			#$species_code=~s/^\s*//;
                        #$species_code=~s/\s*$//;
			
			#$org=~s/^\s*//;
                        #$org=~s/\s*$//;
                        
			$strain=~s/^\s*//;
                        $strain=~s/\s*$//;
                        
			$feedstock=~s/^\s*//;
                        $feedstock=~s/\s*$//;
                        
			$final_percent=~s/^\s*//;
                        $final_percent=~s/\s*$//;
                        
			$time=~s/^\s*//;
                        $time=~s/\s*$//;
                        
			$temperature=~s/^\s*//;
                        $temperature=~s/\s*$//;
			
			
			unless ($short_code){$short_code="NA";}
			unless ($long_code){$long_code="NA";}
			#unless ($org){$org="NA";}
			unless ($strain){$strain="NA";}
			unless ($feedstock){$feedstock="NA";}
			unless ($final_percent){$final_percent="NA";}
			unless ($time){$time="NA";}
			unless ($temperature){$temperature="NA";}
			
			if ($strain=~/\?/){$strain=~s/\?/Delta/;}
			
			
			my $condition_code=$short_code;
			my $condition_desc=$long_code."\t".$strain."\t".$feedstock."\t".$final_percent."\t".$time."\t".$temperature;
			$condition_code=~s/\s*//g;
			$condition_desc=~s/^\s*//;
			$condition_desc=~s/\s*$//;
			$hash_condition_code{$condition_code}=$condition_desc;
		}
		else{print "Error: condition code line is not as described!\n$_";exit;}
	}
}
close(Condition_code);

my @first_displayed_row_cols=split(/\t/,$first_displayed_table_row);

my @all_condition_codes=keys(%hash_condition_code);
my @conditions;
my $index=0;

### hashes contain values to filter table
my %hash_strains;
my %hash_feedstocks;
my %hash_finals;
my %hash_times;
my %hash_temps;

foreach my $coded_condition (@coded_conditions)
{
	my $displayed_condition="";
	foreach my $code (@all_condition_codes)
	{
		if ($coded_condition=~/$code/)
		{
			my $description=$hash_condition_code{$code};
			$displayed_condition=$description."\t".$coded_condition;
			
			my @desc_cols=split(/\t/,$description);
			
			my $temp=pop(@desc_cols);
			if ($temp=~/^(\d*)/) {$temp=$1."_".$temp;}
			$hash_temps{$temp}++;
			
			my $time=pop(@desc_cols);
			
			if ($time=~/^(\d*)/) {$time=$1."_".$time;}
			$hash_times{$time}++;
			
			my $final_percent=pop(@desc_cols);
			
			my $final_percent_lc=lc($final_percent);
			$final_percent=$final_percent_lc."=".$final_percent;
			$hash_finals{$final_percent}++;
			
			my $feedstock=pop(@desc_cols);
			
			my $feedstock_lc=lc($feedstock);
                        $feedstock=$feedstock_lc."=".$feedstock;
			$hash_feedstocks{$feedstock}++;
			
			my $strain=pop(@desc_cols);
			
			my $strain_lc=lc($strain);
			$strain=$strain_lc."=".$strain;
			$hash_strains{$strain}++;
		}
	}
	
	unless($displayed_condition)
	{
		$displayed_condition="NA\tNA\tNA\tNA\tNA\tNA\t".$coded_condition;
		$hash_strains{'na=NA'}++;
		$hash_feedstocks{'na=NA'}++;
		$hash_finals{'na=NA'}++;
		$hash_times{'na_NA'}++;
		$hash_temps{'na_NA'}++;
	}
	$conditions[$index]=$displayed_condition;
	$index++;
}
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
map(($_=~s/^.*\_//),@times);
unshift(@times,"All");

my @temps=keys(%hash_temps);
@temps=sort{$a <=> $b}@temps;
map(($_=~s/^.*\_//),@temps);
unshift(@temps,"All");
#========================================================================================================


#--------------------------------------------------------------------------------
# create an array containg data to be displayed in the sample information table
my @full_table=@conditions;
my @checkbox_rows;
my $cb_row_count=0;
foreach my $condition (@conditions)
{
	my @cols=split(/\t/,$condition);
	my $colname_in_file=pop(@cols);
	$checkbox_rows[$cb_row_count]=$colname_in_file;
	
	$conditions[$cb_row_count]="";
	foreach my $col (@cols)
	{
		if ($conditions[$cb_row_count]){$conditions[$cb_row_count]=$conditions[$cb_row_count]."\t".$col;}
		else{$conditions[$cb_row_count]=$col;}
	}
	
	$cb_row_count++;
}
my @checkboxes=map(checkbox_group(-name=>"Conditions", -value=>$_, -onClick =>"Deselect_all_checkboxes(this,'Select_Deselect_all')"),@checkbox_rows);
my $row_count=0;
foreach my $checkbox (@checkboxes)
{
	$conditions[$row_count]=$checkbox."\t".$conditions[$row_count];
	$row_count++;
}
#my @checkboxes=map(td(checkbox_group(-name=>"Conditions", -value=>$_, -onClick =>"Deselect_all_checkboxes(this,'Select_Deselect_all')")),@checkbox_rows);
my @rows=map(td([split(/\t/,$_)]), @conditions);
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


#========================================================================================================
# create HTML file
print header,
	  start_html(-title => 'Genozyme Transcriptome Data Collection - Select condition(s)', -script=>$JSCRIPT),
	  h1({-style=>'Background: PaleTurquoise;height:30px;',-align => "left"}, font({-size => 3, -color => "black", -face => "Arial"},"Download RNA-Seq Data for $selected_organism"));
print a({href=>"Automatic_RNA_seq_analysis_tool_home.pl"},"Back to home page");
print h2(font({-face => "Arial", -size => 3},"Select condition(s):"));


################################################################ Filter form ################################################################
print start_form (-name => "Filter info table", -method => "post", -action => "Automatic_RNA_seq_analysis_tool_filter_sample_table.pl"),
	  br,"&nbsp",
	  font({-face => "Arial", -size => 2},b("Filter table")),
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
	  
	  hidden(-name => "Filter_Organism", -value => "$selected_organism"),
	  hidden(-name => "Filter_First_row", -values => ["Select column(s) in transcriptome data file",@first_displayed_row_cols]),
	  hidden(-name => "Filter_Full_table", -values => [@full_table]),
	  hidden(-name => "Filter_Full_table_strains", -values => [@strains]),
	  hidden(-name => "Filter_Full_table_feedstocks", -values => [@feedstocks]),
	  hidden(-name => "Filter_Full_table_finals", -values => [@finals]),
	  hidden(-name => "Filter_Full_table_times", -values => [@times]),
	  hidden(-name => "Filter_Full_table_temps", -values => [@temps]),
	  hidden(-name => "Filter_transcriptome_data_file", -value =>"$transcriptome_data_file"),
	  
          "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
	  submit(-name => "Filter"),
          "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          font({-size=>3, color=>"grey"},em('(*** For multiple selections, please use Ctrl/Shift)')),
	  end_form;
################################################################ Filter form ################################################################


################################################################ Sort form ################################################################
print start_form (-name => "Sort sample table", -method => "post", -action => "Automatic_RNA_seq_analysis_tool_sort_sample_table.pl"),
	  br,"&nbsp",
	  font({-face => "Arial", -size => 2},b("Sort table")),
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          font({-face => "Arial", -size => 2},b("Column")),"&nbsp&nbsp",
	  popup_menu(-name => "Sort_column", -values=>[@first_displayed_row_cols]),
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          font({-face => "Arial", -size => 2},b("Order")),"&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          popup_menu(-name => "Sort_order", -values=>["Ascending", "Descending"]),
	  
	  hidden(-name => "Sort_Organism", -value => "$selected_organism"),
	  hidden(-name => "Sort_First_row", -values => ["Select column(s) in transcriptome data file",@first_displayed_row_cols]),
	  hidden(-name => "Sort_Full_table", -values => [@full_table]),
	  hidden(-name => "Sort_filtered_table", -values => [@full_table]),
	  
	  hidden(-name => "Sort_Full_table_strains", -values => [@strains]),
	  hidden(-name => "Sort_Full_table_feedstocks", -values => [@feedstocks]),
	  hidden(-name => "Sort_Full_table_finals", -values => [@finals]),
	  hidden(-name => "Sort_Full_table_times", -values => [@times]),
	  hidden(-name => "Sort_Full_table_temps", -values => [@temps]),
	  
	  hidden(-name => "Sort_transcriptome_data_file", -value =>"$transcriptome_data_file"),
	  
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
          submit(-name => "Sort table"),br, br,
	  end_form;
################################################################ Sort form ################################################################


################################################################ Download form ################################################################
print start_form (-name => "Select conditions", -method => "post", -action => "Automatic_RNA_seq_analysis_tool_download_data_bridge.pl"),
      font({-face => "Arial", -size => 2},
      radio_group(-name =>"Select_Deselect_all", -value =>"Select All", -onClick =>"Select_all_checkboxes(this,'Conditions')"),
      "&nbsp&nbsp&nbsp&nbsp&nbsp",
      radio_group(-name =>"Select_Deselect_all", -value =>"Deselect All", -onClick =>"Deselect_all_checkboxes(this,'Conditions')")),
      br,br;

print table({-style=>"width: 100%;"},
            thead(Tr({-cellpadding=>"3", -cellspacing=>"1", -bgcolor=>"MistyRose", -align=>"left"}, th(["Select column(s) in transcriptome data file",@first_displayed_row_cols]))),
	    tbody(Tr({-cellpadding=>"3", -cellspacing=>"1", -bgcolor=>"AliceBlue"},[@rows]))
            );
print h2(font({-face => "Arial", -size => 3},"Select data type:")),
      font({-face => "Arial", -size => 2},
	  radio_group(-name => "data_type", -value =>"FPKM"),
	  "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
	  radio_group(-name => "data_type", -value =>"Read count"),
	  br, br, br, b(checkbox(-name =>' Include annotation information'))),
	  hidden(-name => "file_name", -value => "$transcriptome_data_file"),
	  br, br,br, submit(-name => "Download file"),
      end_form;
################################################################ Download form ################################################################


print end_html;	 
#========================================================================================================