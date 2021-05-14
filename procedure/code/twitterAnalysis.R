
# install packages for twitter querying and initialize the library
packages = c("rtweet","here","dplyr","rehydratoR")
setdiff(packages, rownames(installed.packages()))
install.packages(setdiff(packages, rownames(installed.packages())),
                 quietly=TRUE)

library(rtweet)

library(dplyr)
library(rehydratoR)
library(tidyverse)

# set up twitter API information with your own information for
# app, consumer_key, and consumer_secret
# this should launch a web browser and ask you to log in to twitter
# for authentication of access_token and access_secret
twitter_token = create_token(
  app = "HR Spatial Clustering ",                     #enter your app name in quotes
  consumer_key = "x1ptxZlD7tIBMtqG08IMjnE3m",  		      #enter your consumer key in quotes
  consumer_secret = "YiiB0Eh9Gs77ZNwC3mKbBX6aGBtt9MlkH6ozdvj4edJHeGd2T5",         #enter your consumer secret in quotes
  access_token = "966146432393732102-EN9TrLpikF67TEbUiAsWi9Wu0F0sKjx",
  access_secret = "FdBDs0SCzAtQ11InS9OfKsWCGj65Yolo98BRXdBkJ3m8R"
)

# get tweets for hurricane Dorian, searched on September 11, 2019
# this code will no longer work! It is here for reference.
vaccineTweets = search_tweets("moderna OR pfizer OR vaccine",
                              n=200000, include_rts=FALSE,
                              token=twitter_token, 
                              geocode="37,-94,1000mi",
                              retryonratelimit=TRUE) 
saveRDS(vaccineTweets, here("data","derived","private","vaccineTweets_raw.rds"))

write.table(vaccineTweets_raw$status_id,
            here("data","raw","public","vaccineTweetsids.txt"), 
            append=FALSE, quote=FALSE, row.names = FALSE, col.names = FALSE)

# get tweets without any text filter for the same geographic region in November, 
# searched on November 19, 2019
# this code will no longer work! It is here for reference.
# the query searches for all verified or unverified tweets, i.e. everything
may = search_tweets("-filter:verified OR filter:verified", 
                         n=200000, include_rts=FALSE, 
                         token=twitter_token,
                         geocode="32,-78,1000mi", 
                         retryonratelimit=TRUE)

saveRDS(may, here("data","derived","private","mayTweets_raw.rds"))

############# LOAD SEARCH TWEET RESULTS  ############# 

### REVAMP THESE INSTRUCTIONS

#vaccineTweets = readRDS(here("data","derived","private","vaccineTweets_clean.RDS"))

# load tweet status id's for Hurricane Dorian search results
vaccineTweetids = 
  data.frame(read.table(here("data","raw","public","vaccineTweetids.txt"), 
                        numerals = 'no.loss'))

# load cleaned status id's for November general twitter search
mayIds =
  data.frame(read.table(here("data","derived","public","mayIds.txt"),
                        numerals = 'no.loss'))

# rehydrate dorian tweets
dorian_raw = rehydratoR(twitter_token$app$key, twitter_token$app$secret, 
                        twitter_token$credentials$oauth_token, 
                        twitter_token$credentials$oauth_secret, dorianids, 
                        base_path = NULL, group_start = 1)

# rehydrate november tweets
november = rehydratoR(twitter_token$app$key, twitter_token$app$secret, 
                      twitter_token$credentials$oauth_token, 
                      twitter_token$credentials$oauth_secret, novemberids, 
                      base_path = NULL, group_start = 1)



############# FILTER VACCINE TWEETS FOR CREATING PRECISE GEOMETRIES ############# 

may = readRDS(here("data","derived","private","mayTweets_raw.RDS"))
#load cleaned data from lab


# reference for lat_lng function: https://rtweet.info/reference/lat_lng.html
# adds a lat and long field to the data frame, picked out of the fields
# that you indicate in the c() list
# sample function: lat_lng(x, coords = c("coords_coords", "bbox_coords"))

# list and count unique place types
# NA results included based on profile locations, not geotagging / geocoding.
# If you have these, it indicates that you exhausted the more precise tweets 
# in your search parameters and are including locations based on user profiles
count(vaccineTweets_raw, place_type)

