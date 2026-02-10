package it.unipd.tys.servlet;

import it.unipd.tys.dao.UserDAO;
import it.unipd.tys.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeParseException;
import java.util.Locale;
import java.util.Set;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private static final int MAX_FIRST_NAME = 100;
    private static final int MAX_LAST_NAME = 100;
    private static final int MAX_MAJOR = 150;
    private static final int MAX_DEPARTMENT = 150;
    private static final int MAX_UNIVERSITY = 200;
    private static final int MAX_EMAIL = 255;
    private static final Set<String> ALLOWED_LEVELS = Set.of("Bachelor", "Master", "PhD", "Other");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Integer userId = getUserId(session);
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = loadUserOrHandle(req, resp, session, userId);
        if (user == null) {
            return;
        }

        if ("1".equals(req.getParameter("updated"))) {
            req.setAttribute("success", "Profile updated successfully.");
        }

        req.setAttribute("user", user);
        req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Integer userId = getUserId(session);
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String firstName = trim(req.getParameter("firstName"));
        String lastName = trim(req.getParameter("lastName"));
        String birthDateS = trim(req.getParameter("birthDate"));
        String degreeLevel = trim(req.getParameter("degreeLevel"));
        String major = trim(req.getParameter("major"));
        String department = trim(req.getParameter("department"));
        String university = trim(req.getParameter("university"));
        String email = trim(req.getParameter("email")).toLowerCase(Locale.ROOT);

        keepForm(req, firstName, lastName, birthDateS, degreeLevel, major, department, university, email);

        if (firstName.isEmpty() || lastName.isEmpty() || birthDateS.isEmpty() ||
                degreeLevel.isEmpty() || major.isEmpty() || department.isEmpty() ||
                university.isEmpty() || email.isEmpty()) {
            forwardWithError(req, resp, session, userId, "All fields are required.");
            return;
        }

        if (firstName.length() > MAX_FIRST_NAME || lastName.length() > MAX_LAST_NAME ||
                major.length() > MAX_MAJOR || department.length() > MAX_DEPARTMENT ||
                university.length() > MAX_UNIVERSITY || email.length() > MAX_EMAIL) {
            forwardWithError(req, resp, session, userId, "One or more fields are too long.");
            return;
        }

        if (!ALLOWED_LEVELS.contains(degreeLevel)) {
            forwardWithError(req, resp, session, userId, "Degree level is not valid.");
            return;
        }

        LocalDate birthDate;
        try {
            birthDate = LocalDate.parse(birthDateS);
        } catch (DateTimeParseException ex) {
            forwardWithError(req, resp, session, userId, "Birth date is not valid.");
            return;
        }

        if (birthDate.isAfter(LocalDate.now())) {
            forwardWithError(req, resp, session, userId, "Birth date cannot be in the future.");
            return;
        }

        int age = Period.between(birthDate, LocalDate.now()).getYears();
        if (age < 12 || age > 120) {
            forwardWithError(req, resp, session, userId, "Birth date is not plausible.");
            return;
        }

        try {
            if (UserDAO.emailExistsForOtherUser(userId, email)) {
                forwardWithError(req, resp, session, userId, "Email is already registered by another account.");
                return;
            }

            UserDAO.updateUserProfile(
                    userId,
                    firstName, lastName, birthDate,
                    degreeLevel, major, department, university,
                    email
            );

            session.setAttribute("userEmail", email);
            session.setAttribute("userName", firstName);
            resp.sendRedirect(req.getContextPath() + "/profile?updated=1");
        } catch (SQLException e) {
            log("Database error while updating profile", e);
            forwardWithError(req, resp, session, userId, "Database error while updating profile.");
        }
    }

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

    private void forwardWithError(HttpServletRequest req, HttpServletResponse resp, HttpSession session, int userId, String error)
            throws ServletException, IOException {
        req.setAttribute("error", error);
        User user = loadUserOrHandle(req, resp, session, userId);
        if (user == null) {
            return;
        }
        req.setAttribute("user", user);
        req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
    }

    private User loadUserOrHandle(HttpServletRequest req, HttpServletResponse resp, HttpSession session, int userId)
            throws IOException {
        try {
            User user = UserDAO.findById(userId);
            if (user == null) {
                if (session != null) {
                    session.invalidate();
                }
                resp.sendRedirect(req.getContextPath() + "/login");
                return null;
            }
            return user;
        } catch (SQLException e) {
            log("Database error while loading profile", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
            return null;
        }
    }

    private Integer getUserId(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object userId = session.getAttribute("userId");
        if (userId instanceof Integer i) {
            return i;
        }
        if (userId instanceof Number n) {
            return n.intValue();
        }
        return null;
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
