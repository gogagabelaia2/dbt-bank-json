with accounts as(
    select 
        account_id,
        customer_id,
        account_type,
        currency,
        balance,
        is_active
    from {{ref('stg_customer_accounts')}}
),
txn_agg as(
    select 
        account_id,
        count(*) as n_transactions,
        sum(amount_value) as total_amount,
        min(transaction_date) as first_transaction_date,
        max(transaction_date) as last_transaction_date
    from {{ref('stg_transactions')}}
    group by 1
),
final as (
    select 
        a.*,
        coalesce(t.n_transactions,0) as n_transactions,
        coalesce(t.total_amount,0) as total_amount,
        t.first_transaction_date,
        t.last_transaction_date
    from accounts a
    left join txn_agg t using (account_id)

)
select * from final