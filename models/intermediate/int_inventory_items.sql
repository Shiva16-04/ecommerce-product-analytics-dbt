with inventory_items as (
    select * from {{ ref('stg_thelook_inventory_items') }}
),
products as (
    select * from {{ ref('stg_thelook_products') }}
)
select
    ii.id as inventory_item_id,
    ii.product_id,
    p.distribution_center_id,

    ii.created_at as stock_in_at,
    ii.sold_at,

    case when ii.sold_at is not null then 1 else 0 end as is_sold,

    ii.cost as unit_cost,
    p.retail_price as unit_retail_price,
    round(safe_divide(p.retail_price - ii.cost, ii.cost) * 100 , 2) as max_breakeven_disc_pct,



    case 
        when ii.sold_at is null then date_diff(current_date(), date(ii.created_at), day) 
        else date_diff(ii.sold_at, ii.created_at, day)
    end as inventory_age_days,

    case 
        when ii.sold_at is not null then 'sold'
        when date_diff(current_date(), date(ii.created_at), day) <= 60 then 'fast moving/active'
        when date_diff(current_date(), date(ii.created_at), day) <= 90 then 'normal/moderate'
        when date_diff(current_date(), date(ii.created_at), day) <= 180 then 'slow_moving'
        when date_diff(current_date(), date(ii.created_at), day) <= 270 then 'aged stock - tier 1'
        when date_diff(current_date(), date(ii.created_at), day) <= 270 then 'aged stock - tier 2'
        when date_diff(current_date(), date(ii.created_at), day) <= 360 then 'aged stock - tier 2'
        else '365+ days (dead stock / LTSF)'
    end as inventory_aging_tier,
    case 
        when ii.sold_at is not null then 0
        when date_diff(current_date(), date(ii.created_at), day) <= 60 then 1
        when date_diff(current_date(), date(ii.created_at), day) <= 90 then 2
        when date_diff(current_date(), date(ii.created_at), day) <= 180 then 3
        when date_diff(current_date(), date(ii.created_at), day) <= 270 then 4
        when date_diff(current_date(), date(ii.created_at), day) <= 270 then 5
        when date_diff(current_date(), date(ii.created_at), day) <= 360 then 6
        else 7
    end as inventory_aging_tier_sort_order

    from inventory_items ii
    left join products p on ii.product_id = p.id
