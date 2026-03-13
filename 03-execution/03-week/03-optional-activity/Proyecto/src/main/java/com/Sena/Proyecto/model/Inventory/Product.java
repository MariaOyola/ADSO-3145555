package com.Sena.Proyecto.model.Inventory;

import java.math.BigDecimal;
import java.util.List;

import com.Sena.Proyecto.model.BaseModel;
import com.Sena.Proyecto.model.Bill.BillDetail;

import com.Sena.Proyecto.model.Bill.OrderDetail;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table (name = "product")
public class Product extends BaseModel{

    @Column ( length = 50) 
    private String nameProduct; 

    @Column (name = "price", precision = 10, scale = 2)
    private  BigDecimal price;

    @Column (length = 50)
    private String description;

    @Column
    private Boolean state; 

    @ManyToOne
    @JoinColumn(name = "id_category")
    private Category category;

    @OneToMany(mappedBy = "product")
    private List<OrderDetail> orderDetails;

    @OneToMany(mappedBy = "product")
    private List<BillDetail> billDetails;

    
}

