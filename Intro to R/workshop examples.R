library("Hmisc")
getHdata(FEV)
#FEV example
mean(FEV$fev)
median(FEV$fev)
summary(FEV$fev)
plot(x=FEV$height, y=FEV$fev)
class(FEV$height)
class(FEV$sex)
class(FEV$smoke)
str(FEV)

FEV$height2<-round(FEV$height/12, digits = 2)
View(FEV)
plot(x=FEV$height2, y=FEV$fev)

#MTCARS example
# Find dataset using the command - datasets::mtcars.
datasets::mtcars
# Use the help console to see a description of the variables
?datasets::mtcars
# Assign this data set the name cardata
cardata<-datasets::mtcars
# The variable wt gives us weight in lb/1000. Convert this variable to be the weigth in lbs.
cardata$wt<-cardata$wt*1000
# Plot y=mpg vs. x=wt (in lbs not lbs/1000)
plot(x=cardata$wt, y=cardata$mpg)
p1<-plot(x=cardata$wt, y=cardata$mpg)
# Make a new data frame named carsubset that only includes the variables mpg, cyl and hp for the first 10 cars.
carsubset<-data.frame(cardata$mpg, cardata$cyl,cardata$hp)
rownames(carsubset)<-rownames(cardata)
carsubset<-carsubset[1:10,]
# Find the mean mpg for the carsubset data.
mean(carsubset$cardata.mpg)
# make a histogram for cylinders. 
hist(carsubset$cardata.cyl)
#In R markdown create a pdf document with the carsubset dataframe 
#displayed as a nice table (use kable function in knitr package).

