## https://www.onceupondata.com/2018/09/28/handling-r-errors/

my_sqrt <- function(x){
  if((x) < 0) {
    stop("x must be positive")
  } else {
    sqrt(x)
  }
}

my_sqrt(-1)

# poprawny argument zwraca wynik
sqrt_cnd <- tryCatch(error = function(cnd) cnd, my_sqrt(1))

# wiadomosc o bledzie
sqrt_cnd <- tryCatch(error = function(cnd) cnd, my_sqrt(-1))
str(sqrt_cnd)

# zero zamiast wiadomosci o bledzie
sqrt_cnd <- tryCatch(error = function(x) 0, my_sqrt(-1))
str(sqrt_cnd)


## define get_val() to simulate random input values
get_val <- function(){
  val <- runif(1, -10, 10)
  if (val < 1){
    stop("Can't get val")
  } else {
    val
  }
}

## Note that `mult_val()` it is not a very practical example,
## because the function doesn't do a single task related to its name, 
## but I am just using it for demo purposes
mult_val <- function(mult_by = 2){
  x <- get_val()
  x*mult_by
}

## in case val negative 
get_val()

mult_val()
## In both cases, we have the same error message and we have no info about the value of val that caused the error.


## So rlang provides functions that correspond to base R ones as follows:
# rlang 	base R
# abort() 	stop()
# warn() 	warning()
# inform() 	message()
## rlang functions are designed to deal with condition objects and create custom ones easily, unlike base R functions that are focused on messages.

## define get_val() to simulate random input values
get_val <- function(){
  val <- runif(1, -10, 10)
  if (val < 1){
    rlang::abort(message = "Can't get val", 
                 .subclass ="get_val_error", 
                 val = val)
  } else {
    val
  }
}

custom_cnd <- tryCatch(error = function(cnd) cnd, get_val())
str(custom_cnd, max.level = 1)

## define an error handler to modify the message
get_val_handler <- function(cnd) {
  msg <- "Can't calculate value"
  
  if (inherits(cnd, "get_val_error")) {
    msg <- paste0(msg, " as `val` passed to `get_val()` equals (", cnd$val,")")
  }
  
  rlang::abort(msg, "mult_val_error")
}

## use get_val_handler() with mult_val()
mult_val <- function(mult_by = 2){
  x <- tryCatch(error = get_val_handler, get_val())
  x*mult_by
}

mult_val()
