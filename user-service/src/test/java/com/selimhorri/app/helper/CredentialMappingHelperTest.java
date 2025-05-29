package com.selimhorri.app.helper;

import com.selimhorri.app.domain.Credential;
import com.selimhorri.app.domain.User;
import com.selimhorri.app.dto.CredentialDto;
import com.selimhorri.app.dto.UserDto;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class CredentialMappingHelperTest {

    @Test
    @DisplayName("Map Credential to CredentialDto: all fields")
    void testMapCredentialToCredentialDto_AllFields() {
        User user = User.builder()
                .userId(1)
                .firstName("John")
                .lastName("Doe")
                .imageUrl("img.png")
                .email("john@doe.com")
                .phone("123456")
                .build();
        Credential credential = Credential.builder()
                .credentialId(10)
                .username("testuser")
                .password("pass")
                .roleBasedAuthority(null)
                .isEnabled(true)
                .isAccountNonExpired(true)
                .isAccountNonLocked(true)
                .isCredentialsNonExpired(true)
                .user(user)
                .build();
        CredentialDto dto = CredentialMappingHelper.map(credential);
        assertEquals(credential.getCredentialId(), dto.getCredentialId());
        assertEquals(credential.getUsername(), dto.getUsername());
        assertEquals(credential.getUser().getFirstName(), dto.getUserDto().getFirstName());
    }

    @Test
    @DisplayName("Map CredentialDto to Credential: all fields")
    void testMapCredentialDtoToCredential_AllFields() {
        UserDto userDto = UserDto.builder()
                .userId(2)
                .firstName("Jane")
                .lastName("Smith")
                .imageUrl("img2.png")
                .email("jane@smith.com")
                .phone("654321")
                .build();
        CredentialDto credentialDto = CredentialDto.builder()
                .credentialId(20)
                .username("otheruser")
                .password("secret")
                .roleBasedAuthority(null)
                .isEnabled(false)
                .isAccountNonExpired(false)
                .isAccountNonLocked(false)
                .isCredentialsNonExpired(false)
                .userDto(userDto)
                .build();
        Credential credential = CredentialMappingHelper.map(credentialDto);
        assertEquals(credentialDto.getCredentialId(), credential.getCredentialId());
        assertEquals(credentialDto.getUsername(), credential.getUsername());
        assertEquals(credentialDto.getUserDto().getFirstName(), credential.getUser().getFirstName());
    }

    @Test
    @DisplayName("Map Credential to CredentialDto: null user")
    void testMapCredentialToCredentialDto_NullUser() {
        Credential credential = Credential.builder()
                .credentialId(30)
                .username("noUser")
                .password("pass")
                .roleBasedAuthority(null)
                .isEnabled(null)
                .isAccountNonExpired(null)
                .isAccountNonLocked(null)
                .isCredentialsNonExpired(null)
                .user(null)
                .build();
        assertThrows(NullPointerException.class, () -> CredentialMappingHelper.map(credential));
    }

    @Test
    @DisplayName("Map CredentialDto to Credential: null userDto")
    void testMapCredentialDtoToCredential_NullUserDto() {
        CredentialDto credentialDto = CredentialDto.builder()
                .credentialId(40)
                .username("noUserDto")
                .password("pass")
                .roleBasedAuthority(null)
                .isEnabled(null)
                .isAccountNonExpired(null)
                .isAccountNonLocked(null)
                .isCredentialsNonExpired(null)
                .userDto(null)
                .build();
        assertThrows(NullPointerException.class, () -> CredentialMappingHelper.map(credentialDto));
    }

    @Test
    @DisplayName("Map Credential to CredentialDto: minimal fields")
    void testMapCredentialToCredentialDto_MinimalFields() {
        User user = User.builder()
                .userId(null)
                .firstName(null)
                .lastName(null)
                .imageUrl(null)
                .email(null)
                .phone(null)
                .build();
        Credential credential = Credential.builder()
                .credentialId(null)
                .username(null)
                .password(null)
                .roleBasedAuthority(null)
                .isEnabled(null)
                .isAccountNonExpired(null)
                .isAccountNonLocked(null)
                .isCredentialsNonExpired(null)
                .user(user)
                .build();
        CredentialDto dto = CredentialMappingHelper.map(credential);
        assertNull(dto.getCredentialId());
        assertNull(dto.getUsername());
        assertNull(dto.getUserDto().getFirstName());
    }
}
