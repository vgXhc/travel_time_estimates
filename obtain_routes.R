library(httr2)
library(tidyverse)

full_routes_pre <- read_csv("data/data_raw.csv",
                            col_names = TRUE,
                            col_types = "ccciccc?")


# a list of origins and destinations, using Google's PlaceID format.
# PlaceIDs can be interactively obtained here: https://developers.google.com/maps/documentation/places/web-service/place-id
OD <- list(
  "JND_Rimrock_inbound" = "Eik2OTggSm9obiBOb2xlbiBEciwgTWFkaXNvbiwgV0kgNTM3MTMsIFVTQSIxEi8KFAoSCVsFaP7lUgaIEdglumaesvmTELoFKhQKEgmN8p8D4FIGiBFixZcm9p6MVQ",
  "JND_Rimrock_outbound" = "EiYxODE2IENvIEh3eSBNTSwgTWFkaXNvbiwgV0kgNTM3MTMsIFVTQSIxEi8KFAoSCcuqsbPoUgaIEXZaQ2U018y7EJgOKhQKEgnXphyomUwGiBFoGHtL8eDtWQ",
  "Hairball_outbound" = "EicyIEpvaG4gTm9sZW4gRHIsIE1hZGlzb24sIFdJIDUzNzAzLCBVU0EiMBIuChQKEgmDT360FFMGiBHZk80Hp-cWtRACKhQKEgmN8p8D4FIGiBFixZcm9p6MVQ",
  "Hairball_inbound" = "EigxMSBKb2huIE5vbGVuIERyLCBNYWRpc29uLCBXSSA1MzcwMywgVVNBIjASLgoUChIJj2RtsRRTBogRSliWlsnzEI4QCyoUChIJjfKfA-BSBogRYsWXJvaejFU",
  "University_Bassett" = "ChIJzaxDKTRTBogRWdNAkvOqtVw",
  "Johnson_First_inbound" = "EjFFIEpvaG5zb24gU3QgJiBOIEZpcnN0IFN0LCBNYWRpc29uLCBXSSA1MzcwNCwgVVNBImYiZAoUChIJnUXwx39TBogRPSbdiBRfApwSFAoSCZ1F8Md_UwaIET0m3YgUXwKcGhQKEglxZHLwe1MGiBEhF4UxTBvydhoUChIJyYMt1YFTBogRt1DP1-5tfKMiCg2ep68ZFa9ivMo",
  "University_Babcock" = "EiY0MDUgQmFiY29jayBEciwgTWFkaXNvbiwgV0kgNTM3MDYsIFVTQSIxEi8KFAoSCT3PV-HGrAeIEV1_lghmhvOxEJUDKhQKEgnp9d9ax6wHiBGQ8k_yQ353jg",
  "Johnson_Orchard" = "EikxMjYyIFcgSm9obnNvbiBTdCwgTWFkaXNvbiwgV0kgNTM3MDYsIFVTQSIxEi8KFAoSCa82OLnIrAeIET0P-Y_A50lFEO4JKhQKEgkbipoxNVMGiBEw0s6SmKjDiA",
  "Johnson_First_outbound" = "ChIJp5bo6n9TBogRS5zC4AWaxFw",
  "E_Wash_E_Springs_outbound" = "ChIJkbie2PRWBogRwBp5EacTCzk",
  "E_Wash_E_Springs_inbound" = "ChIJmxSTKvVWBogRMrS3QN0reB8",
  "E_Wash_Blair_outbound" = "ChIJ3R0F9mpTBogRWGkcBqAeqrs",
  "E_Wash_Blair_inbound" = "ChIJrRxIe2pTBogRFg0-3Y15owU",
  "Williamson_Thornton_inbound" = "EjZXaWxsaWFtc29uIFN0ICYgUyBUaG9ybnRvbiBBdmUsIE1hZGlzb24sIFdJIDUzNzAzLCBVU0EiZiJkChQKEglTceP-glMGiBGy4L7Ba_smehIUChIJU3Hj_oJTBogRsuC-wWv7JnoaFAoSCU95EHRxUwaIEWK02CjjGAaNGhQKEgm5hERAg1MGiBHinegnObsx4yIKDRu0rhkVLv68yg",
  "Williamson_Thornton_outbound" = "EjZXaWxsaWFtc29uIFN0ICYgUyBUaG9ybnRvbiBBdmUsIE1hZGlzb24sIFdJIDUzNzAzLCBVU0EiZiJkChQKEglTceP-glMGiBGy4L7Ba_smehIUChIJU3Hj_oJTBogRsuC-wWv7JnoaFAoSCU95EHRxUwaIEWK02CjjGAaNGhQKEgm5hERAg1MGiBHinegnObsx4yIKDRu0rhkVLv68yg",
  "Williamson_Wilson_inbound" = "Eik2MjggV2lsbGlhbXNvbiBTdCwgTWFkaXNvbiwgV0kgNTM3MDMsIFVTQSIxEi8KFAoSCSveXbhsUwaIEQS0W3k6DzAMEPQEKhQKEglPeRB0cVMGiBFitNgo4xgGjQ",
  "Williamson_Wilson_outbound" = "Eik2MjEgV2lsbGlhbXNvbiBTdCwgTWFkaXNvbiwgV0kgNTM3MDMsIFVTQSIxEi8KFAoSCdG8q7FsUwaIEU-LP25VmkkZEO0EKhQKEglPeRB0cVMGiBFitNgo4xgGjQ",
  "Park_University_inbound" = "EjJVbml2ZXJzaXR5IEF2ZSAmIE4gUGFyayBTdCwgTWFkaXNvbiwgV0kgNTM3MDMsIFVTQSJmImQKFAoSCekYkgbLrAeIEfnDmwElIVfjEhQKEgnpGJIGy6wHiBH5w5sBJSFX4xoUChIJhZwVcRCsB4gRWNpuY7HRXKgaFAoSCf3TDp7LrAeIER1_X0jI7L6zIgoNf3WsGRXNjrbK",
  "Park_University_outbound" = "EiUzMjYgTiBQYXJrIFN0LCBNYWRpc29uLCBXSSA1MzcwNiwgVVNBIjESLwoUChIJuegMCcusB4gRQb3HYjKBG7gQxgIqFAoSCf3TDp7LrAeIER1_X0jI7L6z",
  "Park_Badger_inbound" = "Ei9TIFBhcmsgU3QgJiBXIEJhZGdlciBSZCwgTWFkaXNvbiwgV0kgNTM3MTMsIFVTQSJmImQKFAoSCd2hRR_KUgaIEY7JBQ4CP8BhEhQKEgndoUUfylIGiBGOyQUOAj_AYRoUChIJ-4mKbNNSBogR9y961aIQPeIaFAoSCX9Eggs2rQeIEQ3TypGPiJY1IgoN_CenGRVlkLfK",
  "Park_Badger_outbound" = "EiYyNDkwIFMgUGFyayBTdCwgTWFkaXNvbiwgV0kgNTM3MTMsIFVTQSIxEi8KFAoSCX-0GSLKUgaIEfBQdhyNGb39ELoTKhQKEgn7iYps01IGiBH3L3rVohA94g",
  "Broom_JND" = "ChIJJw5ydztTBogRsMN72N7zVaU",
  "Broom_Gorham" = "EjBOIEJyb29tIFN0ICYgVyBHb3JoYW0gU3QsIE1hZGlzb24sIFdJIDUzNzAzLCBVU0EiZiJkChQKEgmRvi9nNlMGiBE4lkC_kJNLzRIUChIJkb4vZzZTBogROJZAv5CTS80aFAoSCa1WKh03UwaIETrwk5plcFplGhQKEgndeI7ON1MGiBEFS_9cHUc4miIKDQyZrBkVdMa3yg",
  "North_Shore_Bedford_WB" = "EjFTIEJlZGZvcmQgU3QgJiBOIFNob3JlIERyLCBNYWRpc29uLCBXSSA1MzcwMywgVVNBImYiZAoUChIJi77lUCVTBogR0wqFxVu0eNQSFAoSCYu-5VAlUwaIEdMKhcVbtHjUGhQKEgmXChE5MFMGiBG_UnTf7v1CExoUChIJe4g8RiVTBogReDzdRbDcMzEiCg3WV6sZFY5duMo",
  "Regent_Monroe" = "Ei1SZWdlbnQgU3QgJiBNb25yb2UgU3QsIE1hZGlzb24sIFdJIDUzNzExLCBVU0EiZiJkChQKEgkTSHhgw6wHiBEufN3t3ebWqBIUChIJE0h4YMOsB4gRLnzd7d3m1qgaFAoSCWWR03lYrAeIEWHtAniU930-GhQKEgkDcMeV46wHiBFMOTmiBxo-jSIKDQOfqxkVLa-0yg",
  "North_Shore_Bedford_EB" = "ChIJfVkbiC9TBogR_gz5zugkDng"
)


