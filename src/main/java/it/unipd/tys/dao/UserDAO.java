package it.unipd.tys.dao;

import it.unipd.tys.model.User;

import java.sql.*;

public class UserDAO {

    public static boolean emailExists(String email) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE email = ?";
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public static void createUser(String email, String passwordHash) throws SQLException {
        String sql = "INSERT INTO users(email, password_hash) VALUES (?, ?)";
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, passwordHash);
            ps.executeUpdate();
        }
    }

    public static User findByEmail(String email) throws SQLException {
        String sql = "SELECT id, email, password_hash FROM users WHERE email = ?";
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return new User(
                        rs.getInt("id"),
                        rs.getString("email"),
                        rs.getString("password_hash")
                );
            }
        }
    }
}
