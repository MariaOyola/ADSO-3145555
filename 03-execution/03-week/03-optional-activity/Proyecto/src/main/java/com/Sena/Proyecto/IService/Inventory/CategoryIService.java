package com.Sena.Proyecto.IService.Inventory;

import java.util.List;

import com.Sena.Proyecto.RequestDto.Inventory.CategoryRequestDto;
import com.Sena.Proyecto.ResponseDto.Inventory.CategoryResponse;

public interface CategoryIService {
    List<CategoryResponse> findAll (); 
    CategoryResponse findById (Integer id); 
    List<CategoryResponse>findByNameCategory (String nameCategory); 
    CategoryResponse save (CategoryRequestDto C); 
    CategoryResponse update (Integer id, CategoryRequestDto C); 
    void deleteById (Integer id); 
}
