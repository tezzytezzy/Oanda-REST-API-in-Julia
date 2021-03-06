# Oanda-REST-API-in-Julia
How to use REST API with curl in Julia to retrieve market data from Oanda:

First of all, make sure to add the following packages:
```julia
    (v1.0) pkg> status
        Status `~/.julia/environments/v1.0/Project.toml`
      [a93c6f00] DataFrames v0.15.2
      [cd3eb016] HTTP v0.7.1
      [682c06a0] JSON v0.20.0
      [91a5bcdd] Plots v0.22.0
      [f3b207a7] StatsPlots v0.10.1
```
Load the packages next:
```julia
    using Plots
    using DataFrames
    using HTTP
    using JSON
```

1. [Get Current Price](https://github.com/tezzytezzy/Oanda-REST-API-in-Julia#get-current-price)
2. [Get Streaming Price](https://github.com/tezzytezzy/Oanda-REST-API-in-Julia#get-streaming-pricestill-in-dev)
3. [Get Historical Price](https://github.com/tezzytezzy/Oanda-REST-API-in-Julia#get-historical-price)
4. [Plot OHLC Chart](https://github.com/tezzytezzy/Oanda-REST-API-in-Julia#plot-ohlc-chart)
5. [2D Histogram](https://github.com/tezzytezzy/Oanda-REST-API-in-Julia#2d-histogram)
6. [Seasonality Chart](https://github.com/tezzytezzy/Oanda-REST-API-in-Julia#seasonality-chart)
                        
Get Current Price
-----------------
```julia
    instrument = "EUR_USD"
    account_id = "123-456-7890123-456"
    api_key = "9r32rjijfiewjfoihfoi3u9439243294329432-094328hhrfiehfiheip81724jhfd"
    url = string("https://api-fxpractice.oanda.com/v3/accounts/", account_id, "/pricing?instruments=", instrument)
    
    r = HTTP.request(
       "GET",
       url,
       ["Accept" => "application/json",
        "Content-Type" => "application/json",
        "Authorization" => string("Bearer ", api_key)]
        )
    res = r.body

    #The body of a request or response can be cast to a string - as below.
    #Or, you can read and write bytes off of the stream as needed.
    res_in_string = String(res)

    #JSON converts string by curl response to a dictionary object
    data_in_dict = JSON.parse(res_in_string)

    #JSON returns a dictionary of dictionaries. Use [1] to get to one level inside the dictionary
    instrument_code = data_in_dict["prices"][1]["instrument"]
    bid = data_in_dict["prices"][1]["closeoutBid"]
    ask = data_in_dict["prices"][1]["closeoutAsk"]

    println("Code: ", instrument_code, "\nBid: ", bid, "\nAsk: ", ask)
```

Upon execution of HTTP.request() above, REPL should output as follows:
```julia
    HTTP.Messages.Response:
    """
    HTTP/1.1 200 OK
    Access-Control-Allow-Headers: Authorization, Content-Type, Accept-Datetime-Format, OANDA-Agent, ETag
    Access-Control-Allow-Methods: PUT, PATCH, POST, GET, OPTIONS, DELETE
    Access-Control-Allow-Origin: *
    Access-Control-Expose-Headers: ETag, RequestID
    Content-Length: 615
    Content-Type: application/json
    RequestID: 42521523389037367

    {"time":"2019-01-20T12:16:35.196239906Z","prices":[{"type":"PRICE","time":"2019-01-18T21:59:58.547847843Z","bids":[{"price":"1.13582","liquidity":10000000}],"asks":[{"price":"1.13659","liquidity":10000000}],"closeoutBid":"1.13567","closeoutAsk":"1.13674","status":"non-tradeable","tradeable":false,"unitsAvailable":{"default":{"long":"3238866","short":"3238866"},"openOnly":{"long":"3238866","short":"3238866"},"reduceFirst":{"long":"3238866","short":"3238866"},"reduceOnly":{"long":"0","short":"0"}},"quoteHomeConversionFactors":{"positiveUnits":"1.35769000","negativeUnits":"1.35969000"},"instrument":"EUR_USD"}]}"""
```

Get Streaming Price(still in dev)
---------------------------------
```julia
    instrument = "EUR_USD"
    account_id = "123-456-7890123-456"
    api_key = "9r32rjijfiewjfoihfoi3u9439243294329432-094328hhrfiehfiheip81724jhfd"
    url = string("https://stream-fxpractice.oanda.com/v3/accounts/", account_id, "/pricing/stream?instruments=", instrument)

    r = HTTP.request(
       "GET",
       url,
       ["Accept" => "application/json",
        "Content-Type" => "application/json",
        "Authorization" => string("Bearer ", api_key) ]
        )
    response = r.body
```


Get Historical Price
--------------------
```julia
    #The following code utilises Oanda V1 API, which will be officially deprecated soon
    #You don't need account_id and api_key
    
    instrument = "EUR_USD"
    
    #With count paramter of 5000 and daily ("D") data  (NO start or end date to be included!) 
    url = string("https://api-fxpractice.oanda.com/v1/candles?granularity=D&count=5000&instrument=", instrument)

    #Or, pass start and end dates
    #"%3A" means ":" in accordance with the ISO 8601 (UTC) format
    startdate = "2011-01-02T15%3A47%3A40Z"
    enddate = "2019-02-14T15%3A47%3A50Z"
    url = string("https://api-fxpractice.oanda.com/v1/candles?granularity=D&instrument=", instrument, "&start=", startdate, "&end=", enddate)

    r = HTTP.request(
      "GET",
      url,
      ["Accept" => "application/json",
       "Content-Type" => "application/json"]
      )
      
    response = r.body
    data = JSON.parse(String(response))
    
    #Convert every single array into an instance of Dataframe and then concatenate each one of them with "vcat"
    df = vcat(DataFrame.(data["candles"])...)
```

The resultant DataFrame, df, should be as follows (how columns are nicely sorted in an alphabetical order!):
```julia
    julia> df
    5000×11 DataFrame
    │ Row  │ closeAsk │ closeBid │ complete │ highAsk │ highBid │ lowAsk  │ lowBid  │ openAsk │ openBid │ time                        │ volume │
    │      │ Float64  │ Float64  │ Bool     │ Float64 │ Float64 │ Float64 │ Float64 │ Float64 │ Float64 │ String                      │ Int64  │
    ├──────┼──────────┼──────────┼──────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────────────────────────┼────────┤
    │ 1    │ 1.0094   │ 1.0092   │ true     │ 1.0094  │ 1.0092  │ 1.0094  │ 1.0092  │ 1.0094  │ 1.0092  │ 2002-11-06T22:00:00.000000Z │ 1      │
    │ 2    │ 1.0135   │ 1.0125   │ true     │ 1.0135  │ 1.0125  │ 1.0135  │ 1.0125  │ 1.0135  │ 1.0125  │ 2002-11-07T22:00:00.000000Z │ 1      │
    ⋮
    │ 4998 │ 1.15012  │ 1.14993  │ true     │ 1.15709 │ 1.15694 │ 1.14853 │ 1.14839 │ 1.15436 │ 1.15404 │ 2019-01-09T22:00:00.000000Z │ 32717  │
    │ 4999 │ 1.14737  │ 1.14637  │ true     │ 1.15418 │ 1.15399 │ 1.14588 │ 1.14575 │ 1.15008 │ 1.14984 │ 2019-01-10T22:00:00.000000Z │ 31499  │
    │ 5000 │ 1.1467   │ 1.14657  │ false    │ 1.14827 │ 1.14814 │ 1.14514 │ 1.14501 │ 1.14659 │ 1.14559 │ 2019-01-13T22:00:00.000000Z │ 11729  │
```

Plot OHLC Chart
---------------
```julia
    #Load GR backend of Plots (GR is its default)
    gr()
    
    # Use comprehension to add each datapoint to OHLC type
    y = OHLC[(df[i, :openAsk], df[i, :highAsk], df[i, :lowAsk], df[i, :closeAsk]) for i = 1:nrow(df)]
    
    title!("EUR_USD")

    graph = ohlc(y)

    #All output is suppressed when running from a file, one needs to "explicitly" display by command
    #I have tried the following methods each, but none of them seems to work on Atom IDE Plot window...
    display(graph)
    gui(graph)
    show = true
```
2D Histogram
------------
Interesting observation between Open and Close Bids from the 5000 sample data? Let's find out.

```julia
    using StatsPlots
    
    #closeBid in X-Axis and openBid in Y-Axis
    histogram2d(df[:, :closeBid], df[:, :openBid], nbins=25)
    
    xaxis!("CloseBid")
    yaxis!("OpenBid")    
```
![](test.png)

Seasonality Chart
------------
My favourite visual to see any yearly seasonal patterns over the years

```julia
    using StatsPlots, Dates
    
    #Extract "YYYY-MM-DD" in date format, using broadcasting
    d = Date.(first.(df.time, 10))

    #Dynamically add a new column, named "day", to the df DataFrame with day count nubmer in the column
    #@. denotes every single operation involves broadcasting
    #Align day of the year by adding 1 (true) to days in February onwards for a non-leap year  
    df.day = @. dayofyear(d) + ((!isleapyear(d)) & (month(d) > 2))

    #Add year column for grouping later on
    df.year = year.(d)
    
    #Use @df macro to take in DataFrame (Plots cannot!) to multi-line chart, grouping by year
    @df df plot(:day, :closeBid, group=:year)
    
    xaxis!("N-th day of the year")
    title!("EURUSD")
```
![](seasonality2.png)

