kegga.DGELRT <- function(de, geneid = rownames(de), FDR = 0.05, trend = FALSE, ...)
#	KEGG analysis of DE genes from linear model fit
#	Gordon Smyth
#	Created 4 June 2015.  Last modified 4 June 2015.
{
#	Avoid argument collision with default method
	dots <- names(list(...))
	if("universe" %in% dots) stop("kegga.DGELRT defines its own universe",call.=FALSE)
	if((!is.logical(trend) || trend) && "covariate" %in% dots) stop("kegga.DGELRT defines it own covariate",call.=FALSE)
	ngenes <- nrow(de)

#	Check geneid
#	Can be either a vector of gene IDs or an annotation column name
	geneid <- as.character(geneid)
	if(length(geneid) == ngenes) {
		universe <- geneid
	} else {
		if(length(geneid) == 1L) {
			universe <- de$genes[[geneid]]
			if(is.null(universe)) stop("Column ",geneid," not found in de$genes")
		} else
			stop("geneid of incorrect length")
	}

#	Check trend
#	Can be logical, or a numeric vector of covariate values, or the name of the column containing the covariate values
	if(is.logical(trend)) {
		if(trend) {
			covariate <- de$table$logCPM
			if(is.null(covariate)) stop("logCPM not found in fit object")
		}
	} else {
		if(is.numeric(trend)) {
			if(length(trend) != ngenes) stop("If trend is numeric, then length must equal nrow(de)")
			covariate <- trend
			trend <- TRUE
		} else {
			if(is.character(trend)) {
				if(length(trend) != 1L) stop("If trend is character, then length must be 1")
				covariate <- de$genes[[trend]]
				if(is.null(covariate)) stop("Column ",trend," not found in de$genes")
				trend <- TRUE
			} else
				stop("trend is neither logical, numeric nor character")
		}
	}

#	Check FDR
	if(!is.numeric(FDR) | length(FDR) != 1) stop("FDR must be numeric and of length 1.")
	if(FDR < 0 | FDR > 1) stop("FDR should be between 0 and 1.")

#	Get up and down DE genes
	fdr.coef <- p.adjust(de$table$PValue, method = "BH")
	EG.DE.UP <- universe[fdr.coef < FDR & de$table$logFC > 0]
	EG.DE.DN <- universe[fdr.coef < FDR & de$table$logFC < 0]
	DEGenes <- list(Up=EG.DE.UP, Down=EG.DE.DN)

#	If no DE genes, return data.frame with 0 rows
	if(length(EG.DE.UP)==0 && length(EG.DE.DN)==0) {
		message("No DE genes")
		return(data.frame())
	}

	if(trend)
		kegga(de=DEGenes, universe = universe, covariate=covariate, ...)
	else
		kegga(de=DEGenes, universe = universe, ...)
}


kegga.DGEExact <- kegga.DGELRT
