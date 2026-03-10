package com.Sena.Proyecto.IService.Bill;

import java.math.BigDecimal;
import java.util.List;

import com.Sena.Proyecto.RequestDto.Bill.BillDetailRequestDto;
import com.Sena.Proyecto.ResponseDto.Bill.BillDetailResponse;

public interface BillDetailIService {

   List<BillDetailResponse> findAll();
   BillDetailResponse findById (Integer id); 
   List<BillDetailResponse> findByAmount_BillDetail (Integer amount_BillDetail);
   List<BillDetailResponse> findBySubtotal_BillDetail (BigDecimal subtotal_BillDetail); 
   BillDetailResponse save (BillDetailRequestDto Br); 
   BillDetailResponse update (Integer id, BillDetailRequestDto Br); 
   void deleteById (Integer id);

}
