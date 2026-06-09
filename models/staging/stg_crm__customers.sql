with

source as (

    select * from {{ source('crm', 'crm_customers') }}

),

renamed as (

    select 
        custID as customer_id,	
        full_name as customer_name,	
        email,	
        phone,	
        status as customer_status,	
        preferences as customer_preferences,	
        cast(created_at as date) as customer_created_at,
        json_value(address, '$.street') as address_street,
        json_value(address, '$.city') as address_city,
        json_value(address, '$.zip') as address_zip,
        json_value(address, '$.country') as address_country
    from source

)

select * from renamed
