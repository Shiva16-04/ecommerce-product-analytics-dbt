with int_order_items as (
    select * from {{ ref('int_order_items') }}
)
select 
    order_item_id,

    status,
    created_at,
    shipped_at,
    delivered_at,
    returned_at,

    category,
    brand,
    department,

    retail_price,
    cogs,
    gross_profit,
    net_revenue,

    is_cancelled,
    is_returned,
    is_fulfilled,
    user_purchase_type,

    date(created_at) as date_key,
    extract(hour from created_at) as time_key,
    order_id,
    user_id,
    product_id,
    inventory_item_id,
    distribution_center_id

    from int_order_items