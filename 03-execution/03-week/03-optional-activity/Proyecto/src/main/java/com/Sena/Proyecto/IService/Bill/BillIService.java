package com.Sena.Proyecto.IService.Bill;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import com.Sena.Proyecto.RequestDto.Bill.BillRequestDto;
import com.Sena.Proyecto.ResponseDto.Bill.BillResponse;

public interface BillIService {

   List<BillResponse> findAll();
   BillResponse findById (Integer id); 
   List<BillResponse> findByDateBill (LocalDate dateBill);
   List<BillResponse> findByTotalBill (BigDecimal totalBill); 
   BillResponse save (BillRequestDto B); 
   BillResponse update (Integer id, BillRequestDto B); 
   void deleteById (Integer id);

}
