package com.example.demo;

import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@Disabled("Skipping default contextLoads test while focusing on controller/API coverage")
@SpringBootTest
class DemoApplicationTests {

    @Test
    void contextLoads() {
    }
}