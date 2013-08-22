

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Edit Component</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'/component/list')}">Home</a></span>
        </div>
        <div class="body">
            <h1>Edit Component</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${component}">
            <div class="errors">
                <g:renderErrors bean="${component}" as="list" />
            </div>
            </g:hasErrors>
            <g:form method="post" >
                <input type="hidden" name="id" value="${component?.id}" />
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
                                    <label for="branches">Branches:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:component,field:'branches','errors')}">
                                    
<ul>
<g:each var="b" in="${component?.branches?}">
    <li><g:link controller="branch" action="show" id="${b.id}">${b}</g:link></li>
</g:each>
</ul>
<!-- <g:link controller="branch" params="["component.id":component?.id]" action="create">Add Branch</g:link> -->

                                </td>
                            </tr> 
                        
                        </tbody>
                    </table>
                </div>
                <g:render template="component" var="component" bean="${component}"/>
                <div class="buttons">
                    <span class="button"><g:actionSubmit class="save" value="Update" /></span>
                    <span class="button"><g:actionSubmit class="delete" onclick="return confirm('Are you sure?');" value="Delete" /></span>
                </div>
            </g:form>
        </div>
    </body>
</html>
