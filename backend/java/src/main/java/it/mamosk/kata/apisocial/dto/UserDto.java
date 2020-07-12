package it.mamosk.kata.apisocial.dto;

import java.util.Set;

import lombok.Data;

@Data
public class UserDto {

	private String name;

	private Set<String> follows;

}