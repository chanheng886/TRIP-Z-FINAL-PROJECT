package com.tripz.backend.user.dtos.RequestDTO;
import com.tripz.backend.user.enums.UserRole;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserRequestDTO {

    @NotBlank(message = "Username is required")
    @Size(max = 50, message = "Username must be less than 50")
    private String username;

    @NotNull(message = "Role is required")
    private UserRole role;

    @NotBlank(message = "Gender is required")
    private String gender;

    @Size(max = 100, message = "Email must be less than 100 characters")
    private String email;

    @Pattern(regexp = "^[0-9]{10,12}", message = "Phone must be 10-12 digits")
    private String phone;
}
