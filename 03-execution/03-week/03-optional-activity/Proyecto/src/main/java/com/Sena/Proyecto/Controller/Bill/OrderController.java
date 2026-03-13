package com.Sena.Proyecto.Controller.Bill;

import java.math.BigDecimal;
import java.time.LocalDate;
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

import com.Sena.Proyecto.IService.Bill.OrderIService;
import com.Sena.Proyecto.RequestDto.Bill.OrderRequestDto;
import com.Sena.Proyecto.ResponseDto.Bill.OrderResponse;

@RestController // aqui vamos a recibir peticiones 
@RequestMapping ("/Order")
public class OrderController {

     @Autowired
    private OrderIService service; 

    // trar todo los datos

    @GetMapping
    public List<OrderResponse> findAll() {
        return service.findAll(); 

    }

    // buscar por id

    @GetMapping ("/{id}") 
    public OrderResponse findById(@PathVariable Integer id) {
        return service.findById(id); 

    }
    //buscar por fecha
    @GetMapping ("date/{date}")
    public List<OrderResponse> findByDate (@PathVariable LocalDate date) {
        return service.findByDate(date); 
    }

     @GetMapping ("total/{total}")
    public List<OrderResponse> findByTotal (@PathVariable BigDecimal total) {
        return service.findByTotal(total); 
    }

    // Guardar
    @PostMapping
    public OrderResponse save (@RequestBody OrderRequestDto dto) {
        return service.save(dto); 

    }

    // eliminar 
    @DeleteMapping ("/{id}") 
    public void deleteById(@PathVariable Integer id) {
        service.deleteById(id);
    }
    // Actualizae
@PutMapping("/{id}")
public  OrderResponse update(@PathVariable Integer id, @RequestBody OrderRequestDto O) {
    return service.update(id, O); 
}

}
