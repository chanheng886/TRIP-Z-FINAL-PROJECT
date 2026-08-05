package com.tripz.backend.user.enums;

import java.util.IllformedLocaleException;

public enum UserRole {
    Customer,
    Admin,
    BusinessOwner;

    public static UserRole fromString(String value){
        for(UserRole role : UserRole.values()){
            if(role.name().equalsIgnoreCase(value)){
                return role;
            }
        }
        throw new IllformedLocaleException("Invalid role: " + value);
    }
}