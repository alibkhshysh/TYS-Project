package it.unipd.tys.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DB {

    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new IllegalStateException("PostgreSQL JDBC driver not found.", e);
        }
    }

    private static final String HOST = envOrDefault("DB_HOST", "localhost");
    private static final String PORT = envOrDefault("DB_PORT", "5432");
    private static final String NAME = envOrDefault("DB_NAME", "tysdb");
    private static final String USER = envOrDefault("DB_USER", "tysuser");
    private static final String PASS = envOrDefault("DB_PASS", "tyspass");
    private static final String URL = "jdbc:postgresql://" + HOST + ":" + PORT + "/" + NAME;

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }

    private static String envOrDefault(String key, String fallback) {
        String value = System.getenv(key);
        return (value == null || value.isBlank()) ? fallback : value;
    }
}
