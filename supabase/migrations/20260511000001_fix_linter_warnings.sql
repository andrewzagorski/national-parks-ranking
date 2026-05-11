-- ============================================================
--  Migration: fix_linter_warnings
--  Addresses all errors, warnings, and info notices from the
--  Supabase database linter after initial schema creation.
-- ============================================================


-- ------------------------------------------------------------
-- 1. SECURITY DEFINER VIEW (ERROR)
--    Supabase creates views as SECURITY DEFINER by default,
--    meaning the view runs with the creator's permissions
--    rather than the querying user's. This bypasses RLS.
--    Fix: recreate the view with SECURITY INVOKER so RLS
--    is enforced normally.
-- ------------------------------------------------------------

DROP VIEW IF EXISTS public.aggregate_scores;

CREATE VIEW public.aggregate_scores
    WITH (security_invoker = true)
AS
SELECT
    p.id                        AS park_id,
    p.name                      AS park_name,
    p.slug                      AS park_slug,
    COUNT(DISTINCT sub.user_id) AS rater_count,
    ROUND(
        AVG(sub.user_weighted_score)::NUMERIC,
    1)                          AS aggregate_score
FROM parks p
JOIN (
    SELECT
        r.park_id,
        r.user_id,
        SUM( ((r.score - 1) / 4.0) * m.default_weight ) AS user_weighted_score
    FROM ratings r
    JOIN metrics m ON m.id = r.metric_id
    GROUP BY r.park_id, r.user_id
) sub ON sub.park_id = p.id
GROUP BY p.id, p.name, p.slug
ORDER BY aggregate_score DESC;


-- ------------------------------------------------------------
-- 2. GRAPHQL EXPOSURE (WARN)
--    We are not using GraphQL — our Vue app talks directly to
--    the REST API. Revoke SELECT from anon and authenticated
--    on all tables and the view to remove them from the
--    GraphQL schema entirely.
-- ------------------------------------------------------------

REVOKE SELECT ON public.users        FROM anon, authenticated;
REVOKE SELECT ON public.ratings      FROM anon, authenticated;
REVOKE SELECT ON public.user_weights FROM anon, authenticated;
REVOKE SELECT ON public.visits       FROM anon, authenticated;
REVOKE SELECT ON public.parks        FROM anon, authenticated;
REVOKE SELECT ON public.metrics      FROM anon, authenticated;
REVOKE SELECT ON public.aggregate_scores FROM anon, authenticated;

-- Re-grant only what the app actually needs via the REST API.
-- Parks and metrics are public lookup tables.
-- Aggregate scores are public for the leaderboard.
-- All other access is controlled by RLS using the user UUID.
GRANT SELECT ON public.parks             TO anon, authenticated;
GRANT SELECT ON public.metrics           TO anon, authenticated;
GRANT SELECT ON public.aggregate_scores  TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.users        TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.ratings      TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_weights TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.visits       TO authenticated;


-- ------------------------------------------------------------
-- 3. RLS INIT PLAN PERFORMANCE (WARN)
--    current_setting() in RLS policies was being re-evaluated
--    for every row scanned. Wrapping in (SELECT ...) causes
--    Postgres to evaluate it once per query instead.
--    Recreate all affected policies.
-- ------------------------------------------------------------

-- USERS
DROP POLICY "users: read own"   ON public.users;
DROP POLICY "users: insert own" ON public.users;
DROP POLICY "users: update own" ON public.users;

CREATE POLICY "users: read own"   ON public.users
    FOR SELECT USING (id = (SELECT current_setting('app.user_id', true))::UUID);
CREATE POLICY "users: insert own" ON public.users
    FOR INSERT WITH CHECK (id = (SELECT current_setting('app.user_id', true))::UUID);
CREATE POLICY "users: update own" ON public.users
    FOR UPDATE USING (id = (SELECT current_setting('app.user_id', true))::UUID);

-- RATINGS
DROP POLICY "ratings: read own"   ON public.ratings;
DROP POLICY "ratings: insert own" ON public.ratings;
DROP POLICY "ratings: update own" ON public.ratings;
DROP POLICY "ratings: delete own" ON public.ratings;

CREATE POLICY "ratings: read own"   ON public.ratings
    FOR SELECT USING (user_id = (SELECT current_setting('app.user_id', true))::UUID);
CREATE POLICY "ratings: insert own" ON public.ratings
    FOR INSERT WITH CHECK (user_id = (SELECT current_setting('app.user_id', true))::UUID);
CREATE POLICY "ratings: update own" ON public.ratings
    FOR UPDATE USING (user_id = (SELECT current_setting('app.user_id', true))::UUID);
CREATE POLICY "ratings: delete own" ON public.ratings
    FOR DELETE USING (user_id = (SELECT current_setting('app.user_id', true))::UUID);

-- USER_WEIGHTS
DROP POLICY "weights: read own"   ON public.user_weights;
DROP POLICY "weights: insert own" ON public.user_weights;
DROP POLICY "weights: update own" ON public.user_weights;
DROP POLICY "weights: delete own" ON public.user_weights;

CREATE POLICY "weights: read own"   ON public.user_weights
    FOR SELECT USING (user_id = (SELECT current_setting('app.user_id', true))::UUID);
CREATE POLICY "weights: insert own" ON public.user_weights
    FOR INSERT WITH CHECK (user_id = (SELECT current_setting('app.user_id', true))::UUID);
CREATE POLICY "weights: update own" ON public.user_weights
    FOR UPDATE USING (user_id = (SELECT current_setting('app.user_id', true))::UUID);
CREATE POLICY "weights: delete own" ON public.user_weights
    FOR DELETE USING (user_id = (SELECT current_setting('app.user_id', true))::UUID);

-- VISITS
DROP POLICY "visits: read own"   ON public.visits;
DROP POLICY "visits: insert own" ON public.visits;
DROP POLICY "visits: update own" ON public.visits;
DROP POLICY "visits: delete own" ON public.visits;

CREATE POLICY "visits: read own"   ON public.visits
    FOR SELECT USING (user_id = (SELECT current_setting('app.user_id', true))::UUID);
CREATE POLICY "visits: insert own" ON public.visits
    FOR INSERT WITH CHECK (user_id = (SELECT current_setting('app.user_id', true))::UUID);
CREATE POLICY "visits: update own" ON public.visits
    FOR UPDATE USING (user_id = (SELECT current_setting('app.user_id', true))::UUID);
CREATE POLICY "visits: delete own" ON public.visits
    FOR DELETE USING (user_id = (SELECT current_setting('app.user_id', true))::UUID);


-- ------------------------------------------------------------
-- 4. UNINDEXED FOREIGN KEYS (INFO)
--    The linter found FK columns without a covering index.
--    Add the missing ones. (user_id indexes already exist
--    from the initial migration; these cover metric_id and
--    park_id FKs on the smaller tables.)
-- ------------------------------------------------------------

-- ratings_metric_id_fkey — metric_id on ratings
-- (park_id and user_id already indexed in migration 1)
CREATE INDEX IF NOT EXISTS idx_ratings_metric
    ON public.ratings(metric_id);

-- user_weights_metric_id_fkey
CREATE INDEX IF NOT EXISTS idx_user_weights_metric
    ON public.user_weights(metric_id);

-- visits_park_id_fkey
CREATE INDEX IF NOT EXISTS idx_visits_park
    ON public.visits(park_id);