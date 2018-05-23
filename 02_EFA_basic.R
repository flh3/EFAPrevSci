### No fuss example of EFA in R / for MPC
### 2018.05.23
### Francis L. Huang
### EFA for scale construction: Which items go together to form a scale?
### Explore the factor structure / dimensionality
### Barebones with minimal options explained

library(dplyr)
library(psych)
#library(GPArotation) #make sure you have this installed

# .	Contains 300 responses to a 6 item survey of college students
# .	Ratings of the respondents liking of subject matter (biology, algebra, chemistry, calculus, statistics, geology)
# .	Used a Likert scale, 1 = strongly dislike, 5 = strongly like

## 1 Read in and examine dataset (noting variable names)
## I am doing this so you get practice loading in your own data!
dat2 <- import("C:/Users/huangf/Dropbox/Stat4/FH_MU/2018/05_EFA/homework/bioalgebra.sav")
head(dat2)
summary(dat2)
names(dat2)

## 2 Can you factor analyze the data?

# Remember, items have to be related, if not, each item is 
# independent from each other

cor(dat2) %>% round(3) #the %>% works because of dplyr
round(cor(dat2), 3) #same result without dplyr

# What do you conclude?

# Can do Bartlett's test of sphericity
# Explain null hypothesis: (diagonal matrix)

diag(6) #just draws a matrix with zeros as an example
cortest.bartlett(dat2) #in psych package

# NOTE: to get help, type ?functionname
# if you don't know the function name type ??whatyouthinkthefunctionnameis (2 ??)

## Report that x2(15) = 849.21, p < .001. Null is rejected,
## FA is possible! Natch...

cortest.bartlett(diag(6), n = 100) #what is we had an identity matrix?
## NOTE: older studies seem to run these tests but since this is our
## data, we obviously think they should go together! We made the questionnaire...

### 3 Run the factor analysis
### NOTE: many choices: each of which will result in possibly different results

## Corelation matrix vs covariance matrix
## How many factors to retain: PA, scree plot, Kaiser's rule
## What factor method to use: principal axis factoring, minres, mle
## Will you use rotation: what type: orthogonal vs oblique...
## What is the minimum loading: how strong do you want the loadings?
## How many items load onto a factor (think of loadings as weights)
## Pattern matrix vs structure matrix
## What constitutes a factor (2 + items)

## Items are weighted combination of factors
## 

## How many factors? Old style:
scree(dat2)
## Do no use Kaiser's rule with FA! Eigenvalue > 1, only good for PCA

fa.parallel(dat2)
### if this is too cluttered::
fa.parallel(dat2, fa = 'fa') #specify only factor analysis, drop PC

### Some theory? Eigenvalues and eigenvectors

res1 <- fa(dat2, nfactors = 2) #at its simplest!
res1

### unpack results

.86^2 + .02^2 = .74
#MR1^2 + MR2^2 = h2 (communality)
#1 - h2 = u2 (uniqueness)
# discuss standardized loadings
# name the factors
# correlation among factors


#which item goes with which factor?
#goal is to find simple structure (clean loadings)

### This is a super clean example: in reality, will be an iterative process
### Removing variables, rerunning, etc.

### What reliabilities? Discuss...

select(dat2, bio, chem, geo) %>% alpha
select(dat2, alg, calc, stat) %>% alpha

#limitation: Alpha assumes tau equivalence (equal factor loadings)

### better yet, use omegas
library(MBESS) #this has the function to compute omegas
#do not use the one in the psych package, not sure what 
#that is but it is different
#omega does not assume equal factor loadings, but if they are
#equal, then returns alpha: so you have nothing to lose

select(dat2, bio, chem, geo) %>% ci.reliability
select(dat2, alg, calc, stat) %>% ci.reliability

### OTHERS: items are actually categorical
### use polychoric matrix (easy to implement in R)

fa.parallel.poly(dat2, fa = 'fa')
#gives warnings-- warnings are not errors
#given time, explain a bit about polychoric correlations
res2 <- fa(dat2, nfactors = 2, cor = 'poly') #polychoric option, explain
res2


### VISUALIZATION: Won't get around to this...
load <- res1$loadings
load[,1] #first set of loadings
load[,2] #second set of loadings
df <- data.frame(f1 = load[,1], f2 = load[,2])
df$subject <- rownames(df)

library(reshape2)
mm <- melt(df, id.vars = 'subject')
mm$col <- ifelse(abs(mm$value) > .4, 2, 1)
library(ggplot2)
ggplot(mm) + aes(x = subject, y = value, fill = col) + facet_grid(~variable) +
  geom_bar(stat = 'identity') + theme_bw() +
  labs(y = 'Factor loadings', x = 'Subject') + coord_flip() +
  guides(fill = F)
