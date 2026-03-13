package com.Sena.Proyecto.ServiceImp.Bill;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.Sena.Proyecto.IService.Bill.OrderDetailIService;
import com.Sena.Proyecto.Repository.Bill.IOrderDetailRepository;
import com.Sena.Proyecto.RequestDto.Bill.OrderDetailRequestDto;
import com.Sena.Proyecto.ResponseDto.Bill.OrderDetailResponse;
import com.Sena.Proyecto.model.Bill.OrderDetail;

@Service
public class OrderDetailIServiceImp implements OrderDetailIService {

  
    @Autowired
    private IOrderDetailRepository repository;

    @Override
    public List<OrderDetailResponse> findAll() {
        return repository.findAll().stream().map(this::modelTodto).toList();
    }

@Override
public OrderDetailResponse  findById(Integer id) {
    OrderDetail orderDetail = repository.findById(id).orElse(null);

    if (orderDetail == null) {
        return null;
    }
    return modelTodto(orderDetail);
}
    @Override
    public List<OrderDetailResponse> findByAmount(Integer amount) {
        return repository.findByAmount(amount)
                .stream()
                .map(this::modelTodto)
                .toList();
    }

    @Override
    public List<OrderDetailResponse> findBySubtotal(BigDecimal  subtotal) {
        return repository.findBySubtotal(subtotal)
                .stream()
                .map(this::modelTodto)
                .toList();
    }

    @Override
    public OrderDetailResponse save(OrderDetailRequestDto Or) {
        OrderDetail orderDetail = dtoToModel(Or);
        OrderDetail saved = repository.save(orderDetail);
        return modelTodto(saved);
    }

    @Override
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }

    @Override
    public OrderDetailResponse update(Integer id, OrderDetailRequestDto Or) {

        OrderDetail orderDetail = repository.findById(id).orElse(null);

        if (orderDetail == null) {
            return null;
        }
        orderDetail.setAmount(Or.getAmount());
        orderDetail.setSubtotal(Or.getSubtotal());

        OrderDetail updated = repository.save(orderDetail);

        return modelTodto(updated);
    }

    // DTO → Modelo
    private OrderDetail dtoToModel(OrderDetailRequestDto Or) {
        OrderDetail orderDetail = new OrderDetail();

        orderDetail.setAmount(Or.getAmount());
        orderDetail.setSubtotal(Or.getSubtotal());

        return orderDetail;
    }

    // Modelo → DTO
    private OrderDetailResponse modelTodto(OrderDetail orderDetail) {

        OrderDetailResponse dto = new OrderDetailResponse();

        dto.setId(orderDetail.getId());
        dto.setAmount(orderDetail.getAmount());
        dto.setSubtotal(orderDetail.getSubtotal());

        return dto;
    }
}






