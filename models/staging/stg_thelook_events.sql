with source as (
    select * from {{ source('thelook_raw', 'events') }}
),

cleaned_events as (
    select
        id ,
        user_id,
        trim(session_id) as session_id,
        sequence_number,
        lower(trim(event_type)) as event_type,
        trim(uri) as uri,
        coalesce(initcap(trim(traffic_source)), 'Unknown') as traffic_source,
        coalesce(initcap(trim(browser)), 'Unknown') as browser,
        ip_address,
        coalesce(trim(city), 'Unknown') as city,
        coalesce(trim(state), 'Unknown') as state,
        timestamp_trunc(created_at, second) as created_at,
        lag(created_at) over(partition by session_id order by sequence_number asc) as prev_created_at

    from source
    where id is not null 
      and id > 0
      and session_id is not null
      and created_at between timestamp_sub(current_timestamp(), interval 1825 day) 
                         and current_timestamp()
    qualify row_number() over (
        partition by id 
        order by created_at desc
    ) = 1
),
corrected_events as (
    select
    id,
    user_id,
    session_id,
    sequence_number,
    event_type,
    uri,
    traffic_source,
    browser,
    ip_address,
    city,
    state,
    created_at as original_created_at,
    case
        when event_type = 'purchase'
        and Date(created_at) != Date(prev_created_at) 
        and Time(created_at) >= Time(prev_created_at)
        and time_diff(Time(created_at), Time(prev_created_at), second) <= 1800
        then timestamp(datetime(Date(prev_created_at), Time(created_at)))
        else created_at
    end as created_at
    
    from cleaned_events
)

select
    id,
    user_id,
    session_id,
    sequence_number,event_type, uri,
    traffic_source, browser,ip_address,
    city, state, created_at 
 from corrected_events