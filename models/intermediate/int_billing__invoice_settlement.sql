with

invoices as (

    select * from {{ ref('stg_billing__invoices') }}

),

payments as (

    select * from {{ ref('stg_billing__payments') }}

),
joined_data as (
    select
        invoices.invoice_id,	
        invoices.customer_id,	
        invoices.invoice_date,	
        invoices.invoice_due_date,
        invoices.invoice_amount_eur,	
        invoices.invoice_status,
        payments.payment_id,	
        payments.payment_paid_on,	
        payments.payment_amount_eur,	
        payments.payment_method,
        if(payments.payment_id is not null, true, false) as is_paid
    from invoices
    left join payments
    on invoices.invoice_id = payments.invoice_id
)
select * from joined_data