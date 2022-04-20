package com.liammoat.webapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@RestController
public class WebAppApplication {

	@RequestMapping("/")
    public String home() {
        return "Hello World";
    }

	public static void main(String[] args) {
		SpringApplication.run(WebAppApplication.class, args);
	}

}
