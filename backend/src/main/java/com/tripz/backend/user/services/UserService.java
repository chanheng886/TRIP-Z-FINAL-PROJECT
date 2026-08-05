package com.tripz.backend.user.services;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.tripz.backend.user.dtos.RequestDTO.UserRequestDTO;
import com.tripz.backend.user.dtos.ResponseDTO.UserResponseDTO;
import com.tripz.backend.user.enums.UserRole;
import com.tripz.backend.user.mappers.UserMapper;
import com.tripz.backend.user.models.User;
import com.tripz.backend.user.repositories.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserMapper userMapper;
    private final UserRepository userRepository;

    //✅ Get All User
    public List<UserResponseDTO> getAllUser(){
        return userRepository.findAll()
            .stream()
            .map(userMapper::toResponse)
            .collect(Collectors.toList());
    }
    //✅ Get user by user id
    public UserResponseDTO getUserByUserId(Long id){
        return userRepository.findById(id)
            .map(userMapper::toResponse)
            .orElseThrow(() -> new RuntimeException("User with id: " + id + " Not Found!"));
    }

    //✅ Get User by user role
    public List<UserResponseDTO> getUserByRole(String role){
        UserRole userRole = UserRole.valueOf(role);
        List<User> user = userRepository.findByRole(userRole);

        return user.stream().map(userMapper::toResponse).collect(Collectors.toList());
    }

    //✅ Create user
    public UserResponseDTO createUser(UserRequestDTO dto){
        User user = userMapper.toEntity(dto);
        User save = userRepository.save(user);

        return userMapper.toResponse(save);
    }

    //✅ Udpate user
    public UserResponseDTO updateUser(Long id, UserRequestDTO dto){
        User user = userRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("User with id: " + id + " Not Found!"));
        User update =  userMapper.toUpdate(user, dto);
        User save = userRepository.save(update);
        return userMapper.toResponse(save);
    }

    //✅ Delete user
    public UserResponseDTO deleteUser(Long id){
        User user = userRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("User with id: " + id + "Not Found!"));
        userRepository.delete(user);
        return userMapper.toResponse(user);
    }
}
