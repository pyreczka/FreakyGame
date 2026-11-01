cmake_minimum_required(VERSION 3.16)
project(CieploCzyZimno LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/..")

add_executable(gra-shell gra_shell.cpp)
target_compile_options(gra-shell PRIVATE
    $<$<CXX_COMPILER_ID:GNU,Clang>:-Wall;-Wextra;-Wpedantic>
)

find_package(Qt6 COMPONENTS Widgets QUIET)
if(Qt6Widgets_FOUND)
    if(WIN32)
        add_executable(gra-gui WIN32 gra.cpp)
    else()
        add_executable(gra-gui gra.cpp)
    endif()
    target_link_libraries(gra-gui PRIVATE Qt6::Widgets)
    target_compile_options(gra-gui PRIVATE
        $<$<CXX_COMPILER_ID:GNU,Clang>:-Wall;-Wextra;-Wpedantic>
    )
else()
    message(STATUS "Qt 6 Widgets not found; building the shell version only.")
endif()

include(CTest)
if(BUILD_TESTING)
    add_executable(test-gra-logika tests/test_gra_logika.cpp)
    set_target_properties(test-gra-logika PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
    )
    target_compile_options(test-gra-logika PRIVATE
        $<$<CXX_COMPILER_ID:GNU,Clang>:-Wall;-Wextra;-Wpedantic>
    )
    add_test(NAME gra-logika COMMAND test-gra-logika)
endif()

if(WIN32)
    set_target_properties(gra-shell PROPERTIES OUTPUT_NAME "gra-shell")
    if(TARGET gra-gui)
        set_target_properties(gra-gui PROPERTIES OUTPUT_NAME "gra-gui")
    endif()
elseif(UNIX)
    set_target_properties(gra-shell PROPERTIES OUTPUT_NAME "gra-shell-linux")
    if(TARGET gra-gui)
        set_target_properties(gra-gui PROPERTIES OUTPUT_NAME "gra-gui-linux")
    endif()
endif()

foreach(configuration DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)
    set_target_properties(gra-shell PROPERTIES
        "RUNTIME_OUTPUT_DIRECTORY_${configuration}" "${CMAKE_CURRENT_SOURCE_DIR}/.."
    )
    if(TARGET gra-gui)
        set_target_properties(gra-gui PROPERTIES
            "RUNTIME_OUTPUT_DIRECTORY_${configuration}" "${CMAKE_CURRENT_SOURCE_DIR}/.."
        )
    endif()
endforeach()
