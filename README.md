# 📊 Slowly Changing Dimensions (SCD) in Data Warehousing

## 📖 Overview
Slowly Changing Dimensions (SCD) are used in data warehousing to manage historical data and track changes over time. They help maintain data integrity and ensure accurate reporting and analysis by preserving past values or overwriting them as per business needs.

## 🔄 Most Used SCD Types

### 🏛️ SCD Type 0 (Fixed Dimension)
- Data remains static after insertion, ensuring historical accuracy.
- Once a record is created, it is never updated or deleted.
- Useful for reference tables like country codes, postal codes, or static metadata.

### ✏️ SCD Type 1 (Overwrite)
- New data replaces old values, keeping only the latest information.
- No historical data is maintained, making it suitable for attributes that change frequently but do not require tracking.
- Commonly used for non-critical data such as email addresses, phone numbers, or temporary identifiers.

### 📜 SCD Type 2 (Historical Tracking)
- Maintains history by creating new records with versioning details.
- Uses additional columns like `EffectiveDate`, `EndDate`, and `VersionNumber` to track changes over time.
- Best suited for tracking slowly changing attributes such as employee job titles, customer addresses, or product price changes.

## ⚙️ Key Activities for SCD Type 1 & 2 in Synapse Workspace

1. **🔍 Select Activity** – Standardizes column names for clarity.
   - Ensures data is uniformly formatted before transformation.
   - Helps in maintaining consistency across the ETL process.

2. **🔑 Derived Column Activity** – Creates a unique HashKey for records.
   - Generates a hash value based on key attributes.
   - Helps in identifying whether a record has changed.

3. **📊 Lookup Activity** – Identifies changes by comparing ID and HashKey.
   - Checks if an incoming record already exists in the target table.
   - Determines if an update is required or if it’s a new insertion.

4. **🔀 Split Condition Activity** – Separates new and updated records.
   - Classifies records into categories: new inserts and existing updates.
   - Ensures appropriate processing for historical tracking.

5. **🧩 Union Activity** – Merges old records with new ones for updates.
   - Combines new records with existing data to maintain historical accuracy.
   - Prepares the dataset for final processing before loading.

6. **🔄 Alter Row Activity** – Defines update and insert rules.
   - Specifies whether to insert a new row, update an existing one, or mark old records as inactive.
   - Ensures correct handling of data modifications.

7. **📥 Sink Activity** – Loads processed data into the destination table.
   - Writes the final transformed data into the data warehouse.
   - Ensures seamless integration into the analytical environment.

## 🤔 When to Use SCD Types

- **🏛️ SCD Type 0**: Best for static, unchanging data where historical accuracy is paramount, such as predefined categories, product codes, or industry standards.
- **✏️ SCD Type 1**: Used when maintaining historical changes is not required, and only the latest data is relevant. Suitable for attributes like email addresses or contact information.
- **📜 SCD Type 2**: Ideal for comprehensive historical tracking, especially when businesses need to analyze past changes, such as salary adjustments, customer segmentation, or address changes.

## 🎯 Benefits of SCD Implementation

- **✅ Improved Data Integrity**: Ensures accurate data tracking and consistency by maintaining historical and current states of records as per business requirements.
- **📈 Enhanced Reporting**: Maintains historical records for better analytics, allowing users to generate reports on past trends and track data changes over time.
- **🚀 Optimized ETL Process**: Streamlines data transformations and updates by structuring workflows to efficiently handle inserts, updates, and historical data management.
