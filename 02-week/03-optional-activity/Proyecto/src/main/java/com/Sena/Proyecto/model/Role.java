package com.Sena.Proyecto.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
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
@Table(name = "role")

public class Role extends BaseModel {

    @Column (length = 50) 
        private String  nameRole; 

        @Column(length = 50)
        private String descripcion; 

        @ManyToOne
        @JoinColumn (name = "id_user")
        private User user; 

     
}

