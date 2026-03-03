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
@Table(name = "billDetail")
public class BillDetail extends BaseModel {

@Column (nullable = false)
 private Integer amount_BillDetail; 
 
 @Column (precision = 10, scale = 2, nullable = false)
 private BigDecimal subtotal_BillDetail; 

@ManyToOne
@JoinColumn(name = "id_bill")
private Bill bill; 

@ManyToOne
@JoinColumn(name = "id_product")
private Product product;


}
