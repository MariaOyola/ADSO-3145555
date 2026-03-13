package com.Sena.Proyecto.ServiceImp.Inventory;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.Sena.Proyecto.IService.Inventory.ProductIService;
import com.Sena.Proyecto.Repository.Inventory.IProductRepository;
import com.Sena.Proyecto.RequestDto.Inventory.ProductRequetDto;
import com.Sena.Proyecto.ResponseDto.Inventory.ProductResponse;
import com.Sena.Proyecto.model.Inventory.Product;

@Service
public class ProductIServiceImp implements ProductIService {

    @Autowired
    private IProductRepository repository;

    @Override
    public List<ProductResponse> findAll() {
        return repository.findAll().stream().map(this::modelTodto).toList();
    }

    @Override
    public ProductResponse findById(Integer id) {
        Product product = repository.findById(id).orElse(null);

        if (product == null) {
            return null;
        }

        return modelTodto(product);
    }

    @Override
    public List<ProductResponse> findByNameProduct(String nameProduct) {
        return repository.findByNameProduct(nameProduct)
                .stream()
                .map(this::modelTodto)
                .toList();
    }

    @Override
    public ProductResponse save(ProductRequetDto Pr) {
        Product product = dtoToModel(Pr);
        Product saved = repository.save(product);
        return modelTodto(saved);
    }

    @Override
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }

    @Override
    public ProductResponse update(Integer id, ProductRequetDto Pr) {
        Product product = repository.findById(id).orElse(null);

        if (product == null) {
            return null;
        }

        product.setNameProduct(Pr.getNameProduct());
        product.setPrice(Pr.getPrice());
        product.setDescription(Pr.getDescription());

        Product updated = repository.save(product);

        return modelTodto(updated);
    }

    // DTO → Modelo
    private Product dtoToModel(ProductRequetDto Pr) {
        Product product = new Product();

        product.setNameProduct(Pr.getNameProduct());
        product.setPrice(Pr.getPrice());
        product.setDescription(Pr.getDescription());

        return product;
    }

    // Modelo → DTO
    private ProductResponse modelTodto(Product product) {
        ProductResponse dto = new ProductResponse();

        dto.setId(product.getId());
        dto.setNameProduct(product.getNameProduct());
        dto.setPrice(product.getPrice());
        dto.setDescription(product.getDescription());

        return dto;
    }
}


