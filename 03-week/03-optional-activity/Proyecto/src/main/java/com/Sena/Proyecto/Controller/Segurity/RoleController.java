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

import com.Sena.Proyecto.IService.Security.RoleIService;
import com.Sena.Proyecto.RequestDto.Security.RoleRequestDto;
import com.Sena.Proyecto.ResponseDto.Security.RoleResponse;

@RestController
@RequestMapping ("/Role")
public class RoleController  {

 @Autowired
 private RoleIService service; 


 @GetMapping 
 public List<RoleResponse> findAll() {
    return service.findAll(); 

}
@GetMapping ("/{id}") 
public RoleResponse findById (@PathVariable Integer id) {
    return service.findById(id); 
}
@GetMapping ("name/{name}")
public List<RoleResponse> findByName (@PathVariable String nameRole) {
    return service.findByNameRole(nameRole); 
}
@PostMapping 
public RoleResponse save (@RequestBody RoleRequestDto dto) {
    return service.save(dto); 

}
@DeleteMapping ("/{id}") 
public void  deleteById (@PathVariable Integer id) {
    service.deleteById(id);
}

@PutMapping ("/{id}") 
public RoleResponse update (@PathVariable Integer id, @RequestBody RoleRequestDto R) { 
     return service.update(id, R); 

}
}
