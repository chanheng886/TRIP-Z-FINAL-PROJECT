package com.tripz.backend.user.repositories;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import com.tripz.backend.user.models.User;
import com.tripz.backend.user.enums.UserRole;


public interface UserRepository extends JpaRepository<User, Long> {
    List<User> findByRole(UserRole role);
}
