-- ============================================================
--  Migration: initial_schema
--  Creates all tables, indexes, RLS policies, views, and
--  seeds the static parks + metrics data.
-- ============================================================


-- ------------------------------------------------------------
-- TABLES
-- ------------------------------------------------------------

CREATE TABLE parks (
    id    SERIAL PRIMARY KEY,
    name  TEXT NOT NULL UNIQUE,
    slug  TEXT NOT NULL UNIQUE
);

CREATE TABLE metrics (
    id             SERIAL PRIMARY KEY,
    key            TEXT    NOT NULL UNIQUE,
    label          TEXT    NOT NULL,
    default_weight NUMERIC NOT NULL CHECK (default_weight >= 0),
    sort_order     INT     NOT NULL
);

CREATE TABLE users (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_seen  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE ratings (
    id         BIGSERIAL PRIMARY KEY,
    user_id    UUID     NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    park_id    INT      NOT NULL REFERENCES parks(id) ON DELETE CASCADE,
    metric_id  INT      NOT NULL REFERENCES metrics(id) ON DELETE CASCADE,
    score      SMALLINT NOT NULL CHECK (score BETWEEN 1 AND 5),
    rated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

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
    id          BIGSERIAL PRIMARY KEY,
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    park_id     INT  NOT NULL REFERENCES parks(id) ON DELETE CASCADE,
    visited_on  DATE,
    notes       TEXT,

    UNIQUE (user_id, park_id)
);


-- ------------------------------------------------------------
-- INDEXES
-- ------------------------------------------------------------

CREATE INDEX idx_ratings_user        ON ratings(user_id);
CREATE INDEX idx_ratings_park        ON ratings(park_id);
CREATE INDEX idx_ratings_park_metric ON ratings(park_id, metric_id);
CREATE INDEX idx_user_weights_user   ON user_weights(user_id);
CREATE INDEX idx_visits_user         ON visits(user_id);


-- ------------------------------------------------------------
-- ROW LEVEL SECURITY
-- ------------------------------------------------------------

ALTER TABLE parks        ENABLE ROW LEVEL SECURITY;
ALTER TABLE metrics      ENABLE ROW LEVEL SECURITY;
ALTER TABLE users        ENABLE ROW LEVEL SECURITY;
ALTER TABLE ratings      ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_weights ENABLE ROW LEVEL SECURITY;
ALTER TABLE visits       ENABLE ROW LEVEL SECURITY;

-- Parks + metrics: public read, no writes via API
CREATE POLICY "parks: public read"   ON parks   FOR SELECT USING (true);
CREATE POLICY "metrics: public read" ON metrics FOR SELECT USING (true);

-- Users
CREATE POLICY "users: read own"   ON users FOR SELECT USING (id = (current_setting('app.user_id', true))::UUID);
CREATE POLICY "users: insert own" ON users FOR INSERT WITH CHECK (id = (current_setting('app.user_id', true))::UUID);
CREATE POLICY "users: update own" ON users FOR UPDATE USING (id = (current_setting('app.user_id', true))::UUID);

-- Ratings
CREATE POLICY "ratings: read own"   ON ratings FOR SELECT USING (user_id = (current_setting('app.user_id', true))::UUID);
CREATE POLICY "ratings: insert own" ON ratings FOR INSERT WITH CHECK (user_id = (current_setting('app.user_id', true))::UUID);
CREATE POLICY "ratings: update own" ON ratings FOR UPDATE USING (user_id = (current_setting('app.user_id', true))::UUID);
CREATE POLICY "ratings: delete own" ON ratings FOR DELETE USING (user_id = (current_setting('app.user_id', true))::UUID);

-- User weights
CREATE POLICY "weights: read own"   ON user_weights FOR SELECT USING (user_id = (current_setting('app.user_id', true))::UUID);
CREATE POLICY "weights: insert own" ON user_weights FOR INSERT WITH CHECK (user_id = (current_setting('app.user_id', true))::UUID);
CREATE POLICY "weights: update own" ON user_weights FOR UPDATE USING (user_id = (current_setting('app.user_id', true))::UUID);
CREATE POLICY "weights: delete own" ON user_weights FOR DELETE USING (user_id = (current_setting('app.user_id', true))::UUID);

-- Visits
CREATE POLICY "visits: read own"   ON visits FOR SELECT USING (user_id = (current_setting('app.user_id', true))::UUID);
CREATE POLICY "visits: insert own" ON visits FOR INSERT WITH CHECK (user_id = (current_setting('app.user_id', true))::UUID);
CREATE POLICY "visits: update own" ON visits FOR UPDATE USING (user_id = (current_setting('app.user_id', true))::UUID);
CREATE POLICY "visits: delete own" ON visits FOR DELETE USING (user_id = (current_setting('app.user_id', true))::UUID);


-- ------------------------------------------------------------
-- AGGREGATE VIEW
--  Score formula: (score - 1) / 4.0 maps 1→0 and 5→1,
--  then multiplied by the metric weight (sum = 100).
--  Result is a 0–100 score averaged across all raters.
-- ------------------------------------------------------------

CREATE VIEW aggregate_scores AS
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
-- SEED: METRICS  (static — not in seed.sql because these are
-- required for the app to function, not just test data)
-- ------------------------------------------------------------

INSERT INTO metrics (key, label, default_weight, sort_order) VALUES
    ('crowds',           'Crowds',           12, 1),
    ('landscape_beauty', 'Landscape Beauty', 15, 2),
    ('wildlife',         'Wildlife',         12, 3),
    ('uniqueness',       'Uniqueness',       15, 4),
    ('wow_moments',      'Wow Moments',      13, 5),
    ('variety',          'Variety',          12, 6),
    ('selection',        'Selection',        11, 7),
    ('access',           'Access',           10, 8);


-- ------------------------------------------------------------
-- SEED: ALL 63 NATIONAL PARKS
-- ------------------------------------------------------------

INSERT INTO parks (name, slug) VALUES
    ('Acadia',                       'acadia'),
    ('American Samoa',               'american-samoa'),
    ('Arches',                       'arches'),
    ('Badlands',                     'badlands'),
    ('Big Bend',                     'big-bend'),
    ('Biscayne',                     'biscayne'),
    ('Black Canyon of the Gunnison', 'black-canyon-of-the-gunnison'),
    ('Bryce Canyon',                 'bryce-canyon'),
    ('Canyonlands',                  'canyonlands'),
    ('Capitol Reef',                 'capitol-reef'),
    ('Carlsbad Caverns',             'carlsbad-caverns'),
    ('Channel Islands',              'channel-islands'),
    ('Congaree',                     'congaree'),
    ('Crater Lake',                  'crater-lake'),
    ('Cuyahoga Valley',              'cuyahoga-valley'),
    ('Death Valley',                 'death-valley'),
    ('Denali',                       'denali'),
    ('Dry Tortugas',                 'dry-tortugas'),
    ('Everglades',                   'everglades'),
    ('Gates of the Arctic',          'gates-of-the-arctic'),
    ('Gateway Arch',                 'gateway-arch'),
    ('Glacier',                      'glacier'),
    ('Glacier Bay',                  'glacier-bay'),
    ('Grand Canyon',                 'grand-canyon'),
    ('Grand Teton',                  'grand-teton'),
    ('Great Basin',                  'great-basin'),
    ('Great Sand Dunes',             'great-sand-dunes'),
    ('Great Smoky Mountains',        'great-smoky-mountains'),
    ('Guadalupe Mountains',          'guadalupe-mountains'),
    ('Haleakala',                    'haleakala'),
    ('Hawaii Volcanoes',             'hawaii-volcanoes'),
    ('Hot Springs',                  'hot-springs'),
    ('Indiana Dunes',                'indiana-dunes'),
    ('Isle Royale',                  'isle-royale'),
    ('Joshua Tree',                  'joshua-tree'),
    ('Katmai',                       'katmai'),
    ('Kenai Fjords',                 'kenai-fjords'),
    ('Kings Canyon',                 'kings-canyon'),
    ('Kobuk Valley',                 'kobuk-valley'),
    ('Lake Clark',                   'lake-clark'),
    ('Lassen Volcanic',              'lassen-volcanic'),
    ('Mammoth Cave',                 'mammoth-cave'),
    ('Mesa Verde',                   'mesa-verde'),
    ('Mount Rainier',                'mount-rainier'),
    ('New River Gorge',              'new-river-gorge'),
    ('North Cascades',               'north-cascades'),
    ('Olympic',                      'olympic'),
    ('Petrified Forest',             'petrified-forest'),
    ('Pinnacles',                    'pinnacles'),
    ('Redwood',                      'redwood'),
    ('Rocky Mountain',               'rocky-mountain'),
    ('Saguaro',                      'saguaro'),
    ('Sequoia',                      'sequoia'),
    ('Shenandoah',                   'shenandoah'),
    ('Theodore Roosevelt',           'theodore-roosevelt'),
    ('Virgin Islands',               'virgin-islands'),
    ('Voyageurs',                    'voyageurs'),
    ('White Sands',                  'white-sands'),
    ('Wind Cave',                    'wind-cave'),
    ('Wrangell-St. Elias',           'wrangell-st-elias'),
    ('Yellowstone',                  'yellowstone'),
    ('Yosemite',                     'yosemite'),
    ('Zion',                         'zion');