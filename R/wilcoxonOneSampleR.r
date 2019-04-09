#' @title r effect size for Wilcoxon one-sample signed-rank test
#' 
#' @description Calculates r effect size
#'              for a Wilcoxon one-sample signed-rank test; 
#'              confidence intervals by bootstrap.
#' 
#' @param x A vector of observations of an ordinal variable.
#' @param mu The value to compare \code{x} to, as in \code{wilcox.test}
#' @param ci If \code{TRUE}, returns confidence intervals by bootstrap.
#'           May be slow.
#' @param conf The level for the confidence interval.
#' @param type The type of confidence interval to use.
#'             Can be any of "\code{norm}", "\code{basic}", 
#'                           "\code{perc}", or "\code{bca}".
#'             Passed to \code{boot.ci}.
#' @param R The number of replications to use for bootstrap.
#' @param histogram If \code{TRUE}, produces a histogram of bootstrapped values.

#' @param digits The number of significant digits in the output.
#' @param ... Additional arguments passed to the \code{wilcoxsign_test} function.             
#' 
#' @details  A Z value is extracted from the \code{wilcoxsign_test} function in the
#'           coin package.  r  is calculated as Z divided by 
#'           square root of the number of observations.
#'           
#'           The calculated statistic is equivalent to the statistic returned
#'           by the \code{wilcoxPairedR} function with one group equal
#'           to a vector of \code{mu}.
#'           The author knows of no reference for this technique.
#'           
#'           Currently, the function makes no provisions for \code{NA}
#'           values in the data.  It is recommended that \code{NA}s be removed
#'           beforehand.
#'           
#'           When r is close to 0 or very large,
#'           or with small counts in some cells,
#'           the confidence intervals 
#'           determined by this
#'           method may not be reliable, or the procedure may fail.
#'           
#' @author Salvatore Mangiafico, \email{mangiafico@njaes.rutgers.edu}
#' @references \url{http://rcompanion.org/handbook/F_02.html}
#' @concept effect size ordinal nominal
#' @return A single statistic, r.
#'         Or a small data frame consisting of r,
#'         and the lower and upper confidence limits.  
#'         
#' @examples
#' data(Pooh)
#' Data = Pooh[Pooh$Time==2,]
#' wilcox.test(Data$Likert, mu=3, exact=FALSE)
#' wilcoxonOneSampleR(x = Data$Likert, mu=3)
#' 
#' @importFrom coin wilcoxsign_test
#' @importFrom boot boot boot.ci
#' 
#' @export
 
wilcoxonOneSampleR = function (x, mu=NULL, ci=FALSE, conf=0.95, type="perc",
                      R=1000, histogram=FALSE, digits=3, ... ){

  n  =length(x)
  MU = rep(mu, n)
  WT = suppressWarnings(wilcoxsign_test(x ~ MU, ...))
  Z  = as.numeric(statistic(WT, type="standardized"))
  r  = abs(Z)/sqrt(n)
  RR = signif(r, digits=digits)
  
if(ci==TRUE){
  Data = data.frame(x, MU)
  Function = function(input, index){
                    Input = input[index,]
                    n  = length(Input$x)
                    WT = suppressWarnings(wilcoxsign_test(x ~ MU, 
                         data=Input, ...))
                    Z  = as.numeric(statistic(WT, type="standardized"))
                    r  = abs(Z)/sqrt(n)
                    return(r)}
  Boot = boot(Data, Function, R=R)
  BCI  = boot.ci(Boot, conf=conf, type=type)
  if(type=="norm") {CI1=BCI$normal[2];  CI2=BCI$normal[3];}
  if(type=="basic"){CI1=BCI$basic[4];   CI2=BCI$basic[5];}
  if(type=="perc") {CI1=BCI$percent[4]; CI2=BCI$percent[5];}
  if(type=="bca") {CI1=BCI$bca[4];      CI2=BCI$bca[5];}  
  
  CI1=signif(CI1, digits=digits)
  CI2=signif(CI2, digits=digits)
  
  if(histogram==TRUE){hist(Boot$t[,1], col = "darkgray")}
  
}
  
if(ci==FALSE){names(RR)="r"; return(RR)}
if(ci==TRUE){return(data.frame(r=RR, lower.ci=CI1, upper.ci=CI2))}  
  
}  

