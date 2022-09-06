-- -*- lua -*-
whatis("Description: Lmod: An Environment Module System")

prereq("gcc/9.3.0")
prereq("cuda/11.0.3")

setenv("LIBOMP_USE_HIDDEN_HELPER_TASK","0")
setenv("LIBOMPTARGET_MAP_FORCE_ATOMIC","FALSE")
prepend_path('PATH','/gpfs/alpine/mat151/world-shared/opt/llvm/main-20220317/bin')
prepend_path('LD_LIBRARY_PATH','/gpfs/alpine/mat151/world-shared/opt/llvm/main-20220317/lib')

setenv("OMPI_CC","clang")
setenv("OMPI_CXX","clang++")
