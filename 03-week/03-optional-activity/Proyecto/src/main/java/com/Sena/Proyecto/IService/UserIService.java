package com.Sena.Proyecto.IService;

import java.util.List;

import com.Sena.Proyecto.RequestDto.UserRequestDto;
import com.Sena.Proyecto.ResponseDto.UserResponse;


public interface UserIService {
    List<UserResponse>findAll();  // buscar todos los registros
     UserResponse findById (Integer id); // bueca por id
     List<UserResponse> findByNameUser (String nameUser); // busca por nombre
    UserResponse save (UserRequestDto U); // Expone los datos y los guarda segun lo que envia el usuario
    UserResponse update (Integer id, UserRequestDto U); 
    void deleteById (Integer id);  // eliminar por id


}
