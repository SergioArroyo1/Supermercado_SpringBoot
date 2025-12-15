// java
package com.supermercado.service;

import com.supermercado.model.Producto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;

@Service
public class ProductoService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public List<Producto> obtenerProductos() {
        String sql = "SELECT\n" +
                "    codigo,\n" +
                "    descripcion,\n" +
                "    p.getColores() AS \"colores\",\n" +
                "    precio,\n" +
                "    stock,\n" +
                "    minimo\n" +
                "FROM PRODUCTO p";

        return jdbcTemplate.query(sql, (rs, rowNum) -> mapProducto(rs));
    }

    private Producto mapProducto(ResultSet rs) throws SQLException {

        // Recibir colores ya como texto gracias a p.getColores()
        String coloresString = rs.getString("colores");

        if (coloresString == null) {
            coloresString = "";
        }

        // Quitar el texto "Disponible en "
        coloresString = coloresString.replace("Disponible en", "").trim();

        // Separar colores por espacios
        List<String> colores = Arrays.asList(coloresString.split(" "));

        return new Producto(
                rs.getString("codigo"),
                rs.getString("descripcion"),
                colores,
                rs.getDouble("precio"),
                rs.getInt("stock"),
                rs.getInt("minimo")
        );
    }
}