<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>TYS - Track Your Study</title>

    <style>
        body { margin: 0; font-family: Arial, sans-serif; }
        main {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
            text-align: center;
        }
        .card {
            max-width: 520px;
            width: 100%;
            padding: 28px;
            border: 1px solid #ddd;
            border-radius: 12px;
        }
        .actions { margin-top: 18px; display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; }
        .btn {
            display: inline-block;
            padding: 10px 16px;
            border-radius: 10px;
            border: 1px solid #222;
            text-decoration: none;
            color: #222;
            font-weight: 600;
        }
    </style>
</head>
<body>

<main>
    <section class="card" aria-labelledby="title">
        <h1 id="title">Track Your Study</h1>
        <p>
            Track your schedule, build discipline, and achieve more - one day at a time.
        </p>

        <div class="actions">
            <a class="btn" href="<%= request.getContextPath() %>/login">Login</a>
            <a class="btn" href="<%= request.getContextPath() %>/register">Register</a>
        </div>
    </section>
</main>

</body>
</html>
