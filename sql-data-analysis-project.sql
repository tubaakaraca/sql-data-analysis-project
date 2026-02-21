WITH fb_month AS (
    SELECT
        fc.campaign_name,
        DATE_TRUNC('month', fbd.ad_date) AS ad_month,
        SUM(fbd.reach) AS monthly_reach
    FROM facebook_ads_basic_daily fbd
    LEFT JOIN facebook_campaign fc
        ON fbd.campaign_id = fc.campaign_id
    GROUP BY fc.campaign_name, DATE_TRUNC('month', fbd.ad_date)
),
ga_month AS (
    SELECT
        campaign_name,
        DATE_TRUNC('month', ad_date) AS ad_month,
        SUM(reach) AS monthly_reach
    FROM google_ads_basic_daily
    GROUP BY campaign_name, DATE_TRUNC('month', ad_date)
),
combined AS (
    SELECT * FROM fb_month
    UNION ALL
    SELECT * FROM ga_month
),
monthly_totals AS (
    SELECT
        campaign_name,
        ad_month,
        SUM(monthly_reach) AS monthly_reach
    FROM combined
    GROUP BY campaign_name, ad_month
),
growth AS (
    SELECT
        campaign_name,
        ad_month,
        monthly_reach,
        monthly_reach 
            - LAG(monthly_reach) OVER (PARTITION BY campaign_name ORDER BY ad_month)
            AS monthly_growth
    FROM monthly_totals
)
SELECT *
FROM growth
WHERE monthly_growth IS NOT NULL
ORDER BY monthly_growth DESC
LIMIT 1;