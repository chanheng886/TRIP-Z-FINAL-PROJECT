package com.tripz.backend.user.repositories;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import com.tripz.backend.user.models.User;
import com.tripz.backend.user.enums.UserRole;


public interface UserRepository extends JpaRepository<User, Long> {
    List<User> findByRole(UserRole role);
    Optional<User> findByPhone(String phone);
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
    boolean existsByPhone(String phone);
}