# convert GPS coordinates into lat and lng columns
# do not use geo_coords! Lat/Lng will be inverted
vaccineTweets = lat_lng(vaccineTweets_raw, coords=c("coords_coords"))
may = lat_lng(may, coords=c("coords_coords"))


# select any tweets with lat and lng columns (from GPS) or 
# designated place types of your choosing
vaccineTweets = subset(vaccineTweets, 
                place_type == 'city'| place_type == 'neighborhood'| 
                  place_type == 'poi' | !is.na(lat))

may = subset(may,
                  place_type == 'city'| place_type == 'neighborhood'| 
                    place_type == 'poi' | !is.na(lat))

# convert bounding boxes into centroids for lat and lng columns
vaccineTweets = lat_lng(vaccineTweets,coords=c("bbox_coords"))
may = lat_lng(may,coords=c("bbox_coords"))

# re-check counts of place types
count(vaccineTweets, place_type)

############# SAVE FILTERED TWEET IDS TO DATA/DERIVED/PUBLIC ############# 

write.table(vaccineTweets$status_id,
            here("data","derived","public","vaccineTweetsids.txt"), 
            append=FALSE, quote=FALSE, row.names = FALSE, col.names = FALSE)

write.table(may$status_id,
            here("data","derived","public","mayIds.txt"), 
            append=FALSE, quote=FALSE, row.names = FALSE, col.names = FALSE)

############# SAVE TWEETs TO DATA/DERIVED/PRIVATE ############# 

saveRDS(vaccineTweets, here("data","derived","private","vaccineTweets_clean.RDS"))

write.csv(vaccineTweets, here("data","derived","private","vaccineTweets_clean.csv"))
saveRDS(may, here("data","derived","private","may_clean.RDS"))

#install packages for twitter, census, data management, and mapping
packages = c("rtweet","tidycensus","tidytext","maps","RPostgres","igraph","tm", 
             "ggplot2","RColorBrewer","rccmisc","ggraph","here")
setdiff(packages, rownames(installed.packages()))
install.packages(setdiff(packages, 
                         rownames(installed.packages())), quietly=TRUE)

#ANALYZE:
#---------------------------------------------------------------------------------
#initialize the libraries. this must be done each time you load the project
library(rtweet)
library(igraph)
library(dplyr)
library(tidytext)
library(tm)
library(tidyr)
library(ggraph)
library(tidycensus)
library(ggplot2)
library(RPostgres)
library(RColorBrewer)
library(DBI)
library(rccmisc)
library(here)


###############READING IN EMMA'S DATA FOR THE ANTI JOIN#################3
emmaVax  = readRDS(here("data","derived","private","emmasVaccine.RDS"))


#total vax = removes the tweets in my data that overlaps with emmas, 
totalVax = anti_join(vaccineTweets, emmaVax, by="status_id")

#now join total vax and emmaVax
vaccineTweets = full_join(totalVax, emmaVax)


############# TEMPORAL ANALYSIS ############# 

#create temporal data frame & graph it

vaccineTweetsByHour <- ts_data(vaccineTweets, by="hours")
ts_plot(vaccineTweets, by="hours")


############# NETWORK ANALYSIS ############# 

# Create network data frame. 
# Other options for 'edges' in the network include mention, retweet, and reply
vaccineNetwork <- network_graph(vaccineTweets, c("quote"))

plot.igraph(vaccineNetwork)
# This graph needs serious work... e.g. subset to a single state maybe?


############# TEXT / CONTEXTUAL ANALYSIS ############# 

# remove urls, fancy formatting, etc. in other words, clean the text content
vaccineText = vaccineTweets %>% select(text) %>% plain_tweets()

# parse out words from tweet text
vaccineWords = vaccineText %>% unnest_tokens(word, text)

# how many words do you have including the stop words?
count(vaccineWords)

# create list of stop words (useless words not worth analyzing) 
data("stop_words")

# add "t.co" twitter links to the list of stop words
# also add the twitter search terms to the list
stop_words = stop_words %>% 
  add_row(word="t.co",lexicon = "SMART") %>% 
  add_row(word="vaccine",lexicon = "Search") %>% 
  add_row(word="pfizer",lexicon = "Search") %>% 
  add_row(word="moderna",lexicon = "Search")

