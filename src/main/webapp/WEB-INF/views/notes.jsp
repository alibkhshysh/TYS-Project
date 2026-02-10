<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Notes</title>
  <style>
    :root {
      --bg: #f9f9fb;
      --surface: #ffffff;
      --line: #e4d7d8;
      --accent: #9f171d;
      --accent-soft: #fcebec;
      --text: #232323;
      --muted: #6a595b;
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
      width: min(760px, 100%);
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

    .panel p {
      margin: 0 0 8px;
      color: var(--muted);
      line-height: 1.5;
    }

    .hint {
      margin-top: 12px;
      border: 1px dashed #ecd8da;
      border-radius: 10px;
      background: #fff8f8;
      padding: 10px 12px;
      color: #6d4f53;
      font-size: 0.93rem;
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
      color: #3f2d2f;
      background: #fff;
    }

    .btn:hover {
      background: var(--accent-soft);
      color: var(--accent);
    }
  </style>
</head>
<body>
  <header class="topbar">
    <h1>Notes</h1>
  </header>

  <main>
    <section class="panel">
      <h2>Personal study notes</h2>
      <p>This page is ready for your note features.</p>
      <p>You can connect this section to saved notes, tags, and quick references from your dashboard activities.</p>

      <div class="hint">
        Tip: a good next step is storing notes per course and date, then linking them directly from calendar activities.
      </div>

      <div class="actions">
        <a class="btn" href="<%= request.getContextPath() %>/dashboard">Back to Dashboard</a>
        <a class="btn" href="<%= request.getContextPath() %>/analysis">Go to Analysis</a>
      </div>
    </section>
  </main>
</body>
</html>
