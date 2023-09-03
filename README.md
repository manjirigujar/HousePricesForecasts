# House Prices Forecasts

## 1. DATA DESCRIPTION WITH EDA
The dataset comprises information on the Median Sales Price of Houses Sold for the United States, spanning from Q1 1963to Q1 2023. It consists of 263 records and includes two columns: 'Date' and 'MSPUS,' representing the respective dates andmedian house prices.
The original dataset's column 'Date' is of type 'Chr' (character), while the 'MSPUS' column is of type'num' (numeric).
We obtained the dataset in a .CSV file format, which was then read and stored for further analysis. As for data quality, thereare no null values or missing entries. The data source for this dataset is the U.S. Department of Housing and UrbanDevelopment, accessible via the FRED website: (Median Sales Price of Houses Sold for the United States (MSPUS) | FRED |St. Louis Fed). The values are measured in dollars and are not seasonally adjusted. The frequency of data collection isquarterly.
### STATISTICS SUMMARY
The minimum price of US house is 17.800 USD in 1969 whilethe maximum price is 479.500 in 2022.
Most of the median house price of the US are from 17.800USD to 317.800 USD, in which the bin 17.800 - 67.800 and117.800 - 167.800 have the highest number of houses.
### TIME SERIES ANALYSIS
After loading the data into the data frame wechecked the summary of the data of MSPUS(HousePrice), we then assigned relevant column names forthe previously known column names ‘Date’ and ‘MSPUS’ to now changed column names ‘Quarter’and ‘House Price’. Then, we converted the dataframe into a tsibble , and converted the data typefrom ‘chr’(Date) and ‘num’(House Price) to ‘<qtr>’(Quarter) and ‘<int>’(House_Price).
After this we plotted this data to get a view on the variance,trend and seasonality. So to get a detailed view of it wecomputed the STL decomposition, on performing the STLdecomposition we understand that the Trend is upwardand increases exponentially over the period of time, sameis the case with variance and we can see there isseasonality in the data.

## 2. MODEL FITTING
We split the data into training and test sets with a 9:1 ratio. Then, we fit three models to the data: 1) Time Series Regression2) Exponential Smoothing, and 3) ARIMA. In addition, we fit various benchmark models to use for determining the optimalapproach. After plotting the data (Figure 1.2) and conducting STL decomposition (Figure 1.3), we observed that the datadoes not show variation that increases or decreases with the level of the series, hence we chose not to use anytransformation on the data. We also fit the four benchmark models (Mean, Naive, Seasonal Naive, and Random walk withdrift) to compare our models’ accuracy to the accuracy of these benchmark models.
### THE TIME SERIES REGRESSION
We used the TSLM() function on the data, generated theforecasts for 26 quarters in the test set, and calculatedthe accuracy on the test set using the accuracy()function from fabletools package. The TSLM model has aRMSE of 89263.16 and MAPE of 20.04.
We conducted residual diagnostics on the model andfound that the residuals do have significantautocorrelation. This is also evident from the p-value ofthe Ljung-Box test, which was 0.
### EXPONENTIAL SMOOTHING
We used the ETS() function on the data to obtain the best-fitmodel. Based on the lowest AICc of 4517.346, the best modelwas determined to be ETS(M,A,M).
We predicted the forecasts for 26 quarters in the test set andcalculated the accuracy on the test set using the accuracy()function from fabletools package. The best fitting ETS modelhas a RMSE of 40690.54 and MAPE of 7.02.
We conducted residual diagnostics on the model and foundthat the residuals do not have significant autocorrelation. Thisis also evident from the p-value of the Ljung-Box test, whichwas 0.0949.
### ARIMA
As part of our EDA we found out whether the data in the timeseries is stationary or not. As per Figure 1.3, we observed thatthe data is not stationary. We also conducted Unit Root Teststo find whether differencing is required for the time series ornot, to make the data stationary. This process of using asequence of KPSS tests to determine the appropriate numberof first differences is carried out using the unitroot_ndiffs()feature. Through this process we determined it wasappropriate to apply first differencing with no seasonaldifferencing required.
We used the ARIMA() function to find the best fitting modelon the transformed data
and we were provided withARIMA(2,1,2)(1,0,1)[4] w/ drift as the best model with an AICc of4173.37. This model provided us with an RMSE of 57378.2 andMAPE of 8.83. After assessing the residuals we were providedwith a p-value of the Ljung-Box test that was greater than0.05, hence we do not reject the null-hypothesis and concludethe residuals do not have autocorrelation.
### BENCHMARK MODELS
It was determined (figure 2.4) that the Random Walkwith Drift model provided us with the lowest RMSE of59850, followed by the Naive Model with 78445.30, theSeasonal Naive Model with 79229.24, and the MeanModel with 243342.43. It is through these values that weare comparing the efficacy of the forecasts provided byour ARIMA and Exponential Smoothing models.

