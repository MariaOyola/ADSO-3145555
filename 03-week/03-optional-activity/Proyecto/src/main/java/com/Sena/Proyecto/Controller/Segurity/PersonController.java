package com.Sena.Proyecto.Controller.Segurity;

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

import com.Sena.Proyecto.IService.Security.PersonIService;
import com.Sena.Proyecto.RequestDto.Security.PersonRequestDto;
import com.Sena.Proyecto.ResponseDto.Security.PersonResponse;

@RestController // aqui vamos a recibir peticiones 
@RequestMapping ("/Person")
public class PersonController {

    @Autowired
    private PersonIService service; 

    // trar todo los datos

    @GetMapping
    public List<PersonResponse> findAll() {
        return service.findAll(); 

    }

    // buscar por id

    @GetMapping ("/{id}") 
    public PersonResponse findById(@PathVariable Integer id) {
        return service.findById(id); 

    }
    //buscar por nombre
    @GetMapping ("name/{name}")
    public List<PersonResponse> findByName(@PathVariable String name) {
        return service.findByName(name); 
    }

    // Guardar
    @PostMapping
    public PersonResponse save (@RequestBody PersonRequestDto dto) {
        return service.save(dto); 

    }

    // eliminar 
    @DeleteMapping ("/{id}") 
    public void deleteById(@PathVariable Integer id) {
        service.deleteById(id);
    }
    // Actualizae
@PutMapping("/{id}")
public PersonResponse update(@PathVariable Integer id, @RequestBody PersonRequestDto P) {
    return service.update(id, P); 
}

}
