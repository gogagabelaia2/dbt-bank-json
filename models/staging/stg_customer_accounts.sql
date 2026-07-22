with source as (
    select * from {{ source('bank_json', 'raw_customers_json') }}
),

renamed as (
    select
        c.v:customer_id::string                      as customer_id,
        (c.v:personal_info:first_name::string || ' '
         || c.v:personal_info:last_name::string)     as full_name,
        c.v:personal_info:birth_year::int            as birth_year,
        c.v:personal_info:city::string               as city,
        c.v:segment::string                          as segment,
        c.v:branch_id::string                        as branch_id,
        c.v:kyc:status::string                       as kyc_status,
        c.v:kyc:last_updated::date                   as kyc_last_updated,
        a.value:account_id::string                   as account_id,
        a.value:account_type::string                 as account_type,
        a.value:currency::string                     as currency,
        a.value:balance::number(12,2)                as balance,
        a.value:is_active::boolean                   as is_active,
        a.value:opened_date::date                    as opened_date
    from source c,
    lateral flatten(input => c.v:accounts) a
)

select * from renamed