#delete stop words from dorianWords with an anti_join
vaccineWords =  vaccineWords %>% anti_join(stop_words) 

# how many words after removing the stop words?
count(vaccineWords)

# graph frequencies of words
vaccineWords %>%
  count(word, sort = TRUE) %>%
  top_n(15) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(x = word, y = n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip() +
  labs(x = "Count",
       y = "Unique words",
       title = "Count of unique words found in tweets")

# separate words and count frequency of word pair occurrence in tweets
vaccineWordPairs = vaccineText %>% 
  mutate(text = removeWords(tolower(text), stop_words$word)) %>%
  unnest_tokens(paired_words, text, token = "ngrams", n = 2) %>%
  separate(paired_words, c("word1", "word2"),sep=" ") %>%
  count(word1, word2, sort=TRUE)

# graph a word cloud with space indicating association.
# you may change the filter to filter more or less than pairs with 30 instances
vaccineWordPairs %>%
  filter(n >= 25 & !is.na(word1) & !is.na(word2)) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n)) +
  geom_node_point(color = "darkslategray4", size = 3) +
  geom_node_text(aes(label = name), vjust = 1.8, size = 3) +
  labs(title = "Word Network of Tweets about COVID-19 Vaccinations",
       x = "", y = "") +
  theme_void()


############# SPATIAL ANALYSIS ############# 

#first, sign up for a Census API here:
# https://api.census.gov/data/key_signup.html
#replace the key text 'yourkey' with your own key!
counties <- get_estimates("county",
                          product="population",
                          output="wide",
                          geometry=TRUE, keep_geo_vars=TRUE, 
                          key="0ba591c76ddf39419606a12d561a9ebdd4e47d82")

# select only the states you want, with FIPS state codes
# look up fips codes here:
# https://en.wikipedia.org/wiki/Federal_Information_Processing_Standard_state_code 
counties = filter(counties,
                  STATEFP != '02',
                  STATEFP != '15')

# save counties to Derived/Public folder
saveRDS(counties, here("data","derived","public","counties.RDS"))

# optionally, load counties from derived/public/counties.RDS
counties = readRDS(here("data","derived","public","counties.RDS"))

# map results with GGPlot
# note: cut_interval is an equal interval classification function, while 
# cut_number is a quantile / equal count function
# you can change the colors, titles, and transparency of points
ggplot() +
  geom_sf(data=counties, aes(fill=cut_number(DENSITY,5)), color="grey")+
  scale_fill_brewer(palette="GnBu")+
  guides(fill=guide_legend(title="Population Density"))+
  geom_point(data = vaccineTweets, aes(x=lng,y=lat),
             colour = 'purple', alpha = .2) +
  labs(title = "Tweet Locations About COVID-19 Vaccinations")+
  theme(plot.title=element_text(hjust=0.5),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())

## Spatial Clustering Analysis for Hurricane Dorian Twitter Analysis
# Code by Joseph Holler (2021) and Casey Lilley (2019)

packages = c("dplyr", "tidyr", "here", "spdep", "sf", "ggplot2")
setdiff(packages, rownames(installed.packages()))
install.packages(setdiff(packages, rownames(installed.packages())),
                 quietly=TRUE)

library(dplyr)
library(tidyr)
library(here)
library(spdep)
library(sf)
library(ggplot2)

######## SPATIAL JOIN TWEETS and COUNTIES ######## 
# This code was developed by Joseph Holler, 2021
# This section may not be necessary if you have already spatially joined
# and calculated normalized tweet rates in PostGIS

# load vaccine tweet data if not already loaded
#vaccineTweets = readRDS(here("data","derived","private","vaccineTweets.RDS"))

vaccineTweets_sf = vaccineTweets %>%
  st_as_sf(coords = c("lng","lat"), crs=4326) %>%  # make point geometries
  st_transform(4269) %>%  # transform to NAD 1983
  st_join(select(counties,GEOID))  # spatially join counties to each tweet

saveRDS(vaccineTweets_sf, "procedure/code/vaccineTweets_sf.rds")

vaccineTweets_by_county = vaccineTweets_sf %>%
  st_drop_geometry() %>%   # drop geometry / make simple table
  group_by(GEOID) %>%      # group by county using GEOID
  summarise(vaccineTweets = n())  # count # of tweets

