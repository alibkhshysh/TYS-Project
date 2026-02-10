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
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

@WebServlet("/analysis")
public class AnalysisServlet extends HttpServlet {

    private static final DateTimeFormatter MONTH_PARAM_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM");
    private static final DateTimeFormatter MONTH_TITLE_FORMAT = DateTimeFormatter.ofPattern("MMMM yyyy", Locale.ENGLISH);

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

            req.setAttribute("displayName", resolveDisplayName(session));
            req.setAttribute("monthParam", month.format(MONTH_PARAM_FORMAT));
            req.setAttribute("monthLabel", month.format(MONTH_TITLE_FORMAT));
            req.setAttribute("prevMonthParam", month.minusMonths(1).format(MONTH_PARAM_FORMAT));
            req.setAttribute("nextMonthParam", month.plusMonths(1).format(MONTH_PARAM_FORMAT));
            req.setAttribute("prevMonthLabel",
                    month.minusMonths(1).getMonth().getDisplayName(TextStyle.FULL, Locale.ENGLISH));
            req.setAttribute("nextMonthLabel",
                    month.plusMonths(1).getMonth().getDisplayName(TextStyle.FULL, Locale.ENGLISH));

            populateAnalysisAttributes(req, month, today, activitiesByDate);
            req.getRequestDispatcher("/WEB-INF/views/analysis.jsp").forward(req, resp);
        } catch (SQLException e) {
            log("Database error while loading analysis", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }

    private void populateAnalysisAttributes(HttpServletRequest req,
                                            YearMonth month,
                                            LocalDate today,
                                            Map<LocalDate, List<StudyActivity>> activitiesByDate) {
        int totalActivities = 0;
        int doneActivities = 0;
        int todoActivities = 0;
        int totalRelatedMinutes = 0;
        int totalStudiedMinutes = 0;
        int totalReviewMinutes = 0;
        int overdueTodoCount = 0;
        int pendingTodoMinutes = 0;

        int firstWeekOffset = month.atDay(1).getDayOfWeek().getValue() - 1;

        Map<String, CourseAccumulator> byCourse = new HashMap<>();
        Map<Integer, WeekAccumulator> byWeek = new TreeMap<>();

        for (Map.Entry<LocalDate, List<StudyActivity>> entry : activitiesByDate.entrySet()) {
            LocalDate day = entry.getKey();
            List<StudyActivity> dayActivities = entry.getValue();
            if (day == null || dayActivities == null || dayActivities.isEmpty()) {
                continue;
            }

            int weekIndex = ((day.getDayOfMonth() + firstWeekOffset - 1) / 7) + 1;
            WeekAccumulator week = byWeek.computeIfAbsent(weekIndex, k -> new WeekAccumulator());

            for (StudyActivity activity : dayActivities) {
                if (activity == null) {
                    continue;
                }

                totalActivities++;
                boolean done = activity.isDone();
                int studiedMinutes = Math.max(0, activity.getStudiedMinutes());
                int reviewMinutes = Math.max(0, activity.getReviewMinutes());
                int relatedMinutes = relatedMinutes(activity);

                totalStudiedMinutes += studiedMinutes;
                totalReviewMinutes += reviewMinutes;
                totalRelatedMinutes += relatedMinutes;

                if (done) {
                    doneActivities++;
                } else {
                    todoActivities++;
                    pendingTodoMinutes += relatedMinutes;
                    if (day.isBefore(today)) {
                        overdueTodoCount++;
                    }
                }

                String courseName = normalizeCourseName(activity.getCourseName());
                CourseAccumulator course = byCourse.computeIfAbsent(courseName, k -> new CourseAccumulator());
                course.entries++;
                course.relatedMinutes += relatedMinutes;
                course.studiedMinutes += studiedMinutes;
                course.reviewMinutes += reviewMinutes;
                if (activity.getChapterSubject() != null && !activity.getChapterSubject().isBlank()) {
                    course.subjects.add(activity.getChapterSubject().trim());
                }

                week.entries++;
                week.relatedMinutes += relatedMinutes;
                week.studiedMinutes += studiedMinutes;
                week.reviewMinutes += reviewMinutes;
                if (done) {
                    week.done++;
                } else {
                    week.todo++;
                }
            }
        }

        double completionRate = percent(doneActivities, totalActivities);
        double averageStudiedPerDone = doneActivities == 0 ? 0.0 : (double) totalStudiedMinutes / doneActivities;

        List<Map<String, Object>> courseStats = new ArrayList<>();
        byCourse.entrySet().stream()
                .sorted(Comparator
                        .comparingInt((Map.Entry<String, CourseAccumulator> e) -> e.getValue().relatedMinutes)
                        .reversed()
                        .thenComparing(Map.Entry::getKey))
                .forEach(entry -> {
                    CourseAccumulator c = entry.getValue();
                    Map<String, Object> row = new HashMap<>();
                    row.put("courseName", entry.getKey());
                    row.put("entries", c.entries);
                    row.put("relatedMinutes", c.relatedMinutes);
                    row.put("studiedMinutes", c.studiedMinutes);
                    row.put("reviewMinutes", c.reviewMinutes);
                    row.put("subjects", summarizeSubjects(c.subjects));
                    courseStats.add(row);
                });

        String mostStudiedCourse = "-";
        int mostStudiedCourseMinutes = 0;
        if (!courseStats.isEmpty()) {
            Map<String, Object> top = courseStats.get(0);
            mostStudiedCourse = String.valueOf(top.get("courseName"));
            mostStudiedCourseMinutes = (int) top.get("relatedMinutes");
        }

        List<Map<String, Object>> weekStats = new ArrayList<>();
        String mostActiveWeek = "-";
        int mostActiveWeekMinutes = 0;
        for (Map.Entry<Integer, WeekAccumulator> entry : byWeek.entrySet()) {
            int weekNumber = entry.getKey();
            WeekAccumulator w = entry.getValue();

            Map<String, Object> row = new HashMap<>();
            row.put("weekLabel", "Week " + weekNumber);
            row.put("entries", w.entries);
            row.put("done", w.done);
            row.put("todo", w.todo);
            row.put("relatedMinutes", w.relatedMinutes);
            row.put("studiedMinutes", w.studiedMinutes);
            row.put("completionRate", percent(w.done, w.entries));
            weekStats.add(row);

            if (w.relatedMinutes > mostActiveWeekMinutes) {
                mostActiveWeekMinutes = w.relatedMinutes;
                mostActiveWeek = "Week " + weekNumber;
            }
        }

        req.setAttribute("analysisTotalActivities", totalActivities);
        req.setAttribute("analysisDoneActivities", doneActivities);
        req.setAttribute("analysisTodoActivities", todoActivities);
        req.setAttribute("analysisTotalRelatedMinutes", totalRelatedMinutes);
        req.setAttribute("analysisTotalStudiedMinutes", totalStudiedMinutes);
        req.setAttribute("analysisTotalReviewMinutes", totalReviewMinutes);
        req.setAttribute("analysisCompletionRate", completionRate);
        req.setAttribute("analysisOverdueTodoCount", overdueTodoCount);
        req.setAttribute("analysisPendingTodoMinutes", pendingTodoMinutes);
        req.setAttribute("analysisAverageStudiedPerDone", averageStudiedPerDone);
        req.setAttribute("analysisCoursesCount", byCourse.size());
        req.setAttribute("analysisMostStudiedCourse", mostStudiedCourse);
        req.setAttribute("analysisMostStudiedCourseMinutes", mostStudiedCourseMinutes);
        req.setAttribute("analysisMostActiveWeek", mostActiveWeek);
        req.setAttribute("analysisMostActiveWeekMinutes", mostActiveWeekMinutes);
        req.setAttribute("analysisCourseStats", courseStats);
        req.setAttribute("analysisWeekStats", weekStats);
    }

    private int relatedMinutes(StudyActivity activity) {
        if (activity == null) {
            return 0;
        }
        if (activity.isDone()) {
            return Math.max(0, activity.getStudiedMinutes());
        }
        int review = Math.max(0, activity.getReviewMinutes());
        if (review > 0) {
            return review;
        }
        return Math.max(0, activity.getStudiedMinutes());
    }

    private String normalizeCourseName(String courseName) {
        if (courseName == null || courseName.isBlank()) {
            return "Untitled";
        }
        return courseName.trim();
    }

    private String summarizeSubjects(Set<String> subjects) {
        if (subjects == null || subjects.isEmpty()) {
            return "-";
        }
        StringBuilder sb = new StringBuilder();
        int count = 0;
        for (String s : subjects) {
            if (s == null || s.isBlank()) {
                continue;
            }
            if (count > 0) {
                sb.append(", ");
            }
            sb.append(s);
            count++;
            if (count == 3) {
                break;
            }
        }
        if (count == 0) {
            return "-";
        }
        if (subjects.size() > count) {
            sb.append(" ...");
        }
        return sb.toString();
    }

    private double percent(int part, int total) {
        if (total <= 0) {
            return 0.0;
        }
        return (part * 100.0) / total;
    }

    private String resolveDisplayName(HttpSession session) {
        Object name = session.getAttribute("userName");
        if (name instanceof String s && !s.isBlank()) {
            return s;
        }
        Object email = session.getAttribute("userEmail");
        return (email instanceof String s && !s.isBlank()) ? s : "Student";
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
        if (monthParam == null || monthParam.isBlank()) {
            return YearMonth.now();
        }
        try {
            return YearMonth.parse(monthParam, MONTH_PARAM_FORMAT);
        } catch (DateTimeParseException ex) {
            return YearMonth.now();
        }
    }

    private static final class CourseAccumulator {
        int entries;
        int relatedMinutes;
        int studiedMinutes;
        int reviewMinutes;
        Set<String> subjects = new LinkedHashSet<>();
    }

    private static final class WeekAccumulator {
        int entries;
        int done;
        int todo;
        int relatedMinutes;
        int studiedMinutes;
        int reviewMinutes;
    }
}
