package com.Sena.Proyecto.Repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.Sena.Proyecto.model.Inventory;

public interface IInventoryRepository extends JpaRepository <Inventory, Integer>{

    List<Inventory> findByStok (Integer stok); 
    

}
