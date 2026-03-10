package com.Sena.Proyecto.Repository;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List; 
import com.Sena.Proyecto.model.Person;
public interface IPersonRepository  extends JpaRepository <Person, Integer> {

    List<Person>  findByName(String name);
     List<Person> findByLastname(String lastname);
     List<Person> findByEmail(String email);

    

}
