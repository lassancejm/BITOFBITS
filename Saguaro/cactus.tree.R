#! /usr/bin/Rscript
library(phangorn, quietly=TRUE)
args = commandArgs(TRUE)
data=as.matrix(read.table(args[1], header = TRUE, row.names = 1))
tree_upgma=upgma(as.dist(data))
write.tree(tree_upgma, file=args[2])
cairo_pdf(file=args[3])
plot(tree_upgma)
dev.off()
