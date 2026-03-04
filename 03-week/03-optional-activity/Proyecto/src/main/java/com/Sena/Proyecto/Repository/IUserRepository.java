package com.Sena.Proyecto.Repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.Sena.Proyecto.model.Security.User;

import java.util.List;

public interface IUserRepository  extends JpaRepository <User, Integer> {

  List<User> findByNameUser (String nameUser); 

}
