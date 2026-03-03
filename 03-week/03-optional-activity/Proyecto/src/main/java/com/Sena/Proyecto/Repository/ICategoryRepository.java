package com.Sena.Proyecto.Repository;

import java.util.List;
import java.util.Locale.Category;

import org.springframework.data.jpa.repository.JpaRepository;

public interface ICategoryRepository extends JpaRepository < Category, Integer>{

    List<Category> findByName_Category (String name_Category ); 
    List<Category> findByDescription (String description ); 


}
