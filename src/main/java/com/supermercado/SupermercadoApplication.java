package com.supermercado;

import com.supermercado.service.ProductoService;
import com.supermercado.model.Producto;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;

import java.util.List;

@SpringBootApplication
public class SupermercadoApplication {

    public static void main(String[] args) {
        ApplicationContext ctx = SpringApplication.run(SupermercadoApplication.class, args);
        ProductoService servicio = ctx.getBean(ProductoService.class);
        List<Producto> productos = servicio.obtenerProductos();
        productos.forEach(System.out::println);
    }
}