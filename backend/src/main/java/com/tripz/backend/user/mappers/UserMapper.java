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
        .profileImage(dto.getProfileImage())
        .build();
    }

    public User toUpdate(User user, UserRequestDTO dto){
        if (dto.getUsername() != null) user.setUsername(dto.getUsername());
        if (dto.getRole() != null) user.setRole(dto.getRole());
        if (dto.getGender() != null) user.setGender(dto.getGender());
        if (dto.getEmail() != null) user.setEmail(dto.getEmail());
        if (dto.getPhone() != null) user.setPhone(dto.getPhone());
        if (dto.getProfileImage() != null) user.setProfileImage(dto.getProfileImage());
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
        .profileImage(user.getProfileImage())
        .build();
    }
}
