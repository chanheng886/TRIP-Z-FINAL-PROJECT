package com.tripz.backend.upload.services;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.cloudinary.Cloudinary;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class CloudinaryService {

    private final Cloudinary cloudinary;

    public String uploadImage(MultipartFile file, String folder) throws IOException {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("File must not be empty");
        }

        Map<String, Object> params = new HashMap<>();
        if (folder != null && !folder.isBlank()) {
            params.put("folder", folder);
        }
        params.put("resource_type", "auto");

        @SuppressWarnings("rawtypes")
        Map uploadResult = cloudinary.uploader().upload(file.getBytes(), params);

        String secureUrl = (String) uploadResult.get("secure_url");
        log.info("Cloudinary upload successful. Secure URL: {}", secureUrl);
        return secureUrl;
    }
}
