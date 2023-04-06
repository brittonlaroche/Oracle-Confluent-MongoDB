CREATE OR REPLACE VIEW "CUSTOMER_ORDER_PRODUCTS_BY_STORE" (
    "ORDER_ID", 
    "CUSTOMER_ID", 
    "EMAIL_ADDRESS", 
    "FULL_NAME", 
    "STORE_ID", 
    "STORE_NAME", 
    "ITEMS",
    "ORDER_DATETIME", 
    "ORDER_STATUS", 
    "ORDER_TOTAL") AS 
select cast(c.order_id as number(18,0)), 
    cast(c.customer_id as number(18,0)), 
    c.email_address, 
    c.full_name, 
    cast(s.store_id as number(18,0)), 
    s.store_name, 
    c.items, 
    c.order_datetime, 
    c.order_status, 
    cast(c.order_total as number(10,2) ) 
from customer_order_products c,
    stores s,
    orders o
where c.order_id = o.order_id
and o.store_id = s.store_id
