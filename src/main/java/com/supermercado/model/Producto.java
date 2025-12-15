package com.supermercado.model;

import java.util.List;

public class Producto {
    private String codigo;
    private String descripcion;
    private List<String> colores;
    private double precio;
    private int stock;
    private int minimo;

    public Producto(String codigo, String descripcion, List<String> colores, double precio, int stock, int minimo) {
        this.codigo = codigo;
        this.descripcion = descripcion;
        this.colores = colores;
        this.precio = precio;
        this.stock = stock;
        this.minimo = minimo;
    }

    @Override
    public String toString() {
        return "Producto{" +
                "codigo='" + codigo + '\'' +
                ", descripcion='" + descripcion + '\'' +
                ", colores=" + colores +
                ", precio=" + precio +
                ", stock=" + stock +
                ", minimo=" + minimo +
                '}';
    }

}