package com.Sena.Proyecto.RequestDto.Bill; 

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
public class BillRequestDto {

   private LocalDate dateBill; 
    private BigDecimal totalBill; 
    private Integer id_order; 
  

}
