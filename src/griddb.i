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

%include "gstype.i"

%{
#include "gridstore.h"
#include "GSException.h"
#include "Resource.h"
#include "ContainerInfo.h"
#include "Row.h"
#include "RowSet.h"
#include "Query.h"
#include "Container.h"
#include "PartitionController.h"
#include "RowKeyPredicate.h"
#include "Store.h"
#include "StoreFactory.h"
#include "Timestamp.h"
%}

%shared_ptr(griddb::Resource)
%shared_ptr(griddb::AggregationResult)
%shared_ptr(griddb::ContainerInfo)
%shared_ptr(griddb::Row)
%shared_ptr(griddb::RowSet)
%shared_ptr(griddb::Query)
%shared_ptr(griddb::Container)
%shared_ptr(griddb::StoreFactory)
%shared_ptr(griddb::RowKeyPredicate)
%shared_ptr(griddb::Store)
%shared_ptr(griddb::PartitionController)

%include "GSException.h"
%include "Resource.h"
%include "AggregationResult.h"
%include "ContainerInfo.h"
%include "Row.h"
%include "RowSet.h"
%include "Query.h"
%include "Container.h"
%include "PartitionController.h"
%include "RowKeyPredicate.h"
%include "Store.h"
%include "StoreFactory.h"
%include "Timestamp.h"
