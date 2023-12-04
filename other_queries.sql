-- get top 5 most paid
SELECT ps.player, ps.adjustedsalary, stats.pts 
FROM player_salaryinfo AS ps 
JOIN player_stats AS stats
ON ps.seas_id = stats.seas_id 
ORDER BY adjustedsalary DESC
LIMIT 5;

-- salary vs pts per game, trb (total rebounds) per game, ast (assists) per game

SELECT ps.player, SUM(ps.adjustedsalary), SUM(stats.pts) AS pts, SUM(stats.ast) AS ast, SUM(stats.trb) AS trb
FROM player_salaryinfo AS ps 
JOIN player_stats AS stats
ON ps.seas_id = stats.seas_id
GROUP BY ps.player, ps.adjustedsalary
ORDER BY ps.adjustedsalary DESC;

-- find most underpaid player for best stats from last year

SELECT ps.player, ps.adjustedsalary, stats.pts
FROM player_salaryinfo AS ps
JOIN player_stats AS stats
ON ps.seas_id = stats.seas_id
WHERE season = 2023
GROUP BY ps.player, ps.adjustedsalary, stats.pts
ORDER BY ps.adjustedsalary DESC, stats.pts ASC;


EXPLAIN ANALYZE SELECT ps.player, ps.adjustedsalary, stats.pts
FROM player_salaryinfo AS ps
JOIN player_stats AS stats
ON ps.seas_id = stats.seas_id
WHERE season = 2023
GROUP BY ps.player, ps.adjustedsalary, stats.pts
ORDER BY ps.adjustedsalary DESC, stats.pts ASC;

-- highest paid player per age

SELECT player, MAX(adjustedsalary) OVER(PARTITION BY player, age), age
FROM player_salaryinfo
GROUP BY age, player, adjustedsalary
ORDER BY age, adjustedsalary DESC;
