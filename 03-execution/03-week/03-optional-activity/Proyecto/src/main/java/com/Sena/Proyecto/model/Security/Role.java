package com.Sena.Proyecto.model.Security;

import java.util.List;

import com.Sena.Proyecto.model.BaseModel;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.ManyToMany;
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
@Table(name = "roles")

public class Role extends BaseModel {

    @Column (length = 50) 
        private String  nameRole; 

        @Column(length = 50)
        private String description; 

        @ManyToMany (mappedBy = "roles")
        private List<User> users;  
        

     
}

