
#Loading the necessary libraries
library(tidyverse) 
library(fpp3)
library(dplyr)
library(fable)
library(ggplot2)
library(forecast)

###########################################################################################
#Data Cleaning and Exploratory Data Analysis

#Reading the data from the csv file
data_raw <- read.csv("MSPUS.csv", header = TRUE)

head(data_raw, 10)

#Converting the date column from string to Date datatype 
data_raw$DATE <- as.Date(data_raw$DATE)

#Converting the dataframe to a tsibble
house_ts <- data_raw %>%
  mutate(DATE = yearquarter(DATE)) %>%
  as_tsibble(index = DATE)

#Changing the column names
colnames(house_ts) <- c("quarter", "price")

head(house_ts)

#Plotting the time series data
house_ts %>%
  autoplot(price) + labs(title = "Median House Price in the US", y = "Price in Dollars")

#Conducting STL Decomposition and analysis
house_stl <- house_ts %>%
  model(stl = STL(price))
components(house_stl)%>%
  autoplot()

house_stl <- house_ts %>%
  model(stl = STL(price))
head(components(house_stl),10)

tail(house_ts, 20)

head(house_ts)

#Splitting the data into train and test sets in 9:1 ratio
train <- house_ts %>%
  filter_index("1963 Q1" ~ "2016 Q3")
test <- house_ts%>%
  filter_index("2016 Q4" ~ "2023 Q1")

autoplot(train, .vars = price)


# #Calculating the lamda to use in boxcox transformation
# lambda <- train %>%
#   features(price, features = guerrero) %>%
#   pull(lambda_guerrero)
# lambda
# 
# train %>%
#   autoplot(box_cox(price, lambda)) +
#   labs(y = "",
#        title = latex2exp::TeX(paste0(
#          "Transformed median house prices with $\\lambda$ = ",
#          round(lambda,2))))

tail(train)
head(test)
###########################################################################################

# **TSLM Model**

tslm_fit <- train %>%
  model(TSLM(price ~ trend() + season())) %>%
  report()


augment(tslm_fit) %>%
  features(.resid, ljung_box, lag = 8)

augment(tslm_fit) %>%
  features(.innov, ljung_box, lag = 8)

tslm_fit %>%
  gg_tsresiduals()

tslm_fc <- tslm_fit %>%
  forecast(h = 26)
tslm_fc

tslm_acc <- fabletools::accuracy(tslm_fc, test)
tslm_acc$RMSE
round(tslm_acc$MAPE,2)

 #Plotting the forecasts and the prediction intervals
tslm <- train %>%
  model(TSLM(price ~ trend() + season()))%>%
  forecast(h = 26) %>%
  autoplot(train)+
  labs(title="Median Price of Houses Sold in the US",
       y="Price in Dollars")
tslm

###########################################################################################
# **Exponential Smoothing Model**

#Fitting the best ETS Model using ETS() function without transformation

ets_fit <- train%>%
  model(ETS(price))%>%
  report()

#Conducting Residual Diagnostics and Ljung-Box test
augment(ets_fit) %>%
  features(.innov,ljung_box, lag = 8)

#Conducting Residual Diagnostics and Ljung-Box test
ets_fit %>%
  gg_tsresiduals()

augment(ets_fit) %>%
  features(.innov, ljung_box, lag = 8)

augment(ets_fit) %>%
  features(.resid, ljung_box, lag = 8)

#Predicting the forecasts using the forecast() function
ets_fc <- ets_fit%>%
  forecast(h=26)
ets_fc

#Plotting the forecasts and the prediction intervals
fit <- train %>%
  model(ETS(price ~ error("M") + trend("A") + season("M")))%>%
  forecast(h = 26) %>%
  autoplot(train)+
  labs(title="Median Price of Houses Sold in the US",
       y="Price in Dollars")
fit

#Calculating the accuracy of the forecast values
ets_acc <- fabletools::accuracy(ets_fc, test)
round(ets_acc$RMSE, 5)
round(ets_acc$MAPE, 2)
#The AICc of the ETS model on transformed data is 4517.346 and the RMSE and MAPE are 40690.54 and 7.01706, respectively.

###############################################################################################################
# # **ARIMA**

#Plotting the ACF plots to find the period of seasonality
train %>%
  ACF(price) %>%
  autoplot() + labs(subtitle = "Median House Prices")

train%>%
  ACF(difference(price)) %>%
  autoplot() + labs(subtitle = "Changes in the Median House Prices")

train%>%
  mutate(diff_price = difference(price)) %>%
  features(diff_price, ljung_box, lag = 8)

#Conducting unitroot tests to find the degree of differencing required for the data
train %>%
  features(price,unitroot_kpss)

train%>%
  mutate(diff_price = difference(price)) %>%
  features(diff_price,unitroot_kpss)

train%>%
  features(price,unitroot_ndiffs)

train %>%
  mutate(diff_price = difference(difference(price))) %>%
  features(diff_price,unitroot_kpss)

train%>%
  mutate(diff_price = difference(log(price))) %>%
  features(diff_price,unitroot_kpss)

train%>%
  mutate(log_price = log(price)) %>%
  features(log_price, unitroot_nsdiffs) #no differencing required for the seasonal component

#Plotting the ACF and PACF plots
train%>%
  gg_tsdisplay(difference(difference(price)), plot_type='partial')

