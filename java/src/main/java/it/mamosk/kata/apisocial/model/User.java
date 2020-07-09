package it.mamosk.kata.apisocial.model;

import static javax.persistence.CascadeType.PERSIST;
import static javax.persistence.FetchType.EAGER;
import static javax.persistence.GenerationType.IDENTITY;

import java.util.Set;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToMany;
import javax.persistence.Table;

import lombok.Data;

@Data
@Entity
@Table(name = "users")
public class User {

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

	// the key is the simple name of the user
	private static final String K = "name";

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = K)
	private final String name;

	@OneToMany(fetch = EAGER, cascade = PERSIST)
	@JoinColumn(name = K)
	private Set<User> follows;

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

}