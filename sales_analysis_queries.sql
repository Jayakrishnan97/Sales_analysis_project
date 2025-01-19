-- find top top 10 highest revenue generating products

select product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc
limit 10

-- find top 5 highest selling products in each region

with cte as (select region, product_id, sum(sale_price) as sales, row_number() over(partition by region order by sum(sale_price) desc)
from df_orders
group by region, product_id)
select * from cte
where row_number <= 5

--find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023

with cte as (select date_part('year', cast(order_date as date)) as order_year
, date_part('month', cast(order_date as date)) as order_month, sum(sale_price) as sales
from df_orders
group by date_part('year', cast(order_date as date)), date_part('month', cast(order_date as date)))
select order_month
, round(cast(sum(case when order_year = 2022 then sales else 0 end) as numeric),2) as sales_2022
, round(cast(sum(case when order_year = 2023 then sales else 0 end) as numeric),2) as sales_2023
from cte
group by order_month
order by order_month


--for each category which month had highest sales


with cte as (select category, to_char(cast(order_date as date), 'yyyyMM') as order_year_month
, round(cast(sum(sale_price) as numeric),2) as sales
from df_orders
group by category, to_char(cast(order_date as date), 'yyyyMM')
order by category, to_char(cast(order_date as date), 'yyyyMM'))
select * from (
select *, row_number() over(partition by category order by sales desc) as rn
from cte)
where rn = 1


--which sub category had highest growth by profit in 2023 compare to 2022


with cte as (select sub_category, date_part('year', cast(order_date as date)) as order_year
, sum(sale_price) as sales
from df_orders
group by sub_category, date_part('year', cast(order_date as date))),
cte2 as(
select sub_category
, round(cast(sum(case when order_year = 2022 then sales else 0 end) as numeric),2) as sales_2022
, round(cast(sum(case when order_year = 2023 then sales else 0 end) as numeric),2) as sales_2023
from cte
group by sub_category
order by sub_category)
select *
, round((sales_2023-sales_2022) * 100 / sales_2022,2) as growth_perc
from cte2
order by (sales_2023-sales_2022) * 100 / sales_2022 desc
limit 1

