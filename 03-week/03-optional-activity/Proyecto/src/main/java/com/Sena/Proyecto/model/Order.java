package com.Sena.Proyecto.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
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
@Table (name = "order")
public class Order extends BaseModel {

    @Column (name = "date")
    private LocalDate date; 

    @Column (precision = 10, scale = 2, nullable = false)
    private BigDecimal total;

   @ManyToOne
   @JoinColumn(name = "id_user")
    private User user;

     @OneToMany(mappedBy = "order")
    private List<OrderDetail> orderDetails;

    @OneToOne (mappedBy = "order") 
    private  Bill bill; 

}
