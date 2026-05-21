with

source as (

    select * from {{ source('network', 'network_service_activations') }}

),

renamed as (

    select * from source

)

select * from renamed
