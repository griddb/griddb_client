#!/usr/bin/python

import griddb_python_client
import sys
griddb = griddb_python_client

factory = griddb.StoreFactory.get_default()

argv = sys.argv

update = False #No lock for update

try:
	#Get GridStore object
	gridstore = factory.get_store({
		            "notificationAddress": argv[1],
		            "notificationPort": argv[2],
		            "clusterName": argv[3],
		            "user": argv[4],
		            "password": argv[5],
                    "consistency": "EVENTUAL"
	            })
	
	#Get TimeSeries
	#Reuse TimeSeries and data from sample 2
	ts = gridstore.get_container("point01")
	
	#Create normal query to get all row where active = FAlSE and voltage > 50
	query = ts.query("select * from point01 where not active and voltage > 50")
	rs = query.fetch(update) 
	
	#Get result
	rrow = ts.create_row()
	while rs.has_next():
		rs.get_next(rrow)
		timestamp = rrow.get_field_as_timestamp(0)
		
		#Perform aggregation query to get average value 
		#during 10 minutes later and 10 minutes earlier from this point
		aggCommand = "select AVG(voltage) from point01 where timestamp > TIMESTAMPADD(MINUTE, TO_TIMESTAMP_MS({0}), -10) AND timestamp < TIMESTAMPADD(MINUTE, TO_TIMESTAMP_MS({1}), 10)".format(timestamp, timestamp)
		aggQuery = ts.query(aggCommand) 
		aggRs = aggQuery.fetch(update)
		while aggRs.has_next():
			#Get aggregation result
			aggResult = aggRs.get_next_aggregation()
			#Convert result to double and print out
			print "[Timestamp={0}] Average voltage = {1}".format(timestamp, aggResult.get_double())
	
except griddb.GSException as e:
	print e.what()