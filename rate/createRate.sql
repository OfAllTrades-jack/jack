CREATE PROCEDURE `createRate`()
BEGIN
DROP TABLE IF EXISTS rate;
SET @sekeur = 0.0;
SET @sekusd = 0.0;
CREATE TABLE rate (
  `date` date NOT NULL,
  `btcusd` decimal(20,8) DEFAULT NULL,
  `ethusd` decimal(20,8) DEFAULT NULL,
  `sekeur` decimal(6,4) DEFAULT NULL,
  `sekusd` decimal(6,4) DEFAULT NULL,
  PRIMARY KEY (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AS (
	
SELECT date,btcusd,ethusd,
(CASE WHEN sekeur is null 
THEN (CASE WHEN @sekeur=0.0 THEN NULL ELSE @sekeur END)
ELSE @sekeur:=sekeur END) sekeur,
(CASE WHEN sekusd is null 
THEN (CASE WHEN @sekusd=0.0 THEN NULL ELSE @sekusd END)
ELSE @sekusd:=sekusd END) sekusd FROM (
SELECT 
        CAST(`v`.`date` AS DATE) AS `date`,
        `jack`.`sekusd`.`price` AS `sekusd`,
        `jack`.`btcusd`.`price` AS `btcusd`,
        `jack`.`sekeur`.`price` AS `sekeur`,
        `jack`.`ethusd`.`price` AS `ethusd`
    FROM
        ((((((SELECT 
            ('2011-05-30' + INTERVAL (((((`t4`.`i` * 10000) + (`t3`.`i` * 1000)) + (`t2`.`i` * 100)) + (`t1`.`i` * 10)) + `t0`.`i`) DAY) AS `date`
        FROM
            ((((((SELECT 0 AS `i`) UNION SELECT 1 AS `1` UNION SELECT 2 AS `2` UNION SELECT 3 AS `3` UNION SELECT 4 AS `4` UNION SELECT 5 AS `5` UNION SELECT 6 AS `6` UNION SELECT 7 AS `7` UNION SELECT 8 AS `8` UNION SELECT 9 AS `9`) `t0`
        JOIN (SELECT 0 AS `i` UNION SELECT 1 AS `1` UNION SELECT 2 AS `2` UNION SELECT 3 AS `3` UNION SELECT 4 AS `4` UNION SELECT 5 AS `5` UNION SELECT 6 AS `6` UNION SELECT 7 AS `7` UNION SELECT 8 AS `8` UNION SELECT 9 AS `9`) `t1`)
        JOIN (SELECT 0 AS `i` UNION SELECT 1 AS `1` UNION SELECT 2 AS `2` UNION SELECT 3 AS `3` UNION SELECT 4 AS `4` UNION SELECT 5 AS `5` UNION SELECT 6 AS `6` UNION SELECT 7 AS `7` UNION SELECT 8 AS `8` UNION SELECT 9 AS `9`) `t2`)
        JOIN (SELECT 0 AS `i` UNION SELECT 1 AS `1` UNION SELECT 2 AS `2` UNION SELECT 3 AS `3` UNION SELECT 4 AS `4` UNION SELECT 5 AS `5` UNION SELECT 6 AS `6` UNION SELECT 7 AS `7` UNION SELECT 8 AS `8` UNION SELECT 9 AS `9`) `t3`)
        JOIN (SELECT 0 AS `i` UNION SELECT 1 AS `1` UNION SELECT 2 AS `2` UNION SELECT 3 AS `3` UNION SELECT 4 AS `4` UNION SELECT 5 AS `5` UNION SELECT 6 AS `6` UNION SELECT 7 AS `7` UNION SELECT 8 AS `8` UNION SELECT 9 AS `9`) `t4`))) `v`
        LEFT JOIN `jack`.`btcusd` ON ((`jack`.`btcusd`.`date` = `v`.`date`)))
        LEFT JOIN `jack`.`ethusd` ON ((`jack`.`ethusd`.`date` = `v`.`date`)))
        LEFT JOIN `jack`.`sekeur` ON `jack`.`sekeur`.`date` = v.date)
        LEFT JOIN `jack`.`sekusd` ON `jack`.`sekusd`.`date` = v.date)
    WHERE
        (`v`.`date` BETWEEN '2011-05-30' AND CURDATE()))a
        order by date
);
END
