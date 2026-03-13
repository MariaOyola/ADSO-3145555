package com.Sena.Proyecto.RequestDto.Inventory;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ProductRequetDto {

  private String nameProduct; 
  private BigDecimal price; 
  private String description;
  
  private Integer category; 



}
