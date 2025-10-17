# Travel times from the Google Routes API
Using Google Maps API to get real-time traffic data for select routes in Madison, Wisconsin

You can read more about the background of this [on my blog](https://haraldkliems.netlify.app/posts/2025-09-13-using-the-google-routes-api-to-collect-travel-time-data-during-a-traffic-trial/). This repository is a more generalized version, based on feedback from city staff.

## Data
A raw data set is committed after each run in [`data/data_raw.csv`](data/data_raw.csv). Unless you have a good reason to use the raw data, you should use one of the cleaned file instead. Those create a number of additional variables to facilitate analysis (see codebook below). The clean data is available as a [`csv`](data/data_clean.csv) or as an [`RDS`](data/data_clean.RDS) file.

## Analysis
A rudimentary analysis page is available at https://vgxhc.github.io/travel_time_estimates/analysis.html

## Codebook


| Variable | type | values |
| --- | --- | --- |
| `origin` | string | Starting location of route |
| `destination` | string | Destination of route |
| `intermediate` | string | Forced intermediate waypoint on route (to ensure consistent routing) |
| `request_time_local` | POSIXct | Time of request (in US/Central time) |
| `distance` | integer | route distance in meters |
| `duration` | integer | route duration in seconds, with traffic conditions at `request_time` |
| `static_duration` | integer | route duration in seconds, "considering only historical traffic information" |
| `description` | string | Very short route description as returned by the API |
| `duration_minutes` | numeric | route duration in minutes (derived from `duration`) |
| `day_of_week` | ordered factor | Abbreviated day of week (`Mon`, `Tue`, etc.) |
| `weekend` | factor | Was the route calculated on a weekend or weekday |
| `distance_miles` | numeric | Route distance in miles (derived from `distance`) |
| `route_id` | string | human-readable short description of the route. Does not account for direction or route variations |
| `direction` | string | Whether the route travels eastbound (`EB`), westbound (`WB`), northbound (`NB`), or southbound (`SB`) |
| `polyline` | string | Google [polyline](https://developers.google.com/maps/documentation/utilities/polylinealgorithm) encoded coordinates of the route |






