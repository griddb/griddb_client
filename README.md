GridDB Client (Python, Ruby)

## Overview

GridDB Client is developed using GridDB C Client and [SWIG](http://www.swig.org/) (Simplified Wrapper and Interface Generator).  
We can use GridDB with the following language.
 - Python
 - Ruby
These Clients have C-based methods already defined for each data-type.

And there is also the new Python Client with improved usability. 
Please refer to [new Python Client](https://github.com/griddb/python_client).

## Operating environment

Building of the library and execution of the sample programs have been checked in the following environment.

    OS:              CentOS 6.7(x64)
    SWIG:            3.0.10
    GCC:             4.4.7
    Python:          2.6, 3.6
    Ruby:            1.8, 2.4
    GridDB Server:   3.0 (CE)
    GridDB C Client: 3.0 (CE)

## QuickStart
### Preparations

Install SWIG as below.

    $ wget https://sourceforge.net/projects/pcre/files/pcre/8.39/pcre-8.39.tar.gz
    $ tar xvfz pcre-8.39.tar.gz
    $ cd pcre-8.39
    $ ./configure
    $ make
    $ make install

    $ wget https://prdownloads.sourceforge.net/swig/swig-3.0.10.tar.gz
    $ tar xvfz swig-3.0.10.tar.gz
    $ cd swig-3.0.10
    $ ./configure
    $ make
    $ make install

Update include path of Python/Ruby header files in Makefile (INCLUDES_PYTHON, INCLUDES_RUBY) corresponding to Python/Ruby header files directory path in OS.

And update Makefile (LDFLAGS).  

    LDFLAGS = -L<C client library file directory path> -lpthread -lrt -lgridstore

### Build and Run 

Execute the command on project directory.

    $ make

(For Python)

    1. Set the PYTHONPATH variable for griddb Python module files.
    
    $ export PYTHONPATH=$PYTHONPATH:<installed directory path>

    2. Import griddb_python_client in Python.

(For Ruby)

    1. Set the RUBYPATH variable for griddb Ruby module files.
    
    $ export RUBYPATH=$RUBYPATH:<installed directory path>

    2. Import griddb_ruby_client in Ruby.

Note:
1. When you build only Python(Ruby) Client, please execute the following command.

    $ make _griddb_python_client.so

    $ make griddb_ruby_client.so

2. The environment of Python/Ruby should be the same as the version used to build the ".so" file.

### How to run sample

GridDB Server need to be started in advance.

    1. Set LD_LIBRARY_PATH

        export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:<C client library file directory path>

    2. The command to run sample in Python

        $ cp griddb_python_client.py _griddb_python_client.so sample/.  
        $ sample/sample1.py <GridDB notification address> <GridDB notification port>
            <GridDB cluster name> <GridDB user> <GridDB password>
          -->Person: name=name02 status=false count=2 lob=[65, 66, 67, 68, 69, 70, 71, 72, 73, 74]

    3. The command to run sample in Ruby

        $ cp griddb_ruby_client.so sample/.  
        $ sample/sample1.rb <GridDB notification address> <GridDB notification port>
            <GridDB cluster name> <GridDB user> <GridDB password>
          -->Person: name=name02 status=false count=2 lob=[65, 66, 67, 68, 69, 70, 71, 72, 73, 74]

## Function

(available)
- STRING, BOOL, BYTE, SHORT, INTEGER, LONG, FLOAT, DOUBLE, TIMESTAMP, BLOB type for GridDB
- put/get data with key
- normal query, aggregation with TQL
- Multi-Put/Get/Query (batch processing)

(not available)
- GEOMETRY, Array type for GridDB
- timeseries compression
- timeseries-specific function like gsAggregateTimeSeries, gsQueryByTimeSeriesSampling in C client
- trigger, affinity

Please refer to the following files for more detailed information.  
- [Python Client API Reference](https://griddb.github.io/griddb_client/PythonAPIReference.htm)
- [Ruby Client API Reference](https://griddb.github.io/griddb_client/RubyAPIReference.htm)

About API:
- When an error occurs, an exception GSException is thrown.
- Based on C Client API. Please refer to C Client API Reference for the detailed information.
  * [API Reference](https://griddb.github.io/griddb_nosql/manual/GridDB_API_Reference.html)
  * [API Reference(Japanese)](https://griddb.github.io/griddb_nosql/manual/GridDB_API_Reference_ja.html)

Note:
1. The current API might be changed in the next version. e.g. put_container
2. References to objects obtained using the get method described below must be referenced prior to executing the methods. When referencing after the execution of the get methods, please copy the basic data type such as string from the object and reference it to the copied data.
    - get_row_xxx
    - get_partition_xxx
    - get_predicate_xxx
    - get_container_info
    - get_multiple_container_rows

   Please refer to the following note from C Client API Reference document for detailed information of the reason behind the implementation:

    "In order to store the variable-length data such as string or array, it uses a temporary memory area.
    This area is valid until this function or similar functions which use a temporary memory area.
    The behavior is undefined when the area which has been invalidated is accessed."

## Community

  * Issues  
    Use the GitHub issue function if you have any requests, questions, or bug reports. 
  * PullRequest  
    Use the GitHub pull request function if you want to contribute code.
    You'll need to agree GridDB Contributor License Agreement(CLA_rev1.1.pdf).
    By using the GitHub pull request function, you shall be deemed to have agreed to GridDB Contributor License Agreement.

## License
  
  The Python/Ruby client for GridDB source license is Apache License, version 2.0.
