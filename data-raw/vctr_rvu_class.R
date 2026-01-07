wrvu = 6.26 # Work RVU
wgpci = 1 # Work GPCI

pgpci = 0.883 # Practice GPCI
prvu = 4.36 # Practice RVU

mrvu = 0.99 # Malpractice RVU
mgpci = 1.125 # Malpractice GPCI

cf = 32.744 # Conversion Factor

rvu <- c(w = 6.26, p = 4.36, m = 0.99)
gpci <- c(w = 1, p = 0.883, m = 1.125)
cf <- 32.744

total <- function(rvu, gpci, cf) {
  sum(rvu * gpci) * cf
}

infix <- function(rvu, gpci, cf) {
  as.vector(rvu %*% gpci * cf)
}

x <- bench::mark(
  total = total(c(6.26, 4.36, 0.99), c(1, 0.883, 1.125), 32.744),
  infix = infix(c(6.26, 4.36, 0.99), c(1, 0.883, 1.125), 32.744),
  iterations = 50000,
  relative = TRUE
)

summary(x)

ggplot2::autoplot(x, "jitter")
ggplot2::autoplot(x, "beeswarm")
ggplot2::autoplot(x, "ridge")

dout <- function(rvu, gpci, cf) {
  sum(diag(outer(rvu, gpci), names = FALSE)) * cf
}

dross <- function(rvu, gpci, cf) {
  drop(crossprod(rvu, gpci) * cf)
}

library(vctrs)
library(zeallot)
library(collapse)

vctr_rvu <- get_pin("vctr_rvu")

x <- vctr_rvu[1:5, c("w", "m", "p")]

x$p[1] <- NA_real_

x

new_rvu <- function(w = double(), p = double(), m = double()) {
  if (!is.double(w)) {
    cli::cli_abort("{.var w} must be a {.cls double} vector.")
  }
  if (!is.double(p)) {
    cli::cli_abort("{.var p} must be a {.cls double} vector.")
  }
  if (!is.double(m)) {
    cli::cli_abort("{.var m} must be a {.cls double} vector.")
  }
  vctrs::new_rcrd(list(w = w, p = p, m = m), class = "rvu")
}

rvu <- function(w = double(), p = double(), m = double()) {
  c(w, p, m) %<-% vctrs::vec_cast_common(w, p, m, .to = double())
  c(w, p, m) %<-% vctrs::vec_recycle_common(w, p, m)
  new_rvu(w, p, m)
}

x <- rvu(w = x$w, p = x$p, m = x$m)

# purrr::map(x, \(x) rvu(x$w, x$m, x$p))

format.rvu <- function(x, ...) {
  # o <- list(
  #   w = vctrs::field(x, "w"),
  #   p = vctrs::field(x, "p"),
  #   m = vctrs::field(x, "m")
  # )
  w <- vctrs::field(x, "w")
  p <- vctrs::field(x, "p")
  m <- vctrs::field(x, "m")
  out <- as.character(glue::glue("[{w}, ", "{p}, ", "{m}]"))
  out[is.na(w) | is.na(p) | is.na(m)] <- NA
  out
}

vec_ptype_abbr.rvu <- function(x, ...) "rvu"
vec_ptype_full.rvu <- function(x, ...) "rvu"

str(x)

vec_ptype2.rvu.rvu <- function(x, y, ...) new_rvu()
vec_ptype2.rvu.integer <- function(x, y, ...) new_rvu()
vec_ptype2.integer.rvu <- function(x, y, ...) new_rvu()

vec_ptype_show(rvu(), integer(), rvu())

vec_cast.rvu.rvu <- function(x, to, ...) x
vec_cast.double.rvu <- function(x, to, ...) vec_data(x)
vec_cast.rvu.integer <- function(x, to, ...) rvu(x, 1)

vec_c(rvu(1, 2, 3), 1L, NA)
