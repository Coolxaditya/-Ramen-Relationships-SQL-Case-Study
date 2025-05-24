# Danny's Diner - SQL Case Study

This project and the data used were part of a case study, which can be found [here](https://8weeksqlchallenge.com/case-study-1/). It focuses on examining patterns, trends, and factors influencing customer spending to gain insights into their preferences, purchasing habits, and potential areas for improvement in menu offerings or marketing strategies in a dining establishment.

## Introduction

Danny seriously loves Japanese food and in early 2021, he opened a small restaurant that sells his three favorite foods: sushi, curry, and ramen. This case study explores customer patterns, spending habits, and menu preferences to help Danny improve his business and customer loyalty program.

## Database Schema

The database `dannys_diner` contains three tables:

### 1. `sales` table
Captures customer purchases with:
- `customer_id` - Customer identifier
- `order_date` - Date of purchase
- `product_id` - Menu item purchased

### 2. `menu` table
Maps products to details:
- `product_id` - Menu item identifier
- `product_name` - Name of the product (sushi, curry, ramen)
- `price` - Price of the item

### 3. `members` table
Tracks loyalty program members:
- `customer_id` - Customer identifier
- `join_date` - Date they joined the loyalty program

## Entity Relationship Diagram

```mermaid
erDiagram
    sales ||--o{ menu : "product_id"
    sales ||--o{ members : "customer_id"
    menu {
        int product_id PK
        varchar(20) product_name
        int price
    }
    sales {
        varchar(1) customer_id
        date order_date
        int product_id
    }
    members {
        varchar(1) customer_id
        date join_date
    }
