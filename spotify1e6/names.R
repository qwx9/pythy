library(jsonlite)
library(doParallel)

f <- list.files(pattern="\\.json")

nc <- detectCores()
i <- splitIndices(length(f), nc)
fi <- sapply(i, function(i) f[i])

cl <- makeCluster(nc)
registerDoParallel(cl)
trk <- foreach(f=fi, .inorder=FALSE, .packages=c("jsonlite")) %dopar% {
	trk <- lapply(f, function(f){
		d <- fromJSON(f)
		lapply(d$playlists$tracks, function(x) x$track_uri)
	})
	trk <- table(unlist(trk))
	names(trk[trk > quantile(trk, probs=0.05)])
	# slows the rest down
	#sub("spotify:track:", "", names(trk[trk > quantile(trk, probs=0.05)]))
}
trk <- unique(unlist(trk))
write.table(trk, file="names.txt", quote=FALSE, row.names=FALSE, col.names=FALSE)
stopCluster(cl)
