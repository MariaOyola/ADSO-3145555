package com.Sena.Proyecto.RequestDto.Security;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserRequestDto {

    // Request  es lo que nos envia el usuario, en este caso el usuario  nos envia (nombre del usuario y contraseña )
    private String nameUser; 
    private String password; 

}
