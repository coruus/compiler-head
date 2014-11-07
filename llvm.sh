#!/usr/bin/env sh
source ./llvm.vars
cd "${llvmdir}"
mr update
cd polly
./utils/checkout_cloog.sh ../cloog_src
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
llvmvars="""-DCMAKE_INSTALL_PREFIX="${llvmprefix}" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DLLVM_ENABLE_CXX1Y=ON -DLLVM_ENABLE_EH=ON -DLLVM_ENABLE_RTTI=ON -DLLVM_BUILD_EXAMPLES=ON -DLLVM_BUILD_TOOLS=ON -DISL_INCLUDE_DIR="${llvmprefix}/include" -DISL_LIBRARY="${llvmprefix}/lib/libisl.${so}" -DGMP_INCLUDE_DIR="${gmpprefix}/include" -DGMP_LIBRARY="${gmpprefix}/libgmp.${so}" -DCLANG_BUILD_EXAMPLES=ON -DCLANG_ENABLE_STATIC_ANALYZER=ON -DCLANG_PLUGIN_SUPPORT=ON -DLLVM_ENABLE_ASSERTIONS=ON"""

cmake -GNinja .. ${llvmvars}
ninja
ninja install
