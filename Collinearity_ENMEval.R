#### SET UP ####
library(easypackages)
libraries("raster", "sf", "tmap", "dplyr", "usdm", "rgdal", "usdm",
          "sdmpredictors", "PNWColors", "corrplot", "Cairo")

# working directories
setwd("Z:/Courtney/Stuart_MSc_Ch1/")
rasterOptions(tmpdir = "Z:/Courtney/Stuart_MSc_Ch1/Temp/") # temporary working directory for raster package
csv_wd = "Z:/Courtney/Stuart_MSc_Ch1/GitHub/FL_Habitat_Suitability/Data/" # for writing out tabular data
train_wd = "Z:/Courtney/Stuart_MSc_Ch1/Modeling_Data/Training/" # for writing out training data
test_wd = "Z:/Courtney/Stuart_MSc_Ch1/Modeling_Data/Testing/" # for writing out testing data
plots_wd = "Z:/Courtney/Stuart_MSc_Ch1/GitHub/FL_Habitat_Suitability/Figures/"
temp_wd = "Z:/Courtney/Stuart_MSc_Ch1/Temp/"

# save PROJ.4 string for standard projection (ESPG:26958 NAD 83/Florida East) and source LAT/LON data (EPSG:4326 WGS 84/World Geodetic System 1984)
my_crs = CRS("+init=epsg:26958")
gcs = CRS("+init=epsg:4326")

# load environmental rasters from training area
habitat = raster(paste0(train_wd, "Environmental/Habitat.asc"))
mg_dist = raster(paste0(train_wd, "Environmental/Mangrove_Dist.asc"))
depth = raster(paste0(train_wd, "Environmental/Depth.asc"))
sd_depth = raster(paste0(train_wd, "Environmental/SD_Depth.asc"))
slope = raster(paste0(train_wd, "Environmental/Slope.asc"))
curvature = raster(paste0(train_wd, "Environmental/Curvature.asc"))
plan_curve = raster(paste0(train_wd, "Environmental/Plan_Curve.asc"))
bpi_fine = raster(paste0(train_wd, "Environmental/BPI_Fine.asc"))
bpi_broad = raster(paste0(train_wd, "Environmental/BPI_Broad.asc"))
rugosity = raster(paste0(train_wd, "Environmental/Rugosity.asc"))
sum_temp = raster(paste0(train_wd, "Environmental/Mean_Sum_Temp.asc"))
sum_do = raster(paste0(train_wd, "Environmental/Mean_Sum_DO.asc"))
sum_sal = raster(paste0(train_wd, "Environmental/Mean_Sum_Sal.asc"))
win_temp = raster(paste0(train_wd, "Environmental/Mean_Win_Temp.asc"))
win_do = raster(paste0(train_wd, "Environmental/Mean_Win_DO.asc"))
win_sal = raster(paste0(train_wd, "Environmental/Mean_Win_Sal.asc"))

# define crs
crs(habitat) = my_crs
crs(mg_dist) = my_crs
crs(depth) = my_crs
crs(sd_depth) = my_crs
crs(slope) = my_crs
crs(curvature) = my_crs
crs(plan_curve) = my_crs
crs(bpi_fine) = my_crs
crs(bpi_broad) = my_crs
crs(rugosity) = my_crs
crs(sum_temp) = my_crs
crs(sum_do) = my_crs
crs(sum_sal) = my_crs
crs(win_temp) = my_crs
crs(win_do) = my_crs
crs(win_sal) = my_crs

# create raster stack for training area
env = stack(x = c(habitat, mg_dist, depth, sd_depth, slope, curvature, 
                  plan_curve, bpi_fine, bpi_broad, rugosity, sum_temp, sum_do, 
                  sum_sal, win_temp, win_do, win_sal))

#### CORRELATION AND VIF ####
set.seed(42) 

# full pearson correlation matrix on all spatial predictors from the training area
pearson = pearson_correlation_matrix(env)
head(pearson)

# plot full correlation matrix
palette = pnw_palette("Shuksan2", 200, type = "continuous")
par(mar=c(0,0,0,0))
corrplot(pearson, method = "color", col = palette, type = "upper",
         order = "original", addCoef.col = "black", number.cex = 0.55, 
         number.digits = 2, tl.col = "black", tl.srt = 40, tl.cex = 0.8)
# save plot as png
Cairo(file=paste0(plots_wd, "Full_Pearson_Correlation_Matrix.png"), 
      bg="white",
      type="png",
      units="in", 
      width=6, 
      height=5, 
      pointsize=12, 
      dpi=600)
par(mar=c(0,0,0,0))
corrplot(pearson, method = "color", col = palette, type = "upper",
         order = "original", addCoef.col = "black", number.cex = 0.55, 
         number.digits = 2, tl.col = "black", tl.srt = 40, tl.cex = 0.8)
dev.off()

