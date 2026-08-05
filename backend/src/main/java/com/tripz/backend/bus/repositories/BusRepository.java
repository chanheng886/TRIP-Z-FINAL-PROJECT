package com.tripz.backend.bus.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripz.backend.bus.models.Bus;

public interface BusRepository extends JpaRepository<Bus, Long> {
    List<Bus> findByCompany_CompanyName(String companyName);
}