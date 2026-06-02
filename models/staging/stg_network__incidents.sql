with

source as (

    select * 
    from {{ source('network', 'network_incidents') }}

),

renamed as (

    select inc_id as incident_id,
    cast(reported_at as timestamp) as reported_at,
    cast(resolved_at as timestamp) as resolved_at,
    type as incident_type,
    region,
    severity,
    customer_ref as customer_id
    from source

)

select * from renamed
