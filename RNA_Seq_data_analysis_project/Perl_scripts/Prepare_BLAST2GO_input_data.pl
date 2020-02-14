#!/usr/bin/perl -w
use strict;
use CGI qw/:standard/; 

print header,
      start_html(-title => 'Prepare data for running BLAST2GO'),
      h1({-style=>'Background: PaleTurquoise;height:30px;',-align => "left"}, font({-size => 3, -color => "black", -face => "Arial"},"Prepare input data for running BLAST2GO"));
print a({href=>"http://www.blast2go.com/b2ghome"},"BLAST2GO");
print "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp";
print a({href=>"http://blast.ncbi.nlm.nih.gov/Blast.cgi?PROGRAM=blastx&PAGE_TYPE=BlastSearch&LINK_LOC=blasthome"},"BLASTX");
print "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp";
print a({href=>"Automatic_RNA_seq_analysis_tool_home.pl"},"RNA-Seq data analysis home page");

print start_form (-name => "Upload_gene_IDs", -method => "post", -action=>"Prepare_BLAST2GO_input_data_download_cds_seqs.pl"),
      h1(font({-face => "Arial", -size => 3, -color =>"Red"},"Download transcript sequences")),
      b(font({-face => "Arial", -size => 2},"Upload file containing IDs of selected genes:")),
      "&nbsp&nbsp&nbsp&nbsp&nbsp",
      font({-color=>"grey"},em("(*** Each gene ID is in one line)")),
      #br,br,
      "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp",
      filefield(-name => 'upload_Id_file'),
      br,br,
      submit(-name => "Download"),
      br,br,hr,
      end_form;
print end_html;