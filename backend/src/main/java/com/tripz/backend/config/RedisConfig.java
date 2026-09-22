package com.tripz.backend.config;

import java.time.Duration;
import java.util.HashMap;
import java.util.Map;

import org.springframework.cache.Cache;
import org.springframework.cache.annotation.CachingConfigurer;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.interceptor.CacheErrorHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.RedisSerializationContext;
import org.springframework.data.redis.serializer.RedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;

import lombok.extern.slf4j.Slf4j;

@Configuration
@EnableCaching
@Slf4j
public class RedisConfig implements CachingConfigurer {

    public static final String CACHE_LOCATIONS = "locations";
    public static final String CACHE_ROUTES = "routes";
    public static final String CACHE_COMPANIES = "companies";
    public static final String CACHE_BUS_TYPES = "busTypes";
    public static final String CACHE_SCHEDULES = "schedules";

    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory connectionFactory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory);

        RedisSerializer<Object> jsonSerializer = RedisSerializer.json();

        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(jsonSerializer);
        template.setHashKeySerializer(new StringRedisSerializer());
        template.setHashValueSerializer(jsonSerializer);
        template.afterPropertiesSet();
        return template;
    }

    @Bean
    public RedisCacheManager cacheManager(RedisConnectionFactory connectionFactory) {
        RedisSerializer<Object> jsonSerializer = RedisSerializer.json();

        RedisCacheConfiguration defaultCacheConfig = RedisCacheConfiguration.defaultCacheConfig()
                .entryTtl(Duration.ofMinutes(10))
                .disableCachingNullValues()
                .serializeKeysWith(RedisSerializationContext.SerializationPair.fromSerializer(new StringRedisSerializer()))
                .serializeValuesWith(RedisSerializationContext.SerializationPair.fromSerializer(jsonSerializer));

        Map<String, RedisCacheConfiguration> cacheConfigurations = new HashMap<>();
        // Static/rarely changing metadata
        cacheConfigurations.put(CACHE_LOCATIONS, defaultCacheConfig.entryTtl(Duration.ofHours(1)));
        cacheConfigurations.put(CACHE_COMPANIES, defaultCacheConfig.entryTtl(Duration.ofHours(1)));
        cacheConfigurations.put(CACHE_BUS_TYPES, defaultCacheConfig.entryTtl(Duration.ofHours(1)));
        cacheConfigurations.put(CACHE_ROUTES, defaultCacheConfig.entryTtl(Duration.ofMinutes(30)));
        // Schedules change when bookings occur or status changes
        cacheConfigurations.put(CACHE_SCHEDULES, defaultCacheConfig.entryTtl(Duration.ofMinutes(5)));

        return RedisCacheManager.builder(connectionFactory)
                .cacheDefaults(defaultCacheConfig)
                .withInitialCacheConfigurations(cacheConfigurations)
                .build();
    }

    /**
     * Graceful fallback: If Redis is temporarily down or not running locally,
     * log a warning and fall back seamlessly to the PostgreSQL database
     * without crashing or throwing 500 errors to the client.
     */
    @Override
    public CacheErrorHandler errorHandler() {
        return new CacheErrorHandler() {
            @Override
            public void handleCacheGetError(RuntimeException exception, Cache cache, Object key) {
                log.warn("Redis GET failed for key '{}' in cache '{}'. Falling back to database.", key, cache.getName());
            }

            @Override
            public void handleCachePutError(RuntimeException exception, Cache cache, Object key, Object value) {
                log.warn("Redis PUT failed for key '{}' in cache '{}': {}", key, cache.getName(), exception.getMessage());
            }

            @Override
            public void handleCacheEvictError(RuntimeException exception, Cache cache, Object key) {
                log.warn("Redis EVICT failed for key '{}' in cache '{}': {}", key, cache.getName(), exception.getMessage());
            }

            @Override
            public void handleCacheClearError(RuntimeException exception, Cache cache) {
                log.warn("Redis CLEAR failed for cache '{}': {}", cache.getName(), exception.getMessage());
            }
        };
    }
}
