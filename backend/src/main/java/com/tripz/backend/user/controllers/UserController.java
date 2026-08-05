package com.tripz.backend.user.controllers;

import java.util.List;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tripz.backend.user.dtos.RequestDTO.UserRequestDTO;
import com.tripz.backend.user.dtos.ResponseDTO.UserResponseDTO;
import com.tripz.backend.user.services.UserService;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@Tag(name = "Users")
public class UserController {
    private final UserService userService;

    @GetMapping
    public List<UserResponseDTO> getAllUser(){
        return userService.getAllUser();
    }

    @GetMapping("/{id}")
    public UserResponseDTO getUserByUserId(@PathVariable Long id){
        return userService.getUserByUserId(id);
    }

    @GetMapping("role/{role}")
    public List<UserResponseDTO> getUserByRole(@PathVariable String role){
        return userService.getUserByRole(role);
    }

    @PostMapping
    public UserResponseDTO createUser(@Valid @RequestBody UserRequestDTO dto){
        return userService.createUser(dto);
    }
    
    @PutMapping("/{id}")
    public UserResponseDTO updateUser(@PathVariable Long id, @RequestBody UserRequestDTO dto){
        return userService.updateUser(id, dto);
    }

    @DeleteMapping("/{id}")
    public UserResponseDTO deleteUser(@PathVariable Long id){
        return userService.deleteUser(id);
    }
}
