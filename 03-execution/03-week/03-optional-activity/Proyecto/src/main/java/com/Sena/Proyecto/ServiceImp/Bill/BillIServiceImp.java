package com.Sena.Proyecto.ServiceImp.Bill;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.Sena.Proyecto.IService.Bill.BillIService;
import com.Sena.Proyecto.Repository.Bill.IBillRepository;
import com.Sena.Proyecto.RequestDto.Bill.BillRequestDto;
import com.Sena.Proyecto.ResponseDto.Bill.BillResponse;
import com.Sena.Proyecto.model.Bill.Bill;

@Service
public class BillIServiceImp implements BillIService {

     @Autowired
    private IBillRepository repository;

    @Override
    public List<BillResponse> findAll() {
        return repository.findAll().stream().map(this::modelTodto).toList();
    }

@Override
public BillResponse  findById(Integer id) {
    Bill bill = repository.findById(id).orElse(null);

    if (bill == null) {
        return null;
    }
    return modelTodto(bill);
}
    @Override
    public List<BillResponse> findByDateBill (LocalDate dateBill) {
        return repository.findByDateBill(dateBill)
                .stream()
                .map(this::modelTodto)
                .toList();
    }

    @Override
    public List<BillResponse> findByTotalBill(BigDecimal totalBill) {
        return repository.findByTotalBill(totalBill)
                .stream()
                .map(this::modelTodto)
                .toList();
    }

    @Override
    public BillResponse save(BillRequestDto B) {
        Bill bill = dtoToModel(B);
        Bill saved = repository.save(bill);
        return modelTodto(saved);
    }

    @Override
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }

    @Override
    public BillResponse update(Integer id, BillRequestDto B) {
        Bill bill = repository.findById(id).orElse(null);

        if (bill == null) {
            return null;
        }
        bill.setDateBill(B.getDateBill());
        bill.setTotalBill(B.getTotalBill());

        Bill updated = repository.save(bill);

        return modelTodto(updated);
    }

    // DTO → Modelo
    private Bill dtoToModel(BillRequestDto B) {
        Bill bill = new Bill();

        bill.setDateBill(B.getDateBill());
        bill.setTotalBill(B.getTotalBill());

        return bill;
    }

    // Modelo → DTO
    private BillResponse modelTodto(Bill bill) {

        BillResponse dto = new BillResponse();

        dto.setId(bill.getId());
        dto.setDateBill(bill.getDateBill());
        dto.setTotalBill(bill.getTotalBill());

        return dto;
    }
}





