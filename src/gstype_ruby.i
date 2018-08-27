/*
   Copyright (c) 2017 TOSHIBA Digital Solutions Corporation

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

%typemap(in) (const GSColumnInfo* props, int propsCount) (VALUE ary_element, VALUE keys_ary, int i, VALUE key, VALUE val) {
  Check_Type($input, T_ARRAY);
  $2 = NUM2INT(rb_funcall($input, rb_intern("length"), 0, NULL));
  $1 = NULL;
  if ($2 > 0) {
    $1 = (GSColumnInfo *) malloc($2*sizeof(GSColumnInfo));
    for (i = 0; i < $2; i++) {
      ary_element = rb_ary_entry($input, i);
      
      Check_Type(ary_element, T_HASH);
      keys_ary = rb_funcall(ary_element, rb_intern("keys"), 0, NULL);
      key = rb_ary_entry(keys_ary, 0); //hash map only contains 1 key-value pair
      val = rb_hash_aref(ary_element, key);
      Check_Type(key, T_STRING);
      Check_Type(val, T_FIXNUM);
      $1[i].name = StringValuePtr(key);
      $1[i].type = NUM2INT(val);
    }
  }
}

%typemap(typecheck) (const GSColumnInfo* props, int propsCount) {
   try {
       Check_Type($input, T_ARRAY);
       $1 = 1;
   } catch (const std::exception& e) {
       $1 = 0;
   }
}

%typemap(freearg) (const GSColumnInfo* props, int propsCount) {
  if ($1) {
    free((void *) $1);
  }
}

%typemap(in) (const GSPropertyEntry* props, int propsCount) (VALUE keys_ary, int i, VALUE key, VALUE val) {
  Check_Type($input, T_HASH);
  $2 = NUM2INT(rb_funcall($input, rb_intern("size"), 0, NULL));
  $1 = NULL;
  if ($2 > 0) {
    $1 = (GSPropertyEntry *) malloc($2*sizeof(GSPropertyEntry));
    keys_ary = rb_funcall($input, rb_intern("keys"), 0, NULL);
    for (i = 0; i < $2; i++) {
      key = rb_ary_entry(keys_ary, i);
      val = rb_hash_aref($input, key);
      Check_Type(key, T_STRING);
      Check_Type(val, T_STRING);
      $1[i].name = StringValuePtr(key);
      $1[i].value = StringValuePtr(val);
    }
  }
}

%typemap(freearg) (const GSPropertyEntry* props, int propsCount) {
  if ($1) {
    free((void *) $1);
  }
}

%typemap(in) (GSQuery* const* queryList, size_t queryCount) (int i, int res = 0, void* argp, std::shared_ptr<griddb::Query> query, VALUE val) {
  Check_Type($input, T_ARRAY);
  $2 = NUM2INT(rb_funcall($input, rb_intern("length"), 0, NULL));
  $1 = NULL;

  if ($2 > 0) {
    $1 = (GSQuery**) malloc($2*sizeof(GSQuery*));
    for (i = 0; i < $2; i++) {
      val = rb_ary_entry($input, i);
      
      {
        swig_ruby_owntype newmem = {0, 0};
        res = SWIG_ConvertPtrAndOwn(val, &argp, $descriptor(std::shared_ptr<griddb::Query> *), %convertptr_flags, &newmem);
        if (!SWIG_IsOK(res)) {
          %argument_fail(res, "$type", $symname, $argnum);
        }
        if (argp) {
          query = *%reinterpret_cast(argp, std::shared_ptr<griddb::Query>*);
          $1[i] = query->gs_ptr();
        }
        if (newmem.own & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, std::shared_ptr<griddb::Query>*);
      }
    }
  }
}

%typemap(freearg) (GSQuery* const* queryList, size_t queryCount) {
  if ($1) {
    free((void *) $1);
  }
}

%typemap(in) (const GSContainerRowEntry* entryList, size_t entryCount) (VALUE keys_ary, VALUE pyRow, void** pRowList = 0, size_t arraySize, int j, int i,int res = 0, void* argp, std::shared_ptr<griddb::Row> row, VALUE key, VALUE val) {
  Check_Type($input, T_HASH);
  $2 = NUM2INT(rb_funcall($input, rb_intern("size"), 0, NULL));
  $1 = NULL;
  if ($2 > 0) {
    $1 = (GSContainerRowEntry *) malloc($2*sizeof(GSContainerRowEntry));
    memset($1, 0x0, $2*sizeof(GSContainerRowEntry));
    keys_ary = rb_funcall($input, rb_intern("keys"), 0, NULL);
    for (i = 0; i < $2; i++) {
      key = rb_ary_entry(keys_ary, i);
      val = rb_hash_aref($input, key);
      $1[i].containerName = StringValuePtr(key);
      Check_Type(val, T_ARRAY);
      
      //Get number of Row
      arraySize = NUM2INT(rb_funcall(val, rb_intern("length"), 0, NULL));
      if (arraySize > 0) {
        pRowList = (void**)malloc(arraySize*sizeof(void *));
        $1[i].rowList = pRowList; 
      }
      
      $1[i].rowCount = arraySize;
      //Loop through array of Row
      for(j = 0; j < arraySize; j++) {
        pyRow = rb_ary_entry(val, j);
      
        swig_ruby_owntype newmem = {0, 0};
        res = SWIG_ConvertPtrAndOwn(pyRow, &argp, $descriptor(std::shared_ptr<griddb::Row> *), %convertptr_flags, &newmem);
        if (!SWIG_IsOK(res)) {
          %argument_fail(res, "$type", $symname, $argnum);
        }
        if (argp) {
          row = *%reinterpret_cast(argp, std::shared_ptr<griddb::Row>*);
          pRowList[j] = row->gs_ptr();
        }
        if (newmem.own & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, std::shared_ptr<griddb::Row>*);
      }
    }
  }
}

%typemap(freearg) (const GSContainerRowEntry* entryList, size_t entryCount) (int i) {
    for (i = 0; i < $2; i++) {
        if ($1[i].rowList && $1[i].rowCount > 0) {
            free((void *) $1[i].rowList);
        }
    }
    
    if ($1) {
        free((void *) $1);
    }
}

%typemap(in) (const void* const * rowObjs, size_t rowCount) (int i, int res = 0, void* argp, std::shared_ptr<griddb::Row> row, VALUE val) {
  Check_Type($input, T_ARRAY);
  $2 = NUM2INT(rb_funcall($input, rb_intern("length"), 0, NULL));
  $1 = NULL;

  if ($2 > 0) {
    $1 = (void**) malloc($2*sizeof(void*));
    for (i = 0; i < $2; i++) {
      val = rb_ary_entry($input, i);
      
      {
        swig_ruby_owntype newmem = {0, 0};
        res = SWIG_ConvertPtrAndOwn(val, &argp, $descriptor(std::shared_ptr<griddb::Row> *), %convertptr_flags, &newmem);
        if (!SWIG_IsOK(res)) {
          %argument_fail(res, "$type", $symname, $argnum);
        }
        if (argp) {
          row = *%reinterpret_cast(argp, std::shared_ptr<griddb::Row>*);
          $1[i] = row->gs_ptr();
        }
        if (newmem.own & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, std::shared_ptr<griddb::Row>*);
      }
    }
  }
}

%typemap(freearg) (const void* const * rowObjs, size_t rowCount) {
  if ($1) {
    free((void *) $1);
  }
}
      
%typemap(in) (const int8_t *fieldValue, size_t size) (VALUE ary_element, VALUE keys_ary, int i, VALUE key, VALUE val) {
  Check_Type($input, T_ARRAY);
  $2 = NUM2INT(rb_funcall($input, rb_intern("length"), 0, NULL));
  $1 = NULL;
  if ($2 > 0) {
    $1 = (int8_t *) malloc($2*sizeof(int8_t));
    for (i = 0; i < $2; i++) {
      $1[i] = (int8_t) NUM2INT(rb_ary_entry($input, i));
    }
  }
}

%typemap(freearg) (const int8_t *fieldValue, size_t size) {
  if ($1) {
    free((void *) $1);
  }
}

%typemap(in) (const GSRowKeyPredicateEntry *const * predicateList, size_t predicateCount) (VALUE keys_ary, int i, VALUE key, VALUE val, void* argp, std::shared_ptr<griddb::RowKeyPredicate> pPredicate, GSRowKeyPredicateEntry *pList, int res = 0) {
  Check_Type($input, T_HASH);
  $2 = NUM2INT(rb_funcall($input, rb_intern("size"), 0, NULL));
  $1 = NULL;
  if ($2 > 0) {
    pList = (GSRowKeyPredicateEntry *) malloc($2*sizeof(GSRowKeyPredicateEntry));
    memset(pList, 0x0, $2*sizeof(GSRowKeyPredicateEntry));
    $1 = &pList;
    keys_ary = rb_funcall($input, rb_intern("keys"), 0, NULL);
    for (i = 0; i < $2; i++) { 
      key = rb_ary_entry(keys_ary, i);
      val = rb_hash_aref($input, key);
      Check_Type(key, T_STRING);
      pList[i].containerName = StringValuePtr(key);
      
      //Get GSRowKeyPredicate pointer from RowKeyPredicate Ruby Object
      swig_ruby_owntype newmem = {0, 0};
      res = SWIG_ConvertPtrAndOwn(val, &argp, $descriptor(std::shared_ptr<griddb::RowKeyPredicate> *), %convertptr_flags, &newmem);
      if (!SWIG_IsOK(res)) {
        %argument_fail(res, "$type", $symname, $argnum);
      }
      if (argp) {
        pPredicate = *%reinterpret_cast(argp, std::shared_ptr<griddb::RowKeyPredicate>*);
        pList[i].predicate = pPredicate->gs_ptr();
      }
      if (newmem.own & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, std::shared_ptr<griddb::RowKeyPredicate>*);
    }
  }
}

%typemap(freearg) (const GSRowKeyPredicateEntry *const * predicateList, size_t predicateCount) (int i) {
  if ($1 && *$1) {
    free((void *) *$1);
  }
}

%typemap(in, numinputs = 0) (const GSContainerRowEntry **entryList, size_t *entryCount) (GSContainerRowEntry *pEntryList, size_t temp) {
  $1 = &pEntryList;
  $2 = &temp;
}

%typemap(argout) (const GSContainerRowEntry **entryList, size_t *entryCount) (int i, int j, std::shared_ptr<griddb::Row>* row, VALUE hash, VALUE list, VALUE key, VALUE value, GSContainerRowEntry *entry, GSRow *pRow){
    hash = rb_hash_new();
    for(i = 0; i < *$2; i++) {
        entry = &(*$1)[i];
        
        key = rb_str_new2(entry->containerName);
        list = rb_ary_new();
        for(j = 0; j < entry->rowCount; j++) {
            pRow = (GSRow *) entry->rowList[j];

            if (pRow) {
              row = new std::shared_ptr<griddb::Row>(new griddb::Row(pRow));
              value = SWIG_NewPointerObj(%as_voidptr(row), $descriptor(std::shared_ptr<griddb::Row> *), SWIG_POINTER_OWN);
              rb_ary_push(list, value);
            }
        }
        //Add entry to map
        rb_hash_aset(hash, key, list);
    }
    
    $result = hash;
}

%typemap(in, numinputs=0) (const GSChar *const ** stringList, size_t *size) (const GSChar *const *  nameList1, size_t* size1) {
  GSChar** nameList1;
  $1 = &nameList1;  
  size_t size1;
  $2 = &size1;
}

%typemap(argout,numinputs=0, fragment="output_helper") (const GSChar *const ** stringList, size_t *size) (VALUE arr,  VALUE i, VALUE size) {
	GSChar** nameList1 = *$1; 
	size_t size = *$2;
	VALUE arr = rb_ary_new2(size);

    for ( i=0; i< size; i++ ){
        rb_ary_push(arr, rb_str_new2(nameList1[i])); 
    }
    $result = arr;
 }

%typemap(in, numinputs=0) (const int **intList, size_t *size) (int **intList1, size_t *size1) {
  int* intList1;
  $1 = &intList1;  
  size_t size1;
  $2 = &size1;
}

%typemap(argout,numinputs=0) (const int **intList, size_t *size) (int i, size_t size) {
	int* intList = *$1; 
	size_t size = *$2;
	for (i=0;i < size;i++){
		$result = output_helper($result, INT2FIX(intList[i]) );
	}
}

%typemap(in, numinputs=0) (const int **longList, size_t *size) (int **longList1, size_t *size1) {
  long* longList1;
  $1 = &longList1;  
  size_t size1;
  $2 = &size1;
}

%typemap(argout,numinputs=0) (const int **longList, size_t *size) (int i, size_t size) {
	long* longList = *$1; 
	size_t size = *$2;
	for (i=0;i < size;i++){
		$result = output_helper($result, INT2NUM(longList[i]) );
	}
}

%typemap(in) (const GSBlob *fieldValue) {
    Check_Type($input, T_STRING);
    
    $1 = (GSBlob*) malloc(sizeof(GSBlob));
    
    $1->size = NUM2INT(rb_funcall($input, rb_intern("length"), 0, NULL));
    $1->data = StringValuePtr($input);
}

%typemap(freearg) (const GSBlob *fieldValue) {
    if ($1) {
        free((void *) $1);
    }
}

%typemap(in, numinputs = 0) (GSBlob *value) (GSBlob pValue) {
    $1 = &pValue;
}

%typemap(argout) (GSBlob *value) {
    GSBlob output = *$1;
    $result = rb_str_new((char*) output.data, output.size);   
}