<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="it.unipd.tys.model.User" %>
<%!
  private String esc(String s) {
    if (s == null) return "";
    return s.replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
  }

  private String val(Object requestValue, String fallback) {
    if (requestValue != null) return String.valueOf(requestValue);
    return fallback == null ? "" : fallback;
  }
%>
<%
  User u = (User) request.getAttribute("user");
  String error = (String) request.getAttribute("error");
  String success = (String) request.getAttribute("success");

  String firstName = val(request.getAttribute("firstName"), u == null ? "" : u.getFirstName());
  String lastName = val(request.getAttribute("lastName"), u == null ? "" : u.getLastName());
  String birthDate = val(request.getAttribute("birthDate"), (u == null || u.getBirthDate() == null) ? "" : u.getBirthDate().toString());
  String degreeLevel = val(request.getAttribute("degreeLevel"), u == null ? "" : u.getDegreeLevel());
  String major = val(request.getAttribute("major"), u == null ? "" : u.getMajor());
  String department = val(request.getAttribute("department"), u == null ? "" : u.getDepartment());
  String university = val(request.getAttribute("university"), u == null ? "" : u.getUniversity());
  String email = val(request.getAttribute("email"), u == null ? "" : u.getEmail());
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>My Profile</title>
  <style>
    :root {
      --bg: #f9f9fb;
      --surface: #ffffff;
      --line: #e4d7d8;
      --accent: #9f171d;
      --accent-soft: #fcebec;
      --text: #232323;
      --ok: #137a41;
      --ok-bg: #eaf9f0;
      --ok-line: #a8e3be;
      --err: #a01616;
      --err-bg: #fdecec;
      --err-line: #f6b6b6;
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

    main {
      padding: 18px;
      display: grid;
      place-items: center;
    }

    .panel {
      width: min(920px, 100%);
      background: var(--surface);
      border: 1px solid var(--line);
      border-radius: 14px;
      padding: 18px;
    }

    .panel h2 {
      margin: 0 0 10px;
      color: #6d1f27;
      font-size: 1.2rem;
    }

    .notice {
      margin-bottom: 10px;
      padding: 10px 12px;
      border-radius: 10px;
      border: 1px solid transparent;
      font-weight: 600;
      font-size: 0.92rem;
    }

    .notice-ok {
      color: var(--ok);
      background: var(--ok-bg);
      border-color: var(--ok-line);
    }

    .notice-err {
      color: var(--err);
      background: var(--err-bg);
      border-color: var(--err-line);
    }

    .empty {
      border: 1px solid #ecd8da;
      background: #fff8f8;
      border-radius: 10px;
      padding: 12px;
      color: #5d4f51;
      margin-bottom: 10px;
    }

    .section-title {
      margin: 14px 0 10px;
      color: #7a2630;
      font-size: 0.95rem;
      text-transform: uppercase;
      letter-spacing: 0.35px;
    }

    .form-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 10px;
    }

    .field {
      display: grid;
      gap: 6px;
    }

    .field label {
      font-size: 0.88rem;
      font-weight: 700;
      color: #5f2b31;
    }

    .field input,
    .field select {
      width: 100%;
      border: 1px solid #e6d8d9;
      border-radius: 9px;
      padding: 10px 11px;
      font: inherit;
      background: #fff;
    }

    .actions {
      margin-top: 14px;
      display: flex;
      gap: 10px;
      flex-wrap: wrap;
    }

    .btn {
      border: 1px solid #d7c6c8;
      border-radius: 10px;
      padding: 9px 14px;
      text-decoration: none;
      font-weight: 700;
      cursor: pointer;
      font: inherit;
    }

    .btn-primary {
      border-color: var(--accent);
      background: var(--accent);
      color: #fff;
    }

    .btn-primary:hover { background: #7f1016; }

    .btn-secondary {
      background: #fff;
      color: #3f2d2f;
    }

    .btn-secondary:hover {
      background: var(--accent-soft);
      color: var(--accent);
    }

    @media (max-width: 760px) {
      .form-grid { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>
  <header class="topbar">
    <h1>My Profile</h1>
  </header>

  <main>
    <section class="panel">
      <h2>Update your information</h2>

      <% if (success != null && !success.isBlank()) { %>
      <div class="notice notice-ok"><%= esc(success) %></div>
      <% } %>
      <% if (error != null && !error.isBlank()) { %>
      <div class="notice notice-err"><%= esc(error) %></div>
      <% } %>

      <% if (u == null) { %>
      <div class="empty">Profile data is not available.</div>
      <div class="actions">
        <a class="btn btn-secondary" href="<%=request.getContextPath()%>/dashboard">Back to Dashboard</a>
      </div>
      <% } else { %>
      <form method="post" action="<%=request.getContextPath()%>/profile">
        <h3 class="section-title">Personal Information</h3>
        <div class="form-grid">
          <div class="field">
            <label for="firstName">First Name</label>
            <input id="firstName" type="text" name="firstName" maxlength="100" required
                   value="<%= esc(firstName) %>" />
          </div>

          <div class="field">
            <label for="lastName">Surname (Last Name)</label>
            <input id="lastName" type="text" name="lastName" maxlength="100" required
                   value="<%= esc(lastName) %>" />
          </div>

          <div class="field">
            <label for="birthDate">Birth Date</label>
            <input id="birthDate" type="date" name="birthDate" required
                   value="<%= esc(birthDate) %>" />
          </div>
        </div>

        <h3 class="section-title">Study Information</h3>
        <div class="form-grid">
          <div class="field">
            <label for="degreeLevel">Degree Level</label>
            <select id="degreeLevel" name="degreeLevel" required>
              <option value="" <%= degreeLevel.isEmpty() ? "selected" : "" %>>Select...</option>
              <option value="Bachelor" <%= "Bachelor".equals(degreeLevel) ? "selected" : "" %>>Bachelor</option>
              <option value="Master" <%= "Master".equals(degreeLevel) ? "selected" : "" %>>Master</option>
              <option value="PhD" <%= "PhD".equals(degreeLevel) ? "selected" : "" %>>PhD</option>
              <option value="Other" <%= "Other".equals(degreeLevel) ? "selected" : "" %>>Other</option>
            </select>
          </div>

          <div class="field">
            <label for="major">Major / Field of Study</label>
            <input id="major" type="text" name="major" maxlength="150" required
                   value="<%= esc(major) %>" />
          </div>

          <div class="field">
            <label for="department">Department</label>
            <input id="department" type="text" name="department" maxlength="150" required
                   value="<%= esc(department) %>" />
          </div>

          <div class="field">
            <label for="university">University / School</label>
            <input id="university" type="text" name="university" maxlength="200" required
                   value="<%= esc(university) %>" />
          </div>
        </div>

        <h3 class="section-title">Account Information</h3>
        <div class="form-grid">
          <div class="field">
            <label for="email">Email</label>
            <input id="email" type="email" name="email" maxlength="255" required
                   value="<%= esc(email) %>" />
          </div>
        </div>

        <div class="actions">
          <button type="submit" class="btn btn-primary">Save Changes</button>
          <a class="btn btn-secondary" href="<%=request.getContextPath()%>/dashboard">Back to Dashboard</a>
          <a class="btn btn-secondary" href="<%=request.getContextPath()%>/analysis">Go to Analysis</a>
        </div>
      </form>
      <% } %>
    </section>
  </main>
</body>
</html>
