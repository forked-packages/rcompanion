#' @title Pairwise sign tests for paired data
#'
#' @description Conducts pairwise sign tests across groups
#'              for paired data.
#' 
#' @param x      The response variable as a vector.
#' @param g      The grouping variable as a vector.
#' @param method The p-value adjustment method to use for multiple tests.
#'               See \code{\link{p.adjust}}.
#' @param ...    Additional arguments passed to
#'               \code{\link{SIGN.test}}.               
#'             
#' @details The two sample paired sign test compares medians 
#'          among two groups with paired data.
#'          See \url{http://rcompanion.org/handbook/F_07.html} for
#'          futher discussion of this test.
#' 
#'          The \code{pairwiseSignTest} function
#'          can be used as a post-hoc method following an omnibus
#'          Friedman test.
#'          
#'          The function assumes that the data frame is already ordered by
#'          the blocking variable, so that the first observation of Group 1
#'          is paired with the first observation of Group 2, and so on.                                                                                              
#'           
#' @author Salvatore Mangiafico, \email{mangiafico@njaes.rutgers.edu}
#' @references \url{http://rcompanion.org/handbook/F_10.html}
#' @seealso \code{\link{pairwiseSignMatrix}}
#' @concept median nonparametric post-hoc paired Friedman unreplicated
#' @return A dataframe of the groups being compared, the p-values,
#'         and the adjusted p-values. 
#'         
#' @examples
#' data(BobBelcher)
#' BobBelcher = BobBelcher[order(BobBelcher$Instructor, BobBelcher$Rater),]
#' friedman.test(Likert ~ Instructor | Rater,
#'               data = BobBelcher)
#' BobBelcher = BobBelcher[order(factor(BobBelcher$Instructor, 
#'                         levels=c("Linda Belcher", "Louise Belcher",
#'                                  "Tina Belcher", "Bob Belcher",
#'                                  "Gene Belcher"))),] 
#' pairwiseSignTest(x      = BobBelcher$Likert,
#'                  g      = BobBelcher$Instructor,
#'                  method = "fdr")
#' 
#' @importFrom stats p.adjust
#' @importFrom BSDA SIGN.test
#' 
#' @export


pairwiseSignTest = 
  function(x, g, method = "fdr", ...)
  {
  n = length(unique(g))
  N = n*(n-1)/2
  d = data.frame(x = x, g = g)
  Z = data.frame(Comparison=rep("A", N),
                 S=rep(NA, N),
                 p.value=rep(NA, N),
                 p.adjust=rep(NA, N),
                 stringsAsFactors=FALSE)                 
  k=0               
  for(i in 1:(n-1)){
     for(j in (i+1):n){
       k=k+1
     Namea = as.character(unique(g)[i])
     Nameb = as.character(unique(g)[j])
     Datax = subset(d, g==unique(g)[i])
     Datay = subset(d, g==unique(g)[j])
     z = SIGN.test(Datax$x, Datay$x, conf.level=1, ...)
     P = signif(z$p.value, digits=4)
     S = signif(z$statistic, digits=4)
     P.adjust = NA                       
     Z[k,] =c( paste0(Namea, " - ", Nameb, " = 0"), 
             S, P, P.adjust)
     }
    } 
  Z$p.adjust = signif(p.adjust(Z$p.value, method = method), digits=4) 
  return(Z)
  }