# save as CSV
write.csv(pearson, paste0(csv_wd, "Full_Pearson_Correlation_Matrix.csv"))

## examine correlation coefficients and variance inflation factors (VIF)
#install.packages('usdm')
library(usdm)

vif = vif(env, maxobservations = 10000)
vif
vifcor = vifcor(env, th = abs(0.7), maxobservations = 10000) 
vifcor
write.csv(vif, paste0(csv_wd, "Full_VIF.csv"), row.names = F)

# reduce predictors that exceeded correlation and VIF thresholds
# removing DO for both seasons, SD depth, plan curvature, winter temps
env2 = stack(x = c(habitat, mg_dist, depth, slope, curvature, bpi_fine, 
                   bpi_broad, rugosity, sum_temp, sum_sal, win_sal))

# reduced correlation matrix
pearson2 = (pearson_correlation_matrix(env2))
head(pearson2)

# plot and save the reduced correlation matrix
corrplot(pearson2, method = "color", col = palette, type = "upper",
         order = "original", addCoef.col = "black", number.cex = 0.55, 
         number.digits = 2, tl.col = "black", tl.srt = 40, tl.cex = 0.8)
Cairo(file=paste0(plots_wd, "Reduced_Pearson_Correlation_Matrix.png"), 
      bg="white",
      type="png",
      units="in", 
      width=6, 
      height=5, 
      pointsize=12, 
      dpi=300)
par(mar=c(0,0,0,0))
corrplot(pearson2, method = "color", col = palette, type = "upper",
         order = "original", addCoef.col = "black", number.cex = 0.55, 
         number.digits = 2, tl.col = "black", tl.srt = 40, tl.cex = 0.8)
dev.off()

# save csv 
write.csv(pearson2, paste0(csv_wd, "Reduced_Pearson_Correlation_Matrix.csv"))

# explore correlation coefficients and VIFs
vif2 = vif(env2, maxobservations = 10000)
vif2
vifcor2 = vifcor(env2, th = abs(0.7), maxobservations = 10000)
vifcor2
write.csv(vif2, paste0(csv_wd, "Reduced_VIF.csv"), row.names = F)

#### ENM EVALUTATE ####
#install.packages("rJava", dependencies = T)
#install.packages("ENMeval", dependecies = T)
#Sys.setenv(JAVA_HOME="C:/Program Files/Java/jdk-15.0.2/")
library(rJava)
library(ENMeval)

# need rJava first, find the dismo directory and move the maxent.jar file there (manually)
system.file("java", package = "dismo")

# Evaluate what the best settings are for MaxEnt 
# need to read in the bias file created based on the distribution of survey effort, 
# this will guide the selection of background points by MaxEnt
bias = raster(paste0(train_wd, "Occurrences/bias.asc"))
crs(bias) = my_crs

# how many possible background points are available? 
length(which(!is.na(values(subset(env2, 1)))))

# study domain is very large, so select 10,000 background points (the base settings for MaxEnt)
bg = xyFromCell(bias, sample(which(!is.na(values(subset(env2, 1)))), 10000,
                             prob = values(bias)[!is.na(values(subset(env2, 1)))]))

rm(env)

# run evaluation using 10-fold cross-validation & background points selected based
# on bias file. Remember to specify that variable 1 in the raster stack (habitat) 
# is categorical and use only the presence data !
enm_wd = "Z:/Courtney/Stuart_MSc_Ch1/ENMevaluate/"

lg_pres_only = read.csv(paste0(train_wd, "Occurrences/Presence_Only/Subadult_Gray_Snapper_PO_Train.csv"))[,-1]
lg_enm_eval = ENMevaluate(lg_pres_only, env2, method = "randomkfold", kfolds = 10,
                       categoricals = 1, algorithm = 'maxent.jar', bg.coords = bg,
                       RMvalues = c(0.25, 0.50, 1.00, 1.50, 2.00, 5.00),
                       fc = c("L", "LQ", "H", "LQH", "LQHP", "LQHPT"), parallel = TRUE, numCores = 15)
write.csv(lg_enm_eval@results, paste(enm_wd, "lg_enmeval_results.csv"))
rm(lg_enm_eval)

hs_pres_only = read.csv(paste0(train_wd, "Occurrences/Presence_Only/Subadult_Bluestriped_Grunt_PO_Train.csv"))[,-1]
hs_enm_eval = ENMevaluate(hs_pres_only, env2, method = "randomkfold", kfolds = 10,
                          categoricals = 1, algorithm = 'maxent.jar', bg.coords = bg,
                          RMvalues = c(0.25, 0.50, 1.00, 1.50, 2.00, 5.00),
                          fc = c("L", "LQ", "H", "LQH", "LQHP", "LQHPT"), parallel = TRUE, numCores = 15)
write.csv(hs_enm_eval@results, paste(enm_wd, "hs_enmeval_results.csv"))