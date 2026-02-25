package com.Sena.Proyecto.IService;

import java.util.List;

import com.Sena.Proyecto.RequestDto.PersonRequestDto;
import com.Sena.Proyecto.ResponseDto.PersonResponse;

public interface PersonIService {
     List<PersonResponse>findAll();  // buscar todos los registros
     PersonResponse findById (Integer id); // bueca por id
     List<PersonResponse> findByName (String name); // busca por nombre
     PersonResponse save (PersonRequestDto P); // Expone los datos y los guarda segun lo que envia el usuario
     PersonResponse update ( Integer id, PersonRequestDto P); // Actualiza por id y lo que envia el usuario
    void deleteById (Integer id);  // eliminar por id



}
