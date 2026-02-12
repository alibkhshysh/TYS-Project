<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="it.unipd.tys.model.StudyActivity" %>
<%!
  private String esc(String s) {
    if (s == null) return "";
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
            .replace("\"", "&quot;").replace("'", "&#39;");
  }

  private String url(String s) {
    try {
      String value = (s == null) ? "" : s;
      return java.net.URLEncoder.encode(value, java.nio.charset.StandardCharsets.UTF_8.toString());
    } catch (Exception ex) {
      return "";
    }
  }

  private int relatedTime(StudyActivity a) {
    if (a == null) return 0;
    int review = Math.max(0, a.getReviewMinutes());
    int studied = Math.max(0, a.getStudiedMinutes());
    return review + studied;
  }
%>
<%
  String monthParam = (String) request.getAttribute("monthParam");
  String monthLabel = (String) request.getAttribute("monthLabel");
  String prevMonthParam = (String) request.getAttribute("prevMonthParam");
  String nextMonthParam = (String) request.getAttribute("nextMonthParam");
  String prevMonthLabel = (String) request.getAttribute("prevMonthLabel");
  String nextMonthLabel = (String) request.getAttribute("nextMonthLabel");
  String displayName = (String) request.getAttribute("displayName");
  String flashSuccess = (String) request.getAttribute("flashSuccess");
  String flashError = (String) request.getAttribute("flashError");

  LocalDate today = (LocalDate) request.getAttribute("today");
  List<List<LocalDate>> calendarRows = (List<List<LocalDate>>) request.getAttribute("calendarRows");
  Map<LocalDate, List<StudyActivity>> activitiesByDate =
          (Map<LocalDate, List<StudyActivity>>) request.getAttribute("activitiesByDate");
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Dashboard</title>
  <style>
    :root {
      --bg: #f9f9fb;
      --surface: #ffffff;
      --surface-alt: #fff7f7;
      --text: #222;
      --muted: #666;
      --line: #e4d7d8;
      --accent: #9f171d;
      --accent-soft: #fcebec;
      --scheduled-blue: #0f5fae;
      --scheduled-blue-soft: #e9f2ff;
      --completed-green: #1f8f50;
      --completed-green-soft: #eaf9f0;
      --late-red: #b42318;
      --late-red-soft: #fdecec;
      --empty-red-soft: #fff1f1;
    }

    * { box-sizing: border-box; }

    body {
      margin: 0;
      background: var(--bg);
      color: var(--text);
      font-family: "Segoe UI", "Trebuchet MS", Arial, sans-serif;
    }

    .topbar {
      background: var(--surface);
      border-bottom: 1px solid var(--line);
      padding: 18px 26px;
    }

    .topbar h1 {
      margin: 0;
      color: var(--accent);
      font-size: 2rem;
      font-weight: 700;
      letter-spacing: 0.2px;
    }

    .layout {
      max-width: 1700px;
      margin: 0 auto;
      padding: 18px;
      display: grid;
      grid-template-columns: minmax(0, 1fr) 300px;
      gap: 18px;
    }

    .panel {
      background: var(--surface);
      border: 1px solid var(--line);
      border-radius: 14px;
    }

    .calendar-panel {
      padding: 14px;
    }

    .month-nav {
      display: grid;
      grid-template-columns: 1fr auto 1fr;
      gap: 8px;
      align-items: center;
      margin-bottom: 12px;
    }

    .month-nav a {
      text-decoration: none;
      color: var(--accent);
      font-weight: 700;
    }

    .month-nav .prev { justify-self: start; }
    .month-nav .next { justify-self: end; }
    .month-nav .current {
      color: var(--text);
      font-size: 1.25rem;
      font-weight: 700;
    }

    .flash {
      border-radius: 10px;
      padding: 10px 12px;
      margin-bottom: 10px;
      font-weight: 600;
      border: 1px solid transparent;
    }

    .flash-success {
      color: #137a41;
      background: #eaf9f0;
      border-color: #a8e3be;
    }

    .flash-error {
      color: #a01616;
      background: #fdecec;
      border-color: #f6b6b6;
    }

    table.calendar {
      width: 100%;
      border-collapse: collapse;
      table-layout: fixed;
      border: 1px solid var(--line);
      border-radius: 12px;
      overflow: hidden;
    }

    .calendar th {
      background: #fff6f6;
      color: #5f2930;
      border-bottom: 1px solid var(--line);
      padding: 8px;
      text-align: left;
      font-weight: 700;
    }

    .calendar td {
      --day-cell-height: 220px;
      border-top: 1px solid var(--line);
      border-left: 1px solid var(--line);
      vertical-align: top;
      padding: 0;
      height: var(--day-cell-height);
      overflow: hidden;
    }

    .calendar tr td:first-child { border-left: none; }
    .empty-day { background: #fcfbfb; }

    .day-cell {
      background: #fff;
      cursor: pointer;
    }

    .day-cell.day-state-empty {
      background: linear-gradient(180deg, #fff6f7 0%, #fdeff0 66%, #f8e0e3 100%);
    }

    .day-cell.day-state-scheduled {
      background: linear-gradient(180deg, #f4f8ff 0%, #eaf2ff 66%, #dbe8ff 100%);
    }

    .day-cell.day-state-overdue {
      background: linear-gradient(180deg, #f7e2e5 0%, #f2d2d6 66%, #eab8be 100%);
    }

    .day-cell.day-state-completed {
      background: linear-gradient(180deg, #f3fcf7 0%, #ecf8f1 66%, #dcf1e4 100%);
    }

    .day-cell.day-state-mixed {
      background: linear-gradient(to right, #eaf2ff 0%, #eaf2ff 50%, #ecf8f1 50%, #ecf8f1 100%);
    }

    .day-cell.day-state-mixed-overdue {
      background: linear-gradient(to right, #f2d2d6 0%, #f2d2d6 50%, #ecf8f1 50%, #ecf8f1 100%);
    }

    .day-wrapper {
      height: 100%;
      padding: 8px;
      display: flex;
      flex-direction: column;
      gap: 0;
      overflow: hidden;
      box-sizing: border-box;
      border-radius: 10px;
      border: 1px solid #dccdd0;
      background: rgba(255, 255, 255, 0.12);
      transition: box-shadow 150ms ease, transform 150ms ease, border-color 150ms ease, background-color 150ms ease;
      position: relative;
      isolation: isolate;
    }

    /* Crystal finish block start (visual-only, safe to revert as one block) */
    .day-wrapper::before {
      content: "";
      position: absolute;
      inset: 0;
      border-radius: inherit;
      pointer-events: none;
      background: linear-gradient(160deg, rgba(255, 255, 255, 0.44) 0%, rgba(255, 255, 255, 0.16) 36%, rgba(255, 255, 255, 0.05) 58%, rgba(255, 255, 255, 0) 80%);
      z-index: 0;
    }

    .day-wrapper > * {
      position: relative;
      z-index: 1;
    }
    /* Crystal finish block end */

    .day-cell:hover .day-wrapper,
    .day-cell:focus-within .day-wrapper {
      box-shadow: 0 2px 10px rgba(93, 62, 67, 0.14), inset 0 0 0 1px rgba(255, 255, 255, 0.35);
      transform: translateY(-1px);
      border-color: #cab0b4;
    }

    .day-cell.day-state-empty:hover {
      background: linear-gradient(180deg, #fff9fa 0%, #fbe2e4 65%, #f5d4d8 100%);
    }

    .day-cell.day-state-scheduled:hover {
      background: linear-gradient(180deg, #f8fbff 0%, #ddeaff 65%, #cfe1ff 100%);
    }

    .day-cell.day-state-overdue:hover {
      background: linear-gradient(180deg, #f9e8ea 0%, #ebc2c8 65%, #e3a9b0 100%);
    }

    .day-cell.day-state-completed:hover {
      background: linear-gradient(180deg, #f8fdfb 0%, #e3f5eb 65%, #d1ecd9 100%);
    }

    .day-cell.day-state-mixed:hover {
      background: linear-gradient(to right, #ddeaff 0%, #ddeaff 50%, #e3f5eb 50%, #e3f5eb 100%);
    }

    .day-cell.day-state-mixed-overdue:hover {
      background: linear-gradient(to right, #ebc2c8 0%, #ebc2c8 50%, #e3f5eb 50%, #e3f5eb 100%);
    }

    .day-top {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 6px;
    }

    .day-number {
      font-weight: 800;
      color: #6f1d24;
      border-radius: 999px;
      padding: 2px 9px;
      font-size: 0.9rem;
      min-width: 28px;
      min-height: 28px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      position: relative;
    }

    .day-number-btn {
      border: 1px solid #bb5b64;
      background: #fff;
      cursor: pointer;
      line-height: 1;
      box-shadow: 0 0 0 2px rgba(187, 91, 100, 0.18), 0 1px 0 rgba(111, 29, 36, 0.08);
      transition: transform 140ms ease, box-shadow 140ms ease, background-color 140ms ease, border-color 140ms ease, color 140ms ease, opacity 140ms ease;
    }

    .day-number-btn:hover,
    .day-number-btn:focus-visible {
      background: #fcebec;
      border-color: #9f171d;
      box-shadow: 0 0 0 3px rgba(159, 23, 29, 0.22), 0 3px 8px rgba(111, 29, 36, 0.2);
      transform: translateY(-1px);
      outline: none;
    }

    .day-number-btn.today {
      background: var(--accent);
      border-color: var(--accent);
      color: #fff;
      box-shadow: 0 2px 6px rgba(159, 23, 29, 0.28);
    }

    .day-number-btn.today:hover,
    .day-number-btn.today:focus-visible {
      background: #861217;
      border-color: #861217;
    }

    .day-details {
      display: none;
      width: 100%;
      min-width: 0;
      box-sizing: border-box;
      padding: 0;
      margin: 0;
    }

    .day-cell.has-activities:hover .day-details,
    .day-cell.has-activities:focus-within .day-details {
      display: block;
      margin-bottom: 8px;
    }

    .activity-columns {
      min-height: 0;
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 6px;
      width: 100%;
      min-width: 0;
      align-items: stretch;
    }

    .activity-columns.single-col {
      grid-template-columns: 1fr;
    }

    .activity-col {
      border: 1px solid #eadfe0;
      border-radius: 8px;
      background: #fff;
      padding: 6px;
      min-height: 0;
      min-width: 0;
      width: 100%;
      display: flex;
      flex-direction: column;
      gap: 4px;
      overflow: hidden;
    }

    .scheduled-col {
      background: linear-gradient(180deg, #fcfeff 0%, #f5faff 100%);
      border-color: #cfe1f7;
      box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.75);
    }
    .completed-col {
      background: linear-gradient(180deg, #fbfffd 0%, #f3fcf7 100%);
      border-color: #cde8d8;
      box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.75);
    }
    .overdue-col {
      background: linear-gradient(180deg, #fff8f8 0%, #fff1f2 100%);
      border-color: #e0b2b8;
      box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.72);
    }

    .col-head {
      font-size: 0.72rem;
      font-weight: 800;
      text-transform: uppercase;
      letter-spacing: 0.4px;
    }

    .scheduled-head { color: var(--scheduled-blue); }
    .completed-head { color: var(--completed-green); }
    .overdue-head { color: #8e1c24; }

    .summary-columns {
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 6px;
      align-items: stretch;
    }

    .summary-col {
      min-width: 0;
      justify-content: flex-start;
      gap: 4px;
      padding: 5px 6px;
      border-radius: 7px;
    }

    .summary-col .col-head {
      font-size: 0.56rem;
      line-height: 1.08;
      letter-spacing: 0.1px;
      text-transform: none;
      white-space: normal;
      overflow: visible;
      text-overflow: clip;
      word-break: break-word;
    }

    .summary-time {
      font-size: 0.6rem;
      font-weight: 700;
      line-height: 1.12;
      color: #2f3a45;
      width: 100%;
      white-space: normal;
      overflow: visible;
      text-overflow: clip;
      word-break: break-word;
    }

    .activity-list {
      list-style: none;
      margin: 0;
      padding: 0;
      display: grid;
      grid-template-columns: 1fr;
      align-content: start;
      gap: 4px;
      width: 100%;
      min-width: 0;
      overflow-x: hidden;
      overflow-y: auto;
      max-height: 114px;
      scrollbar-width: thin;
      scrollbar-color: #d5c3c6 transparent;
    }

    .activity-list::-webkit-scrollbar {
      width: 6px;
      height: 6px;
    }

    .activity-list::-webkit-scrollbar-track {
      background: transparent;
    }

    .activity-list::-webkit-scrollbar-thumb {
      background: #d5c3c6;
      border-radius: 999px;
    }

    .activity-item {
      width: 100%;
      min-width: 0;
      box-sizing: border-box;
      border-radius: 7px;
      padding: 4px 5px;
      font-size: 0.72rem;
      line-height: 1.2;
    }

    .activity-main {
      display: flex;
      width: 100%;
      min-width: 0;
      justify-content: space-between;
      align-items: flex-start;
      gap: 6px;
    }

    .activity-main > div {
      min-width: 0;
      flex: 1;
    }

    .activity-item.scheduled {
      background: linear-gradient(180deg, #f4f9ff 0%, var(--scheduled-blue-soft) 100%);
      border: 1px solid #bcd6f5;
      color: #0b3f76;
      box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.62);
    }

    .activity-item.scheduled.overdue {
      background: linear-gradient(180deg, #fff3f4 0%, var(--late-red-soft) 100%);
      border-color: #efb2b2;
      color: var(--late-red);
      box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.58);
    }

    .activity-item.completed {
      background: linear-gradient(180deg, #f6fff9 0%, var(--completed-green-soft) 100%);
      border: 1px solid #b8e5cb;
      color: #17663b;
      box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.62);
    }

    .line-main {
      font-weight: 700;
      display: block;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .line-sub {
      display: block;
      color: #5f6772;
      font-size: 0.67rem;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .edit-btn {
      margin-left: auto;
      border: 1px solid #d7c6c8;
      border-radius: 6px;
      background: #fff;
      color: #563437;
      font-size: 0.64rem;
      font-weight: 700;
      padding: 2px 6px;
      line-height: 1.15;
      white-space: nowrap;
      cursor: pointer;
      flex-shrink: 0;
    }

    .edit-btn:hover {
      border-color: #d99aa1;
      background: #fcebec;
      color: var(--accent);
    }

    .activity-actions {
      display: flex;
      align-items: flex-start;
      gap: 4px;
      flex-shrink: 0;
    }

    .delete-btn {
      border: 1px solid #d99aa1;
      border-radius: 6px;
      background: #fff7f8;
      color: #9f171d;
      font-size: 0.64rem;
      font-weight: 700;
      padding: 2px 6px;
      line-height: 1.15;
      white-space: nowrap;
      cursor: pointer;
      flex-shrink: 0;
    }

    .delete-btn:hover {
      background: #9f171d;
      color: #fff;
      border-color: #9f171d;
    }

    .day-bottom {
      margin-top: auto;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 6px;
    }

    .completed-total {
      width: 100%;
      border-radius: 8px;
      background: #f2f6f5;
      border: 1px solid #d7e3dd;
      padding: 4px 6px;
      text-align: center;
      font-size: 0.72rem;
      color: #2a5f43;
      font-weight: 700;
    }

    .add-btn {
      border: 1px solid var(--accent);
      color: var(--accent);
      background: #fff;
      border-radius: 999px;
      font-size: 0.72rem;
      font-weight: 800;
      padding: 4px 14px;
      cursor: pointer;
    }

    .add-btn:hover {
      background: var(--accent);
      color: #fff;
    }

    .sidebar {
      display: grid;
      gap: 14px;
      align-content: start;
    }

    .side-card {
      padding: 14px;
    }

    .side-card h2 {
      margin: 0 0 6px;
      color: var(--accent);
      font-size: 1.1rem;
    }

    .hello {
      margin: 0;
      color: #7a3238;
      font-weight: 700;
    }

    .hello strong {
      display: block;
      margin-top: 4px;
      color: #2f2f2f;
      font-size: 1.02rem;
    }

    .menu a {
      display: block;
      padding: 9px 10px;
      margin-bottom: 4px;
      border-radius: 8px;
      text-decoration: none;
      color: #2f2f2f;
      font-weight: 700;
    }

    .menu a:hover {
      background: var(--accent-soft);
      color: var(--accent);
    }

    dialog {
      width: min(620px, 94vw);
      border: none;
      border-radius: 14px;
      padding: 0;
      box-shadow: 0 24px 64px rgba(0, 0, 0, 0.26);
    }

    dialog::backdrop {
      background: rgba(36, 12, 14, 0.5);
    }

    .dialog-head {
      background: #fff6f6;
      border-bottom: 1px solid #efdbdc;
      padding: 12px 14px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .dialog-head strong {
      color: var(--accent);
      font-size: 1.04rem;
    }

    .dialog-body {
      padding: 14px;
      display: grid;
      gap: 9px;
    }

    .dialog-body label {
      font-size: 0.88rem;
      font-weight: 700;
      color: #5f2b31;
    }

    .dialog-body input,
    .dialog-body select,
    .dialog-body textarea {
      width: 100%;
      border: 1px solid #e6d8d9;
      border-radius: 8px;
      padding: 8px 9px;
      font: inherit;
      background: #fff;
    }

    .dialog-grid-2 {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 10px;
    }

    .dialog-body textarea {
      min-height: 74px;
      resize: vertical;
    }

    .day-dialog-content {
      display: grid;
      gap: 10px;
    }

    .day-dialog-empty {
      border: 1px dashed #e7d4d6;
      border-radius: 9px;
      padding: 10px 12px;
      color: #6b5356;
      background: #fff8f8;
      font-size: 0.88rem;
    }

    .day-dialog-columns {
      min-height: unset;
    }

    .day-dialog-columns .activity-list {
      max-height: 220px;
    }

    .day-dialog-columns .line-note {
      margin-top: 4px;
      display: block;
      color: #5f4f52;
      font-size: 0.67rem;
      line-height: 1.35;
      white-space: normal;
      word-break: break-word;
      opacity: 0.95;
    }

    .day-dialog-total {
      border: 1px solid #d7e3dd;
      background: #f2f6f5;
      border-radius: 8px;
      padding: 8px 10px;
      text-align: center;
      font-size: 0.86rem;
      color: #2a5f43;
      font-weight: 700;
    }

    .dialog-actions {
      margin-top: 4px;
      display: flex;
      justify-content: flex-end;
      gap: 8px;
    }

    .btn {
      border-radius: 8px;
      border: 1px solid #d7c6c8;
      background: #fff;
      color: #4d3336;
      font-weight: 700;
      padding: 8px 12px;
      cursor: pointer;
    }

    .btn-primary {
      border-color: var(--accent);
      background: var(--accent);
      color: #fff;
    }

    .btn-primary:hover {
      background: #7e1116;
    }

    @media (max-width: 1140px) {
      .layout {
        grid-template-columns: 1fr;
      }
    }

    @media (max-width: 760px) {
      .calendar td {
        --day-cell-height: 250px;
        height: var(--day-cell-height);
      }
      .activity-columns { grid-template-columns: 1fr; }
      .dialog-grid-2 { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>
  <header class="topbar">
    <h1>Dashboard</h1>
  </header>

  <main class="layout">
    <section class="panel calendar-panel" aria-labelledby="monthTitle">
      <div class="month-nav">
        <a class="prev" href="<%= request.getContextPath() %>/dashboard?month=<%= esc(prevMonthParam) %>">&laquo; <%= esc(prevMonthLabel) %></a>
        <div class="current" id="monthTitle"><%= esc(monthLabel) %></div>
        <a class="next" href="<%= request.getContextPath() %>/dashboard?month=<%= esc(nextMonthParam) %>"><%= esc(nextMonthLabel) %> &raquo;</a>
      </div>

      <% if (flashSuccess != null) { %>
      <div class="flash flash-success"><%= esc(flashSuccess) %></div>
      <% } %>
      <% if (flashError != null) { %>
      <div class="flash flash-error"><%= esc(flashError) %></div>
      <% } %>

      <table class="calendar" aria-label="Monthly calendar">
        <thead>
          <tr>
            <th>Mon</th>
            <th>Tue</th>
            <th>Wed</th>
            <th>Thu</th>
            <th>Fri</th>
            <th>Sat</th>
            <th>Sun</th>
          </tr>
        </thead>
        <tbody>
          <% for (List<LocalDate> week : calendarRows) { %>
          <tr>
            <% for (LocalDate day : week) { %>
              <% if (day == null) { %>
                <td class="empty-day"></td>
              <% } else { %>
                <%
                  List<StudyActivity> all = activitiesByDate.get(day);
                  List<StudyActivity> scheduledList = new ArrayList<>();
                  List<StudyActivity> completedList = new ArrayList<>();
                  int completedTotalTime = 0;
                  int scheduledTotalTime = 0;

                  if (all != null) {
                    for (StudyActivity a : all) {
                      if (a == null) continue;
                      if (a.isCompleted()) {
                        completedList.add(a);
                        completedTotalTime += relatedTime(a);
                      } else {
                        scheduledList.add(a);
                        scheduledTotalTime += relatedTime(a);
                      }
                    }
                  }

                  boolean noActivities = scheduledList.isEmpty() && completedList.isEmpty();
                  boolean hasCompleted = !completedList.isEmpty();
                  boolean hasScheduled = !scheduledList.isEmpty();
                  boolean hasMissedScheduled = hasScheduled && today != null && day.isBefore(today);
                  boolean hasActivities = !noActivities;
                  boolean isToday = today != null && today.equals(day);
                  String dayClass = "day-cell";
                  if (hasActivities) {
                    dayClass += " has-activities";
                    if (hasCompleted && hasScheduled) {
                      dayClass += hasMissedScheduled ? " day-state-mixed-overdue" : " day-state-mixed";
                    } else if (hasCompleted) {
                      dayClass += " day-state-completed";
                    } else if (hasMissedScheduled) {
                      dayClass += " day-state-overdue";
                    } else {
                      dayClass += " day-state-scheduled";
                    }
                  } else {
                    dayClass += " day-state-empty";
                  }
                  String dayIso = day.toString();
                %>
                <td class="<%= dayClass %>">
                  <div class="day-wrapper">
                    <div class="day-top">
                      <button
                              type="button"
                              class="day-number day-number-btn <%= isToday ? "today" : "" %>"
                              data-day-open="1"
                              data-date="<%= esc(dayIso) %>"
                              title="Open details for <%= esc(dayIso) %>"
                              aria-label="Open details for <%= esc(dayIso) %>"
                      ><%= day.getDayOfMonth() %></button>
                    </div>

                    <% if (hasActivities) { %>
                    <div class="day-details">
                      <div class="activity-columns summary-columns">
                        <section class="activity-col <%= hasMissedScheduled ? "overdue-col" : "scheduled-col" %> summary-col" aria-label="Scheduled activities summary">
                          <div class="col-head <%= hasMissedScheduled ? "overdue-head" : "scheduled-head" %>">Scheduled Activities</div>
                          <div class="summary-time">Total time: <%= scheduledTotalTime %>m</div>
                        </section>
                        <section class="activity-col completed-col summary-col" aria-label="Completed activities summary">
                          <div class="col-head completed-head">Completed Activities</div>
                          <div class="summary-time">Total time: <%= completedTotalTime %>m</div>
                        </section>
                      </div>
                    </div>

                    <div class="day-popup-source" hidden>
                      <div class="activity-columns <%= (hasCompleted && hasScheduled) ? "" : "single-col" %>">
                        <% if (hasScheduled) { %>
                        <section class="activity-col <%= hasMissedScheduled ? "overdue-col" : "scheduled-col" %>" aria-label="Scheduled activities">
                          <div class="col-head <%= hasMissedScheduled ? "overdue-head" : "scheduled-head" %>">Scheduled Activities</div>
                          <ul class="activity-list">
                            <% for (StudyActivity a : scheduledList) { %>
                              <li class="activity-item scheduled <%= hasMissedScheduled ? "overdue" : "" %>" title="<%= esc(a.getNotes()) %>">
                                <div class="activity-main">
                                  <div>
                                    <span class="line-main"><%= esc(a.getCourseName()) %> -> <%= relatedTime(a) %>m</span>
                                    <% if (a.getChapterSubject() != null && !a.getChapterSubject().isBlank()) { %>
                                    <span class="line-sub"><%= esc(a.getChapterSubject()) %></span>
                                    <% } %>
                                  </div>
                                  <div class="activity-actions">
                                    <button
                                            type="button"
                                            class="edit-btn"
                                            data-activity-id="<%= a.getId() %>"
                                            data-date="<%= esc(dayIso) %>"
                                            data-status="<%= esc(a.getStatus()) %>"
                                            data-course="<%= esc(url(a.getCourseName())) %>"
                                            data-subject="<%= esc(url(a.getChapterSubject())) %>"
                                            data-review="<%= a.getReviewMinutes() %>"
                                            data-studied="<%= a.getStudiedMinutes() %>"
                                            data-sources="<%= esc(url(a.getUsedSources())) %>"
                                            data-notes="<%= esc(url(a.getNotes())) %>"
                                    >Edit</button>
                                    <button
                                            type="button"
                                            class="delete-btn"
                                            data-activity-id="<%= a.getId() %>"
                                            data-course="<%= esc(url(a.getCourseName())) %>"
                                    >Delete</button>
                                  </div>
                                </div>
                              </li>
                            <% } %>
                          </ul>
                        </section>
                        <% } %>

                        <% if (hasCompleted) { %>
                        <section class="activity-col completed-col" aria-label="Completed activities">
                          <div class="col-head completed-head">Completed Activities</div>
                          <ul class="activity-list">
                            <% for (StudyActivity a : completedList) { %>
                              <li class="activity-item completed" title="<%= esc(a.getNotes()) %>">
                                <div class="activity-main">
                                  <div>
                                    <span class="line-main"><%= esc(a.getCourseName()) %> -> <%= relatedTime(a) %>m</span>
                                    <% if (a.getChapterSubject() != null && !a.getChapterSubject().isBlank()) { %>
                                    <span class="line-sub"><%= esc(a.getChapterSubject()) %></span>
                                    <% } %>
                                  </div>
                                  <div class="activity-actions">
                                    <button
                                            type="button"
                                            class="edit-btn"
                                            data-activity-id="<%= a.getId() %>"
                                            data-date="<%= esc(dayIso) %>"
                                            data-status="<%= esc(a.getStatus()) %>"
                                            data-course="<%= esc(url(a.getCourseName())) %>"
                                            data-subject="<%= esc(url(a.getChapterSubject())) %>"
                                            data-review="<%= a.getReviewMinutes() %>"
                                            data-studied="<%= a.getStudiedMinutes() %>"
                                            data-sources="<%= esc(url(a.getUsedSources())) %>"
                                            data-notes="<%= esc(url(a.getNotes())) %>"
                                    >Edit</button>
                                    <button
                                            type="button"
                                            class="delete-btn"
                                            data-activity-id="<%= a.getId() %>"
                                            data-course="<%= esc(url(a.getCourseName())) %>"
                                    >Delete</button>
                                  </div>
                                </div>
                              </li>
                            <% } %>
                          </ul>
                        </section>
                        <% } %>
                      </div>
                      <% if (hasCompleted) { %>
                      <div class="completed-total">Completed total: <%= completedTotalTime %>m</div>
                      <% } %>
                    </div>
                    <% } %>

                    <div class="day-bottom">
                      <button type="button" class="add-btn" data-date="<%= esc(dayIso) %>">Add Activity</button>
                    </div>
                  </div>
                </td>
              <% } %>
            <% } %>
          </tr>
          <% } %>
        </tbody>
      </table>
    </section>

    <aside class="sidebar" aria-label="Sidebar">
      <section class="panel side-card">
        <h2>Hello</h2>
        <p class="hello"><strong><%= esc(displayName) %></strong></p>
      </section>

      <nav class="panel side-card menu" aria-label="Menu">
        <a href="<%=request.getContextPath()%>/profile">My Profile</a>
        <a href="<%=request.getContextPath()%>/notes">Notes</a>
        <a href="<%=request.getContextPath()%>/analysis?month=<%= esc(monthParam) %>">Analysis</a>
        <a href="<%=request.getContextPath()%>/logout">Logout</a>
      </nav>
    </aside>
  </main>

  <dialog id="activityDialog">
    <form method="post" action="<%=request.getContextPath()%>/dashboard" id="activityForm">
      <div class="dialog-head">
        <strong id="dialogTitle">Add Study Activity</strong>
        <button type="button" class="btn" id="closeDialogBtn">Close</button>
      </div>

      <div class="dialog-body">
        <input type="hidden" name="month" value="<%= esc(monthParam) %>" />
        <input type="hidden" name="mode" id="modeInput" value="create" />
        <input type="hidden" name="activityId" id="activityIdInput" value="" />
        <input type="hidden" name="activityDate" id="activityDateInput" />

        <label for="activityDateLabel">Date</label>
        <input id="activityDateLabel" type="text" readonly />

        <div class="dialog-grid-2">
          <div>
            <label for="statusInput">Status</label>
            <select id="statusInput" name="status" required>
              <option value="SCHEDULED" selected>Scheduled Activities</option>
              <option value="COMPLETED">Completed Activities</option>
            </select>
          </div>
          <div>
            <label for="courseNameInput">Course Name</label>
            <input id="courseNameInput" name="courseName" type="text" maxlength="200" required />
          </div>
        </div>

        <label for="chapterInput">Chapter / Subject</label>
        <input id="chapterInput" name="chapterSubject" type="text" maxlength="255" />

        <div class="dialog-grid-2">
          <div>
            <label for="reviewInput">Review Time (minutes)</label>
            <input id="reviewInput" name="reviewMinutes" type="number" min="0" max="1440" value="0" />
          </div>
          <div>
            <label for="studiedInput">Studied Time (minutes)</label>
            <input id="studiedInput" name="studiedMinutes" type="number" min="0" max="1440" value="0" />
          </div>
        </div>

        <label for="sourcesInput">Used Sources (links, one per line)</label>
        <textarea id="sourcesInput" name="usedSources" maxlength="4000" placeholder="https://example.com/lesson-1"></textarea>

        <label for="notesInput">Notes</label>
        <textarea id="notesInput" name="notes" maxlength="2000"></textarea>

        <div class="dialog-actions">
          <button type="button" class="btn" id="cancelDialogBtn">Cancel</button>
          <button type="submit" class="btn btn-primary" id="saveActivityBtn">Save Activity</button>
        </div>
      </div>
    </form>
  </dialog>

  <form method="post" action="<%=request.getContextPath()%>/dashboard" id="deleteActivityForm" style="display:none;">
    <input type="hidden" name="month" value="<%= esc(monthParam) %>" />
    <input type="hidden" name="mode" value="delete" />
    <input type="hidden" name="activityId" id="deleteActivityIdInput" value="" />
  </form>

  <dialog id="dayDialog">
    <div class="dialog-head">
      <strong id="dayDialogTitle">Day Activities</strong>
      <button type="button" class="btn" id="closeDayDialogBtn">Close</button>
    </div>
    <div class="dialog-body">
      <div id="dayDialogContent" class="day-dialog-content"></div>
      <div class="dialog-actions">
        <button type="button" class="btn btn-primary" id="addFromDayBtn">Add Activity</button>
      </div>
    </div>
  </dialog>

  <script>
    (function () {
      const dialog = document.getElementById('activityDialog');
      const dayDialog = document.getElementById('dayDialog');
      const form = document.getElementById('activityForm');
      const deleteForm = document.getElementById('deleteActivityForm');
      const deleteActivityIdInput = document.getElementById('deleteActivityIdInput');
      const addButtons = document.querySelectorAll('.add-btn[data-date]');
      const dayOpenButtons = document.querySelectorAll('.day-number-btn[data-day-open="1"]');
      const dialogTitle = document.getElementById('dialogTitle');
      const saveActivityBtn = document.getElementById('saveActivityBtn');
      const modeInput = document.getElementById('modeInput');
      const activityIdInput = document.getElementById('activityIdInput');
      const activityDateInput = document.getElementById('activityDateInput');
      const activityDateLabel = document.getElementById('activityDateLabel');
      const closeButton = document.getElementById('closeDialogBtn');
      const cancelButton = document.getElementById('cancelDialogBtn');
      const courseNameInput = document.getElementById('courseNameInput');
      const statusInput = document.getElementById('statusInput');
      const chapterInput = document.getElementById('chapterInput');
      const reviewInput = document.getElementById('reviewInput');
      const studiedInput = document.getElementById('studiedInput');
      const sourcesInput = document.getElementById('sourcesInput');
      const notesInput = document.getElementById('notesInput');
      const dayDialogTitle = document.getElementById('dayDialogTitle');
      const dayDialogContent = document.getElementById('dayDialogContent');
      const closeDayDialogBtn = document.getElementById('closeDayDialogBtn');
      const addFromDayBtn = document.getElementById('addFromDayBtn');
      let currentDayDate = '';

      function closeDialog() {
        if (typeof dialog.close === 'function') {
          dialog.close();
        }
      }

      function closeDayDialog() {
        if (typeof dayDialog.close === 'function') {
          dayDialog.close();
        }
      }

      function decodeForm(value) {
        return decodeURIComponent((value || '').replace(/\+/g, '%20'));
      }

      function truncateWords(value, maxWords) {
        const text = (value || '').trim().replace(/\s+/g, ' ');
        if (!text) return '';
        const words = text.split(' ');
        if (words.length <= maxWords) return text;
        return words.slice(0, maxWords).join(' ') + ' ...';
      }

      function openAdd(date) {
        if (typeof form.reset === 'function') {
          form.reset();
        }
        modeInput.value = 'create';
        activityIdInput.value = '';
        statusInput.value = 'SCHEDULED';
        activityDateInput.value = date;
        activityDateLabel.value = date;
        dialogTitle.textContent = 'Add Study Activity';
        saveActivityBtn.textContent = 'Save Activity';

        if (typeof dialog.showModal === 'function') {
          dialog.showModal();
          courseNameInput.focus();
        }
      }

      function openEdit(button) {
        modeInput.value = 'edit';
        activityIdInput.value = button.getAttribute('data-activity-id') || '';

        const activityDate = button.getAttribute('data-date') || '';
        const status = button.getAttribute('data-status') || 'SCHEDULED';
        const courseName = decodeForm(button.getAttribute('data-course'));
        const chapterSubject = decodeForm(button.getAttribute('data-subject'));
        const reviewMinutes = button.getAttribute('data-review') || '0';
        const studiedMinutes = button.getAttribute('data-studied') || '0';
        const usedSources = decodeForm(button.getAttribute('data-sources'));
        const notes = decodeForm(button.getAttribute('data-notes'));

        activityDateInput.value = activityDate;
        activityDateLabel.value = activityDate;
        const normalizedStatus = status.toUpperCase();
        statusInput.value = (normalizedStatus === 'COMPLETED') ? 'COMPLETED' : 'SCHEDULED';
        courseNameInput.value = courseName;
        chapterInput.value = chapterSubject;
        reviewInput.value = reviewMinutes;
        studiedInput.value = studiedMinutes;
        sourcesInput.value = usedSources;
        notesInput.value = notes;

        dialogTitle.textContent = 'Edit Study Activity';
        saveActivityBtn.textContent = 'Update Activity';

        if (typeof dialog.showModal === 'function') {
          dialog.showModal();
          courseNameInput.focus();
        }
      }

      function openDayDialog(date, cell) {
        currentDayDate = date || '';
        dayDialogTitle.textContent = currentDayDate ? ('Activities - ' + currentDayDate) : 'Day Activities';
        dayDialogContent.innerHTML = '';

        const detailsColumns = cell
          ? (cell.querySelector('.day-popup-source .activity-columns') || cell.querySelector('.activity-columns'))
          : null;
        if (detailsColumns) {
          const cloneColumns = detailsColumns.cloneNode(true);
          cloneColumns.classList.add('day-dialog-columns');

          cloneColumns.querySelectorAll('.activity-item').forEach(function (item) {
            if (item.querySelector('.line-note')) return;

            const noteRaw = (item.getAttribute('title') || '').trim();
            const preview = truncateWords(noteRaw, 15);
            if (!preview) return;

            const noteLine = document.createElement('span');
            noteLine.className = 'line-note';
            noteLine.textContent = 'Note: ' + preview;
            item.appendChild(noteLine);
          });

          dayDialogContent.appendChild(cloneColumns);

          const total = cell
            ? (cell.querySelector('.day-popup-source .completed-total') || cell.querySelector('.completed-total'))
            : null;
          if (total) {
            const totalClone = total.cloneNode(true);
            totalClone.classList.add('day-dialog-total');
            dayDialogContent.appendChild(totalClone);
          }
        } else {
          const empty = document.createElement('div');
          empty.className = 'day-dialog-empty';
          empty.textContent = 'No activities registered for this day yet.';
          dayDialogContent.appendChild(empty);
        }

        if (typeof dayDialog.showModal === 'function') {
          dayDialog.showModal();
        }
      }

      function submitDelete(button) {
        if (!deleteForm || !deleteActivityIdInput) return;
        const activityId = button.getAttribute('data-activity-id') || '';
        if (!activityId) return;

        const courseName = decodeForm(button.getAttribute('data-course'));
        const message = courseName
          ? ('Delete activity "' + courseName + '"?')
          : 'Delete this activity?';
        if (!window.confirm(message)) return;

        deleteActivityIdInput.value = activityId;
        closeDayDialog();
        deleteForm.submit();
      }

      addButtons.forEach(function (button) {
        button.addEventListener('click', function () {
          const date = button.getAttribute('data-date') || '';
          openAdd(date);
        });
      });

      dayOpenButtons.forEach(function (button) {
        button.addEventListener('click', function () {
          const date = button.getAttribute('data-date') || '';
          const cell = button.closest('.day-cell');
          openDayDialog(date, cell);
        });
      });

      closeButton.addEventListener('click', closeDialog);
      cancelButton.addEventListener('click', closeDialog);

      closeDayDialogBtn.addEventListener('click', closeDayDialog);

      addFromDayBtn.addEventListener('click', function () {
        if (!currentDayDate) return;
        closeDayDialog();
        openAdd(currentDayDate);
      });

      dayDialogContent.addEventListener('click', function (event) {
        const deleteBtn = event.target.closest('.delete-btn[data-activity-id]');
        if (deleteBtn) {
          submitDelete(deleteBtn);
          return;
        }

        const btn = event.target.closest('.edit-btn[data-activity-id]');
        if (!btn) return;
        closeDayDialog();
        openEdit(btn);
      });

      dayDialog.addEventListener('click', function (event) {
        const box = dayDialog.getBoundingClientRect();
        const inside = event.clientX >= box.left && event.clientX <= box.right
          && event.clientY >= box.top && event.clientY <= box.bottom;
        if (!inside) {
          closeDayDialog();
        }
      });
    })();
  </script>
</body>
</html>

