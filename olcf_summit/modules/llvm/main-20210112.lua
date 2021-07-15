-- -*- lua -*-
whatis("Description: Lmod: An Environment Module System")

prereq("gcc/8.1.1")

prepend_path('PATH','/ccs/proj/XXXXXX/llvm/main-20210112/bin')
prepend_path('LD_LIBRARY_PATH','/ccs/proj/XXXXXX/llvm/main-20210112/lib')

setenv("OMPI_CC","clang")
setenv("OMPI_CXX","clang++")
