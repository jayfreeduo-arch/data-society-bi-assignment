-- question 1
with yearly_segment_sales as (
    select 
        c.year,
        cust.segment,
        sum(s.unitprice) as total_unit_price,
        rank() over (partition by c.year order by sum(s.unitprice) desc) as sales_rank
    from sales s
    join customers cust on s.customerid = cust.customerid
    join calendar c on s.orderdate = c.date
    group by c.year, cust.segment
)
select 
    year,
    segment,
    total_unit_price
from yearly_segment_sales
where sales_rank = 1
order by year;

-- question 2
select 
    p.subcategory,
    sum(case when c.year = 2024 then s.quantity else 0 end) as units_2024,
    sum(case when c.year = 2025 then s.quantity else 0 end) as units_2025,
    (sum(case when c.year = 2025 then s.quantity else 0 end) - 
     sum(case when c.year = 2024 then s.quantity else 0 end)) as absolute_unit_growth,
    round(
        (sum(case when c.year = 2025 then s.quantity else 0 end) - sum(case when c.year = 2024 then s.quantity else 0 end)) * 100.0 / 
        nullif(sum(case when c.year = 2024 then s.quantity else 0 end), 0), 2
    ) as percentage_growth
from sales s
join products p on s.productid = p.productid
join calendar c on s.orderdate = c.date
where c.year in (2024, 2025)
group by p.subcategory
order by absolute_unit_growth desc
limit 1;

-- question 3
with monthly_regional_sales as (
    select 
        s.region,
        c.month,
        c.monthname,
        sum(s.unitprice) as monthly_unit_price
    from sales s
    join calendar c on s.orderdate = c.date
    where c.year = 2024
    group by s.region, c.month, c.monthname
)
select 
    region,
    month,
    monthname,
    monthly_unit_price,
    lag(monthly_unit_price) over (partition by region order by month) as previous_month_unit_price,
    (monthly_unit_price - lag(monthly_unit_price) over (partition by region order by month)) as mom_value_change,
    round(
        (monthly_unit_price - lag(monthly_unit_price) over (partition by region order by month)) * 100.0 / 
        nullif(lag(monthly_unit_price) over (partition by region order by month), 0), 2
    ) as mom_percentage_change
from monthly_regional_sales
order by region, month;

-- question 4
select 
    p.subcategory,
    round(avg(case when s.discount > 0 then s.quantity end), 2) as avg_units_per_order_discounted,
    round(avg(case when s.discount = 0 then s.quantity end), 2) as avg_units_per_order_full_price,
    round(
        avg(case when s.discount > 0 then s.quantity end) - 
        avg(case when s.discount = 0 then s.quantity end), 2
    ) as avg_units_diff
from sales s
join products p on s.productid = p.productid
group by p.subcategory
order by avg_units_diff desc;

-- question 5
update customers
set segment = 'Enterprise'
where customername = 'Customer_1096';