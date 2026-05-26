with

customers as (

    select * from {{ ref('stg_crm__customers') }}

),

contracts as (

    select * from {{ ref('stg_crm__contracts') }}

),

-- Rank contracts per customer by start_date descending so rn = 1 is the latest
contracts_ranked as (

    select
        *,
        row_number() over (
            partition by customer_id
            order by start_date desc
        ) as rn
    from contracts

),

latest_contract as (

    select * from contracts_ranked where rn = 1

),

joined as (

    select
        -- All customer fields
        customers.customer_id,
        customers.customer_name,
        customers.email,
        customers.phone,
        customers.customer_status,
        customers.customer_created_at,
        customers.address_street,
        customers.address_city,
        customers.address_zip,
        customers.address_countr,

        -- Preferences unpacked from JSON (null when not set)
        json_value(customers.customer_preferences, '$.language')               as preferred_language,
        cast(json_value(customers.customer_preferences, '$.paperless') as bool) as paperless_billing,
        cast(json_value(customers.customer_preferences, '$.marketing_opt_in') as bool) as marketing_opt_in,

        -- Latest contract fields — null for customers with no contract (e.g. C017)
        latest_contract.contract_id,
        latest_contract.status                                as contract_status,
        latest_contract.start_date                           as contract_start_date,
        latest_contract.end_date                             as contract_end_date,
        safe_cast(latest_contract.monthly_fee as numeric)   as monthly_fee_eur

    from customers
    left join latest_contract
        on customers.customer_id = latest_contract.customer_id

)

select * from joined
