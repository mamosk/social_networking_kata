package it.mamosk.kata.apisocial.dto;

import java.util.Set;

import javax.validation.constraints.NotEmpty;

import lombok.Data;
import lombok.NonNull;

@Data
public class UserDto {

	private String name;

	private Set<UserDto> follows;

}