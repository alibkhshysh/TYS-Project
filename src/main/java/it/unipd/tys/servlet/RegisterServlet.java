package it.unipd.tys.servlet;

import at.favre.lib.crypto.bcrypt.BCrypt;
import it.unipd.tys.dao.UserDAO;
import it.unipd.tys.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.Period;
import java.util.Locale;
import java.util.Set;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private static final int MAX_FIRST_NAME = 100;
    private static final int MAX_LAST_NAME = 100;
    private static final int MAX_MAJOR = 150;
    private static final int MAX_DEPARTMENT = 150;
    private static final int MAX_UNIVERSITY = 200;
    private static final int MAX_EMAIL = 255;
    private static final Set<String> ALLOWED_LEVELS = Set.of("Bachelor", "Master", "PhD", "Other");

    private void keepForm(HttpServletRequest req,
                          String firstName, String lastName, String birthDate,
                          String degreeLevel, String major, String department, String university,
                          String email) {
        req.setAttribute("firstName", firstName);
        req.setAttribute("lastName", lastName);
        req.setAttribute("birthDate", birthDate);
        req.setAttribute("degreeLevel", degreeLevel);
        req.setAttribute("major", major);
        req.setAttribute("department", department);
        req.setAttribute("university", university);
        req.setAttribute("email", email);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String firstName = trim(req.getParameter("firstName"));
        String lastName = trim(req.getParameter("lastName"));
        String birthDateS = trim(req.getParameter("birthDate"));
        String degreeLevel = trim(req.getParameter("degreeLevel"));
        String major = trim(req.getParameter("major"));
        String department = trim(req.getParameter("department"));
        String university = trim(req.getParameter("university"));
        String email = trim(req.getParameter("email")).toLowerCase(Locale.ROOT);

        String password = req.getParameter("password");
        String confirm = req.getParameter("confirm");

        // Simple server-side validation (security: never trust client)
        if (firstName.isEmpty() || lastName.isEmpty() || birthDateS.isEmpty() ||
                degreeLevel.isEmpty() || major.isEmpty() || department.isEmpty() || university.isEmpty() ||
                email.isEmpty() || password == null || confirm == null) {
            handleRegisterError(req, resp, "All fields are required.",
                    firstName, lastName, birthDateS, degreeLevel, major, department, university, email);
            return;
        }

        if (firstName.length() > MAX_FIRST_NAME || lastName.length() > MAX_LAST_NAME ||
                major.length() > MAX_MAJOR || department.length() > MAX_DEPARTMENT ||
                university.length() > MAX_UNIVERSITY || email.length() > MAX_EMAIL) {
            handleRegisterError(req, resp, "One or more fields are too long.",
                    firstName, lastName, birthDateS, degreeLevel, major, department, university, email);
            return;
        }

        if (!ALLOWED_LEVELS.contains(degreeLevel)) {
            handleRegisterError(req, resp, "Degree level is not valid.",
                    firstName, lastName, birthDateS, degreeLevel, major, department, university, email);
            return;
        }

        LocalDate birthDate;
        try {
            birthDate = LocalDate.parse(birthDateS);
        } catch (Exception e) {
            handleRegisterError(req, resp, "Birth date is not valid.",
                    firstName, lastName, birthDateS, degreeLevel, major, department, university, email);
            return;
        }

        if (birthDate.isAfter(LocalDate.now())) {
            handleRegisterError(req, resp, "Birth date cannot be in the future.",
                    firstName, lastName, birthDateS, degreeLevel, major, department, university, email);
            return;
        }

        int age = Period.between(birthDate, LocalDate.now()).getYears();
        if (age < 12 || age > 120) {
            handleRegisterError(req, resp, "Birth date is not plausible.",
                    firstName, lastName, birthDateS, degreeLevel, major, department, university, email);
            return;
        }

        if (password.length() < 8) {
            handleRegisterError(req, resp, "Password must be at least 8 characters.",
                    firstName, lastName, birthDateS, degreeLevel, major, department, university, email);
            return;
        }

        if (!password.equals(confirm)) {
            handleRegisterError(req, resp, "Passwords do not match.",
                    firstName, lastName, birthDateS, degreeLevel, major, department, university, email);
            return;
        }

        try {
            if (UserDAO.emailExists(email)) {
                handleRegisterError(req, resp, "Email is already registered.",
                        firstName, lastName, birthDateS, degreeLevel, major, department, university, email);
                return;
            }

            String hash = BCrypt.withDefaults().hashToString(12, password.toCharArray());
            UserDAO.createUser(
                    firstName, lastName, birthDate,
                    degreeLevel, major, department, university,
                    email, hash
            );

            User createdUser = UserDAO.findByEmail(email);
            if (createdUser == null) {
                req.setAttribute("error", "Account was created, but automatic login failed.");
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
                return;
            }

            HttpSession session = req.getSession(true);
            session.setAttribute("userId", createdUser.getId());
            session.setAttribute("userEmail", createdUser.getEmail());
            session.setAttribute("userName", createdUser.getFirstName());

            // PRG pattern: redirect after POST (avoids duplicate submissions)
            resp.sendRedirect(req.getContextPath() + "/dashboard");

        } catch (SQLException e) {
            log("Database error during registration", e);
            handleRegisterError(req, resp, "Database error during registration.",
                    firstName, lastName, birthDateS, degreeLevel, major, department, university, email);
        }
    }

    private void handleRegisterError(HttpServletRequest req,
                                     HttpServletResponse resp,
                                     String message,
                                     String firstName,
                                     String lastName,
                                     String birthDate,
                                     String degreeLevel,
                                     String major,
                                     String department,
                                     String university,
                                     String email) throws ServletException, IOException {
        keepForm(req, firstName, lastName, birthDate, degreeLevel, major, department, university, email);
        req.setAttribute("error", message);
        req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
    }

    private String trim(String s) {
        return (s == null) ? "" : s.trim();
    }
}
