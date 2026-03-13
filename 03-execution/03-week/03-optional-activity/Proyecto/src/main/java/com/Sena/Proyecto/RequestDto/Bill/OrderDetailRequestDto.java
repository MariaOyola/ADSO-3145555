package com.Sena.Proyecto.RequestDto.Bill;
import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class OrderDetailRequestDto {

    private Integer amount; 
    private BigDecimal subtotal; 

    private Integer id_order; 
    private Integer id_product; 

}
