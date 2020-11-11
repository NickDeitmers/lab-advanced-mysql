USE publications;
SET SQL_SAFE_UPDATES = 0;

SELECT * FROM sales;

-- CHALLENGE 1

SELECT 
	title_id,
	au_id,
    advance + total_royalty as profit
FROM
(SELECT 
	title_id,
    au_id,
    sum(sales_royalty) as total_royalty,
    advance
FROM (
SELECT 
	ta.title_id, 
	ta.au_id, 
    round(t.advance * ta.royaltyper / 100) as advance,
    round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) as sales_royalty
FROM 
titleauthor as ta
LEFT JOIN
titles as t
ON ta.title_id = t.title_id
LEFT JOIN
sales as s
ON ta.title_id = s.title_id) as step1
GROUP BY title_id, au_id) as step2
ORDER BY profit DESC
LIMIT 3;


-- CHALLENGE 2
-- STEP 1
DROP TABLE IF EXISTS step1;
CREATE TEMPORARY TABLE step1
SELECT 
	ta.title_id, 
	ta.au_id, 
    round(t.advance * ta.royaltyper / 100) as advance,
    round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) as sales_royalty
FROM 
titleauthor as ta
LEFT JOIN
titles as t
ON ta.title_id = t.title_id
LEFT JOIN
sales as s
ON ta.title_id = s.title_id;

SELECT * FROM step1;

-- STEP 2
DROP TABLE IF EXISTS step2;
CREATE TEMPORARY TABLE step2
SELECT title_id, au_id, sum(sales_royalty) as total_royalty
FROM step1
GROUP BY title_id, au_id;

SELECT * FROM step2;

-- STEP 3
CREATE TEMPORARY TABLE step3
SELECT 
	s1.au_id,
    sum(s2.total_royalty + s1.advance) as profit
FROM step1 as s1
INNER JOIN
step2 as s2
ON s1.au_id = s2.au_id
GROUP BY au_id
ORDER BY profit DESC
LIMIT 3;

SELECT * FROM step3;

-- CHALLENGE 3
CREATE TABLE most_profiting_authors (
	id int auto_increment,
    au_id varchar(255),
    profits int,
    PRIMARY KEY (id)
);

INSERT INTO most_profiting_authors (au_id, profits)
SELECT au_id, profit
FROM step3;

SELECT * FROM most_profiting_authors;