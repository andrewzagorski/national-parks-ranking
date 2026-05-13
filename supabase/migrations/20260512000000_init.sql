-- ============================================================
--  Consolidated Migration: National Park Rankings
--  Replaces: 20260511000000 through 20260511000003
--
--  Identity & Auth Model
--  ─────────────────────
--  These are two separate concerns and must not be conflated.
--
--  Authentication → Supabase Anonymous Auth
--    Every visitor calls signInAnonymously() as the very first
--    step. This produces a signed JWT that PostgREST validates,
--    ensuring all requests arrive as the 'authenticated' role
--    rather than 'anon'. The anonymous auth UID is not stored
--    anywhere and is not meaningful to the application.
--
--  Identity → App UUID (bearer token)
--    A random UUID is the user's stable identity and effectively
--    their password. It is resolved client-side in priority order:
--      1. Cookie
--      2. localStorage
--      3. Browser fingerprint lookup (find_user_by_fingerprint)
--      4. Manual entry ("log in from another device")
--      5. Generate a new UUID (first-time visitor)
--    The resolved UUID is sent on every request as the custom
--    header x-app-user-id. The pre-request hook reads it and
--    writes it to app.user_id. All RLS policies check that
--    setting — never auth.uid().
--
--  Security posture: the UUID is a 128-bit random secret. Anyone
--  who knows it can read and write that user's data, the same
--  threat model as a bearer token or session cookie. This is
--  acceptable for public park ratings with no sensitive PII.
-- ============================================================


-- ============================================================
-- SECTION 1: TABLES
-- ============================================================

CREATE TABLE parks (
    id          SERIAL       PRIMARY KEY,
    name        TEXT         NOT NULL UNIQUE,
    slug        TEXT         NOT NULL UNIQUE,
    states      TEXT,                        -- 'CA' or 'TN, NC'; filter with LIKE '%TN%'
    nps_region  TEXT         CHECK (nps_region IN (
                                 'Alaska',
                                 'Intermountain',
                                 'Midwest',
                                 'National Capital',
                                 'Northeast',
                                 'Pacific West',
                                 'Southeast'
                             )),
    established SMALLINT,                    -- year designated as a national park
    area_acres  NUMERIC(12,2)
);

CREATE TABLE metrics (
    id             SERIAL  PRIMARY KEY,
    key            TEXT    NOT NULL UNIQUE,
    label          TEXT    NOT NULL,
    default_weight NUMERIC NOT NULL CHECK (default_weight >= 0),
    sort_order     INT     NOT NULL
);

