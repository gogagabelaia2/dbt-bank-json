with source as (
    select * from {{source('bank_json','raw_transactions_json')}}
),
renamed as(
    select 
        t.v:transaction_id::string as transaction_id,
        t.v:customer_id::string as customer_id,
        t.v:timestamp::date as transaction_date,
        t.v:type::string as transaction_type,
        t.v:channel::string as channel,
        f.index as fee_seq,
        f.value:amount::number(12,2) as fee_amount,
        f.value:fee_type::string as fee_type
    from source t,
    lateral flatten(input=> t.v:fees) f

)
select * from renamed