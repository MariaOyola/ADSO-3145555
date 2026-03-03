package com.Sena.Proyecto.ResponseDto;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ProductResponse {

    private Integer id; 
    private String name_Product; 
    private BigDecimal price; 
    private String description;

    private Integer category;
    private String name_Category;  



}
