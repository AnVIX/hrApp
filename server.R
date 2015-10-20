#------------------------------------------------------------
# server.R source file for 'hospialRank' Shiny application
#------------------------------------------------------------

# Require libraries
library(shiny)
library(curl)
library(ggplot2)

# Read dataset from location: Google Drive (for now)
fileURL <- "https://drive.google.com/file/d/0B7e-zWxmqAW6N2hKTDJUR2hRdU0/view?pli=1"
id <- regmatches(fileURL, gregexpr("0.*0", fileURL))
gURL <- sprintf("https://docs.google.com/uc?id=%s&export=download", id)
con <- curl(gURL)
hospitals <- read.csv(con, colClasses="character")

# Helper function to parse variable of outcome
colNames <- tolower((colnames(hospitals)))
colNames <- gsub("\\.", " ", colNames, perl=TRUE)
varParse <- function(x){
  grep(paste0("^hospital.*death.*(",
              tolower(as.character(x)),")$"), colNames, 
              perl=TRUE)
}

# Subset data according to state
result.tab <- data.frame()
data_State <- split(hospitals, hospitals$State)
validState <- unique(hospitals$State)

# Begin Shiny unnamed function definition
shinyServer(function(input, output) {

  # Reactive function for data processing 
  procData <- reactive({
              colIndex <- varParse(input$var)                            
              # Rank hospitals for each state  
              if( as.numeric(input$radio) == 2 ){
                  validState <- as.character(input$zip)}                            
              for( i in seq_len(length(validState)) ){                
                # Nation or State condition
                if( as.numeric(input$radio) == 2 ){
                    state <- validState}
                else{state <- sort(unique(hospitals$State))[i]}              
                data_SS <- data_State[[state]]
                ouDat <- suppressWarnings(
                                as.numeric(data_SS[,colIndex]))                 
                # Keep only complete cases (remove NA's)
                ccL <- complete.cases(ouDat,data_SS$Hospital.Name)            
                # Order and handle ties (alphabetical)
                ranks <- order(ouDat[ccL])      
                hospital.rank <- 
                data_SS$Hospital.Name[ccL][order(ouDat[ccL],data_SS$Hospital.Name[ccL])] 
                # Nationwide sorting
                result <- hospital.rank[input$rank]
                if( input$rank > length(ccL) ) {result <- ""}
                if( input$checkbox == TRUE ) {result <- hospital.rank[max(ranks)]}
                # State sorting
                if( as.numeric(input$radio) == 2 ){result <- hospital.rank}
              
                result.tab <- rbind(result.tab,cbind(state,result))
              }                             
                colnames(result.tab) <- c("STATE","HOSPITAL NAME")              
              list(colIndex=colIndex, result.tab=result.tab)
  })
  
  # Reactive function for generating plot
  procPlot <- reactive({
              colInd <- procData()$colIndex
              hospitals[,colInd] <- suppressWarnings(
                                    as.numeric(hospitals[,colInd]) )    
              # Statistics
              ouMean <- mean(hospitals[,colInd], na.rm=TRUE)
              ouSD <-   sd(hospitals[,colInd], na.rm=TRUE)
              ouMax <-  max(hospitals[,colInd], na.rm=TRUE) 
              list(df=hospitals[,colInd], ouMean=ouMean, ouMax=ouMax,
                   ouSD=ouSD)
  })
    
  # Render outcome histogram overlaid with normal (Guassian)
  # density distribution
  output$fig <- renderPlot({
              colInd <- procData()$colIndex   
              hospitals[,colInd] <- procPlot()$df
              ouMean <- procPlot()$ouMean
              ouMax  <- procPlot()$ouMax
              ouSD   <- procPlot()$ouSD
              binw <- (range(hospitals[,colInd], na.rm=TRUE)[2]-
                       range(hospitals[,colInd], na.rm=TRUE)[1])/35.0
              ouVar <- as.name(colnames(hospitals)[colInd])    
              # Create a ggplot class plot
              g <- ggplot(hospitals, aes_string(x=ouVar)) 
              g <- g + geom_rug(color="grey") 
              g <- g + theme_bw(base_size=14)
              g <- g + geom_histogram(binwidth=binw, 
                            aes(y = ..density..), 
                            alpha=1/3, fill="grey", 
                            color="grey", size=0.8)
              g <- g + stat_function(fun=dnorm, args=list(mean=ouMean, sd=ouSD), 
                           size=0.8, color="red")
              g <- g + annotate("text", x=ouMax-1, y=0.3,
                      label=c("NORMAL DISTRIBUTION"), size=4.5, color="red")
              g <- g + annotate("segment", x=ouMax-3.9, xend=ouMax-2.9,
                      y=0.3, yend=0.3, color="red", size=1)              
              g <- g + theme(axis.text=element_text(size=12))
              g <- g + scale_y_continuous(breaks=seq(0,0.3,0.05))
              g <- g + scale_x_continuous(breaks=seq(0,25,2))
              g <- g + labs(x=paste("30-day risk-adjusted mortality rate (%) from",
                          tolower(input$var)), y="Density")
              print(g)
  })
    
  # Render text objects
  output$text1 <- renderText({ 
    paste("Hospital Mortality Rates from ", input$var)
  })
  
  output$text2 <- renderText({ 
    paste("Average hospital 30-day mortality rate from",
          input$var,":",
          round(procPlot()$ouMean,1),
          " %")
  })
  
  # Render hospital ranking table
  output$tab <- renderDataTable({
    procData()$result.tab
  })



})