-- The users table is keyed on the app UUID, not Supabase's auth.uid().
-- A row is upserted here on every session start (last_seen update)
-- and whenever the fingerprint is first computed or changes.
CREATE TABLE users (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    fingerprint TEXT,                        -- SHA-256 hash of FingerprintJS visitorId
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_seen   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE ratings (
    id        BIGSERIAL   PRIMARY KEY,
    user_id   UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    park_id   INT         NOT NULL REFERENCES parks(id) ON DELETE CASCADE,
    metric_id INT         NOT NULL REFERENCES metrics(id) ON DELETE CASCADE,
    score     SMALLINT    NOT NULL CHECK (score BETWEEN 1 AND 5),
    rated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

    UNIQUE (user_id, park_id, metric_id)
);

CREATE TABLE user_weights (
    id        BIGSERIAL PRIMARY KEY,
    user_id   UUID    NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    metric_id INT     NOT NULL REFERENCES metrics(id) ON DELETE CASCADE,
    weight    NUMERIC NOT NULL CHECK (weight >= 0),

    UNIQUE (user_id, metric_id)
);

CREATE TABLE visits (
    id         BIGSERIAL   PRIMARY KEY,
    user_id    UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    park_id    INT         NOT NULL REFERENCES parks(id) ON DELETE CASCADE,
    visited_on DATE,
    notes      TEXT,

    UNIQUE (user_id, park_id)
);


-- ============================================================
-- SECTION 2: INDEXES
-- ============================================================

CREATE INDEX idx_parks_region ON parks(nps_region);
CREATE INDEX idx_parks_states ON parks(states);

CREATE INDEX idx_ratings_user        ON ratings(user_id);
CREATE INDEX idx_ratings_park        ON ratings(park_id);
CREATE INDEX idx_ratings_metric      ON ratings(metric_id);
CREATE INDEX idx_ratings_park_metric ON ratings(park_id, metric_id);

CREATE INDEX idx_user_weights_user   ON user_weights(user_id);
CREATE INDEX idx_user_weights_metric ON user_weights(metric_id);

CREATE INDEX idx_visits_user ON visits(user_id);
CREATE INDEX idx_visits_park ON visits(park_id);


-- ============================================================
-- SECTION 3: FUNCTIONS
-- ============================================================

-- ------------------------------------------------------------
-- set_app_user_id()
--   PostgREST pre-request hook. Called before every API request.
--   Reads the x-app-user-id header and writes its value to the
--   app.user_id session variable. All RLS policies read this
--   variable. If the header is absent or unparseable, the setting
--   is left empty and RLS blocks all personalised data access.
--
--   Not SECURITY DEFINER — it doesn't touch any tables.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.set_app_user_id()
RETURNS void
LANGUAGE plpgsql
SET search_path = ''
AS $$
DECLARE
    v_headers json;
    v_user_id text;
BEGIN
    BEGIN
        v_headers := current_setting('request.headers', true)::json;
        v_user_id := v_headers->>'x-app-user-id';
    EXCEPTION WHEN OTHERS THEN
        v_user_id := NULL;
    END;

    PERFORM set_config('app.user_id', COALESCE(v_user_id, ''), true);
END;
$$;

GRANT EXECUTE ON FUNCTION public.set_app_user_id() TO anon, authenticated;

-- Register as the PostgREST pre-request hook.
-- In Supabase you may also need to set this in the dashboard:
--   API → DB Pre-request Function → public.set_app_user_id
ALTER ROLE authenticator SET pgrst.db_pre_request TO 'public.set_app_user_id';


-- ------------------------------------------------------------
-- find_user_by_fingerprint(p_fingerprint)
--   Returns the app UUID for a given SHA-256 fingerprint hash,
--   or NULL if not found. Called during the client-side identity
--   resolution flow when cookie and localStorage are both missing.
--
--   SECURITY DEFINER: must bypass RLS to read the users table
--   before app.user_id is established. Safe because the caller
--   must already know the fingerprint hash, and the returned UUID
--   is only useful to someone who can send it as x-app-user-id.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.find_user_by_fingerprint(p_fingerprint TEXT)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_count INT;
    v_user_id UUID;
BEGIN
    SELECT count(*), min(id) INTO v_count, v_user_id
    FROM   users
    WHERE  fingerprint = p_fingerprint;

    IF v_count = 1 THEN
        RETURN v_user_id;
    END IF;

    RETURN NULL;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.find_user_by_fingerprint(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.find_user_by_fingerprint(TEXT) TO authenticated;


-- ============================================================
-- SECTION 4: ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE parks        ENABLE ROW LEVEL SECURITY;
ALTER TABLE metrics      ENABLE ROW LEVEL SECURITY;
ALTER TABLE users        ENABLE ROW LEVEL SECURITY;
ALTER TABLE ratings      ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_weights ENABLE ROW LEVEL SECURITY;
ALTER TABLE visits       ENABLE ROW LEVEL SECURITY;

-- Parks + metrics: public read; no writes via the REST API.
CREATE POLICY "parks: public read"   ON parks   FOR SELECT USING (true);
CREATE POLICY "metrics: public read" ON metrics FOR SELECT USING (true);

-- Convenience expression used in every user-data policy.
-- NULLIF converts an empty string (header absent) to NULL so that
-- the UUID cast doesn't error, and the comparison quietly returns
-- false, exposing no rows.

-- Users
CREATE POLICY "users: read own"   ON users
    FOR SELECT USING (
        id = (SELECT NULLIF((select current_setting('app.user_id', true)), '')::UUID)
    );
CREATE POLICY "users: insert own" ON users
    FOR INSERT WITH CHECK (
        id = (SELECT NULLIF((select current_setting('app.user_id', true)), '')::UUID)
    );
CREATE POLICY "users: update own" ON users
    FOR UPDATE USING (
        id = (SELECT NULLIF((select current_setting('app.user_id', true)), '')::UUID)
    );

-- Ratings
CREATE POLICY "ratings: read own" ON ratings
    FOR SELECT USING (
        user_id = (SELECT NULLIF((select current_setting('app.user_id', true)), '')::UUID)
    );
CREATE POLICY "ratings: insert own" ON ratings
    FOR INSERT WITH CHECK (
        user_id = (SELECT NULLIF((select current_setting('app.user_id', true)), '')::UUID)
    );
CREATE POLICY "ratings: update own" ON ratings
    FOR UPDATE USING (
        user_id = (SELECT NULLIF((select current_setting('app.user_id', true)), '')::UUID)
    );
CREATE POLICY "ratings: delete own" ON ratings
    FOR DELETE USING (
        user_id = (SELECT NULLIF((select current_setting('app.user_id', true)), '')::UUID)
    );

-- User weights
CREATE POLICY "weights: read own" ON user_weights
    FOR SELECT USING (
        user_id = (SELECT NULLIF((select current_setting('app.user_id', true)), '')::UUID)
    );
CREATE POLICY "weights: insert own" ON user_weights
    FOR INSERT WITH CHECK (
        user_id = (SELECT NULLIF((select current_setting('app.user_id', true)), '')::UUID)
    );
CREATE POLICY "weights: update own" ON user_weights
    FOR UPDATE USING (
        user_id = (SELECT NULLIF((select current_setting('app.user_id', true)), '')::UUID)
    );
CREATE POLICY "weights: delete own" ON user_weights
    FOR DELETE USING (
        user_id = (SELECT NULLIF((select current_setting('app.user_id', true)), '')::UUID)
    );

-- Visits
CREATE POLICY "visits: read own" ON visits
    FOR SELECT USING (
        user_id = (SELECT NULLIF((select current_setting('app.user_id', true)), '')::UUID)
    );
CREATE POLICY "visits: insert own" ON visits
    FOR INSERT WITH CHECK (
        user_id = (SELECT NULLIF((select current_setting('app.user_id', true)), '')::UUID)
    );
CREATE POLICY "visits: update own" ON visits
    FOR UPDATE USING (
        user_id = (SELECT NULLIF((select current_setting('app.user_id', true)), '')::UUID)
    );
CREATE POLICY "visits: delete own" ON visits
    FOR DELETE USING (
        user_id = (SELECT NULLIF((select current_setting('app.user_id', true)), '')::UUID)
    );


-- ============================================================
-- SECTION 5: GRANTS
-- ============================================================

-- Start from a clean slate on all app tables.
REVOKE ALL ON parks        FROM anon, authenticated;
REVOKE ALL ON metrics      FROM anon, authenticated;
REVOKE ALL ON users        FROM anon, authenticated;
REVOKE ALL ON ratings      FROM anon, authenticated;
REVOKE ALL ON user_weights FROM anon, authenticated;
REVOKE ALL ON visits       FROM anon, authenticated;

-- Parks and metrics are public. Grant to anon so the park list and
-- metric labels load even during the brief moment before
-- signInAnonymously() resolves.
GRANT SELECT ON parks   TO anon, authenticated;
GRANT SELECT ON metrics TO anon, authenticated;

-- Users: authenticated users upsert and read their own row.
-- RLS enforces that id must match app.user_id.
GRANT SELECT, INSERT, UPDATE ON users TO authenticated;

-- User data tables: full CRUD for authenticated users.
-- RLS enforces that user_id must match app.user_id.
GRANT SELECT, INSERT, UPDATE, DELETE ON ratings      TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON user_weights TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON visits       TO authenticated;


-- ============================================================
-- SECTION 6: AGGREGATE VIEW
--
--  Not created with WITH (security_invoker = true), so it runs
--  as its owner (postgres / superuser) and bypasses RLS on the
--  ratings table. This is intentional: the community leaderboard
--  must aggregate scores across all users, not just the current
--  one. The view exposes only aggregated data — park name, rater
--  count, and average score. No user IDs or individual ratings
--  are accessible through it.
--
--  The Supabase linter will flag this as a SECURITY DEFINER
--  view. That warning is correct in general and acceptable here.
-- ============================================================

CREATE VIEW public.aggregate_scores AS
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
    FROM   ratings r
    JOIN   metrics m ON m.id = r.metric_id
    GROUP  BY r.park_id, r.user_id
) sub ON sub.park_id = p.id
GROUP  BY p.id, p.name, p.slug
ORDER  BY aggregate_score DESC;

-- Aggregate scores view: public, for the community leaderboard.
GRANT SELECT ON aggregate_scores TO anon, authenticated;

-- ============================================================
-- SECTION 7: SEED DATA — METRICS
-- ============================================================

INSERT INTO metrics (key, label, default_weight, sort_order) VALUES
    ('landscape_beauty', 'Landscape Beauty', 25, 1),
    ('uniqueness',       'Uniqueness',       15, 2),
    ('wow_moments',      'Wow Moments',      10, 3),
    ('crowds',           'Crowds',           5, 4),
    ('wildlife',         'Wildlife',         15, 5),
    ('variety',          'Variety',          10, 6),
    ('selection',        'Selection',        15, 7),
    ('access',           'Access',           5, 8);


-- ============================================================
-- SECTION 8: SEED DATA — ALL 63 NATIONAL PARKS
-- ============================================================

INSERT INTO parks (name, slug, states, nps_region, established, area_acres) VALUES
    ('Acadia',                       'acadia',                       'ME',          'Northeast',     1919,  49071.40),
    ('American Samoa',               'american-samoa',               'AS',          'Pacific West',  1988,  8256.67),
    ('Arches',                       'arches',                       'UT',          'Intermountain', 1971,  76678.98),
    ('Badlands',                     'badlands',                     'SD',          'Midwest',       1978,  242755.94),
    ('Big Bend',                     'big-bend',                     'TX',          'Intermountain', 1944,  801163.21),
    ('Biscayne',                     'biscayne',                     'FL',          'Southeast',     1980,  172971.11),
    ('Black Canyon of the Gunnison', 'black-canyon-of-the-gunnison', 'CO',          'Intermountain', 1999,  30779.83),
    ('Bryce Canyon',                 'bryce-canyon',                 'UT',          'Intermountain', 1928,  35835.08),
    ('Canyonlands',                  'canyonlands',                  'UT',          'Intermountain', 1964,  337597.83),
    ('Capitol Reef',                 'capitol-reef',                 'UT',          'Intermountain', 1971,  241904.50),
    ('Carlsbad Caverns',             'carlsbad-caverns',             'NM',          'Intermountain', 1930,  46766.45),
    ('Channel Islands',              'channel-islands',              'CA',          'Pacific West',  1980,  249561.00),
    ('Congaree',                     'congaree',                     'SC',          'Southeast',     2003,  26692.60),
    ('Crater Lake',                  'crater-lake',                  'OR',          'Pacific West',  1902,  183224.05),
    ('Cuyahoga Valley',              'cuyahoga-valley',              'OH',          'Midwest',       2000,  32571.88),
    ('Death Valley',                 'death-valley',                 'CA, NV',      'Pacific West',  1994,  3408395.63),
    ('Denali',                       'denali',                       'AK',          'Alaska',        1917,  4740911.16),
    ('Dry Tortugas',                 'dry-tortugas',                 'FL',          'Southeast',     1992,  64701.22),
    ('Everglades',                   'everglades',                   'FL',          'Southeast',     1947,  1508938.57),
    ('Gates of the Arctic',          'gates-of-the-arctic',          'AK',          'Alaska',        1980,  7523897.45),
    ('Gateway Arch',                 'gateway-arch',                 'MO',          'Midwest',       2018,  91.00),
    ('Glacier',                      'glacier',                      'MT',          'Intermountain', 1910,  1013126.39),
    ('Glacier Bay',                  'glacier-bay',                  'AK',          'Alaska',        1980,  3223383.43),
    ('Grand Canyon',                 'grand-canyon',                 'AZ',          'Intermountain', 1919,  1201647.03),
    ('Grand Teton',                  'grand-teton',                  'WY',          'Intermountain', 1929,  310044.36),
    ('Great Basin',                  'great-basin',                  'NV',          'Intermountain', 1986,  77180.00),
    ('Great Sand Dunes',             'great-sand-dunes',             'CO',          'Intermountain', 2004,  107345.73),
    ('Great Smoky Mountains',        'great-smoky-mountains',        'TN, NC',      'Southeast',     1934,  522426.88),
    ('Guadalupe Mountains',          'guadalupe-mountains',          'TX',          'Intermountain', 1966,  86367.10),
    ('Haleakala',                    'haleakala',                    'HI',          'Pacific West',  1961,  33264.62),
    ('Hawaii Volcanoes',             'hawaii-volcanoes',             'HI',          'Pacific West',  1916,  325605.28),
    ('Hot Springs',                  'hot-springs',                  'AR',          'Midwest',       1921,  5554.15),
    ('Indiana Dunes',                'indiana-dunes',                'IN',          'Midwest',       2019,  15349.08),
    ('Isle Royale',                  'isle-royale',                  'MI',          'Midwest',       1940,  571790.30),
    ('Joshua Tree',                  'joshua-tree',                  'CA',          'Pacific West',  1994,  795155.85),
    ('Katmai',                       'katmai',                       'AK',          'Alaska',        1980,  3674529.33),
    ('Kenai Fjords',                 'kenai-fjords',                 'AK',          'Alaska',        1980,  669650.05),
    ('Kings Canyon',                 'kings-canyon',                 'CA',          'Pacific West',  1940,  461901.20),
    ('Kobuk Valley',                 'kobuk-valley',                 'AK',          'Alaska',        1980,  1750716.16),
    ('Lake Clark',                   'lake-clark',                   'AK',          'Alaska',        1980,  2619816.49),
    ('Lassen Volcanic',              'lassen-volcanic',              'CA',          'Pacific West',  1916,  106589.02),
    ('Mammoth Cave',                 'mammoth-cave',                 'KY',          'Southeast',     1941,  54016.29),
    ('Mesa Verde',                   'mesa-verde',                   'CO',          'Intermountain', 1906,  52485.00),
    ('Mount Rainier',                'mount-rainier',                'WA',          'Pacific West',  1899,  236381.64),
    ('New River Gorge',              'new-river-gorge',              'WV',          'Northeast',     2020,  7021.00),
    ('North Cascades',               'north-cascades',               'WA',          'Pacific West',  1968,  504780.94),
    ('Olympic',                      'olympic',                      'WA',          'Pacific West',  1938,  922650.94),
    ('Petrified Forest',             'petrified-forest',             'AZ',          'Intermountain', 1962,  221390.21),
    ('Pinnacles',                    'pinnacles',                    'CA',          'Pacific West',  2013,  26685.73),
    ('Redwood',                      'redwood',                      'CA',          'Pacific West',  1968,  138999.37),
    ('Rocky Mountain',               'rocky-mountain',               'CO',          'Intermountain', 1915,  265807.11),
    ('Saguaro',                      'saguaro',                      'AZ',          'Intermountain', 1994,  92125.74),
    ('Sequoia',                      'sequoia',                      'CA',          'Pacific West',  1890,  404063.63),
    ('Shenandoah',                   'shenandoah',                   'VA',          'Northeast',     1935,  199223.77),
    ('Theodore Roosevelt',           'theodore-roosevelt',           'ND',          'Midwest',       1978,  70446.89),
    ('Virgin Islands',               'virgin-islands',               'VI',          'Southeast',     1956,  14940.00),
    ('Voyageurs',                    'voyageurs',                    'MN',          'Midwest',       1975,  218222.36),
    ('White Sands',                  'white-sands',                  'NM',          'Intermountain', 2019,  145761.93),
    ('Wind Cave',                    'wind-cave',                    'SD',          'Midwest',       1903,  33970.84),
    ('Wrangell-St. Elias',           'wrangell-st-elias',            'AK',          'Alaska',        1980,  13175799.00),
    ('Yellowstone',                  'yellowstone',                  'WY, MT, ID',  'Intermountain', 1872,  2219790.71),
    ('Yosemite',                     'yosemite',                     'CA',          'Pacific West',  1890,  761747.50),
    ('Zion',                         'zion',                         'UT',          'Intermountain', 1919,  147242.66);