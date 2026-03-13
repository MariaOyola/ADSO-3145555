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

import com.Sena.Proyecto.IService.Bill.BillDetailIService;
import com.Sena.Proyecto.RequestDto.Bill.BillDetailRequestDto;
import com.Sena.Proyecto.ResponseDto.Bill.BillDetailResponse;

@RestController // aqui vamos a recibir peticiones 
@RequestMapping ("/BillDetail")
public class BillDetailController {

     @Autowired
    private BillDetailIService service; 

    // trar todo los datos

    @GetMapping
    public List<BillDetailResponse> findAll() {
        return service.findAll(); 

    }

    // buscar por id

    @GetMapping ("/{id}") 
    public BillDetailResponse findById(@PathVariable Integer id) {
        return service.findById(id); 

    }
    //buscar por fecha
    @GetMapping ("amount/{amount}")
    public List<BillDetailResponse> findByAmountBillDetail (@PathVariable Integer amountBillDetail) {
        return service.findByAmountBillDetail(amountBillDetail); 
    }

     @GetMapping ("subtotal/{subtotal}")
    public List<BillDetailResponse>  findBySubtotalBillDetail (@PathVariable BigDecimal subtotalBillDetail) {
        return service.findBySubtotalBillDetail(subtotalBillDetail); 
    }

    // Guardar
    @PostMapping
    public   BillDetailResponse  save (@RequestBody BillDetailRequestDto  Br) {
        return service.save(Br); 

    }

    // eliminar 
    @DeleteMapping ("/{id}") 
    public void deleteById(@PathVariable Integer id) {
        service.deleteById(id);
    }
    // Actualizae
@PutMapping("/{id}")
public  BillDetailResponse update(@PathVariable Integer id, @RequestBody BillDetailRequestDto Br) {
    return service.update(id, Br); 
}





}
