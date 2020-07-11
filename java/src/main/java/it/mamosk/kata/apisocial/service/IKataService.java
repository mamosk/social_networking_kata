package it.mamosk.kata.apisocial.service;

import java.util.List;

import javax.validation.constraints.NotEmpty;

import it.mamosk.kata.apisocial.dto.UserDto;
import it.mamosk.kata.apisocial.exception.UserNotFoundException;

public interface IKataService {

	List<UserDto> getUsers();

	UserDto getUser(String name) throws UserNotFoundException;

	UserDto createUser(String name);

	UserDto updateUser(String name, String follows);

}