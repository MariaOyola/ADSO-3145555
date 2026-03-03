package com.Sena.Proyecto.RequestDto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RoleRequestDto {
     // Request  es lo que nos envia el usuario, en este caso el usuario  nos envia (nombre rol, descripcion )

     private String nameRole;
     private String description; 


}
