-- -*- lua -*-
whatis("Description: Lmod: An Environment Module System")

prereq("gcc/9.3.0")
prereq("cuda/11.0.3")

setenv("LIBOMP_USE_HIDDEN_HELPER_TASK","0")
setenv("LIBOMPTARGET_MAP_FORCE_ATOMIC","FALSE")

local root_path = "/gpfs/alpine/mat151/world-shared/opt/llvm/release-15.0.0"
prepend_path("PATH", pathJoin(root_path, "bin"), ":")
prepend_path("MANPATH", pathJoin(root_path, "share/man"), ":")
prepend_path("LD_LIBRARY_PATH", pathJoin(root_path, "lib"), ":")

setenv("OMPI_CC","clang")
setenv("OMPI_CXX","clang++")
