# Script Documentation: socialcops_task2_v2.R

This document is a ReadMe file for the script socialcops_task2_v2.R. It aims to describe the code flow and important variables. 

## Code Flow

The R script assumes that the data is present (in the native csv format) in the user's working directory. Downloading from URLs has been omitted to account for differences in path specifications and OS-dependent syntax. 

The code flows as per the following steps:

### Step 1

a. Reading the files in using the read.csv function
b. Using regular expressions, convert the commodity names to uniformity, in order to create a merge ID
c. Write a function to remove outliers (all values of a variable outside the 25-75 percentile, in IQR)
d. Merge in the data using the ID created in step 1b) and sort accordingly. Plot untreated prices (prices_raw.png)
e. Apply the function created in step 1c) using dplyr. Plot the prices thus treated (prices_treated.png)

### Step 2

a. Identify valid APMC-commodity clusters that hold enough data (at least 12 points) to constitute a time series
b. Subset an example cluster
c. Plot the timeseries so obtained (ts_1.png)
d. Perform the ACF and ADF tests to check for stationarity using the library tseries (acf_ts_1.png)
e. Decompose the timeseries (additive and multiplicative - addts.png, multts.png)

### Step 3

a. Plot the additively decomposed deseasonalised prices with raw and minimum support price (deseas_add.png)
b. Plot the mutliplicatively decomposed deseasonalised prices with raw and minimum support price (deseas_mult.png)

### Step 4

a. Flag APMC/Commodity clusters that see the maximum fluctuation in prices, by year (final_out1.csv)
b. Flag APMC/Commodity clusters that see the maximum fluctuation in prices, by year and crop season (final_out2.csv)