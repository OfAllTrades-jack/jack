DROP TABLE IF EXISTS sekeur;

CREATE TABLE sekeur (
  `date` date NOT NULL,
  `price` decimal(20,8) NOT NULL,
  PRIMARY KEY (`date`),
  INDEX idxDate(date)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;




LOAD DATA INFILE '/var/lib/mysql-files/SEK_EUR_RIKSBANKEN.csv'
INTO TABLE sekeur
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 3 ROWS
(@date,@info1,@info2,@price)
SET date = STR_TO_DATE(@date, '%Y-%m-%d'),
price=@price;
