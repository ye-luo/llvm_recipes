prefix=`pwd`
install_path=/soft/llvm

export CMAKE_PREFIX_PATH=/soft/spack/opt/spack/linux-ubuntu20.04-zen2/gcc-9.4.0/libffi-3.4.6-s4cthjwrnauavtc24wk3u4ceuzu6b5gi:$CMAKE_PREFIX_PATH

module load llvm/release-18.1
module list

CC=clang
CXX=clang++

cd $prefix

if [ ! -d $prefix/llvm-project ] ; then
  git clone https://github.com/llvm/llvm-project.git
fi

cd $prefix/llvm-project

if [ $# -eq 0 ] ; then
  echo building main
  echo -----------------------------------
  build_folder=build_llvm_main
  INSTALL_FOLDER=$install_path/main-`date +%Y%m%d`
  git co main
  git pull

  #git fetch jdoerfert
  #git co feature/declare_variant_begin
  #git reset --hard jdoerfert/feature/declare_variant_begin
  PACKAGES="clang;lld;mlir;flang"
  RUNTIMES="openmp;offload;compiler-rt"
elif [ $1 == "patched" ] ; then
  echo building patch
  echo -----------------------------------
  build_folder=build_llvm_patched
  INSTALL_FOLDER=$install_path/main-patched
  #INSTALL_FOLDER=$install_path/main-20210112
  PACKAGES="clang;lld;mlir;flang"
  RUNTIMES="openmp;offload;compiler-rt"
else
  echo building release $1
  echo -----------------------------------
  build_folder=build_llvm_release
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
  PACKAGES="clang;lld;mlir;flang"
  RUNTIMES="openmp;offload;compiler-rt"
fi

echo install folder $INSTALL_FOLDER
rm -rf $prefix/$build_folder
mkdir $prefix/$build_folder ; cd $prefix/$build_folder

cmake -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX \
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
    -DLIBOMPTARGET_ENABLE_DEBUG=ON \
    -DLLVM_PARALLEL_LINK_JOBS=4 \
    -DLLVM_BINUTILS_INCDIR=/usr/include \
    ../llvm-project/llvm && make -j15 -k

make -j32 install && echo --gcc-install-dir=/usr/lib/gcc/x86_64-linux-gnu/11 > $INSTALL_FOLDER/bin/x86_64-unknown-linux-gnu.cfg && chmod -w -R $INSTALL_FOLDER

chmod -R -w $INSTALL_FOLDER
