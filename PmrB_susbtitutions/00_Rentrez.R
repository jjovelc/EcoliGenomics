
library(XML)
library(rentrez)

res <- entrez_search("assembly", "Escherichia coli[ORGN]", retmax = 250000, use_history = TRUE)


randoms_ids <- sample(res$ids, 10000, replace = F)
randoms_ids

write.table(randoms_ids, "ecoli_assembly_ftp_links.txt")


random_ids <- sample(res$ids, 15000, replace = F)

write.table(random_ids, "ecoli_assembly_ids.txt", rownames=F)