counties = counties %>%
  left_join(vaccineTweets_by_county, by="GEOID") %>% # join count of tweets to counties
  mutate(vaccineTweets = replace_na(vaccineTweets,0))       # replace nulls with 0's

rm(vaccineTweets_by_county)


####### NOW DO AGAIN FOR MAY DATA#############
may_by_county = may %>% 
  st_as_sf(coords = c("lng","lat"), crs=4326) %>%
  st_transform(4269) %>%
  st_join(select(counties,GEOID)) %>%
  st_drop_geometry() %>%
  group_by(GEOID) %>% 
  summarise(may = n())

counties = counties %>%
  left_join(may_by_county, by="GEOID") %>%
  mutate(nov = replace_na(may,0))

counties = counties %>%
  mutate(vaxTweetRate = vaccineTweets / POP * 10000) %>%  # dorrate is tweets per 10,000
  mutate(ntdi = (vaccineTweets - may) / (vaccineTweets + may)) %>%  # normalized tweet diff
  mutate(ntdi = replace_na(ntdi,0))   # replace NULLs with 0's

# save counties geographic data with derived tweet rates
saveRDS(counties,here("data","derived","public","counties_tweet_counts.RDS"))

# optionally, reload counties
counties = readRDS(here("data","derived","public","counties_tweet_counts.RDS"))

######## SPATIAL CLUSTER ANALYSIS ######## 
# This code was originally developed by Casey Lilley (2019)
# and edited by Joseph Holler (2021)
# See https://caseylilley.github.io/finalproj.html

thresdist = counties %>% 
  st_centroid() %>%     # convert polygons to centroid points
  st_coordinates() %>%  # convert to simple x,y coordinates to play with stdep
  dnearneigh(0, 110, longlat = TRUE) %>%  # use geodesic distance of 110km
  # distance should be long enough for every feature to have >= one neighbor
  include.self()       # include a county in its own neighborhood (for G*)

# three optional steps to view results of nearest neighbors analysis
thresdist # view statistical summary of the nearest neighbors 
plot(counties_sp, border = 'lightgrey')  # plot counties background
plot(selfdist, coords, add=TRUE, col = 'red') # plot nearest neighbor ties

#Create weight matrix from the neighbor objects
dwm = nb2listw(thresdist, zero.policy = T)

######## Local G* Hotspot Analysis ######## 
#Get Ord G* statistic for hot and cold spots
counties$locG = as.vector(localG(counties$vaxTweetRate, listw = dwm, 
                                 zero.policy = TRUE))

# optional step to check summary statistics of the local G score
summary(counties$locG)

# classify G scores by significance values typical of Z-scores
# where 1.15 is at the 0.125 confidence level,
# and 1.95 is at the 0.05 confidence level for two tailed z-scores
# based on Getis and Ord (1995) Doi: 10.1111/j.1538-4632.1992.tb00261.x
# to find other critical values, use the qnorm() function as shown here:
# https://methodenlehre.github.io/SGSCLM-R-course/statistical-distributions.html
# Getis Ord also suggest applying a Bonferroni correction 

siglevel = c(1.15,1.95)
counties = counties %>% 
  mutate(sig = cut(locG, c(min(counties$locG),
                           siglevel[2]*-1,
                           siglevel[1]*-1,
                           siglevel[1],
                           siglevel[2],
                           max(counties$locG))))
rm(siglevel)

# Map hot spots and cold spots!
# breaks and colors from http://michaelminn.net/tutorials/r-point-analysis/
# based on 1.96 as the 95% confidence interval for z-scores
# if your results don't have values in each of the 5 categories, you may need
# to change the values & labels accordingly.
ggplot() +
  geom_sf(data=counties, aes(fill=sig), color="white", lwd=0.1)+
  scale_fill_manual(
    values = c("#0000FF80", "#8080FF80", "#FFFFFF80", "#FF808080", "#FF000080"),
    labels = c("low","", "insignificant","","high"),
    aesthetics = "fill"
  ) +
  guides(fill=guide_legend(title="Hot Spots"))+
  labs(title = "Clusters of COVID-19 Vaccine Twitter Activity")+
  theme(plot.title=element_text(hjust=0.5),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
