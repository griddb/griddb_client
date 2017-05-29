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

%typemap(in) (const GSColumnInfo* props, int propsCount) (PyObject* tuple, int i) {
//Convert Python list of tuple into GSColumnInfo properties
    if (!PyList_Check($input)) {
        PyErr_SetString(PyExc_ValueError,"Expected a List");
        return NULL;
    }
    $2 = (int)PyInt_AS_LONG(PyInt_FromSsize_t(PyList_Size($input)));
    $1 = NULL;
    if ($2 > 0) {
        $1 = (GSColumnInfo *) malloc($2*sizeof(GSColumnInfo));
        i = 0;
        while (i < $2) {
            tuple = PyList_GetItem($input,i);
            if (!PyTuple_Check(tuple)) {
                PyErr_SetString(PyExc_ValueError,"Expected a Tuple as List element");
                free((void *) $1);
                return NULL;
            }
            $1[i].name = PyString_AS_STRING(PyTuple_GetItem(tuple,0)); 
            $1[i].type = (int)(PyInt_AS_LONG(PyTuple_GetItem(tuple,1)));
            i++;
        }
    }
}

%typemap(typecheck) (const GSColumnInfo* props, int propsCount) {
   $1 = PyList_Check($input) ? 1 : 0;
}

%typemap(freearg) (const GSColumnInfo* props, int propsCount) {
  free((void *) $1);
}

%typemap(in) (const GSPropertyEntry* props, int propsCount) (int i, Py_ssize_t si, PyObject* key, PyObject* val) {
    if (!PyDict_Check($input)) {
        PyErr_SetString(PyExc_ValueError,"Expected a Dict");
        return NULL;
    }
    $2 = (int)PyInt_AS_LONG(PyInt_FromSsize_t(PyDict_Size($input)));
    $1 = NULL;
    if ($2 > 0) {
        $1 = (GSPropertyEntry *) malloc($2*sizeof(GSPropertyEntry));
        i = 0;
        si = 0;
        while (PyDict_Next($input, &si, &key, &val)) {
            $1[i].name = PyString_AS_STRING(key);
            $1[i].value = PyString_AS_STRING(val);
            i++;
        }
    }
}

%typemap(freearg) (const GSPropertyEntry* props, int propsCount) {
  free((void *) $1);
}

%typemap(in) (GSQuery* const* queryList, size_t queryCount) (PyObject* pyQuery, std::shared_ptr<griddb::Query> query, void *vquery, int i, int res = 0) {
    if(!PyList_Check($input)) {
        PyErr_SetString(PyExc_ValueError,"Expected a List");
        return NULL;
    }
    $2 = (size_t)PyInt_AS_LONG(PyInt_FromSsize_t(PyList_Size($input)));
    $1 = NULL;
    i = 0;
    if($2 > 0) {
        $1 = (GSQuery**) malloc($2*sizeof(GSQuery*));
        while (i < $2) {
            pyQuery = PyList_GetItem($input,i);
            {
                int newmem = 0;
                res = SWIG_ConvertPtrAndOwn(pyQuery, (void **) &vquery, $descriptor(std::shared_ptr<griddb::Query>*), %convertptr_flags, &newmem);
                if (!SWIG_IsOK(res)) {
                    %argument_fail(res, "$type", $symname, $argnum);
                }
                if (vquery) {
                    query = *%reinterpret_cast(vquery, std::shared_ptr<griddb::Query>*);
                    $1[i] = query->gs_ptr();
                    if (newmem & SWIG_CAST_NEW_MEMORY) {
                        delete %reinterpret_cast(vquery, std::shared_ptr<griddb::Query>*);
                    }             
                }
            }
            
            i++;
        }
    }
}

%typemap(freearg) (GSQuery* const* queryList, size_t queryCount) {
  free((void *) $1);
}

