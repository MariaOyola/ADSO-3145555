package com.Sena.Proyecto.Repository.Inventory;

import java.util.List;
import com.Sena.Proyecto.model.Inventory.Category;

import org.springframework.data.jpa.repository.JpaRepository;

public interface ICategoryRepository extends JpaRepository < Category, Integer>{

    List<Category> findByNameCategory (String nameCategory );


}
