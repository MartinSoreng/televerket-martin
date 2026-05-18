with casts as (
select 
	CustId as customer_id,
	full_name,
	email,
	phone,
	status,
	created_at::date as created_at,
	address::JSON ->> 'street' as street,
	address::JSON ->> 'city' as city,
	address::JSON ->> 'zip' as zip_code,
	address::JSON ->> 'country' as country_code,
	(preferences::JSON ->> 'paperless')::bool as use_paperless,
	preferences::JSON ->> 'language' as language,
	(preferences::JSON ->> 'marketing_opt_in')::bool as is_marketing_enabled

from {{ source("crm", "customers") }}
)
select
	customer_id,
	full_name,
	email,
	phone,
	status,
	country_code,
	zip_code,
	city,
	street,
	language,
	use_paperless,
	is_marketing_enabled
from casts
