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






