# July 11th 2017
# Download CAZy tables
# Input: list of CAZy families
# Output: folders containing html files and summarized table

#! /usr/perl/bin -w
use strict;
use File::Fetch;
use Getopt::Long;

my $cazy_family_input="";
my $group="";
my $folderout="";
mkdir "$folderout";



############################################################################################################
GetOptions('family=s'=>\$cazy_family_input,'group=s'=>\$group,'out=s'=>\$folderout);

if (($cazy_family_input) and ($group) and ($folderout)){print "\nStart processing\n";}
else
{
	print "\n";
	print "Usage: download table of protein IDs from CAZy\n";
	print "--family: input one or more family names (e.g. \"GH24\" or \"GH24,GH25\")\n";
	print "--group: 'all', 'archaea', 'bacteria', 'eukaryota', 'viruses', 'characterized'\n";
	print "--out: name of output folder\n";
	print "\n";
}
############################################################################################################





#========================================================================================================#
# Get list of CAZy families
$cazy_family_input=~s/\s*//g;
my @cazy_list;
if ($cazy_family_input=~/\,/){@cazy_list=split(/\,/),$cazy_family_input;}
else{push(@cazy_list,$cazy_family_input);}
#========================================================================================================#


#========================================================================================================#
foreach my $cazy_family (@cazy_list)
{
	#### Download the first table ####
	mkdir "$folderout/$cazy_family";
	chdir "$folderout/$cazy_family";
	my $url_all='http://www.cazy.org/'.$cazy_family.'_'.$group.'.html';
	my $ff = File::Fetch -> new(uri => $url_all);
	my $file = $ff -> fetch() || die $ff -> error;
	print "\nDownload file $file: done\n";
	##################################
	
	
	#### Read first downloaded file to get the number of tables ####
	open(First_table,"<$file") || die "Cannot open file $file!!!";
	my $number="";
	while (<First_table>)
	{
		$_=~s/^\s*$//;
		# <a href='GH20_all.html?debut_PRINC=3000#pagination_PRINC' class='lien_pagination' rel='nofollow'>4</a></span>
		if ($_=~/href\=\'$cazy_family\_$group\.html\?debut\_TAXO\=(\d+)\#pagination\_TAXO\'/)
		{
			my $temp=$1;
			if ($temp>$number){$number=$temp;}
		}
		
		#<tr valign="top" onmouseover="this.bgColor=
		if ($_=~/\<tr\s+valign\=\"top\"\s+onmouseover\=\"this\.bgColor\=/){last;}
	}
	close(First_table);
	################################################################
	
	
	
	#### Download other pages if applicable #####
	if ($number)
	{
		for (my $i=100; $i<=$number; $i=$i+100)
		{
			mkdir "$folderout/$cazy_family/Temp";
			chdir "$folderout/$cazy_family/Temp";
			my $url='http://www.cazy.org/'.$cazy_family.'_'.$group.'.html?debut_TAXO='.$i.'#pagination_TAXO';
			my $ff1 = File::Fetch -> new(uri => $url);
			my $file1 = $ff1 -> fetch() || die $ff1 -> error;
			my $filenew=$file1;
			$filenew=~s/Temp\/.+//;
			$filenew=$filenew.$cazy_family."_".$i.".html";
			my $cmd="mv $file1 $filenew";
			system $cmd;
			rmdir "$folderout/$cazy_family/Temp";
			print "\nDownload file $filenew: done\n";
		}
	}
	#############################################

}
#========================================================================================================#