# main function to obtain route
get_route <- function(origin, destination, intermediate = NULL) {
  #Define the request body as a list, depending on whether an intermediate is given
  if (is.null(intermediate)) {
    request_body <- list(
      origin = list(placeId = OD[[origin]]),
      destination = list(placeId = OD[[destination]]),
      travelMode = "DRIVE",
      routingPreference = "TRAFFIC_AWARE",
      computeAlternativeRoutes = TRUE,
      languageCode = "en-US",
      units = "METRIC"
    )
  } else {
    request_body <- list(
      origin = list(placeId = OD[[origin]]),
      destination = list(placeId = OD[[destination]]),
      intermediates = list(placeId = OD[[intermediate]]),
      travelMode = "DRIVE",
      routingPreference = "TRAFFIC_AWARE",
      computeAlternativeRoutes = TRUE,
      languageCode = "en-US",
      units = "METRIC"
    )
  }
  
  
  # Build the API request and perform it
  response <-
    request("https://routes.googleapis.com/directions/v2:computeRoutes") |>
    req_method("POST")  |>
    req_headers(
      "Content-Type" = "application/json",
      "X-Goog-Api-Key" = Sys.getenv("ROUTES_API_KEY"),
      "X-Goog-FieldMask" = "routes.duration,routes.description,routes.staticDuration,routes.distanceMeters,routes.polyline.encodedPolyline"
    ) %>%
    req_body_json(request_body) |>
    req_perform()
  
  # Parse the response
  result <- response %>% resp_body_json()
  
  create_tibble <- function(x) {
    routes <- result$routes[[x]]
    tibble(
      origin = origin,
      destination = destination,
      intermediate = ifelse(is.null(intermediate), NA_character_, intermediate),
      distance = routes$distanceMeters,
      duration = routes$duration,
      description = routes$description,
      static_duration = routes$staticDuration,
      polyline = routes$polyline$encodedPolyline,
      request_time_UTC = Sys.time()
    )
  }
  
  # Return the results as tibble
  return(
    map(1:length(result$routes), create_tibble) |> list_rbind()
    )

}

