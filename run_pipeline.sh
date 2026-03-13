#!/bin/bash

echo "================================================"
echo "Starting Whole Foods Location Scoring Pipeline"
echo "================================================"

BASE="/content/drive/MyDrive/msba405-group-project"
NB="$BASE/notebooks"
OUT="$BASE/pipeline_outputs"

echo ""
echo "[Stage 1/3] Running tract-level data processing pipeline"
echo "Objective: Clean raw datasets and generate tract-level feature tables"

papermill \
"$NB/data_processing.ipynb" \
"$OUT/data_processing_executed.ipynb"

echo ""
echo "[Stage 2/3] Running Spark similarity scoring model"
echo "Objective: Merge tract features, compute similarity scores, and rank candidate locations"

papermill \
"$NB/whole_foods_location_similarity_model.ipynb" \
"$OUT/model_executed.ipynb"

echo ""
echo "[Stage 3/3] Publishing results to Snowflake serving layer"
echo "Objective: Upload tract scoring outputs and recommendation tables for downstream queries"

papermill \
"$NB/snowflake_pipeline.ipynb" \
"$OUT/snowflake_executed.ipynb"

echo ""
echo "================================================"
echo "Pipeline execution completed successfully"
echo "Generated outputs include:"
echo "- tract-level feature tables"
echo "- ranked candidate locations"
echo "- Snowflake serving tables and views"
echo "================================================"

