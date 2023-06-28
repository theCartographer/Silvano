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







