library(data.table)

Teams <- setDT(Lahman::Teams)
Pitching <- setDT(Lahman::Pitching)

# zwraca tą samą ramkę danych ----
Pitching[ , .SD]

# zwraca wybrane kolumny ----
## W: Wins; L: Losses; G: Games
Pitching[ , .SD, .SDcols = c('W', 'L', 'G')] # analogicznie Pitching[, .(W, L, G)]

# sprawdzenie które kolumny są typu znakowego ----
fkt <- c('teamIDBR', 'teamIDlahman45', 'teamIDretro')
Teams[ , lapply(.SD, is.character), .SDcols = fkt]

# zamiana typów kolumn ----
## zmienną fkt trzeba otoczyć nawiasami () by zmusić data.table by rozumiała ją jako nazwy kolumn
Teams[ , (fkt) := lapply(.SD, as.factor), .SDcols = fkt]

# akceptuje też pozycję kolumny ----
## while .SDcols accepts a logical vector, := does not, so we need to convert to column positions with which()
fkt_idx <- which(sapply(Teams, is.factor))
Teams[ , (fkt_idx) := lapply(.SD, as.character), .SDcols = fkt_idx]

# jeszcze inny sposób zamiany kolumn za pomocą wyrażeń regularnych - po drodze konwersja na nazwy kolumn ----
team_idx = grep('team', names(Teams), value = TRUE)
Teams[ , (team_idx) := lapply(.SD, factor), .SDcols = team_idx]

# wybór kolumn możliwy za pomocą wyrażeń regularnych ----
Teams[ , .SD, .SDcols = patterns('team')]

# Controlling a Model’s Right-Hand Side ----
# this generates a list of the 2^k possible extra variables
#   for models of the form ERA ~ G + (...)
extra_var = c('yearID', 'teamID', 'G', 'L')
models = unlist(
  lapply(0L:length(extra_var), combn, x = extra_var, simplify = FALSE),
  recursive = FALSE
)

# here are 16 visually distinct colors, taken from the list of 20 here:
#   https://sashat.me/2017/01/11/list-of-20-simple-distinct-colors/
col16 = c('#e6194b', '#3cb44b', '#ffe119', '#0082c8',
          '#f58231', '#911eb4', '#46f0f0', '#f032e6',
          '#d2f53c', '#fabebe', '#008080', '#e6beff',
          '#aa6e28', '#fffac8', '#800000', '#aaffc3')

par(oma = c(2, 0, 0, 0))
lm_coef = sapply(models, function(rhs) {
  # using ERA ~ . and data = .SD, then varying which
  #   columns are included in .SD allows us to perform this
  #   iteration over 16 models succinctly.
  #   coef(.)['W'] extracts the W coefficient from each model fit
  Pitching[ , coef(lm(ERA ~ ., data = .SD))['W'], .SDcols = c('W', rhs)]
})
barplot(lm_coef, names.arg = sapply(models, paste, collapse = '/'),
        main = 'Wins Coefficient\nWith Various Covariates',
        col = col16, las = 2L, cex.names = .8)

# Conditional Joins ----
# to exclude pitchers with exceptional performance in a few games,
#   subset first; then define rank of pitchers within their team each year
#   (in general, we should put more care into the 'ties.method' of frank)
Pitching[G > 5, rank_in_team := frank(ERA), by = .(teamID, yearID)]
Pitching[rank_in_team == 1, team_performance :=
           Teams[copy(.SD), Rank, on = c('teamID', 'yearID')]]

# Group subsetting ----
Teams[ , .SD[.N], by = teamID]
## .SD[1L] to get the first observation for each group, or .SD[sample(.N, 1L)] to return a random row for each group

Teams[ , .SD[which.max(R)], by = teamID]

# Grouped Regression ----
# Overall coefficient for comparison
overall_coef = Pitching[ , coef(lm(ERA ~ W))['W']]
# use the .N > 20 filter to exclude teams with few observations
Pitching[ , if (.N > 20L) .(w_coef = coef(lm(ERA ~ W))['W']), by = teamID
          ][ , hist(w_coef, 20L, las = 1L,
                    xlab = 'Fitted Coefficient on W',
                    ylab = 'Number of Teams', col = 'darkgreen',
                    main = 'Team-Level Distribution\nWin Coefficients on ERA')]
abline(v = overall_coef, lty = 2L, col = 'red')

