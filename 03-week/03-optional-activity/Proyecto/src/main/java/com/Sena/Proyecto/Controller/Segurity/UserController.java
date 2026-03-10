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

import com.Sena.Proyecto.IService.Security.UserIService;
import com.Sena.Proyecto.RequestDto.Security.UserRequestDto;
import com.Sena.Proyecto.ResponseDto.Security.UserResponse;

@RestController
@RequestMapping ("/User")
public class UserController {

    @Autowired 

    private UserIService service; 

    @GetMapping 
    public List<UserResponse> findAll() {
        return service.findAll(); 
    }


        @GetMapping  ("/{id}")  
        public UserResponse findById (@PathVariable Integer id) {
            return service.findById(id); 
        }

        @GetMapping ("name/{name}")
        public List<UserResponse> findByName(@PathVariable String nameUser ) {
            return service.findByNameUser(nameUser); 


        }
        @PostMapping 
        public UserResponse save( @RequestBody UserRequestDto dto) {
            return service.save(dto); 
        }
         @DeleteMapping  ("/{id}") 

            public void deleteById (@PathVariable Integer id) {
                 service.deleteById(id);

        }
    @PutMapping ("/{id}")
    public UserResponse update (@PathVariable Integer id,@RequestBody UserRequestDto U) {
       return service.update(id, U); 
    }


    
}
