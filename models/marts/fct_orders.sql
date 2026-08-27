with int_order_items as (
    select * from {{ ref('int_order_items') }}
)
select 
    order_id,

    min(created_at) as order_created_at,

    sum(retail_price) as total_order_value,
    sum(cogs) as total_order_cogs,
    sum(gross_profit) as order_profit,
    sum(net_revenue) as net_order_revenue,

    user_id,
    date(min(created_at)) as date_key,
    extract(hour from min(created_at)) as time_key,

    count(order_item_id) as total_order_count,
    max(is_returned) as is_order_returned,
    max(is_cancelled) as is_order_cancelled,
    max(is_fulfilled) as is_order_fufilled

    from int_order_items
    group by order_id, user_id