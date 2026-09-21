package com.tripz.backend;

import com.tripz.backend.config.EnvLoader;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class BackendApplication {

	static {
		EnvLoader.load();
	}

	public static void main(String[] args) {
		EnvLoader.load();
		SpringApplication.run(BackendApplication.class, args);
	}
}