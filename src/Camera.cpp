#include "Camera.h"

Camera::Camera(glm::vec3 position, glm::vec3 up , float yaw, float pitch) : Front(glm::vec3(0.0f, 0.0f, -1.0f)), radius(position.z) {
    Position = position;
    WorldUp = up;
    Yaw = yaw;
    Pitch = pitch;
    updateCameraVectors();
}

void Camera::ProcessMouseScroll(float yoffset) {
    Zoom -= (float)yoffset;
    if (Zoom < 1.0f)
        Zoom = 1.0f;
    if (Zoom > 45.0f)
        Zoom = 45.0f;
}

void Camera::ProcessMouseMovement(float xoffset, float yoffset, GLboolean constrainPitch) {
    xoffset *= MouseSensitivity;
    yoffset *= MouseSensitivity;

    Yaw -= xoffset;
    Pitch -= yoffset;

    if (constrainPitch) {
        if (Pitch > 89.0f)
            Pitch = 89.0f;
        if (Pitch < -89.0f)
            Pitch = -89.0f;
    }
    updateCameraVectors();
}

void Camera::ProcessKeyboard(CAMDIR direction, float deltaTime) {
    float velocity = MovementSpeed * deltaTime;
    switch (direction) {
    case CAMDIR::FORWARD:
        Position += Front * velocity;
        break;
    case CAMDIR::BACKWARD:
        Position -= Front * velocity;
        break;
    case CAMDIR::RIGHT:
        Position += Right * velocity;
        break;
    case CAMDIR::LEFT:
        Position -= Right * velocity;
        break;
    case CAMDIR::UP:
        Position += WorldUp * velocity;
        break;
    case CAMDIR::DOWN:
        Position -= WorldUp * velocity;
        break;
    }
}

glm::mat4 Camera::GetViewMatrix() {
    return glm::lookAt(Position, glm::vec3(0.0f), Up);
}

void Camera::updateCameraVectors() {
    Position.x = radius * cos(glm::radians(Pitch)) * sin(glm::radians(Yaw));
    Position.y = radius * sin(glm::radians(Pitch));
    Position.z = radius * cos(glm::radians(Pitch)) * cos(glm::radians(Yaw));

    Front = glm::normalize(-Position);

    Right = glm::normalize(glm::cross(Front, WorldUp));
    Up    = glm::normalize(glm::cross(Right, Front));
}
