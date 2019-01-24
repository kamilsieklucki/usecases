df <- tibble(
  g1 = c(1, 1, 2, 2, 2),
  g2 = c(1, 2, 1, 2, 1),
  a = sample(5),
  b = sample(5)
)


my_summarise <- function(df, group_var) {
  group_var <- enquo(group_var)
  
  df %>%
    group_by(!! group_var) %>%
    summarise(a = mean(a))
}

my_summarise(df, g1)




my_summarise2 <- function(df, expr) {
  expr <- enquo(expr)
  
  summarise(df,
            mean = mean(!! expr),
            sum = sum(!! expr),
            n = n()
  )
}

my_summarise2(df, a * b)




my_mutate <- function(df, expr) {
  expr <- enquo(expr)
  mean_name <- paste0("mean_", quo_name(expr))
  sum_name <- paste0("sum_", quo_name(expr))
  
  mutate(df,
         !! mean_name := mean(!! expr),
         !! sum_name := sum(!! expr)
  )
}

my_mutate(df, a)




my_summarise <- function(df, ...) {
  group_var <- quos(...)
  
  df %>%
    group_by(!!! group_var) %>%
    summarise(a = mean(a))
}

my_summarise(df, g1, g2)
