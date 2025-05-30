create database zomato;
use zomato;

-- Create and populate goldusers_signup
CREATE TABLE goldusers_signup (
    userid INT,
    gold_signup_date DATE
); 

INSERT INTO goldusers_signup (userid, gold_signup_date) 
VALUES 
(1, '2017-09-22'),
(3, '2017-04-21');

-- Create and populate users
CREATE TABLE users (
    userid INT,
    signup_date DATE
); 

INSERT INTO users (userid, signup_date) 
VALUES 
(1, '2014-09-02'),
(2, '2015-01-15'),
(3, '2014-04-11');

-- Create and populate sales
CREATE TABLE sales (
    userid INT,
    created_date DATE,
    product_id INT
); 

INSERT INTO sales (userid, created_date, product_id) 
VALUES 
(1, '2017-04-19', 2),
(3, '2019-12-18', 1),
(2, '2020-07-20', 3),
(1, '2019-10-23', 2),
(1, '2018-03-19', 3),
(3, '2016-12-20', 2),
(1, '2016-11-09', 1),
(1, '2016-05-20', 3),
(2, '2017-09-24', 1),
(1, '2017-03-11', 2),
(1, '2016-03-11', 1),
(3, '2016-11-10', 1),
(3, '2017-12-07', 2),
(3, '2016-12-15', 2),
(2, '2017-11-08', 2),
(2, '2018-09-10', 3);

-- Create and populate product
CREATE TABLE product (
    product_id INT,
    product_name VARCHAR(50),
    price INT
); 

INSERT INTO product (product_id, product_name, price) 
VALUES
(1, 'p1', 980),
(2, 'p2', 870),
(3, 'p3', 330);

-- View table data
SELECT * FROM sales;
SELECT * FROM product;
SELECT * FROM goldusers_signup;
SELECT * FROM users;

-- total amount spent by each user on zomato
select s.userid, sum(p.price) as amount_spent from sales as s left join product as p on p.product_id=s.product_id group by s.userid order by s.userid ;

-- how many days a pearson visited Zomato
select userid, count(distinct created_date) as no_times_visites from sales group by userid;

-- first product purchased by each customer
SELECT userid, product_id, created_date FROM sales as s WHERE created_date = (SELECT MIN(created_date) FROM sales WHERE userid = s.userid);

-- most purchased item and how many time it was purchased
SELECT product_id, COUNT(*) AS order_count FROM sales GROUP BY product_id order by  order_count desc;

-- how many times the most ordered product is purchased by each user
select userid, count(userid) from sales where product_id = 2 group by userid order by userid;

-- which item was the most ordered item of each customer
SELECT userid, product_id, COUNT(*) AS order_count FROM sales
GROUP BY userid, product_id
HAVING COUNT(*) = (
    SELECT MAX(cnt)
     FROM (
        SELECT COUNT(*) AS cnt
        FROM sales AS s2
        WHERE s2.userid = sales.userid
        GROUP BY s2.product_id) AS sub );

-- which item was ordered by customer after they became golduser
SELECT s.userid, s.product_id, s.created_date
FROM sales as s
WHERE s.created_date = (
    SELECT MIN(s2.created_date)
    FROM sales as s2
    JOIN goldusers_signup as g ON s2.userid = g.userid
    WHERE s2.userid = s.userid
      AND s2.created_date > g.gold_signup_date
);

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

-- total order and amount spend by each member before becoming member
SELECT 
    s.userid,
    COUNT(*) AS total_orders_before_gold,
    SUM(p.price) AS total_amount_before_gold
FROM sales s
JOIN product as p ON s.product_id = p.product_id
JOIN goldusers_signup as g ON s.userid = g.userid
WHERE s.created_date < g.gold_signup_date
GROUP BY s.userid;

-- buying each product gives point p1 5rs = 1pt, p2 10rs = 5pt, p3 5rs = 1pt find points collected by each member and 
select 
     s.userid, 
  (sum(if(s.product_id = 1, p.price/5, 0))+ 
     sum(if(s.product_id = 2,p.price/2, 0))+
     sum(if(s.product_id = 3,p.price/5, 0))) as total_points
from sales as s 
left join product as p on p.product_id = s.product_id
group by s.userid;

-- proudct for which max points have been given
select 
     s.product_id,
  (sum(if(s.product_id = 1, p.price/5, 0))+ 
     sum(if(s.product_id = 2,p.price/2, 0))+
     sum(if(s.product_id = 3,p.price/5, 0))) as total_points
from sales as s 
left join product as p on p.product_id = s.product_id
group by s.product_id order by total_points desc;

-- in int first year after becoming member who earned most pt irrespective of product purchased 2rs = 1 pt
select s.userid, sum(if(timestampdiff(year, s.created_date, g.gold_signup_date) <=1, p.price/2, 0)) as total_pt_1year from sales as s
inner join goldusers_signup as g on g.userid = s.userid
inner join product as p on p.product_id = s.product_id
group by s.userid;

