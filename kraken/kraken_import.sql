DROP TABLE IF EXISTS krakentemp;

CREATE TABLE `krakentemp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  prevTokenId int(11) DEFAULT NULL,
  txId varchar(30) DEFAULT NULL,
  refId varchar(30) NOT NULL,
  `time` datetime NOT NULL,
  `type` varchar(20) NOT NULL,
  `asset` varchar(20) NOT NULL,
  `action` varchar(20) NOT NULL DEFAULT 'Undefined',
  inBalance decimal(20,10) default null,
  amountLessFee decimal(20,10),
  `amount` decimal(22,10) NOT NULL,
  `fee` decimal(22,10) NOT NULL,
  `balance` decimal(22,10) DEFAULT NULL,
  `baseToken` varchar(20) default NULL,
  `baseTotal` decimal(22,10) DEFAULT NULL,
  `feePercentage` decimal(22,10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY(txId,refId)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;



LOAD DATA INFILE '/var/lib/mysql-files/kraken.csv'
INTO TABLE krakentemp
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 3 ROWS
(@txid,@refid,@time,@type,@aclass,@asset,@amount,@fee,@balance)
SET time = STR_TO_DATE(@time, '%Y-%m-%d %H:%i:%s'),
	txId = NULLIF(@txid,''), refId = NULLIF(@refid,''),
    type = NULLIF(@type,''),
	asset = NULLIF(@asset,''), amount = NULLIF(@amount,''), 
    fee = NULLIF(@fee,''), balance = NULLIF(@balance,'');
commit;

UPDATE krakentemp LEFT JOIN
    (SELECT 
        year,
            ADDTIME(ADDDATE(LAST_DAY(DATE(CONCAT(year, '-03-01'))), - MOD(1 + WEEKDAY(LAST_DAY(DATE(CONCAT(year, '-03-01')))), 7)), '01:00:00') lastSundayOfMarchAt1AM,
            ADDTIME(ADDDATE(LAST_DAY(DATE(CONCAT(year, '-10-01'))), - MOD(1 + WEEKDAY(LAST_DAY(DATE(CONCAT(year, '-10-01')))), 7)), '01:00:00') lastSundayOfOctoberAt1AM
    FROM
        (SELECT DISTINCT
        YEAR(time) year
    FROM
        krakentemp) a) b on b.year=YEAR(krakentemp.time)
SET time = (CASE WHEN time>=lastSundayOfMarchAt1AM and time<lastSundayOfOctoberAt1AM
				THEN addtime(time,'02:00:00')
                ELSE addtime(time,'01:00:00')
			END);

SET @token:='';
SET @prevTokenId:=0;
UPDATE krakentemp
	SET prevTokenId = (
		CASE
			WHEN @token=asset THEN @prevTokenId + (0*(@prevTokenId:=id))
            ELSE NULLIF(0*( (@token:=asset) || (@prevTokenId:=id)),0)
		END
    )
WHERE id>0 AND balance is not null
ORDER BY asset,id;
commit;

UPDATE krakentemp a left join krakentemp b on b.id=a.prevTokenId
SET a.inBalance = IFNULL(b.balance,0)
WHERE a.id>0 and a.balance is not null;
commit;
    
UPDATE krakentemp
SET asset = (CASE 
				WHEN asset='XXBT' THEN 'BTC'
                WHEN asset='ZEUR' THEN 'EUR'
                WHEN asset='XXDG' THEN 'DOGE'
                WHEN asset='XETH' THEN 'ETH'
                ELSE asset
			END)
WHERE id >0;
commit;

UPDATE krakentemp
SET action = (CASE 
				WHEN amount<0 THEN 'Sell'
                WHEN amount>0 THEN 'Buy'
                ELSE NULL
			END)
WHERE id >0 and (type='trade');
commit;

UPDATE krakentemp
SET amountLessFee = amount-fee
WHERE id>0 AND inBalance is not null;
commit;

UPDATE krakentemp a
        LEFT JOIN
    krakentemp b ON b.refId = a.refId
        AND (
				(b.asset NOT IN ('BTC' , 'EUR') )
				OR 
                (a.asset='EUR' AND b.asset='BTC')
            )
SET 
    a.baseToken = a.asset,
    b.baseToken = a.asset,
    a.baseTotal = (CASE
        WHEN a.action = 'Buy' THEN a.amount
        WHEN a.action = 'Sell' THEN ABS(a.amountLessFee)
    END),
    b.baseTotal = (CASE
        WHEN b.action = 'Buy' THEN ABS(a.amountLessFee)
        WHEN b.action = 'Sell' THEN a.amount
    END),
    a.feePercentage = (CASE
			WHEN a.action = 'Sell' THEN ROUND((a.fee/abs(a.amountLessFee))+(b.fee/abs(b.amount)) ,10)
            ELSE NULL
    END),
    b.feePercentage = (CASE 
			WHEN b.action = 'Sell' THEN ROUND((a.fee/abs(a.amount))+(b.fee/abs(b.amountLessFee)),10)
            ELSE NULL
    END)
WHERE
    a.id > 0
        AND a.inBalance IS NOT NULL
        AND a.asset IN ('BTC' , 'EUR');
commit; 

SELECT * FROM krakentemp where inBalance+amountLessFee<>balance order by id ;

DROP TABLE IF EXISTS unitedkraken;

CREATE TABLE `unitedkraken` (
	id int(11) not null auto_increment,
  `time` datetime NOT NULL,
  `venue` varchar(10) DEFAULT 'kraken',
  `orderNumber` varchar(50) NOT NULL,
  `token` varchar(20) NOT NULL,
  `action` varchar(20) NOT NULL,
  `amountChange` decimal(22,10) NOT NULL,
  `baseToken` varchar(20) NOT NULL,
  `baseTotal` decimal(22,10) NOT NULL,
  `fee` decimal(22,10) NOT NULL ,
  usedInTax boolean NOT NULL,
  useInTax boolean not null,
  `comment` varchar(50) default '',
  primary key(id)
) ENGINE=InnoDB auto_increment=1 DEFAULT CHARSET=utf8;

INSERT INTO `jack`.`unitedkraken`
(`time`,`orderNumber`,`token`,`action`,`amountChange`,
`baseToken`,`baseTotal`,`fee`,`usedInTax`,`useInTax`)
SELECT
    `krakentemp`.`time`,`krakentemp`.`refId`,`krakentemp`.`asset`,
    `krakentemp`.`action`,`krakentemp`.`amountLessFee`,`krakentemp`.`baseToken`,
    `krakentemp`.`baseTotal`,IFNULL(`krakentemp`.`feePercentage`,0),false,true
    FROM `jack`.`krakentemp` LEFT JOIN (SELECT refId,count(refId) refIdCount FROM krakentemp group by refId ) k2 on k2.refId=krakentemp.refId
WHERE action in ('Buy','Sell') and k2.refIdCount=2 order by id;

DROP TABLE IF EXISTS krakentemp;
