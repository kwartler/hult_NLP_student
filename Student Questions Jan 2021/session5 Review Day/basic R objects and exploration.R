# Object classes
# Jan 21
# TK

#numeric
x<- 1
is.numeric(x)
is.integer(x)

y <- 326L
is.numeric(y)
is.integer(y)


# Classes
class(x * y)

# Factors
x <- as.factor(letters[1:3])
class(x)

# Strings
x <- 'some text that we have'
class(x)
nchar(x)
nchar(y) #Coercion

# Dates
x <- Sys.Date()
y <- x-7
difftime(x,  y, units = 'mins') #?difftime

library(lubridate)
year(x)
month(x)
day(x)
weekdays(x)

# Logicals
x <- TRUE
y <- F
class(x)
class(y)

347*x
347*y

# Vectors & Vector Operations
x <- c(1,2,3,4,5)
y <- c(6:10)
length(x)
class(x)
class(y)

x*y
x+1
x^2
sqrt(x)

# Char Vectors
x <- c(letters[1:10])
x
nchar(x)

# Logical Operators
x <- 1
y <- 2
x>y
x>=1
x<y

x <- c(1,2,3,4,5)
y <- c(1:3,6,7)
x>y
x<y

# Missing data
x <- c(1,NA,3,4,5)
x
is.na(x)

y <- c(1,NULL,3,4,5)
y

# is.null doesn't work on vectors since null is not within a vector, see y above
is.null(NULL)
is.null(3)

# End