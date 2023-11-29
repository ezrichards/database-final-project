DROP TABLE IF EXISTS player_info;
DROP TABLE IF EXISTS player_stats;
DROP TABLE IF EXISTS player_all;
DROP TABLE IF EXISTS player_all_clean;
DROP TABLE IF EXISTS player_salaries;
DROP TABLE IF EXISTS player_salaryinfo;

CREATE 
TABLE player_all(
    seas_id INT, season NUMERIC(4), player_id NUMERIC, player TEXT, birth_year TEXT,
    pos TEXT, age NUMERIC, experience NUMERIC, lg TEXT, tm TEXT, g NUMERIC, 
    gs NUMERIC, mp NUMERIC, fg NUMERIC, fga NUMERIC,
    fg_percent FLOAT, x3p NUMERIC, x3pa NUMERIC, x3p_percent NUMERIC(4,1),
    x2p NUMERIC, x2pa NUMERIC, x2p_percent NUMERIC(4,1), e_fg_percent NUMERIC(4,1),
    ft NUMERIC, fta NUMERIC, ft_percent NUMERIC(4,1), orb NUMERIC, drb NUMERIC,
    trb NUMERIC, ast NUMERIC, stl NUMERIC, blk NUMERIC, tov NUMERIC, pf NUMERIC, pts NUMERIC
);

CREATE 
TABLE player_info(
    seas_id INT, season NUMERIC(4), player_id NUMERIC, player TEXT,
    pos TEXT, age NUMERIC, experience NUMERIC, lg TEXT, tm TEXT
);

CREATE 
TABLE player_stats(
    seas_id INT, player_id NUMERIC, player TEXT, g NUMERIC, 
    gs NUMERIC, mp NUMERIC, fg NUMERIC, fga NUMERIC,
    fg_percent FLOAT, x3p NUMERIC, x3pa NUMERIC, x3p_percent FLOAT,
    x2p NUMERIC, x2pa NUMERIC, x2p_percent FLOAT, e_fg_percent FLOAT,
    ft NUMERIC, fta NUMERIC, ft_percent FLOAT, orb NUMERIC, drb NUMERIC,
    trb NUMERIC, ast NUMERIC, stl NUMERIC, blk NUMERIC, tov NUMERIC, pf NUMERIC, pts NUMERIC
);


\copy player_all FROM 'new_player_totals.csv' CSV HEADER;
ALTER TABLE player_info ADD PRIMARY KEY(seas_id);

CREATE TABLE player_all_clean
AS SELECT * FROM player_all WHERE season < 2024 and season > 1950;

--select player from player_all_clean where season = 2021 GROUP BY (season,player) HAVING count(*) > 1;

DELETE FROM player_all_clean WHERE tm != 'TOT' and player_id in (select player_id from player_all_clean GROUP BY (season,player_id) HAVING count(*) > 1);

--select player from player_all_clean where season = 2021 GROUP BY (season,player) HAVING count(*) > 1;


INSERT INTO player_info
SELECT seas_id,season,player_id,player,pos,age,experience,lg,tm 
FROM player_all_clean;

INSERT INTO player_stats
SELECT seas_id, player_id, player, g, 
    gs , mp , fg , fga ,
    fg_percent , x3p , x3pa , x3p_percent ,
    x2p , x2pa , x2p_percent , e_fg_percent ,
    ft , fta , ft_percent , orb , drb ,
    trb , ast , stl , blk , tov , pf , pts 
FROM player_all_clean;

-- Clean Salary
CREATE TABLE player_salaries (
    rank INT,
    name TEXT,
    season NUMERIC(4),
    salary MONEY,
    adjustedSalary MONEY
);

\copy player_salaries FROM 'salary.csv' CSV HEADER;


CREATE TABLE player_salaryInfo
AS SELECT seas_id,pi.season,player_id,player,sal.salary,sal.adjustedSalary,pos,age,experience,lg,tm
FROM player_info AS pi
JOIN player_salaries AS sal ON (pi.player,pi.season) = (sal.name,sal.season);

DROP TABLE IF EXISTS player_info;

--SELECT seas_id, player_id, player, salaries.salary, g, 
--    gs , mp , fg , fga ,
--    fg_percent , x3p , x3pa , x3p_percent ,
--    x2p , x2pa , x2p_percent , e_fg_percent ,
--    ft , fta , ft_percent , orb , drb ,
--    trb , ast , stl , blk , tov , pf , pts FROM player_stats AS stats JOIN player_salaries AS salaries ON stats.player = salaries.name;
