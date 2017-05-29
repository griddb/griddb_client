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
  
  #Create Collection 
  col = gridstore.put_container("col01", [
                        {"name"=> Griddb::GS_TYPE_STRING},
                        {"status"=> Griddb::GS_TYPE_BOOL},
                        {"count"=> Griddb::GS_TYPE_LONG},
                        {"lob"=> Griddb::GS_TYPE_BLOB},
                          ], Griddb::GS_CONTAINER_COLLECTION)
  
  #Change auto commit mode to false
  col.set_auto_commit(false)
  
  #Set an index on the Row-key Column
  col.create_index("name",Griddb::GS_INDEX_FLAG_DEFAULT)
  
  #Set an index on the Column
  col.create_index("count",Griddb::GS_INDEX_FLAG_DEFAULT)
  
  #Create and set row data
  blob = [65, 66, 67, 68, 69, 70, 71, 72, 73, 74].pack("U*")
  row = col.create_row() #Create row for refer
  row.set_field_by_string(0, "name01")
  row.set_field_by_bool(1, false)
  row.set_field_by_long(2, 1)
  row.set_field_by_blob(3, blob)
  
  #Put row: RowKey is "name01"
  update = true
  ret = col.put_row(row)
  row2 = col.create_row() #Create row for refer
  col.get_row_by_string("name01", true, row2) #Get row with RowKey "name01"
  col.delete_row_by_string("name01") #Remove row with RowKey "name01"
  
  #Put row: RowKey is "name02"
  col.put_row_by_string("name02", row)
  col.commit()
  
  #Create normal query
  query=col.query("select * where name = 'name02'")
  
  #Execute query
  rrow = col.create_row()
  rs = query.fetch(update)
  while rs.has_next()
    rs.get_next(rrow)
    
    name = rrow.get_field_as_string(0)
    status = rrow.get_field_as_bool(1)
    count = rrow.get_field_as_long(2) + 1
    lob = rrow.get_field_as_blob(3)
    print "Person: name=#{name} status=#{status} count=#{count} lob="
    p lob.unpack("U*")
    
    #Update row
    rrow.set_field_by_long(2, count)
    rs.update_current(rrow)
  end
  #End transaction
  col.commit()
rescue Griddb::GSException => e
  print "#{e.what()}\n"
end
