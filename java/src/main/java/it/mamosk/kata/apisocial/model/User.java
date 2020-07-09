package it.mamosk.kata.apisocial.model;

import static javax.persistence.FetchType.LAZY;

import java.util.HashSet;
import java.util.Set;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.Table;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;

@Data
@Entity
@Table(name = User.TABLE)
@RequiredArgsConstructor
@NoArgsConstructor // required by Hibernate
@EqualsAndHashCode(exclude = "follows")
public class User {

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

	// tables
	public static final String TABLE = "users";
	public static final String JOINTABLE = "followers";

	// columns
	public static final String NAME = "name";
	public static final String FOLLOWS = "follows";

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

	@Id
	@Column(name = NAME)
	private @NonNull String name;

	@ManyToMany(fetch = LAZY)
	@JoinTable(name = JOINTABLE, //
			joinColumns = { @JoinColumn(name = NAME) }, //
			inverseJoinColumns = { @JoinColumn(name = FOLLOWS) } //
	)
	private Set<User> follows = new HashSet<>();

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

	@Override
	// no need to know about followers
	public String toString() {
		return getName();
	}

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

}