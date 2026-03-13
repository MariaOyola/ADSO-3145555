package com.Sena.Proyecto.Controller.Inventory;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.Sena.Proyecto.IService.Inventory.CategoryIService;
import com.Sena.Proyecto.RequestDto.Inventory.CategoryRequestDto;
import com.Sena.Proyecto.ResponseDto.Inventory.CategoryResponse;

@RestController
@RequestMapping ("/Category")
public class CategorynController {

    @Autowired
    private CategoryIService service; 

    // trar todo los datos

    @GetMapping
    public List<CategoryResponse> findAll() {
        return service.findAll(); 

    }

    // buscar por id

    @GetMapping ("/{id}") 
    public CategoryResponse findById(@PathVariable Integer id) {
        return service.findById(id); 

    }
    //buscar por nombre
    @GetMapping ("name/{name}")
    public List<CategoryResponse> findByNameCategory(@PathVariable String nameCategory) {
        return service.findByNameCategory(nameCategory); 
    }

    // Guardar
    @PostMapping
    public CategoryResponse save (@RequestBody CategoryRequestDto dto) {
        return service.save(dto); 

    }

    // eliminar 
    @DeleteMapping ("/{id}") 
    public void deleteById(@PathVariable Integer id) {
        service.deleteById(id);
    }
    // Actualizae
@PutMapping("/{id}")
public CategoryResponse update(@PathVariable Integer id, @RequestBody CategoryRequestDto C) {
    return service.update(id, C); 
}

}


