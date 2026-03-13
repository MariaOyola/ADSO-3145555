package com.Sena.Proyecto.Repository.Bill;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.Sena.Proyecto.model.Bill.Bill;
import com.Sena.Proyecto.model.Bill.BillDetail;
import java.math.BigDecimal;
import com.Sena.Proyecto.model.Inventory.Product;



public interface IBillDetailRepository extends JpaRepository <BillDetail, Integer> {

    List<BillDetail> findByAmountBillDetail(Integer amountBillDetail);
    List<BillDetail> findBySubtotalBillDetail(BigDecimal subtotalBillDetail);
    List<BillDetail> findByBill(Bill bill);
    List<BillDetail> findByProduct(Product product); 

}
