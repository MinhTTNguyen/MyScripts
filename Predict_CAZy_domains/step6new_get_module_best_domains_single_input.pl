# October 18th 2017
# Get the best domain CAZy module
# Among overlaping domains, pick up the one with lowest evalue
# Once selected the domain with the lowest evalue, consider domains before and after the selected ones in the initial overlaping group
# E.g. 
#GH43_29.hmm (3.9e-09 , 82% , 34 , 270)
#GH43.hmm (1.2e-29 , 72% , 34 , 393)
#GH43_3.hmm (2.3e-19 , 63% , 35 , 278)
#GH43_17.hmm (7.8e-08 , 49% , 38 , 191)
#GH43_4.hmm (4e-14 , 73% , 38 , 278)
#GH43_31.hmm (2.9e-15 , 78% , 38 , 384)
#GH43_8.hmm (5.3e-12 , 74% , 39 , 252)
#GH43_5.hmm (1.3e-08 , 67% , 39 , 280)
#GH43_10.hmm (6.8e-10 , 78% , 40 , 280)
#GH43_36.hmm (4.3e-06 , 68% , 41 , 251)
#GH43_11.hmm (2.1e-09 , 73% , 41 , 261)
#GH43_14.hmm (3.9e-07 , 68% , 42 , 263)
#GH43_13.hmm (6.1e-07 , 74% , 42 , 265)
#GH43_12.hmm (1.2e-08 , 67% , 43 , 264)
#GH43_30.hmm (3.9e-23 , 80% , 43 , 279)
#GH43_33.hmm (5.6e-13 , 45% , 44 , 204)
#GH43_24.hmm (5e-95 , 98% , 44 , 287)
#GH43_25.hmm (1.4e-25 , 100% , 45 , 277)
#GH43_37.hmm (3.5e-33 , 93% , 48 , 265)
#GH43_32.hmm (1.5e-08 , 63% , 50 , 273)
#GH43_24.hmm (2.6e-06 , 46% , 306 , 444)
#CBM35.hmm (4.3e-18 , 99% , 327 , 446)
# Final module should be: GH43_24 (5e-95 , 98% , 44 , 287) - CBM35.hmm (4.3e-18 , 99% , 327 , 446) not just GH43_24 (5e-95 , 98% , 44 , 287)
# The old perl script (step6_get_module_best_domains_single_input.pl) could not print out CBM35 since it was covered by GH43.hmm (1.2e-29 , 72% , 34 , 393)


#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $path="";
my $filein="";
my $fileout="";
GetOptions('path=s'=>\$path, 'filein=s'=>\$filein, 'fileout=s'=>\$fileout);


#######################################################################################################################################################
print "\n";
if (($path) and ($filein) and ($fileout)){print "\nProcessing...\n";}
else
{
	print "\n";
	print "Usage: extract best domains among overlapping domains and print out best domain module\n";
	print "\n--path   : working directory\n";
	print "\n--filein : input file containing all domains, one line per protein\n";
	print "\n--fileout: output file\n";
	print "\n";
}
#######################################################################################################################################################


