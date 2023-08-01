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
                 h3("Purpose of Each Page:"),
                 p(HTML("1. <strong>About</strong>: This page here. This just provides a general map of the app, the data, and its source.")),    
                 p(HTML("2. <strong>Data Exploration</strong>: Allows users to create numerical and graphical summaries of the data. This helps users do whatever exploratory data analysis they might be interested in before they get to the modelling page. This contains tools for analyses for one variables, two variables, and multiple (2+) variables.")),
                 p(HTML("3. <strong>Modeling</strong>: Allows users to fit three supervised learning models (linear regression, decision tree, and random forest) to the wine quality data and compare their performance. In this particualr case, we are looking at the predictions for wine quality (as a rating). Note that this contains a model fitting box and a prediction box. You must select something in the model fitting box in order for the prediction box to return something.")),
                 p(HTML("4. <strong>Data</strong>: Allows users to manipulate and download the raw data based on the number of rows they would like to see, and which variables they would like to observe.")),
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
          box(
            title = "One Variable Analysis",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            #selectInput("selectedOneVar", "Select One Variable:", choices = names(WineQuality)),
            # Checkbox to select the output options
            checkboxInput("oneVarSummary", "Display Summary"),
            checkboxInput("oneVarHistogram", "Display Histogram"),
            actionButton("oneVarAnalysis", "Analyze"), # Analyze button to trigger the outputs
            conditionalPanel(
              condition = "input.oneVarAnalysis",
              # Conditionally display the summary output
              conditionalPanel(
                condition = "input.oneVarSummary",
                verbatimTextOutput("oneVarSummaryOutput")
              ),
              # Conditionally display the histogram output
              conditionalPanel(
                condition = "input.oneVarHistogram",
                plotOutput("oneVarHistogramOutput")
              )
            )
          ),
          box(
            title = "Two Variable Analysis",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            # Select two variables for analysis
            selectInput("selectedTwoVar1", "Select Variable 1:", choices = names(WineQuality)),
            selectInput("selectedTwoVar2", "Select Variable 2:", choices = names(WineQuality)),
            checkboxInput("twoVarScatterplot", "Scatterplot"),
            checkboxInput("correlationOutput", "Correlation Coefficient"),
            actionButton("analyzeTwoVar", "Analyze"), # Analyze button to trigger the outputs
            conditionalPanel(
              condition="input.analyzeTwoVar",
              #Conditionally display scatterplot 
              conditionalPanel(
                condition="input.twoVarScatterplot",
                plotOutput("twoVarScatterplotOutput")
              ),
              conditionalPanel(
                condition="input.correlationOutput",
                verbatimTextOutput("correlationOutput")
              ),
            )
          ),
          # New box for Multivariable Analysis
          box(
            title = "Multivariable Analysis",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            # Select multiple variables (multiple = TRUE)
            selectInput("selectedMultiVar", "Select Variables:", choices = names(WineQuality), multiple = TRUE),
            # Checkbox to select the output options
            checkboxInput("multiVarPCA", "Display PCA Plot"),
            checkboxInput("multiVarCorrelation", "Display Correlation Heatmap"),
            # Analyze button to trigger the outputs
            actionButton("analyzeMultiVar", "Analyze"),
            
            # Conditionally display the outputs
            conditionalPanel(
              condition = "input.analyzeMultiVar",
              # Conditionally display the PCA plot
              conditionalPanel(
                condition = "input.multiVarPCA",
                plotOutput("multiVarPCAOutput")
              ),
              # Conditionally display the correlation heatmap
              conditionalPanel(
                condition = "input.multiVarCorrelation",
                plotOutput("multiVarCorrelationOutput")
              )
            )
          ),
          #add more boxes here
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
                # Linear Regression
                column(width = 12,
                       h3("Linear Regression"),
                       withMathJax(
                         "
         Linear regression is a fundamental statistical model used for predicting numeric response variables. In this case, we are interested in predicting a numeric value, such as the quality rating of a wine (an integer value).

         The linear regression model aims to find the best-fitting line (or hyperplane in higher dimensions) that represents the relationship between the predictor variables and the response variable. The model equation for linear regression can be written as:

         \\[ 
         y = \\beta_0 + \\beta_1 \\cdot x_1 + \\beta_2 \\cdot x_2 + \\ldots + \\beta_k \\cdot x_k + \\varepsilon
         \\]

         where \\( y \\) is the response variable (quality rating of the wine), and \\( \\beta_0, \\beta_1, \\ldots, \\beta_k \\) are the coefficients of the predictors \\( x_1, x_2, \\ldots, x_k \\) respectively. The term \\( \\varepsilon \\) represents the error term, accounting for the variability not explained by the model.

         The goal of the linear regression is to estimate these coefficients to minimize the sum of squared differences between the predicted values and the actual values in the training data.
         "
                       )
                ),
                # Decision Trees for Regression
                column(width = 12,
                       h3("Decision Trees for Regression"),
                       withMathJax(
                         "
         Decision Trees for regression tasks are non-linear predictive models that recursively partition the data into subsets based on predictor variables, with the aim of creating homogeneous groups within each subset with respect to the numeric response variable (e.g., quality rating of the wine).

         Each split in the tree represents a decision based on the values of one of the predictor variables to minimize the variance within the resulting subsets.

         The decision rule at each internal node of the tree can be represented as:

         \\[ 
         \\text{if} \\quad x_j \\leq \\text{threshold} \\quad \\text{then} \\quad \\text{left branch} \\quad \\text{else} \\quad \\text{right branch}
         \\]

         where \\( x_j \\) is the value of predictor \\( j \\), and the threshold is the value that determines the split.

         The predicted value for a new data point is the average of the response variable in the leaf node to which the data point belongs.
         "
                       )
                ),
              # Random Forest for Regression
              column(width = 12,
                     h3("Random Forest for Regression"),
                     withMathJax(
                       "
         Random Forest for regression is an ensemble learning method that builds multiple decision trees and combines their predictions to improve accuracy and reduce overfitting. Each tree in the forest is grown on a bootstrap sample of the data, and at each split, a random subset of predictor variables is considered.

         The predictions of individual trees are combined through averaging for regression tasks to make the final prediction.

         The prediction of the Random Forest model can be written as:

         \\[ 
         \\text{Prediction} = \\frac{1}{N} \\sum_{i=1}^{N} \\text{Prediction}_{\\text{tree}_i}
         \\]

         where \\( \\text{Prediction}_{\\text{tree}_i} \\) is the prediction of the \\( i \\)-th tree in the forest, and \\( N \\) is the number of trees in the forest.
         "
                     )
                )
              )
            )
          ),
          # Model Fitting tab content
          tabBox(
            title = "Model Fitting",
            tabPanel(
              "Model Fitting",
              sliderInput("train_prop", "Proportion of data for training:", min = 0.1, max = 0.9, value = 0.7),
              # checkboxGroupInput("model_vars", "Variables to use in models:", choices = names(wine)),
              selectInput("model_vars", "Variables to use in models:", choices = names(WineQuality), multiple = TRUE),
              selectInput("dependent_var", "Choose a dependent variable:", choices = c('quality')),
              actionButton("fit_models", "Fit Models"),
              verbatimTextOutput("model_output"),
              h3("Linear Regression Summary"),
              verbatimTextOutput("lin_reg_summary"),
              h3("Tree Model Summary"),
              verbatimTextOutput("tree_summary"),
              h3("Random Forest Summary"),
              verbatimTextOutput("rf_summary"),
              h3("Test Statistics"),
              verbatimTextOutput("test_stats")
              )
          ),
          # Prediction tab content
          tabBox(
            title = "Prediction",
            tabPanel(
              "Prediction",
              fluidRow(
                h2("Prediction"),
                selectInput("prediction_model", "Model to use for prediction:", 
                            choices = c("Linear Regression" = "lin_reg", "Tree" = "tree", "Random Forest" = "rf")),
                uiOutput("predictor_inputs"),
                actionButton("predict", "Predict"),
                verbatimTextOutput("prediction_output")
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
               # Allow the user to subset rows and columns
               sidebarLayout(sidebarPanel(numericInput("rows", "Number of rows:", min = 1, max = nrow(WineQuality), value = nrow(WineQuality)),
               uiOutput("column_checkboxes"),
               # Download the whole or subsetted dataset as a CSV file
               downloadButton("download_data", "Download the subsetted CSV")),
               mainPanel(
                 div(style = 'overflow-x: scroll', 
                     DT::DTOutput("data_table")
                 )
               )
               )
        )
      )
    )
    )
  )
)

