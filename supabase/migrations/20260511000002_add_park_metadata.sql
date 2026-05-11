-- ============================================================
--  Migration: add_park_metadata
--  Adds state(s), NPS region, established year, and area in
--  acres to the parks table, then populates all 63 parks.
--
--  Sources:
--    - NPS official acreage reports
--    - NPS regional office designations
--    - Congressional designation dates (year as national park,
--      not predecessor monument/recreation area dates)
-- ============================================================


-- ------------------------------------------------------------
-- 1. ADD COLUMNS
-- ------------------------------------------------------------

ALTER TABLE parks
    ADD COLUMN states       TEXT,         -- e.g. 'CA' or 'CA, NV'
    ADD COLUMN nps_region   TEXT,         -- official NPS region name
    ADD COLUMN established  SMALLINT,     -- year designated as national park
    ADD COLUMN area_acres   NUMERIC(12,2); -- official NPS acreage


-- ------------------------------------------------------------
-- 2. POPULATE METADATA FOR ALL 63 PARKS
--
--  NPS Regions used:
--    Alaska
--    Pacific West       (CA, OR, WA, HI, ID, NV, American Samoa)
--    Intermountain      (AZ, CO, MT, NM, OK, TX, UT, WY)
--    Midwest            (AR, IL, IN, IA, KS, MI, MN, MO, NE, ND, OH, SD, WI)
--    Southeast          (AL, FL, GA, KY, LA, MS, NC, PR, SC, TN, USVI)
--    Northeast          (CT, DE, MA, MD, ME, NH, NJ, NY, PA, RI, VA, VT, WV)
--    National Capital   (DC area)
-- ------------------------------------------------------------

