package it.mamosk.kata.apisocial.service;

import static java.util.stream.Collectors.toList;
import static lombok.AccessLevel.PROTECTED;

import java.util.Collection;
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
public class KataService implements IKataService {

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

	// convert one
	protected UserDto convert(User user) {
		return getModelMapper().map(user, UserDto.class);
	}

	// convert many
	protected List<UserDto> convert(final Collection<User> users) {
		return users.stream().map(this::convert).collect(toList());
	}

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

	@Override
	public List<UserDto> getUsers() {
		val users = find();
		val usersDto = convert(users);
		return usersDto;
	}

	@Override
	public UserDto getUser(String name) throws UserNotFoundException {
		val user = find(name);
		val userDto = convert(user);
		return userDto;
	}

	@Override
	public UserDto createUser(@NotEmpty String name) {
		User user = findOrAdd(name);
		val userDto = convert(user);
		return userDto;
	}

	@Override
	public UserDto updateUser(@NotEmpty String name, @NotEmpty String follows) {
		var user = findOrAdd(name);
		val followed = findOrAdd(follows);
		user.getFollows().add(followed); // no null-check needed for 'follows' set
		user = getUserRepository().save(user);
		val userDto = convert(user);
		return userDto;
	}

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

	private List<User> find() {
		return getUserRepository().findAll();
	}

	private User save(String name) {
		return save(new User(name));
	}

	private User save(User user) {
		return getUserRepository().save(user);
	}

	private User find(String name) throws UserNotFoundException {
		return getUserRepository().findById(name).orElseThrow(() -> missing(name));
	}

	private User findOrAdd(String name) {
		return getUserRepository().findById(name).orElseGet(() -> save(name));
	}

	// *******************************************************************

	// shortcut for new exception
	private UserNotFoundException missing(String name) {
		return new UserNotFoundException(name);
	}

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

}