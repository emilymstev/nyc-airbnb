# NYC Airbnb Visualization App

An interactive **R Shiny** web application that helps users explore and compare Airbnb listings across New York City neighborhoods. The app combines Airbnb listing data with NYC census information to provide insights into neighborhood demographics, host activity, and available Airbnb accommodations.

---

## Features

- **Neighborhood Comparison**  
  Compare two NYC neighborhoods side by side using census data. Metrics include:  
  - Total population  
  - % below poverty level  
  - % commuting by transit  
  - % walking to work  

- **Host Summary**  
  Select and compare multiple hosts. View listings by:  
  - Price per night  
  - Availability (365 days)  
  - Number of reviews  

- **Interactive Map**  
  Filter and explore Airbnb listings by:  
  - Price range (up to $1000/night)  
  - Room type  
  - Neighborhood  
  Results are displayed on an interactive **Leaflet map** with cluster markers and popups.  

---

## Data Sources  

This app uses two datasets, both available on **Kaggle**:  

1. **Airbnb Listings — `AB_NYC_2019.csv`**  
   - Contains data on Airbnb locations in New York City, including price, location, room type, number of reviews, and more.  
   - [Download from Kaggle](https://www.kaggle.com/dgomonov/new-york-city-airbnb-open-data)  

2. **NYC Census Data — `nyc_census_tracts.csv`**  
   - Contains demographic information for New York City census tracts, including population, poverty rate, and commuting methods.  
   - [Download from Kaggle](https://www.kaggle.com/muonneutrino/new-york-city-census-data)  

After downloading, save both CSV files in the **project root folder**.  


## Requirements

- **R version**: 4.0 or later (earlier versions may work, but not tested)  
- **R packages** (install with `install.packages()`):  
  - `shiny`  
  - `dplyr`  
  - `ggplot2`  
  - `leaflet`  
  - `tidyverse`  
  - `readxl`  

You can install them all at once with:  

```r
install.packages(c("shiny", "dplyr", "ggplot2", "leaflet", "tidyverse", "readxl"))

```

Run the application via the app.R file

## Project Structure

```plaintext
├── app.R                  # Main Shiny application (UI + server logic)
├── Data.r                 # Data loading and aggregation scripts
├── AB_NYC_2019.csv        # Airbnb dataset (download from Kaggle)
├── nyc_census_tracts.csv  # NYC census dataset (download from Kaggle)
└── README.md              # Project documentation
```
