package com.Sena.Proyecto.IService.Bill;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import com.Sena.Proyecto.RequestDto.Bill.OrderRequestDto;
import com.Sena.Proyecto.ResponseDto.Bill.OrderResponse;
import com.Sena.Proyecto.ResponseDto.Inventory.ProductResponse;

public interface OrderIService {
     List<OrderResponse> findAll();
    ProductResponse findById (Integer id); 
    List<OrderResponse> findByDate (LocalDate date);
    List<OrderResponse> findByTotal (BigDecimal total); 
    OrderResponse save (OrderRequestDto O); 
    OrderResponse update (Integer id, OrderRequestDto O); 
    void deleteById (Integer id); 
}
