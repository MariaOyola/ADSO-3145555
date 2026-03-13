package com.Sena.Proyecto.model.Inventory;

import java.util.List;

import com.Sena.Proyecto.model.BaseModel;

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
    private String nameCategory; 

    @OneToMany (mappedBy = "category")
    private List<Product> products; 



}
