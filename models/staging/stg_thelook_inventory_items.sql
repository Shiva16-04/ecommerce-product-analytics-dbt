with source as (
    select * from {{source('thelook_raw', 'inventory_items')}}
),
cleaned_inventory_items as (
    select
    id,
    product_id,
    timestamp_trunc(created_at, second) as created_at,
    timestamp_trunc(sold_at, second) as sold_at,
    round(cost, 2) as cost,
    product_distribution_center_id as distribution_center_id
    from source
    where id is not null and id>0
    qualify row_number() over(partition by id order by created_at desc) = 1
) select * from cleaned_inventory_items