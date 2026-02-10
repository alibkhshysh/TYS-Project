<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html>
<head><title>Register</title></head>
<body>
<h1>Register</h1>

<p style="color:red;"><%= request.getAttribute("error") == null ? "" : request.getAttribute("error") %></p>

<form method="post" action="<%=request.getContextPath()%>/register">
  <label>Email</label><br/>
  <input type="email" name="email" value="<%= request.getAttribute("email") == null ? "" : request.getAttribute("email") %>" required/><br/><br/>

  <label>Password</label><br/>
  <input type="password" name="password" required/><br/><br/>

  <label>Confirm Password</label><br/>
  <input type="password" name="confirm" required/><br/><br/>

  <button type="submit">Create account</button>
</form>

<p><a href="<%=request.getContextPath()%>/home">Back</a></p>
</body>
</html>
