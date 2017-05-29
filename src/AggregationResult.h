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

#ifndef _AGGREGATIONRESULT_H_
#define _AGGREGATIONRESULT_H_

#include "Resource.h"
#include "GSException.h"
#include<gridstore.h>

using namespace std;

namespace griddb {

	class AggregationResult : public Resource {
		GSAggregationResult* mAggResult;
	public:
		AggregationResult(GSAggregationResult* aggResult);
		~AggregationResult();

		long get_long();
		double get_double();
		GSTimestamp get_timestamp();
	private:
		void close();
	};

} /* namespace griddb */

#endif /* _AGGREGATIONRESULT_H_ */
