package com.Sena.Proyecto.Repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.Sena.Proyecto.model.Security.Person;

import java.util.List;
public interface IPersonRepository  extends JpaRepository <Person, Integer> {

    List<Person>  findByName(String name);
     List<Person> findByLastname(String lastname);
     List<Person> findByEmail(String email);

    

}