UPDATE parks SET states = 'ME',        nps_region = 'Northeast',     established = 1919, area_acres = 49071.40   WHERE slug = 'acadia';
UPDATE parks SET states = 'AS',        nps_region = 'Pacific West',  established = 1988, area_acres = 8256.67    WHERE slug = 'american-samoa';
UPDATE parks SET states = 'UT',        nps_region = 'Intermountain', established = 1971, area_acres = 76678.98   WHERE slug = 'arches';
UPDATE parks SET states = 'SD',        nps_region = 'Midwest',       established = 1978, area_acres = 242755.94  WHERE slug = 'badlands';
UPDATE parks SET states = 'TX',        nps_region = 'Intermountain', established = 1944, area_acres = 801163.21  WHERE slug = 'big-bend';
UPDATE parks SET states = 'FL',        nps_region = 'Southeast',     established = 1980, area_acres = 172971.11  WHERE slug = 'biscayne';
UPDATE parks SET states = 'CO',        nps_region = 'Intermountain', established = 1999, area_acres = 30779.83   WHERE slug = 'black-canyon-of-the-gunnison';
UPDATE parks SET states = 'UT',        nps_region = 'Intermountain', established = 1928, area_acres = 35835.08   WHERE slug = 'bryce-canyon';
UPDATE parks SET states = 'UT',        nps_region = 'Intermountain', established = 1964, area_acres = 337597.83  WHERE slug = 'canyonlands';
UPDATE parks SET states = 'UT',        nps_region = 'Intermountain', established = 1971, area_acres = 241904.50  WHERE slug = 'capitol-reef';
UPDATE parks SET states = 'NM',        nps_region = 'Intermountain', established = 1930, area_acres = 46766.45   WHERE slug = 'carlsbad-caverns';
UPDATE parks SET states = 'CA',        nps_region = 'Pacific West',  established = 1980, area_acres = 249561.00  WHERE slug = 'channel-islands';
UPDATE parks SET states = 'SC',        nps_region = 'Southeast',     established = 2003, area_acres = 26692.60   WHERE slug = 'congaree';
UPDATE parks SET states = 'OR',        nps_region = 'Pacific West',  established = 1902, area_acres = 183224.05  WHERE slug = 'crater-lake';
UPDATE parks SET states = 'OH',        nps_region = 'Midwest',       established = 2000, area_acres = 32571.88   WHERE slug = 'cuyahoga-valley';
UPDATE parks SET states = 'CA, NV',    nps_region = 'Pacific West',  established = 1994, area_acres = 3408395.63 WHERE slug = 'death-valley';
UPDATE parks SET states = 'AK',        nps_region = 'Alaska',        established = 1917, area_acres = 4740911.16 WHERE slug = 'denali';
UPDATE parks SET states = 'FL',        nps_region = 'Southeast',     established = 1992, area_acres = 64701.22   WHERE slug = 'dry-tortugas';
UPDATE parks SET states = 'FL',        nps_region = 'Southeast',     established = 1947, area_acres = 1508938.57 WHERE slug = 'everglades';
UPDATE parks SET states = 'AK',        nps_region = 'Alaska',        established = 1980, area_acres = 7523897.45 WHERE slug = 'gates-of-the-arctic';
UPDATE parks SET states = 'MO',        nps_region = 'Midwest',       established = 2018, area_acres = 91.00      WHERE slug = 'gateway-arch';
UPDATE parks SET states = 'MT',        nps_region = 'Intermountain', established = 1910, area_acres = 1013126.39 WHERE slug = 'glacier';
UPDATE parks SET states = 'AK',        nps_region = 'Alaska',        established = 1980, area_acres = 3223383.43 WHERE slug = 'glacier-bay';
UPDATE parks SET states = 'AZ',        nps_region = 'Intermountain', established = 1919, area_acres = 1201647.03 WHERE slug = 'grand-canyon';
UPDATE parks SET states = 'WY',        nps_region = 'Intermountain', established = 1929, area_acres = 310044.36  WHERE slug = 'grand-teton';
UPDATE parks SET states = 'NV',        nps_region = 'Intermountain', established = 1986, area_acres = 77180.00   WHERE slug = 'great-basin';
UPDATE parks SET states = 'CO',        nps_region = 'Intermountain', established = 2004, area_acres = 107345.73  WHERE slug = 'great-sand-dunes';
UPDATE parks SET states = 'TN, NC',    nps_region = 'Southeast',     established = 1934, area_acres = 522426.88  WHERE slug = 'great-smoky-mountains';
UPDATE parks SET states = 'TX',        nps_region = 'Intermountain', established = 1966, area_acres = 86367.10   WHERE slug = 'guadalupe-mountains';
UPDATE parks SET states = 'HI',        nps_region = 'Pacific West',  established = 1961, area_acres = 33264.62   WHERE slug = 'haleakala';
UPDATE parks SET states = 'HI',        nps_region = 'Pacific West',  established = 1916, area_acres = 325605.28  WHERE slug = 'hawaii-volcanoes';
UPDATE parks SET states = 'AR',        nps_region = 'Midwest',       established = 1921, area_acres = 5554.15    WHERE slug = 'hot-springs';
UPDATE parks SET states = 'IN',        nps_region = 'Midwest',       established = 2019, area_acres = 15349.08   WHERE slug = 'indiana-dunes';
UPDATE parks SET states = 'MI',        nps_region = 'Midwest',       established = 1940, area_acres = 571790.30  WHERE slug = 'isle-royale';
UPDATE parks SET states = 'CA',        nps_region = 'Pacific West',  established = 1994, area_acres = 795155.85  WHERE slug = 'joshua-tree';
UPDATE parks SET states = 'AK',        nps_region = 'Alaska',        established = 1980, area_acres = 3674529.33 WHERE slug = 'katmai';
UPDATE parks SET states = 'AK',        nps_region = 'Alaska',        established = 1980, area_acres = 669650.05  WHERE slug = 'kenai-fjords';
UPDATE parks SET states = 'CA',        nps_region = 'Pacific West',  established = 1940, area_acres = 461901.20  WHERE slug = 'kings-canyon';
UPDATE parks SET states = 'AK',        nps_region = 'Alaska',        established = 1980, area_acres = 1750716.16 WHERE slug = 'kobuk-valley';
UPDATE parks SET states = 'AK',        nps_region = 'Alaska',        established = 1980, area_acres = 2619816.49 WHERE slug = 'lake-clark';
UPDATE parks SET states = 'CA',        nps_region = 'Pacific West',  established = 1916, area_acres = 106589.02  WHERE slug = 'lassen-volcanic';
UPDATE parks SET states = 'KY',        nps_region = 'Southeast',     established = 1941, area_acres = 54016.29   WHERE slug = 'mammoth-cave';
UPDATE parks SET states = 'CO',        nps_region = 'Intermountain', established = 1906, area_acres = 52485.00   WHERE slug = 'mesa-verde';
UPDATE parks SET states = 'WA',        nps_region = 'Pacific West',  established = 1899, area_acres = 236381.64  WHERE slug = 'mount-rainier';
UPDATE parks SET states = 'WV',        nps_region = 'Northeast',     established = 2020, area_acres = 7021.00    WHERE slug = 'new-river-gorge';
UPDATE parks SET states = 'WA',        nps_region = 'Pacific West',  established = 1968, area_acres = 504780.94  WHERE slug = 'north-cascades';
UPDATE parks SET states = 'WA',        nps_region = 'Pacific West',  established = 1938, area_acres = 922650.94  WHERE slug = 'olympic';
UPDATE parks SET states = 'AZ',        nps_region = 'Intermountain', established = 1962, area_acres = 221390.21  WHERE slug = 'petrified-forest';
UPDATE parks SET states = 'CA',        nps_region = 'Pacific West',  established = 2013, area_acres = 26685.73   WHERE slug = 'pinnacles';
UPDATE parks SET states = 'CA',        nps_region = 'Pacific West',  established = 1968, area_acres = 138999.37  WHERE slug = 'redwood';
UPDATE parks SET states = 'CO',        nps_region = 'Intermountain', established = 1915, area_acres = 265807.11  WHERE slug = 'rocky-mountain';
UPDATE parks SET states = 'AZ',        nps_region = 'Intermountain', established = 1994, area_acres = 92125.74   WHERE slug = 'saguaro';
UPDATE parks SET states = 'CA',        nps_region = 'Pacific West',  established = 1890, area_acres = 404063.63  WHERE slug = 'sequoia';
UPDATE parks SET states = 'VA',        nps_region = 'Northeast',     established = 1935, area_acres = 199223.77  WHERE slug = 'shenandoah';
UPDATE parks SET states = 'ND',        nps_region = 'Midwest',       established = 1978, area_acres = 70446.89   WHERE slug = 'theodore-roosevelt';
UPDATE parks SET states = 'VI',        nps_region = 'Southeast',     established = 1956, area_acres = 14940.00   WHERE slug = 'virgin-islands';
UPDATE parks SET states = 'MN',        nps_region = 'Midwest',       established = 1975, area_acres = 218222.36  WHERE slug = 'voyageurs';
UPDATE parks SET states = 'NM',        nps_region = 'Intermountain', established = 2019, area_acres = 145761.93  WHERE slug = 'white-sands';
UPDATE parks SET states = 'SD',        nps_region = 'Midwest',       established = 1903, area_acres = 33970.84   WHERE slug = 'wind-cave';
UPDATE parks SET states = 'AK',        nps_region = 'Alaska',        established = 1980, area_acres = 13175799.00 WHERE slug = 'wrangell-st-elias';
UPDATE parks SET states = 'WY, MT, ID', nps_region = 'Intermountain', established = 1872, area_acres = 2219790.71 WHERE slug = 'yellowstone';
UPDATE parks SET states = 'CA',        nps_region = 'Pacific West',  established = 1890, area_acres = 761747.50  WHERE slug = 'yosemite';
UPDATE parks SET states = 'UT',        nps_region = 'Intermountain', established = 1919, area_acres = 147242.66  WHERE slug = 'zion';


-- ------------------------------------------------------------
-- 3. ADD CHECK CONSTRAINT ON nps_region
--    Locks the column to the 7 official NPS region names so
--    future inserts can't drift from the enum.
-- ------------------------------------------------------------

ALTER TABLE parks
    ADD CONSTRAINT chk_nps_region CHECK (nps_region IN (
        'Alaska',
        'Intermountain',
        'Midwest',
        'National Capital',
        'Northeast',
        'Pacific West',
        'Southeast'
    ));


-- ------------------------------------------------------------
-- 4. INDEX ON REGION AND STATE FOR FILTERING
-- ------------------------------------------------------------

CREATE INDEX idx_parks_region ON parks(nps_region);
CREATE INDEX idx_parks_states ON parks(states);