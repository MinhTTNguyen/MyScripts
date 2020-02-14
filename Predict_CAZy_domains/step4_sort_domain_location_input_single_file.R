filein=""
fileout=""

hmmscan_table=read.csv(file=filein,header=TRUE,sep="\t")
check_table <- is.data.frame(hmmscan_table)
sorted_table <- hmmscan_table[order(hmmscan_table$Seq_id,hmmscan_table$Domain_from,hmmscan_table$Domain_to),]
write.table (sorted_table,file=fileout,sep="\t",append=FALSE,row.names=FALSE,quote=FALSE)

