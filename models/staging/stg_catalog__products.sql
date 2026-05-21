with

source as (

    select * from {{ source('catalog', 'catalog_products') }}

),

renamed as (

    select * from source

)

select * from renamed
