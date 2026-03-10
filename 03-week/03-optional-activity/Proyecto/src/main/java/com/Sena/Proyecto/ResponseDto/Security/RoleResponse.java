package com.Sena.Proyecto.ResponseDto.Security;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RoleResponse {

    private Integer id; 
    private String nameRole;
    private String descripcion; 

}
