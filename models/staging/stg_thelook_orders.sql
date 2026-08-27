With source as (
    select * from {{source('thelook_raw','orders')}}
),
cleaned_orders as (
    select
        order_id,
        user_id,
        lower(trim(status)) as status,
        coalesce(num_of_item, 0) as num_of_items,
        timestamp_trunc(created_at, SECOND) as created_at,
        timestamp_trunc(shipped_at, SECOND) as shipped_at,
        timestamp_trunc(delivered_at, SECOND) as delivered_at,
        timestamp_trunc(returned_at, SECOND) as returned_at,
    from source
    where order_id is not null and created_at between timestamp_sub(current_timestamp(), interval 1825 day) and current_timestamp() 
    qualify row_number() over(partition by order_id order by created_at desc) = 1
) 
select * from cleaned_orders