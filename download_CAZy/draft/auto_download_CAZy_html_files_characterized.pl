# July 11th 2017
# Download CAZy tables
# Input: list of CAZy families
# Output: folders containing html files and summarized table

#! /usr/perl/bin -w
use strict;
use File::Fetch;

my $path="/home/mnguyen/Research/Lysozyme/GH23/CAZy";
my $filein_cazy_list="CAZy_list.txt";
my $folderout="HTML_Characterized";
mkdir "$path/$folderout";
#========================================================================================================#
# Get list of CAZy families
my @cazy_list;
open(List,"<$filein_cazy_list") || die "Cannot open file $filein_cazy_list";
while (<List>)
{
	$_=~s/\s*//g;
	push(@cazy_list,$_);
}
close(List);
#========================================================================================================#


#========================================================================================================#
foreach my $cazy_family (@cazy_list)
{
	#### Download the first table ####
	mkdir "$path/$folderout/$cazy_family";
	chdir "$path/$folderout/$cazy_family";
	my $url_all='http://www.cazy.org/'.$cazy_family.'_characterized.html';
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
		if ($_=~/href\=\'$cazy_family\_characterized\.html\?debut\_FUNC\=(\d+)\#pagination\_FUNC\'/)
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
			mkdir "$path/$folderout/$cazy_family/Temp";
			chdir "$path/$folderout/$cazy_family/Temp";
			my $url='http://www.cazy.org/'.$cazy_family.'_characterized.html?debut_FUNC='.$i.'#pagination_FUNC';
			my $ff1 = File::Fetch -> new(uri => $url);
			my $file1 = $ff1 -> fetch() || die $ff1 -> error;
			my $filenew=$file1;
			$filenew=~s/Temp\/.+//;
			$filenew=$filenew.$cazy_family."_".$i.".html";
			my $cmd="mv $file1 $filenew";
			system $cmd;
			rmdir "$path/$folderout/$cazy_family/Temp";
			print "\nDownload file $filenew: done\n";
		}
	}
	#############################################

}
#========================================================================================================#
