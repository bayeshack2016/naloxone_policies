library(shiny)
library(leaflet)

# Choices for drop-downs
vars <- c(
    "Overdose deaths per 100K people" = "ratesplit_low",
    "Claims per 1000 people" = "claim_pop",
    "Providers per 1000 people" = "provider_pop",
    "Deaths per 100K if immunity to despensers Naloxone" = "estimate_immunity_dispensers_all",
    "Deaths per 100K if immunity to prescribers of Naloxone" = "estimate_immunity_prescribers_all"
)


shinyUI(navbarPage("Naloxone", id="nav",
    
    tabPanel("Interactive map",
        div(class="outer",
            tags$head(# Include our custom CSS
                includeCSS("styles.css"),
                includeScript("gomap.js")),
            
            leafletOutput("map", width="100%", height="100%"),
            
            # Shiny versions prior to 0.11 should use class="modal" instead.
            absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                width = 330, height = "auto",
                
                h2("ZIP explorer"),
                
                selectInput("color", "Color", vars)
            )
            
        )
    ),
    
    tabPanel("Data explorer",
            HTML("<b>Prescibers immunity civil</b> Immunity to Prescribers from civil prosecution<br>
            <b>Prescibers immunity criminal</b> Immunity to Prescribers from criminal prosecution<br>
            <b>Prescibers immunity disciplinary</b> Immunity to Prescribers from disciplinary action<br>
            <b>Dispensers immunity civil</b> Immunity to Dispensers from civil prosecution<br>
            <b>Dispensers immunity criminal</b> Immunity to Dispensers from criminal prosecution<br>
            <b>Dispensers immunity disciplinary</b> Immunity to Dispensers from disciplinary action<br>
            <b>Lay administrator immunity civil</b> Immunity to lay administrators from civil prosecution<br>
            <b>Lay administrator immunity criminal</b> Immunity to lay administrators from criminal prosecution<br>
            <b>Lay person distribution</b> distribution allowed by lay people<br>
            <b>Lay person possesion without Rx</b> possession without RX allowed by lay people<br>
            <b>Presciption permitted, 3rd party</b> prescription of drugs to a person other than the person to whom they will be administered<br>
            <b>Prescription permitted, standing order</b> prescription allowing to a person the physician has not personally examined<br>"),
        hr(),
        DT::dataTableOutput("ziptable")
    ),
    
    conditionalPanel("false", icon("crosshair"))
))