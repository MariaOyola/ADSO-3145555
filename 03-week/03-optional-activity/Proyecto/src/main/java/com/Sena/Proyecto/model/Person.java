package com.Sena.Proyecto.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
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
@Table (name = "person")
public class Person extends BaseModel {

@Column (length = 50) 
private String name; 

@Column (length = 20)
private String lastname; 

@Column (length = 20) 
private String phone;

@Column (length = 50) 
private String email; 

@OneToOne (mappedBy = "person") 
private User user; 

}