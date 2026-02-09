cmake_minimum_required(VERSION 3.14)
project(cpp-service)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(DOMAIN_TESTS tests/domain_tests.cpp)
set(APPLICATION_TESTS tests/application_tests.cpp)
set(INFRASTRUCTURE_TESTS tests/infrastructure_tests.cpp)

find_package(PkgConfig)
find_package(GTest CONFIG REQUIRED)
include (GoogleTest)

pkg_check_modules(Pistache REQUIRED IMPORTED_TARGET libpistache)

add_executable(${PROJECT_NAME} main.cpp)
add_executable(domain-tests ${DOMAIN_TESTS})

target_link_libraries(${PROJECT_NAME} PkgConfig::Pistache)
target_link_libraries(domain-tests PRIVATE GTest::gtest_main)
