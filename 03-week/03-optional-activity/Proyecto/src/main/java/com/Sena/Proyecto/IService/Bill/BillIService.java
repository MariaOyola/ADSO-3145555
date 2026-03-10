package com.Sena.Proyecto.IService.Bill;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import com.Sena.Proyecto.RequestDto.Bill.BillDetailRequestDto;
import com.Sena.Proyecto.ResponseDto.Bill.BillResponse;

public interface BillIService {

   List<BillResponse> findAll();
   BillResponse findById (Integer id); 
   List<BillResponse> findByDate_Bill (LocalDate date_Bill);
   List<BillResponse> findByTotal_Bill (BigDecimal total_Bill); 
   BillResponse save (BillDetailRequestDto B); 
   BillResponse update (Integer id, BillDetailRequestDto B); 
   void deleteById (Integer id);

}
