<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html>
<head><title>Profile</title></head>
<body>
<h1>Your Profile</h1>

<p>Logged in as: <strong><%= session.getAttribute("userEmail") %></strong></p>

<p><a href="<%=request.getContextPath()%>/logout">Logout</a></p>
</body>
</html>
