#!/usr/bin/perl -w
use strict;
use CGI qw/:standard/;

my $transcriptome_data_path="/mnt/fpkm";
my $predicted_cds_folder="predicted_cds";

my $upload_dir="/mnt/fpkm/Upload_files";
my $upload_filehandle=upload("upload_Id_file");
my $filename=param("upload_Id_file");


############ Saving the uploaded file into $upload_dir ############
open(UPLOADFILE,">$upload_dir/$filename") || die "$!";
binmode UPLOADFILE;
while (<$upload_filehandle>){print UPLOADFILE;}
close(UPLOADFILE);
############ Saving the uploaded file into $upload_dir ############



############ read content of uploaded file to get selected IDs ############
open(Selected_IDs,"<$upload_dir/$filename") || die "Cannot open file $filename";
my @selected_IDs;
my $id_count=0;
while(<Selected_IDs>)
{
	$_=~s/^\s*//g;
	$_=~s/\s*$//g;
	$selected_IDs[$id_count]=$_;
	$id_count++;
}
my $species_name=$selected_IDs[0];
if ($species_name=~/(.+)\_\d+/){$species_name=$1;}
else{print "Error: gene Id is not as described!\nGene ID: $species_name\n";exit;}
close(Selected_IDs);
############ read content of uploaded file to get selected IDs ############




############ read cds sequences of selected species ############
opendir(CDs_DIR,"$transcriptome_data_path/$predicted_cds_folder") || die "Cannot open folder CDs_DIR";
my @cds_files=readdir(CDs_DIR);
@cds_files=sort(@cds_files);
shift(@cds_files);shift(@cds_files);
my $selected_file="";
foreach my $cds_file (@cds_files)
{
	if ($cds_file=~/$species_name/){$selected_file=$cds_file;}
}
closedir(CDs_DIR);
############ read cds sequences of selected species ############




############ create hash containing cds sequences ############
open(Fasta_file,"<$transcriptome_data_path/$predicted_cds_folder/$selected_file") || die "Cannot open file Fasta_file";
my %fasta;
my $fasta_key="";
my $seq="";

while (<Fasta_file>)
{
	my $fasta_line=$_;
	chomp($fasta_line);
	if ($fasta_line=~/^\>/)
	{
		if ($seq)
		{
			$seq=~s/\s*//g;	
			$seq=uc($seq);
			$fasta{$fasta_key}=$seq;
			$seq="";
			$fasta_key="";
		}
		$fasta_key=$fasta_line;
		$fasta_key=~s/\>//;
		#$fasta_key=~s/\s*//g;
		$fasta_key=~s/^\s*//g;
		$fasta_key=~s/\s*$//g;
	}else{$seq=$seq.$fasta_line;}
}
$seq=~s/\s*//g;
$seq=uc($seq);
$fasta{$fasta_key}=$seq;
close (Fasta_file);
############ create hash containing cds sequences ############


print ("Content-Type:application/x-download\n");
my $downloaded_file=substr($filename,0,-3);
$downloaded_file=$downloaded_file."fasta";
print "Content-Disposition: attachment; filename=$downloaded_file\n\n";
foreach my $selected_id (@selected_IDs)
{
	print ">$selected_id\n";
	print "$fasta{$selected_id}\n";
}
unlink "$upload_dir/$filename";