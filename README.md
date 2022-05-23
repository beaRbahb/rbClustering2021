# rbClustering2021
Initial work on clustering NFL RB's from 2021

First a thank you to Arjun Menon who wrote the article https://mfootballanalytics.com/2021/07/13/clustering-2020-nfl-running-backs/

This code is based off his article and my attempt at recreating it for 2021 to further my understanding of R. 

In the code, I utilize the K means clustering alogrithm, which attempts to cluster data points into similar groups based off of selected variables. The variables chosen were from the PFF Rushing grades data set based off of 2021 regular data: 

* Yards per Rush Attempt
* Yards after Contact per Rush Attempt
* Number of Runs over 10+ yards
* Targets per Route Run
* Missed Tackle Forced per Rush Attempt 

These variables combine some amount of receiving ability, ability to break tackles, and generate explosive runs to differentiate the running backs in the league. 

I used the Factoextra library to perform kmeans (and some PCA). I would highly recommend as this simplified the process greatly. The number of clusters to utilize is a bit of an art, so here are three approaches: 

* WSS - 6 clusters 
* Silhouette - 2 clusters
* Gap Stat - 1 cluster

Fviz_cluster was used to visually inspect the various number of clusters: 

![image](https://user-images.githubusercontent.com/92967109/169906831-5238889b-94bd-4ccd-b2e1-0d5b73ee4f43.png)

5 clusters captured the data pretty well: 
![image](https://user-images.githubusercontent.com/92967109/169907225-e1fcf399-c963-41b7-a836-858e6c598332.png)

Cluster 1
* Add in cluster definitions 

GT Table Time

Next the RB's were added into a GT Table along with their team wordmark

![image](https://user-images.githubusercontent.com/92967109/169908663-07a1e563-7b45-4fa7-be2b-e9ff7368ef45.png)

Next the RB's were filtered into mostly RB 1's from each team: 

![image](https://user-images.githubusercontent.com/92967109/169908587-99663edb-fcf7-47f7-95f9-de37ca42ebed.png)


Then the RB's RYOE were averaged and put in another GT Table: 

![image](https://user-images.githubusercontent.com/92967109/169908706-ca185009-f9b6-428a-9370-d20795ea2583.png)


