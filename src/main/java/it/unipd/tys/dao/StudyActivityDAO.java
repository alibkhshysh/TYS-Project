package it.unipd.tys.dao;

import it.unipd.tys.model.StudyActivity;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class StudyActivityDAO {

    private static final String STATUS_DB_SCHEDULED = "TODO";
    private static final String STATUS_DB_COMPLETED = "DONE";

    public static void createActivity(
            int userId,
            LocalDate activityDate,
            String status,
            String courseName,
            String chapterSubject,
            int reviewMinutes,
            int studiedMinutes,
            String usedSources,
            String notes
    ) throws SQLException {
        String normalizedStatus = normalizeStatusForDb(status);
        String legacyTitle = buildLegacyTitle(courseName, chapterSubject);
        int legacyDuration = Math.max(1, STATUS_DB_COMPLETED.equals(normalizedStatus)
                ? studiedMinutes
                : Math.max(reviewMinutes, studiedMinutes));

        String sql = """
                INSERT INTO study_activities(
                  user_id, activity_date,
                  title, duration_minutes, notes,
                  status, course_name, chapter_subject, review_minutes, studied_minutes, used_sources
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;

        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, Date.valueOf(activityDate));
            ps.setString(3, legacyTitle);
            ps.setInt(4, legacyDuration);
            ps.setString(5, notes);
            ps.setString(6, normalizedStatus);
            ps.setString(7, courseName);
            ps.setString(8, chapterSubject);
            ps.setInt(9, reviewMinutes);
            ps.setInt(10, studiedMinutes);
            ps.setString(11, usedSources);
            ps.executeUpdate();
        }
    }

    public static boolean updateActivity(
            int userId,
            int activityId,
            LocalDate activityDate,
            String status,
            String courseName,
            String chapterSubject,
            int reviewMinutes,
            int studiedMinutes,
            String usedSources,
            String notes
    ) throws SQLException {
        String normalizedStatus = normalizeStatusForDb(status);
        String legacyTitle = buildLegacyTitle(courseName, chapterSubject);
        int legacyDuration = Math.max(1, STATUS_DB_COMPLETED.equals(normalizedStatus)
                ? studiedMinutes
                : Math.max(reviewMinutes, studiedMinutes));

        String sql = """
                UPDATE study_activities
                SET activity_date = ?,
                    title = ?,
                    duration_minutes = ?,
                    notes = ?,
                    status = ?,
                    course_name = ?,
                    chapter_subject = ?,
                    review_minutes = ?,
                    studied_minutes = ?,
                    used_sources = ?
                WHERE id = ?
                  AND user_id = ?
                """;

        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(activityDate));
            ps.setString(2, legacyTitle);
            ps.setInt(3, legacyDuration);
            ps.setString(4, notes);
            ps.setString(5, normalizedStatus);
            ps.setString(6, courseName);
            ps.setString(7, chapterSubject);
            ps.setInt(8, reviewMinutes);
            ps.setInt(9, studiedMinutes);
            ps.setString(10, usedSources);
            ps.setInt(11, activityId);
            ps.setInt(12, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public static Map<LocalDate, List<StudyActivity>> findActivitiesByMonth(int userId, YearMonth month)
            throws SQLException {
        String sql = """
                SELECT id, user_id, activity_date,
                       status, course_name, chapter_subject,
                       review_minutes, studied_minutes, used_sources,
                       title, duration_minutes, notes
                FROM study_activities
                WHERE user_id = ?
                  AND activity_date >= ?
                  AND activity_date <= ?
                ORDER BY activity_date ASC, created_at ASC, id ASC
                """;

        LocalDate start = month.atDay(1);
        LocalDate end = month.atEndOfMonth();
        Map<LocalDate, List<StudyActivity>> result = new HashMap<>();

        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, Date.valueOf(start));
            ps.setDate(3, Date.valueOf(end));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Date sqlDate = rs.getDate("activity_date");
                    LocalDate activityDate = (sqlDate == null) ? null : sqlDate.toLocalDate();
                    if (activityDate == null) {
                        continue;
                    }

                    String status = normalizeStatusForView(rs.getString("status"));

                    String courseName = rs.getString("course_name");
                    if (courseName == null || courseName.isBlank()) {
                        courseName = rs.getString("title");
                    }
                    if (courseName == null || courseName.isBlank()) {
                        courseName = "Untitled";
                    }

                    String chapterSubject = rs.getString("chapter_subject");
                    if (chapterSubject == null) {
                        chapterSubject = "";
                    }

                    int reviewMinutes = rs.getInt("review_minutes");
                    if (rs.wasNull()) {
                        reviewMinutes = 0;
                    }

                    int studiedMinutes = rs.getInt("studied_minutes");
                    if (rs.wasNull()) {
                        studiedMinutes = rs.getInt("duration_minutes");
                    }

                    String usedSources = rs.getString("used_sources");
                    if (usedSources == null) {
                        usedSources = "";
                    }

                    StudyActivity activity = new StudyActivity(
                            rs.getInt("id"),
                            rs.getInt("user_id"),
                            activityDate,
                            status,
                            courseName,
                            chapterSubject,
                            reviewMinutes,
                            studiedMinutes,
                            usedSources,
                            rs.getString("notes")
                    );
                    result.computeIfAbsent(activityDate, d -> new ArrayList<>()).add(activity);
                }
            }
        }

        return result;
    }

    public static boolean deleteActivity(int userId, int activityId) throws SQLException {
        String sql = """
                DELETE FROM study_activities
                WHERE id = ?
                  AND user_id = ?
                """;

        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, activityId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    private static String buildLegacyTitle(String courseName, String chapterSubject) {
        String course = courseName == null ? "" : courseName.trim();
        String chapter = chapterSubject == null ? "" : chapterSubject.trim();

        String merged;
        if (chapter.isEmpty()) {
            merged = course;
        } else {
            merged = course + " - " + chapter;
        }

        if (merged.isEmpty()) {
            merged = "Untitled";
        }
        return (merged.length() <= 200) ? merged : merged.substring(0, 200);
    }

    private static String normalizeStatusForDb(String status) {
        if (status == null) {
            return STATUS_DB_SCHEDULED;
        }
        String normalized = status.trim().toUpperCase();
        if ("COMPLETED".equals(normalized) || STATUS_DB_COMPLETED.equals(normalized)) {
            return STATUS_DB_COMPLETED;
        }
        return STATUS_DB_SCHEDULED;
    }

    private static String normalizeStatusForView(String status) {
        if (status == null) {
            return "SCHEDULED";
        }
        String normalized = status.trim().toUpperCase();
        if ("COMPLETED".equals(normalized) || STATUS_DB_COMPLETED.equals(normalized)) {
            return "COMPLETED";
        }
        return "SCHEDULED";
    }
}
