# Sparse_Matrix
This repository contains code for creating sparse matrix in R from a data set that has more than 38 million of rows FAERS Database.

Note: Original Dataframe was converted from Long format to Wide format this reduced the number of iterations needed(from 38 to 21 iterations 1 million rows in each iteration) and we wanted to use this representation of data for further analysis.

It is also possible to do all 38 million rows converted at once but the machine i use has a limited RAM and R loads all its data in RAM so imagine a (38 Million rows and 2 columns) dataframe converted to (21 million rows and 3110 column) dataframe the space needed to hold that kind of data strucutre in RAM then performing Neural networks or SVM on them.
