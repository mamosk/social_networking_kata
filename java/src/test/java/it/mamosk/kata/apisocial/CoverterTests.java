package it.mamosk.kata.apisocial;

import static java.util.function.Function.identity;
import static java.util.stream.Collectors.toList;
import static java.util.stream.Collectors.toMap;
import static lombok.AccessLevel.PRIVATE;
import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.stream.Stream;

import org.junit.jupiter.api.Test;
import org.modelmapper.ModelMapper;

import it.mamosk.kata.apisocial.dto.UserDto;
import it.mamosk.kata.apisocial.model.User;
import lombok.Getter;
import lombok.val;
import net.bytebuddy.utility.RandomString;

class CoverterTests {

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

	@Getter(value = PRIVATE, lazy = true)
	private final ModelMapper modelMapper = initModelMapper();

	private ModelMapper initModelMapper() {
		return new ModelMapper();
	}

	// *******************************************************************

	@Test
	void modelMapperOne() {
		val name = newName();
		val user = new User(name);
		val userDto = convert(user);
		assertEquals( //
				user.getName(), //
				userDto.getName(), //
				"the DTO name is not equals to entity name" //
		);
	}

	@Test
	void modelMapperMany() {
		val users = Stream.generate(this::newName).limit(3).collect(toMap(identity(), User::new));
		val usersDto = users.values().stream().map(this::convert).collect(toList());
		usersDto.forEach(userDto -> assertEquals( //
				userDto.getName(), //
				users.get(userDto.getName()).getName(), //
				"at least one of the DTO names is not equals to its corresponding entity name")//
		);
	}

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

	private String newName() {
		return RandomString.make(7);
	}

	// *******************************************************************

	private UserDto convert(final User user) {
		return getModelMapper().map(user, UserDto.class);
	}

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

}
