prefix=`pwd`
install_path=/home/packages/llvm

cd $prefix

if [ ! -d $prefix/llvm-project ] ; then
  git clone https://github.com/llvm/llvm-project.git
fi

cd $prefix/llvm-project

if [ $# -eq 0 ] ; then
  echo building main
  echo -----------------------------------
  build_folder=build_mirror_offload_main
  INSTALL_FOLDER=$install_path/main-`date +%Y%m%d`
  git co main
  git pull

  #git fetch jdoerfert
  #git co feature/declare_variant_begin
  #git reset --hard jdoerfert/feature/declare_variant_begin
  PACKAGES="clang;compiler-rt;lld;lldab"
  RUNTIMES="libcxxabi;libcxx;openmp"
elif [ $1 == "patched" ] ; then
  echo building patch
  echo -----------------------------------
  build_folder=build_mirror_offload_patched
  INSTALL_FOLDER=$install_path/main-patched
  #INSTALL_FOLDER=$install_path/main-20210112
  PACKAGES="clang;lld"
  RUNTIMES="libcxxabi;libcxx;openmp"
else
  echo building release $1
  echo -----------------------------------
  build_folder=build_mirror_offload_release
  INSTALL_FOLDER=$install_path/release-$1
  git fetch
  git co llvmorg-$1
  PACKAGES="clang;compiler-rt"
  RUNTIMES="libcxxabi;libcxx;openmp"
fi

rm -rf $prefix/$build_folder
mkdir $prefix/$build_folder ; cd $prefix/$build_folder

cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_FOLDER \
    -DLLVM_ENABLE_BACKTRACES=ON \
    -DLLVM_ENABLE_WERROR=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DLLVM_ENABLE_RTTI=ON \
    -DLLVM_TARGETS_TO_BUILD="X86;AMDGPU;NVPTX" \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_ENABLE_PROJECTS="$PACKAGES" \
    -DLLVM_ENABLE_RUNTIMES="$RUNTIMES" \
    -DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES="80,61" \
    -DCLANG_OPENMP_NVPTX_DEFAULT_ARCH=sm_80 \
    -DLIBOMPTARGET_NVPTX_MAX_SM=38 \
    -DLIBOMPTARGET_ENABLE_DEBUG=ON \
    ../llvm-project/llvm

make -j15 && make -j15 && sudo make -j15 install
