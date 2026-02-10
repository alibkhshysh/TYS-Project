package it.unipd.tys.model;

import java.time.LocalDate;

public class StudyActivity {
    private final int id;
    private final int userId;
    private final LocalDate activityDate;
    private final String status;
    private final String courseName;
    private final String chapterSubject;
    private final int reviewMinutes;
    private final int studiedMinutes;
    private final String usedSources;
    private final String notes;

    public StudyActivity(int id,
                         int userId,
                         LocalDate activityDate,
                         String status,
                         String courseName,
                         String chapterSubject,
                         int reviewMinutes,
                         int studiedMinutes,
                         String usedSources,
                         String notes) {
        this.id = id;
        this.userId = userId;
        this.activityDate = activityDate;
        this.status = status;
        this.courseName = courseName;
        this.chapterSubject = chapterSubject;
        this.reviewMinutes = reviewMinutes;
        this.studiedMinutes = studiedMinutes;
        this.usedSources = usedSources;
        this.notes = notes;
    }

    public int getId() { return id; }
    public int getUserId() { return userId; }
    public LocalDate getActivityDate() { return activityDate; }
    public String getStatus() { return status; }
    public String getCourseName() { return courseName; }
    public String getChapterSubject() { return chapterSubject; }
    public int getReviewMinutes() { return reviewMinutes; }
    public int getStudiedMinutes() { return studiedMinutes; }
    public String getUsedSources() { return usedSources; }
    public String getNotes() { return notes; }

    public boolean isDone() {
        return "DONE".equalsIgnoreCase(status);
    }

    public boolean isTodo() {
        return !isDone();
    }
}
