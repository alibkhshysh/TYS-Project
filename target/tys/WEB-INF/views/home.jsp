<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>TYS - Home</title>

    <style>
        @import url("https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap");

        :root {
            --accent: #a0151c;
            --accent-dark: #7f1016;
            --surface: rgba(255, 255, 255, 0.93);
            --text: #1f1f1f;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: "Poppins", "Segoe UI", sans-serif;
            color: var(--text);
            background-image:
                linear-gradient(110deg, rgba(255, 255, 255, 0.16) 0%, rgba(160, 21, 28, 0.62) 100%),
                url("<%= request.getContextPath() %>/assets/homepage.png");
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
        }

        main {
            min-height: 100vh;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            padding: 28px 6vw;
        }

        .card {
            width: min(640px, 100%);
            padding: 34px 36px;
            border: 1px solid rgba(160, 21, 28, 0.28);
            border-radius: 18px;
            background: var(--surface);
            box-shadow: 0 20px 55px rgba(53, 16, 18, 0.34);
            backdrop-filter: blur(2px);
        }

        .tag {
            margin: 0 0 10px;
            color: var(--accent);
            font-weight: 700;
            letter-spacing: 0.7px;
            text-transform: uppercase;
            font-size: 0.84rem;
        }

        h1 {
            margin: 0;
            font-size: clamp(1.8rem, 4vw, 2.9rem);
            line-height: 1.15;
            font-weight: 800;
            color: #151515;
        }

        .subtitle {
            margin: 16px 0 0;
            font-size: clamp(1rem, 2vw, 1.15rem);
            line-height: 1.6;
            color: #333;
            max-width: 52ch;
        }

        .actions {
            margin-top: 28px;
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .btn {
            display: inline-block;
            min-width: 148px;
            text-align: center;
            padding: 12px 18px;
            border-radius: 12px;
            border: 2px solid transparent;
            text-decoration: none;
            font-weight: 700;
            letter-spacing: 0.2px;
            transition: transform 120ms ease, box-shadow 120ms ease, background-color 120ms ease;
        }

        .btn:hover {
            transform: translateY(-1px);
        }

        .btn-primary {
            background: var(--accent);
            color: #fff;
            border-color: var(--accent);
            box-shadow: 0 8px 20px rgba(160, 21, 28, 0.28);
        }

        .btn-primary:hover {
            background: var(--accent-dark);
            border-color: var(--accent-dark);
        }

        .btn-secondary {
            background: #fff;
            color: var(--accent);
            border-color: var(--accent);
        }

        .btn-secondary:hover {
            background: #ffe9eb;
        }

        @media (max-width: 820px) {
            main {
                justify-content: center;
                padding: 18px;
            }
            .card {
                padding: 24px 20px;
            }
        }
    </style>
</head>
<body>

<main>
    <section class="card" aria-labelledby="title">
        <p class="tag">Track Your Study</p>
        <h1 id="title">Plan your day, achieve your goals.</h1>
        <p class="subtitle">(Empowering students and professors to stay organized and productive)</p>

        <div class="actions">
            <a class="btn btn-primary" href="<%= request.getContextPath() %>/register">Register</a>
            <a class="btn btn-secondary" href="<%= request.getContextPath() %>/login">Login</a>
        </div>
    </section>
</main>

</body>
</html>
