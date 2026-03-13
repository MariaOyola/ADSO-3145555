package com.Sena.Proyecto.IService.Bill;

import java.math.BigDecimal;
import java.util.List;

import com.Sena.Proyecto.RequestDto.Bill.OrderDetailRequestDto;
import com.Sena.Proyecto.ResponseDto.Bill.OrderDetailResponse;

public interface OrderDetailIService {

   List<OrderDetailResponse> findAll();
   OrderDetailResponse findById (Integer id); 
   List<OrderDetailResponse> findByAmount (Integer amount);
   List<OrderDetailResponse> findBySubtotal (BigDecimal subtotal); 
   OrderDetailResponse save (OrderDetailRequestDto Or); 
   OrderDetailResponse update (Integer id, OrderDetailRequestDto Or); 
   void deleteById (Integer id); 

}
