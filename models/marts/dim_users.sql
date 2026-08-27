with users as (
    select * from {{ ref('stg_thelook_users') }}
),

user_orders as (
    select
        user_id,
        min(created_at) as first_order_at,
        max(created_at) as last_order_at,
        count(distinct order_id) as lifetime_orders_count,
        sum(retail_price) as lifetime_gross_spend,
        sum(net_revenue) as lifetime_net_spend,
        sum(gross_profit) as lifetime_gross_profit,
        sum(is_cancelled) as lifetime_cancelled_items,
        sum(is_returned) as lifetime_returned_items
    from {{ ref('int_order_items') }}
    group by user_id
)

select
    
    u.id as user_id,

    u.full_name,
    u.email,
    u.age,
    u.gender,
    case 
        when u.age < 18 then 'Under 18'
        when u.age between 18 and 24 then '18-24'
        when u.age between 25 and 34 then '25-34'
        when u.age between 35 and 44 then '35-44'
        when u.age between 45 and 54 then '45-54'
        when u.age between 55 and 64 then '55-64'
        else '65+'
    end as age_group,

    
    u.country,
    u.state,
    u.city,
    u.latitude,
    u.longitude,

    
    u.traffic_source,
    u.signed_up_at,
    date(u.signed_up_at) as signed_up_date_key,
    extract(hour from u.signed_up_at) as signed_up_time_key,
    
    uo.first_order_at,
    uo.last_order_at,
    date(uo.first_order_at) as first_order_date_key,
    date(uo.last_order_at) as last_order_date_key,
    coalesce(uo.lifetime_orders_count, 0) as lifetime_orders_count,
    coalesce(uo.lifetime_net_spend, 0.0) as lifetime_net_spend,
    coalesce(uo.lifetime_gross_profit, 0.0) as lifetime_gross_profit,

    --Recency
    date_diff(current_date(), date(uo.last_order_at), day) as days_since_last_order,

    --Segmentation Flags
    case when coalesce(uo.lifetime_orders_count, 0) > 0 then 1 else 0 end as is_paying_customer,
    case when coalesce(uo.lifetime_orders_count, 0) > 1 then 1 else 0 end as is_repeat_customer,
    case 
        when coalesce(uo.lifetime_orders_count, 0) = 0 then 'Non Purchaser'
        when coalesce(uo.lifetime_orders_count, 0) = 1 then 'One Time Buyer'
        when coalesce(uo.lifetime_orders_count, 0) between 2 and 4 then 'Repeat Buyer'
        else 'VIP/Frequent Buyer'
    end as customer_segment

from users u
left join user_orders uo 
    on u.id = uo.user_id