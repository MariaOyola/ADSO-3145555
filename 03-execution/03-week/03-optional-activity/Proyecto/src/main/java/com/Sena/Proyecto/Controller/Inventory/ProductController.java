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

import com.Sena.Proyecto.IService.Inventory.ProductIService;
import com.Sena.Proyecto.RequestDto.Inventory.ProductRequetDto;
import com.Sena.Proyecto.ResponseDto.Inventory.ProductResponse;

@RestController // aqui vamos a recibir peticiones 
@RequestMapping ("/Product")
public class ProductController {
    
  
    @Autowired
    private ProductIService service; 

    // trar todo los datos

    @GetMapping
    public List<ProductResponse> findAll() {
        return service.findAll();  

    }

    // buscar por id

    @GetMapping ("/{id}") 
    public ProductResponse findById(@PathVariable Integer id) {
        return service.findById(id); 

    }
    //buscar por nombre
    @GetMapping ("name/{name}")
    public List<ProductResponse> findByNameProduct(@PathVariable String nameProduct) {
        return service.findByNameProduct(nameProduct); 
    }

    // Guardar
    @PostMapping
    public ProductResponse save (@RequestBody ProductRequetDto dto) {
        return service.save(dto); 

    }

    // eliminar 
    @DeleteMapping ("/{id}") 
    public void deleteById(@PathVariable Integer id) {
        service.deleteById(id);
    }
    // Actualizae
@PutMapping("/{id}")
public ProductResponse update(@PathVariable Integer id, @RequestBody ProductRequetDto Pr) {
    return service.update(id, Pr); 
}
  

}
