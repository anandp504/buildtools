

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Create Build</title>         
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'/component/list')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list" params="[bid:branch.id]">Build List</g:link></span>
        </div>
        <div class="body">
            <h1>Create Build</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${build}">
            <div class="errors">
                <g:renderErrors bean="${build}" as="list" />
            </div>
            </g:hasErrors>
            <g:form action="save" method="post" enctype="multipart/form-data" >
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="branch">Component:</label>
                                </td>

                                <td valign="top" class="value ${hasErrors(bean:build,field:'branch','errors')}">
                                    <g:link controller="component" action="show" id="${branch?.component?.id}">
                                    <label for="branch">${branch.component.component}</label>
                                    </g:link>
                                </td>
                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="branch">Branch:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:build,field:'branch','errors')}">
                                    <g:link controller="branch" action="show" id="${branch?.id}">
                                    <label for="branch">${branch.name}</label>
                                    </g:link>
                                    <input type="hidden" id="branch.id" name="branch.id" value="${branch.id}"/>
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="release">Release:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:build,field:'release','errors')}">
                                    <input type="text" id="release" name="release" value="${fieldValue(bean:build,field:'release')}"/>
                                </td>
                            </tr> 

                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="base">Label:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:build,field:'base','errors')}">
                                    <input type="text" id="base" name="base" value="${fieldValue(bean:build,field:'base')}"/>
                                </td>
                            </tr> 

                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="tickets">Changelist(s):</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:build,field:'tickets','errors')}">
                                    <input type="text" id="tickets" name="tickets" value="${fieldValue(bean:build,field:'tickets')}"/>
                                </td>
                            </tr> 

                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="notes">Notes:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:build,field:'notes','errors')}">
                                    <g:textArea name="notes" value="${build.notes}" rows="5" cols="40"/>
                                   <%--  <input type="text" id="notes" name="notes" value="${fieldValue(bean:build,field:'notes')}"/> --%>
                                </td>
                            </tr> 
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="notes">Attach File to Email:</label>
                                </td>
                                <td valign="top">
                                   <input type="file" name="attachedfile"/> 
                                </td>
                            </tr> 
                        
                        </tbody>
                    </table>
                </div>
                <div class="buttons">
                    <span class="button"><input class="save" type="submit" value="Create" /></span>
                </div>
            </g:form>
        </div>
    </body>
</html>
