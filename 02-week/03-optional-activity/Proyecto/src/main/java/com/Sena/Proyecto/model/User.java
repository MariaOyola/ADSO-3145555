package com.Sena.Proyecto.model;

import java.util.List;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
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
@Table(name = "users")

public class User extends BaseModel {

    @Column(length = 50)
    private String nameUser;

    @Column(length = 50)
    private String password;

    @OneToOne
    @JoinColumn(name = "id_person", unique = true)
    private Person person;

    @OneToMany(mappedBy = "user")
    private List<Role> roles; ;      
}
