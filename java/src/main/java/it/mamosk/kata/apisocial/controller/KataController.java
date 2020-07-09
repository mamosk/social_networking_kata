package it.mamosk.kata.apisocial.controller;

import static lombok.AccessLevel.PROTECTED;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import it.mamosk.kata.apisocial.dto.UserDto;
import it.mamosk.kata.apisocial.exception.UserNotFoundException;
import it.mamosk.kata.apisocial.service.KataService;
import lombok.Getter;

@RestController
@RequestMapping("/api/v1")
public class KataController {

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

	@Autowired
	@Getter(PROTECTED)
	private KataService userService;

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

	@GetMapping("/users")
	@ResponseStatus(HttpStatus.OK)
	@ResponseBody
	public List<UserDto> getUsers() {
		return getUserService().getUsers();
	}

	@GetMapping("/users/{name}")
	@ResponseStatus(HttpStatus.OK)
	@ResponseBody
	public UserDto getUser(@PathVariable("name") String name) //
			throws UserNotFoundException {
		return getUserService().getUser(name);
	}

	@PutMapping("/users")
	@ResponseStatus(HttpStatus.CREATED)
	@ResponseBody
	public UserDto createUser(@RequestBody String name) {
		return getUserService().createUser(name);
	}

	@PutMapping("/users/{name}")
	@ResponseStatus(HttpStatus.OK)
	@ResponseBody
	public UserDto updateUser(@PathVariable("name") String name, @RequestBody String follows) //
			throws UserNotFoundException {
		return getUserService().updateUser(name, follows);
	}

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

}