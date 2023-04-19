prefix=`pwd`
install_path=/soft/compilers/llvm

module load cmake/3.23.2

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

  PACKAGES="clang;compiler-rt;lldb;lld;openmp"
  RUNTIMES="libcxxabi;libcxx"
elif [ $1 == "patched" ] ; then
  echo building patch
  echo -----------------------------------
  build_folder=build_mirror_offload_patched
  INSTALL_FOLDER=$install_path/main-patched
  PACKAGES="clang;compiler-rt;lldb;lld;openmp"
  RUNTIMES="libcxxabi;libcxx"
else
  echo building release $1
  echo -----------------------------------
  build_folder=build_mirror_offload_release
  git fetch
  version=$1
  git co llvmorg-$version
  if [ $? != 0 ] ; then
    version=`echo $1 | sed "s/release\///"`
    git co release/$version
    git pull
    if [ $? != 0 ] ; then
      echo "Neither llvmorg-$version nor release/$version branch was found."
      exit 1
    fi
  fi
  INSTALL_FOLDER=$install_path/release-$version
  PACKAGES="clang;compiler-rt;lldb;lld;openmp"
  RUNTIMES="libcxxabi;libcxx"
fi

rm -rf $prefix/$build_folder
mkdir $prefix/$build_folder ; cd $prefix/$build_folder

cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_FOLDER \
    -DGCC_INSTALL_PREFIX=/opt/cray/pe/gcc/11.2.0/snos \
    -DLLVM_ENABLE_BACKTRACES=ON \
    -DLLVM_ENABLE_WERROR=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DLLVM_ENABLE_RTTI=ON \
    -DLLVM_TARGETS_TO_BUILD="X86;NVPTX" \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_ENABLE_PROJECTS="$PACKAGES" \
    -DLLVM_ENABLE_RUNTIMES="$RUNTIMES" \
    -DLIBOMPTARGET_ENABLE_DEBUG=ON \
    -DLIBOMP_OMPT_SUPPORT=OFF \
    ../llvm-project/llvm

make -j15 && make -j15 install && chmod -R -w $INSTALL_FOLDER
