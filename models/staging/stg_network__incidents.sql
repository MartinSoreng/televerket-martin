with

source as (

    select * from {{ source('network', 'network_incidents') }}

),

renamed as (

    select * from source

)

select * from renamed
