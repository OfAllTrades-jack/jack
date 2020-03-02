# Notes: 
- Earliest rate date is hardcoded to 2011-05-30. Change as necessary.
- SEK is used as target fiat. Dates lacking SEK rates against EUR and USD will use the latest available rate at the time of the trade (I.e. If a trade happens before RIKSBANKEN sets a new fixing rate around noon (programmatically hardcoded to 12:00:00), the latest known rate is being used for calculating the cumulative average cost of acquiring each cryptocurrency or fiat, as well as sales price of respective currency).

1. Collect csv data
2. Import csv data into tables
3. Run createRate.sql to consolidate rate data

