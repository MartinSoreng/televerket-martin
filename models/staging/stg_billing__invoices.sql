with

source as (

    select * from {{ source('billing', 'billing_invoices') }}

),

renamed as (

    select * from source

)

select * from renamed
