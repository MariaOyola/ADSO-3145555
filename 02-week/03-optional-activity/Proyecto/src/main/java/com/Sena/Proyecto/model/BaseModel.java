package com.Sena.Proyecto.model;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.MappedSuperclass;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import lombok.Getter; // Libreria 
import lombok.NoArgsConstructor; 
import lombok.Setter;

@MappedSuperclass  //  Anotacion el la cual indico que voy a  usar los atributos de esta clase, pero no quiero que se muestre en mi base de datos
@NoArgsConstructor  // Generar automaticamente los  contructores sin parametros
 @Getter   // Generar automaticamente los Getter ( Obtener)
@Setter   //  Generar automaticamente los Setter ( Modificar)



public abstract  class BaseModel {

    @Id
    @GeneratedValue (strategy = GenerationType.SEQUENCE ) // Generara  automaticamente el id en la base de datos
    private Integer id; 

    @Column (updatable = false )  // Aqui indico que este campo no se actualiza despues de ser creado
    private LocalDateTime created;  // creacion del registro

    private LocalDateTime update;  // Actualizacion del registro

    @PrePersist  // Ejecutareste metodo auntomaticamente antes de guardar un insert en la base de datos
       protected void Created () {
        this.created = LocalDateTime.now(); 
        this.update = LocalDateTime.now(); 

       }
   @PreUpdate  // ejecuta automaticamente antes  de actualizar un registro en la base de dattos
   protected void Update () {
    this.update = LocalDateTime.now(); 
   }
 
}