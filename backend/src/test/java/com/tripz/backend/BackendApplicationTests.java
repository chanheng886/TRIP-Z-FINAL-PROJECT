package com.tripz.backend;

import com.tripz.backend.config.EnvLoader;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class BackendApplicationTests {

	static {
		EnvLoader.load();
	}

	@Test
	void contextLoads() {
	}

}
