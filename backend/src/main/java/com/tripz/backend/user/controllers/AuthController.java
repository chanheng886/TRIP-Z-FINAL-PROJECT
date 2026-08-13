package com.tripz.backend.user.controllers;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tripz.backend.user.dtos.RequestDTO.LoginRequest;
import com.tripz.backend.user.dtos.RequestDTO.RegisterRequest;
import com.tripz.backend.user.dtos.ResponseDTO.AuthResponse;
import com.tripz.backend.user.dtos.ResponseDTO.UserResponseDTO;
import com.tripz.backend.user.services.AuthService;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PatchMapping("/admin/promote/{userId}")
    public ResponseEntity<UserResponseDTO> promoteToAdmin(@PathVariable Long userId) {
        return ResponseEntity.ok(authService.promoteToAdmin(userId));
    }
}
