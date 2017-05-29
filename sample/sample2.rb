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
                        "password"=> ARGV[4]
                      })
  
  #Create TimeSeries 
  ts = gridstore.put_container("point01", [
                        {"timestamp"=> Griddb::GS_TYPE_TIMESTAMP},
                        {"active"=> Griddb::GS_TYPE_BOOL},
                        {"voltage"=> Griddb::GS_TYPE_DOUBLE},                        
                          ], Griddb::GS_CONTAINER_TIME_SERIES)
  
  #Create and set row data  
  row = ts.create_row()
  row.set_field_by_timestamp(0, Griddb::Timestamp.current())
  row.set_field_by_bool(1, false)
  row.set_field_by_double(2, 100)
  
  #Put row to timeseries with current timestamp
  update = false
  ts.put_row(row)

  #Create normal query for range of timestamp from 6 hours ago to now
  query = ts.query("select * where timestamp > TIMESTAMPADD(HOUR, NOW(), -6)")
  rs = query.fetch(update)
  
  #Get result
  rrow = ts.create_row()
  while rs.has_next()
    rs.get_next(rrow)
    timestamp = rrow.get_field_as_timestamp(0)
    active = rrow.get_field_as_bool(1)
    voltage = rrow.get_field_as_double(2)
    print "Time=#{timestamp} Active=#{active} Voltage=#{voltage}\n"
  end
rescue Griddb::GSException => e
  print "#{e.what()}\n"
end
