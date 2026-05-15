-- Coalesce to 0 for parks with no ratings
CREATE OR REPLACE VIEW public.aggregate_scores AS
SELECT
    p.id                        AS park_id,
    p.name                      AS park_name,
    p.slug                      AS park_slug,
    COUNT(DISTINCT sub.user_id) AS rater_count,
    COALESCE(ROUND(
        AVG(sub.user_weighted_score)::NUMERIC,
    1), 0)                          AS aggregate_score
FROM parks p
LEFT JOIN (
    SELECT
        r.park_id,
        r.user_id,
        SUM( ((r.score - 1) / 4.0) * m.default_weight ) AS user_weighted_score
    FROM   ratings r
    JOIN   metrics m ON m.id = r.metric_id
    GROUP  BY r.park_id, r.user_id
) sub ON sub.park_id = p.id
GROUP  BY p.id, p.name, p.slug
ORDER  BY aggregate_score DESC;

GRANT SELECT ON aggregate_scores TO anon;

-- Rename for clarity as only one visit per user per park is stored
ALTER TABLE public.visits RENAME TO user_park_ratings;
ALTER TABLE public.user_park_ratings RENAME visited_on TO last_visit_date;
ALTER INDEX idx_visits_user RENAME TO idx_user_park_ratings_user;
ALTER INDEX idx_visits_park RENAME TO idx_user_park_ratings_park;
ALTER POLICY "visits: read own" ON public.user_park_ratings RENAME TO "user_park_ratings: read own";
ALTER POLICY "visits: insert own" ON public.user_park_ratings RENAME TO "user_park_ratings: insert own";
ALTER POLICY "visits: update own" ON public.user_park_ratings RENAME TO "user_park_ratings: update own";
ALTER POLICY "visits: delete own" ON public.user_park_ratings RENAME TO "user_park_ratings: delete own";

-- Add theme column to user table
ALTER TABLE public.users ADD COLUMN theme TEXT DEFAULT NULL;