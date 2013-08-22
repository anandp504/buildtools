

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Create Component</title>         
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'/component/list')}">Home</a></span>
        </div>
        <div class="body">
            <h1>Create Component</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${component}">
            <div class="errors">
                <g:renderErrors bean="${component}" as="list" />
            </div>
            </g:hasErrors>
            <g:form action="save" method="post" >
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="component">Component:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:component,field:'component','errors')}">
                                    <input type="text" id="component" name="component" value="${fieldValue(bean:component,field:'component')}"/>
                                </td>
                            </tr> 
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="component">Main Branch:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:branch,field:'path','errors')}">
                                    <input type="text" id="mainBranch" name="mainBranch" value="//depot/"/>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <g:render template="component" var="component" bean="${component}"/>
                <div class="buttons">
                    <span class="button"><input class="save" type="submit" value="Create" /></span>
                </div>
            </g:form>
        </div>
    </body>
</html>
