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
4. [Plot OHLC chart](https://github.com/tezzytezzy/Oanda-REST-API-in-Julia#plot-ohlc-chart)

                        
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

    instrument = "EUR_USD"
    account_id = "123-456-7890123-456"
    api_key = "9r32rjijfiewjfoihfoi3u9439243294329432-094328hhrfiehfiheip81724jhfd"
    
    #With count paramter of 5000 and daily ("D") data  (NO start or end date to be included!) 
    url = string("https://api-fxpractice.oanda.com/v1/candles?instrument=", instrument, "&granularity=D&count=5000"

    r = HTTP.request(
      "GET",
      url,
      ["Accept" => "application/json",
       "Content-Type" => "application/json",
       "Authorization" => string("Bearer ", api_key) ]
       )
    response = r.body
    data = JSON.parse(String(response))
    
    #Convert every single array into an instance of Dataframe and then concatenate each one of them with "vcat"
    #Without the splat (...), a warning gets generated, but it executes without a failure
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

Plot OHLC chart
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

Any relationsihp between Open and Close Bids???
---------------
Interesting observation from the 5000 sample data? Let's find out.

```julia
    #closeBid in X-Axis and openBid in Y-Axis
    histogram2d(df[:, :closeBid], df[:, :openBid], nbins=25)
    
    xaxis!("CloseBid")
    yaxis!("OpenBid")    
```



