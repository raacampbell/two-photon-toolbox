
Do something like


saveZdepths
N=findNuclei(data(1));
[masks,centroids]=centroids2masks(data,centroids)
centroids2masks(data,N.centroid);
addRemoveCentroids(data);
