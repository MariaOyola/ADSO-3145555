package com.Sena.Proyecto.ServiceImp.Bill;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.Sena.Proyecto.IService.Bill.BillDetailIService;
import com.Sena.Proyecto.Repository.Bill.IBillDetailRepository;
import com.Sena.Proyecto.RequestDto.Bill.BillDetailRequestDto;
import com.Sena.Proyecto.ResponseDto.Bill.BillDetailResponse;
import com.Sena.Proyecto.model.Bill.BillDetail;

@Service
public class BillDetailIServiceImp implements BillDetailIService {


    
     @Autowired
    private IBillDetailRepository repository;

    @Override
    public List<BillDetailResponse> findAll() {
        return repository.findAll().stream().map(this::modelTodto).toList();
    }

@Override
public BillDetailResponse findById(Integer id) {
    BillDetail billDetail = repository.findById(id).orElse(null);

    if (billDetail == null) {
        return null;
    }
    return modelTodto(billDetail);
}
    @Override
    public List<BillDetailResponse> findByAmountBillDetail (Integer amountBillDetail) {
        return repository.findByAmountBillDetail(amountBillDetail)
                .stream()
                .map(this::modelTodto)
                .toList();
    }

    @Override
    public List<BillDetailResponse> findBySubtotalBillDetail(BigDecimal subtotalBillDetail) {
        return repository.findBySubtotalBillDetail(subtotalBillDetail)
                .stream()
                .map(this::modelTodto)
                .toList();
    }

    @Override
    public BillDetailResponse save(BillDetailRequestDto Br) {
        BillDetail billDetail = dtoToModel(Br);
        BillDetail saved = repository.save(billDetail);
        return modelTodto(saved);
    }

    @Override
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }

    @Override
    public BillDetailResponse update(Integer id, BillDetailRequestDto Br) {
        BillDetail billDetail = repository.findById(id).orElse(null);

        if (billDetail == null) {
            return null;
        }
        billDetail.setAmountBillDetail(Br.getAmountBillDetail());
        billDetail.setSubtotalBillDetail(Br.getSubtotalBillDetail());

        BillDetail updated = repository.save(billDetail);

        return modelTodto(updated);
    }

    // DTO → Modelo
    private BillDetail dtoToModel(BillDetailRequestDto Br) {
        BillDetail billDetail = new BillDetail();

        billDetail.setAmountBillDetail(Br.getAmountBillDetail());
        billDetail.setSubtotalBillDetail(Br.getSubtotalBillDetail());

        return billDetail;
    }

    // Modelo → DTO
    private BillDetailResponse modelTodto(BillDetail billDetail) {

        BillDetailResponse dto = new BillDetailResponse();

        dto.setId(billDetail.getId());
        dto.setAmountBillDetail(billDetail.getAmountBillDetail());
        dto.setSubtotalBillDetail(billDetail.getSubtotalBillDetail());

        return dto;
    }
}
