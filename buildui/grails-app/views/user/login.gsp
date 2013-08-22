
<html>
   <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
      <meta name="layout" content="main" />
      <title>User Login</title>
   </head>
   <body>
      <div class="body" style="padding:5px">
         <g:form method="post">
         <div class="dialog">
            <h1>Please login</h1>  
            <table class="userForm">
                <tr class='prop'>
                    <td valign='top' style='text-align:left;' width='8%'>
                        <label for='email'>UserName:</label>
                    </td>
                    <td valign='top' style='text-align:left;' width='80%'>
                        <input id="username" type='text' name='username' value='${user?.username}' />
                    </td>
                </tr>
                <tr class='prop'>
                    <td valign='top' style='text-align:left;' width='8%'>
                        <label for='password'>Password:</label>
                    </td>
                    <td valign='top' style='text-align:left;' width='80%'>
                        <input id="password" type='password' name='password' value='${user?.password}' />
                    </td>
                </tr>
            </table>
         </div>
         <div class="buttons">
            <%-- <span class="formButton">
                <input type="submit" value="Login"></input>
            </span> --%>
            <span class="formbutton"><g:actionSubmit value="Login" action="doLogin"/></span>
            <%-- span class="formbutton"><g:actionSubmit value="New User" action="Create"/></span --%>
         </div>
         </g:form>
         <br/><br/>
	  <b><g:message code="${flash.message}"/></b>
      </div>
   </body>
</html>
