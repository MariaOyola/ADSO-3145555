package com.Sena.Proyecto.ServiceImp;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.Sena.Proyecto.IService.RoleIService;
import com.Sena.Proyecto.Repository.IRoleRepository;
import com.Sena.Proyecto.RequestDto.RoleRequestDto;
import com.Sena.Proyecto.ResponseDto.RoleResponse;
import com.Sena.Proyecto.model.Role;


@Service
public class RoleServiceImp implements RoleIService {

    @Autowired 
    private IRoleRepository repository; 


    @Override
    public List<RoleResponse> findAll () {
        return repository.findAll().stream().map(this::modelTodto).toList(); 

    }
    @Override
    public RoleResponse findById( Integer id) {
        Role role = repository.findById(id).orElse(null); 

        if (role == null) {
            return null; 
        }
        return modelTodto(role); 
    } 

     @Override
    public List<RoleResponse> findByNameRole (String nameRole ) {
        return repository.findByNameRole(nameRole).stream().map(this::modelTodto).toList();  
    }

 @Override 
 public RoleResponse save (RoleRequestDto R) {
    Role role = dtoToModel(R); 
    Role saved = repository.save(role); 
    return modelTodto(saved); 

 }
 @Override
 public void deleteById  (Integer id) {
    repository.deleteById(id);
 }

    @Override 
    public RoleResponse update (Integer id, RoleRequestDto R) {
        Role role = repository.findById(id).orElse(null); 

        if(role == null) {
            return null; 
        }

         role.setNameRole(R.getNameRole());
         role.setDescription(R.getDescription());
          repository.save(role); 

          return modelTodto(role); 
    
 }

    // convertir de DTO A model 

    public Role dtoToModel(RoleRequestDto R) {
        Role role = new Role(); 
        role.setNameRole(R.getNameRole());
        role.setDescription(R.getDescription());

        return role; 

    } 

    public RoleResponse modelTodto(Role role) {
        RoleResponse dto = new RoleResponse(); 
        dto.setId(role.getId());
        dto.setNameRole(role.getNameRole());
        dto.setDescripcion(role.getDescription());

        return dto; 
    }

}
