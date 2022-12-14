-- Create Pace table
CREATE TABLE cumulative_pace (
    "index" INT,
    team VARCHAR,
    schedule_season INT,
    team_year VARCHAR,
    sec_play_total NUMERIC,
    sec_play_neutral NUMERIC,
    sec_play_composite NUMERIC);
 -- View table   
SELECT * FROM cumulative_pace

-- Create Totals table
CREATE TABLE totals_cleaned (
    "index" INT,
    schedule_date DATE,
    schedule_season INT,
    schedule_week INT,
    team_home VARCHAR,
    team_home_full VARCHAR,
    team_away VARCHAR,
    team_away_full VARCHAR,
    score_home INT,
    score_away INT,
    score_total INT,
    over_under_line NUMERIC,
    over_under_diff NUMERIC,
    over_binary NUMERIC,
    spread_favorite NUMERIC);
-- View table
SELECT * FROM totals_cleaned

-- Create DVOA table
CREATE TABLE cumulative_dvoa (
"index" INT,
team VARCHAR,
schedule_season INT,
team_year VARCHAR,
total_dvoa NUMERIC,
weighted_dvoa NUMERIC,
offense_dvoa NUMERIC,
defense_dvoa NUMERIC,
special_dvoa NUMERIC,
off_def_difference NUMERIC);
-- View table
SELECT * FROM cumulative_dvoa

-------------------------------
-- CSVs imported into tables
-------------------------------

-- Query to test merging of initial tables
SELECT tc.index, tc.schedule_date, tc.schedule_season, tc.schedule_week, tc.team_home, 
       tc.team_home_full, tc.team_away, tc.team_away_full, tc.score_home, tc.score_away, tc.score_total, 
       tc.over_under_line, tc.over_under_diff, tc.over_binary, tc.spread_favorite,  cd.total_dvoa, 
       cd.weighted_dvoa, cd.offense_dvoa, cd.defense_dvoa, cd.special_dvoa, cd.off_def_difference, 
       cp.sec_play_total, cp.sec_play_neutral, cp.sec_play_composite 
FROM totals_cleaned tc, cumulative_pace cp, cumulative_dvoa cd
WHERE cp.team_year = tc.team_home_full AND tc.team_home_full = cd.team_year ;

-- Creating home table from query
CREATE TABLE nfl_home_table AS (
SELECT tc.index, tc.schedule_date, tc.schedule_season, tc.schedule_week, tc.team_home, 
       tc.team_home_full, tc.team_away, tc.team_away_full, tc.score_home, tc.score_away, tc.score_total, 
       tc.over_under_line, tc.over_under_diff, tc.over_binary, tc.spread_favorite,  cd.total_dvoa, 
       cd.weighted_dvoa, cd.offense_dvoa, cd.defense_dvoa, cd.special_dvoa, cd.off_def_difference, 
       cp.sec_play_total, cp.sec_play_neutral, cp.sec_play_composite 
FROM totals_cleaned tc, cumulative_pace cp, cumulative_dvoa cd
WHERE cp.team_year = tc.team_home_full AND tc.team_home_full = cd.team_year) ;

-- Creating away table from query
CREATE TABLE nfl_away_table AS (
SELECT tc.index, tc.schedule_date, tc.schedule_season, tc.schedule_week, tc.team_home, 
       tc.team_home_full, tc.team_away, tc.team_away_full, tc.score_home, tc.score_away, tc.score_total, 
       tc.over_under_line, tc.over_under_diff, tc.over_binary, tc.spread_favorite,  cd.total_dvoa, 
       cd.weighted_dvoa, cd.offense_dvoa, cd.defense_dvoa, cd.special_dvoa, cd.off_def_difference, 
       cp.sec_play_total, cp.sec_play_neutral, cp.sec_play_composite 
FROM totals_cleaned tc, cumulative_pace cp, cumulative_dvoa cd
WHERE cp.team_year = tc.team_away_full AND tc.team_away_full = cd.team_year) ;

-- Renaming home table columns in prep for merge with away
ALTER TABLE nfl_home_table
RENAME total_dvoa TO home_total_dvoa ;
ALTER TABLE nfl_home_table
RENAME weighted_dvoa TO home_weighted_dvoa 
ALTER TABLE nfl_home_table
RENAME offense_dvoa TO home_offense_dvoa ;
ALTER TABLE nfl_home_table
RENAME defense_dvoa TO home_defense_dvoa ;
ALTER TABLE nfl_home_table
RENAME special_dvoa TO home_special_dvoa ;
ALTER TABLE nfl_home_table
RENAME off_def_difference TO home_off_def_difference ;
ALTER TABLE nfl_home_table
RENAME sec_play_total TO home_sec_play_total ;
ALTER TABLE nfl_home_table
RENAME sec_play_neutral TO home_sec_play_neutral ;
ALTER TABLE nfl_home_table
RENAME sec_play_composite TO home_sec_play_composite ;

-- Renaming away team columns in prep for merge with home
ALTER TABLE nfl_away_table
RENAME total_dvoa TO away_total_dvoa ;
ALTER TABLE nfl_away_table
RENAME weighted_dvoa TO away_weighted_dvoa ;
ALTER TABLE nfl_away_table
RENAME offense_dvoa TO away_offense_dvoa ;
ALTER TABLE nfl_away_table
RENAME defense_dvoa TO away_defense_dvoa ;
ALTER TABLE nfl_away_table
RENAME special_dvoa TO away_special_dvoa ;
ALTER TABLE nfl_away_table
RENAME off_def_difference TO away_off_def_difference ;
ALTER TABLE nfl_away_table
RENAME sec_play_total TO away_sec_play_total ;
ALTER TABLE nfl_away_table
RENAME sec_play_neutral TO away_sec_play_neutral ;
ALTER TABLE nfl_away_table
RENAME sec_play_composite TO away_sec_play_composite ;

