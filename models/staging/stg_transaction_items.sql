with source as (    
    select * from {{source('bank_json','raw_transactions_json')}}
),
renamed as(
    select 
        t.v:transaction_id::string as transaction_id,
        t.v:customer_id::string as customer_id,
        t.v:timestamp::date as transaction_date,
        i.index as item_seq,
        t.v:merchant:name::string as merchant_name,
        t.v:merchant:category::string as merchant_category,
        i.value:item_id::string as item_id,
        i.value:qty::int as quantity,
        i.value:unit_price::number(12,2) as unit_price,
        i.value:description::string as description,
        (i.value:qty::int * i.value:unit_price::number(12,2)) as line_total

    from source t,
    lateral flatten(input=> t.v:items) i
)
select * from renamed