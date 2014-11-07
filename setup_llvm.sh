#!/usr/bin/env sh
source ./llvm_variables.sh
test -d "${llvmdir}" || mkdir -p "${llvmdir}"
cd "${llvmdir}" &&
parallel -j8 'git clone {}' ::: https://github.com/llvm-mirror/{llvm,clang,clang-tools-extra,compiler-rt,dragonegg,libclc,libcxx,libcxxabi,lld,llvm,openmp,polly,poolalloc}
cd "${llvmdir}/llvm/projects"
ln -s ../../compiler-rt ../../libcxx ../../libcxxabi .
cd "${llvmdir}/llvm/tools"
ln -s ../../polly ../../clang ../../lld .
cd "${llvmdir}/clang/tools"
ln -s ../../clang-tools-extra .
cd "${llvmdir}"
touch .mrconfig
mr register ./*
cd "${llvmdir}"

source ./llvm_variables.sh
cd polly
./scripts/checkout_cloog.sh ../cloog_src
cd "${llvmdir}/cloog_src"
./configure --with-gmp-prefix="${gmpprefix}" --prefix="${llvmprefix}"
make -j16
make install
cd "${llvmdir}/cloog_src/isl"
make install
cd "${llvmdir}/cloog_src/osl"
./configure --with-gmp-prefix="${gmpprefix}" --prefix="${llvmprefix}"
make -j16
make install
cd "${llvmdir}/llvm"
[test -d build ] || mkdir build
cd build
llvmvars=$(printf '
-DCMAKE_INSTALL_PREFIX="${llvmprefix}"
-DCMAKE_EXPORT_COMPILE_COMMANDS
-DLLVM_ENABLE_CXX1Y
-DLLVM_ENABLE_EH
-DLLVM_ENABLE_RTTI
-DLLVM_BUILD_EXAMPLES
-DLLVM_BUILD_TOOLS
-DISL_INCLUDE_DIR="${llvmprefix}/include"
-DISL_LIBRARY="${llvmprefix}/lib/libisl.${so}"
-DGMP_INCLUDE_DIR="${gmpprefix}/include"
-DGMP_LIBRARY="${gmpprefix}/libgmp.${so}"
-DCLANG_BUILD_EXAMPLES
-DCLANG_ENABLE_STATIC_ANALYZER
-DCLANG_PLUGIN_SUPPORT
-DLLVM_ENABLE_ASSERTIONS
' | tr '\n' ' ')
printf "llvmvars=" ${llvmvars}
cmake -GNinja .. ${llvmvars}
ninja
ninja install
