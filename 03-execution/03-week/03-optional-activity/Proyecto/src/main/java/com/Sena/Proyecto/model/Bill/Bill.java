package com.Sena.Proyecto.model.Bill;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import com.Sena.Proyecto.model.BaseModel;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table ( name = "bill")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Bill extends BaseModel {
   
  @Column (name = "date")
    private LocalDate dateBill; 

  @Column (precision = 10, scale = 2, nullable = false)
    private BigDecimal totalBill;

    @OneToOne
@JoinColumn(name = "id_order")
private Order order;
    
   @OneToMany(mappedBy = "bill")
private List<BillDetail> billDetails;

}
