package com.Sena.Proyecto.Repository.Bill;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.Sena.Proyecto.model.Bill.Order;
import com.Sena.Proyecto.model.Bill.OrderDetail;
import java.math.BigDecimal;
import com.Sena.Proyecto.model.Inventory.Product;



public interface IOrderDetailRepository extends JpaRepository <OrderDetail, Integer> {

    List<OrderDetail> findByAmount(Integer amount);  // Buscar por cantidad
    List<OrderDetail> findBySubtotal(BigDecimal subtotal); // Buscar por Subtotal 
    List<OrderDetail> findByOrder(Order order); // Buscar por pedidos
    List<OrderDetail> findByProduct(Product product); // Buscar por Producto


}
