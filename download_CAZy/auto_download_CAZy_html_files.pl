# July 11th 2017
# Download CAZy tables
# Input: name of CAZy family of interest or a file containing list of CAZy families
# Output: folders containing html files and summarized table
# 

#! /usr/perl/bin -w
use strict;
use File::Fetch;
use Getopt::Long;

my $cazy_family="";
my $filein_cazy_list="";
my $tab=""; #e.g., eukaryota, characterized, all...
my $folderout="";


GetOptions('cazy_family=s'=>\$cazy_family, 'filein_cazy_list=s'=>\$filein_cazy_list,'tab=s'=>\$tab,'folderout=s'=>\$folderout);

mkdir $folderout;

#========================================================================================================#
# Get list of CAZy families
my @cazy_list;
if ($cazy_family){push(@cazy_list,$cazy_family);}
else
{
	open(List,"<$filein_cazy_list") || die "Cannot open file $filein_cazy_list";
	while (<List>)
	{
		$_=~s/\s*//g;
		push(@cazy_list,$_);
	}
	close(List);
}
#========================================================================================================#


#========================================================================================================#
foreach my $cazy_family (@cazy_list)
{
	#### Download the first table ####
	mkdir "$folderout/$cazy_family";
	chdir "$folderout/$cazy_family";
	my $url_all='http://www.cazy.org/'.$cazy_family.'_'.$tab.'.html';
	#print "\n", $url_all, "\n";exit;
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
		if ($_=~/href\=\'$cazy_family\_$tab\.html\?debut\_PRINC\=(\d+)\#pagination\_PRINC\'/)
		{
			my $temp=$1;
			#print "\n$_\n$temp\n";exit;
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
		for (my $i=1000; $i<=$number; $i=$i+1000)
		{
			mkdir "$folderout/$cazy_family/Temp";
			chdir "$folderout/$cazy_family/Temp";
			my $url='http://www.cazy.org/'.$cazy_family.'_'.$tab.'.html?debut_PRINC='.$i.'#pagination_PRINC';
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
