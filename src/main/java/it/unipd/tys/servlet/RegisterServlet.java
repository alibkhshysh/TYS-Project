package it.unipd.tys.servlet;

import at.favre.lib.crypto.bcrypt.BCrypt;
import it.unipd.tys.dao.UserDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirm = req.getParameter("confirm");

        email = (email == null) ? "" : email.trim();

        // Simple server-side validation (security: never trust client)
        if (email.isEmpty() || password == null || confirm == null) {
            req.setAttribute("error", "All fields are required.");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
            return;
        }

        if (password.length() < 8) {
            req.setAttribute("error", "Password must be at least 8 characters.");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
            return;
        }

        if (!password.equals(confirm)) {
            req.setAttribute("error", "Passwords do not match.");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
            return;
        }

        try {
            if (UserDAO.emailExists(email)) {
                req.setAttribute("error", "Email is already registered.");
                req.setAttribute("email", email);
                req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
                return;
            }

            String hash = BCrypt.withDefaults().hashToString(12, password.toCharArray());
            UserDAO.createUser(email, hash);

            // PRG pattern: redirect after POST (avoids duplicate submissions)
            resp.sendRedirect(req.getContextPath() + "/login?registered=1");

        } catch (SQLException e) {
            log("Database error during registration", e);
            req.setAttribute("error", "Database error during registration.");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
        }
    }
}
