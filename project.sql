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
    fg_percent NUMERIC(4,3), x3p NUMERIC, x3pa NUMERIC, x3p_percent NUMERIC(4,3),
    x2p NUMERIC, x2pa NUMERIC, x2p_percent NUMERIC(4,3), e_fg_percent NUMERIC(4,3),
    ft NUMERIC, fta NUMERIC, ft_percent NUMERIC(4,3), orb NUMERIC, drb NUMERIC,
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
    fg_percent NUMERIC(4,3), x3p NUMERIC, x3pa NUMERIC, x3p_percent NUMERIC(4,3),
    x2p NUMERIC, x2pa NUMERIC, x2p_percent NUMERIC(4,3), e_fg_percent NUMERIC(4,3),
    ft NUMERIC, fta NUMERIC, ft_percent NUMERIC(4,3), orb NUMERIC, drb NUMERIC,
    trb NUMERIC, ast NUMERIC, stl NUMERIC, blk NUMERIC, tov NUMERIC, pf NUMERIC, pts NUMERIC
);


\copy player_all FROM 'new_player_totals.csv' CSV HEADER;
ALTER TABLE player_info ADD PRIMARY KEY(seas_id);

CREATE TABLE player_all_clean
AS SELECT * FROM player_all WHERE season < 2024 and season > 1950;

--select player from player_all_clean where season = 2021 GROUP BY (season,player) HAVING count(*) > 1;

DELETE FROM player_all_clean WHERE tm != 'TOT' and (season,player_id) in (select season,player_id from player_all_clean GROUP BY (season,player_id) HAVING count(*) > 1);

--select player from player_all_clean where season = 2021 GROUP BY (season,player) HAVING count(*) > 1;

DROP TABLE IF EXISTS player_reg;

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
    salary NUMERIC,
    adjustedSalary NUMERIC
);

\copy player_salaries FROM 'salary.csv' CSV HEADER;


CREATE TABLE player_salaryInfo
AS SELECT seas_id,pi.season,player_id,player,sal.salary,sal.adjustedSalary,pos,age,experience,lg,tm
FROM player_info AS pi
JOIN player_salaries AS sal ON (pi.player,pi.season) = (sal.name,sal.season);



CREATE TABLE player_reg 
AS SELECT pi.seas_id,pi.season,pi.player,pi.adjustedsalary::MONEY,
(9.5 * ps.pts * POWER(10,3) + 1.066 * ps.ast * POWER(10,4) - 1.54 * ps.orb * POWER(10,4) + 2.085*ps.drb*POWER(10,4) - 3.543 * ps.stl * POWER(10,4) + 7.01 * ps.gs * POWER(10,4) + 6.738 * pi.experience * POWER(10,5) - 6.223 * ps.mp * POWER(10,3) + ps.fg_percent * -1.686 * POWER(10,7) + 5.192 * POWER(10,6)*ps.x2p_percent + 1.34 * POWER(10,7) * ps.e_fg_percent ) AS predSal,
(pi.adjustedsalary - (9.5 * ps.pts * POWER(10,3) + 1.066 * ps.ast * POWER(10,4) - 1.54 * ps.orb * POWER(10,4) + 2.085*ps.drb*POWER(10,4) - 3.543 * ps.stl * POWER(10,4) + 7.01 * ps.gs * POWER(10,4) + 6.738 * pi.experience * POWER(10,5) - 6.223 * ps.mp * POWER(10,3) + ps.fg_percent * -1.686 * POWER(10,7) + 5.192 * POWER(10,6)*ps.x2p_percent + 1.34 * POWER(10,7) * ps.e_fg_percent) ) AS residual
FROM player_salaryinfo as pi
JOIN player_stats as ps on (pi.seas_id = ps.seas_id);


DROP TABLE IF EXISTS player_info;
ALTER TABLE f23_group14.player_reg OWNER to f23_group14;
ALTER TABLE f23_group14.player_stats OWNER to f23_group14;
ALTER TABLE f23_group14.player_salaryinfo OWNER to f23_group14;
--SELECT seas_id, player_id, player, salaries.salary, g, 
--    gs , mp , fg , fga ,
--    fg_percent , x3p , x3pa , x3p_percent ,
--    x2p , x2pa , x2p_percent , e_fg_percent ,
--    ft , fta , ft_percent , orb , drb ,
--    trb , ast , stl , blk , tov , pf , pts FROM player_stats AS stats JOIN player_salaries AS salaries ON stats.player = salaries.name;
