package com.Sena.Proyecto.IService.Bill;

import java.math.BigDecimal;
import java.util.List;

import com.Sena.Proyecto.RequestDto.Bill.BillDetailRequestDto;
import com.Sena.Proyecto.ResponseDto.Bill.BillDetailResponse;

public interface BillDetailIService {

   List<BillDetailResponse> findAll();
   BillDetailResponse findById (Integer id); 
   List<BillDetailResponse> findByAmountBillDetail (Integer amountBillDetail);
   List<BillDetailResponse> findBySubtotalBillDetail (BigDecimal subtotalBillDetail); 
   BillDetailResponse save (BillDetailRequestDto Br); 
   BillDetailResponse update (Integer id, BillDetailRequestDto Br); 
   void deleteById (Integer id);

}
