cmake_minimum_required(VERSION 3.27)

set(PROJECT_NAME "gltf_view")
project(${PROJECT_NAME})
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin")

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -Wall -g -O0")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O2")

# CGLM
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fms-extensions")

if(NOT APPLE)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fobjc-runtime=gnustep-2.0 -fuse-ld=lld")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fblocks -fobjc-exceptions -fexceptions -fno-strict-aliasing")
endif()

set(VENDOR_DIR ${CMAKE_CURRENT_LIST_DIR}/vendor/)

set(SRC_DIR ${CMAKE_CURRENT_LIST_DIR}/src/)
set(INC_DIR ${CMAKE_CURRENT_LIST_DIR}/include/)

set(BASE_DIR ${VENDOR_DIR}base/)
set(BASE_INC_DIR ${BASE_DIR}/include/)
set(BASE_LIB_DIR ${BASE_DIR}/lib/)

set(GLAD_SRC_DIR ${VENDOR_DIR}glad/src/)
set(GLAD_INC_DIR ${VENDOR_DIR}glad/include/)

set(STB_INC_DIR ${VENDOR_DIR}stb)

set(CGLM_DIR ${VENDOR_DIR}cglm/)
set(SDL3_DIR ${VENDOR_DIR}SDL/)
set(CGLTF_DIR ${VENDOR_DIR}cgltf/)

link_directories(${BASE_LIB_DIR})

find_package(SDL3 QUIET)
if(SDL3_FOUND)
    message(STATUS "Using SDL3 via find_package")
endif()
if(NOT SDL3_FOUND AND EXISTS "${SDL3_DIR}CMakeLists.txt")
    add_subdirectory(${SDL3_DIR})
    message(STATUS "Using SDL3 via add_subdirectory")
    set(SDL3_FOUND TRUE)
endif()

set(SOURCES
    ${SRC_DIR}main.m
    ${SRC_DIR}model.m
    ${SRC_DIR}mesh.m
    ${SRC_DIR}shader.m
    ${SRC_DIR}texture.m
    ${SRC_DIR}material.m
    ${SRC_DIR}animation.m
    ${SRC_DIR}animation/sampler.m
    ${SRC_DIR}animation/channel.m
    ${SRC_DIR}node.m
    ${SRC_DIR}skin.m
    ${SRC_DIR}matrix.m
    ${SRC_DIR}vector.m
    ${GLAD_SRC_DIR}glad.c
)

add_executable(${PROJECT_NAME} ${SOURCES})

# CGLM
add_subdirectory(${CGLM_DIR})

# 
target_include_directories(${PROJECT_NAME}
    PUBLIC
    ${INC_DIR}
    ${BASE_INC_DIR}
    ${GLAD_INC_DIR}
    ${STB_INC_DIR}
    ${CGLTF_DIR}
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC
    base
    SDL3::SDL3
    cglm
)

if(NOT APPLE)
    target_link_libraries(${PROJECT_NAME}
        PUBLIC
        objc
    )

    if(WIN32)
        # Copy DLL File
        add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${BASE_LIB_DIR}/objc.dll"
            $<TARGET_FILE_DIR:${PROJECT_NAME}>)
    else()
        message(FATAL_ERROR "UNIX support is not implemented yet.")
    endif()
else()
    target_link_libraries(${PROJECT_NAME}
        PUBLIC
        "-framework Cocoa"
        "-framework AppKit"
        "-framework CoreData"
        "-framework Foundation"
        "-framework OpenGL"
)
endif()
