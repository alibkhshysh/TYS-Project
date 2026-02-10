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
  String reg = request.getParameter("registered");
  String error = (request.getAttribute("error") == null) ? "" : String.valueOf(request.getAttribute("error"));
  String email = (request.getAttribute("email") == null) ? "" : String.valueOf(request.getAttribute("email"));
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Login</title>
  <style>
    @import url("https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap");

    :root {
      --surface: rgba(255, 255, 255, 0.94);
      --line: rgba(227, 198, 202, 0.85);
      --accent: #9f171d;
      --accent-dark: #7d1015;
      --accent-soft: #fdecee;
      --text: #212121;
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
      min-height: 100vh;
      color: var(--text);
      font-family: "Poppins", "Segoe UI", sans-serif;
      background-image:
        linear-gradient(115deg, rgba(255, 255, 255, 0.18) 0%, rgba(126, 15, 21, 0.58) 100%),
        url("<%= request.getContextPath() %>/assets/login.png");
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
      min-height: calc(100vh - 78px);
      display: flex;
      justify-content: flex-end;
      align-items: center;
      padding: 22px 5vw;
    }

    .panel {
      width: min(560px, 100%);
      background: var(--surface);
      border: 1px solid var(--line);
      border-radius: 16px;
      padding: 22px;
      box-shadow: 0 24px 56px rgba(33, 12, 15, 0.32);
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
      margin: 0 0 14px;
      color: #5a4a4d;
      font-size: 0.92rem;
      line-height: 1.5;
    }

    .flash {
      border-radius: 10px;
      padding: 10px 12px;
      margin-bottom: 12px;
      font-weight: 600;
      border: 1px solid transparent;
      font-size: 0.9rem;
    }

    .flash-ok {
      color: var(--ok);
      background: var(--ok-bg);
      border-color: var(--ok-line);
    }

    .flash-err {
      color: var(--err);
      background: var(--err-bg);
      border-color: var(--err-line);
    }

    .field {
      margin-bottom: 12px;
      display: grid;
      gap: 6px;
    }

    .field label {
      font-size: 0.88rem;
      font-weight: 700;
      color: #5f2b31;
    }

    .field input {
      width: 100%;
      border: 1px solid #e6d8d9;
      border-radius: 9px;
      padding: 10px 11px;
      font: inherit;
      background: #fff;
    }

    .actions {
      margin-top: 10px;
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
      main {
        justify-content: center;
        padding: 18px;
      }
      .panel { padding: 18px; }
    }
  </style>
</head>
<body>
  <header class="topbar">
    <h1>Login</h1>
  </header>

  <main>
    <section class="panel">
      <p class="tag">Track Your Study</p>
      <h2>Welcome back</h2>
      <p class="sub">Continue from where you stopped and stay consistent with your study goals.</p>

      <% if ("1".equals(reg)) { %>
      <div class="flash flash-ok">Account created. You can log in now.</div>
      <% } %>

      <% if (!error.isBlank()) { %>
      <div class="flash flash-err"><%= esc(error) %></div>
      <% } %>

      <form method="post" action="<%=request.getContextPath()%>/login">
        <div class="field">
          <label for="email">Email</label>
          <input id="email" type="email" name="email" value="<%= esc(email) %>" required />
        </div>

        <div class="field">
          <label for="password">Password</label>
          <input id="password" type="password" name="password" required />
        </div>

        <div class="actions">
          <button type="submit" class="btn btn-primary">Login</button>
          <a class="btn btn-secondary" href="<%=request.getContextPath()%>/home">Back to Home</a>
        </div>
      </form>

      <p class="helper">
        No account yet? <a href="<%=request.getContextPath()%>/register">Create one</a>
      </p>
    </section>
  </main>
</body>
</html>
