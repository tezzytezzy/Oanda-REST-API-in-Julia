using Plots
using DataFrames
using HTTP
using JSON


function get_current_price()
   #REFERENCE: https://developer.oanda.com/rest-live-v20/pricing-ep/#CurrentPrices
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

   #The body of a request or response can be cast to a string - as below - or you can read and write bytes off of the stream as needed.
   res_in_string = String(res)

   #JSON converts string by curl response to a dictionary object
   data_in_dict = JSON.parse(res_in_string)

   #JSON returns a dictionary of dictionaries. Use [1] to get to the one-level further in the dictionary
   instrument_code = data_in_dict["prices"][1]["instrument"]
   bid = data_in_dict["prices"][1]["closeoutBid"]
   ask = data_in_dict["prices"][1]["closeoutAsk"]

   println("Code: ", instrument_code, "\nBid: ", bid, "\nAsk: ", ask)
end


function get_historical_data()
   #REFERENCE: http://developer.oanda.com/rest-live/rates/#retrieveInstrumentHistory
   # THIS IS V1 AND SHOULD HAVE BEEN ALREADY DEPRICATED???

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
end


function get_stream_pricing()
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
end
