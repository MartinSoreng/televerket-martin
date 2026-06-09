select
    {{ dbt_utils.star(
        from=ref('int_customers__enriched'),
        except=['_loaded_at']
    ) }}
from {{ ref('int_customers__enriched') }}