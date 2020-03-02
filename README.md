# jack
## United Cryptocurrency Trading Database

### DISCLAIMER: Use at own risk.

## Story: 
  - Trading cryptocurrencies implies income tax requirements.
  - By unifying transfer-data, trade-data and fiat-data from multiple sources, using double-entry book-keeping, we can provide a basis for:
    - proactive trade decisions
    - tax reports
    - identifying trade exchange inconsistencies
    
## Requirements:
  - Dates and times of consolidated trade data must account for daylight savings time as well as the user's timezone 
  - Trading data from each trading venue must be individually tested for balance inconsistencies 
  - There must be a means to add funds to accommodate for trades that otherwise would produce negative funds and, ultimately, a skewed end result (I.e. If one cannot show where funds came from, it effectively voids the tax dimension of this database).
  
    
## Prerequisites:
  - Personal bank statements showing buys and sells (for manual entry into csv-file)
  - Transfer-data and trade-data from trading venues (csv-files for automatic entry)
  - Historic fiat rates for the base currency of every applicable trade pair (csv-files for automatic entry)
  - Historic fiat rates for non-(EURO,USD) currencies (csv-files for automatic entry)
  - MySQL version 5.7
  - MySQL gui client, such as MySQL Workbench
  
## Procedure:
  - Collect and import rate data, consolidate into one table
  - Collect and import trade data (Kraken provided. Also have code for Poloniex, Mercatox, Shapeshift and AnycoinDirect.eu)
  - Unite trade data into one table. (Not provided here)
  - Consolidate trade data and rate data to produce cumulative cost of acquiry, sales and trading fees. (Not provided here)
  - Run predictive trade decision queries for managing tax-derived profits and losses in a controlled manner. (Not provided here)
  - Produce tax report grouped by year, currency, profit/loss. (Not provided here)
  - ???
  - Profit.
