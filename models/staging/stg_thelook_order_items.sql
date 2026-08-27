with source as (
    select * from {{source('thelook_raw', 'order_items')}}
),
cleaned_order_items as (
    select
    id,
    order_id,
    user_id,
    product_id,
    inventory_item_id,
    lower(trim(status)) as status,
    timestamp_trunc(created_at, second) as created_at,
    timestamp_trunc(shipped_at, second) as shipped_at,
    timestamp_trunc(delivered_at, second) as delivered_at,
    timestamp_trunc(returned_at, second) as returned_at,
    round(sale_price, 2) as sale_price
    from source
    where id is not null and id > 0 and created_at between timestamp_sub(current_timestamp(), Interval 1825 day) and current_timestamp()
    qualify row_number() over(partition by id order by created_at desc) = 1
)
select * from cleaned_order_items