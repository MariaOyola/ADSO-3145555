package com.Sena.Proyecto.IService.Inventory;

import java.util.List;

import com.Sena.Proyecto.RequestDto.Inventory.ProductRequetDto;
import com.Sena.Proyecto.ResponseDto.Inventory.ProductResponse;

public interface ProductIService {
    List<ProductResponse> findAll();
    ProductResponse findById (Integer id); 
    List<ProductResponse> findByName_Product (String name_Product); 
    ProductResponse save (ProductRequetDto Pr); 
    ProductResponse update (Integer id, ProductRequetDto Pr); 
    void deleteById (Integer id); 
}
