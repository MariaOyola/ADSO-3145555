package com.Sena.Proyecto.Repository;

import com.Sena.Proyecto.model.Role;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface IRoleRepository  extends JpaRepository <Role, Integer> {
  List<Role> findByNameRole (String nameRole); 
}

