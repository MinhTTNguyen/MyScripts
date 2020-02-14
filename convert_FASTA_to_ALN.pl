=pod
July 14th 2015
This script is to automatically convert fasta files into .aln files (clustal format)
=cut

#! /usr/perl/bin -w
use strict;
use Getopt::Long;
use Bio::AlignIO;

my $folder_fasta;
my $folder_aln;

GetOptions('folderin=s'=>\$folder_fasta, 'folderout=s'=>\$folder_aln);

mkdir "$folder_aln";
opendir(FASTA,"$folder_fasta") || die "Cannot open folder $folder_fasta";
my @fasta_files=readdir(FASTA);

foreach my $fasta_file (@fasta_files)
{
	if (($fasta_file eq ".") || ($fasta_file eq "..")){next;}
	my $fileout=$fasta_file;
	$fileout=~s/\.fasta.*//;
	$fileout=~s/^sub/C/;
	$fileout=$fileout.".doc";
	open(IN,"<$folder_fasta/$fasta_file") || die "Cannot open file $folder_fasta/$fasta_file";
	open(OUT,">$folder_aln/$fileout") || die "Cannot open file $folder_aln/$fileout";
	my $in=Bio::AlignIO -> new(-fh => \*IN, -format => 'fasta');
	my $out=Bio::AlignIO -> new(-fh => \*OUT, -format => 'clustalw');
	while (my $aln=$in->next_aln)
	{
		$out->write_aln($aln);
	}
	close(IN);
	close(OUT);
}
closedir(FASTA);
