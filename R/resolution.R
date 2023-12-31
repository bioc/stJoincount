#' Resolution calculation
#'
#' Automatic calculation of optimal raster resolution for the sample.
#'
#' @importFrom stats median
#' @importFrom graphics boxplot
#' @export
#'
#' @param sampleInfo A data.frame contains the pixel information and cluster labels for each barcode of a human breast cancer sample.
#' The index contains barcodes, and at least three other columns that have these information are required and the column names should be the same as following:
#' "imagerow": The row pixel coordinate of the center of the spot
#' "imagecol": The column pixel coordinate of the center of the spot
#' "Cluster": The label that corresponding to this barcode
#'
#' @return A list that contains length and height of resolution.
#'
#' @examples
#' fpath <- system.file("extdata", "dataframe.rda", package="stJoincount")
#' load(fpath)
#' resolutionList <- resolutionCalc(humanBC)

resolutionCalc <- function(sampleInfo){
  sampleCoord <- sampleInfo
  sampleCoord$int.row <- as.integer(sampleCoord$imagerow)
  sampleCoord$int.col <- as.integer(sampleCoord$imagecol)

  diffCol <- list()
  diffRow <- list()

  for (i in seq_len(nrow(sampleCoord))){
    a <- sampleCoord$int.row[i]
    targetCol <- subset(sampleCoord, int.row == a)[order(subset(sampleCoord, int.row == a)$imagecol),]
    subtractCol <- diff(as.matrix(targetCol$imagecol))
    outliersA <- boxplot(subtractCol, plot=FALSE)$out
    if (length(outliersA) > 0){
      subtractCol <- subtractCol[-which(subtractCol %in% outliersA),]
      differenceInCol <- mean(subtractCol)/2
    } else {
      differenceInCol <- mean(subtractCol)/2
    }
    diffCol <- c(diffCol, differenceInCol)

    b <- sampleCoord$int.col[i]
    targetRow <- subset(sampleCoord, int.col == b)[order(subset(sampleCoord, int.col == b)$imagerow),]
    subtractRow <- diff(as.matrix(targetRow$imagerow))
    outliersB <- boxplot(subtractRow, plot=FALSE)$out
    if (length(outliersB) > 0){
      subtractRow <- subtractRow[-which(subtractRow %in% outliersB),]
      differenceInRow <- mean(subtractRow)
    } else {
      differenceInRow <- mean(subtractRow)
    }
    diffRow <- c(diffRow, differenceInRow )
  }

  X <- lapply(diffRow, function(x) x[!is.na(x)])
  X <- median(unlist(X))
  Y <- lapply(diffCol, function(x) x[!is.na(x)])
  Y <- median(unlist(Y))

  # checking the orientation
  if (abs(X-Y) < 2){
    X <- X/2
    Y <- Y*2
  }

  return(c(X, Y))
}
