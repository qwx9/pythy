library(jsonlite)
library(doParallel)
library(reticulate)

f <- list.files(pattern="\\.json")
#nc <- detectCores()
nc <- 8
i <- splitIndices(length(f), nc)
fi <- sapply(i, function(i) f[i])

trk <- unlist(read.delim("names.txt", header=FALSE))
names(trk) <- NULL

cl <- makeCluster(nc)
registerDoParallel(cl)
v <- foreach(f=fi, n=seq_along(i), .inorder=FALSE, .packages=c("jsonlite", "reticulate")) %dopar% {
	ss <- import("scipy")$sparse
	v <- NULL
	for(i in f){
		d <- fromJSON(i)
		d <- sapply(d$playlists$tracks[1:500], function(x) as.numeric(trk %in% x$track_uri))
		d <- d[,apply(d, 2, sum) > 5]
		gc()
		d <- t(d)
		gc()
		d <- ss$csr_matrix(d)
		gc()
		if(is.null(v)){
			v <- d
		}else{
			v <- rbind(v, d)
		}
		save(d, file=sub("json", "RData", i))
	}
	ss$save_npz(paste0("mat", n, ".npz"), v)
	v
}
save(v, file="mat.RData")
stopCluster(cl)

#v <- lapply(1:nc, function(i) ss$load_npz(paste0("res/mat", i, ".npz")))
mat <- do.call(rbind, v)
save(mat, file="matc.RData")
ss$save_npz("mat.npz", mat)
