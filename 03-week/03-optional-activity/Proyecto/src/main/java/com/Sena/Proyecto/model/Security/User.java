package com.Sena.Proyecto.model.Security;

import java.util.List;

import com.Sena.Proyecto.model.BaseModel;
import com.Sena.Proyecto.model.Bill.Order;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
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

    @ManyToMany
    @JoinTable(name = "user_role", joinColumns = @JoinColumn(name = "id_user"),
    inverseJoinColumns = @JoinColumn(name = "id_role"))
    private List<Role> roles; 

      @OneToMany(mappedBy = "user")
      private List<Order> orders; 
}
