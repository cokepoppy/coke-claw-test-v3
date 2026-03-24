package com.example.demo;

import java.util.Map;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.*;

@SpringBootApplication
@RestController
@RequestMapping("/api")
public class Application {
  public static void main(String[] args) {
    SpringApplication.run(Application.class, args);
  }

  @PostMapping("/login")
  public Map<String, Object> login(@RequestBody Map<String, String> payload) {
    return Map.of(
      "ok", true,
      "username", payload.getOrDefault("username", "guest"),
      "message", "Login accepted without database"
    );
  }

  @GetMapping("/health")
  public Map<String, Object> health() {
    return Map.of("ok", true, "service", "login-backend");
  }
}
