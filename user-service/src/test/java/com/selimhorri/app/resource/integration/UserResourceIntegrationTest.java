package com.selimhorri.app.resource.integration;

import com.selimhorri.app.dto.UserDto;
import com.selimhorri.app.dto.response.collection.DtoCollectionResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.util.StreamUtils;
import org.springframework.web.client.DefaultResponseErrorHandler;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
public class UserResourceIntegrationTest {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @BeforeEach
    void setUp() {
        restTemplate.getRestTemplate().setErrorHandler(new DefaultResponseErrorHandler() {
            @Override
            public void handleError(ClientHttpResponse response) throws IOException {
                String body = StreamUtils.copyToString(response.getBody(), StandardCharsets.UTF_8);
                System.err.println("Response error: " + body);
                super.handleError(response);
            }
        });
    }

    @Test
    void testFindAll() {
        String url = "http://localhost:" + port + "/user-service/api/users";
        DtoCollectionResponse<LinkedHashMap> response = restTemplate.getForObject(url, DtoCollectionResponse.class);
        assertNotNull(response, "Response should not be null");
        // Puede estar vacío si la BD está limpia, pero la estructura debe existir
        assertNotNull(response.getCollection(), "Collection should not be null");
    }

    @Test
    void testSaveAndFindById() {
        String url = "http://localhost:" + port + "/user-service/api/users";
        UserDto userDto = UserDto.builder()
                .firstName("Test")
                .lastName("User")
                .email("test@user.com")
                .phone("123456")
                .build();
        UserDto saved = restTemplate.postForObject(url, userDto, UserDto.class);
        assertNotNull(saved, "Saved user should not be null");
        assertNotNull(saved.getUserId(), "User ID should not be null");

        String findUrl = url + "/" + saved.getUserId();
        UserDto found = restTemplate.getForObject(findUrl, UserDto.class);
        assertNotNull(found, "Found user should not be null");
        assertEquals(saved.getUserId(), found.getUserId(), "User ID should match");
    }

    @Test
    void testUpdate() {
        String url = "http://localhost:" + port + "/user-service/api/users";
        UserDto userDto = UserDto.builder()
                .firstName("Update")
                .lastName("Me")
                .email("update@me.com")
                .phone("654321")
                .build();
        UserDto saved = restTemplate.postForObject(url, userDto, UserDto.class);
        assertNotNull(saved);
        saved.setFirstName("Updated");
        UserDto updated = restTemplate.exchange(url, HttpMethod.PUT, new HttpEntity<>(saved), UserDto.class).getBody();
        assertNotNull(updated);
        assertEquals("Updated", updated.getFirstName());
    }

    @Test
    void testDelete() {
        String url = "http://localhost:" + port + "/user-service/api/users";
        UserDto userDto = UserDto.builder()
                .firstName("Delete")
                .lastName("Me")
                .email("delete@me.com")
                .phone("000000")
                .build();
        UserDto saved = restTemplate.postForObject(url, userDto, UserDto.class);
        assertNotNull(saved);
        String deleteUrl = url + "/" + saved.getUserId();
        restTemplate.delete(deleteUrl);
        // Verifica que ya no existe
        String findUrl = url + "/" + saved.getUserId();
        UserDto found = restTemplate.getForObject(findUrl, UserDto.class);
        assertNull(found);
    }

    @Test
    void testFindByUsername() {
        String url = "http://localhost:" + port + "/user-service/api/users";
        UserDto userDto = UserDto.builder()
                .firstName("ByUsername")
                .lastName("User")
                .email("byusername@user.com")
                .phone("111111")
                .build();
        UserDto saved = restTemplate.postForObject(url, userDto, UserDto.class);
        assertNotNull(saved);
        String findUrl = url + "/username/" + saved.getFirstName(); // Ajusta si el username es otro campo
        UserDto found = restTemplate.getForObject(findUrl, UserDto.class);
        assertNotNull(found);
        assertEquals(saved.getFirstName(), found.getFirstName());
    }
}
