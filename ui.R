# ui.R
library("highcharter")
shinyUI(fluidPage(
  
  titlePanel("Users by country"),
  
  sidebarLayout(
    sidebarPanel( 
      p("View a map of users to company websites by country"),
      
      radioButtons("brandSelect", 
                   label = "Select Brand", 
                   choices = list( "Brand 1" = "Brand 1", "Brand 2" = "Brand 2"),
                   selected = "Brand 1", 
                   inline=TRUE),
      
      dateRangeInput('dateRange',
                     label = 'Date range',
                     start = as.Date("2015-09-01"), end = as.Date("2016-09-01")
      ),
      br(),
      br(),
      helpText("View the source code for this dashboard"),
      tags$a("https://github.com/Phippsy/global-visitor-dashboard", href="https://github.com/Phippsy/global-visitor-dashboard", target = "new")
      
    ),
    mainPanel(
        tabsetPanel(
          tabPanel("Map",h4(textOutput("brandText")),highchartOutput("countryChart", height = 450),downloadButton('downloadData', 'Download this data')),
          tabPanel("Bar Chart",h4(textOutput("brandText1")),highchartOutput("countryBar", height = 450),downloadButton("downloadBar", "Download full data")))
      )
    )
  )
)


