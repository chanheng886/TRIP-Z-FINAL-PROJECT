package com.tripz.backend.user.mappers;

import org.springframework.stereotype.Component;

import com.tripz.backend.user.dtos.RequestDTO.UserRequestDTO;
import com.tripz.backend.user.dtos.ResponseDTO.UserResponseDTO;
import com.tripz.backend.user.models.User;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class UserMapper {
    // Convert from DTO to entity
    public User toEntity(UserRequestDTO dto){
        return User.builder()
        .username(dto.getUsername())
        .role(dto.getRole())
        .gender(dto.getGender())
        .email(dto.getEmail())
        .phone(dto.getPhone())
        .build();
    }

    public User toUpdate(User user, UserRequestDTO dto){
        user.setUsername(dto.getUsername());
        user.setRole(dto.getRole());
        user.setGender(dto.getGender());
        user.setEmail(dto.getEmail());
        user.setPhone(dto.getPhone());
        return user;
    }

    public UserResponseDTO toResponse(User user){
        return UserResponseDTO.builder()
        .id(user.getId())
        .username(user.getUsername())
        .role(user.getRole())
        .gender(user.getGender())
        .email(user.getEmail())
        .phone(user.getPhone())
        .build();
    }
}
