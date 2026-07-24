with items as (
    select * from {{ ref('stg_transaction_items') }}
),

merchant_agg as (
    select
        merchant_name,
        merchant_category,
        count(distinct transaction_id)  as n_transactions,
        count(*)                        as n_items,
        sum(line_total)                 as total_spend,
        round(avg(unit_price), 2)       as avg_unit_price
    from items
    group by 1, 2
),

ranked as (
    select
        *,
        round(total_spend / nullif(n_transactions, 0), 2) as avg_basket_value,

        rank() over (partition by merchant_category
                     order by total_spend desc)           as rank_in_category,

        round(100.0 * total_spend
            / sum(total_spend) over (partition by merchant_category), 1)
                                                          as pct_of_category
    from merchant_agg
)

select * from ranked
order by merchant_category, rank_in_category