-- View home and away intermediate tables
SELECT * FROM nfl_home_table
SELECT * FROM nfl_away_table

-- Joining the home and away tables into final table
CREATE TABLE nfl_complete_dataset AS (
SELECT b.index, b.schedule_date, b.schedule_season, b.schedule_week, 
       b.team_home, b.team_home_full, b.team_away, b.team_away_full, b.score_home, 
       b.score_away, b.score_total, b.over_under_line, b.over_under_diff, 
       b.over_binary, b.spread_favorite, b.home_total_dvoa, b.home_weighted_dvoa, 
       b.home_offense_dvoa, b.home_defense_dvoa, b.home_special_dvoa, b.home_off_def_difference, 
       b.home_sec_play_total, b.home_sec_play_neutral, b.home_sec_play_composite, d.away_total_dvoa, 
       d.away_weighted_dvoa, d.away_offense_dvoa, d.away_defense_dvoa, d.away_special_dvoa, 
       d.away_off_def_difference, d.away_sec_play_total, d.away_sec_play_neutral, d.away_sec_play_composite
FROM nfl_home_table b, nfl_away_table d
WHERE b.index = d.index);

-- Check table counts
SELECT * FROM nfl_complete_dataset
SELECT COUNT (*)
FROM totals_cleaned
SELECT COUNT (*)
FROM cumulative_pace
SELECT COUNT (*)
FROM cumulative_dvoa

-- Creating initial table with engineered features
CREATE TABLE intermediate_nfl_table AS (
SELECT "index", schedule_date, schedule_season, schedule_week, team_home, team_home_full, team_away_full, score_home, score_away, score_total,
        over_under_line, over_under_diff, over_binary, spread_favorite, home_total_dvoa, home_weighted_dvoa, home_offense_dvoa, home_defense_dvoa,
        home_special_dvoa, home_off_def_difference, home_sec_play_total, home_sec_play_neutral, home_sec_play_composite, away_total_dvoa, away_weighted_dvoa,
        away_offense_dvoa, away_defense_dvoa, away_special_dvoa, away_off_def_difference, away_sec_play_total, away_sec_play_neutral, away_sec_play_composite, 
        (home_total_dvoa + away_total_dvoa) AS dvoa_total_cumulative, (SELECT ABS (home_total_dvoa - away_total_dvoa) AS dvoa_total_difference), 
        (home_weighted_dvoa + away_weighted_dvoa) AS dvoa_weighted_cumulative, (SELECT ABS (home_weighted_dvoa - away_weighted_dvoa) AS dvoa_weighted_difference), 
        (home_offense_dvoa + away_offense_dvoa) AS dvoa_offense_cumulative, (SELECT ABS (home_offense_dvoa - away_offense_dvoa) AS dvoa_offense_difference), 
        (home_defense_dvoa + away_defense_dvoa) AS dvoa_defense_cumulative, (SELECT ABS (home_defense_dvoa - away_defense_dvoa) AS dvoa_defense_difference), 
        (home_special_dvoa + away_special_dvoa) AS dvoa_special_cumulative, (SELECT ABS (home_special_dvoa - away_special_dvoa) AS dvoa_special_difference),
        (home_offense_dvoa + away_defense_dvoa) AS dvoa_home_offense_matchup, (away_offense_dvoa + home_defense_dvoa) AS dvoa_away_offense_matchup, 
        ((home_sec_play_composite + away_sec_play_composite)/2) AS composite_pace_average, (SELECT ABS (home_sec_play_composite - away_sec_play_composite) AS composite_pace_difference),
        (home_off_def_difference + away_off_def_difference) AS dvoa_offdefdiff_cumulative, (SELECT ABS (home_off_def_difference - away_off_def_difference) AS dvoa_offdefdiff_difference)
FROM nfl_complete_dataset );

-- Creating additional features on final table
CREATE TABLE nfl_ml_dataset AS (
SELECT "index", schedule_date, schedule_season, schedule_week, team_home, team_home_full, team_away_full, score_home, score_away, score_total,
        over_under_line, over_under_diff, over_binary, spread_favorite, home_total_dvoa, home_weighted_dvoa, home_offense_dvoa, home_defense_dvoa,
        home_special_dvoa, home_off_def_difference, home_sec_play_total, home_sec_play_neutral, home_sec_play_composite, away_total_dvoa, away_weighted_dvoa,
        away_offense_dvoa, away_defense_dvoa, away_special_dvoa, away_off_def_difference, away_sec_play_total, away_sec_play_neutral, away_sec_play_composite, 
        dvoa_total_cumulative, dvoa_total_difference, dvoa_weighted_cumulative, dvoa_weighted_difference, dvoa_offense_cumulative, dvoa_offense_difference, 
        dvoa_defense_cumulative, dvoa_defense_difference, dvoa_special_cumulative, dvoa_special_difference, dvoa_home_offense_matchup, dvoa_away_offense_matchup, 
        composite_pace_average, composite_pace_difference, dvoa_offdefdiff_cumulative, dvoa_offdefdiff_difference, 
        (dvoa_home_offense_matchup + dvoa_away_offense_matchup) AS offense_matchup_cumulative, 
        (SELECT ABS (dvoa_home_offense_matchup - dvoa_away_offense_matchup) AS offense_matchup_difference)
FROM intermediate_nfl_table);
