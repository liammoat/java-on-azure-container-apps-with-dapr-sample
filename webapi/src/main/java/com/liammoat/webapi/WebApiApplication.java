package com.liammoat.webapi;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import io.dapr.client.DaprClient;
import io.dapr.client.DaprClientBuilder;
import io.dapr.client.domain.State;
import reactor.core.publisher.Mono;

@SpringBootApplication
@RestController
public class WebApiApplication {

	public static class MyClass {
		public String message;

		@Override
		public String toString() {
			return message;
		}
	}

	private static final String STATE_STORE_NAME = "statestore";

	@GetMapping("/api/messages/{key}")
	public Mono<String> getMessage(@PathVariable String key) {
		return Mono.fromSupplier(() => {
			try (DaprClient client = new DaprClientBuilder().build()) {
				client.waitForSidecar(10000).block();

				State<MyClass> retrievedState = client.getState(STATE_STORE_NAME, key, MyClass.class).block();
				String retreivedMessage = retrievedState.getValue().message;
				System.out.println("Retrieved state using get: " + retreivedMessage);

				return retreivedMessage;
			} catch (Exception ex) {
				throw new RuntimeException(ex)
			}
		});
	}

	@PostMapping("/api/messages/{key}")
	public Mono<String> postMessage(@PathVariable String key, @RequestBody String message) {
		return Mono.fromSupplier(() => {
			try (DaprClient client = new DaprClientBuilder().build()) {
				client.waitForSidecar(10000).block();

				MyClass myClass = new MyClass();
				myClass.message = message;

				client.saveState(STATE_STORE_NAME, key, myClass).block();
				System.out.println("Saving class with message: " + myClass.message);

				return message;
			} catch (Exception ex) {
				throw new RuntimeException(ex)
			}
		});
	}

	public static void main(String[] args) {
		SpringApplication.run(WebApiApplication.class, args);
	}

}
