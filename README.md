# Amazon E-commerce SQL Analysis

A MySQL analysis of a simulated e-commerce dataset. The project covers customer segmentation, product inventory, sales channel performance, customer satisfaction, revenue trends, and product profitability.

## Tools

- MySQL 8.0+ (uses window functions, CTEs, and `LAG()`)

## Database Schema

The database is `amazondb` and contains six tables:

| Table | Purpose |
|---|---|
| `customers` | Customer details, signup date, activity status, customer segment, and state |
| `products` | Product name, category, status, stock quantity, unit price, and cost price |
| `orders` | Order status, sales channel, and the customer who placed each order |
| `order_items` | Line items for each order, with quantity and line total |
| `payments` | Payment records with amount, date, and status |
| `reviews` | Product ratings and review IDs |

## Setup

1. Open MySQL Workbench or your preferred MySQL client.
2. Run the script to create the database:

   ```sql
   CREATE DATABASE amazondb;
   USE amazondb;
   ```

3. Import the data for each table, then run `amazon_sql_analysis.sql`.

## Queries

| # | Business Question | Key Techniques |
|---|---|---|
| 1 | Active customers who signed up in 2025 and belong to the Loyal or Regular segment | Filtering, date range, `IN` |
| 2 | Active products with low stock (under 50 units) and unit price above ₹5,000, sorted by stock | Filtering, sorting |
| 3 | Total, delivered, and cancelled orders per sales channel, with delivery rate | Conditional aggregation with `CASE`, `GROUP BY` |
| 4 | Product review analysis by category: review counts, average rating, positive and negative reviews, and positive review rate | Joins, conditional aggregation, `HAVING` |
| 5 | Monthly revenue from successful payments | `DATE_FORMAT`, aggregation |
| 6 | Top 10 customers by total successful payment amount | Multi-table joins, `ORDER BY`, `LIMIT` |
| 7 | Monthly revenue compared with the previous month | CTEs, `LAG()` window function |
| 8 | Top 3 customers by spend in each state | CTEs, `DENSE_RANK()` with `PARTITION BY` |
| 9 | Most profitable products after cost and discounts (delivered orders, minimum 10 units sold) | Multi-table joins, CTEs, profit margin calculation |

## Key Metrics

- **Delivery rate:** delivered orders as a percentage of all orders in a sales channel.
- **Positive review rate:** reviews rated 4 or 5 as a percentage of all reviews in a category.
- **Profit margin:** (total revenue − total cost) ÷ total revenue, as a percentage.

## Skills Demonstrated

- Writing joins across multiple related tables
- Conditional aggregation with `CASE WHEN`
- Window functions (`LAG`, `DENSE_RANK`)
- Common table expressions (CTEs) for multi-step logic
- Date formatting and monthly trend analysis
- Translating business questions into SQL queries

## Project Structure

```
amazon-sql-analysis/
├── amazon_sql_analysis.sql   # All queries, in order
└── README.md
```
