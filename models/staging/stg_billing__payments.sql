with

source as (

    select * from {{ source('billing', 'billing_payments') }}

),

renamed as (

    select * from source

)

select * from renamed
