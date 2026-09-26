package com.tripz.backend;

import com.tripz.backend.config.EnvLoader;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.data.redis.core.StringRedisTemplate;
import lombok.extern.slf4j.Slf4j;

@SpringBootApplication
@Slf4j
public class BackendApplication {

	static {
		EnvLoader.load();
	}

	public static void main(String[] args) {
		EnvLoader.load();
		SpringApplication.run(BackendApplication.class, args);
	}

	@Bean
	CommandLineRunner testRedisConnection(StringRedisTemplate redisTemplate) {
		return args -> {
			try {
				redisTemplate.opsForValue().set("tripz:ping", "pong");
				String result = redisTemplate.opsForValue().get("tripz:ping");
				log.info("[Redis] Upstash Redis connected successfully! Ping result: {}", result);
			} catch (Exception e) {
				log.warn("[Redis] Failed to connect to Redis on startup: {}", e.getMessage());
			}
		};
	}
}