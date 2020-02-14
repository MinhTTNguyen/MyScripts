#! /usr/perl/bin -w
# can be used for both JGI and CSFG genomes
use strict;
use Getopt::Long;


my $filein="";
my $fileout="";
my $folderin="";
GetOptions('filein=s'=>\$filein, 'fileout=s'=>\$fileout, 'fasta_folder=s'=>\$folderin);


open(Out,">$fileout") || die "Cannot open file $fileout";
open(In,"<$filein") || die "Cannot open file $filein";
my %hash_fasta;
my %hash_protid;
while (<In>)
{
	$_=~s/\s*$//;
	if ($_!~/^\#/)
	{
		my @cols=split(/\t/,$_);
		shift(@cols); # in case the first column is the domain name
		my $species=$cols[0];
		
		my $protid=$cols[1];
		$protid=~s/\s+.*$//;
		
		if ($protid=~/^jgi/)
		{
			my @temps=split(/\|/,$protid);
			$protid=$temps[0]."|".$temps[1]."|".$temps[2];
			$species=$temps[1];
		}
	
		
		my $fasta_file=$species.".fasta";
		$fasta_file=~s/\.dbCAN.+//;
		$fasta_file=~s/\.txt.*//;

		unless ($fasta_file=~/\.fasta$/)
		{
			unless ($fasta_file=~/\.faa$/)
			{
				$fasta_file=$fasta_file.".fasta";
			}
		}
		$hash_fasta{$fasta_file}++;
		$hash_protid{$protid}++;
	}
}
close(In);

my @fasta_files=keys(%hash_fasta);
foreach my $fasta_file (@fasta_files)
{
	print "\n$fasta_file\n";
	open(FASTA,"<$folderin/$fasta_file") || die "Cannot open file $folderin/$fasta_file";
	my $id="";
	my $seq="";
	while (<FASTA>)
	{
		$_=~s/\s*$//;
		if ($_=~/^\>/)
		{
			if ($seq)
			{
				if ($hash_protid{$id}){print Out ">$id\n$seq\n";delete($hash_protid{$id});}
				$seq="";$id="";
			}
			$id=$_;
			$id=~s/^\>//;
			$id=~s/\s+.*$//;
			if ($id=~/^jgi/)
			{
				my @temps=split(/\|/,$id);
				$id=$temps[0]."|".$temps[1]."|".$temps[2];
			}
			#print "\n-$id-\n";exit;
		}
		else{$_=~s/\s*//g;$seq=$seq.$_;}
	}
	close(FASTA);
	if ($hash_protid{$id}){print Out ">$id\n$seq\n";delete($hash_protid{$id});}
}

close(Out);

my @ids_noseq=keys(%hash_protid);
my $number_noseq=scalar(@ids_noseq);
if ($number_noseq>0)
{
	print "\nNumber of ids not having sequences: $number_noseq\n";
	foreach my $each_id_noseq(@ids_noseq){print "$each_id_noseq\n";}
}
