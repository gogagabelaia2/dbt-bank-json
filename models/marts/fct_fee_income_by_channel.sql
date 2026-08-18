with fee_income as (
    select * from {{ ref('int_fee_income_by_channel') }}
),

ranked as (
    select
        channel,
        fee_type,
        n_fees,
        total_fee_income,
        avg_fee,
        round(100.0 * total_fee_income
            / sum(total_fee_income) over (partition by channel), 1)
                                                    as pct_of_channel,
        rank() over (partition by channel
                     order by total_fee_income desc) as rank_in_channel,
        rank() over (order by total_fee_income desc) as overall_rank
    from fee_income
)

select * from ranked
order by channel, rank_in_channel