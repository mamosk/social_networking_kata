package it.mamosk.kata.apisocial;

import static org.junit.jupiter.api.Assertions.assertNotNull;

import org.junit.jupiter.api.Test;

import it.mamosk.kata.apisocial.model.User;
import lombok.val;

class EntityTests {

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

	@Test
	void userFollowsNotNull() {
		val user = new User();
		assertNotNull( //
				user.getFollows(), //
				"User 'follows' set is null");
	}

	// *******************************************************************
	// *******************************************************************
	// *******************************************************************

}
