## LaunchMart SQL Analysis

**Overview**

This project contains SQL queries for analyzing customer behavior, revenue performance and loyalty engagement. for LaunchMart(A growing e-commerce company).
The tasks were completed as part of a data analytics SQL challenge, focusing on query writing and data exploration using PostgreSQL.

#### Project Structure
LaunchMart_Sql_Analysis
- 01_schema.sql          # Table scripts (DDL)
- 02_seed_data.sql       # Data scripts
- 03_queries.sql         # Analytical solutions
- 03_launchMart_erd.png  # ER diagram of database schema
- README.md              # Project documentation

#### Setup Instructions

Follow these steps to set up and run the SQL queries locally using PostgreSQL, pgAdmin.

1. Create the Database: Open PostgreSQL environment (pgAdmin0) and Create Database launchmart_db;

2. Create Tables
Execute the DDL statements in 01_schema.sql to create all required tables: customers, products, orders, order_items and loyalty_points

3. Insert Sample Data
Run the 02_seed_data.sql file to populate the tables with sample data.

4. Run Queries
Use the 04_queries.sql file to execute and test all required business analysis queries.

**Analytical Tasks**

Below are some analytical problems solved in this project:

####	Task Description
-	Calculate Average Order Value (AOV) per customer.
-	Rank customers by total revenue using DENSE_RANK().
-	List customers with more than one order, showing order count and first/last order dates.
-	Compute total loyalty points for all customers, including those with zero.
-	Assign loyalty tiers (Bronze, Silver, Gold) and summarize tier counts and total points.
-	Identify customers who spent over ₦50,000 but have less than 200 loyalty points.
-	Flag churn risk customers who are Bronze-tier and have no orders in the last 90 days before 2023-12-31.

**Tools Used**
- PostgreSQL 15+
- pgAdmin 4
- SQL Queries(Basic queries, CTEs, Window Functions, Joins)

