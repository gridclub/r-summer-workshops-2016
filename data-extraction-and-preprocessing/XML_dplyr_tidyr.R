## rip data from the internet
library(XML)

## find website with data of interest and save its html
site <- "http://www.basketball-reference.com/players/a/antetgi01/gamelog/2015/"

## use readHTMLTable() to see all of the tables on that site (this may include some tables that don't have the info you're interested in)
tables <- readHTMLTable(site)

## within tables, find the data you are interested in and pull it out
giannis <- tables$pgl_basic
## this data had a few un-named columns, dplyr doesn't like this, so I'm going to fill them in
names(giannis)[which(names(giannis)=="")] <- paste0("bla", seq(1, length(which(names(giannis)==""))))

## format your data the way you want it!
library(dplyr)
## tbl format is a dplyr format that is tidier than the base data.frame format
giannis <- as.tbl(giannis)
giannis

## use select to choose only the columns you are interested in. there are many different select() fxns, such as contains()
select(giannis, G, contains("%"))

## or you can just write the names of the columns (without quotes)
giannis <- select(giannis, G, Date, Age, Opp, PTS)
giannis

## sometimes the column names are poorly formatted or uninformative, rename() makes it easy to change that!
giannis <- rename(giannis, Points = PTS)
summary(giannis)
## in the summary, all of the variables are represented as factors, why is that?
View(giannis)

## use filter() to look at only the data that you want to see!
giannis <- filter(giannis, G != "G")
summary(giannis)
## removed the "G" rows, but variables are still represented as factors

## use mutate() to create columns that are functions of other columns! (much more on this to come)
giannis <- mutate(giannis, 
                  G = as.numeric(as.character(G)),
                  Date = as.Date(Date),
                  Points = as.numeric(as.character(Points)))
summary(giannis)
## good, now each column is in the appropriate class

## use arrange() to reorder your data by a column! use desc() to do so descendingly.
arrange(giannis, desc(Points))

## here are some simple ways to sample your data!
sample_frac(giannis, 0.1, replace = FALSE)
sample_n(giannis, 10, replace = FALSE)
slice(giannis, 19:24)
top_n(giannis, 5, Points)

## there are a bunch of neat mutate() functions for manipulating your data more easily!
mutate(giannis, lead_points = lead(Points))
mutate(giannis, lag_points = lag(Points))
mutate(giannis, rank_points = dense_rank(desc(Points)))
mutate(giannis, rank_points = percent_rank(Points))
mutate(giannis, quartile = ntile(Points, 4))
mutate(giannis, points_per_game = cummean(Points))
mutate(giannis, total_points = cumsum(Points))
mutate(giannis, max_points = cummax(Points))

## use summarise() or summarize() to get summary statistics for your data!
summarise(giannis,
          total_games = n(),
          points_per_game = mean(Points))

## use group_by() and summarise() or mutate() to find statistics within groups of your data!
giannis <- group_by(giannis, Opp)
summarise(giannis,
          total_games = n(),
          points_per_game = mean(Points))

mutate(giannis, cumsum(Points))
## that didn't show much, lets look at the bottom of the tbl
tail(mutate(giannis, cumsum(Points)))

## ungroup() ungroups the tbl
giannis <- ungroup(giannis)

## can do this all through "piping" with %>%
g2 <- tables$pgl_basic
names(g2)[which(names(g2)=="")] <- paste0("bla", seq(1, length(which(names(g2)==""))))

g2 %>% 
        as.tbl() %>%
        select(G, Date, Age, Opp, PTS) %>%
        rename(Points = PTS) %>%
        filter(G != "G") %>%
        mutate(G = as.numeric(as.character(G)),
               Date = as.Date(Date),
               Points = as.numeric(as.character(Points))) %>%
        sample_frac(0.5, replace = FALSE) %>%
        group_by(Opp) %>%
        summarise(total_games = n(), points_per_game = mean(Points)) %>%
        arrange(desc(points_per_game))

## get another player's stats to show other dplyr fxns
site2 <- "http://www.basketball-reference.com/players/k/koufoko01/gamelog/2015/"
tables2 <- readHTMLTable(site2)
kosta <- tables2$pgl_basic
names(kosta)[which(names(kosta)=="")] <- paste0("bla", seq(1, length(which(names(kosta)==""))))

## use bind_rows(), instead of rbind()
bind_rows(g2, kosta)

g3 <- g2 %>%
        as.tbl() %>%
        select(Date, PTS)

k2 <- kosta %>%
        as.tbl() %>%
        select(Date, kosta_PTS = PTS)

## four different kinds of merge! left_join() keeps all data from first and everything that matches in the second
left_join(g3, k2, by = "Date")
## right_join() keeps all data from the second and everything that matches from the first
right_join(g3, k2, by = "Date")
## full_join() keeps all data from both
full_join(g3, k2, by = "Date")
## inner_join() keeps only data that match in both
inner_join(g3, k2, by = "Date")

## further manipulation in tidyr
library(tidyr)
## this is what our original data looks like
giannis

## what if you wanted to have the Date run across the columns with points across the rows?
## use spread()!
g4 <- giannis %>%
        select(Date, Opp, Points) %>%
        spread(Date, Points)
View(g4)
## piping works across tidyr() and dplyr()!

## have a large number of columns that you want to neatly arrange into a few columns?
## use gather()!
gather(g4, "Date", "Points", -1, na.rm=TRUE)
