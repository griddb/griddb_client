#!/usr/bin/python

import griddb_python_client
import sys
griddb = griddb_python_client

factory = griddb.StoreFactory.get_default()

argv = sys.argv

blob = bytearray([65, 66, 67, 68, 69, 70, 71, 72, 73, 74])
update = True

try:
	#Get GridStore object
	gridstore = factory.get_store({
		            "notificationAddress": argv[1],
		            "notificationPort": argv[2],
		            "clusterName": argv[3],
		            "user": argv[4],
		            "password": argv[5]
	            })
	
	#Create Collection 
	col = gridstore.put_container("col01", [
		            ("name", griddb.GS_TYPE_STRING),
		            ("status", griddb.GS_TYPE_BOOL),
		            ("count", griddb.GS_TYPE_LONG),	        
		            ("lob", griddb.GS_TYPE_BLOB)]
					, griddb.GS_CONTAINER_COLLECTION)
	
	#Change auto commit mode to false
	col.set_auto_commit(False)
	
	#Set an index on the Row-key Column
	col.create_index("name",griddb.GS_INDEX_FLAG_DEFAULT)
	
	#Set an index on the Column
	col.create_index("count",griddb.GS_INDEX_FLAG_DEFAULT)
	
	#Create and set row data
	row = col.create_row() #Create row for refer
	row.set_field_by_string(0, "name01")
	row.set_field_by_bool(1, False)
	row.set_field_by_long(2, 1)
	row.set_field_by_blob(3, blob)
	
	#Put row: RowKey is "name01"
	ret = col.put_row(row)
	row2 = col.create_row() #Create row for refer
	col.get_row_by_string("name01", True, row2) #Get row with RowKey "name01"
	col.delete_row_by_string("name01") #Remove row with RowKey "name01"
	
	#Put row: RowKey is "name02"
	col.put_row_by_string("name02", row)
	col.commit();
	
	#Create normal query
	query=col.query("select * where name = 'name02'")
	
	#Execute query
	rrow = col.create_row()
	rs = query.fetch(update)
	while rs.has_next():
		rs.get_next(rrow)

		name = rrow.get_field_as_string(0)
		status = rrow.get_field_as_bool(1)
		count = rrow.get_field_as_long(2) + 1
		lob = rrow.get_field_as_blob(3)
		print("Person: name={0} status={1} count={2} lob=[{3}]".format(name, status, count, ', '.join(str(e) for e in lob)))
		
		#Update row
		rrow.set_field_by_long(2, count)
		rs.update_current(rrow)
		
	#End transaction
	col.commit()
except griddb.GSException as e:
	print(e.what())
