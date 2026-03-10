{\rtf1\ansi\ansicpg936\cocoartf2761
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\froman\fcharset0 Times-Roman;}
{\colortbl;\red255\green255\blue255;\red0\green0\blue0;\red109\green109\blue109;}
{\*\expandedcolortbl;;\cssrgb\c0\c0\c0;\cssrgb\c50196\c50196\c50196;}
\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\deftab720
\pard\pardeftab720\partightenfactor0

\f0\fs24 \cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec3 # Whole Foods Location Similarity Analysis\
\
## Project Overview\
\
This project develops a **data-driven location recommendation model** to identify census tracts in Los Angeles that resemble neighborhoods where **Whole Foods currently operates**.\
\
Using tract-level demographic, retail, and crime characteristics, the model compares each census tract to the profile of existing Whole Foods locations and ranks tracts by similarity score to identify potential expansion opportunities.\
\
The project implements a **data pipeline combining PySpark processing and Snowflake data warehousing**.\
\
---\
\
## Project Pipeline\
\
The analytical workflow consists of four main stages:\
\
1. Raw Data Integration  \
2. Tract-Level Feature Engineering  \
3. Similarity-Based Location Scoring  \
4. Snowflake Serving Layer  \
\
Pipeline structure:\
\
```text\
Raw Data\
   \uc0\u8595 \
data_processing.ipynb\
   \uc0\u8595 \
Tract-level datasets\
   \uc0\u8595 \
whole_foods_location_similarity_model.ipynb (PySpark pipeline)\
   \uc0\u8595 \
Candidate ranking\
   \uc0\u8595 \
Snowflake tables and views\
```\
\
---\
\
## Data Sources\
\
The analysis integrates several public datasets for Los Angeles:\
\
- **Los Angeles Crime Data** \'97 City of Los Angeles Open Data Portal  \
- **ACS Demographic Data** \'97 American Community Survey  \
- **TIGER/Line Census Tracts** \'97 U.S. Census Bureau tract boundaries  \
- **OpenStreetMap (OSM)** \'97 retail and service amenities  \
- **Whole Foods Store Locations** \'97 existing store coordinates  \
\
These datasets are spatially aggregated to the **census tract level**.\
\
---\
\
## Data Processing\
\
The notebook **`data_processing.ipynb`** constructs tract-level datasets used for modeling.\
\
Processing steps include:\
\
- Preparing Los Angeles census tract boundaries  \
- Cleaning and filtering crime records  \
- Mapping crime events to census tracts  \
- Aggregating OSM retail amenities by tract  \
- Integrating ACS demographic variables  \
- Computing tract-level density metrics  \
\
Outputs generated:\
\
```text\
tract_crime.csv\
tract_acs.csv\
tract_osm.csv\
tract_wf.csv\
```\
\
These files serve as the **feature inputs for the modeling stage**.\
\
Detailed documentation is available in:\
\
`DATA_PROCESSING.md`\
\
---\
\
## Spark-Based Modeling Pipeline\
\
The notebook **`whole_foods_location_similarity_model.ipynb`** implements a PySpark-based analytical pipeline that:\
\
1. Reads tract-level datasets  \
2. Merges them into a **master tract-level dataset**  \
3. Selects relevant modeling features  \
4. Standardizes variables using z-scores  \
5. Computes a **Whole Foods neighborhood centroid**  \
6. Measures **Euclidean distance** between each tract and the centroid  \
7. Converts distance into a **similarity score**  \
8. Ranks candidate tracts by similarity  \
\
Similarity score formula:\
\
```text\
score = 1 / (1 + distance)\
```\
\
Higher scores indicate tracts whose demographic and retail characteristics are more similar to neighborhoods where Whole Foods currently operates.\
\
---\
\
## Model Validation\
\
To validate the similarity-based ranking model, we test whether census tracts that already contain Whole Foods stores receive higher similarity scores.\
\
Validation checks include:\
\
- Average similarity score comparison  \
- Median similarity score comparison  \
- Recovery rate of existing Whole Foods tracts among the highest-scoring tracts  \
\
Results show that neighborhoods already containing Whole Foods stores tend to receive **higher similarity scores**, suggesting the model captures meaningful location characteristics.\
\
---\
\
## Snowflake Serving Layer\
\
Processed results are loaded into **Snowflake** to support querying and dashboard applications.\
\
Database structure:\
\
```text\
MSBA405\
\uc0\u9492 \u9472 \u9472  PROJECT\
    \uc0\u9500 \u9472 \u9472  TRACT_MASTER\
    \uc0\u9500 \u9472 \u9472  TOP_CANDIDATES\
    \uc0\u9492 \u9472 \u9472  WF_RECOMMENDATIONS (view)\
```\
\
Key tables:\
\
**TRACT_MASTER**  \
Master tract-level dataset containing demographic, crime, and retail features.\
\
**TOP_CANDIDATES**  \
Top-ranked census tracts recommended as potential Whole Foods expansion locations.\
\
**WF_RECOMMENDATIONS**  \
A view used for querying and dashboard presentation.\
\
Example query:\
\
```sql\
SELECT *\
FROM MSBA405.PROJECT.WF_RECOMMENDATIONS\
LIMIT 10;\
```\
\
---\
\
## Repository Structure\
\
```text\
project_repo/\
\uc0\u9500 \u9472 \u9472  README.md\
\uc0\u9500 \u9472 \u9472  DATA_PROCESSING.md\
\uc0\u9500 \u9472 \u9472  notebooks/\
\uc0\u9474    \u9500 \u9472 \u9472  data_processing.ipynb\
\uc0\u9474    \u9492 \u9472 \u9472  whole_foods_location_similarity_model.ipynb\
\uc0\u9492 \u9472 \u9472  sql/\
    \uc0\u9500 \u9472 \u9472  snowflake_setup.sql\
    \uc0\u9492 \u9472 \u9472  snowflake_views.sql\
```\
\
---\
\
## Technologies Used\
\
- Python  \
- PySpark  \
- Snowflake  \
- SQL  \
- Jupyter Notebook  \
- Google Colab  \
\
---\
\
## Output\
\
The final output of the project is a **ranked list of census tracts most similar to existing Whole Foods neighborhoods**, which can be used as a starting point for location analysis and expansion strategy.\strokec2 \
\
}