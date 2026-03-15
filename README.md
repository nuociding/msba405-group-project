# Whole Foods Location Scoring Pipeline

**MSBA 405 Final Project Team 18**

This project builds an **end-to-end data pipeline** to identify candidate locations for new **Whole Foods Market openings in Los Angeles County** by analyzing demographic characteristics, crime conditions, and neighborhood retail environments.

The pipeline integrates multiple public datasets, constructs tract-level features, computes similarity scores between census tracts and existing Whole Foods locations, and publishes the results for visualization and downstream analytics.

---

## 1. Problem Statement

Whole Foods Market tends to locate stores in neighborhoods with specific demographic and commercial characteristics.

This project attempts to identify **census tracts that resemble existing Whole Foods neighborhoods** and therefore represent promising expansion opportunities.

### Hypothesis

Census tracts that share similar characteristics with existing Whole Foods locations — including income levels, education attainment, population density, and retail environment — are strong candidates for future store expansion.

To evaluate this hypothesis, the project builds a data pipeline that:

1. Collects and processes multiple public datasets  
2. Constructs tract-level demographic, crime, and retail features  
3. Identifies candidate tracts that meet operational requirements  
4. Measures similarity to existing Whole Foods neighborhoods  
5. Ranks candidate tracts based on similarity scores  

---

## 2. Data Sources

The project integrates multiple public datasets related to **demographics, geography, crime, and amenities**.

### 2.1 U.S. Census Bureau (ACS Data)

