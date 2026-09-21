package com.tripz.backend.upload.controllers;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.tripz.backend.upload.services.CloudinaryService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/v1/upload")
@Tag(name = "Upload", description = "File & Image Upload API")
@RequiredArgsConstructor
@Slf4j
public class UploadController {

    private final CloudinaryService cloudinaryService;

    @PostMapping(value = "/image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Upload image to Cloudinary (Admin only)")
    public ResponseEntity<Map<String, Object>> uploadImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "folder", required = false, defaultValue = "tripz/locations") String folder) {
        try {
            String url = cloudinaryService.uploadImage(file, folder);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("url", url);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        } catch (IOException e) {
            log.error("Failed to upload image to Cloudinary", e);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("message", "Image upload failed: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
}
