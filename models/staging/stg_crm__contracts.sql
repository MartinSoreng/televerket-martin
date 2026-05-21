with

source as (

    select * from {{ source('crm', 'crm_contracts') }}

),

renamed as (

    select * from source

)

select * from renamed
