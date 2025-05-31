package com.selimhorri.app.resource.integration;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;

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

import com.selimhorri.app.dto.ProductDto;
import com.selimhorri.app.dto.CategoryDto;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
public class ProductResourceIntegrationTest {

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
        String url = "http://localhost:" + port + "/product-service/api/products";
        DtoCollectionResponse<LinkedHashMap> response = restTemplate.getForObject(url, DtoCollectionResponse.class);

        assertNotNull(response, "Response should not be null");
        assertFalse(response.getCollection().isEmpty(), "Response should contain at least one product");
    }

    @Test
    void testFindById() {
        String url = "http://localhost:" + port + "/product-service/api/products/21"; // Usar un ID existente
        ProductDto response = restTemplate.getForObject(url, ProductDto.class);

        assertNotNull(response, "Response should not be null");
        assertNotNull(response.getProductId(), "Product ID should not be null");
        assertNotNull(response.getProductTitle(), "Product title should not be null");
        assertNotNull(response.getImageUrl(), "Image URL should not be null");
        assertNotNull(response.getSku(), "SKU should not be null");
        assertNotNull(response.getPriceUnit(), "Price unit should not be null");
        assertNotNull(response.getQuantity(), "Quantity should not be null");
    }

    @Test
    void testSave() {
        String url = "http://localhost:" + port + "/product-service/api/products";
        ProductDto productDto = new ProductDto();
        productDto.setProductTitle("Test Product");
        productDto.setSku("TEST-SKU-001");
        productDto.setPriceUnit(99.99);
        productDto.setQuantity(10);
        productDto.setImageUrl("http://example.com/image.jpg");
        productDto.setCategoryDto(CategoryDto.builder().categoryId(10).build()); // Usar category ID 10 que sí existe en data.sql

        ProductDto response = restTemplate.postForObject(url, productDto, ProductDto.class);

        assertNotNull(response, "Response should not be null");
        assertNotNull(response.getProductId(), "Product ID should not be null");
        assertEquals(productDto.getProductTitle(), response.getProductTitle(), "Product title should match");
    }

    @Test
    void testUpdate() {
        // Primero obtenemos el producto existente
        String getUrl = "http://localhost:" + port + "/product-service/api/products/22";
        ProductDto original = restTemplate.getForObject(getUrl, ProductDto.class);
        assertNotNull(original, "Original product should exist");

        // Modificamos el producto, pero mantenemos el SKU original para que el update funcione correctamente
        ProductDto productDto = new ProductDto();
        productDto.setProductId(original.getProductId());
        productDto.setProductTitle("Updated Product without ID");
        productDto.setSku(original.getSku()); // Mantener el SKU original
        productDto.setPriceUnit(299.99);
        productDto.setQuantity(40);
        productDto.setImageUrl("http://example.com/updated_without_id.jpg");
        productDto.setCategoryDto(CategoryDto.builder().categoryId(14).build()); // Usar category ID 14

        String url = "http://localhost:" + port + "/product-service/api/products";
        ProductDto response = restTemplate.exchange(url, HttpMethod.PUT, new HttpEntity<>(productDto), ProductDto.class).getBody();

        assertNotNull(response, "Response should not be null");
        assertEquals(productDto.getProductId(), response.getProductId(), "Product ID should match");
        assertEquals(productDto.getProductTitle(), response.getProductTitle(), "Product title should match");
        assertEquals(productDto.getSku(), response.getSku(), "SKU should match");
        assertEquals(productDto.getPriceUnit(), response.getPriceUnit(), "Price unit should match");
        assertEquals(productDto.getQuantity(), response.getQuantity(), "Quantity should match");
        assertEquals(productDto.getImageUrl(), response.getImageUrl(), "Image URL should match");
        assertEquals(productDto.getCategoryDto().getCategoryId(), response.getCategoryDto().getCategoryId(), "Category ID should match");
    }

    @Test
    void testDelete() {
        String url = "http://localhost:" + port + "/product-service/api/products/23"; // Usar product ID 23 que sí existe en data.sql
        restTemplate.delete(url);

        // Verify that the product was deleted
        DtoCollectionResponse<LinkedHashMap> response = restTemplate.getForObject("http://localhost:" + port + "/product-service/api/products", DtoCollectionResponse.class);
        assertNotNull(response, "Response should not be null");
        assertFalse(response.getCollection().stream().anyMatch(product -> product.get("productId").equals(23)), "Product should be deleted");
    }
}
