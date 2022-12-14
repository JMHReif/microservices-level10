package com.jmhreif.service2;

import lombok.AllArgsConstructor;
import lombok.Data;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.retry.annotation.EnableRetry;
import org.springframework.retry.annotation.Retryable;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Flux;

@SpringBootApplication
@EnableRetry
public class Service2Application {
	public static void main(String[] args) {
		SpringApplication.run(Service2Application.class, args);
	}

	@Bean
	@LoadBalanced
	WebClient.Builder createLoadBalancedBuilder() { return WebClient.builder(); }

	@Bean
	WebClient client(WebClient.Builder builder) { return builder.baseUrl("http://mongo-client").build(); }
}

@RestController
@RequestMapping("/goodreads")
@AllArgsConstructor
class BookController {
	private final WebClient client;

	@GetMapping
	String liveCheck() { return "Service2 is up"; }

	@Retryable
	@GetMapping("/books")
	Flux<Book> getBooks() {
		return client.get()
				.uri("/db/books")
				.retrieve()
				.bodyToFlux(Book.class);
	}
}

@Data
class Book {
	private String mongoId;
	private String book_id;
	private String title, format, isbn, isbn13, edition_information;
}
