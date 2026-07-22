with source as(
    select * from {{source('bank_json','raw_transactions_json')}}
),
renamed as(
    select 
        v:transaction_id::string as transaction_id,
        v:account_id::string as account_id,
        v:customer_id::string as customer_id,
        v:timestamp::timestamp_ntz as transaction_tm,
        v:timestamp::date as transaction_date,
        v:type::string as transaction_type,
        v:channel::string as channel,
        v:amount:value::number(12,2) as amount_value,
        v:amount:currency::string as amount_currency,
        v:status::string as transaction_status,
        v:merchant:name::string as merchant_name,
        v:merchant:city::string as merchant_city,
        v:merchant:category::string as merchant_category
    from source
)
select * from renamed