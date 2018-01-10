###packages to import
library("RMySQL");
library(Matrix);
library(reshape2);

###Creating MySQL connection
connection <- dbConnect(MySQL(), user = "xxx", password = "xxx", host = "xxx", port = 3306, dbname = "FAERS"); ##Connection to MySQL
###Fetching Data from MySQL Connection
Total_Data <- dbGetQuery(connection, "Select ISR, DrugName from RS01_TEMP1_UNIQUEISR_DRUGNAME where ISR in (Select ISR from RS01_TEMP1_ISR_OUTCOMESCODES) order by ISR;"); # All Id, ISR & Drug_Names
Distinct_DrugNames <- dbGetQuery(connection, "Select distinct DrugName from RS01_TEMP1_UNIQUEISR_DRUGNAME where ISR in (Select ISR from RS01_TEMP1_ISR_OUTCOMESCODES);");# All Distinct DrugNames

###Unlisting
Distinct_DrugNames <- unlist(Distinct_DrugNames)

###createing a dataframe
#People_dead <- as.data.frame(People_dead);

### create two vectors of length 21
start <- vector(mode = "numeric", length = 21)
end <- vector(mode = "numeric", length = 21)

###loop to find the ISR to seperate the whole dataframe into 27 parts and such that each part has no overlapping of ISR's
for(i in 1:21)
{
  if(i==1){ st <- 1
  ed <- 1000000}
  
  if(i==21)
  { start[i] <- end[i-1] +1
  end[i] <- 20118747 #this is count(*) in CorrectDrugs table.
  break}
  
  repeat{
    t1 <- if(Total_Data[ed,2]==Total_Data[ed+1,2]) 1 else 0
    if(t1==0){break}
    ed = ed +1
  }
  end[i] <- ed
  start[i] <- st
  st <- ed + 1
  ed <- ed + 1000000
}

### Creating a vector to create a vector of 23 runs. Run1,Run2...Run23 as follows
sp.names <- paste("Run",1:length(start),sep = "")

###removing extra variables
remove(ed)
remove(st)
remove(i)
remove(t1)
### To calculate the time taken
start.time <- Sys.time()

### This loop will take each part of dataframe convert it into wide format then add the columns which are not present in that wide format
### then create a sparse matrix of that dataframe as Run1,Run2...Run23 for each part respectively.
for (i in 1:21)
{ ## Long to Wide format dataframe
  Total_Data_Wide <- dcast(Total_Data[start[i]:end[i],c("ISR","DrugName")], ISR~DrugName, drop = TRUE ,value.var = "DrugName")
  ## remove ISR column from the dataframe
  Total_Data_Wide <- subset(Total_Data_Wide, select = -1)
  ## Fill 1 where Wide format Dataframe has some value which is not NA
  Total_Data_Wide[!is.na.data.frame(Total_Data_Wide)] <- 1
  ## Get all Column names which are not present in Wide format dataframe into x
  x <- setdiff(Distinct_DrugNames,colnames(Total_Data_Wide))
  ## Add those all columns into Wide format dataframe and fill NA as values in them
  Total_Data_Wide[,x]<- NA
  ## ordering the column names in dataframe as in DistinctDrugNames 
  Total_Data_Wide <- Total_Data_Wide[Distinct_DrugNames]
  ## replace all NA values with 0 to create a sparse matrix
  Total_Data_Wide[is.na.data.frame(Total_Data_Wide)] <- 0
  ## convert dataframe to numeric as currently its not in numeric format we need it to create a sparse matrix
  Total_Data_Wide <- data.matrix(Total_Data_Wide)
  ## creating sparse matrix from Total_Data_Wide after making it in Matrix format
  Sparse_Matrix = Matrix(Total_Data_Wide, sparse = TRUE)
  ## removeing Total_Data_Wide to free up space
  remove(Total_Data_Wide)
  ## assign the sparse matrix as Run1,Run2...Run23 respectively
  assign(sp.names[i],Sparse_Matrix)
  ## remove the sparse matrix
  remove(Sparse_Matrix)
  ## print to get the progress of loop
  print("Number of times loop ran :")
}
## calcluating total time needed
end.time <- Sys.time()
time.taken <- start.time - end.time
time.taken

## To combine all sparse matrix obtained to get one final SparseMatrix as Final_Sparse_Matrix
Final_Sparse_Matrix <- rbind2(Run1,Run2)
Final_Sparse_Matrix <- rbind2(Final_Sparse_Matrix,Run3)
Final_Sparse_Matrix <- rbind2(Final_Sparse_Matrix,Run4)
Final_Sparse_Matrix <- rbind2(Final_Sparse_Matrix,Run5)
Final_Sparse_Matrix <- rbind2(Final_Sparse_Matrix,Run6)
Final_Sparse_Matrix <- rbind2(Final_Sparse_Matrix,Run7)
Final_Sparse_Matrix <- rbind2(Final_Sparse_Matrix,Run8)
Final_Sparse_Matrix <- rbind2(Final_Sparse_Matrix,Run9)
Final_Sparse_Matrix <- rbind2(Final_Sparse_Matrix,Run10)
Final_Sparse_Matrix <- rbind2(Final_Sparse_Matrix,Run11)
Final_Sparse_Matrix <- rbind2(Final_Sparse_Matrix,Run12)
Final_Sparse_Matrix <- rbind2(Final_Sparse_Matrix,Run13)
Final_Sparse_Matrix <- rbind2(Final_Sparse_Matrix,Run14)
Final_Sparse_Matrix <- rbind2(Final_Sparse_Matrix,Run15)
Final_Sparse_Matrix <- rbind2(Final_Sparse_Matrix,Run16)
Final_Sparse_Matrix <- rbind2(Final_Sparse_Matrix,Run17)
Final_Sparse_Matrix <- rbind2(Final_Sparse_Matrix,Run18)
Final_Sparse_Matrix <- rbind2(Final_Sparse_Matrix,Run19)
Final_Sparse_Matrix <- rbind2(Final_Sparse_Matrix,Run20)
Final_Sparse_Matrix <- rbind2(Final_Sparse_Matrix,Run21)

##removing objects/variables to free some RAM
remove(Total_Data)
remove(Run1)
remove(Run2)
remove(Run3)
remove(Run4)
remove(Run5)
remove(Run6)
remove(Run7)
remove(Run8)
remove(Run9)
remove(Run10)
remove(Run11)
remove(Run12)
remove(Run13)
remove(Run14)
remove(Run15)
remove(Run16)
remove(Run17)
remove(Run18)
remove(Run19)
remove(Run20)
remove(Run21)
remove(end)
remove(end.time)
remove(i)
remove(sp.names)
remove(start)
remove(start.time)
remove(time.taken)
remove(x)

### Createing a sparse of people dead
People_Dead <- dbGetQuery(connection, "select ISR, MAX(OutcomeCode) as Score from RS01_TEMP1_ISR_OUTCOMESCODES group by ISR order by ISR;");
People_Dead <- subset(People_Dead, select = -1)
People_Dead <- data.matrix(People_Dead);
M2_OutCome_Code_Sparse_Matrix <- Matrix(People_Dead, sparse = TRUE)

# Renaming DrugName sparse matrix for more clarity
M2_Drugname_Sparse_Matrix <- Final_Sparse_Matrix

###Combining both sparse matrix
M2_Sparse_Data <- cbind2(M2_OutCome_Code_Sparse_Matrix, M2_Drugname_Sparse_Matrix)

## Removing some no more needed objects or variables
remove(connection)
remove(Final_Sparse_Matrix)
remove(People_Dead)
