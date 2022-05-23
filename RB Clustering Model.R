# Recreating Arjun's RB Clustering model 

library(caTools)
library(gghighlight)
library(ggplot2)
library(ggthemes)
library(tidyverse)
library(factoextra)
library(gridExtra)
library(FactoMineR)
library(nflplotR)
library(nflreadr)

# import pff data
data <- read.csv('/Users/McCay/Downloads/PFF-RushSummary2021.csv')

str(data)

#look at the attempts data 
ggplot(df,aes(attempts)) + geom_histogram(binwidth = 10)

#factor the columns
data$position <- as.factor(data$position)
data$team_name <- as.factor(data$team_name)

# create rate stats
df <- data %>% select(player,yco_attempt,explosive,ypa,targets,routes,attempts,avoided_tackles, position) %>% 
  filter(attempts > 80)
df$tprr <- df$targets / df$routes
df$mtfa <- df$avoided_tackles / df$attempts

#select columns for clustering and
df2 <- df %>% select(player,yco_attempt,explosive,ypa,tprr,mtfa,position) %>% 
  filter(position == 'HB' & tprr > 0)

#standardize the columns 
df3 <- df2 %>% select(-position)
df3 <- column_to_rownames(df3, var = 'player')
df3 <- scale(df3)

#find optimal K values through different methods 
fviz_nbclust(df3,kmeans,method='wss') # 5 clusters
fviz_nbclust(df3,kmeans,method='silhouette') # two clusters
gap_stat <- clusGap(df3,FUN=kmeans,nstart=25,K.max=10,B=50) 
  fviz_gap_stat(gap_stat) # 1 cluster

# create various models of k

k1 <- kmeans(df3, centers = 1, nstart = 25)
k2 <- kmeans(df3, centers = 2, nstart = 25)
k3 <- kmeans(df3, centers = 3, nstart = 25)
k4 <- kmeans(df3, centers = 4, nstart = 25)
k5 <- kmeans(df3, centers = 5, nstart = 25)

# plots to compare the different k values 
p1 <- fviz_cluster(k1, geom = "point",data = df3) + ggtitle("k = 1")
p2 <- fviz_cluster(k2, geom = "point",data = df3) + ggtitle("k = 2")
p3 <- fviz_cluster(k3, geom = "point",data = df3) + ggtitle("k = 3")
p4 <- fviz_cluster(k4, geom = "point",data = df3) + ggtitle("k = 4")
p5 <- fviz_cluster(k5, geom = "point",data = df3) + ggtitle("k = 5")

#put them in a grid to look at them together
grid.arrange(p1, p2, p3,p4,p5, nrow = 3)

#see the labels plotted
fviz_cluster(k5,data=df3)

#add in cluster back to the df3 data
# cbind with df data frame and the 'column name' = the column data you are pulling 
df4 <- as.data.frame(cbind(df3,Cluster = k5$cluster))

#looking further into the pCA that was done

#do the PCA
pcadf4 <- PCA(df4[1:5])
# find the info about the PCA
var <- get_pca_var(pcadf4)
var
# look at how each variable contributed to PCA
var$contrib
#graph the contribution direction by variable
fviz_pca_var(pcadf4, col.var='contrib',
             gradient.cols = c('#00AFBB','#E7B800','#FC4E07'),
             repel = T)
#graph the direction + all the observations 
fviz_pca_biplot(pcadf4, repel = T)

### GT Tables

## get name + cluster + team wordmark and create two dataframes 
gtData <- data %>% 
  filter(position == 'HB' & targets > 0 & attempts > 80) %>% 
  select(player,team_name) %>% 
  mutate(cluster = df4$Cluster) %>% 
  rename(c('team_abbr'='team_name'))

#get the wordmarks data 
wordMarks <- readRDS(url("https://github.com/nflverse/nflfastR-data/raw/master/teams_colors_logos.rds"))

#select team name and wordmark for the join 
wordMarks <- wordMarks %>% 
  select(team_abbr,team_wordmark)

# join the tables by team_abbr amd arrange the data by cluster #
gtData <- merge(x=gtData,y=wordMarks,by='team_abbr') %>% 
  select(player,team_wordmark,cluster) %>% 
  arrange(cluster)

#make two GT tables to I can put them side by side / split in half 
gtData1 <- gtData %>% 
  slice(1:25) %>% 
  gt::gt() %>% 
  gt_img_rows(team_wordmark) %>% 
  opt_all_caps() %>% 
  cols_label(team_wordmark = ' ') %>% 
  tab_header(title='NFL RBs and their Cluster',subtitle = 'Minimum 80 rush attempts') %>% 
  opt_align_table_header(align = 'left') %>% 
  data_color(columns = cluster,colors = scales::col_numeric(palette = c('#187498','#36AE7C','#F8CB2E','#EE5007','#B22727'),domain = c(1,5)))

