package com.tripz.backend.user.services;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.tripz.backend.security.JwtService;
import com.tripz.backend.security.UserPrincipal;
import com.tripz.backend.user.dtos.RequestDTO.LoginRequest;
import com.tripz.backend.user.dtos.RequestDTO.RegisterRequest;
import com.tripz.backend.user.dtos.ResponseDTO.AuthResponse;
import com.tripz.backend.user.dtos.ResponseDTO.UserResponseDTO;
import com.tripz.backend.user.enums.UserRole;
import com.tripz.backend.user.mappers.UserMapper;
import com.tripz.backend.user.models.User;
import com.tripz.backend.user.repositories.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final UserMapper userMapper;

    public AuthResponse register(RegisterRequest request) {
        validateUniqueness(request.getUsername(), request.getEmail(), request.getPhone());

        User user = User.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .gender(request.getGender())
                .phone(request.getPhone())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(UserRole.Customer)
                .build();

        return buildAuthResponse(userRepository.save(user));
    }

    public UserResponseDTO promoteToAdmin(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

        user.setRole(UserRole.Admin);
        return userMapper.toResponse(userRepository.save(user));
    }

    public AuthResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword()));

        UserPrincipal principal = (UserPrincipal) authentication.getPrincipal();
        return buildAuthResponse(principal.getUser());
    }

    private void validateUniqueness(String username, String email, String phone) {
        if (userRepository.existsByUsername(username)) {
            throw new RuntimeException("Username is already taken");
        }
        if (userRepository.existsByEmail(email)) {
            throw new RuntimeException("Email is already registered");
        }
        if (userRepository.existsByPhone(phone)) {
            throw new RuntimeException("Phone is already registered");
        }
    }

    private AuthResponse buildAuthResponse(User user) {
        UserPrincipal principal = new UserPrincipal(user);
        String token = jwtService.generateToken(principal);
        UserResponseDTO userDTO = userMapper.toResponse(user);

        return AuthResponse.builder()
                .token(token)
                .tokenType("Bearer")
                .expiresIn(jwtService.getExpiration())
                .user(userDTO)
                .build();
    }
}
