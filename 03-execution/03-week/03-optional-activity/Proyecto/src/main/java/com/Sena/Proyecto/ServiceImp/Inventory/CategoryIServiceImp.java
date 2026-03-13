package com.Sena.Proyecto.ServiceImp.Inventory;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.Sena.Proyecto.IService.Inventory.CategoryIService;
import com.Sena.Proyecto.Repository.Inventory.ICategoryRepository;
import com.Sena.Proyecto.RequestDto.Inventory.CategoryRequestDto;
import com.Sena.Proyecto.ResponseDto.Inventory.CategoryResponse;
import com.Sena.Proyecto.model.Inventory.Category;

@Service
public class CategoryIServiceImp implements CategoryIService {

    @Autowired
    private ICategoryRepository repository;

 @Override
public List<CategoryResponse> findAll() {
    return repository.findAll().stream().map(this::modelTodto).toList(); 
}

@Override
public CategoryResponse findById(Integer id) {
    Category category = repository.findById(id).orElse(null); 

    if (category == null) {
        return null;
    }

    return modelTodto(category);
}

    @Override
    public List<CategoryResponse> findByNameCategory(String nameCategory) {
       return repository.findByNameCategory(nameCategory)
       .stream().map(this::modelTodto).toList(); 
    }

    @Override
    public CategoryResponse save(CategoryRequestDto C) {

        Category category = dtoToModel(C);
        Category saved = repository.save(category);

        return modelTodto(saved);
    }

    @Override
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }

    @Override
    public CategoryResponse update(Integer id, CategoryRequestDto C) {
        Category category = repository.findById(id).orElse(null);

        if (category == null) {
            return null;
        }

        category.setNameCategory(C.getNameCategory());
        repository.save(category); 

        return modelTodto(category);
    }

    // Convertir DTO → Modelo
    private Category dtoToModel(CategoryRequestDto C) {
        Category category = new Category();
        category.setNameCategory(C.getNameCategory());
        return category;
    }

    // Convertir Modelo → DTO
    private CategoryResponse modelTodto(Category category) {
        CategoryResponse dto = new CategoryResponse();

        dto.setId(category.getId());
        dto.setNameCategory(category.getNameCategory());

        return dto;
    }
}


