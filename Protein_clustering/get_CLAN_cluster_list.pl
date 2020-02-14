# October 4th 2017
# Get list of protein ids and cluster information from CLAN clusters

#! /usr/perl/bin -w
use strict;
use Getopt::Long;

my $CLAN_cluster_folder="";
my $fileout="";
my $folderout="";

GetOptions('CLAN_folder=s'=>\$CLAN_cluster_folder, 'outfile=s'=>\$fileout, 'outfolder=s'=>\$folderout);


mkdir $folderout;

open(Out,">$fileout") || die "Cannot open file $fileout";
print Out "#Cluster\tID\tDomain_location\n";
opendir(DIR,"$CLAN_cluster_folder") || die "Cannot open folder $CLAN_cluster_folder";
my @files=readdir(DIR);
closedir(DIR);

foreach my $file (@files)
{
	if (($file ne ".") and ($file ne ".."))
	{
		open(In,"<$CLAN_cluster_folder/$file") || die "Cannot open file $CLAN_cluster_folder/$file";
		open(FASTA_Out,">$folderout/$file") || die "Cannot open file $folderout/$file";
		my $cluster=$file;
		$cluster=~s/\_muscle\_edited\_nogap\.fasta//;
		$cluster=~s/^.+\_//;
		$cluster="C".$cluster;
		my $id_line="";
		my $seq="";
		while (<In>)
		{
			$_=~s/\s*$//;
			if ($_=~/^\>/)
			{
				if ($seq)
				{
					my $newid=$cluster."|".$id_line;
					print FASTA_Out ">$newid\n$seq\n";
					$id_line="";
					$seq="";
				}
				$id_line=$_;
				$id_line=~s/^\>//;
				$id_line=~s/\s+\d+$//;

				my @id_domain=split(/\|/,$id_line);
				my $domain_loc=pop(@id_domain);
				$domain_loc=~s/\-/../;
				print Out "$cluster\t$id_line\t$domain_loc\n";
			}else{$_=~s/\s*$//;$seq=$seq.$_;}
		}
		my $newid=$cluster."|".$id_line;
		print FASTA_Out ">$newid\n$seq\n";
		close(In);
		close(FASTA_Out);
	}
}

close(Out);