# obtain routes -----------------------------------------------------------

rimrock_hairball <- get_route(origin = "JND_Rimrock_inbound",
                              destination = "Hairball_inbound")

hairball_rimrock <- get_route(origin = "Hairball_outbound",
                              destination = "JND_Rimrock_outbound")

gorham <- get_route(origin = "Johnson_First_inbound",
                    destination = "University_Bassett")

university <- get_route(origin = "University_Bassett",
                        destination = "University_Babcock")

johnson <- get_route(origin = "Johnson_Orchard",
                     destination = "Johnson_First_outbound")

east_wash_EB <- get_route(origin = "E_Wash_Blair_outbound",
                          destination = "E_Wash_E_Springs_outbound")

east_wash_WB <- get_route(origin = "E_Wash_E_Springs_inbound",
                          destination = "E_Wash_Blair_inbound")

williamson_outbound <- get_route(origin = "Williamson_Wilson_outbound",
                                 destination = "Williamson_Thornton_outbound")
williamson_inbound <- get_route(origin = "Williamson_Thornton_inbound",
                                 destination = "Williamson_Wilson_inbound")

park_inbound <- get_route(origin = "Park_Badger_inbound",
                          destination = "Park_University_inbound")

park_outbound <- get_route(origin = "Park_University_outbound",
                           destination = "Park_Badger_outbound")

