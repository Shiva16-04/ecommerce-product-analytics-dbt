With source as (
    select * from {{source('thelook_raw', 'users')}}
),
cleaned_users as (
    select 
    id,
    nullif(initcap(trim(array_to_string([first_name, last_name],' '))),'') as full_name,
    lower(trim(email)) as email,
    case    
        when age between 18 and 115 then age else null
    end as age,
    case 
        when lower(trim(gender)) in ('m', 'male') then 'Male'
        when lower(trim(gender)) in ('f', 'female') then 'Female'
        else 'Other/Undisclosed'
    end as gender, 
    initcap(trim(city)) as city,
    initcap(trim(state)) as state,
    initcap(trim(country)) as country,
    case 
        when latitude BETWEEN -90.0 and 90.0 and NOT(latitude = 0.0 and longitude = 0.0) then Round(latitude, 4)
        else null
    end as latitude, 
    case
        when longitude BETWEEN -180.0 and 180.0 and NOT (latitude = 0.0 and longitude = 0.0) then ROund(longitude, 4)
    end as longitude,
    timestamp_trunc(created_at, SECOND) as signed_up_at,
    traffic_source
    from source
    where id is not NULL and created_at between TIMESTAMP_SUB(current_timestamp(), Interval 1825 DAY) and current_timestamp()
    qualify row_number() over(partition by id order by created_at desc) = 1
)
select * from cleaned_users