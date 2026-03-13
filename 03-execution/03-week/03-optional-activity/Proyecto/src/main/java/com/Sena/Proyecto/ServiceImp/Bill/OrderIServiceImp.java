package com.Sena.Proyecto.ServiceImp.Bill;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.Sena.Proyecto.IService.Bill.OrderIService;
import com.Sena.Proyecto.Repository.Bill.IOrderRepository;
import com.Sena.Proyecto.RequestDto.Bill.OrderRequestDto;
import com.Sena.Proyecto.ResponseDto.Bill.OrderResponse;
import com.Sena.Proyecto.model.Bill.Order;

@Service
public class OrderIServiceImp implements OrderIService {

    @Autowired
    private IOrderRepository repository;

    @Override
    public List<OrderResponse> findAll() {
        return repository.findAll().stream().map(this::modelTodto).toList();
    }

@Override
public OrderResponse  findById(Integer id) {
    Order order = repository.findById(id).orElse(null);

    if (order == null) {
        return null;
    }
    return modelTodto(order);
}
    @Override
    public List<OrderResponse> findByDate(LocalDate date) {
        return repository.findByDate(date)
                .stream()
                .map(this::modelTodto)
                .toList();
    }

    @Override
    public List<OrderResponse> findByTotal(BigDecimal total) {
        return repository.findByTotal(total)
                .stream()
                .map(this::modelTodto)
                .toList();
    }

    @Override
    public OrderResponse save(OrderRequestDto O) {
        Order order = dtoToModel(O);
        Order saved = repository.save(order);
        return modelTodto(saved);
    }

    @Override
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }

    @Override
    public OrderResponse update(Integer id, OrderRequestDto O) {

        Order order = repository.findById(id).orElse(null);

        if (order == null) {
            return null;
        }
        order.setDate(O.getDate());
        order.setTotal(O.getTotal());

        Order updated = repository.save(order);

        return modelTodto(updated);
    }

    // DTO → Modelo
    private Order dtoToModel(OrderRequestDto O) {
        Order order = new Order();

        order.setDate(O.getDate());
        order.setTotal(O.getTotal());

        return order;
    }

    // Modelo → DTO
    private OrderResponse modelTodto(Order order) {

        OrderResponse dto = new OrderResponse();

        dto.setId(order.getId());
        dto.setDate(order.getDate());
        dto.setTotal(order.getTotal());

        return dto;
    }
}