# Comparing efficiency looping through dataframe rows when vectorizing is not a good option
# Yunfei 2019-07-29

allIterations <- data.frame(v1 = runif(1e5), v2 = runif(1e5))
    
DoSomething <- function(row) {
  someCalculation <- row[["v1"]] + 1
}

# The most efficient way is to use apply. However vectorizing is not always an option.
# Sometimes the syntax is less clean when the function performed involves lots of local variables and assignments.
> system.time(apply(allIterations, 1, DoSomething))
   user  system elapsed 
   0.20    0.00    0.22 
   
# Directly looping through rows by using row numbers is intuitive, but slow as the number of rows go up.
# Reason being R needs to look at the dataframe and find that row, instead of justing taking the next row.
# Most people think R's for loop is always slower than the apply family (which is wrong), because of this common practice when using for loop on dataframes.
> system.time(
+       {
+         for (r in 1:nrow(allIterations)) {
+           DoSomething(allIterations[r, ])
+         }
+       }
+     )
   user  system elapsed 
   4.50    0.02    4.55 

# An interesting finding about data table -- it's much much slower if we do the same.
> allIterations <- as.data.table(allIterations)
> system.time(
+       {
+         for (r in 1:nrow(allIterations)) {
+           DoSomething(allIterations[r, ])
+         }
+       }
+     )
   user  system elapsed 
  53.78   25.05   78.46 

   
# Instead of looping through row numbers and search for that row, we can convert the dataframe into list of rows, and directly loop the function through each item in the row.
# This will save the time to get a particular row in each iteration.
# There needs to be some overhead computing time to convert dataframe into lists.
> system.time(
+       {
+         listOfRows = apply(allIterations, 1, as.list)
+         for (r in listOfRows) {
+           DoSomething(r)
+         }
+       }
+     )
   user  system elapsed 
   0.86    0.00    0.92 
 
 # A faster option is to use purrr::transpose(as.list(allIterations)). 
 > system.time(
+       {
+         listOfRows = purrr::transpose(as.list(allIterations))
+         for (r in listOfRows) {
+           DoSomething(r)
+         }
+       }
+     )
   user  system elapsed 
   0.11    0.00    0.13 

