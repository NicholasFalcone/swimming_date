cmake_minimum_required(VERSION 3.20)
project(swimming C)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(PLAYDATE_GAME_NAME swimming)

if(NOT DEFINED ENV{PLAYDATE_SDK_PATH} OR "$ENV{PLAYDATE_SDK_PATH}" STREQUAL "")
    message(FATAL_ERROR "PLAYDATE_SDK_PATH is not set. Please set it to your Playdate SDK root.")
endif()

set(SDK $ENV{PLAYDATE_SDK_PATH})

add_library(${PLAYDATE_GAME_NAME} SHARED
    source/main.c
    source/Core/Vector3.c
    source/Core/Camera.c
    source/Game/World.c
    source/Game/Player.c
    source/Game/Fish.c
)

target_include_directories(${PLAYDATE_GAME_NAME} PRIVATE
    source
    source/Core
    source/Game
)

if(NOT WIN32)
    target_link_libraries(${PLAYDATE_GAME_NAME} m)
endif()

include(${SDK}/C_API/buildsupport/playdate_game.cmake)
