package com.tripz.backend.user.dtos.ResponseDTO;
import com.tripz.backend.user.enums.UserRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponseDTO {
    private Long id;
    private String username;
    private UserRole role;
    private String gender;
    private String email;
    private String phone;
}
