package com.Sena.Proyecto.model;


import java.math.BigDecimal;

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
@Table( name = "orderDetail")

public class OrderDetail extends BaseModel {

 @Column (nullable = false)
 private Integer amount; 
 
 @Column (precision = 10, scale = 2, nullable = false)
 private BigDecimal subtotal; 

@ManyToOne
@JoinColumn(name = "id_order")
private Order order;

 @ManyToOne
@JoinColumn(name = "id_product")
private Product product;


}
 
