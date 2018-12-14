### Reading in data
### Examining the dataset + 
### Some recoding +
### Correlations
### Francis L. Huang
### 2018.05.22

### Loading in the packages

library(rio) #for importing
library(dplyr) #for select, mutate, filter, arrange, group_by
library(descr) #for frequencies, crosstabs

#### Read and inspect dataset / dataframe

## Practice reading files
## some basic data management
## Download the files and save it on the computer
## know where you put it!! 
## Rule 1:  the path on Windows computers uses a forward slash
## instead of a backslash: Mac users don't have to worry about that
## since they already use a forward slash

## download dataset from here: http://faculty.missouri.edu/huangf/data/prevsci/literacy250.csv
## There are many ways to read in data into R. I prefer
## to use the rio package since users have to only remember
## one function `import()`
## the import() function is in the rio package. makes importing files easier
## only need to know one function which is import()

dat1 <- import('C:/Users/huangf/Box Sync/Projects/efaprevsci/EFAPrevSci/data/literacy250.csv')

## doesn't the file already have a filename? Yes, but we can give 
## the data it's own data object (in this case, dat1)

head(dat1) #first 6 observations
str(dat1) #the structure
summary(dat1) #summary of the variables
freq(dat1$gender) #frequency count: note: this is in the descr package

table(dat1$gender) #just using plain R, doesn't give percents or totals
names(dat1) #display the names of the variables
#Rule 2: R is case sensitive! very important

### selecting a small set of variables
#I. ## select(dataset, var1, var2, -var3, etc.)
reduced <- select(dat1, bs, rhyme, abc, les, spell) 
head(reduced)

#II. ## renaming variables

#rename(dataset, newname = oldname, newname2 = oldname2)

reduced <- rename(reduced, letters = les, spelling = spell)
head(reduced)

## III. want to remove a variable?
reduced2 <- select(reduced, -bs, -abc) #negative bs
head(reduced2)

#### IV. subsetting: filter

### filter(dataset, condition to match)
## NOTE: the double equals!! Very important

boys <- filter(dat1, gender == 'M')
girls <- filter(dat1, gender == 'F')

boys.frpl <- filter(dat1, gender == 'M' & frpl == 1)
girls.frpl <- filter(dat1, gender == 'F' & frpl == 1)

mixed <- filter(dat1, gender == 'F' | frpl == 1)
head(mixed)
tail(mixed)

## select females or those with frpl of 1

### V. creating new variables: mutate and regular R
## this is the usual way: using the $ notation, repetitive
dat1$total <- dat1$spell + dat1$bs + dat1$rhyme + 
  dat1$abc +   dat1$les

## can also use the with function
dat1$overall <- with(dat1, spell + bs + rhyme + abc + les)

#using dplyr
#mutate, and using the %>% "then" sign
#sometimes called a pipe
# 
# dat1 <- dat1 %>% 
#   mutate(overall = spell + bs + rhyme + abc + les)

### grouping: using group_by() and summarise()
# 
# dat1 %>% group_by(gender) %>% summarise(
#   m = mean(overall)
#   )
# 
# #a tibble is a kind of data frame
# 
# dat1 %>% group_by(gender, frpl) %>% summarise(
#   m = mean(overall), m.bs = mean(bs), m.abc = mean(abc)
# )

### VI. Running simple t.tests
t.test(overall ~ gender, data = dat1)  
t.test(overall ~ frpl, data = dat1) 

# VII. simple dummy coding
dat1$male[dat1$gender == 'M'] <- 1
dat1$male[dat1$gender == 'F'] <- 0
table(dat1$male, dat1$gender) #just to check, this is in the descr package too

#### what about frpl? coded as 1 = no or 2 = yes
table(dat1$frpl) 
### try it: code 2 as 1 and 1 as 0

### putting this all together
### Moving away from data management...
### Run some analyses...
### GO over, variance, covariance, correlation
### How are they all related?

### Variables are of different scales
### How do we make them comparable? Can make them
### z scores

### (var - mean of var) / sd(of var)

describe(dat1$abc)

zabc <- (dat1$abc - mean(dat1$abc))/sd(dat1$abc)
### NOTE: zabc is not connected to any data.frame, it's just
### 'floating' in memory

head(zabc)
mean(zabc) #that's zero
sd(zabc)
describe(zabc)

zles <- (dat1$les - mean(dat1$les)) / sd(dat1$les)
describe(zles)

#of course, we can also use the scale function
zles2 <- scale(dat1$les)
zabc2 <- scale(dat1$abc)

cov(dat1$les, dat1$abc) #hard to interpret
cov(zles2, zabc2)
cor(zles2, zabc2)

plot(dat1$abc, dat1$les)
## if you want to get a correlation matrix
# cor(dat1) #you get an error: because you have nonnumeric data
select(dat1, bs, rhyme, abc, les, spell, male) %>% cor()

### select the variables you want, pass it to the cor function,
### round it to 3 digits so it looks better

select(dat1, bs, rhyme, abc, les, spell, male) %>% cor() %>% 
  round(3) #round is a function, tell it what to round and indicate
#how many decimal places, in this case, just 3

#the other way of doing this is cumbersome without the %>%
round(cor(select(dat1, bs:spell, frpl, male)), 3) #much harder to read

### you can use cor with 2 variables

cor.test(dat1$abc, dat1$les)
#note, these tell you the correlations but not if they are 
#statistically significant

library(psych) #package with a lot of useful functions

### corr.test takes a data.frame as its input

select(dat1, bs, rhyme, abc, les, spell) %>% corr.test

##OR
small <- select(dat1, bs, rhyme, abc, les, spell)
describe(small) #in the psych package
corr.test(small)
pairs.panels(small) #in the psych package
