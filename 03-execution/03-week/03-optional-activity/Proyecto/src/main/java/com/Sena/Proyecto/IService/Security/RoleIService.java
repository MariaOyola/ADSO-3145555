package com.Sena.Proyecto.IService.Security;

import java.util.List;

import com.Sena.Proyecto.RequestDto.Security.RoleRequestDto;
import com.Sena.Proyecto.ResponseDto.Security.RoleResponse;

public interface RoleIService { 

        List<RoleResponse>findAll();  // buscar todos los registros
     RoleResponse findById (Integer id); // bueca por id
     List<RoleResponse> findByNameRole (String nameRole); // busca por nombre
    RoleResponse save (RoleRequestDto R); // Expone los datos y los guarda segun lo que envia el usuario
    RoleResponse update (Integer id, RoleRequestDto R); 
    void deleteById (Integer id);  // eliminar por id

    

}
