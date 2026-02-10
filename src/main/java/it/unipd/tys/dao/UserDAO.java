package it.unipd.tys.dao;

import it.unipd.tys.model.User;

import java.sql.*;
import java.time.LocalDate;

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

    public static void createUser(
            String firstName, String lastName, LocalDate birthDate,
            String degreeLevel, String major, String department, String university,
            String email, String passwordHash
    ) throws SQLException {
        String sql = """
                INSERT INTO users(first_name, last_name, birth_date, degree_level, major, department, university, email, password_hash)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, firstName);
            ps.setString(2, lastName);
            ps.setDate(3, Date.valueOf(birthDate));
            ps.setString(4, degreeLevel);
            ps.setString(5, major);
            ps.setString(6, department);
            ps.setString(7, university);
            ps.setString(8, email);
            ps.setString(9, passwordHash);
            ps.executeUpdate();
        }
    }

    public static User findByEmail(String email) throws SQLException {
        String sql = """
                SELECT id, first_name, last_name, birth_date, degree_level, major, department, university, email, password_hash
                FROM users WHERE email = ?
                """;
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Date birthDateValue = rs.getDate("birth_date");
                return new User(
                        rs.getInt("id"),
                        rs.getString("first_name"),
                        rs.getString("last_name"),
                        birthDateValue == null ? null : birthDateValue.toLocalDate(),
                        rs.getString("degree_level"),
                        rs.getString("major"),
                        rs.getString("department"),
                        rs.getString("university"),
                        rs.getString("email"),
                        rs.getString("password_hash")
                );
            }
        }
    }

    public static User findById(int id) throws SQLException {
        String sql = """
                SELECT id, first_name, last_name, birth_date, degree_level, major, department, university, email, password_hash
                FROM users WHERE id = ?
                """;
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Date birthDateValue = rs.getDate("birth_date");
                return new User(
                        rs.getInt("id"),
                        rs.getString("first_name"),
                        rs.getString("last_name"),
                        birthDateValue == null ? null : birthDateValue.toLocalDate(),
                        rs.getString("degree_level"),
                        rs.getString("major"),
                        rs.getString("department"),
                        rs.getString("university"),
                        rs.getString("email"),
                        rs.getString("password_hash")
                );
            }
        }
    }

    public static boolean emailExistsForOtherUser(int userId, String email) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE email = ? AND id <> ?";
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public static void updateUserProfile(
            int userId,
            String firstName, String lastName, LocalDate birthDate,
            String degreeLevel, String major, String department, String university,
            String email
    ) throws SQLException {
        String sql = """
                UPDATE users
                SET first_name = ?,
                    last_name = ?,
                    birth_date = ?,
                    degree_level = ?,
                    major = ?,
                    department = ?,
                    university = ?,
                    email = ?
                WHERE id = ?
                """;
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, firstName);
            ps.setString(2, lastName);
            ps.setDate(3, Date.valueOf(birthDate));
            ps.setString(4, degreeLevel);
            ps.setString(5, major);
            ps.setString(6, department);
            ps.setString(7, university);
            ps.setString(8, email);
            ps.setInt(9, userId);
            ps.executeUpdate();
        }
    }
}
