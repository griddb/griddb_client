SWIG = swig -DSWIGWORDSIZE64
CXX = g++


ARCH = $(shell arch)
LDFLAGS = -lpthread -lrt -lgridstore
LDFLAGS_RUBY = -L. -Wl,-Bsymbolic-functions -Wl,-z,relro 		\
				-rdynamic -Wl,-export-dynamic -ldl -lcrypt -lm -lc

CPPFLAGS = -fPIC -std=c++0x -g -O2
INCLUDES = -Iinclude -Isrc
INCLUDES_PYTHON = $(INCLUDES)	\
				-I/usr/include/python2.6
INCLUDES_RUBY = $(INCLUDES)	\
				-I/usr/lib64/ruby/1.8/$(ARCH)-linux/

PROGRAM = _griddb_python_client.so griddb_ruby_client.so
EXTRA = griddb_python_client.py griddb_python_client.pyc

SOURCES = 	  src/Resource.cpp \
		  src/AggregationResult.cpp	\
		  src/ContainerInfo.cpp			\
		  src/Container.cpp			\
		  src/Store.cpp			\
		  src/StoreFactory.cpp	\
		  src/PartitionController.cpp	\
		  src/Query.cpp				\
		  src/Row.cpp				\
		  src/RowKeyPredicate.cpp	\
		  src/RowSet.cpp			\
		  src/Timestamp.cpp			\


all: $(PROGRAM)

SWIG_DEF = src/griddb.i

SWIG_PYTHON_SOURCES = src/griddb_python.cxx
SWIG_RUBY_SOURCES = src/griddb_ruby.cxx

OBJS = $(SOURCES:.cpp=.o)
SWIG_PYTHON_OBJS = $(SWIG_PYTHON_SOURCES:.cxx=.o)
SWIG_RUBY_OBJS = $(SWIG_RUBY_SOURCES:.cxx=.o)


$(SWIG_PYTHON_SOURCES) : $(SWIG_DEF)
	$(SWIG) -outdir . -o $@ -c++ -python $<

$(SWIG_RUBY_SOURCES) : $(SWIG_DEF)
	$(SWIG) -outdir . -o $@ -c++ -ruby $<


.cpp.o:
	$(CXX) $(CPPFLAGS) -c -o $@ $(INCLUDES) $<

$(SWIG_PYTHON_OBJS): $(SWIG_PYTHON_SOURCES)
	$(CXX) $(CPPFLAGS) -c -o $@ $(INCLUDES_PYTHON) $<
	
$(SWIG_RUBY_OBJS): $(SWIG_RUBY_SOURCES)
	$(CXX) $(CPPFLAGS) -c -o $@ $(INCLUDES_RUBY) $<


_griddb_python_client.so: $(OBJS) $(SWIG_PYTHON_OBJS)
	$(CXX) -shared  -o $@ $(OBJS) $(SWIG_PYTHON_OBJS) $(LDFLAGS)
	
griddb_ruby_client.so: $(OBJS) $(SWIG_RUBY_OBJS)
	$(CXX) -shared  -o $@ $(OBJS) $(SWIG_RUBY_OBJS) $(LDFLAGS) $(LDFLAGS_RUBY)

clean:
	rm -rf $(OBJS) $(SWIG_RUBY_OBJS) $(SWIG_PYTHON_OBJS)
	rm -rf $(SWIG_PYTHON_SOURCES) $(SWIG_RUBY_SOURCES)
	rm -rf $(PROGRAM) $(EXTRA)
