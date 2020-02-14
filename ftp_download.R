library(curl)
url <- "ftp://ftp.wipo.int/pub/published_pct_sequences/publication/"
h <- new_handle(dirlistonly=TRUE)
con <- curl(url, "r", h)
folders_year = read.table(con, stringsAsFactors=TRUE, fill=TRUE)
close(con)

for (folder in folders_year[,1]){
  url_year <- paste(url,folder,sep="")
  url_year <- paste(url_year,"/",sep="")
  head(url_year)
  h <- new_handle(dirlistonly=TRUE)
  con <- curl(url=url_year,open="r",handle=h)
  folders_dates <-  read.table(con, stringsAsFactors=TRUE, fill=TRUE)
  break
}