%typemap(in) (const GSContainerRowEntry* entryList, size_t entryCount) (int i, int j, int res = 0, void** pRowList = 0, Py_ssize_t listSize, Py_ssize_t dictSize, PyObject* key, PyObject* val, PyObject* pyRow, void* vrow, std::shared_ptr<griddb::Row> row, std::shared_ptr<griddb::Row>* sprow, griddb::Row* prow) {
    if (!PyDict_Check($input)) {
        PyErr_SetString(PyExc_ValueError,"Expected a Dict");
        return NULL;
    }
    $2 = (int)PyInt_AS_LONG(PyInt_FromSsize_t(PyDict_Size($input)));
    $1 = NULL;
    if ($2 > 0) {
        $1 = (GSContainerRowEntry *) malloc($2*sizeof(GSContainerRowEntry));
        i = 0;
        dictSize = 0;
        while (PyDict_Next($input, &dictSize, &key, &val)) {
            $1[i].containerName = PyString_AS_STRING(key);
            if (!PyList_Check(val)) {
                PyErr_SetString(PyExc_ValueError,"Expected a List as Dict element");
                free((void *) $1);
                return NULL;
            }

            // Get Row element from list
            listSize = (int)PyInt_AS_LONG(PyInt_FromSsize_t(PyList_Size(val)));
            if (listSize > 0) {
                pRowList = (void**)malloc(listSize*sizeof(void *));
                $1[i].rowList = pRowList;
            }
            
            $1[i].rowCount = listSize;
            for(j = 0; j < listSize; j++) {
                pyRow = PyList_GetItem(val,j);
                int newmem = 0;
                res = SWIG_ConvertPtrAndOwn(pyRow, (void **) &vrow, $descriptor(std::shared_ptr<griddb::Row>*), %convertptr_flags, &newmem);
                if (!SWIG_IsOK(res)) {
                    %argument_fail(res, "$type", $symname, $argnum);
                }
                if (vrow) {
                    if (newmem & SWIG_CAST_NEW_MEMORY) {
                        row = *%reinterpret_cast(vrow, std::shared_ptr<griddb::Row>*);
                        delete %reinterpret_cast(vrow, std::shared_ptr<griddb::Row>*);
                        prow = %const_cast(row.get(), griddb::Row *);
                    } else {
                        sprow = %reinterpret_cast(vrow, std::shared_ptr<griddb::Row> *);
                        prow = %const_cast((sprow ? sprow->get() : 0), griddb::Row *);
                    }

                    pRowList[j] = prow->gs_ptr();
                }
            }
            
            i++;                    
                  
        }                    
    }
}

%typemap(freearg) (const GSContainerRowEntry* entryList, size_t entryCount) (int i) {
    for (i = 0; i < $2; i++) {
        if ($1[i].rowList) {
            free((void *) $1[i].rowList);
        }
    }
    
    free((void *) $1);
}

%typemap(in) (const void* const * rowObjs, size_t rowCount) (PyObject* pyRow, std::shared_ptr<griddb::Row> row, void *vrow, int i, int res = 0) {
    if(!PyList_Check($input)) {
        PyErr_SetString(PyExc_ValueError,"Expected a List");
        return NULL;
    }
    $2 = (size_t)PyInt_AS_LONG(PyInt_FromSsize_t(PyList_Size($input)));
    $1 = NULL;
    i = 0;
    if($2 > 0) {
        $1 = (void**) malloc($2*sizeof(void*));
        while (i < $2) {
            pyRow = PyList_GetItem($input,i);
            {
                int newmem = 0;
                res = SWIG_ConvertPtrAndOwn(pyRow, (void **) &vrow, $descriptor(std::shared_ptr<griddb::Row>*), %convertptr_flags, &newmem);
                if (!SWIG_IsOK(res)) {
                    %argument_fail(res, "$type", $symname, $argnum);
                }
                if (vrow) {
                    row = *%reinterpret_cast(vrow, std::shared_ptr<griddb::Row>*);
                    $1[i] = row->gs_ptr();
                    if (newmem & SWIG_CAST_NEW_MEMORY) {
                        delete %reinterpret_cast(vrow, std::shared_ptr<griddb::Row>*);
                    }             
                }
            }
            
            i++;
         }
    }
}

%typemap(freearg) (const void* const * rowObjs, size_t rowCount) {
  free((void *) $1);
}

%typemap(in) (const int8_t *fieldValue, size_t size) (int i) {
    if (!PyList_Check($input)) {
        PyErr_SetString(PyExc_ValueError,"Expected a List");
        return NULL;
    }
    $2 = (int)PyInt_AS_LONG(PyInt_FromSsize_t(PyList_Size($input)));
    $1 = NULL;
    if ($2 > 0) {
        $1 = (int8_t *) malloc($2*sizeof(int8_t));
        i = 0;
        while(i < $2) {
        	$1[i] = (int8_t)PyInt_AS_LONG(PyList_GetItem($input,i));
        	i++;

        }
    }
}

%typemap(freearg) (const int8_t *fieldValue, size_t size) {
  free((void *) $1);
}

