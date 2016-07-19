data management and web scraping
========================================================
author: katie leap and stephen lauer
date: 7/19/16

Sponsors
========================================================
[![Graduate Women In STEM](gwis-logo.png)](http://blogs.umass.edu/gwis/)

[![Graduate Researchers in Data](grid-logo.png)](http://gridclub.io/)

[Western Mass Statistics and Data Science Meetup](http://www.meetup.com/Pioneer-Valley-and-Five-College-R-Statistical-Meetup/)

Data Extraction
========================================================
- With R, this isn't really a thing
- `read.csv` will read in csv files
  - very easy syntax, used most frequently
- In this workshop, we'll cover two other methods
  - Importing SAS files
  - Scraping HTML tables from the internet

Data Management
========================================================
- Actually refers to a lot of things
  - some of them very technical with names like "data architecture"
- We're using it just to refer to managing **data quality**
  - cleaning 
  - processing
- Additionally, sometimes data comes to you as a giant file, but you don't need all of it
  - R makes it easy to filter and select just the data you're interested in

Case Study 1: NHANES
========================================================
- We'll get started with a public health dataset that we're going to find online right now
- [wwwn.cdc.gov/Nchs/Nhanes/Search/Nhanes13_14.aspx](http://wwwn.cdc.gov/Nchs/Nhanes/Search/Nhanes13_14.aspx)


```r
library(Hmisc)
demographics <- sasxport.get("http://wwwn.cdc.gov/Nchs/Nhanes/2013-2014/DEMO_H.XPT")
taste.smell <- sasxport.get("http://wwwn.cdc.gov/Nchs/Nhanes/2013-2014/CSX_H.XPT")
```

Clean Up, Clean Up, Everybody Everywhere...
========================================================
1. Decide which variables to use
2. Look for missing data: why are they missing and is this a problem?
3. Look for out-of-range data: why would a living person have a pulse of 0 bpm?
4. Make sure numbers are numbers and factors are factors

Introducing dplyr!
========================================================
- `dplyr` works like magic
- We're going to look at the following functions in `dplyr`:
  - `select()`
  - `rename()`
  - `filter()`
  - `mutate()`
  - `group_by()`
  - `summarize()`
  - `arrange()`
- They all do what it sounds like they do (but we'll go through them anyways)

But First!
========================================================

- the pipe!
- **%>%**
- this handy little thing comes from the `magrittr` package
- replaces the first argument in a function with the object before the pipe
- it makes code a million times more readable
- keyboard shortcut: **cmd-shift-M** (for **m**agrittr)

%>% in action!
========================================================

```r
library(magrittr) # or dplyr

## confusing ##
mean(seq_len(sum(seq(1:10))))
```

```
[1] 28
```

```r
## clear ##
seq(1:10) %>% 
  sum %>%
  seq_len %>% 
  mean
```

```
[1] 28
```

Back to NHANES
========================================================
- Our first step is to decide which variables we want to use
- We probably want to investigate a relationship, so we should choose a predictor variable and a response variable
- Now we look at the codebook to figure out what these have been named

Back to NHANES
========================================================
- Let's select the variables we decided to work with
- We can rename them at the same time

```r
library(plyr)
library(dplyr)
demo <- demographics %>% 
  select(id=seqn,gender=riagendr,age=ridageyr) 
```
- If we didn't want to select only a specific number of columns, we would use `rename()`

Freebie: helper functions
========================================================
- `contains()`
- `ends_with()`
- `everything()`
- `matches()`
- `num_range("x", 1:5)`: columns named x1, x2, x3, x4, x5.
- `one_of()`
- `starts_with()`

Back to Cleaning!
========================================================
- `summary()` provides summary statistics
- this is a one-stop-shop for missing data, out-of-range data and checking that numbers are numbers and factors are factors
- however magic `dplyr` is, data management relies on your brain
  - be thorough
  - document what you do
  - justify every decision you make
  - don't overwrite your original data

========================================================
![Plus, now I know that I have risk factors for elbow dysplasia, heartworm, parvo, and mange.](http://imgs.xkcd.com/comics/genetic_testing.png)

Mutants!
========================================================
- `mutate()` allows us to add new columns
- usually we do this because we have changed something about another column and want to preserve both
- for example, changing kg to lbs because this is AMERICA
- `mutate_each()`: multiple columns

Mutants!
========================================================

```r
demo <- demographics %>% 
  select(id=seqn,gender=riagendr,age=ridageyr) %>% 
  mutate(gender=revalue(as.factor(gender), c("1"="male","2"="female")))
summary(demo)
```

```
       id           gender          age       
 Min.   :73557   male  :5003   Min.   : 0.00  
 1st Qu.:76100   female:5172   1st Qu.:10.00  
 Median :78644                 Median :26.00  
 Mean   :78644                 Mean   :31.48  
 3rd Qu.:81188                 3rd Qu.:52.00  
 Max.   :83731                 Max.   :80.00  
```

Select : Columns :: Filter : Rows
========================================================
- `filter()` allows you to pick rows that have a specific value inside a column
- For example, let's say we want to pick all of the women

```r
women <- demo %>% 
  filter(gender=="female")
```
- You can use the >, <, ==, >=, and <= operators to `filter()` rows

```r
old.farts <- demo %>% 
  filter(age>75)
```

Summarize
========================================================
- When we want to get one number, we use `summarize()`
- Think of functions like `mean()`

```r
demo %>% 
  summarize(mean.age = mean(age))
```

```
  mean.age
1 31.48413
```
- `summarize_each()`: multiple columns

Grouping
========================================================

```r
group <- demo %>%
  group_by(gender)
head(group)
```

```
Source: local data frame [6 x 3]
Groups: gender [2]

     id gender   age
  (int) (fctr) (int)
1 73557   male    69
2 73558   male    54
3 73559   male    72
4 73560   male     9
5 73561 female    73
6 73562   male    56
```

Arrange
========================================================

```r
arrange <- demo %>% 
  arrange(gender)
head(arrange)
```

```
     id gender age
1 73557   male  69
2 73558   male  54
3 73559   male  72
4 73560   male   9
5 73562   male  56
6 73563   male   0
```


Divide and Conquer!
========================================================

```r
demo %>%
  group_by(gender) %>%  
  summarize(mean.age = mean(age))
```

```
Source: local data frame [2 x 2]

  gender mean.age
  (fctr)    (dbl)
1   male 30.69159
2 female 32.25077
```


Freebie: Summarize function examples
========================================================
- `dplyr` specific:
  - `first`: First value of a vector.
  - `last`: Last value of a vector.
  - `nth`: Nth value of a vector.
  - `n`: # of values in a vector.
  - `n_distinct`: # of distinct values in a vector.
- Other functions:
  - `IQR`
  - `min`, `max`
  - `mean`, `median`
  - `var`, `sd`

Why did we download two datasets?
========================================================
- Because we can join them!
- There are different joins depending on how you want to do it
- I look them up every time: [data wrangling cheat sheet](https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf)

But first!
========================================================
- 10 minutes to clean the second dataset!
- Remember to:
  - select just the variables you want (rename probably)
  - look for missing values
  - check your factors



Left join!
========================================================

```r
library(tidyr)
full.dat <- left_join(demo, ts, by = "id")
```
- Optional `by` statement
- Can use more than one `by` variables as well
  - `by = c("id","age")`

Have fun!
========================================================
- Find some interesting stuff, please
- Take a snack break if you like
- Let us know what you find!
  - Do old people smell funny?
- Complete list of `dplyr` functions can be found on the [data wrangling cheat sheet](https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf)

Web Scraping
========================================================
- Refers to extracting information from websites
- Really easy to do in R with the help of some packages
  - `XML`
  - `rvest`

Case Study 2: Scraping Celtics statistics
========================================================
Scraping an HTML table from [www.basketball-reference.com/teams/BOS/2016.html](http://www.basketball-reference.com/teams/BOS/2016.html)

```r
library(XML)
site <- "http://www.basketball-reference.com/teams/BOS/2016.html"
celtics_2016 <- readHTMLTable(site)
celtics_players <- celtics_2016$per_game
```

Highest scoring Celtics in 2016
========================================================

```
         Player Age  G  PTS
1  Marcus Smart  21 61  9.1
2  Amir Johnson  28 79  7.3
3     David Lee  32 30  7.1
4  Tyler Zeller  26 60  6.1
5 Jonas Jerebko  28 78  4.4
6 Isaiah Thomas  26 82 22.2
```

Looking at historical Celtics stats
========================================================

```r
years <- 1980:2013
all_celtics <- c()
for(year in years){
  site <- paste0("http://www.basketball-reference.com/teams/BOS/", year, ".html")
  celtics_one_year <- readHTMLTable(site)
  one_year_players <- celtics_one_year$per_game
  one_year_players$Year <- year
  all_celtics <- bind_rows(all_celtics, one_year_players)
}
```

Highest scoring Celtics in a single season
========================================================

```r
all_celtics %>% 
  select(Player, Year, PTS) %>% 
  arrange(desc(as.numeric(PTS)))
```

Highest scoring Celtics in a single season
========================================================

```
Source: local data frame [544 x 3]

         Player  Year   PTS
          (chr) (int) (chr)
1    Larry Bird  1988  29.9
2    Larry Bird  1985  28.7
3    Larry Bird  1987  28.1
4   Paul Pierce  2006  26.8
5  Kevin McHale  1987  26.1
6   Paul Pierce  2002  26.1
7   Paul Pierce  2003  25.9
8    Larry Bird  1986  25.8
9   Paul Pierce  2001  25.3
10  Paul Pierce  2007  25.0
..          ...   ...   ...
```

Highest scoring Celtics over career
========================================================

```r
all_celtics %>% 
  group_by(Player) %>% 
  summarize(Games=sum(as.numeric(G)),             
            PPG=weighted.mean(as.numeric(PTS), as.numeric(G))) %>% 
  arrange(desc(PPG))
```

Highest scoring Celtics over career
========================================================

```
Source: local data frame [242 x 3]

              Player Games      PPG
               (chr) (dbl)    (dbl)
1         Larry Bird   897 24.30234
2        Paul Pierce  1102 21.81053
3     Antoine Walker   552 20.62083
4       Kevin McHale   971 17.84449
5  Dominique Wilkins    77 17.80000
6       Reggie Lewis   450 17.57533
7          Ray Allen   358 16.71844
8         Dino Radja   224 16.68437
9      Robert Parish  1106 16.48300
10       Ricky Davis   181 16.26022
..               ...   ...      ...
```

`rvest` and the SelectorGadget
========================================================
- Load up `rvest`

```r
library(rvest)
```
- Download the selector gadget at [selectorgadget.com](http://selectorgadget.com/)

IMDB Web Scrape
========================================================
[IMDB's Top 100 "Robot Movies"](http://www.imdb.com/search/title?count=100&keywords=robot&num_votes=3000,&title_type=feature&ref_=gnr_kw_ro)

```r
imdb <- read_html("http://www.imdb.com/search/title?count=100&keywords=robot&num_votes=3000,&title_type=feature&ref_=gnr_kw_ro")

descriptions <- imdb %>% 
  html_nodes(".outline") %>% 
  html_text()
```
IMDB Web Scrape
========================================================

```r
descriptions[[1]]
```

```
[1] "After the re-emergence of the world's first mutant, world-destroyer Apocalypse, the X-Men must unite to defeat his extinction level plan."
```

IMDB Web Scrape
========================================================

```r
rating <- imdb %>% 
  html_nodes(".value") %>% 
  html_text() %>% 
  as.numeric
```

IMDB Web Scrape
========================================================

```r
head(rating)
```

```
[1] 7.4 8.2 8.2 6.6 8.6 7.5
```

IMDB Web Scrape
========================================================

```r
year <- imdb %>% 
  html_nodes(".year_type") %>% 
  html_text() %>% 
  gsub(pattern="\\(",replacement="") %>% 
  gsub(pattern="\\)",replacement="") %>% 
  as.numeric
```

IMDB Web Scrape
========================================================

```r
head(year)
```

```
[1] 2016 2016 2015 2015 2014 2015
```

IMDB Web Scrape
========================================================

```r
title <- imdb %>% 
  html_nodes(".title") %>% 
  html_text()

title2 <- unlist(strsplit(title,"\n    \n\n\n\n    "))[seq(from=2,to=length(title),by=2)]
title3 <- unlist(strsplit(title2,"\n    \\("))[seq(from=1,to=length(title),by=2)]
```

IMDB Web Scrape
========================================================

```r
head(title3)
```

```
[1] "X-Men: Apocalypse"            "Captain America: Civil War"  
[3] "Star Wars: The Force Awakens" "Terminator Genisys"          
[5] "Interstellar"                 "Avengers: Age of Ultron"     
```

IMDB Web Scrape
========================================================

```r
robot.movies <- data.frame(title=title3,year,rating)
head(arrange(robot.movies,desc(rating)),4)
```

```
                                           title year rating
1 Star Wars: Episode V - The Empire Strikes Back 1980    8.8
2                                     The Matrix 1999    8.7
3             Star Wars: Episode IV - A New Hope 1977    8.7
4                                   Interstellar 2014    8.6
```

IMDB Web Scrape Activities
========================================================
- Find which years have had the most "robot movies"
- Use `grep` to find which descriptions contain robot words ("robot", "android", "AI", etc.) to filter out fake robot movies (X-Men Apocalyse, really?)
- Find average rating of robot movies, as well as the lowest and highest rated ones

Thank You!
========================================================
[![Graduate Women In STEM](gwis-logo.png)](http://blogs.umass.edu/gwis/)

[![Graduate Researchers in Data](grid-logo.png)](http://gridclub.io/)

[Western Mass Statistics and Data Science Meetup](http://www.meetup.com/Pioneer-Valley-and-Five-College-R-Statistical-Meetup/)
