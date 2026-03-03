package com.Sena.Proyecto.Repository;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import com.Sena.Proyecto.model.Product;

public interface IProductRepository extends JpaRepository <Product, Integer> {

    List<Product> findByName_Product (String name_Product); 
    List<Product> findByPrice (BigDecimal price); 
    List<Product> findByDescription (String description); 
    
    List<Product> findByCategory (Integer category); 





}
