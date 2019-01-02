[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

# Project Compiler

### About

This project consists in a college project for discipline `INF01147 - Compilers (Federal University of Rio Grande do Sul)`. The main goal of this project it's build a compiler from 0 to `ILOC`, passing throught important compilation steps, like:

 - Lexical Analysis
 - Syntax Analysis
 - AST `(Abstract syntax tree)`
 - Semanthic Analysis
 - Code Generation
 - Execution Suport

### Running instructions

After clone the repository, on root directory:

```shell
mkdir -p pc/build
cd pc/build
# Active Compilation E1
cmake -DE1=ON ..
# Compile
make
# Execute
./main
```

For change between stages, you should:

```shell
# Disable E1 flags and Active Compilation E2
cmake -DE1=OFF -DE2=ON .
make
```

### Running tests

Inside of `/build` directory, execute

```
ctest -R e1
```

For running the tests of E1.

### General comments

- The all base project is actually a mirror of https://github.com/schnorr/pc

- You can execute individually tests `ctest -R e1_avaliacao_00 -V`

### Environment
- cmake
- bison
- flex
- valgrind

### Contributors

- [Lucas Valandro](https://github.com/valandro)
- [Francisco Knebel](https://github.com/FranciscoKnebel)
- [Lucas M. Schnorr](https://github.com/schnorr)


### License
Apache License. [Click here for more information.](LICENSE)