## 3. MODEL SELECTION & FORECASTING
In our time series analysis project on the Median prices of houses sold in the US, we explored the effectiveness of TimeSeries Regression, ETS and ARIMA models. By evaluating the residual diagnostics of all the models, we observed that theETS and ARIMA both capture the underlying dynamics of the data reasonably well. The residual diagnostics for the TSLMshowed that the residuals had autocorrelation and thus did not resemble white noise. However, a comprehensivecomparison of the RMSE and MAPE values led us to conclude that the ETS model outperforms the TSLM and ARIMAmodels in terms of accurate forecasting.
We compared the RMSE and MAPE of all the models includingthe benchmark models and found that the ETS model is moreaccurate. Consequently, we selected the ETS model as our finalchoice and utilized it to generate forecasts for the next sixyears from our training data.
Notably, theETS model demonstrates commendable accuracy in capturingthe anticipated patterns. As we extend the forecast horizon,the prediction intervals naturally widen. This phenomenon isexpected in multi-step predictions, as the wider intervals aimto encompass potential shifts in market conditions, changes incustomer behavior, or the impact of unforeseen events.
Conversely, the ARIMA model'sforecasts (Figure 3.2) primarilyexhibit a straight-line pattern withnarrow prediction intervals. This isdue to the fact that the model onlyaccounts for the variation in theerrors. Although the model mayaccurately capture the overall level ofthe data, it fails to account for thecomplexities arising from trend andseasonality.
The Time Series Linear Regressionmodel’s forecasts (Figure 3.3)captures the increasing trend andseasonality to some extent but it isnot in continuation with the actualdata. The prediction intervals arewide so they do account for theuncertainties affecting the medianprices of houses sold in the US.
As a result, we favored the ETS model due to its superiorperformance in accuratelypredicting the future median houseprices in the US.

## 4. CONCLUSION & LIMITATIONS
### INSIGHTS
The median prices of houses in the US have been influenced by socio-economic factors such as inflation,household income, rising interest rates, and Purchasing Power Parity.
The time series plot indicates
decrease in median house prices starting from 2005, with a significant drop duringthe 2008 recession. Prices started rising again after 2010.
The forecasts obtained from fitting the ETS model align with the increasing trend observed in the time series data.
External research and analysis of economic factors can provide additional insights into the fluctuations and trendsobserved in the median house prices.
### LIMITATIONS
The dataset's focus on median prices restricts the analysis to the impact of time alone on house prices, neglectingother influential factors such as location-specific variables.
Without state or regional data, it becomes difficult to interpret localized fluctuations in house prices based onobserved peaks and declines.
Sole reliance on median values within the dataset fails to represent the entire range of house prices acrossdifferent cities and states in the US from 1969 to 2023. Consequently, the insights provided may lack completeaccuracy when applied to specific areas within the real estate industry. Moreover, accurate predictions wouldrequire the consideration of additional factors like socio-economic conditions, consumer behavior, and thecorrelation between house attributes and prices.
The chosen model may not be fully optimized for predicting median house prices. The limitations of the datasetcan impact the model's accuracy, consequently affecting the effectiveness of the generated forecasts. Since thedataset lacks comprehensive information regarding other influential factors, the model attempts to account forthese variables during forecasting, leading to wider prediction intervals as demonstrated by the ETS model.Therefore, a conservative approach must be adopted when assessing the practicality of the forecasts.
### CONCLUSION
In summary, the median house prices in the US havegenerally increased over time, with a notable decreaseduring the 2008 recession. As the model with lowest RMSEvalue (figure 4.1), we decided to use ETS model in ourforecasting for the next six years. The prediction show thatthe median US house price has an upward trend in the next6-year period..
