with

source as (

    select * from {{ source('crm', 'crm_customers') }}

),

renamed as (

    select * from source

)

select * from renamed
