with source as (
    select * from {{source('thelook_raw', 'distribution_centers')}}
),
cleaned_distribution_centers as (
    select
    id,
    coalesce(initcap(trim(name)), 'Default')as name,
    case
        when latitude between -90.0 and 90.0 and not(latitude = 0 and longitude = 0) then round(latitude, 4)
        else null
    end as latitude,
    case
        when longitude between -180.0 and 180.0 and not(latitude = 0 and longitude = 0) then round(longitude, 4)
        else null
    end as longitude,
    from source
    where id is not null and id > 0
    qualify row_number() over(partition by id order by id desc) = 1
)
select * from cleaned_distribution_centers