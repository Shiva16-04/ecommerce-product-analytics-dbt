with int_inventory_items as (
    select * from {{ ref('int_inventory_items') }}
)
select 
    inventory_item_id,

    product_id,
    distribution_center_id,

    stock_in_at,
    sold_at,
    date(stock_in_at) as stock_in_at_date_key,
    extract(hour from stock_in_at) as stock_in_at_time_key,
    date(sold_at) as sold_at_date_key,

    is_sold,

    unit_cost,
    unit_retail_price,
    max_breakeven_disc_pct,

    inventory_age_days,
    inventory_aging_tier,
    inventory_aging_tier_sort_order

    from int_inventory_items