# Alza Banner Campaign Monitoring

## Overview
A concise SQL-based solution for tracking and analyzing banner advertising campaigns across multiple sites. Includes:

- Schema definitions with tables, keys and constraints
- Sample data scripts to generate realistic test records
- Queries for:
    - Campaign balance (revenue vs. cost)
    - Weekly CPD balance breakdown by weekday
- Index scripts to optimize joins and date filters
- ER diagram (`docs/AlzaCampaignsDiagram.png`)

## Prerequisites
- SQL Server 2019 or later (or Docker image)
- JetBrains DataGrip (or any T-SQL client)
- Docker Desktop (optional, for local testing)

## Getting Started

**Clone the repo**
   ```bash
   git clone git@github.com:BlahBlahBleeBlahBloop/alza-banner-campaign-monitoring.git
   ```

**(Optional) Run SQL Server in Docker**
```bash
    docker run -e "ACCEPT_EULA=Y" \
           -e "SA_PASSWORD=YourStrong!Passw0rd" \
           -p 1433:1433 \
           --name alza-sqlserver \
           -d mcr.microsoft.com/mssql/server:2019-latest
   ```

**Create and switch to your database**
```bash
CREATE DATABASE AlzaCampaigns;
GO
USE AlzaCampaigns;
GO
```


### Applying the Schema

Run the scripts in the following order:

1. **Tables**  
   - src/schema/01_create_tables.sql

2. **Constraints**
   - src/constraints/05_create_constraints.sql

3. **Indexes**
   - src/indexes/04_create_indexes.sql

### Loading Sample Data

1. **Populate test data**
   - src/data/sample_data.sql

### Running the Queries

- **Campaign balance**  
  - src/queries/02_campaign_balance.sql

- **Weekly CPD balance**
  - src/queries/03_weekly_cpd_balance.sql

Results can be viewed directly in DataGrip or exported for reporting tools.
