package com.selimhorri.app.helper;

import com.selimhorri.app.domain.Credential;
import com.selimhorri.app.domain.User;
import com.selimhorri.app.dto.CredentialDto;
import com.selimhorri.app.dto.UserDto;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class UserMappingHelperTest {

    @Test
    @DisplayName("Map User to UserDto: all fields")
    void testMapUserToUserDto_AllFields() {
        Credential credential = Credential.builder()
                .credentialId(1)
                .username("testuser")
                .password("pass")
                .roleBasedAuthority(null)
                .isEnabled(true)
                .isAccountNonExpired(true)
                .isAccountNonLocked(true)
                .isCredentialsNonExpired(true)
                .build();
        User user = User.builder()
                .userId(10)
                .firstName("John")
                .lastName("Doe")
                .imageUrl("img.png")
                .email("john@doe.com")
                .phone("123456")
                .credential(credential)
                .build();
        UserDto dto = UserMappingHelper.map(user);
        assertEquals(user.getUserId(), dto.getUserId());
        assertEquals(user.getFirstName(), dto.getFirstName());
        assertEquals(user.getCredential().getUsername(), dto.getCredentialDto().getUsername());
    }

    @Test
    @DisplayName("Map UserDto to User: all fields")
    void testMapUserDtoToUser_AllFields() {
        CredentialDto credentialDto = CredentialDto.builder()
                .credentialId(2)
                .username("otheruser")
                .password("secret")
                .roleBasedAuthority(null)
                .isEnabled(false)
                .isAccountNonExpired(false)
                .isAccountNonLocked(false)
                .isCredentialsNonExpired(false)
                .build();
        UserDto userDto = UserDto.builder()
                .userId(20)
                .firstName("Jane")
                .lastName("Smith")
                .imageUrl("img2.png")
                .email("jane@smith.com")
                .phone("654321")
                .credentialDto(credentialDto)
                .build();
        User user = UserMappingHelper.map(userDto);
        assertEquals(userDto.getUserId(), user.getUserId());
        assertEquals(userDto.getFirstName(), user.getFirstName());
        assertEquals(userDto.getCredentialDto().getUsername(), user.getCredential().getUsername());
    }

    @Test
    @DisplayName("Map User to UserDto: null credential")
    void testMapUserToUserDto_NullCredential() {
        User user = User.builder()
                .userId(30)
                .firstName("NoCred")
                .lastName("User")
                .imageUrl(null)
                .email(null)
                .phone(null)
                .credential(null)
                .build();
        assertThrows(NullPointerException.class, () -> UserMappingHelper.map(user));
    }

    @Test
    @DisplayName("Map UserDto to User: null credentialDto")
    void testMapUserDtoToUser_NullCredentialDto() {
        UserDto userDto = UserDto.builder()
                .userId(40)
                .firstName("NoCredDto")
                .lastName("UserDto")
                .imageUrl(null)
                .email(null)
                .phone(null)
                .credentialDto(null)
                .build();
        assertThrows(NullPointerException.class, () -> UserMappingHelper.map(userDto));
    }

    @Test
    @DisplayName("Map User to UserDto: minimal fields")
    void testMapUserToUserDto_MinimalFields() {
        Credential credential = Credential.builder()
                .credentialId(null)
                .username(null)
                .password(null)
                .roleBasedAuthority(null)
                .isEnabled(null)
                .isAccountNonExpired(null)
                .isAccountNonLocked(null)
                .isCredentialsNonExpired(null)
                .build();
        User user = User.builder()
                .userId(null)
                .firstName(null)
                .lastName(null)
                .imageUrl(null)
                .email(null)
                .phone(null)
                .credential(credential)
                .build();
        UserDto dto = UserMappingHelper.map(user);
        assertNull(dto.getUserId());
        assertNull(dto.getFirstName());
        assertNull(dto.getCredentialDto().getUsername());
    }
}
