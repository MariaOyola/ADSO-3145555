package com.Sena.Proyecto.Repository.Security;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

import com.Sena.Proyecto.model.Security.Role;

public interface IRoleRepository  extends JpaRepository <Role, Integer> {
  List<Role> findByNameRole (String nameRole); 
}