#second gt 2 table
gtData2 <- gtData %>% 
  slice(26:56) %>% 
  gt::gt() %>% 
  tab_header(title='NFL RBs and their Cluster',subtitle = 'Minimum 80 rush attempts') %>% 
  opt_align_table_header(align = 'left') %>% 
  gt_img_rows(team_wordmark) %>% 
  opt_all_caps() %>% 
  cols_label(team_wordmark = ' ') %>% 
  data_color(columns = cluster,colors = scales::col_numeric(palette = c('#187498','#36AE7C','#F8CB2E','#EE5007','#B22727'),domain = c(1,5)))

# make a list with the two tables (needed for gt_two_column_layout function)
gtLists <- list(gtData1,gtData2)

# make tha table! 
gt_two_column_layout(gtLists)

### RB1 Head graph

#create RB name list from my current HB's in clusters 
rbNames <- gtData$player

# load the players from NFL readr to get the headshot
playerHeadshot <- load_rosters() %>% 
  select(full_name,gsis_id,headshot_url,team)

#fix a few players names that don't match between PFF / nlf readr data 
playerHeadshot[playerHeadshot == 'Mark Ingram'] <- 'Mark Ingram II'
playerHeadshot[playerHeadshot == 'AJ Dillon'] <- 'A.J. Dillon'
playerHeadshot[playerHeadshot == 'Melvin Gordon'] <- 'Melvin Gordon III'

#filter only our clustered RBS
playerHeadshot <- playerHeadshot %>% 
  filter(full_name %in% rbNames) %>% 
  distinct(full_name, .keep_all = TRUE) %>% 
  arrange(full_name)

#re-arrange the data by playername 
gtData <- arrange(gtData,player)

#add in the cluster number 
playerHeadshot$cluster <- gtData$cluster

#Find the RB1 only (used best guess plus depth chart from ESPN in week 1)
rb1data <- read.csv('/Users/McCay/Downloads/RB Data - Sheet2.csv')

#only show the "RB1's" in the headshot data
playerHeadshot <- playerHeadshot %>% 
  filter(full_name %in% rb1data$Name) %>% 
  arrange(full_name)

#create rank in cluster (so there is something for a y variable to put in the headshots)
#sadly there is a much cleaner way to write this
rank1 <- playerHeadshot %>% 
  filter (cluster == 1) %>% 
  mutate(rank = dense_rank(full_name))

rank2 <- playerHeadshot %>% 
  filter (cluster == 2) %>% 
  mutate(rank = dense_rank(full_name))

rank3 <- playerHeadshot %>% 
  filter (cluster == 3) %>% 
  mutate(rank = dense_rank(full_name))

rank4 <- playerHeadshot %>% 
  filter (cluster == 4) %>% 
  mutate(rank = dense_rank(full_name))

rank5 <- playerHeadshot %>% 
  filter (cluster == 5) %>% 
  mutate(rank = dense_rank(full_name))

# add the rank clusters back into one data frame 
playerHeadshot <- rbind(rank1,rank2,rank3,rank4,rank5)

# plot out the data with the stacked headshots / had to nudge the label down a bit for spacing 
ggplot(playerHeadshot, aes(cluster,rank)) +
  geom_text(aes(label = full_name),nudge_y =-.33) + 
  geom_nfl_headshots(aes(player_gsis = gsis_id, width = 0.075))

# RYOE Mean
cluster1ryoeMean <- c(-.35,-.59)
cluster2ryoeMean <- c(-.23,-.53,.14,-.12,-.4,-.71,-.46)
cluster3ryoeMean <- c(.87,1.72)
cluster4ryoeMean <- c(.28,.01,-.18,-.66,.78,-.1,.17,.89,.03)
cluster5ryoeMean <- c(.96,.5,.02,-.24,-.1)

#round them to three digits 
a <- round(mean(cluster1ryoeMean),3)
b <- round(mean(cluster2ryoeMean),3)
c <- round(mean(cluster3ryoeMean),3)
d <- round(mean(cluster4ryoeMean),3)
e <- round(mean(cluster5ryoeMean),3)

#graph them 
gtDataRyoe <- as.data.frame(c(a,b,c,d,e))
names(gtDataRyoe)[1] <- 'Cluster Mean Ryoe'

#add the cluster value to the dataframe
gtDataRyoe$cluster <- c(1,2,3,4,5)

#make a new gt table with Hulk color palette 
gtDataRyoe %>% 
  gt::gt() %>% 
  tab_header(title='Cluster RYOE Averages') %>% 
  opt_align_table_header(align = 'left') %>% 
  opt_all_caps() %>% 
  gt_hulk_col_numeric(columns = 'Cluster Mean Ryoe')






