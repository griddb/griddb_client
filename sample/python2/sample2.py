#!/usr/bin/python

import griddb_python_client
import sys
griddb = griddb_python_client

factory = griddb.StoreFactory.get_default()

argv = sys.argv

update = False

try:
	#Get GridStore object
	gridstore = factory.get_store({
		            "notificationAddress": argv[1],
		            "notificationPort": argv[2],
		            "clusterName": argv[3],
		            "user": argv[4],
		            "password": argv[5]
	            })
	
	#Create TimeSeries
	ts = gridstore.put_container("point01", [
		            ("timestamp", griddb.GS_TYPE_TIMESTAMP),
		            ("active", griddb.GS_TYPE_BOOL),	        
		            ("voltage", griddb.GS_TYPE_DOUBLE)]
					, griddb.GS_CONTAINER_TIME_SERIES)

	#Create and set row data	
	row = ts.create_row()
	row.set_field_by_timestamp(0, griddb.Timestamp.current())
	row.set_field_by_bool(1, False)
	row.set_field_by_double(2, 100)
	
	#Put row to timeseries with current timestamp
	ts.put_row(row)

	#Create normal query for range of timestamp from 6 hours ago to now
	query = ts.query("select * where timestamp > TIMESTAMPADD(HOUR, NOW(), -6)")
	rs = query.fetch(update)
	
	#Get result
	rrow = ts.create_row()
	while rs.has_next():
		rs.get_next(rrow)
		timestamp = rrow.get_field_as_timestamp(0)
		active = rrow.get_field_as_bool(1)
		voltage = rrow.get_field_as_double(2)
		print "Time={0} Active={1} Voltage={2}".format(timestamp, active, voltage)

except griddb.GSException as e:
		print e.what()