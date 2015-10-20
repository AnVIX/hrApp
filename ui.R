#--------------------------------------------------------
# ui.R source file for 'hospialRank' Shiny application
#--------------------------------------------------------

shinyUI(fluidPage(
  titlePanel("hospitalRank"),
  
  sidebarLayout(
    sidebarPanel(
      
      p("Compare ranking of over 4,000 Medicare-certified hospitals nationwide 
         and by state based on data from the",
        a("Hospital Compare", 
          href = "https://www.medicare.gov/hospitalcompare/About/What-Is-HOS.html",
          "website."), 
          "Ranking is measured by estimates of deaths within 30-days of a hospital 
           admission for a given medical condition."),
      hr(), 
      
      helpText("Use these widgets to select sorting options"), 
      
      selectInput("var", 
                  label = "Choose a medical condition:",
                  choices = list("Heart Attack", "Heart Failure",
                                 "Pneumonia"),
                  selected = "Heart Attack", width="80%"),
      sliderInput("rank", 
                  label = "Select hospital rank to view:",
                  min = 1, max = 300, value = 1),
      
      helpText("Check this box to view worst ranking hospitals", tags$u("only")),       
      checkboxInput("checkbox", label = strong("Worst rank"), 
                    value = FALSE),
      
      hr(),
      radioButtons("radio", label = h4("Sort options"),
                   choices = list("Nationwide" = 1, "State" = 2), 
                   selected = 1),      
      
      helpText(h5("When sorting by", strong("State"), 
                "enter the U.S. State 2 letter code (e.g., AK for Alaska)")),
      selectInput("zip", 
                  label = h5(strong("State code")), 
                  choices = list("AK", "AL", "AR", "AZ", "CA", "CO",
                                 "CT", "DC", "DE", "FL", "GA", "GU", 
                                 "HI", "IA", "ID", "IL", "IN", "KS", 
                                 "KY", "LA", "MA", "MD", "ME", "MI",
                                 "MN", "MO", "MS", "MT", "NC", "ND", 
                                 "NE", "NH", "NJ", "NM", "NV", "NY", 
                                 "OH", "OK", "OR", "PA", "PR", "RI", 
                                 "SC", "SD", "TN", "TX", "UT", "VA",
                                 "VI", "VT", "WA", "WI", "WV", "WY"),                                 
                  width="40%"),
      
      hr(),
      h6(" hospitalRank is developed by ", 
      span("AnVIX", style = "color:blue"), "and can be downloaded
      from", a("Github", href="https://github.com/AnVIX/hrApp"))
    ),
        
    mainPanel(
      h4(span(textOutput("text1"), style = "color:black")),     
      plotOutput("fig", width="80%"),
      br(),
      h5(span(textOutput("text2"), style = "color:royalblue")), 
      hr(),
      dataTableOutput("tab")
      )    
  )
))
