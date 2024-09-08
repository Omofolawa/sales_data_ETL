# Sales Data ETL Pipeline

This project demonstrates an end-to-end **ETL (Extract, Transform, Load)** pipeline for sales data using various tools and technologies. The pipeline includes data generation, transformation, and storage, ultimately feeding into **Power BI** for visualization.

## Project Overview

The ETL pipeline follows these steps:
1. **Data Generation**: Synthetic sales data was generated using Python libraries such as `csv`, `pandas`, `Faker`, `random`, and `datetime`.
2. **Data Storage**: The generated data was stored as a CSV file within the project folder.
3. **Data Review and Blob Storage**: The data was reviewed and then stored in **Azure Blob Storage**.
4. **Data Ingestion**: The data was ingested into **Azure Data Factory (ADF)** for further transformation and processing.
5. **Data Transformation**: 
   - Using the **ADF Data Flow Canvas**, two transformations were applied:
     - A **calculated column** for `TotalAmount`, derived from multiplying `Quantity` and `Price`.
     - A **substring extraction** to reformat the `SalesDate` column to display only the date (without time).
   - Real-time transformation was enabled using ADF’s **debug mode** and cluster processing.
6. **Clean Data Storage**: The transformed data was stored back into **Azure Blob Storage**.
7. **Data Visualization**: The cleaned data was visualized using **Power BI** for insights.

## Tools and Technologies

- **Python**: For data generation using libraries like `pandas`, `Faker`, and others.
- **Jupyter Notebook**: To run Python scripts and generate the sales data.
- **Azure Blob Storage**: For storing the raw and transformed data.
- **Azure Data Factory (ADF)**: For orchestrating the ETL pipeline and applying data transformations.
- **Power BI**: For visualizing the cleaned and processed data.

## Pipeline Details

### 1. Data Generation
- Synthetic sales data was created using `Faker` to generate customer names, `random` for product data, and `datetime` for timestamps.
- The data was saved as a CSV file in the project folder.

### 2. Data Ingestion & Transformation
- The raw CSV file was ingested into Azure Data Factory.
- **ADF Data Flow** was used to apply two key transformations:
  - **TotalAmount Calculation**: A calculated column was added to the sales data, multiplying `Quantity` and `Price` to create the `TotalAmount` field.
  - **Date Format Correction**: The `SalesDate` column was cleaned by extracting only the date (removing the time component).

### 3. Data Storage & Visualization
- The cleaned and transformed data was stored back into **Azure Blob Storage**.
- **Power BI** was connected to the cleaned dataset, allowing interactive data exploration and visualization.

## Visualization (Power BI)
Power BI was used to create dashboards and reports for the transformed sales data, providing insights into:
- Total sales by product and region
- Sales trends over time
- Sales performance by sales representatives

## Conclusion

This project showcases a complete ETL pipeline, from data generation to visualizing insights. It integrates multiple tools like Python, Azure, and Power BI to process and analyze sales data efficiently.

--------------------------------------------------------------------------------------------------------------------------------------------------------------
