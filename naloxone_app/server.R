library(shiny)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(car)
library(raster)


zipdata <- opioid[opioid$zcta5 %in% allzips$zipcode,]
zipdata[setdiff(names(tmp), 'state')] <- sapply(setdiff(names(tmp), 'state'), function(var)
    recode(trimws(gsub('-', '', tmp[[var]][match(zipdata$State.Abbreviation, tmp$state)])), "''='No'; NA='No'"))
try(zipdata[names(allzips)] <- sapply(names(allzips), function(var)
    allzips[[var]][match(formatC(zipdata$zcta5, width=5, format="d", flag="0"), allzips$zipcode)]))
vars <- c('claim_pop', 'provider_pop', 'pop14', 'arrests_1000', 'cancer_incidence_per_1000', 'povertyline')
zipdata[vars] <- sapply(vars, function(var) round(as.numeric(zipdata[[var]]), digits=0))
zipdata$centile <- as.numeric(zipdata$centile)
tmp <- tmp[-c(14)]
colnames(tmp) <- c("State", "Prescibers immunity civil", "Prescibers immunity criminal", "Prescibers immunity disciplinary",
    "Dispensers immunity civil", "Dispensers immunity criminal", "Dispensers immunity disciplinary", "Lay administrator immunity civil",
    "Lay administrator immunity criminal", "Lay person distribution", "Lay person possesion without Rx",
    "Presciption permitted, 3rd party", "Prescription permitted, standing order")

shinyServer(function(input, output, session) {
    
    ## Interactive Map ###########################################
    
    # Create the map
    output$map <- renderLeaflet({
        leaflet() %>%
            addTiles(
                urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
            ) %>%
            setView(lng = -93.85, lat = 37.45, zoom = 4)
    })
    
    # A reactive expression that returns the set of zips that are
    # in bounds right now
    zipsInBounds <- reactive({
        if (is.null(input$map_bounds))
            return(zipdata[FALSE,])
        bounds <- input$map_bounds
        latRng <- range(bounds$north, bounds$south)
        lngRng <- range(bounds$east, bounds$west)
        
        subset(zipdata,
               latitude >= latRng[1] & latitude <= latRng[2] &
                   longitude >= lngRng[1] & longitude <= lngRng[2])
    })
    
    # This observer is responsible for maintaining the circles and legend,
    # according to the variables the user has chosen to map to color and size.
    observe({
        colorBy <- input$color
        
        colorData <- zipdata[[colorBy]]
        pal <- colorFactor("Spectral", colorData)

                
        radius <- log(zipdata$pop14)*2000
        leafletProxy("map", data = zipdata) %>%
            clearShapes() %>%
            addCircles(~longitude, ~latitude, radius=radius, layerId=~zipcode,
                       stroke=FALSE, fillOpacity=.5, fillColor=pal(colorData)) 
    })
    
    # Show a popup at the given location
    showZipcodePopup <- function(zipcode, lat, lng) {
        selectedZip <- zipdata[zipdata$zipcode == zipcode,]
        content <- as.character(tagList(
            tags$h4("Score:", as.integer(selectedZip$score)),
            tags$strong(HTML(sprintf("%s, %s",
                                     selectedZip$county, selectedZip$state.x
            ))), tags$br(),
            sprintf("Population: %s", selectedZip$pop14), tags$br(),
            sprintf("Prescription rate per 1000: %s", selectedZip$claim_pop), tags$br(),
            sprintf("Provider population per 1000: %s", selectedZip$provider_pop), tags$br(),
            sprintf("Overdose deaths per 100K: %s", selectedZip$DeathRate), tags$br(),
            sprintf("Crime rate per 1000: %s", selectedZip$arrests_1000), tags$br(),
            sprintf("Cancer rate per 1000: %s", selectedZip$cancer_incidence_per_1000), tags$br(),
            sprintf("Percent in poverty: %s%%", selectedZip$povertyline), tags$br(),
            sprintf("Deaths per 100K if immunity to dispensers: %s", round(selectedZip$estimate_immunity_dispensers_all, digits=2)), tags$br(),
            sprintf("Deaths per 100K if immunity to perscribers: %s", round(selectedZip$estimate_immunity_prescribers_all, digits=2))
        ))
        leafletProxy("map") %>% addPopups(lng, lat, content, layerId = zipcode)
    }
    
    # When map is clicked, show a popup with city info
    observe({
        leafletProxy("map") %>% clearPopups()
        event <- input$map_shape_click
        if (is.null(event))
            return()
        
        isolate({
            showZipcodePopup(event$id, event$lat, event$lng)
        })
    })
    
    
    ## Data Explorer ###########################################

    observe({
        if (is.null(input$goto))
            return()
        isolate({
            map <- leafletProxy("map")
            map %>% clearPopups()
            dist <- 0.5
            zip <- input$goto$zip
            lat <- input$goto$lat
            lng <- input$goto$lng
            showZipcodePopup(zip, lat, lng)
            map %>% fitBounds(lng - dist, lat - dist, lng + dist, lat + dist)
        })
    })
    
    output$ziptable <- DT::renderDataTable({
        df <- tmp %>%
            filter(
                is.null(input$states) | State %in% input$states
            ) 
        action <- DT::dataTableAjax(session, df)
        
        DT::datatable(df, options = list(ajax = list(url = action), paging=FALSE), escape = FALSE)
    })
})