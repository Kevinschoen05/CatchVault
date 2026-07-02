## Views/Screens
1. User enters app to the **Main Dashboard** (ReservoirHome.swift) or potentially the ContentView.swift
    - Header + Year filter 
        - year filter should effect the high level metrics that are displayed on each of the reservoir tiles.
    - 1 or Many Reservoir Tiles based on how many locations are associated with the user's account
        - Reusable Tile Componet
    - 'Add Reservoir' Tile
        - utilize the resuable Reservoir Tile component
    - Analytics button - Navigation button that will take the user to the Analytics specific Dashboard. 
    
- From the main dashboard view the user has 3 workflows: 
    1. Click a Reservoir Tile and navigate to a ReservoirDetails Screen 1(a) or Start an Active Trip (1b)
    2. Click the Analytics button and navigate to the Analytics Dashboard 
    3. Add a new Reservoir

## PATH 1a
**Reservoir Details Screen**
- High level metrics - total trips, total fish, total weight
        - can be filtered by year or all time values
- Trip Tiles - each trip that the user records for this specific reservoir gets a tile. they are sorted chronologically with the most recent trips at the top. the trip tiles can be filtered to only display a single year, or all trips, all time
        -trip tiles contain high level information: Anglers on the trip, total fish, total weight, date
        -trip tiles contain the View Trip Details button which navigates the user to a more detailed screen for that specific trip. this screen will be documented separately. 
- Catch Map - this requirement will be documented separately, but the intention is to leverage the location data to build a visualization of all the fish locations for the specific reservoir. 
- From the reservoir details screen, the user has 2 options
    1. Click a single trip tile's 'View Trip Details button' and navigate to the Trip Details Screen 
    2. Click the 'Catch Map' button and navigate to the **Reservoir Catch Map**.
        - Reservoir Catch Map is the end of a workflow

**Trip Details Screen**
-  Trip details contains more detailed information/data for one specific trip: date, trip duration
- Catch Map - leverages the catch location data to map where specific catches were recorded for the specific trip. 
- Catch list - Tile/row that captures: Fish species, Angler, Date, Time, weight of Fish
- Trip Weather - new feature to be added: capture weather data during the duration of the trip
    Trip Details is the end of a workflow


## Path 1b
**Start Trip**
- if the user selects the 'Start Trip' button on a Reservoir Tile on the main dashboard, they are taken to the intermediate 'Start Trip' screen. 
- Only functionality here is to select from the list of anglers who is included on the trip. 
- also provides the opportunity to add a new angler that has never been on a trip before. This needs to instantiate a new 'Angler' record. 

**Active Trip** 
- Once the user starts a trip, they are navigated to the Active Trip screen. this will be the most dynamic of the screens as this is where user inputs/etc are logged in real time. 
Components: 
    - active trip duration/timer
    -active catch map showing catch locations for the ongoing trip
    - active catch list - shows list of catches for the ongoing trip
    -record fish button - opens 'Record Fish' screen described above. 
    -end trip button - opens trip summary screen, addtional prompt to 'end trip' and save trip data- 

**Record Fish**
 - record fish worklfow can happen 0 to many times from the Active Trip screen

**End Trip**
trip summary screen, addtional prompt to 'end trip' and save trip data
- when the user saves the data, this is the end of the workflow, navigate back to the Main Dashboard

## Path B

Button on the main dashboard navigates to a similar dashboard with tiles for each analytical breakdown view

**Analytics Dashboard**
- similar dashboard with tiles for each analytical breakdown view

**Angler Totals**
    - Total Fish Caught per angler. Filterable by Specific reservoir, specific year, or 'All' in both cases
    - High level metrics: Total Fish, Total Trips, Catch Average per trip, weight average per trip
    - total catch numbers by species. if a user has never caught a specific species, it doesn't appear on their list

**Reservoir Leaderboard**
- For each Reservoir, a top 10 list of the largest fish caught. Filterable by year, or 'All'
- Angler, Species, Weight, and year caught

**Species Breakdown**
- For each species, display the total number of fish caught of the species broken down by reservoir.Filterable by year, or 'All'

**Catch Trends per Species**
- The user is prompted to select a species, and a chart displaying all months of the year is displayed. Total number of the specific species caught for each month are displayed. 


Total Views 12: 
Main Dashboard (ReservoirHome.swift)
Reservoir Details (ReservoirDetails.swift)
Start Trip (StartTrip.swift)
Record Fish (RecordFish.swift)
Active Trip (ActiveTrip.swift)
End Trip (EndTrip.swift)
Add Reservoir (AddReservoir.swift)
Analytics Dashboard (Analytics Dashboard.swift)
Angler Totals (AnglerTotals.swift)
Reservoir Leaderboard (ReservoirLeaderboard.swift)
Species Breakdown (SpeciesBreakdown.swift)
Catch Trends (CatchTrends.swift)