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
    if (a.isDone()) return Math.max(0, a.getStudiedMinutes());
    return Math.max(0, a.getReviewMinutes() > 0 ? a.getReviewMinutes() : a.getStudiedMinutes());
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
      --todo-blue: #0f5fae;
      --todo-blue-soft: #e9f2ff;
      --done-green: #1f8f50;
      --done-green-soft: #eaf9f0;
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
    }

    .day-cell.day-state-empty {
      background: var(--empty-red-soft);
    }

    .day-cell.day-state-todo {
      background: #eaf2ff;
    }

    .day-cell.day-state-overdue {
      background: #fdeff0;
    }

    .day-cell.day-state-done {
      background: #ecf8f1;
    }

    .day-cell.day-state-todo:hover {
      background: #ddeaff;
    }

    .day-cell.day-state-overdue:hover {
      background: #fbe2e4;
    }

    .day-cell.day-state-done:hover {
      background: #e3f5eb;
    }

    .day-wrapper {
      height: 100%;
      padding: 8px;
      display: flex;
      flex-direction: column;
      gap: 0;
      overflow: hidden;
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
      padding: 2px 8px;
      font-size: 0.9rem;
    }

    .day-number-btn {
      border: none;
      background: transparent;
      cursor: pointer;
      line-height: 1;
    }

    .day-number-btn:hover {
      background: #f5e0e3;
    }

    .day-number.today {
      background: var(--accent);
      color: #fff;
    }

    .day-details {
      display: grid;
      gap: 6px;
      width: 100%;
      min-width: 0;
      opacity: 0;
      max-height: 0;
      overflow: hidden;
      margin: 0;
      transform: translateY(-3px);
      pointer-events: none;
      transition: opacity 180ms ease, max-height 180ms ease, margin 180ms ease, transform 180ms ease;
    }

    .day-cell.has-activities:hover .day-details,
    .day-cell.has-activities:focus-within .day-details {
      opacity: 1;
      max-height: calc(var(--day-cell-height) - 88px);
      margin-bottom: 8px;
      transform: translateY(0);
      pointer-events: auto;
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

    .todo-col { background: #f8fbff; }
    .done-col { background: #f6fff9; }

    .col-head {
      font-size: 0.72rem;
      font-weight: 800;
      text-transform: uppercase;
      letter-spacing: 0.4px;
    }

    .todo-head,
    .scheduled-head { color: var(--todo-blue); }
    .done-head,
    .completed-head { color: var(--done-green); }

    .empty-note {
      font-size: 0.72rem;
      color: #8a8a8a;
      font-style: italic;
    }

    .summary-columns {
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 6px;
    }

    .summary-col {
      justify-content: flex-start;
      gap: 4px;
      padding: 6px;
    }

    .summary-time {
      font-size: 0.7rem;
      font-weight: 700;
      line-height: 1.2;
      color: #2f3a45;
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

    .activity-item.todo {
      background: var(--todo-blue-soft);
      border: 1px solid #c2daf7;
      color: #0b3f76;
    }

    .activity-item.todo.overdue {
      background: var(--late-red-soft);
      border-color: #efb2b2;
      color: var(--late-red);
    }

    .activity-item.done {
      background: var(--done-green-soft);
      border: 1px solid #b8e5cb;
      color: #17663b;
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

    .done-total {
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
                  List<StudyActivity> todoList = new ArrayList<>();
                  List<StudyActivity> doneList = new ArrayList<>();
                  int doneStudiedTotal = 0;
                  int scheduledRegisteredTotal = 0;

                  if (all != null) {
                    for (StudyActivity a : all) {
                      if (a == null) continue;
                      if (a.isDone()) {
                        doneList.add(a);
                        doneStudiedTotal += Math.max(0, a.getStudiedMinutes());
                      } else {
                        todoList.add(a);
                        scheduledRegisteredTotal += relatedTime(a);
                      }
                    }
                  }

                  boolean noActivities = todoList.isEmpty() && doneList.isEmpty();
                  boolean hasDone = !doneList.isEmpty();
                  boolean hasTodo = !todoList.isEmpty();
                  boolean hasOverdueTodo = hasTodo && today != null && day.isBefore(today);
                  boolean hasActivities = !noActivities;
                  boolean isToday = today != null && today.equals(day);
                  String dayClass = "day-cell";
                  if (hasActivities) {
                    dayClass += " has-activities";
                    if (hasDone) {
                      dayClass += " day-state-done";
                    } else if (hasOverdueTodo) {
                      dayClass += " day-state-overdue";
                    } else {
                      dayClass += " day-state-todo";
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
                              aria-label="Open details for <%= esc(dayIso) %>"
                      ><%= day.getDayOfMonth() %></button>
                    </div>

                    <% if (hasActivities) { %>
                    <div class="day-details">
                      <div class="activity-columns summary-columns">
                        <section class="activity-col todo-col summary-col" aria-label="Scheduled activities summary">
                          <div class="col-head todo-head">Scheduled Activities</div>
                          <div class="summary-time">Total time: <%= scheduledRegisteredTotal %>m</div>
                        </section>
                        <section class="activity-col done-col summary-col" aria-label="Completed activities summary">
                          <div class="col-head done-head">Completed Activities</div>
                          <div class="summary-time">Total time: <%= doneStudiedTotal %>m</div>
                        </section>
                      </div>
                    </div>

                    <div class="day-popup-source" hidden>
                      <div class="activity-columns <%= (hasDone && hasTodo) ? "" : "single-col" %>">
                        <% if (hasTodo) { %>
                        <section class="activity-col todo-col" aria-label="Scheduled activities">
                          <div class="col-head todo-head">Scheduled Activities</div>
                          <ul class="activity-list">
                            <% for (StudyActivity a : todoList) { %>
                              <li class="activity-item todo <%= (today != null && day.isBefore(today)) ? "overdue" : "" %>" title="<%= esc(a.getNotes()) %>">
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

                        <% if (hasDone) { %>
                        <section class="activity-col done-col" aria-label="Completed activities">
                          <div class="col-head done-head">Completed Activities</div>
                          <ul class="activity-list">
                            <% for (StudyActivity a : doneList) { %>
                              <li class="activity-item done" title="<%= esc(a.getNotes()) %>">
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
                      <% if (hasDone) { %>
                      <div class="done-total">Completed total: <%= doneStudiedTotal %>m</div>
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
              <option value="TODO" selected>Scheduled Activities</option>
              <option value="DONE">Completed Activities</option>
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
      const editButtons = document.querySelectorAll('.edit-btn[data-activity-id]');
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
        statusInput.value = 'TODO';
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
        const status = button.getAttribute('data-status') || 'TODO';
        const courseName = decodeForm(button.getAttribute('data-course'));
        const chapterSubject = decodeForm(button.getAttribute('data-subject'));
        const reviewMinutes = button.getAttribute('data-review') || '0';
        const studiedMinutes = button.getAttribute('data-studied') || '0';
        const usedSources = decodeForm(button.getAttribute('data-sources'));
        const notes = decodeForm(button.getAttribute('data-notes'));

        activityDateInput.value = activityDate;
        activityDateLabel.value = activityDate;
        statusInput.value = status.toUpperCase() === 'DONE' ? 'DONE' : 'TODO';
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
            ? (cell.querySelector('.day-popup-source .done-total') || cell.querySelector('.done-total'))
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

      editButtons.forEach(function (button) {
        button.addEventListener('click', function () {
          openEdit(button);
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
