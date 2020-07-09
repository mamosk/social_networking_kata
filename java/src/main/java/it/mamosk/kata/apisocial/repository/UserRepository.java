package it.mamosk.kata.apisocial.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import it.mamosk.kata.apisocial.model.User;

@Repository
public interface UserRepository extends JpaRepository<User, String> {

}