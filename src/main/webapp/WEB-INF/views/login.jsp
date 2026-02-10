<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html>
<head><title>Login</title></head>
<body>
<h1>Login</h1>

<%
  String reg = request.getParameter("registered");
  if ("1".equals(reg)) {
%>
<p style="color:green;">Account created! You can login now.</p>
<% } %>

<p style="color:red;"><%= request.getAttribute("error") == null ? "" : request.getAttribute("error") %></p>

<form method="post" action="<%=request.getContextPath()%>/login">
  <label>Email</label><br/>
  <input type="email" name="email" value="<%= request.getAttribute("email") == null ? "" : request.getAttribute("email") %>" required/><br/><br/>

  <label>Password</label><br/>
  <input type="password" name="password" required/><br/><br/>

  <button type="submit">Login</button>
</form>

<p><a href="<%=request.getContextPath()%>/home">Back</a></p>
</body>
</html>
