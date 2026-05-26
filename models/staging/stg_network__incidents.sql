with

source as (

    select * 
    from {{ source('network', 'network_incidents') }}

),

renamed as (

    select * except (customer_ref),
    customer_ref as customer_id
    from source

)

select * from renamed
