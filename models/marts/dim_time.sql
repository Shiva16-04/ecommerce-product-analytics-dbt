with time_range as (
    select hours_24 
    from unnest(generate_array(0,23))as hours_24
)
select
    hours_24 as time_key,

    case
        when hours_24 = 0 then '12 AM'
        when hours_24 < 12 then concat(cast(hours_24 as string), ' AM')
        when hours_24 = 0 then '12 PM'
        when hours_24 < 24 then concat(cast(hours_24 as string), ' PM')
    end as hours_12_label,

    case
        when hours_24 between 0 and 5 then 'Late Night'
        when hours_24 between 6 and 11 then 'Morning'
        when hours_24 between 12 and 15 then 'Afternoon'    
        when hours_24 between 16 and 19 then 'Evening'
        else 'Night'
    end as part_of_day,

    case
        when hours_24 between 0 and 5 then 1
        when hours_24 between 6 and 11 then 2
        when hours_24 between 12 and 15 then 3    
        when hours_24 between 16 and 19 then 4
        else 5
    end as part_of_day_sort_order,

    case 
        when hours_24 between 18 and 23 then 1 
        else 0
    end as is_prime_time
from time_range
