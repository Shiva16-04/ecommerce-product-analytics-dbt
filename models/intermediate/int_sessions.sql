with events as (
    select * from {{ ref('stg_thelook_events') }}
),
session_aggregates as (
    select 
    session_id,
    user_id,
    traffic_source,
    browser,
    Min(created_at) as session_start_at,
    Max(created_at) as session_end_at,
    count(1) as total_events,
    countif(event_type = 'purchase') as total_purchases
    from events
    group by session_id, user_id, traffic_source, browser
) 
select
    *,
    timestamp_diff(session_end_at, session_start_at, second) as session_duration_seconds,
    case when total_events = 1 then 1 else 0 end as is_bounced,
    case when total_purchases > 0 then 1 else 0 end as is_converted
    from session_aggregates 