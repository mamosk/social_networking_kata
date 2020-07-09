package it.mamosk.kata.apisocial.model;

import static javax.persistence.CascadeType.PERSIST;
import static javax.persistence.FetchType.EAGER;

import java.util.Set;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToMany;
import javax.persistence.Table;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;

@Data
@Entity
@Table(name = User.TABLE)
@RequiredArgsConstructor
@NoArgsConstructor // required by Hibernate
public class User {

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

	// table
	public static final String TABLE = "users";

	// columns
	private static final String NAME = "name";
	private static final String FOLLOWS = "follows";

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

	@Id
	@Column(name = NAME)
	private @NonNull String name;

	@Column(name = FOLLOWS)
	@OneToMany(fetch = EAGER, cascade = PERSIST)
	@JoinColumn(name = NAME)
	private Set<User> follows;

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

}