package com.Sena.Proyecto.RequestDto.Security;


import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PersonRequestDto {

    // Request  es lo que nos envia el usuario, en este caso el usuario  nos envia (nombre, apellido, telefono, enail )

    private String name; 
    private String lastname; 
    private String phone; 
    private String email; 
}

