library(shiny)
library(shinydashboard)
library(DT)

# UI for the Shiny App
ui <- dashboardPage(
  dashboardHeader(title = "Wine Quality App"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "aboutTab"),
      menuItem("Data Exploration", tabName = "exploreTab"),
      menuItem("Modeling", tabName = "modelingTab"),
      menuItem("Data", tabName = "dataTab")
    )
  ),
  dashboardBody(
    tabItems(
      # About Page
      tabItem(
        tabName = "aboutTab",
        fluidRow(
          column(width = 12,
                 h2("About This App"),
                 p("Welcome to the Wine Quality App!"),
                 p("The purpose of this app is to provide an interactive platform for exploring and analyzing the Wine Quality dataset."),
                 p("The app consists of multiple pages (tabs), each serving a specific purpose."),
                 h3("Purpose of Each Tab:"),
                 p("1. About: Provides general information about the app, the data, and its source."),
                 p("2. Data Exploration: Allows users to create numerical and graphical summaries of the data."),
                 p("3. Modeling: Allows users to fit three supervised learning models (multiple linear regression, regression/classification tree, and random forest) to the data and compare their performance."),
                 p("4. Data: Allows users to view and manipulate the raw data."),
                 h3("The Wine Quality Data:"),
                 p("The Wine Quality dataset contains information about various red and white wines."),
                 p("The dataset is sourced from the UCI Machine Learning Repository."),
                 p("For more information about the data and its attributes, please visit the original source:"), 
                 p(a(href = "https://archive.ics.uci.edu/ml/datasets/wine+quality", "Wine Quality Data at UCI Repository")),
                 p("Please note that any modifications or subsets made to the data within this app will not affect the original dataset.")
          ),
          column(width = 12,
                 # You can add an image of red and white wine here
                 img(src = "red_and_white_wine.jpg", width = "100%", height = "auto")
          )
        )
      ),
      # Data Exploration Page
      tabItem(
        tabName = "exploreTab",
        fluidRow(
          # Your Data Exploration page content goes here
        )
      ),
      # Modeling Page
      tabItem(
        tabName = "modelingTab",
        fluidRow(
          # Modeling Info tab content
          tabBox(
            title = "Modeling Info",
            tabPanel(
              "Info",
              fluidRow(
                # Your explanation and mathJax content for modeling approaches goes here
              )
            )
          ),
          # Model Fitting tab content
          tabBox(
            title = "Model Fitting",
            tabPanel(
              "Fitting",
              fluidRow(
                # Select model type
                column(width = 4,
                       h4("Select Model Type"),
                       selectInput("modelType", "Model Type:",
                                   choices = c("Generalized Linear Model", "Classification Tree", "Random Forest"))
                ),
                # Select variables
                column(width = 4,
                       h4("Select Variables"),
                       selectInput("variables", "Select Variables to Use:", names(WineQuality),
                                   multiple = TRUE)
                ),
                # Data split proportions
                column(width = 4,
                       h4("Data Split Proportions"),
                       numericInput("trainProp", "Training Data Proportion:", 0.7, min = 0, max = 1, step = 0.05),
                       numericInput("testProp", "Test Data Proportion:", 0.3, min = 0, max = 1, step = 0.05)
                )
              ),
              fluidRow(
                actionButton("fitModels", "Fit Models")
              )
            )
          ),
          # Prediction tab content
          tabBox(
            title = "Prediction",
            tabPanel(
              "Prediction",
              fluidRow(
                column(width = 4,
                       h4("Select Model Type for Prediction"),
                       selectInput("predictionModel", "Model Type:",
                                   choices = c("Generalized Linear Model", "Classification Tree", "Random Forest"))
                ),
                # Select predictors for prediction
                column(width = 4,
                       h4("Select Predictor Values"),
                       # Add input elements for each predictor variable
                       # For example, numericInput("predictor_var", "Predictor Variable:", 0)
                ),
                # Predict button
                column(width = 4,
                       actionButton("predictButton", "Predict")
                )
              ),
              # Display prediction result
              fluidRow(
                # Add an element to display the prediction resut
              )
            )
          )
        )
      ),
      # Data Page
      tabItem(
        tabName = "dataTab",
        fluidRow(
          # Your Data page content goes here
          column(width = 12,
                 h2("Data"),
                 # Display the dataset in a data table
                 DTOutput("dataTable"),
                 # Allow the user to subset rows and columns
                 uiOutput("subsetControls"),
                 # Download the whole or subsetted dataset as a CSV file
                 downloadButton("downloadData", "Download CSV")
          )
        )
      )
    )
  )
)

