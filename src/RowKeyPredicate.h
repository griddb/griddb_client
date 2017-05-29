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

#ifndef _ROWKEYPREDICATE_H_
#define _ROWKEYPREDICATE_H_

#include <string>
#include <vector>
#include "Resource.h"
#include "gridstore.h"

using namespace std;

namespace griddb {

	class RowKeyPredicate : public Resource {
		GSRowKeyPredicate *mPredicate;
	public:
		RowKeyPredicate(GSRowKeyPredicate *predicate);
		~RowKeyPredicate();
		GSType get_key_type();
		const GSChar* get_start_key_as_string();
		const GSChar* get_finish_key_as_string();
		int32_t get_finish_key_as_integer();
		int64_t get_finish_key_as_long();
		int32_t get_start_key_as_integer();
		int64_t get_start_key_as_long();
		GSTimestamp get_start_key_as_timestamp();
		GSTimestamp get_finish_key_as_timestamp();
		void get_predicate_distinct_keys_as_string(
				const GSChar * const ** stringList, size_t *size);
		void get_predicate_distinct_keys_as_integer(const int **intList,
				size_t *size);
		void get_predicate_distinct_keys_as_long(const long **longList,
				size_t *size);
		void get_predicate_distinct_keys_as_timestamp(const long **longList,
				size_t *size);
		void set_finish_key_by_string(const GSChar *finishKey);
		void set_finish_key_by_integer(const int32_t finishKey);
		void set_finish_key_by_long(const int64_t finishKey);
		void set_finish_key_by_timestamp(const GSTimestamp finishKey);
		void set_start_key_by_string(const GSChar *startKey);
		void set_start_key_by_integer(const int32_t startKey);
		void set_start_key_by_long(const int64_t startKey);
		void set_start_key_by_timestamp(const GSTimestamp startKey);
		void add_key_by_string(const GSChar *key);
		void add_key_by_integer(int32_t key);
		void add_key_by_long(int64_t key);
		void add_key_by_timestamp(GSTimestamp key);
		GSRowKeyPredicate* gs_ptr();
	};

} /* namespace griddb */

#endif /* _ROWKEYPREDICATE_H_ */
