# Friday, October 25th 2019
# Read and extract information of patented proteins from GenPept file

#! /usr/perl/bin -w
use strict;
use Getopt::Long;
use Bio::SeqIO;
use Bio::Species;


my $filein="";
my $fileout="";
my $format="";
my $filein_ID="";

GetOptions('in=s'=>\$filein, 'out=s'=>\$fileout, 'format=s'=>\$format, 'id_list=s'=>\$filein_ID);

open(IDs,"<$filein_ID") || die "Cannot open file $filein_ID";
my %hash_ids;
while (<IDs>)
{
	$_=~s/\s*$//;
	$hash_ids{$_}++;
}
close(IDs);
my @all_ids=keys(%hash_ids);
my $id_counts=scalar(@all_ids);

open(Out,">$fileout") || die "Cannot open file  $fileout";
print Out "#Accession\tReference_title\tReference_location\tAuthors\tDesciption\tSpecies\tProtein_length\tSequence\n";
my $count=0;
my $seqio_obj = Bio::SeqIO -> new (-file => "$filein",
								 -format => "$format"); #genbank
while (my $seq_obj = $seqio_obj->next_seq)
{
	my $protein_seq=$seq_obj ->seq;
	my $accession_number=$seq_obj ->accession_number;
	my $desc=$seq_obj->desc;
	my $seq_len=$seq_obj->length;
	my $species_obj=$seq_obj->species;
	my $species=$species_obj->node_name;
	my $annotation_collection_obj=$seq_obj->annotation;
	my $reference_title="";
	my $authors="";
	my $reference_location="";
	for my $key ($annotation_collection_obj->get_all_annotation_keys)
	{
		my @annotations = $annotation_collection_obj->get_Annotations($key);
		for my $value (@annotations)
		{	
			if ($value -> tagname eq "reference")
			{
				$reference_title=$value->title();
				$reference_location=$value->location();
				$authors=$value->authors();
			}
		}
	}
	if ($hash_ids{$accession_number})
	{
		print Out "$accession_number\t$reference_title\t$reference_location\t$authors\t$desc\t$species\t$seq_len\t$protein_seq\n";
		$count++;
		if ($count==$id_counts){exit;}
	}
}
close(Out);