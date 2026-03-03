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
@Table(name = "category")
@NoArgsConstructor
@AllArgsConstructor
public class Category extends BaseModel {

    @Column (length = 50 ) 
    private String name_Category; 

    @Column (length = 50) 
    private String description;

    @OneToMany (mappedBy = "category")
    private List<Product> products; 



}
