with

source as (

    select * from {{ source('crm', 'crm_contracts') }}

),

renamed as (

    select 
        contract_id as contract_id,
        cust_id as customer_id,
        product_code
        status,
        parse_date('%Y-%m-%d', start_date) as start_date,
        parse_date('%Y-%m-%d', end_date) as end_date,
        monthly_fee
    from source
    
)

select * from renamed
