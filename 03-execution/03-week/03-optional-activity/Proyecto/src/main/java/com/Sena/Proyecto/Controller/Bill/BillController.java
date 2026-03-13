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

import com.Sena.Proyecto.IService.Bill.BillIService;
import com.Sena.Proyecto.RequestDto.Bill.BillRequestDto;
import com.Sena.Proyecto.ResponseDto.Bill.BillResponse;



@RestController // aqui vamos a recibir peticiones 
@RequestMapping ("/Bill")
public class BillController {

    @Autowired
    private  BillIService service; 

    // trar todo los datos

    @GetMapping
    public List<BillResponse> findAll() {
        return service.findAll(); 

    }

    // buscar por id

    @GetMapping ("/{id}") 
    public BillResponse findById(@PathVariable Integer id) {
        return service.findById(id); 

    }
    //buscar por fecha
    @GetMapping ("date/{date}")
    public List<BillResponse> findByDateBill (@PathVariable LocalDate dateBill) {
        return service.findByDateBill(dateBill); 
    }

     @GetMapping ("total/{total}")
    public List<BillResponse> findByTotalBill (@PathVariable BigDecimal total) {
        return service.findByTotalBill(total); 
    }

    // Guardar
    @PostMapping
    public   BillResponse  save (@RequestBody BillRequestDto B) {
        return service.save(B); 

    }

    // eliminar 
    @DeleteMapping ("/{id}") 
    public void deleteById(@PathVariable Integer id) {
        service.deleteById(id);
    }
    // Actualizae
@PutMapping("/{id}")
public  BillResponse update(@PathVariable Integer id, @RequestBody BillRequestDto B) {
    return service.update(id, B); 
}


}
