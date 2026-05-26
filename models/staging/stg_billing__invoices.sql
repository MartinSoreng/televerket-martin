with

source as (

    select * from {{ source('billing', 'billing_invoices') }}

),

renamed as (

    select 
        InvoiceID as invoice_id,	
        customer_id,	
        parse_date('%Y%m%d', invoice_date) as invoice_date,	
        parse_date('%Y%m%d', due_date) as invoice_due_date,	
        cast(amount_eur as numeric) as invoice_amount_eur,	
        status as invoice_status
    from source

)

select * from renamed
