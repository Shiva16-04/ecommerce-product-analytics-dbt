with source as (
    select * from {{source('thelook_raw', 'products')}}
),
cleaned_products as (
    select
    id,
    coalesce(initcap(trim(name)), 'Unknown Product') as name,
    coalesce(initcap(trim(brand)), 'Generic') as brand,
    coalesce(initcap(trim(category)), 'Uncategorized') as category,
    coalesce(initcap(trim(department)), 'Unassigned') as department,
    round(cost,2) as cost,
    round(retail_price,2) as retail_price,
    trim(sku) as sku,
    distribution_center_id
    from source
    where id is not null and id > 0 
    qualify row_number() over(partition by id order by id) = 1
)
select * from cleaned_products 