open(In,"<$path/$filein") || die "Cannot open file $filein";
open(Out,">$path/$fileout") || die "Cannot open file $fileout";
print Out "#Seq_id\tCAZy_module\tCAZy_module (evalue, HMM coverage, domain_start, domain_end)\n";
while (<In>)
{
	if($_!~/^\#/)
	{
		$_=~s/\s*$//;
		my @cols=split(/\t/,$_);
		my $id=$cols[0];
		my $cazy=$cols[1];
		my @regions=split(/ \- /,$cazy);
		my $best_cazy_module_short="";
		my $best_cazy_module_long="";
		foreach my $region (@regions)
		{
			my $selected_cazy_long=&Process_overlap_region($region);
			if ($best_cazy_module_long){$best_cazy_module_long=$best_cazy_module_long." - ".$selected_cazy_long;}
			else{$best_cazy_module_long=$selected_cazy_long;}
		}
		my @families_long=split(/ \- /,$best_cazy_module_long);
		foreach my $family_long (@families_long)
		{
			$family_long=~s/\s*\(.+\)//;
			if ($best_cazy_module_short){$best_cazy_module_short=$best_cazy_module_short." - ".$family_long;}
			else{$best_cazy_module_short=$family_long;}
		}
		print Out "$id\t$best_cazy_module_short\t$best_cazy_module_long\n";
	}
}
close(In);
close(Out);

#=============================================================================================================================#
sub Process_overlap_region
{
	my $overlap_module=$_[0];#GH43_34.hmm (1.6e-09 , 75% , 28 , 303) | GH43.hmm (1.2e-31 , 72% , 29 , 282) | GH43_3.hmm (2.5e-19 , 72% , 30 , 277) | GH43_8.hmm (6.5e-08 , 75% , 36 , 265) | GH43_4.hmm (1.7e-11 , 73% , 36 , 278) | GH43_31.hmm (3.1e-14 , 79% , 36 , 342) | GH43_5.hmm (1.2e-11 , 77% , 37 , 280) | GH43_11.hmm (8e-09 , 65% , 38 , 247) | GH43_14.hmm (2.7e-08 , 78% , 38 , 274) | GH43_12.hmm (5.3e-07 , 72% , 39 , 259) | GH43_10.hmm (1.8e-06 , 83% , 39 , 275) | GH43_30.hmm (1.7e-17 , 79% , 40 , 279) | GH43_33.hmm (3e-08 , 39% , 41 , 185) | GH43_37.hmm (2.9e-31 , 94% , 42 , 268) | GH43_24.hmm (3.5e-87 , 98% , 42 , 287) | GH43_25.hmm (8e-16 , 98% , 43 , 277) | GH43_32.hmm (2.9e-07 , 59% , 48 , 216) | CBM35.hmm (1.4e-12 , 88% , 327 , 449)
	my @families=split(/ \| /,$overlap_module);
	my $lowest_evalue=10;
	my $lowest_e_family="";
	my $lowest_e_family_index="";
	my $lowest_e_family_start="";
	my $lowest_e_family_end="";
	my $i=-1;
	my $total_families=scalar(@families);
	
	#====================================================================================================#
	# get family with lowest evalue
	foreach my $family (@families)
	{
		$i++;
		if ($family=~/.+\s*\((.+)\s*\,\s*\d+\%\s*\,\s*(\d+)\s*\,\s*(\d+)\)/)
		{
			my $evalue=$1;
			my $start=$2;
			my $end=$3;
			if ($evalue<$lowest_evalue)
			{
				$lowest_evalue=$evalue;
				$lowest_e_family=$family;
				$lowest_e_family_index=$i;
				$lowest_e_family_start=$start;
				$lowest_e_family_end=$end;
			}
		}else{print "Error (line ".__LINE__."): Family information is not as described:\nFamily: -$family- \n";exit;}
	}
	#====================================================================================================#
	
	#====================================================================================================#
	#upstream
	my $upstream_families="";
	for (my $a=0;$a<$lowest_e_family_index;$a++)
	{
		if ($families[$a]=~/.+\s*\(.+\s*\,\s*\d+\%\s*\,\s*\d+\s*\,\s*(\d+)\)/)
		{
			my $end=$1;
			if ($end<$lowest_e_family_start)
			{
				if ($upstream_families){$upstream_families=$upstream_families." | ".$families[$a];}
				else{$upstream_families=$families[$a];}
			}
		}else{print "Error (line ".__LINE__."): Family information is not as described:\nFamily: -$families[$a]- \n";exit;}
	}
	my $upstream_module="";
	if ($upstream_families){$upstream_module=&Process_overlap_region($upstream_families);$upstream_module=$upstream_module." - ";};
	#====================================================================================================#
	
	
	
	#====================================================================================================#
	#downstream
	my $downstream_families="";
	for (my $b=$lowest_e_family_index+1;$b<$total_families;$b++)
	{
		if ($families[$b]=~/.+\s*\(.+\s*\,\s*\d+\%\s*\,\s*(\d+)\s*\,\s*\d+\)/)
		{
			my $start=$1;
			if ($start>$lowest_e_family_end)
			{
				if ($downstream_families){$downstream_families=$downstream_families." | ".$families[$b];}
				else{$downstream_families=$families[$b]}
			}
		}else{print "Error (line ".__LINE__."): Family information is not as described:\nFamily: -$families[$b]- \n";exit;}
	}
	my $downstream_module="";
	if ($downstream_families){$downstream_module=&Process_overlap_region($downstream_families);$downstream_module=" - ".$downstream_module;}
	#====================================================================================================#
	
	my $final_module=$upstream_module.$lowest_e_family.$downstream_module;
	$final_module=~s/\.hmm//g;
	return($final_module);
}
print "\ndone\n";
#=============================================================================================================================#
