library(readr)

data <- read_csv("finalv1.csv")

data.flip <- data[data$flipped == TRUE,]
data.flip.rep <- data.flip[data.flip$party == "REPUBLICAN",]
data.flip.dem <- data.flip[data.flip$party == "DEMOCRAT",]

data.notflip <- data[data$flipped == FALSE,]
data.notflip.rep <- data.notflip[data.notflip$party == "REPUBLICAN",]
data.notflip.dem <- data.notflip[data.notflip$party == "DEMOCRAT",]


flip.rep.mean <- colMeans(data.flip.rep[,c("WC","BC","AIC", "AC", "NH", "OC", "TMC")])
flip.dem.mean <- colMeans(data.flip.dem[,c("WC","BC","AIC", "AC", "NH", "OC", "TMC")])

notflip.rep.mean <- colMeans(data.notflip.rep[,c("WC","BC","AIC", "AC", "NH", "OC", "TMC")])
notflip.dem.mean <- colMeans(data.notflip.dem[,c("WC","BC","AIC", "AC", "NH", "OC", "TMC")])


repub_employ <- notflip.rep.mean - flip.dem.mean
dem_employ <- notflip.dem.mean - flip.rep.mean

repub_employ
dem_employ
