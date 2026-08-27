With date_range as (
    select calendar_date 
    from unnest(generate_date_array(date_sub(current_date(), interval 1825 day), current_date(), interval 1 day)) as calendar_date
)
select 
    calendar_date as date_key,

    Extract(Year from calendar_date) as year,

    Extract(quarter from calendar_date) as quarter_num,
    concat('Q', cast(Extract(quarter from calendar_date) as string)) as quarter_label,


    Extract(Month from calendar_date) as month_num,
    format_date('%B', calendar_date) as month_name,
    format_date('%b', calendar_date) as month_name_short,
    format_date('%y-%b', calendar_date) as year_month,
    cast(format_date('%Y%m', calendar_date) as int64) as year_month_sort_key,

    Extract(day from calendar_date) as day_of_month,
    EXtract(dayofweek from calendar_date) as day_of_week_num,
    format_date('%A', calendar_date) as day_of_week_name,
    format_date('%a', calendar_date) as day_of_week_name_short,

    case
        when EXtract(dayofweek from calendar_date) in (1,7) then 1 
        else 0
    end as is_weekend,
    -- case
    --     when calendar_date = current_date() then 1 
    --     else 0
    -- end as is_today

from date_range