package it.mamosk.kata.apisocial.dto;

import java.util.Set;

import javax.validation.constraints.NotEmpty;

import lombok.Data;

@Data
public class UserDto {

	@NotEmpty
	private String name;

	private final Set<UserDto> follows;

}