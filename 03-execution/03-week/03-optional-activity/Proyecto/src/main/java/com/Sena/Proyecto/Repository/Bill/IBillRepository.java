package com.Sena.Proyecto.Repository.Bill;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.Sena.Proyecto.model.Bill.Bill;
import java.time.LocalDate;
import java.math.BigDecimal;



public interface IBillRepository  extends JpaRepository < Bill, Integer>{
    List<Bill> findByDateBill(LocalDate dateBill);
    List<Bill> findByTotalBill(BigDecimal totalBill);

}
