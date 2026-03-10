package com.Sena.Proyecto.ResponseDto.Inventory;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CategoryResponse {

    private Integer id; 
    private String name_Category;
    private String description;

    private List<ProductResponse> products; 
 
}
