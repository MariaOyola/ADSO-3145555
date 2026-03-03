package com.Sena.Proyecto.ResponseDto;

import java.util.List;

import com.Sena.Proyecto.model.Product;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class InventoryResponse {

    private Integer id; 
    private Integer stok; 

    private List<Product>products; 





}
