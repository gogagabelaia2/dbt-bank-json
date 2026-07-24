with fees as (
    select channel, fee_type, fee_amount
    from {{ ref('stg_transaction_fees') }}
),

agg as (
    select
        channel,
        fee_type,
        count(*)                  as n_fees,
        sum(fee_amount)           as total_fee_income,
        round(avg(fee_amount), 2) as avg_fee
    from fees
    group by 1, 2
)

select * from agg