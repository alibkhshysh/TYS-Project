<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%!
  private String esc(String s) {
    if (s == null) return "";
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
            .replace("\"", "&quot;").replace("'", "&#39;");
  }

  private String jsEsc(String s) {
    if (s == null) return "";
    return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", " ").replace("\n", " ");
  }

  private int intVal(Object obj) {
    if (obj instanceof Integer) return ((Integer) obj).intValue();
    if (obj instanceof Number) return ((Number) obj).intValue();
    if (obj == null) return 0;
    try {
      return Integer.parseInt(String.valueOf(obj));
    } catch (Exception ex) {
      return 0;
    }
  }

  private double doubleVal(Object obj) {
    if (obj instanceof Double) return ((Double) obj).doubleValue();
    if (obj instanceof Number) return ((Number) obj).doubleValue();
    if (obj == null) return 0.0;
    try {
      return Double.parseDouble(String.valueOf(obj));
    } catch (Exception ex) {
      return 0.0;
    }
  }

  private String fmt1(double value) {
    return String.format(java.util.Locale.ENGLISH, "%.1f", value);
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

  int totalActivities = intVal(request.getAttribute("analysisTotalActivities"));
  int completedActivities = intVal(request.getAttribute("analysisCompletedActivities"));
  int scheduledActivities = intVal(request.getAttribute("analysisScheduledActivities"));
  int totalRelatedMinutes = intVal(request.getAttribute("analysisTotalRelatedMinutes"));
  int totalStudiedMinutes = intVal(request.getAttribute("analysisTotalStudiedMinutes"));
  int totalReviewMinutes = intVal(request.getAttribute("analysisTotalReviewMinutes"));
  int overdueScheduledCount = intVal(request.getAttribute("analysisOverdueScheduledCount"));
  int pendingScheduledMinutes = intVal(request.getAttribute("analysisPendingScheduledMinutes"));
  int coursesCount = intVal(request.getAttribute("analysisCoursesCount"));
  int mostStudiedCourseMinutes = intVal(request.getAttribute("analysisMostStudiedCourseMinutes"));
  int mostActiveWeekMinutes = intVal(request.getAttribute("analysisMostActiveWeekMinutes"));
  double completionRate = doubleVal(request.getAttribute("analysisCompletionRate"));
  double avgStudiedPerCompleted = doubleVal(request.getAttribute("analysisAverageStudiedPerCompleted"));

  String mostStudiedCourse = String.valueOf(request.getAttribute("analysisMostStudiedCourse"));
  String mostActiveWeek = String.valueOf(request.getAttribute("analysisMostActiveWeek"));
  if ("null".equals(mostStudiedCourse)) mostStudiedCourse = "-";
  if ("null".equals(mostActiveWeek)) mostActiveWeek = "-";

  List<Map<String, Object>> courseStats =
      (List<Map<String, Object>>) request.getAttribute("analysisCourseStats");
  if (courseStats == null) courseStats = new ArrayList<>();

  List<Map<String, Object>> weekStats =
      (List<Map<String, Object>>) request.getAttribute("analysisWeekStats");
  if (weekStats == null) weekStats = new ArrayList<>();

  int topCourseCount = Math.min(6, courseStats.size());
  StringBuilder topCourseLabels = new StringBuilder();
  StringBuilder topCourseMinutes = new StringBuilder();
  for (int i = 0; i < topCourseCount; i++) {
    Map<String, Object> row = courseStats.get(i);
    if (i > 0) {
      topCourseLabels.append(",");
      topCourseMinutes.append(",");
    }
    String name = String.valueOf(row.get("courseName"));
    if ("null".equals(name)) name = "-";
    topCourseLabels.append("\"").append(jsEsc(name)).append("\"");
    topCourseMinutes.append(intVal(row.get("relatedMinutes")));
  }

%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Analysis</title>
  <style>
    :root {
      --bg: #f9f9fb;
      --surface: #ffffff;
      --line: #e4d7d8;
      --accent: #9f171d;
      --accent-soft: #fcebec;
      --ok: #1f8f50;
      --warn: #0f5fae;
      --danger: #b42318;
      --muted: #6f5557;
      --text: #232323;
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

    .content {
      display: grid;
      gap: 14px;
    }

    .section {
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

    .kpi-grid {
      display: grid;
      grid-template-columns: repeat(4, minmax(0, 1fr));
      gap: 10px;
    }

    .kpi {
      border: 1px solid #ecd8da;
      border-radius: 10px;
      padding: 10px 11px;
      background: #fff8f8;
    }

    .kpi .label {
      display: block;
      font-size: 0.72rem;
      text-transform: uppercase;
      letter-spacing: 0.35px;
      color: #84595e;
      font-weight: 700;
      margin-bottom: 5px;
    }

    .kpi .value {
      display: block;
      font-size: 1.14rem;
      font-weight: 800;
      color: #6f171d;
    }

    .kpi .value.ok { color: var(--ok); }
    .kpi .value.warn { color: var(--warn); }
    .kpi .value.danger { color: var(--danger); }

    .insights {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 10px;
      margin-top: 10px;
    }

    .insight {
      border: 1px dashed #ead6d8;
      border-radius: 10px;
      padding: 10px;
      background: #fffdfd;
    }

    .insight strong {
      color: #6f171d;
    }

    .chart-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 10px;
    }

    .chart-card {
      border: 1px solid #ecd8da;
      border-radius: 10px;
      padding: 10px;
      background: #fff;
    }

    .chart-card h3 {
      margin: 0 0 10px;
      color: #5e2027;
      font-size: 1rem;
    }

    .chart-wrap {
      height: 260px;
    }

    .table-card {
      border: 1px solid #ecd8da;
      border-radius: 10px;
      overflow: hidden;
    }

    .table-card h3 {
      margin: 0;
      padding: 10px 12px;
      background: #fff6f6;
      border-bottom: 1px solid #ecd8da;
      color: #5e2027;
      font-size: 1rem;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      font-size: 0.9rem;
    }

    th, td {
      border-top: 1px solid #f0e3e4;
      padding: 8px 9px;
      text-align: left;
      vertical-align: top;
    }

    th {
      color: #6e3a41;
      background: #fff;
      font-size: 0.78rem;
      text-transform: uppercase;
      letter-spacing: 0.35px;
    }

    .empty {
      margin: 0;
      padding: 12px;
      color: var(--muted);
      font-style: italic;
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

    .menu a:hover,
    .menu a.active {
      background: var(--accent-soft);
      color: var(--accent);
    }

    @media (max-width: 1220px) {
      .kpi-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
      .chart-grid { grid-template-columns: 1fr; }
    }

    @media (max-width: 1140px) {
      .layout { grid-template-columns: 1fr; }
    }

    @media (max-width: 760px) {
      .insights { grid-template-columns: 1fr; }
      .kpi-grid { grid-template-columns: 1fr; }
      .chart-wrap { height: 240px; }
      table { font-size: 0.84rem; }
    }
  </style>
</head>
<body>
  <header class="topbar">
    <h1>Analysis</h1>
  </header>

  <main class="layout">
    <section class="content" aria-label="Analysis content">
      <section class="panel section">
        <div class="month-nav">
          <a class="prev" href="<%= request.getContextPath() %>/analysis?month=<%= esc(prevMonthParam) %>">&laquo; <%= esc(prevMonthLabel) %></a>
          <div class="current"><%= esc(monthLabel) %></div>
          <a class="next" href="<%= request.getContextPath() %>/analysis?month=<%= esc(nextMonthParam) %>"><%= esc(nextMonthLabel) %> &raquo;</a>
        </div>

        <% if (totalActivities <= 0) { %>
        <p class="empty">No activities recorded for this month yet.</p>
        <% } else { %>
        <div class="kpi-grid">
          <article class="kpi">
            <span class="label">Total Entries</span>
            <span class="value"><%= totalActivities %></span>
          </article>
          <article class="kpi">
            <span class="label">Completion Rate</span>
            <span class="value ok"><%= fmt1(completionRate) %>%</span>
          </article>
          <article class="kpi">
            <span class="label">Completed Studied Time</span>
            <span class="value"><%= totalStudiedMinutes %>m</span>
          </article>
          <article class="kpi">
            <span class="label">Planned Pending Time</span>
            <span class="value warn"><%= pendingScheduledMinutes %>m</span>
          </article>
          <article class="kpi">
            <span class="label">Overdue Scheduled Items</span>
            <span class="value danger"><%= overdueScheduledCount %></span>
          </article>
          <article class="kpi">
            <span class="label">Tracked Courses</span>
            <span class="value"><%= coursesCount %></span>
          </article>
          <article class="kpi">
            <span class="label">Avg Completed Time / Item</span>
            <span class="value"><%= fmt1(avgStudiedPerCompleted) %>m</span>
          </article>
          <article class="kpi">
            <span class="label">Total Related Time</span>
            <span class="value"><%= totalRelatedMinutes %>m</span>
          </article>
        </div>

        <div class="insights">
          <article class="insight">
            Most studied course: <strong><%= esc(mostStudiedCourse) %></strong> (<%= mostStudiedCourseMinutes %>m).
          </article>
          <article class="insight">
            Most active week: <strong><%= esc(mostActiveWeek) %></strong> (<%= mostActiveWeekMinutes %>m).
          </article>
        </div>
        <% } %>
      </section>

      <% if (totalActivities > 0) { %>
      <section class="panel section">
        <div class="chart-grid">
          <article class="chart-card">
            <h3>Completed vs Scheduled</h3>
            <div class="chart-wrap"><canvas id="statusChart"></canvas></div>
          </article>
          <article class="chart-card">
            <h3>Time Distribution (minutes)</h3>
            <div class="chart-wrap"><canvas id="timeChart"></canvas></div>
          </article>
          <article class="chart-card">
            <h3>Top Courses by Related Time</h3>
            <div class="chart-wrap"><canvas id="courseChart"></canvas></div>
          </article>
        </div>
      </section>

      <section class="panel section">
        <div class="table-card">
          <h3>Course Breakdown</h3>
          <table>
            <thead>
              <tr>
                <th>Course</th>
                <th>Entries</th>
                <th>Related</th>
                <th>Studied</th>
                <th>Review</th>
                <th>Subjects</th>
              </tr>
            </thead>
            <tbody>
              <% for (Map<String, Object> row : courseStats) {
                   if (row == null) continue;
                   String cName = String.valueOf(row.get("courseName"));
                   String subjects = String.valueOf(row.get("subjects"));
                   if ("null".equals(cName)) cName = "-";
                   if ("null".equals(subjects)) subjects = "-";
              %>
              <tr>
                <td><%= esc(cName) %></td>
                <td><%= intVal(row.get("entries")) %></td>
                <td><%= intVal(row.get("relatedMinutes")) %>m</td>
                <td><%= intVal(row.get("studiedMinutes")) %>m</td>
                <td><%= intVal(row.get("reviewMinutes")) %>m</td>
                <td><%= esc(subjects) %></td>
              </tr>
              <% } %>
            </tbody>
          </table>
        </div>
      </section>

      <section class="panel section">
        <div class="table-card">
          <h3>Weekly Breakdown</h3>
          <table>
            <thead>
              <tr>
                <th>Week</th>
                <th>Entries</th>
                <th>Completed</th>
                <th>Scheduled</th>
                <th>Related</th>
                <th>Studied</th>
                <th>Completion</th>
              </tr>
            </thead>
            <tbody>
              <% for (Map<String, Object> row : weekStats) {
                   if (row == null) continue;
                   String weekLabel = String.valueOf(row.get("weekLabel"));
                   if ("null".equals(weekLabel)) weekLabel = "-";
              %>
              <tr>
                <td><%= esc(weekLabel) %></td>
                <td><%= intVal(row.get("entries")) %></td>
                <td><%= intVal(row.get("completed")) %></td>
                <td><%= intVal(row.get("scheduled")) %></td>
                <td><%= intVal(row.get("relatedMinutes")) %>m</td>
                <td><%= intVal(row.get("studiedMinutes")) %>m</td>
                <td><%= fmt1(doubleVal(row.get("completionRate"))) %>%</td>
              </tr>
              <% } %>
            </tbody>
          </table>
        </div>
      </section>
      <% } %>
    </section>

    <aside class="sidebar" aria-label="Sidebar">
      <section class="panel side-card">
        <h2>Hello</h2>
        <p class="hello"><strong><%= esc(displayName) %></strong></p>
      </section>

      <nav class="panel side-card menu" aria-label="Menu">
        <a href="<%=request.getContextPath()%>/dashboard?month=<%= esc(monthParam) %>">Dashboard</a>
        <a href="<%=request.getContextPath()%>/profile">My Profile</a>
        <a href="<%=request.getContextPath()%>/notes">Notes</a>
        <a class="active" href="<%=request.getContextPath()%>/analysis?month=<%= esc(monthParam) %>">Analysis</a>
        <a href="<%=request.getContextPath()%>/logout">Logout</a>
      </nav>
    </aside>
  </main>

  <% if (totalActivities > 0) { %>
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.2/dist/chart.umd.min.js"></script>
  <script>
    (function () {
      const statusCtx = document.getElementById('statusChart');
      const timeCtx = document.getElementById('timeChart');
      const courseCtx = document.getElementById('courseChart');

      new Chart(statusCtx, {
        type: 'doughnut',
        data: {
          labels: ['Completed', 'Scheduled'],
          datasets: [{
            data: [<%= completedActivities %>, <%= scheduledActivities %>],
            backgroundColor: ['#1f8f50', '#0f5fae']
          }]
        },
        options: {
          maintainAspectRatio: false,
          plugins: { legend: { position: 'bottom' } }
        }
      });

      new Chart(timeCtx, {
        type: 'bar',
        data: {
          labels: ['Completed studied', 'Review', 'Pending scheduled'],
          datasets: [{
            label: 'Minutes',
            data: [<%= totalStudiedMinutes %>, <%= totalReviewMinutes %>, <%= pendingScheduledMinutes %>],
            backgroundColor: ['#1f8f50', '#9f171d', '#0f5fae']
          }]
        },
        options: {
          maintainAspectRatio: false,
          plugins: { legend: { display: false } },
          scales: { y: { beginAtZero: true } }
        }
      });

      new Chart(courseCtx, {
        type: 'bar',
        data: {
          labels: [<%= topCourseLabels %>],
          datasets: [{
            label: 'Related minutes',
            data: [<%= topCourseMinutes %>],
            backgroundColor: '#9f171d'
          }]
        },
        options: {
          maintainAspectRatio: false,
          plugins: { legend: { display: false } },
          scales: { y: { beginAtZero: true } }
        }
      });

    })();
  </script>
  <% } %>
</body>
</html>
