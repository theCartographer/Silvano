
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





