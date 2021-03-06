.runThisTest <- Sys.getenv("RunAllsjstatsTests") == "yes"

if (.runThisTest && Sys.getenv("USER") != "travis") {

  if (suppressWarnings(
    require("testthat") &&
    require("sjstats") &&
    require("brms")
  )) {
    context("sjstats, brms-resp_var")

    data("epilepsy")
    data(efc)

    bprior1 <- prior(student_t(5,0,10), class = b) + prior(cauchy(0,2), class = sd)

    m1 <- brm(
      count ~ Age + Base * Trt + (1|patient),
      data = epilepsy,
      family = poisson(),
      prior = bprior1,
      chains = 1,
      iter = 500
    )

    f1 <- bf(neg_c_7 ~ e42dep + c12hour + c172code)
    f2 <- bf(c12hour ~ c172code)
    m2 <- brm(f1 + f2 + set_rescor(FALSE), data = efc, chains = 1, iter = 500)

    dat <- read.table(header = TRUE, text = "
      n r r/n group treat c2 c1 w
      62 3 0.048387097 1 0 0.1438 1.941115288 1.941115288
      96 1 0.010416667 1 0 0.237 1.186583128 1.186583128
      17 0 0 0 0 0.2774 1.159882668 3.159882668
      41 2 0.048780488 1 0 0.2774 1.159882668 3.159882668
      212 170 0.801886792 0 0 0.2093 1.133397521 1.133397521
      143 21 0.146853147 1 1 0.1206 1.128993008 1.128993008
      143 0 0 1 1 0.1707 1.128993008 2.128993008
      143 33 0.230769231 0 1 0.0699 1.128993008 1.128993008
      73 62 1.260273973 0 1 0.1351 1.121927228 1.121927228
      73 17 0.232876712 0 1 0.1206 1.121927228 1.121927228"
    )
    dat$treat <- as.factor(dat$treat)

    m3 <- brm(r | trials(n) ~ treat * c2, data = dat, family = binomial(link = logit))

    test_that("resp_var", {
      expect_equal(resp_var(m1, combine = TRUE), "count")
      expect_equal(resp_var(m2, combine = TRUE), c(negc7 = "neg_c_7", c12hour = "c12hour"))
      expect_equal(resp_var(m3, combine = TRUE), c("r", "n"))
      expect_equal(resp_var(m1, combine = FALSE), "count")
      expect_equal(resp_var(m2, combine = FALSE), c(negc7 = "neg_c_7", c12hour = "c12hour"))
      expect_equal(resp_var(m3, combine = FALSE), c("r", "n"))
    })

    test_that("resp_val", {
      resp_val(m1)
      resp_val(m2)
      resp_val(m3)
    })
  }
}
