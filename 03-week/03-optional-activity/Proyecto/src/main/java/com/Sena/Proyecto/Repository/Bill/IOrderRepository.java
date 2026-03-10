package com.Sena.Proyecto.Repository.Bill;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.Sena.Proyecto.model.Bill.Order;

public interface IOrderRepository extends JpaRepository <Order, Integer> {

    List<Order> findByDate(LocalDate date); 
    List<Order> findByTotal(BigDecimal total);
    List<Order> findByUserId(Integer idUser);

}
