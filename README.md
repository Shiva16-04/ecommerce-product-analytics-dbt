# ⚙️ E-Commerce Dimensional Data Warehouse (dbt + BigQuery)

Production dbt data transformation pipeline converting the Google BigQuery public dataset `thelook_ecommerce` into an enterprise-grade Kimball dimensional Multi Fact star schema.

> 📊 **Downstream BI Dashboard:**  
> These transformed marts power the executive Power BI reporting layer.  
> View the dashboard and DAX metrics: **[ecommerce-powerbi-analytics](https://github.com/Shiva16-04/ecommerce-powerbi-analytics)**

---

## 🏗️ Data Architecture & Flow
BigQuery Public Source (thelook_ecommerce)
                │
                ▼
Staging Layer (models/staging/) ──> [source extraction, cleaning, type casting, column aliasing]
                │
                ▼
Intermediate Layer (models/intermediate/int_order_items.sql) ──> [Business rules, margin enrichment]
                │
                ▼
Marts Layer (models/marts/) ──> [Fact Constellation Schema/Galaxy Schema: Dimensions & Fact Tables]
                │
                ▼
Power BI Semantic Model (DirectQuery)
