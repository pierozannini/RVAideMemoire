prop.multinom <- function(x) {
  if (is.data.frame(x)) {
    x <- as.matrix(x)
  }
  if (is.matrix(x)) {
    if (!is.numeric(x)) {stop("incorrect 'x' format")}
    if (is.null(colnames(x))) {colnames(x) <- LETTERS[1:ncol(x)]}
    lab <- colnames(x)
  } else if (is.factor(x) | is.character(x)) {
    x <- as.factor(x)
    lab <- levels(x)
  } else {stop("incorrect 'x' format")}
  prop <- std.err <- integer(length(lab))
  names(prop) <- names(std.err) <- lab
  if (is.matrix(x)) {
    for (i in 1:length(lab)) {
	In <- x[,i]
	Out <- if (ncol(x)>2) {
	  if (nrow(x)==1) {
	    sum(x[,-i])
	  } else {
	    rowSums(x[,-i])
	  }
	} else {
	  if (nrow(x)==1) {
	    x[,-i]
	  } else {
	    t(t(x[,-i]))
	  }
	}
	mod <- glm(cbind(In,Out)~1,family="quasibinomial")
	pred <- predict(mod,type="response",se.fit=TRUE)
	prop[i] <- unique(pred$fit)
	std.err[i] <- if (nrow(x)>1) {unique(pred$se.fit)} else {se(In,In+Out)}
    }
  } else {
    for (i in 1:length(lab)) {
	x2 <- relevel(factor(ifelse(as.numeric(x)==i,lab[i],"Other")),ref="Other")
	mod <- glm(x2~1,family="quasibinomial")
	pred <- predict(mod,type="response",se.fit=TRUE)
	prop[i] <- unique(pred$fit)
	std.err[i] <- unique(pred$se.fit)
    }
  }
  res <- list(probs=prop,se=std.err)
  return(res)
}
