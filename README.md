# COVID-19 Global Analysis

## Overview
This repository provides a comprehensive **SQL-based analysis of global COVID-19 data**, including cases, deaths, population, and vaccination statistics. The project examines trends, disparities, and the impact of vaccinations across countries and continents using advanced SQL techniques.

## Key Features
- Tracks **case fatality rates (CFR)** and total deaths over time.
- Compares **total cases relative to population** for countries worldwide.
- Assesses **vaccination rollout**, coverage, and inequality across countries.
- Identifies **peak outbreak days** and calculates **week-over-week growth rates**.
- Ranks countries by **daily CFR** to analyze pandemic severity dynamically.
- Uses advanced SQL features:
  - **Window functions**: `RANK()`, `DENSE_RANK()`, `NTILE()`, `LAG()`
  - **Cumulative sums and rolling averages**
  - Subqueries and temporary tables for performance optimization.

## Datasets
- `coviddeaths`: Contains daily COVID-19 cases, deaths, population, and continent for multiple countries.
- `covidvaccinations`: Contains daily vaccination counts and GDP per capita for each country.

