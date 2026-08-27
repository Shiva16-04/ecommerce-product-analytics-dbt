with order_items as (
    select * from {{ ref('stg_thelook_order_items') }}
),
products as (
    select * from {{ ref('stg_thelook_products') }}
),
inventory_items as (
    select * from {{ ref('stg_thelook_inventory_items') }}
)
select 
    oi.id as order_item_id,
    
    oi.status,
    oi.created_at,
    oi.shipped_at,
    oi.delivered_at,
    oi.returned_at,
    
    p.category,
    p.brand,
    p.department,

    oi.sale_price as retail_price,
    coalesce(it.cost, p.cost) as cogs,
    round(oi.sale_price-coalesce(it.cost, p.cost),2)  as gross_profit,
    case when oi.status  in ('returned', 'cancelled') then 0 else oi.sale_price end as net_revenue,
    
    case when oi.status = 'returned' then 1 else 0 end as is_returned,
    case when oi.status = 'cancelled' then 1 else 0 end as is_cancelled,
    case when oi.status = 'complete' then 1 else 0 end as is_fulfilled,

    case
        when dense_rank()over(partition by oi.user_id order by oi.created_at asc, oi.order_id) = 1 then 'New Customer'
        else 'Repeat Customer'
    end as user_purchase_type,

    oi.order_id,
    oi.user_id,
    oi.product_id,
    oi.inventory_item_id,
    p.distribution_center_id

    from order_items oi
    left join products p on oi.product_id = p.id
    left join inventory_items it on oi.inventory_item_id = it.id