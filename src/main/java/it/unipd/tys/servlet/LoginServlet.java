package it.unipd.tys.servlet;

import at.favre.lib.crypto.bcrypt.BCrypt;
import it.unipd.tys.dao.UserDAO;
import it.unipd.tys.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String password = req.getParameter("password");

        email = (email == null) ? "" : email.trim();

        if (email.isEmpty() || password == null || password.isEmpty()) {
            req.setAttribute("error", "Email and password are required.");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        try {
            User u = UserDAO.findByEmail(email);
            if (u == null) {
                req.setAttribute("error", "Invalid email or password.");
                req.setAttribute("email", email);
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
                return;
            }

            BCrypt.Result r = BCrypt.verifyer().verify(password.toCharArray(), u.getPasswordHash());
            if (!r.verified) {
                req.setAttribute("error", "Invalid email or password.");
                req.setAttribute("email", email);
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
                return;
            }

            HttpSession session = req.getSession(true);
            session.setAttribute("userId", u.getId());
            session.setAttribute("userEmail", u.getEmail());
            session.setAttribute("userName", u.getFirstName());

            resp.sendRedirect(req.getContextPath() + "/dashboard");

        } catch (SQLException e) {
            log("Database error during login", e);
            req.setAttribute("error", "Database error during login.");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
        }
    }
}
