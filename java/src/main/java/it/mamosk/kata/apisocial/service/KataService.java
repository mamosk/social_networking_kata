package it.mamosk.kata.apisocial.service;

import static java.util.stream.Collectors.toList;
import static lombok.AccessLevel.PROTECTED;

import java.util.List;

import javax.validation.constraints.NotEmpty;

import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import it.mamosk.kata.apisocial.dto.UserDto;
import it.mamosk.kata.apisocial.exception.UserNotFoundException;
import it.mamosk.kata.apisocial.model.User;
import it.mamosk.kata.apisocial.repository.UserRepository;
import lombok.Getter;
import lombok.val;
import lombok.var;

@Service
public class KataService {

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

	@Autowired
	@Getter(PROTECTED)
	private UserRepository userRepository;

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

	@Autowired
	@Getter(PROTECTED)
	private ModelMapper modelMapper; // http://modelmapper.org/

	// from entity to DTO
	protected UserDto convert(User user) {
		return getModelMapper().map(user, UserDto.class);
	}

	// from DTO to entity
	protected User convert(UserDto user) {
		return getModelMapper().map(user, User.class);
	}

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

	public List<UserDto> getUsers() {
		val users = getUserRepository().findAll();
		val usersDto = users.stream().map(this::convert).collect(toList());
		return usersDto;
	}

	public UserDto getUser(String name) //
			throws UserNotFoundException {
		val user = find(name);
		val userDto = convert(user);
		return userDto;
	}

	public UserDto createUser(@NotEmpty String name) {
		var user = new User(name);
		user = getUserRepository().save(user);
		val userDto = convert(user);
		return userDto;
	}

	public UserDto updateUser(@NotEmpty String name, @NotEmpty String follows) //
			throws UserNotFoundException {
		var user = find(name);
		var followed = find(follows);
		user.getFollows().add(followed);
		user = userRepository.save(user);
		val userDto = convert(user);
		return userDto;
	}

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

	// shortcut for findById(String) throwing exception
	private User find(String name) throws UserNotFoundException {
		return getUserRepository().findById(name).orElseThrow(() -> missing(name));
	}

	// shortcut for new exception
	private UserNotFoundException missing(String name) {
		return new UserNotFoundException(name);
	}

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

}