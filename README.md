# Zomato Dataset Analysis with SQL
## Overview
This project utilizes a sample dataset from Zomato, a leading restaurant discovery and food delivery platform. The goal is to perform data analysis using SQL queries. We have five different data tables available for analysis, and by joining them as required, we aim to derive meaningful insights and solutions related to Zomato’s operations, delivery performance, and customer preferences.
## Requirnments
Database: MySQL

Dataset: Created Table using queries

Tables: gold_usersignups, product, sales, users

## Sample Queries

-- total amount spent by each user on zomato

select s.userid, sum(p.price) as amount_spent from sales as s left join product as p on p.product_id=s.product_id group by s.userid order by s.userid ;


-- which item was ordered by customer before they became golduser

SELECT s.userid, s.product_id, s.created_date
FROM sales as s
WHERE s.created_date = (
    SELECT max(s2.created_date)
    FROM sales as s2
    JOIN goldusers_signup as g ON s2.userid = g.userid
    WHERE s2.userid = s.userid
      AND s2.created_date < g.gold_signup_date
);
