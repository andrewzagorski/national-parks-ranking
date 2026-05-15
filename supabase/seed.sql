-- ============================================================
--  seed.sql — sample data for local development only
--  Run via:  supabase db reset
--  This file is NOT applied to production by default.
-- ============================================================

-- Two fake users
INSERT INTO users (id) VALUES
    ('a0000000-0000-0000-0000-000000000001'),
    ('a0000000-0000-0000-0000-000000000002');

-- Sample user_park_ratings
INSERT INTO user_park_ratings (user_id, park_id, last_visit_date, notes) VALUES
    ('a0000000-0000-0000-0000-000000000001',
        (SELECT id FROM parks WHERE slug = 'grand-canyon'),
        '2023-05-14',
        'Hiked the Bright Angel Trail. Stunning but very hot.'),
    ('a0000000-0000-0000-0000-000000000001',
        (SELECT id FROM parks WHERE slug = 'zion'),
        '2023-05-17',
        'Angels Landing was incredible. Chains section not for the faint-hearted.'),
    ('a0000000-0000-0000-0000-000000000002',
        (SELECT id FROM parks WHERE slug = 'yellowstone'),
        '2024-07-04',
        'Old Faithful right on time. Saw a grizzly near Hayden Valley.');

-- Sample ratings: user 1 rates Grand Canyon
INSERT INTO ratings (user_id, park_id, metric_id, score) VALUES
    ('a0000000-0000-0000-0000-000000000001', (SELECT id FROM parks WHERE slug = 'grand-canyon'), (SELECT id FROM metrics WHERE key = 'crowds'),           2),
    ('a0000000-0000-0000-0000-000000000001', (SELECT id FROM parks WHERE slug = 'grand-canyon'), (SELECT id FROM metrics WHERE key = 'landscape_beauty'), 5),
    ('a0000000-0000-0000-0000-000000000001', (SELECT id FROM parks WHERE slug = 'grand-canyon'), (SELECT id FROM metrics WHERE key = 'wildlife'),         3),
    ('a0000000-0000-0000-0000-000000000001', (SELECT id FROM parks WHERE slug = 'grand-canyon'), (SELECT id FROM metrics WHERE key = 'uniqueness'),       5),
    ('a0000000-0000-0000-0000-000000000001', (SELECT id FROM parks WHERE slug = 'grand-canyon'), (SELECT id FROM metrics WHERE key = 'wow_moments'),      5),
    ('a0000000-0000-0000-0000-000000000001', (SELECT id FROM parks WHERE slug = 'grand-canyon'), (SELECT id FROM metrics WHERE key = 'variety'),          4),
    ('a0000000-0000-0000-0000-000000000001', (SELECT id FROM parks WHERE slug = 'grand-canyon'), (SELECT id FROM metrics WHERE key = 'selection'),        4),
    ('a0000000-0000-0000-0000-000000000001', (SELECT id FROM parks WHERE slug = 'grand-canyon'), (SELECT id FROM metrics WHERE key = 'access'),           4);

-- Sample ratings: user 1 rates Zion
INSERT INTO ratings (user_id, park_id, metric_id, score) VALUES
    ('a0000000-0000-0000-0000-000000000001', (SELECT id FROM parks WHERE slug = 'zion'), (SELECT id FROM metrics WHERE key = 'crowds'),           1),
    ('a0000000-0000-0000-0000-000000000001', (SELECT id FROM parks WHERE slug = 'zion'), (SELECT id FROM metrics WHERE key = 'landscape_beauty'), 5),
    ('a0000000-0000-0000-0000-000000000001', (SELECT id FROM parks WHERE slug = 'zion'), (SELECT id FROM metrics WHERE key = 'wildlife'),         3),
    ('a0000000-0000-0000-0000-000000000001', (SELECT id FROM parks WHERE slug = 'zion'), (SELECT id FROM metrics WHERE key = 'uniqueness'),       4),
    ('a0000000-0000-0000-0000-000000000001', (SELECT id FROM parks WHERE slug = 'zion'), (SELECT id FROM metrics WHERE key = 'wow_moments'),      5),
    ('a0000000-0000-0000-0000-000000000001', (SELECT id FROM parks WHERE slug = 'zion'), (SELECT id FROM metrics WHERE key = 'variety'),          4),
    ('a0000000-0000-0000-0000-000000000001', (SELECT id FROM parks WHERE slug = 'zion'), (SELECT id FROM metrics WHERE key = 'selection'),        3),
    ('a0000000-0000-0000-0000-000000000001', (SELECT id FROM parks WHERE slug = 'zion'), (SELECT id FROM metrics WHERE key = 'access'),           4);

-- Sample ratings: user 2 rates Yellowstone
INSERT INTO ratings (user_id, park_id, metric_id, score) VALUES
    ('a0000000-0000-0000-0000-000000000002', (SELECT id FROM parks WHERE slug = 'yellowstone'), (SELECT id FROM metrics WHERE key = 'crowds'),           2),
    ('a0000000-0000-0000-0000-000000000002', (SELECT id FROM parks WHERE slug = 'yellowstone'), (SELECT id FROM metrics WHERE key = 'landscape_beauty'), 4),
    ('a0000000-0000-0000-0000-000000000002', (SELECT id FROM parks WHERE slug = 'yellowstone'), (SELECT id FROM metrics WHERE key = 'wildlife'),         5),
    ('a0000000-0000-0000-0000-000000000002', (SELECT id FROM parks WHERE slug = 'yellowstone'), (SELECT id FROM metrics WHERE key = 'uniqueness'),       5),
    ('a0000000-0000-0000-0000-000000000002', (SELECT id FROM parks WHERE slug = 'yellowstone'), (SELECT id FROM metrics WHERE key = 'wow_moments'),      5),
    ('a0000000-0000-0000-0000-000000000002', (SELECT id FROM parks WHERE slug = 'yellowstone'), (SELECT id FROM metrics WHERE key = 'variety'),          5),
    ('a0000000-0000-0000-0000-000000000002', (SELECT id FROM parks WHERE slug = 'yellowstone'), (SELECT id FROM metrics WHERE key = 'selection'),        5),
    ('a0000000-0000-0000-0000-000000000002', (SELECT id FROM parks WHERE slug = 'yellowstone'), (SELECT id FROM metrics WHERE key = 'access'),           3);

-- Sample custom weights for user 2 (they care a lot about wildlife)
INSERT INTO user_weights (user_id, metric_id, weight) VALUES
    ('a0000000-0000-0000-0000-000000000002', (SELECT id FROM metrics WHERE key = 'wildlife'),         25),
    ('a0000000-0000-0000-0000-000000000002', (SELECT id FROM metrics WHERE key = 'crowds'),           10),
    ('a0000000-0000-0000-0000-000000000002', (SELECT id FROM metrics WHERE key = 'landscape_beauty'), 10),
    ('a0000000-0000-0000-0000-000000000002', (SELECT id FROM metrics WHERE key = 'uniqueness'),       13),
    ('a0000000-0000-0000-0000-000000000002', (SELECT id FROM metrics WHERE key = 'wow_moments'),      12),
    ('a0000000-0000-0000-0000-000000000002', (SELECT id FROM metrics WHERE key = 'variety'),          10),
    ('a0000000-0000-0000-0000-000000000002', (SELECT id FROM metrics WHERE key = 'selection'),        10),
    ('a0000000-0000-0000-0000-000000000002', (SELECT id FROM metrics WHERE key = 'access'),           10);