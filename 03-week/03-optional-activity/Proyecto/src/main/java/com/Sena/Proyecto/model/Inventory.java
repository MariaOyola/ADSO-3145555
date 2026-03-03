package com.Sena.Proyecto.model;


import java.util.List;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table (name = "inventory")
public class Inventory extends BaseModel{

    @Column (nullable = false) 
    private Integer stok; 

    @OneToMany (mappedBy =  "inventory") 
    private List<Product> products; 
    
}
