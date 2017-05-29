/*
   Copyright (c) 2017 TOSHIBA CORPORATION.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

#include "Query.h"

namespace griddb {
	Query::Query(GSQuery *query) : Resource(query), mQuery(query) {

	}

	Query::~Query() {
		close();
	}

	/**
	 * Fetch data from query result.
	 */
	shared_ptr<RowSet> Query::fetch(bool forUpdate) {
		GSRowSet *rowSet;
		// Call method from C-Api.
		GSBool gsForUpdate = (forUpdate == true ? GS_TRUE:GS_FALSE);
		GSResult ret = gsFetch(mQuery, gsForUpdate, &rowSet);

		// Check ret, if error, throw exception
		if (ret != GS_RESULT_OK) {
			throw GSException(ret);
		}

		return make_shared<RowSet>(rowSet);
	}

	/**
	 * Get row set. Convert from C-Api: gsGetRowSet
	 */
	shared_ptr<RowSet> Query::get_row_set() {
		GSRowSet *rowSet;
		GSResult ret =  gsGetRowSet(mQuery, &rowSet);

		// Check ret, if error, throw exception
		if (ret != GS_RESULT_OK) {
			throw GSException(ret);
		}

		return make_shared<RowSet>(rowSet);
	}

	/**
	 * Sets an fetch option of integer type for a result acquisition.
	 */
	void Query::set_fetch_option_integer(GSFetchOption fetchOption, int32_t value) {
		GSResult ret = gsSetFetchOption(mQuery, fetchOption, &value, GS_TYPE_INTEGER);
		if(ret != GS_RESULT_OK) {
			throw GSException(ret);
		}
	}

	/**
	 * Sets an fetch option of long type for a result acquisition.
	 */
	void Query::set_fetch_option_long(GSFetchOption fetchOption, int64_t value) {
		GSResult ret = gsSetFetchOption(mQuery, fetchOption, &value, GS_TYPE_LONG);
		if(ret != GS_RESULT_OK) {
			throw GSException(ret);
		}
	}

	/**
	 * Release all resources created by this Query object.
	 */
	void Query::close() {
		if (mQuery) {
			gsCloseQuery(&mQuery);
			mQuery = NULL;
		}
	}

	GSQuery* Query::gs_ptr() {
		return mQuery;
	}
}