%typemap(in) (const GSRowKeyPredicateEntry *const * predicateList, size_t predicateCount) (PyObject* key, PyObject* val, std::shared_ptr<griddb::RowKeyPredicate> pPredicate, GSRowKeyPredicateEntry* pList, void *vpredicate, Py_ssize_t si, int i, int res = 0) {
    if(!PyDict_Check($input)) {
        PyErr_SetString(PyExc_ValueError,"Expected a Dict");
        return NULL;
    }
    $2 = (size_t)PyInt_AS_LONG(PyInt_FromSsize_t(PyDict_Size($input)));
    $1 = NULL;
    i = 0;
    si = 0;
    if($2 > 0) {
        pList = (GSRowKeyPredicateEntry*) malloc($2*sizeof(GSRowKeyPredicateEntry));
        $1 = &pList;
 
        while (PyDict_Next($input, &si, &key, &val)) {
            GSRowKeyPredicateEntry *predicateEntry = &pList[i];
            predicateEntry->containerName = PyString_AS_STRING(key);
            //Get GSRowKeyPredicate pointer from RowKeyPredicate pyObject
            int newmem = 0;
            res = SWIG_ConvertPtrAndOwn(val, (void **) &vpredicate, $descriptor(std::shared_ptr<griddb::RowKeyPredicate>*), %convertptr_flags, &newmem);
            if (!SWIG_IsOK(res)) {
                %argument_fail(res, "$type", $symname, $argnum);
            }
            if (vpredicate) {
                pPredicate = *%reinterpret_cast(vpredicate, std::shared_ptr<griddb::RowKeyPredicate>*);
                predicateEntry->predicate = pPredicate->gs_ptr();
                if (newmem & SWIG_CAST_NEW_MEMORY) {
                    delete %reinterpret_cast(vpredicate, std::shared_ptr<griddb::RowKeyPredicate>*);
                }
            }

            i++;
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

%typemap(argout) (const GSContainerRowEntry **entryList, size_t *entryCount) (size_t i = 0, size_t j = 0, GSContainerRowEntry *entry, GSRow* pRow, std::shared_ptr<griddb::Row>* row, PyObject* dict, PyObject* list, PyObject* key, PyObject* value) {
    dict = PyDict_New();
    for(i = 0; i < *$2; i++) {
        entry = &(*$1)[i];
        
        key = PyString_FromString(entry->containerName);
        list = PyList_New(entry->rowCount);
        for(j = 0; j < entry->rowCount; j++) {
            pRow = (GSRow *) entry->rowList[j];

            if (pRow) {
                row = new std::shared_ptr<griddb::Row>(std::make_shared<griddb::Row>(pRow));
                value = SWIG_NewPointerObj(%as_voidptr(row), $descriptor(std::shared_ptr<griddb::Row> *), SWIG_POINTER_OWN);
                PyList_SetItem(list, j, value);
            }
        }
        //Add entry to map
        PyDict_SetItem(dict, key, list);
    }
    
    $result = dict;
}

%typemap(in, numinputs=0) (const GSChar *const ** stringList, size_t *size) (GSChar **nameList1, size_t size1) {
  $1 = &nameList1;  
  $2 = &size1;
}

%typemap(argout,numinputs=0) (const GSChar *const ** stringList, size_t *size) (  int i, size_t size) {
	GSChar** nameList1 = *$1; 
	size_t size = *$2;
	$result = PyList_New(size);
	for (i = 0; i < size; i++) {
		PyObject *o = PyString_FromString(nameList1[i]);
		PyList_SetItem($result,i,o);
	}
}

%typemap(in, numinputs=0) (const int **intList, size_t *size) (int *intList1, size_t size1) {
  $1 = &intList1;  
  $2 = &size1;
}

%typemap(argout,numinputs=0) (const int **intList, size_t *size) (int i, size_t size) {
	int* intList = *$1; 
	size_t size = *$2;
	$result = PyList_New(size);
	for (i = 0; i < size; i++) {
		PyObject *o = PyInt_FromLong(intList[i]);
		PyList_SetItem($result,i,o);
	}
}

%typemap(in, numinputs=0) (const long **longList, size_t *size) (long *longList1, size_t size1) {
  $1 = &longList1;  
  $2 = &size1;
}

%typemap(argout,numinputs=0) (const long **longList, size_t *size) (int i, size_t size) {
	long* longList = *$1; 
	size_t size = *$2;
	$result = PyList_New(size);
	for (i = 0; i < size; i++) {
		PyObject *o = PyFloat_FromDouble(longList[i]);
		PyList_SetItem($result,i,o);
	}
}

%typemap(in) (const GSBlob *fieldValue) {
    if(!PyByteArray_Check($input)){
        PyErr_SetString(PyExc_ValueError,"Expected a byte array");
        return NULL;
    }
    
    $1 = (GSBlob*) malloc(sizeof(GSBlob));
    
    $1->size = PyByteArray_Size($input);
    $1->data = PyByteArray_AsString($input);
}

%typemap(freearg) (const GSBlob *fieldValue) {
    free((void *) $1);
}

%typemap(in, numinputs = 0) (GSBlob *value) (GSBlob pValue) {
    $1 = &pValue;
}

%typemap(argout) (GSBlob *value) {
    GSBlob output = *$1;
    $result = PyByteArray_FromStringAndSize((char*) output.data, output.size);   
}