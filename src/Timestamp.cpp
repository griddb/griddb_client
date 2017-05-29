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

#include "Timestamp.h"

namespace griddb {

Timestamp::Timestamp() {
}

Timestamp::~Timestamp() {
}

/**
 * Get current timestamp. Convert from C-API: gsCurrentTime .
 */
GSTimestamp Timestamp::current() {
	return gsCurrentTime();
}

/**
 * Add timestamp. Convert from C-API: gsAddTime .
 */
GSTimestamp Timestamp::add_time(GSTimestamp timestamp, int32_t amount,
		GSTimeUnit timeUnit) {
	return gsAddTime(timestamp, amount, timeUnit);
}

/**
 * Format timestamp. Convert from C-API: gsFormatTime .
 */
string Timestamp::format_time(GSTimestamp timestamp, size_t bufSize) {
	char* strBuf =  new char[bufSize];
	size_t stringSize = gsFormatTime(timestamp, strBuf, bufSize);
	string ret(strBuf, stringSize);
	delete [] strBuf;
	return ret;
}

/**
 * Parse timestamp. Convert from C-API: gsParseTime .
 */
GSTimestamp Timestamp::parse(char* str) {
	GSTimestamp value;
	GSBool ret = gsParseTime(str, &value);
	if (ret == GS_FALSE) {
		throw GSException("Can't convert timestamp from string");
	}
	return value;
}

} /* namespace griddb */
