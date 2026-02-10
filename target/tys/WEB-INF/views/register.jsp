<%@ page contentType="text/html;charset=UTF-8" %>
<%!
  private String esc(String s) {
    if (s == null) return "";
    return s.replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
  }
%>
<%
  String error = request.getAttribute("error") == null ? "" : String.valueOf(request.getAttribute("error"));
  String firstName = request.getAttribute("firstName") == null ? "" : String.valueOf(request.getAttribute("firstName"));
  String lastName = request.getAttribute("lastName") == null ? "" : String.valueOf(request.getAttribute("lastName"));
  String birthDate = request.getAttribute("birthDate") == null ? "" : String.valueOf(request.getAttribute("birthDate"));
  String major = request.getAttribute("major") == null ? "" : String.valueOf(request.getAttribute("major"));
  String department = request.getAttribute("department") == null ? "" : String.valueOf(request.getAttribute("department"));
  String university = request.getAttribute("university") == null ? "" : String.valueOf(request.getAttribute("university"));
  String email = request.getAttribute("email") == null ? "" : String.valueOf(request.getAttribute("email"));
  String lvl = request.getAttribute("degreeLevel") == null ? "" : String.valueOf(request.getAttribute("degreeLevel"));
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Register</title>
  <style>
    @import url("https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap");

    :root {
      --surface: rgba(255, 255, 255, 0.95);
      --line: rgba(230, 200, 203, 0.92);
      --accent: #9f171d;
      --accent-dark: #7d1015;
      --accent-soft: #fdecee;
      --text: #232323;
      --err: #a01616;
      --err-bg: #fdecec;
      --err-line: #f6b6b6;
    }

    * { box-sizing: border-box; }

    body {
      margin: 0;
      min-height: 100vh;
      color: var(--text);
      font-family: "Poppins", "Segoe UI", sans-serif;
      background-image:
        linear-gradient(120deg, rgba(255, 255, 255, 0.18) 0%, rgba(126, 15, 21, 0.52) 100%),
        url("<%= request.getContextPath() %>/assets/register.png");
      background-size: cover;
      background-position: center;
      background-repeat: no-repeat;
    }

    .topbar {
      background: rgba(255, 255, 255, 0.86);
      border-bottom: 1px solid rgba(227, 198, 202, 0.9);
      padding: 16px 24px;
      backdrop-filter: blur(3px);
    }

    .topbar h1 {
      margin: 0;
      color: var(--accent);
      font-size: 1.9rem;
      font-weight: 800;
      letter-spacing: 0.2px;
    }

    main {
      padding: 20px;
      display: grid;
      place-items: center;
    }

    .panel {
      width: min(940px, 100%);
      background: var(--surface);
      border: 1px solid var(--line);
      border-radius: 16px;
      padding: 20px;
      box-shadow: 0 24px 56px rgba(31, 11, 13, 0.32);
      backdrop-filter: blur(3px);
    }

    .tag {
      margin: 0;
      color: var(--accent);
      font-size: 0.76rem;
      font-weight: 800;
      letter-spacing: 0.55px;
      text-transform: uppercase;
    }

    .panel h2 {
      margin: 6px 0 8px;
      color: #631922;
      font-size: 1.5rem;
      font-weight: 800;
    }

    .sub {
      margin: 0 0 12px;
      color: #5a4a4d;
      font-size: 0.92rem;
      line-height: 1.5;
    }

    .flash-err {
      color: var(--err);
      background: var(--err-bg);
      border: 1px solid var(--err-line);
      border-radius: 10px;
      padding: 10px 12px;
      margin-bottom: 12px;
      font-weight: 600;
      font-size: 0.9rem;
    }

    .section-title {
      margin: 14px 0 10px;
      color: #7a2630;
      font-size: 0.88rem;
      text-transform: uppercase;
      letter-spacing: 0.45px;
      font-weight: 800;
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

    .field.wide {
      grid-column: 1 / -1;
    }

    .field label {
      font-size: 0.86rem;
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
      transition: transform 120ms ease, background-color 120ms ease;
    }

    .btn:hover { transform: translateY(-1px); }

    .btn-primary {
      border-color: var(--accent);
      background: var(--accent);
      color: #fff;
    }

    .btn-primary:hover { background: var(--accent-dark); }

    .btn-secondary {
      background: #fff;
      color: #3f2d2f;
    }

    .btn-secondary:hover {
      background: var(--accent-soft);
      color: var(--accent);
    }

    .helper {
      margin-top: 14px;
      font-size: 0.9rem;
      color: #6a5a5c;
    }

    .helper a {
      color: var(--accent);
      font-weight: 700;
      text-decoration: none;
    }

    @media (max-width: 900px) {
      .panel { padding: 18px; }
    }

    @media (max-width: 760px) {
      .form-grid { grid-template-columns: 1fr; }
      main { padding: 16px; }
    }
  </style>
</head>
<body>
  <header class="topbar">
    <h1>Register</h1>
  </header>

  <main>
    <section class="panel">
      <p class="tag">Track Your Study</p>
      <h2>Create your account</h2>
      <p class="sub">Set up your study profile once and use your dashboard to manage daily progress.</p>

      <% if (!error.isBlank()) { %>
      <div class="flash-err"><%= esc(error) %></div>
      <% } %>

      <form method="post" action="<%=request.getContextPath()%>/register">
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
              <option value="" <%= lvl.isEmpty() ? "selected" : "" %>>Select...</option>
              <option value="Bachelor" <%= "Bachelor".equals(lvl) ? "selected" : "" %>>Bachelor</option>
              <option value="Master" <%= "Master".equals(lvl) ? "selected" : "" %>>Master</option>
              <option value="PhD" <%= "PhD".equals(lvl) ? "selected" : "" %>>PhD</option>
              <option value="Other" <%= "Other".equals(lvl) ? "selected" : "" %>>Other</option>
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

          <div class="field">
            <label for="password">Password</label>
            <input id="password" type="password" name="password" minlength="8" required />
          </div>

          <div class="field wide">
            <label for="confirm">Confirm Password</label>
            <input id="confirm" type="password" name="confirm" minlength="8" required />
          </div>
        </div>

        <div class="actions">
          <button type="submit" class="btn btn-primary">Create Account</button>
          <a class="btn btn-secondary" href="<%=request.getContextPath()%>/home">Back to Home</a>
        </div>
      </form>

      <p class="helper">
        Already have an account? <a href="<%=request.getContextPath()%>/login">Login</a>
      </p>
    </section>
  </main>
</body>
</html>
