package com.Sena.Proyecto.ServiceImp.Segurity;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.Sena.Proyecto.IService.Security.PersonIService;
import com.Sena.Proyecto.Repository.Security.IPersonRepository;
import com.Sena.Proyecto.RequestDto.Security.PersonRequestDto;
import com.Sena.Proyecto.ResponseDto.Security.PersonResponse;
import com.Sena.Proyecto.model.Security.Person;

@Service  // es una clase service
public class PersonServiceImp implements PersonIService  {

    @Autowired // crea automaticamente repository y es como una conexion a la base de datos
    private IPersonRepository repository; 

    @Override  // llamo una listade de personas y la convierto en dto para mostrar al usuario
    public List<PersonResponse>findAll() {
        return repository.findAll().stream().map(this:: modelTodto).toList(); 
                                    // recorro una lista  que convierto a dto y lo concierto a lista para mostrar al usuario 
    }
    @Override
    public PersonResponse findById(Integer id) {  // buscar por id y convierte a dto para mostrar al usuario
        Person person = repository.findById(id).orElse(null); 

        if (person == null) {
            return null; 
        }
        return modelTodto(person); 

    }
    @Override
    public List<PersonResponse> findByName (String name) {
        return repository.findByName(name).stream().map(this::modelTodto).toList(); 

    }

    @Override // llega DTO lo convierto a model para guardarlo  en la base de datos y luego lo convierto a dto para mostrar al usuario
    public PersonResponse save (PersonRequestDto P) {
        Person person = dtoToModel(P); 
        Person saved = repository.save(person); 
        return modelTodto(saved); 
    }
    @Override
    
    public void deleteById (Integer id) {
    repository.deleteById(id);
    }

    @Override
    public   PersonResponse update ( Integer id, PersonRequestDto P) { // buscamos por id
        Person person = repository.findById(id).orElse(null);  //si no encuentra nada devulve null
        if (person == null) { // si no encuentra no pasa nada
            return null; 
        }
        person.setName(P.getName()); // actualizamos los datos que nos envio el usuario 
        person.setLastname(P.getLastname());
        person.setEmail(P.getEmail());
        repository.save(person);    // se guarda el nuevo cambio en la base de datos
        return modelTodto(person);  // lo convierto en dto para mostar al usuario
    }

    // vamos a pasr de Dto a Model 

       public Person dtoToModel (PersonRequestDto P) { // llega un dto lo convierto a model para guardar en la nbase de datos
        Person person = new Person();  // creo nuevo ogjeto de tipo persona
        person.setName(P.getName()); // copio los datos del dto al model  para guardarse en la base de datos 
        person.setLastname(P.getLastname());
        person.setEmail(P.getEmail());

        return person;  // devuelvo la entidad de 
       } 

       // ahora de MOdel a dto
       public PersonResponse modelTodto(Person person) {
        PersonResponse dto = new PersonResponse(); 
        dto.setId(person.getId());
        dto.setName(person.getName());
        dto.setLastname(person.getLastname()); 
        dto.setEmail(person.getEmail());

        return dto; 
       }

}
