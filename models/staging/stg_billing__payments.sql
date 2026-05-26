with

source as (

    select * from {{ source('billing', 'billing_payments') }}

),

payments_deduped as (
    select  
    source.payment_id,	
    source.invoice_ref as invoice_id,	
    cast(source.paid_on as date) as payment_paid_on,	
    cast(source.amount as numeric) as payment_amount_eur,	
    source.method as payment_method,
    row_number() over (
        partition by source.invoice_ref
        order by source.payment_id asc
 ) as rn
from source
)
select * except(rn) from payments_deduped
where rn = 1