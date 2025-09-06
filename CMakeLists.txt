cmake_minimum_required(VERSION 3.16)
project(OpenGLApp)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(libs/glfw-3.4)
add_subdirectory(libs/glad)
add_subdirectory(libs/glm)

add_executable(app src/main.cpp src/Shader.cpp src/ShadowMap.cpp src/Material.cpp src/Light.cpp src/models/Model.cpp src/models/Cube.cpp src/models/Plane.cpp src/models/Pyramid.cpp src/Camera.cpp)
target_link_libraries(app PRIVATE glad glfw glm)

# Skopiuj katalog assets do folderu build podczas kompilacji
file(COPY ${CMAKE_SOURCE_DIR}/assets DESTINATION ${CMAKE_BINARY_DIR})

# LINUX
if(UNIX AND NOT APPLE)
    target_link_libraries(app PRIVATE dl pthread X11 Xrandr Xi Xxf86vm Xinerama Xcursor)
endif()