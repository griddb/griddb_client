#!/bin/env ruby

$:.unshift File.dirname(__FILE__)
require 'griddb_ruby_client'
Griddb = Griddb_ruby_client

begin
  factory = Griddb::StoreFactory.get_default()
  
  #Get GridStore object
  gridstore = factory.get_store({
                        "notificationAddress"=> ARGV[0],
                        "notificationPort"=> ARGV[1],
                        "clusterName"=> ARGV[2],
                        "user"=> ARGV[3],
                        "password"=> ARGV[4],
                        "consistency"=> "EVENTUAL"
                      })
  
  #Get TimeSeries
  #Reuse TimeSeries and data from sample 2
  ts = gridstore.get_container("point01")
  
  #Create normal query to get all row where active = FAlSE and voltage > 50
  update = false #No lock for update
  query = ts.query("select * from point01 where not active and voltage > 50")
  rs = query.fetch(update) 
  
  #Get result
  rrow = ts.create_row()
  while rs.has_next()
    rs.get_next(rrow)
    timestamp = rrow.get_field_as_timestamp(0)
    
    #Perform aggregation query to get average value 
    #during 10 minutes later and 10 minutes earlier from this point
    aggCommand = "select AVG(voltage) from point01 where timestamp > TIMESTAMPADD(MINUTE, TO_TIMESTAMP_MS(#{timestamp}), -10) AND timestamp < TIMESTAMPADD(MINUTE, TO_TIMESTAMP_MS(#{timestamp}), 10)"
    aggQuery = ts.query(aggCommand) 
    aggRs = aggQuery.fetch(update)
    while aggRs.has_next()
      #Get aggregation result
      aggResult = aggRs.get_next_aggregation()
      #Convert result to double and print out
      print "[Timestamp=#{timestamp}] Average voltage = #{aggResult.get_double()}\n"
    end
  end
rescue Griddb::GSException => e
  print "#{e.what()}\n"
end
