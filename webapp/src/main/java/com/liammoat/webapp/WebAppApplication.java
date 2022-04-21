package com.liammoat.webapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import io.dapr.client.DaprClient;
import io.dapr.client.DaprClientBuilder;
import io.dapr.client.domain.HttpExtension;
import reactor.core.publisher.Mono;

@SpringBootApplication
@RestController
public class WebAppApplication {

	private static final String SERVICE_APP_ID = "webapi";

	@GetMapping("/api/messages/{key}")
	public Mono<String> getMessage(@PathVariable String key) {
		return Mono.fromSupplier(() -> {
			try (DaprClient client = new DaprClientBuilder().build()) {
				byte[] response = client.invokeMethod(SERVICE_APP_ID, "api/messages/" + key, null, HttpExtension.GET, byte[].class).block();
				return new String(response);
			} catch (Exception ex) {
				throw new RuntimeException(ex);
			}
		});
	}

	public static void main(String[] args) {
		SpringApplication.run(WebAppApplication.class, args);
	}

}
