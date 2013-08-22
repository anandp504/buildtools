

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Edit Branch</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'/component/list')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">Branch List</g:link></span>
        </div>
        <div class="body">
            <h1>Edit Branch</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${branch}">
            <div class="errors">
                <g:renderErrors bean="${branch}" as="list" />
            </div>
            </g:hasErrors>
            <g:form method="post" >
                <input type="hidden" name="id" value="${branch?.id}" />
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="component">Component:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:branch,field:'component','errors')}">
                                    <g:link controller="component" action="show" id="${branch?.component?.id}">
                                    <label>${branch.component.component}</label>
                                    </g:link>
                                    <input type="hidden" id="component.id" name="component.id" value="${branch.component.id}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="name">Name:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:branch,field:'name','errors')}">
                                    <input type="text" id="name" name="name" value="${fieldValue(bean:branch,field:'name')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="path">Path:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:branch,field:'path','errors')}">
                                    <input type="text" id="path" name="path" value="${fieldValue(bean:branch,field:'path')}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="builds">Builds:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:branch,field:'builds','errors')}">
                                    
<ul>
<g:each var="b" in="${branch?.builds?}">
    <li><g:link controller="build" action="show" id="${b.id}">${b}</g:link></li>
</g:each>
</ul>

                                </td>
                            </tr> 
                        
                        </tbody>
                    </table>
                </div>
                <g:render template="branch" var="branch" bean="${branch}"/>
                <div class="buttons">
                    <span class="button"><g:actionSubmit class="save" value="Update" /></span>
                    <span class="button"><g:actionSubmit class="delete" onclick="return confirm('Are you sure?');" value="Delete" /></span>
                </div>
            </g:form>
        </div>
    </body>
</html>
