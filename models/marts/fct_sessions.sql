with int_sessions as (
    select * from {{ ref('int_sessions') }}
) 
select
    session_id,
    user_id,
    date(session_start_at) as date_key,
    extract(hour from session_end_at) as time_key,
    traffic_source,
    browser,
    session_start_at,
    session_end_at,
    session_duration_seconds,
    round(safe_divide(session_duration_seconds, 60.0),2) as session_duration_minutes,
    total_purchases,
    is_bounced,
    is_converted
    from int_sessions
    
