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
public class BillResponse {

    private Integer id; 
    private LocalDate date_Bill; 
    private BigDecimal total_Bill; 

    private Integer id_order; 
}
