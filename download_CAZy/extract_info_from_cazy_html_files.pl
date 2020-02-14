# July 11th 2017
# Extract information from html files downloaded from CAZy

#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $folderin;
my $folderout;

GetOptions('in=s'=>\$folderin,'out=s'=>\$folderout);

###################################################################################
print "\n";
print "--in: folder containing html files downloaded from CAZy\n";
print "--out: folder containing output files\n";
print "\n";
###################################################################################

mkdir $folderout;
chdir $folderout;
opendir(DIR,"$folderin") || die "Cannot open folder $folderin";
my @cazy_folders=readdir(DIR);
closedir(DIR);

foreach my $cazy_family (@cazy_folders)
{
	if (($cazy_family ne ".") and ($cazy_family ne ".."))
	{
		my $fileout=$cazy_family.".txt";
		open(Out,">$fileout") || die "Cannot open file $fileout"; 
		print Out "#Protein_name\tEC\tOrganism\tGenBank\tUniProt\tPDB\tSubf\n";

		opendir(CAZy_folder,"$folderin/$cazy_family") || die "Cannot open folder $folderin/$cazy_family";
		my @html_files=readdir(CAZy_folder);
		foreach my $html_file (@html_files)
		{
			if (($html_file ne ".") and ($html_file ne ".."))
			{
				open(HTML,"<$folderin/$cazy_family/$html_file") || die "Cannot open file $html_file";
				
				my $protname="";
				my $ec="";
				my $org="";
				my $gb="";
				my $uniprot="";
				my $pdb="";
				my $sub="";
				while (<HTML>)
				{
					$_=~s/\s*$//;
					if ($_=~/\<tr\s+valign\=\"top\"\s+onmouseover\=\"this\.bgColor\=/)
					{
						if ($protname){print Out "$protname\t$ec\t$org\t$gb\t$uniprot\t$pdb\t$sub\t$html_file\n";}
						$protname="";
						$ec="";
						$gb="";
						$org="";
						$uniprot="";
						$pdb="";
						$sub="";
					}
					
					#<td id="separateur2">&nbsp;PCZ31_3489 (Bglh_6)</td>
					if ($_=~/\<td\s+id\=\"separateur2\"\>\&nbsp\;(.+)\<\/td\>/)
					{
						my $temp=$1;
						$temp=~s/^\s*//;
						$temp=~s/\s*$//;
						$temp=~s/\t/ /g;
						if ($temp){$protname=$temp;}
					}
					
					#<td id="separateur2" align="left"><font class="E"><a href="http://www.enzyme-database.org/query.php?ec=3.2.1.86" target="_link">3.2.1.86</a></font></td>
					#<td id="separateur2" align="left"><font class="E"><a href="http://www.enzyme-database.org/query.php?ec=3.2.1.21" target="_link">3.2.1.21</a></font><br><font class="E"><a href="http://www.enzyme-database.org/query.php?ec=3.2.1.23" target="_link">3.2.1.23</a></font><br><font class="E"><a href="http://www.enzyme-database.org/query.php?ec=3.2.1.*" target="_link">3.2.1.-</a></font></td>
					if ($_=~/\<a\s+href\=\"http\:\/\/www\.enzyme\-database\.org\/query\.php\?ec=(.+)\"\s+target/)
					{
						if ($_=~/\<br\>/)
						{
							my @all_ecs=split(/\<br\>/,$_);
							foreach my $ec_line (@all_ecs)
							{
								my $ec_number=$ec_line;
								$ec_number=~s/^.+\"\>//;
								$ec_number=~s/\<.+$//;
								if ($ec){$ec=$ec.";".$ec_number;}
								else{$ec=$ec_number;}
							}
						}
						else
						{
							if ($ec){$ec=$ec.";".$1;}
							else{$ec=$1;}
						}
					}
					
					#<a href="http://www.cazy.org/b3432.html"><b>Bacillus subtilis subsp. subtilis str. AG1839</b></a>
					if ($_=~/\<a\s+href\=\"http\:\/\/www\.cazy\.org\/.+\.html\"\>\<b\>(.+)\<\/b\>\<\/a\>/){$org=$1;}
					
					#<a href="http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=649539" target="ncbitaxid">alpha proteobacterium U95</a>
					#if ($_=~/\<a\s+href\=\"http\:\/\/www\.ncbi\.nlm\.nih\.gov\/Taxonomy\/Browser\/wwwtax\.cgi\?id\=\d+\"\s+target\=\"ncbitaxid\"\>(.+)\<\/\a\>/){$org=$1;}
					if ($_=~/\<a\s+href\=\"http\:\/\/www\.ncbi\.nlm\.nih\.gov\/Taxonomy\/Browser\/wwwtax\.cgi\?id\=\d+\"\s+target\=\"ncbitaxid\"\>(.+)\<\/a\>/){$org=$1;}
					
					#<td id="separateur2"><a href=http://www.ncbi.nlm.nih.gov/entrez/viewer.fcgi?db=protein&val=AIC42950.1 target=_link><b>AIC42950.1</b></a></td>
					#<td id="separateur2"><a href=http://www.ncbi.nlm.nih.gov/entrez/viewer.fcgi?db=protein&val=AAA72843.1 target=_link><b>AAA72843.1</b></a><br>AAE29896.1<br>AAK43121.1<br>ABC06397.1<br>ACW34039.1<br>CAC24042.1<br>CAJ18790.1<br>NP_344331.1</td>
					#<td id="separateur2"><a href=http://www.ncbi.nlm.nih.gov/entrez/viewer.fcgi?db=protein&val=CAB42305.1 target=_link><b>CAB42305.1</b></a><br>ABE26517.1<br>ABE26518.1<br>CAA03091.1</td>
					if ($_=~/\<a\s+href\=http\:\/\/www\.ncbi\.nlm\.nih\.gov\/entrez\/viewer\.fcgi\?db\=protein\&val=.+target\=\_link\>\<b\>(.+)\<\/td\>/)
					{
						if ($_=~/\<br\>/)
						{
							my @all_gbs=split(/\<br\>/,$_);
							foreach my $gb_id (@all_gbs)
							{
								#<td id="separateur2"><a href=http://www.ncbi.nlm.nih.gov/entrez/viewer.fcgi?db=protein&val=AAA72843.1 target=_link><b>AAA72843.1</b></a>
								#AAE29896.1
								#NP_344331.1</td>
								#<a href=http://www.ncbi.nlm.nih.gov/entrez/viewer.fcgi?db=protein&val=ABE85993.1 target=_link><b>ABE85993.1</b></a></td>
								if ($gb_id=~/\<\/td\>/){$gb_id=~s/\<\/td\>//;}
								if ($gb_id=~/\</)
								{
									$gb_id=~s/^.+\<b\>//;
									$gb_id=~s/\<\/b\>.+$//;
								}
								if ($gb){$gb=$gb.";".$gb_id;}
								else{$gb=$gb_id;}
							}
						}else
						{
							my $temp=$1;#<b>P09849</b> or D5TUP9
							$temp=~s/\<b\>//;
							$temp=~s/\<\/.+$//;
							if ($gb){$gb=$gb.";".$temp;}
							else{$gb=$temp;}
						}
					}
					
					#<td id="separateur2"><a href="http://www.uniprot.org/uniprot/D5TUP9" target="_link">D5TUP9</a></td>
					#<td id="separateur2"><a href="http://www.uniprot.org/uniprot/P09849" target="_link"><b>P09849</b></a></td>
					#<td id="separateur2"><a href="http://www.uniprot.org/uniprot/E7FHC0" target="_link">E7FHC0</a><br><a href="http://www.uniprot.org/uniprot/Q51733" target="_link">Q51733</a></td>
					#<td id="separateur2"><a href="http://www.uniprot.org/uniprot/P29736" target="_link"><b>P29736</b></a><br><a href="http://www.uniprot.org/uniprot/Q7SIB0" target="_link">Q7SIB0</a></td>
					if ($_=~/href\=\"http\:\/\/www\.uniprot\.org\/uniprot\/.+\"\s+target\=\"\_link\"\>(.+)\<\/td\>/)
					{
						if ($_=~/\<br\>/)
						{
							my @all_uniprots=split(/\<br\>/,$_);
							foreach my $uniprot_line (@all_uniprots)
							{
								$uniprot_line=~s/^.+\"\>//;
								$uniprot_line=~s/^\<b\>//;
								$uniprot_line=~s/\<\/.+$//;
								if ($uniprot){$uniprot=$uniprot.";".$uniprot_line;}
								else{$uniprot=$uniprot_line;}
							}
						}
						else
						{
							my $temp=$1;#<b>P09849</b> or D5TUP9
							$temp=~s/\<b\>//;
							$temp=~s/\<\/.+$//;
							if ($uniprot){$uniprot=$uniprot.";".$temp;}
							else{$uniprot=$temp;}
						}
					}
					
					
					#<td id="separateur2"><a href=http://www.rcsb.org/pdb/explore/explore.do?structureId=1CLV target=_link>1CLV[A]</a><br><a href=http://www.rcsb.org/pdb/explore/explore.do?structureId=1JAE target=_link>1JAE[A]</a><br><a href=http://www.rcsb.org/pdb/explore/explore.do?structureId=1TMQ target=_link>1TMQ[A]</a><br><a href=http://www.rcsb.org/pdb/explore/explore.do?structureId=1VIW target=_link>1VIW[A]</a> </td>
					if ($_=~/href\=http\:\/\/www\.rcsb\.org\/pdb\/explore\/explore\.do\?structureId\=.+\s+target\=\_link\>(.+)\<\/a\>/)
					{
						if ($_=~/\<br\>/)
						{
							my @all_pdbs=split(/\<br\>/,$_);
							foreach my $each_pdb (@all_pdbs)
							{
								$each_pdb=~s/^.+\_link\>//;
								$each_pdb=~s/\<\/.+$//;
								if ($pdb){$pdb=$pdb.";".$each_pdb;}
								else{$pdb=$each_pdb;}
							}
						}
						else
						{
							my $temp=$1;#<b>P09849</b> or D5TUP9
							$temp=~s/\<b\>//;
							$temp=~s/\<\/.+$//;
							$pdb=$temp;
						} # if no <br>, it means there is only one pdb id
					}
					
					#<td id="separateur2" align="center">24</td>
					if ($_=~/\<td\s+id\=\"separateur2\"\s+align\=\"center\"\>(\d+)\<\/td\>/){$sub=$1;}
				}
				print Out "$protname\t$ec\t$org\t$gb\t$uniprot\t$pdb\t$sub\t$html_file\n";
				close(HTML);
			}
		}
		closedir(CAZy);
		close(Out);
	}
}


