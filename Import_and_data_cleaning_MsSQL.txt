
--creating a temporary table for a mi_customer_profile data
IF OBJECT_ID('tempdb..#profile') is not null DROP TABLE tempdb..#profile

CREATE TABLE tempdb..#profile (
    cohort1 varchar(25),
    customer_id int,
    cohort varchar(25),
    foa_country varchar(25),
    foa_departure_date varchar(25),
    foa_departure_time time,
    foa_from_country varchar(25),
    foa_from_slug varchar(25),
    foa_mc4 varchar(25),
    foa_n_tickets int,
    foa_order_noi float,
    foa_platform varchar(25),
    foa_prebooking_days int,
    foa_tickets_noi float,
    foa_to_country varchar(25),
    foa_to_slug varchar(50),
    foa_trip_weekday int,
    foa_voucher_type varchar(25)

)

--Data import
BULK INSERT tempdb..#profile
    FROM 'F:\SFTP_Root\Temporary_Files\copy_Dataset.csv'
WITH
( FIRSTROW = 2,
    FIELDTERMINATOR = ','
    --ROWTERMINATOR = '\n'
)

--converting parameters into Date format

update tempdb..#profile
SET cohort = convert(date,cohort, 112)
where cohort is not null

update tempdb..#profile
SET cohort1 = convert(date,cohort1, 112)
where cohort is not null

update tempdb..#profile
SET foa_departure_date = convert(date,foa_departure_date, 112)
where foa_departure_date is not null


--creating a temporary table for a mi_customer_transactions

IF OBJECT_ID('tempdb..#Cust_Transactions') is not null DROP TABLE tempdb..#Cust_Transactions
CREATE TABLE tempdb..#Cust_Transactions (
    customer_id int,
    cohort varchar(25),
mc4 varchar(25),
order_id BIGINT,
seq_order int,
platform varchar(25),
order_date varchar(25),
relation varchar(50),
n_tickets int,
noi float

)

--Data import
BULK INSERT tempdb..#Cust_Transactions
    FROM 'F:\SFTP_Root\Temporary_Files\mi_customer_transactions.csv'
WITH
( FIRSTROW = 2,
    FIELDTERMINATOR = ','
    --ROWTERMINATOR = '\n'
)

--converting parameters into Date format


update tempdb..#Cust_Transactions
SET cohort = convert(date,cohort, 112)
where cohort is not null


update tempdb..#Cust_Transactions
SET order_date = convert(date,order_date, 112)
where order_date is not null


-- Data cleaning

-- looking for a duplicated customers profiles
Select customer_id, count(*) as multipied_redords
from tempdb..#profile
group by customer_id
Having
    count(*) > 1
order by customer_id ASC


--duplicates removal

WITH CTE AS (
    SELECT customer_ID, ROW_NUMBER() OVER(PARTITION BY customer_ID ORDER BY customer_ID) AS RN
    FROM tempdb..#profile
)
DELETE FROM CTE WHERE RN > 1;


--double checking for a multipied profile records
Select order_id,relation, count(*)
from tempdb..#Cust_Transactions
group by order_id,relation
Having
    count(*) > 1
order by order_id ASC


/* What was the percentage of customers who made at least a second booking within 6 months after acquisition?
   Write an SQL script to get to that result.
 */

Select customer_id, datediff(month, cohort,min(order_date) ) as DateDiff

    from tempdb..#Cust_Transactions
    group by  customer_id,cohort
    having datediff(month, cohort,min(order_date) ) > 0
        and datediff(month, cohort,min(order_date) ) <= 6


Select count( distinct customer_id) as Total_customers,
       count( DISTINCT CASE WHEN (datediff(month, Accq,Min_OrderDate ) > 0 and datediff(month, Accq,Min_OrderDate ) <= 6) THEN customer_id END) as customer_booking_withing_6_months,
       count( DISTINCT CASE WHEN (datediff(month, Accq,Min_OrderDate ) > 0 and datediff(month, Accq,Min_OrderDate ) <= 6) THEN customer_id END) * 100.0/count( distinct customer_id) as percent_bookied_withing_6_monhts

    from
        ( Select
              customer_id as Customer_Transaction_ID,
              cohort as Accq,
              Min(order_date) as Min_OrderDate
              From tempdb..#Cust_Transactions
              group by customer_id,cohort
              ) as TransactionCalc
    Full OUTER JOIN tempdb..#profile on TransactionCalc.Customer_Transaction_ID = #profile.customer_id



/*
 What was the Customer Lifetime Value (CLV) of customers who were acquired in Q3-2017 6 months after their acquisition?
 How has this CLV developed compared to customers who were acquired in Q3-2016?
 Which factors could have driven that evolution?
 Write a SQL script to get those results.
 Note: you can consider that CLV = Average Purchase Value Per Customer x Average Number of Purchases during the time period.
 */



Select
    AVG(AVG_purchese_value_per_customer * avg_number_of_pruchases) as CLV

from (Select customer_id,
             AVG(NOI)                                               as AVG_purchese_value_per_customer,
             count(distinct order_id) / count(distinct customer_id) as avg_number_of_pruchases

      from tempdb..#Cust_Transactions
      WHERE order_date <= dateadd(month, 6, cohort)
      AND customer_id in (
                Select customer_id
                from tempdb..#profile
                where cohort1 between '2017-07-01' and '2017-08-31'
              )
      group by customer_id) as customer_metrics


Select
    AVG(AVG_purchese_value_per_customer * avg_number_of_pruchases) as CLV

from (Select customer_id,
             AVG(NOI)                                               as AVG_purchese_value_per_customer,
             count(distinct order_id) / count(distinct customer_id) as avg_number_of_pruchases

      from tempdb..#Cust_Transactions
      WHERE order_date <= dateadd(month, 6, cohort)
      AND customer_id in (
                Select customer_id
                from tempdb..#profile
                where cohort1 between '2016-07-01' and '2016-08-31'
              )
      group by customer_id) as customer_metrics







