package com.Sena.Proyecto.Controller.Bill;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.Sena.Proyecto.IService.Bill.OrderDetailIService;
import com.Sena.Proyecto.RequestDto.Bill.OrderDetailRequestDto;
import com.Sena.Proyecto.ResponseDto.Bill.OrderDetailResponse;

@RestController // aqui vamos a recibir peticiones 
@RequestMapping ("/OrderDetail")
public class OderDetailController {

     @Autowired
    private OrderDetailIService service; 

    // trar todo los datos

    @GetMapping
    public List<OrderDetailResponse> findAll() {
        return service.findAll(); 

    }

    // buscar por id

    @GetMapping ("/{id}") 
    public OrderDetailResponse findById(@PathVariable Integer id) {
        return service.findById(id); 

    }
    //buscar por fecha
    @GetMapping ("amount/{amount}")
    public List<OrderDetailResponse> findByAmount (@PathVariable Integer amount) {
        return service.findByAmount(amount); 
    }

     @GetMapping ("subtotal/{subtotal}")
    public List<OrderDetailResponse> findBySubtotal (@PathVariable BigDecimal subtotal) {
        return service.findBySubtotal(subtotal); 
    }

    // Guardar
    @PostMapping
    public   OrderDetailResponse  save (@RequestBody OrderDetailRequestDto Or) {
        return service.save(Or); 

    }

    // eliminar 
    @DeleteMapping ("/{id}") 
    public void deleteById(@PathVariable Integer id) {
        service.deleteById(id);
    }
    // Actualizae
@PutMapping("/{id}")
public  OrderDetailResponse update(@PathVariable Integer id, @RequestBody OrderDetailRequestDto Or) {
    return service.update(id, Or); 
}

}

