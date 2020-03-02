DROP TABLE IF EXISTS btcusd;

CREATE TABLE `btcusd` (
  `date` date NOT NULL,
  `price` decimal(20,8) NOT NULL,
  `open` decimal(20,8) NOT NULL,
  `high` decimal(20,8) NOT NULL,
  `low` decimal(20,8) NOT NULL,
  `volume` varchar(20) NOT NULL,
  `changepercent` varchar(45) NOT NULL,
  PRIMARY KEY (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



LOAD DATA INFILE '/var/lib/mysql-files/BTC_USD.csv'
INTO TABLE btcusd
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 3 ROWS
(@date,price,open,high,low,volume,changepercent)
SET date = STR_TO_DATE(@date, '%b %d, %Y');
