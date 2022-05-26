# rbClustering2021

First a thank you to Arjun Menon who wrote the article https://mfootballanalytics.com/2021/07/13/clustering-2020-nfl-running-backs/ and answered a questions in the nflPlotR discord (+ Tan). This code is based off his article and my attempt at recreating it for 2021 to further my understanding of R. 

## Project Overview 

In the code, I utilize the K means clustering alogrithm, which attempts to cluster data points into similar groups based off of selected variables. The variables chosen were from the PFF Rushing grades data set based off of 2021 regular season data with 80 minimum rushing attempts: 

* Yards per Rush Attempt
* Yards after Contact per Rush Attempt
* Number of Runs over 10+ yards
* Targets per Route Run
* Missed Tackle Forced per Rush Attempt 

These variables combine some amount of receiving ability, ability to break tackles, and generate explosive runs to differentiate the running backs in the league. I would be interested to further investigate other variables that may better differentiate the running backs. 

I used the Factoextra library by following this great walk through of KMeans clustering: http://uc-r.github.io/kmeans_clustering to perform kmeans (and some PCA). I would highly recommend, as this simplified the process greatly, especially with the visualizations. 

## tl;dr
Clustering the league running backs fall into 4 main categories: 
* Elite production
* Below average production
* Average production with receiving ability
* Average production without receiving ability 

Now please find the rest of the charts below! 

## Clustering

The number of clusters to utilize is a bit of an art, so here are three approaches: 

* WSS - 6 clusters 
* Silhouette - 2 clusters
* Gap Stat - 1 cluster

Fviz_cluster was used to visually inspect the various number of clusters: 

![image](https://user-images.githubusercontent.com/92967109/169906831-5238889b-94bd-4ccd-b2e1-0d5b73ee4f43.png)

#### Use of 6 Clusters

![image](https://user-images.githubusercontent.com/92967109/170167016-535a94d0-826b-4349-8ea7-83938602894f.png)

#### Cluster Overviews

Here are the cluster overviews: 
![image](https://user-images.githubusercontent.com/92967109/170520669-9648e191-0a15-457f-8eb5-83ec91dd58fe.png)

Cluster 1 - Below average running backs
* Lowest Explosive runs, missed tackles per att,rush yards per att, and yard after contact per att
* Average targets per route run 

Cluster 2 - Above average all around running backs
* Above average in most categories 

Cluster 3 - Elite Running Backs with little receiving production
* Significantly higher in explosive runs, rush yards per attempt, and yard after contact per attempt

Cluster 4 - Slightly better than Cluster 1 without receiving production
* Below average in all categories with minimal targets per route tun

Cluster 5 - Average running backs
* Average in all categories 

Cluster 6 - Average running back with receiving ability
* Average in all categories but highest in targets per route run 

## GT Tables

Next the RB's were added into a GT Table along with their team wordmark

![image](https://user-images.githubusercontent.com/92967109/170170395-0bac8f85-b4ea-4b3c-aea0-7887d3890a62.png)

## RB1's and their Cluster

Next the RB's were filtered into RB 1's from each team: 

![image](https://user-images.githubusercontent.com/92967109/170529648-09b19666-b2b9-4941-a69b-54aa93de26cc.png)

## Rushing Yards Over Expected 

Then the RB's RYOE were averaged and put in another GT Table. RYOE via https://mfbanalytics.shinyapps.io/RYOE/

![image](https://user-images.githubusercontent.com/92967109/170406688-1fcbb305-9d82-47d9-8969-5adcf86ac4a4.png)

We can see ryoe by cluster generally reflects the type of RB we would expect: 

* Cluster 1 - Below average running backs
* Cluster 2 - Above average all around running backs
* Cluster 3 - Elite Running Backs
* Cluster 4 - Slightly better than Cluster 1
* Cluster 5 - Average running backs
* Cluster 6 - Average running backs

## Salary Cap Data

Finally, I wanted to see the ranges of salary for each cluster to get a sense of if a certain contracts typically fall into one type of cluster. 

![image](https://user-images.githubusercontent.com/92967109/170171862-d41f2522-3919-4f3e-94ee-009fd709f9ce.png)

And since I have it, here is where the apy_cap_pct and how it related to RYOE model data to show were you are getting better value from a contract perspective. 

![image](https://user-images.githubusercontent.com/92967109/170160580-1f227f4c-467d-4ffb-86b5-7b6c38e4d5fe.png)

## Conclusion

Overall, this was a great initial dive into Kmeans clustering. I am particularly thankful for people like Arjun,Tej,Tan and others who not only posted interesting content, but have answered multiple questions. 

From the analysis, it is interesting to see where the various RB's fall into relation to each other. It is meant to further explore whether or not you have a 'guy' who is really that different from other running backs out there. There really are only a few outliers (both good and bad), while the rest of the running backs more fall into 2 categories of average with or without receiving ability. 

Hope you enjoyed the content! 








