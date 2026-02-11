package it.unipd.tys.servlet;

import it.unipd.tys.dao.StudyActivityDAO;
import it.unipd.tys.model.StudyActivity;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private static final DateTimeFormatter MONTH_PARAM_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM");
    private static final DateTimeFormatter MONTH_TITLE_FORMAT = DateTimeFormatter.ofPattern("MMMM yyyy", Locale.ENGLISH);
    private static final int MAX_COURSE_NAME = 200;
    private static final int MAX_CHAPTER_SUBJECT = 255;
    private static final int MAX_SOURCES = 4000;
    private static final int MAX_NOTES = 2000;
    private static final Set<String> ALLOWED_STATUS = Set.of("TODO", "DONE");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Integer userId = getUserId(session);
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        YearMonth month = parseMonth(req.getParameter("month"));
        LocalDate today = LocalDate.now();
        try {
            Map<LocalDate, List<StudyActivity>> activitiesByDate =
                    StudyActivityDAO.findActivitiesByMonth(userId, month);

            req.setAttribute("calendarRows", buildCalendarRows(month));
            req.setAttribute("activitiesByDate", activitiesByDate);
            req.setAttribute("monthParam", month.format(MONTH_PARAM_FORMAT));
            req.setAttribute("monthLabel", month.format(MONTH_TITLE_FORMAT));
            req.setAttribute("prevMonthParam", month.minusMonths(1).format(MONTH_PARAM_FORMAT));
            req.setAttribute("nextMonthParam", month.plusMonths(1).format(MONTH_PARAM_FORMAT));
            req.setAttribute("prevMonthLabel",
                    month.minusMonths(1).getMonth().getDisplayName(TextStyle.FULL, Locale.ENGLISH));
            req.setAttribute("nextMonthLabel",
                    month.plusMonths(1).getMonth().getDisplayName(TextStyle.FULL, Locale.ENGLISH));
            req.setAttribute("today", today);
            req.setAttribute("displayName", resolveDisplayName(session));

            consumeFlash(session, req);
            req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(req, resp);
        } catch (SQLException e) {
            log("Database error while loading dashboard", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        Integer userId = getUserId(session);
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        YearMonth requestedMonth = parseMonth(req.getParameter("month"));
        String mode = trim(req.getParameter("mode")).toLowerCase(Locale.ROOT);
        int activityId = parsePositiveInt(req.getParameter("activityId"));
        String status = trim(req.getParameter("status")).toUpperCase(Locale.ROOT);
        String courseName = trim(req.getParameter("courseName"));
        String chapterSubject = trim(req.getParameter("chapterSubject"));
        String reviewMinutesS = trim(req.getParameter("reviewMinutes"));
        String studiedMinutesS = trim(req.getParameter("studiedMinutes"));
        String usedSources = trim(req.getParameter("usedSources"));
        String notes = trim(req.getParameter("notes"));
        String activityDateS = trim(req.getParameter("activityDate"));

        if ("delete".equals(mode)) {
            if (activityId <= 0) {
                setFlashError(session, "Invalid activity id.");
                redirectToMonth(req, resp, requestedMonth);
                return;
            }

            try {
                boolean deleted = StudyActivityDAO.deleteActivity(userId, activityId);
                if (!deleted) {
                    setFlashError(session, "Activity not found or not allowed.");
                } else {
                    session.setAttribute("flashSuccess", "Activity removed.");
                }
            } catch (SQLException e) {
                log("Database error while deleting activity", e);
                setFlashError(session, "Database error while deleting activity.");
            }
            redirectToMonth(req, resp, requestedMonth);
            return;
        }

        if (activityDateS.isEmpty() || status.isEmpty() || courseName.isEmpty()) {
            setFlashError(session, "Date, status, and course name are required.");
            redirectToMonth(req, resp, requestedMonth);
            return;
        }

        if (!ALLOWED_STATUS.contains(status)) {
            setFlashError(session, "Activity status is invalid.");
            redirectToMonth(req, resp, requestedMonth);
            return;
        }

        if (courseName.length() > MAX_COURSE_NAME || chapterSubject.length() > MAX_CHAPTER_SUBJECT) {
            setFlashError(session, "Course or chapter text is too long.");
            redirectToMonth(req, resp, requestedMonth);
            return;
        }

        if (usedSources.length() > MAX_SOURCES) {
            setFlashError(session, "Used sources field is too long.");
            redirectToMonth(req, resp, requestedMonth);
            return;
        }

        if (notes.length() > MAX_NOTES) {
            setFlashError(session, "Notes are too long.");
            redirectToMonth(req, resp, requestedMonth);
            return;
        }

        LocalDate activityDate;
        try {
            activityDate = LocalDate.parse(activityDateS);
        } catch (DateTimeParseException ex) {
            setFlashError(session, "Activity date is invalid.");
            redirectToMonth(req, resp, requestedMonth);
            return;
        }

        int reviewMinutes = parseMinutes(reviewMinutesS);
        int studiedMinutes = parseMinutes(studiedMinutesS);
        if (reviewMinutes < 0 || reviewMinutes > 1440 || studiedMinutes < 0 || studiedMinutes > 1440) {
            setFlashError(session, "Review and studied time must be between 0 and 1440 minutes.");
            redirectToMonth(req, resp, requestedMonth);
            return;
        }

        if (reviewMinutes == 0 && studiedMinutes == 0) {
            setFlashError(session, "Add at least one time value (review or studied).");
            redirectToMonth(req, resp, requestedMonth);
            return;
        }

        if ("DONE".equals(status) && studiedMinutes == 0) {
            setFlashError(session, "Completed activities require studied time greater than 0.");
            redirectToMonth(req, resp, requestedMonth);
            return;
        }

        if ("edit".equals(mode) && activityId <= 0) {
            setFlashError(session, "Invalid activity id.");
            redirectToMonth(req, resp, requestedMonth);
            return;
        }

        try {
            if ("edit".equals(mode)) {
                boolean updated = StudyActivityDAO.updateActivity(
                        userId,
                        activityId,
                        activityDate,
                        status,
                        courseName,
                        chapterSubject,
                        reviewMinutes,
                        studiedMinutes,
                        usedSources.isEmpty() ? null : usedSources,
                        notes.isEmpty() ? null : notes
                );

                if (!updated) {
                    setFlashError(session, "Activity not found or not allowed.");
                    redirectToMonth(req, resp, requestedMonth);
                    return;
                }
                session.setAttribute("flashSuccess", "Activity updated for " + activityDate + ".");
            } else {
                StudyActivityDAO.createActivity(
                        userId,
                        activityDate,
                        status,
                        courseName,
                        chapterSubject,
                        reviewMinutes,
                        studiedMinutes,
                        usedSources.isEmpty() ? null : usedSources,
                        notes.isEmpty() ? null : notes
                );
                session.setAttribute("flashSuccess", "Activity saved for " + activityDate + ".");
            }

            redirectToMonth(req, resp, YearMonth.from(activityDate));
        } catch (SQLException e) {
            log("Database error while saving activity", e);
            setFlashError(session, "Database error while saving activity.");
            redirectToMonth(req, resp, requestedMonth);
        }
    }

    private String resolveDisplayName(HttpSession session) {
        Object name = session.getAttribute("userName");
        if (name instanceof String s && !s.isBlank()) {
            return s;
        }
        Object email = session.getAttribute("userEmail");
        return (email instanceof String s && !s.isBlank()) ? s : "Student";
    }

    private void setFlashError(HttpSession session, String message) {
        session.setAttribute("flashError", message);
    }

    private void consumeFlash(HttpSession session, HttpServletRequest req) {
        Object success = session.getAttribute("flashSuccess");
        if (success != null) {
            req.setAttribute("flashSuccess", success);
            session.removeAttribute("flashSuccess");
        }
        Object error = session.getAttribute("flashError");
        if (error != null) {
            req.setAttribute("flashError", error);
            session.removeAttribute("flashError");
        }
    }

    private void redirectToMonth(HttpServletRequest req, HttpServletResponse resp, YearMonth month) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/dashboard?month=" + month.format(MONTH_PARAM_FORMAT));
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

    private YearMonth parseMonth(String monthParam) {
        String value = trim(monthParam);
        if (value.isEmpty()) {
            return YearMonth.now();
        }
        try {
            return YearMonth.parse(value, MONTH_PARAM_FORMAT);
        } catch (DateTimeParseException ex) {
            return YearMonth.now();
        }
    }

    private List<List<LocalDate>> buildCalendarRows(YearMonth month) {
        List<LocalDate> cells = new ArrayList<>(42);

        LocalDate firstDay = month.atDay(1);
        int leadingEmpty = firstDay.getDayOfWeek().getValue() - 1; // Monday=1, Sunday=7
        for (int i = 0; i < leadingEmpty; i++) {
            cells.add(null);
        }

        for (int day = 1; day <= month.lengthOfMonth(); day++) {
            cells.add(month.atDay(day));
        }

        while (cells.size() < 42) {
            cells.add(null);
        }

        List<List<LocalDate>> rows = new ArrayList<>(6);
        for (int i = 0; i < 42; i += 7) {
            rows.add(new ArrayList<>(cells.subList(i, i + 7)));
        }
        return rows;
    }

    private String trim(String value) {
        return (value == null) ? "" : value.trim();
    }

    private int parseMinutes(String raw) {
        if (raw == null || raw.isBlank()) {
            return 0;
        }
        try {
            return Integer.parseInt(raw);
        } catch (NumberFormatException ex) {
            return -1;
        }
    }

    private int parsePositiveInt(String raw) {
        if (raw == null || raw.isBlank()) {
            return -1;
        }
        try {
            int value = Integer.parseInt(raw.trim());
            return value > 0 ? value : -1;
        } catch (NumberFormatException ex) {
            return -1;
        }
    }
}
