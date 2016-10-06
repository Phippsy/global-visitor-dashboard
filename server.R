# Load packages 
require(reshape2)
require(dplyr)
require(ggplot2)
require(devtools)
require(highcharter)

# server.R

options(scipen=5)

shinyServer(
  function(input, output) {
    data(worldgeojson, package = "highcharter")
    load("alldata.rda")
    countryCodes <- read.csv("iso-codes.csv") %>% select(-c(4:5))
    currentBrand <- reactive({
      if (input$brandSelect == "Brand 1" ) {
        "Brand 1"
      } else {
        "Brand 2"
      }
    })
    
    
    # Getting the data
    # Time-series data
    fullData <- reactive({
      currentData <- dplyr::filter(alldata, brand == input$brandSelect & date >input$dateRange[1] & date < input$dateRange[2])
      summary <- currentData %>% group_by(countryIsoCode) %>% summarise(users = sum(users))
      fullData <- merge(summary, countryCodes, by.x = "countryIsoCode", by.y = "Alpha.2.code")
      names(fullData)[names(fullData)=="Alpha.3.code"] <- "iso3"
      fullData
    })
    
    rankData <- reactive({
      data <- fullData() %>% 
        arrange(desc(users))
      data <- data[1:10,]
      data
    })
 
    downloadData <- reactive({
      data <- fullData() %>% select(-c(1,4))
      names(data) <- c("users", "country")
      data <- data %>% select(country, users) %>% arrange(desc(users))
      data
    })
    
    # Text Outputs
    output$brandText <- renderText ({
      paste0("Total users by country for ", currentBrand(),", for the period ", input$dateRange[1], " to ", input$dateRange[2])
    })
  
    output$brandText1 <- renderText ({
      paste0("Total users by country (top 10 countries only) for ", currentBrand(),", for the period ", input$dateRange[1], " to ", input$dateRange[2])
    })
    
    # Plots  
    # Countries map
    output$countryChart <- renderHighchart({
      highchart() %>% 
        hc_add_series_map(worldgeojson, fullData(), value = "users", joinBy = "iso3") %>% 
        hc_legend(enabled = TRUE) %>% 
        hc_add_theme(hc_theme_538()) %>%
        hc_mapNavigation(enabled = TRUE)
    })

    output$downloadData <- downloadHandler(
      filename = function() { paste0("CountryCounts-",input$brandSelect, "-", as.character(input$dateRange[1]), " until ", as.character(input$dateRange[2]),'.csv') },
      content = function(file) {
        write.csv(downloadData(), file, row.names = F)
      }) # end downloadData     
    
    # Top 5 countries bar
     output$countryBar <- renderHighchart({
       hc <- highchart() %>%
        hc_xAxis(categories = rankData()$country) %>%
         hc_add_series(name = "Country", data = rankData()$users, type = "column")
       hc
     })
    
    output$downloadBar <- downloadHandler(
      filename = function() { paste0("CountryCounts-",input$brandSelect, "-", as.character(input$dateRange[1]), " until ", as.character(input$dateRange[2]),'.csv') },
      content = function(file) {
        write.csv(downloadData(), file, row.names = F)
      }) # end downloadData     

 
    
  })
