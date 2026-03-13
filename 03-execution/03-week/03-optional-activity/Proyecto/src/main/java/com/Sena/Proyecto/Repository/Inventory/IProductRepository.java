package com.Sena.Proyecto.Repository.Inventory;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.Sena.Proyecto.model.Inventory.Product;

public interface IProductRepository extends JpaRepository <Product, Integer> {

    List<Product> findByNameProduct (String nameProduct); 
    List<Product> findByPrice (BigDecimal price); 
    List<Product> findByDescription (String description); 
    
    List<Product> findByCategoryId(Integer id);





}
