path="//CSFG-FS3/UserProfiles/tnguy/Research/Symbiomics/AA3/AA3_2/AA3_2_manuscript/MycoCLAP_CSFG/dbCANv6_CSFG"
folderout="//CSFG-FS3/UserProfiles/tnguy/Research/Symbiomics/AA3/AA3_2/AA3_2_manuscript/MycoCLAP_CSFG/dbCANv6_CSFG_domain_sorted"

setwd(path)
files <- list.files(path=".",all.files=FALSE,full.names=FALSE,no..=TRUE)
total_file_number=length(files)
for (i in seq(from=1,to=total_file_number,by=1))
{  
  hmmscan_table=read.csv(file=files[i],header=TRUE,sep="\t")
  
  check_table <- is.data.frame(hmmscan_table)
  sorted_table <- hmmscan_table[order(hmmscan_table$Seq_id,hmmscan_table$Domain_from,hmmscan_table$Domain_to),]
  
  fileout=paste(folderout,files[i],sep='/')
  write.table (sorted_table,file=fileout,sep="\t",append=FALSE,row.names=FALSE,quote=FALSE)
}
