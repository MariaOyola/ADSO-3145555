package com.Sena.Proyecto.ResponseDto.Security;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PersonResponse {

    // Response es lo que se le responde al usuario osea lo que le voy a mostrar al usuario

    private Integer id; 
    private String name; 
    private String lastname; 
    private String email; 

}
