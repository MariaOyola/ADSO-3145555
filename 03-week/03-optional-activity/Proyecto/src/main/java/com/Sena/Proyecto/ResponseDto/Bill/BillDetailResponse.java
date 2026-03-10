package com.Sena.Proyecto.ResponseDto.Bill;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class BillDetailResponse {

    private Integer id; 
    private Integer amount_BillDetail; 
    private BigDecimal subtotal_BillDetail; 

    private Integer id_bill; 
    private Integer id_product; 

}
