package com.Sena.Proyecto.ServiceImp;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.Sena.Proyecto.IService.UserIService;
import com.Sena.Proyecto.Repository.IUserRepository;
import com.Sena.Proyecto.RequestDto.UserRequestDto;
import com.Sena.Proyecto.ResponseDto.UserResponse;
import com.Sena.Proyecto.model.Security.User;

@Service
public class UserServiceImp implements UserIService {

    @Autowired
    private IUserRepository repository;


    @Override

    public List<UserResponse>findAll () {
        return repository.findAll().stream().map(this::modelTodto).toList(); 


    }
    @Override
    public UserResponse findById (Integer id) {
        User user = repository.findById(id).orElse(null); 
    
    if (user == null) {
        return null; 
    }
    return modelTodto(user); 
}

@Override
public List<UserResponse> findByNameUser (String name) {
    return repository.findByNameUser(name).stream().map(this::modelTodto).toList(); 

}
@Override 
public UserResponse save (UserRequestDto U) {
    User user = dtoToModel(U);
    User saved = repository.save(user); 
    return modelTodto(saved); 

}
@Override 
public void deleteById (Integer id) {
    repository.deleteById(id);

}

@Override
public UserResponse update (Integer id, UserRequestDto U) {  
    User user = repository.findById(id).orElse(null); 

    if (user == null) {
        return null; 
    }
    user.setNameUser(U.getNameUser());
    repository.save(user); 
    return modelTodto(user); 



    
}

public User dtoToModel (UserRequestDto U) {
    User user = new User(); 
    user.setNameUser(U.getNameUser());
    user.setPassword(U.getPassword());

    return user; 

}
public UserResponse modelTodto (User user) {
    UserResponse dto = new UserResponse(); 
    dto.setId(user.getId());
    dto.setNameUser(user.getNameUser());

    return dto; 
    }
}

