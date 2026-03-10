package com.Sena.Proyecto.ResponseDto.Bill;

import java.math.BigDecimal;
import java.time.LocalDate;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class OrderResponse {

    private Integer id; 
    private LocalDate date;  
    private BigDecimal total;

    private Integer id_user; 
    private String name_user; 

}