#Finding and fitting the ARIMA model using the ARIMA() function from fable library
# arima_fit <- train %>%
#   model("fit1" = ARIMA(price ~ pdq(0,2,0)),
#         "fit2" = ARIMA(price ~ pdq(1,2,0)),
#         "fit3" = ARIMA(price ~ pdq(2,2,0)),
#         "fit4" = ARIMA(price ~ pdq(0,2,1)),
#         "fit5" = ARIMA(price ~ pdq(2,2,0)),
#         "fit6" = ARIMA(price ~ pdq(2,2,1)),
#         "fit7" = ARIMA(price ~ pdq(2,2,2)),
#         "fit8" = ARIMA(price ~ pdq(0,2,2)),
#         "fit9" = ARIMA(price),
#         "fit10" = ARIMA(price, stepwise = FALSE))

arima_fit <- train %>%
  model("fit1" = ARIMA(price ~ pdq(0,1,0)),
        "fit2" = ARIMA(price ~ pdq(1,1,0)),
        "fit3" = ARIMA(price ~ pdq(2,1,0)),
        "fit4" = ARIMA(price ~ pdq(0,1,1)),
        "fit5" = ARIMA(price ~ pdq(1,1,1)),
        "fit6" = ARIMA(price ~ pdq(2,1,1)),
        "fit7" = ARIMA(price ~ pdq(0,1,2)),
        "fit8" = ARIMA(price ~ pdq(1,1,2)),
        "fit9" = ARIMA(price ~ pdq(2,1,2)),
        "fit10" = ARIMA(price, stepwise = FALSE),
        "fit11" = ARIMA(price))

glance(arima_fit) %>% arrange(AICc)
arima_fit %>%
  select(fit9) %>%
  report()
arima_fit
#Conducting Residual Diagnosis and Ljung-box test to find whether the residuals resemble white noise or not
arima_fit %>%
  select(fit9) %>%
  gg_tsresiduals()

arima_fit %>%
  select(fit9) %>%
  augment() %>%
  features(.resid, ljung_box, lag = 8, dof = 4)

arima_fit %>%
  select(fit9) %>%
  augment() %>%
  features(.innov, ljung_box, lag = 8, dof = 4)

#The p-value of the Ljung-Box test is greater than 0.05, hence we do not reject the null-hypothesis that the residuals resemble white noise. 
#We move on predict the forecasts 

arima_fc <- arima_fit %>% select(fit8) %>% forecast(h=26)
arima_fc

#Calculating the accuracy of the ARIMA Model
arima_acc <- fabletools::accuracy(arima_fc,test)
arima_acc $RMSE
round(arima_acc$MAPE,2)

#Plotting the forecasts and the prediction intervals
arima_fit %>% 
  select(fit9) %>%
  forecast(h=26) %>% 
  autoplot(train) + 
  labs(title = "Median Price of Houses Sold in the US", y="Price in Dollars")

#The AICc of the ARIMA model is -82.08 and the RMSE and the MAPE are 364873 and 100.

# Compare RMSE and MAPE values
min_value_rmse <- min(ets_acc$RMSE, arima_acc$RMSE)
min_value_rmse
min_value_mape <- min(ets_acc$MAPE, arima_acc$MAPE)
min_value_mape

#After comparing the two models we find that the ETS model seems to be the slightly more accurate model based on the test set RMSE and MAPE. Hence, we select ETS as our final model.

#################################################################################

ushp_benchmark <- train %>%
  model(
    Mean = MEAN(price),
    Naive = NAIVE(price),
    Drift = RW(price ~ drift()),
    Seasonal_Naive = SNAIVE(price)
  )


fc <- ushp_benchmark %>%
  forecast(h = 26)
fc

ushp_benchmark <- train %>%
  model(
    Mean = MEAN(price),
    Naive = NAIVE(price),
    Drift = RW(price ~ drift()),
    Seasonal_Naive = SNAIVE(price)
  ) %>%
  forecast(h = 26) %>%
  autoplot(train, level = NULL) + 
  labs(title = "Median House Prices", y = "Price in Dollars") +
  guides(colour = guide_legend(title = "Forecast"))

ushp_benchmark

benchmark <- fabletools::accuracy(fc,test) %>% arrange(RMSE)
benchmark
min_rmse <- min(benchmark$RMSE)
min_rmse

benchmark <- fabletools::accuracy(fc,test) %>% arrange(RMSE)
benchmark
drift_accuracy <- benchmark %>%
  filter(.model == "Drift")
drift_accuracy
naive_accuracy <- benchmark %>%
  filter(.model == "Naive")
naive_accuracy
snaive_accuracy <- benchmark %>%
  filter(.model == "Seasonal_Naive")
snaive_accuracy
mean_accuracy <- benchmark %>%
  filter(.model == "Mean")
mean_accuracy

min_mape <- min(benchmark$MAPE)
min_mape
min<-min("ETS" = ets_acc$RMSE, "ARIMA" = arima_acc$RMSE, "Bechmark" = min_rmse, tslm_acc$RMSE)
min

# Create a data frame with the accuracy measures for each model
data <- data.frame(Model = c("TSLM", "ETS", "ARIMA", "Drift", "Naive", "Seasonal Naive", "Mean"),
                   RMSE = c(tslm_acc$RMSE, ets_acc$RMSE, arima_acc$RMSE, drift_accuracy$RMSE, naive_accuracy$RMSE, snaive_accuracy$RMSE, mean_accuracy$RMSE),
                   MAPE = c(tslm_acc$MAPE, ets_acc$MAPE, arima_acc$MAPE, drift_accuracy$MAPE, naive_accuracy$MAPE, snaive_accuracy$MAPE, mean_accuracy$MAPE))

# Set the row names to be the Model column
row.names(data) <- data$Model

# Remove the Model column
data$Model <- NULL

# Sort the data frame by the RMSE and MAE columns in ascending order
data <- data[order(data$RMSE, data$MAPE), ]

# Print the resulting table
data