**Source**  
[https://www.census.gov/](https://www.census.gov/)

The American Community Survey provides demographic and socioeconomic information at the census tract level.

**Key variables used**
- Median household income  
- Population  
- Educational attainment  
- Population age 25+  

**Derived variables**
- **income** — average tract income (2022–2024)  
- **pop** — average tract population (2022–2024)  
- **ba_rate** — proportion of residents age 25+ with a bachelor’s degree or higher  
- **pop_density** — population per square kilometer  

Population density is computed using tract population and tract land area.

---

### 2.2 Geographic Boundary Data

**Source**  
U.S. Census Bureau – TIGER/Line Shapefiles  
[https://www.census.gov/cgi-bin/geo/shapefiles/index.php](https://www.census.gov/cgi-bin/geo/shapefiles/index.php)

**Dataset used**
- 2024 Census Tract Boundaries  

Tract geometries are used for:
- spatial joins  
- population density calculations  
- mapping results in Tableau  

---

### 2.3 Los Angeles Crime Data

**Source**  
Los Angeles Open Data Portal  
[https://data.lacity.org/](https://data.lacity.org/)

Crime records from **2022–2024** are used.

#### Crime Classification

Crime descriptions are classified using a **keyword-based approach**.

**Violent crime keywords**
- HOMICIDE  
- ASSAULT  
- ROBBERY  

**Property crime keywords**
- BURGLARY  
- THEFT  
- CRIMINAL DAMAGE  

All other crimes are classified as **other crimes**.

#### Crime Rate Calculation

Crime indicators are computed per 1,000 residents:

```text
violent_per_1000 = violent incidents / population × 1000
property_per_1000 = property incidents / population × 1000
````

#### Low-Crime Indicator

A tract is labeled as a **low-crime tract** if:

* violent crime rate ≤ 60th percentile
* property crime rate ≤ 60th percentile

This creates the variable:

```text
crime_low_60
```

---

### 2.4 OpenStreetMap (OSM) Amenity Data

**Source**
[https://download.bbbike.org/osm/bbbike/](https://download.bbbike.org/osm/bbbike/)

The project extracts selected retail and service amenities from OpenStreetMap.

**Selected amenity categories**

* restaurant
* fast_food
* cafe
* bar
* pharmacy
* bank
* atm
* fuel
* ice_cream
* dentist
* clinic
* post_office
* post_box
* bicycle_rental
* vending_machine

#### Retail Density

Retail density is calculated as:

```text
retail_density = number of retail amenities / tract land area (sq km)
```

Tracts without retail points are assigned:

```text
retail_density = 0
```

---

### 2.5 Whole Foods Store Locations

Latitude and longitude coordinates of existing Whole Foods stores in Los Angeles are collected manually.

Store locations are converted into a **GeoDataFrame** and spatially joined with census tracts.

Each tract is labeled with:

```text
has_wf = 1 if it contains an existing Whole Foods store
```

---

## 3. Master Feature Table

All datasets are joined on the census tract identifier `GEOID`.

The final master feature table contains:

```text
GEOID
income
ba_rate
pop
pop_density
violent_per_1000
property_per_1000
crime_low_60
retail_density
has_wf
```

**Total census tracts**

```text
2498 tracts
```

---

## 4. Feature Selection and Candidate Definition

The similarity model focuses on tract characteristics that are plausibly associated with existing Whole Foods locations.

### Modeling Variables

The model uses the following four features:

* income
* ba_rate
* pop_density
* retail_density

These variables represent:

* purchasing power
* education level
* urban density
* retail environment

### Operational Filters

Two additional conditions define the **candidate tract universe**.

Candidate tracts must:

1. satisfy the low-crime condition
2. not already contain a Whole Foods store

```text
crime_low_60 == True
has_wf == 0
```

After applying these filters and removing missing values, the final candidate set contains:

```text
1358 candidate tracts
```

---

## 5. Similarity Scoring Model

The project uses a **similarity-based scoring approach** rather than a supervised prediction model.

The goal is to identify census tracts that most closely resemble the profile of existing Whole Foods neighborhoods.

### 5.1 Feature Standardization

Because the modeling variables are measured on different scales, they are first converted into **z-scores**.

```text
z = (x − mean) / standard deviation
```

**Standardized variables**

* z_income
* z_ba_rate
* z_pop_density
* z_retail_density

---

### 5.2 Whole Foods Reference Profile

The model computes the **centroid of existing Whole Foods tracts** in standardized feature space.

This centroid represents the **average neighborhood profile** of current Whole Foods locations.

---

### 5.3 Distance Calculation

For each candidate tract, the model computes Euclidean distance to the Whole Foods centroid.

```text
distance_i = sqrt(
(z_income_i − z_income_wf)^2 +
(z_ba_rate_i − z_ba_rate_wf)^2 +
(z_pop_density_i − z_pop_density_wf)^2 +
(z_retail_density_i − z_retail_density_wf)^2
)
```

A smaller distance indicates that a tract more closely resembles existing Whole Foods neighborhoods.

---

### 5.4 Similarity Score

To improve interpretability, distance is converted into a bounded similarity score:

```text
score = 1 / (1 + distance)
```

**Properties**

* `score ∈ (0, 1)`
* higher score = stronger similarity

---

### 5.5 Ranking Candidate Locations

Candidate tracts are ranked by similarity score in descending order.

The highest-ranked tracts represent the strongest candidates for potential Whole Foods expansion.

---

## 6. Data Pipeline

The project pipeline consists of three stages.

```text
Raw Data
↓
Feature Engineering
↓
Similarity Scoring Model
↓
Snowflake Serving Layer
↓
Tableau Visualization
```

### Stage 1 — Data Processing

**Notebook**
`data_processing.ipynb`

**Tasks**

* load raw datasets
* clean and standardize data
* construct tract-level features
* build master feature table

---

### Stage 2 — Similarity Scoring

**Notebook**
`whole_foods_location_similarity_model.ipynb`

**Tasks**

* define candidate tracts
* standardize features
* compute Whole Foods centroid
* calculate similarity scores
* rank candidate locations

---

### Stage 3 — Serving Layer

**Notebook**
`snowflake_pipeline.ipynb`

**Tasks**

* upload scoring results to Snowflake
* create tables for analytics and visualization
* enable dashboard queries

---


## 7. Tableau Dashboards

The final results are visualized using two interactive Tableau dashboards hosted on Tableau Public.

You can explore the dashboards directly here:

- **Dashboard 1 — Market Pattern Analysis**  
  https://public.tableau.com/app/profile/meng.ren6414/viz/405proj/Dashboard1?publish=yes

- **Dashboard 2 — Candidate Locations Opportunity Map**  
  https://public.tableau.com/app/profile/meng.ren6414/viz/405proj/Dashboard2?publish=yes

---

### Dashboard 1 — Market Pattern

This dashboard explains **why Whole Foods tends to choose certain neighborhoods** by comparing tracts with existing Whole Foods stores to all other tracts.

**Open the dashboard:**  
https://public.tableau.com/app/profile/meng.ren6414/viz/405proj/Dashboard1?publish=yes

**Visualizations include**

- **Income vs Population Density**  
  Shows how Whole Foods tracts tend to cluster in relatively affluent areas with moderate urban density.

- **Income vs Retail Density**  
  Highlights the relationship between purchasing power and neighborhood commercial activity.

- **Income vs Bachelor’s Degree Rate**  
  Shows that Whole Foods tracts are generally associated with higher educational attainment.

- **Whole Foods vs Non-Whole Foods Feature Comparison**  
  Compares average values of key features such as income, bachelor’s degree attainment, and retail density between tracts with and without Whole Foods stores.

**Purpose**

Dashboard 1 helps users understand the **market pattern behind existing Whole Foods locations**. It demonstrates that Whole Foods stores are more likely to be located in tracts with higher income, higher education levels, and stronger neighborhood commercial activity.

---

### Dashboard 2 — Candidate Locations for New Whole Foods Stores Opportunity Map

This dashboard presents the **final tract-level recommendations** for potential new Whole Foods openings in Los Angeles County.

**Open the dashboard:**  
https://public.tableau.com/app/profile/meng.ren6414/viz/405proj/Dashboard2?publish=yes

**Includes**

- **Geographic Opportunity Map**  
  A tract-level choropleth map of Los Angeles County colored by similarity score, where darker green indicates stronger opportunity.

- **Top 10 Candidates**  
  A ranked bar chart showing the highest-scoring candidate tracts.

- **Characteristics of the Top 10 Candidates**  
  A comparison panel displaying key variables for the highest-ranked tracts, including income, population density, and similarity metrics.

**Purpose**

Dashboard 2 allows users to **identify the strongest candidate tracts for expansion** and compare the characteristics of the top locations suggested by the similarity model.


---

## 8. Repository Structure

The repository is organized as follows:

```text
raw_data/
    Raw datasets downloaded from public sources
    (ACS, crime data, OSM extracts, tract boundaries)

processed_data/
    Intermediate tract-level datasets generated during preprocessing

notebooks/
    data_processing.ipynb
        Data cleaning and feature engineering

    whole_foods_location_similarity_model.ipynb
        Candidate tract selection and similarity scoring model

    snowflake_pipeline.ipynb
        Upload processed results to Snowflake

pipeline_outputs/
    Executed notebook outputs generated by the automated pipeline

run_pipeline.sh
    Shell script that runs the full pipeline sequentially
```

---

## 9. Credentials and External Services

The project uses **Snowflake** for the serving layer.

Because credentials cannot be shared, users should:

1. create their own Snowflake account
2. generate credentials
3. update the Snowflake connection settings in the notebook

---

## 10. Reproducibility

Once the datasets are downloaded and credentials are configured, running the pipeline notebooks will reproduce the entire workflow:

1. feature construction
2. candidate tract selection
3. similarity scoring
4. ranked expansion opportunities