broom <- get_route(origin = "Broom_JND",
                   destination = "Broom_Gorham")

regent_eastbound <- get_route(origin = "Regent_Monroe",
                              destination = "North_Shore_Bedford_EB")

regent_westbound <- get_route(origin = "North_Shore_Bedford_WB",
                              destination = "Regent_Monroe")

# combine routes ----------------------------------------------------------

full_routes <- bind_rows(
  full_routes_pre,
  rimrock_hairball,
  hairball_rimrock,
  gorham,
  university,
  johnson,
  east_wash_EB,
  williamson_outbound,
  williamson_inbound,
  park_inbound,
  park_outbound,
  broom,
  regent_eastbound,
  regent_westbound
)



full_routes |> write_csv(file = "data/data_raw.csv")

# basic data cleaning and variable creation
full_routes_clean <- full_routes |>
  mutate(
    duration = as.integer(str_remove(duration, "s")),
    duration_minutes = duration / 60,
    static_duration = as.integer(str_remove(static_duration, "s")),
    day_of_week = wday(request_time_UTC, label = TRUE),
    weekend = ifelse(day_of_week %in% c("Sat", "Sun"), TRUE, FALSE),
    distance_miles = distance / 1609.344,
    route_id = case_when(
      origin %in% c("JND_Rimrock_inbound", "Hairball_outbound") ~ "John Nolen Dr (Rimrock <-> Hairball)",
      origin == "Johnson_First_inbound" ~ "Gorham (First to Bassett)",
      origin == "University_Bassett" ~ "University (Bassett to Babcock)",
      origin == "Johnson_Orchard" ~ "Johnson (Orchard to First)",
      origin %in% c("E_Wash_E_Springs_inbound","E_Wash_Blair_outbound") ~ "E Wash (Blair <-> E Springs)",
      origin %in% c("Williamson_Wilson_outbound", "Williamson_Thornton_inbound") ~ "Williamson (Wilson <-> Thornton)",
      origin %in% c("Park_Badger_inbound", "Park_University_outbound") ~ "Park (Badger <-> University)",
      origin == "Broom_JND" ~ "Broom (JND to University)",
      origin %in% c(origin = "Regent_Monroe", "North_Shore_Bedford_WB") ~ "Regent (Monroe <-> Bedford)"
    ),
    direction = case_match(origin,
                           c("JND_Rimrock_inbound", 
                             "Johnson_Orchard",
                             "E_Wash_Blair_outbound",
                             "Williamson_Wilson_outbound",
                             "Park_Badger_inbound",
                             "Broom_JND") ~ "NB",
                           c("Hairball_outbound",
                             "Johnson_First_inbound",
                             "E_Wash_E_Springs_inbound",
                             "Williamson_Thornton_inbound",
                             "Park_University_outbound") ~ "SB",
                           c("University_Bassett",
                             "North_Shore_Bedford_WB") ~ "WB",
                           c("Regent_Monroe") ~ "EB"),
    route_description = paste0(origin, " to ", destination, " via ", description),
    route_description = str_replace_all(route_description, "_", " "),
    route_description = str_replace_all(route_description, "inbound|outbound", ""),
    route_description = str_replace_all(route_description, "  ", " "),
    request_time_local = as.character(with_tz(request_time_UTC, tzone = "US/Central"))
  ) 

write_csv(full_routes_clean, file = "data/data_clean.csv")