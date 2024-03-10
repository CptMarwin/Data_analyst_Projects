---KPI queries

select sum(total_price) as Total_revenue 
from pizza_sales 


select  sum(total_price)/count(distinct order_id) as Average_order_value
from pizza_sales

select sum(quantity) as Total_pizzas_sold 
from pizza_sales 

select count(distinct order_id) as Total_orders
from pizza_sales 

select cast(sum(quantity)/ cast(count(distinct order_id) as decimal(10,2)) as decimal(10,2)) as Avr_pizzas_Per_order
from pizza_sales

-----

select DATENAME(DW, order_date) as order_day, count(distinct order_id) as Total_orders
from pizza_sales
group by DATENAME(DW, order_date)
order by DATENAME(DW, order_date)


select * from pizza_sales

select DATENAME(MONTH, order_date) as Month_name, count(distinct order_id) as Total_orders
from pizza_sales
group by DATENAME(MONTH, order_date)
order by Total_orders desc

select pizza_category, cast(SUM(total_price) *100 / (select SUM(total_price) from pizza_sales where DATENAME(MONTH, order_date) = 'January') as decimal(10,2)) as Sales_Percentage
from pizza_sales
where DATENAME(MONTH, order_date) = 'January'
group by pizza_category

select pizza_size, cast(SUM(total_price) *100 / (select SUM(total_price) from pizza_sales) as decimal(10,2)) as Sales_Percentage
from pizza_sales
--where DATENAME(MONTH, order_date) = 'January'
group by pizza_size

select TOP 5 pizza_name, cast(sum(total_price) as decimal(10,2)) as Revenue
from pizza_sales
group by pizza_name
order by Revenue desc

select TOP 5 pizza_name, sum(quantity) as Total_orders
from pizza_sales
group by pizza_name
order by Total_orders desc

select TOP 5 pizza_name, COUNT(distinct order_id) as Total_orders
from pizza_sales
group by pizza_name
order by Total_orders desc

select TOP 5 pizza_name, cast(sum(total_price) as decimal(10,2)) as Revenue
from pizza_sales
group by pizza_name
order by Revenue 

select TOP 5 pizza_name, sum(quantity) as Total_orders
from pizza_sales
group by pizza_name
order by Total_orders 

select TOP 5 pizza_name, COUNT(distinct order_id) as Total_orders
from pizza_sales
group by pizza_name
order by Total_orders 





