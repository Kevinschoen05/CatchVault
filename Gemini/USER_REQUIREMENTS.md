# CatchVault — User Requirements

The main functionality of the existing application is to allow the users to record relevant information related to their fishing trips in real time and then provide a UI for the information to be displayed, analyzed and visualized. I will provide details of each functionality currently in production below

1. Record Fish
- This functionality allows the user to quickly and easily record the details of a fish in real time as they make a catch. It is currently a simple form in which the user inputs the data either in dropdown form or as a freeform text field. The fields currently align to the database schema with only a few auto-generated fields. 
    - Fish Species: Dropdown of a list of available fish species to minimize user input errors.
        - potential issues we can resolve: As user base grows, all fish species might not be accounted for in the static dropdown list. need to be able to handle new fish species in the future. 
    - Name of Angler: Free text field. This has caused issues in the past as extra spaces/etc entered into the text field has essentially created a 'new' Angler. In the app re-write, this was somewhat addressed by forcing the user to select one or many Anglers to be included as part of a 'Trip', but we can discuss this design decision. 
    - Weight of Fish: number field, fairly straightforward
    - Reservoir: dropdown of available fishing locations. This is a fairly critical field for the design of the existing application. All records/etc and the UI are based on grouping the data by fishing location. this allows the user to view things like total fish caught per location across all trips, largest fish at each location, average fish counts per trip, etc.
    - Comments: Free text field, rarely used currently in production
    - 'Add current Location' - Button that the user has to manually click when they are recording a fish that captures the user's current location by Latitude and Longitude. I'd like this to be a more seamless process, and one of the main issues the users face is recording location in remote areas with poor cell service, which makes the location details sometimes inaccurate. 

2. Main Dashboard 
- When the user first enters the app, this is the main nagivation screen. There are a couple different paths the user can take.
    1. Reservoir Tiles - as mentioned above, records are organized by fishing location (or reservoirs in the legacy app). each fishing location has a couple different actions: 
        - Start Trip - start a new fishing trip at this location, will open up the 'Active Trip' workflow that will be documented separately. 
        - Reservoir Details - Navigates the user to a details page for all the data related to a specific reservoir. this screen will be documented separately. 
    2. Analytics Button - allows the user to navigate to a dedicated analytics screen with additional tiles for data visualizations/etc

3. Reservoir Details
- When a user clicks on the the corresponding reservoir tile -> reservoir details button, they are navigated to the Reservoir details screen that contains the following components:
    1. High level metrics - total trips, total fish, total weight
        - can be filtered by year or all time values
    2. Trip Tiles - each trip that the user records for this specific reservoir gets a tile. they are sorted chronologically with the most recent trips at the top. the trip tiles can be filtered to only display a single year, or all trips, all time
        -trip tiles contain high level information: Anglers on the trip, total fish, total weight, date
        -trip tiles contain the View Trip Details button which navigates the user to a more detailed screen for that specific trip. this screen will be documented separately. 
    3. Catch Map - this requirement will be documented separately, but the intention is to leverage the location data to build a visualization of all the fish locations for the specific reservoir. 

4. Trip Details
- Trip details contains more detailed information/data for one specific trip: date, trip duration
- Catch Map - leverages the catch location data to map where specific catches were recorded for the specific trip. 
- Catch list - Tile/row that captures: Fish species, Angler, Date, Time, weight of Fish
- Trip Weather - new feature to be added: capture weather data during the duration of the trip

5. Start Trip:
- if the user selects the 'Start Trip' button on a Reservoir Tile on the main dashboard, they are taken to the intermediate 'Start Trip' screen. 
- Only functionality here is to select from the list of anglers who is included on the trip. 
- also provides the opportunity to add a new angler that has never been on a trip before. This needs to instantiate a new 'Angler' record. 

6. Active Trip: 
- Once the user starts a trip, they are navigated to the Active Trip screen. this will be the most dynamic of the screens as this is where user inputs/etc are logged in real time. 
Components: 
    - active trip duration/timer
    -active catch map showing catch locations for the ongoing trip
    - active catch list - shows list of catches for the ongoing trip
    -record fish button - opens 'Record Fish' screen described above. 
    -end trip button - opens trip summary screen, addtional prompt to 'end trip' and save trip data

        
## ANALYTICS

If the user doesn't select a specific reservoir tile on the main dashboard, the other option is to navigate to the analytics dashboard. This has a separate set of tiles which allows the user to view different breakdowns of the data. 

1. Angler Totals: 
    - Total Fish Caught per angler. Filterable by Specific reservoir, specific year, or 'All' in both cases
    - High level metrics: Total Fish, Total Trips, Catch Average per trip, weight average per trip
    - total catch numbers by species. if a user has never caught a specific species, it doesn't appear on their list

2. Reservoir Leaderboard
- For each Reservoir, a top 10 list of the largest fish caught. Filterable by year, or 'All'
- Angler, Species, Weight, and year caught

3. Species Breakdown
- For each species, display the total number of fish caught of the species broken down by reservoir.Filterable by year, or 'All'

4. Catch Trends per Species
- The user is prompted to select a species, and a chart displaying all months of the year is displayed. Total number of the specific species caught for each month are displayed. 

These are the current data points being displayed, but the intention of the Analytics dashboard and tile navigation is intended to be extendable as more metrics are added. 