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

#ifndef _TIMESTAMP_H_
#define _TIMESTAMP_H_
#include "gridstore.h"
#include <string>
#include "GSException.h"

using namespace std;

namespace griddb {

	class Timestamp {

	public:
		Timestamp();
		~Timestamp();
		static GSTimestamp current();
		static GSTimestamp add_time(GSTimestamp timestamp, int32_t amount, GSTimeUnit timeUnit);
		static string format_time(GSTimestamp timestamp, size_t bufSize);
		static GSTimestamp parse(char* str);
	};

} /* namespace griddb */

#endif /* _TIMESTAMP_H_ */
