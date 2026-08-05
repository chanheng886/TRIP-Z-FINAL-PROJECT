package com.tripz.backend.bus.repositories;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripz.backend.bus.models.Company;

public interface CompanyRepository extends JpaRepository<Company, Long> {
    Optional<Company> findByCompanyName(String companyName);
}
