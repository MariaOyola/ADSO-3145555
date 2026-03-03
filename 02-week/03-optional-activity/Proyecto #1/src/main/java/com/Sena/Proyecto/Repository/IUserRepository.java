package com.Sena.Proyecto.Repository;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import com.Sena.Proyecto.model.User;

public interface IUserRepository  extends JpaRepository <User, Integer> {

  List<User> findByNameUser (String nameUser); 

}
