

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Edit Build</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'/component/list')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list">Build List</g:link></span>
            <span class="menuButton"><g:link class="create" action="create">New Build</g:link></span>
        </div>
        <div class="body">
            <h1>Edit Build</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${build}">
            <div class="errors">
                <g:renderErrors bean="${build}" as="list" />
            </div>
            </g:hasErrors>
            <g:form method="post" >
                <input type="hidden" name="id" value="${build?.id}" />
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="branch">Branch:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:build,field:'branch','errors')}">
                                    <g:select optionKey="id" from="${Branch.list()}" name="branch.id" value="${build?.branch?.id}" ></g:select>
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
                                    <label for="date">Date:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:build,field:'date','errors')}">
                                    <g:datePicker name="date" value="${build?.date}" ></g:datePicker>
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
                        
                        
                        </tbody>
                    </table>
                </div>
                <div class="buttons">
                    <span class="button"><g:actionSubmit class="save" value="Update" /></span>
                    <span class="button"><g:actionSubmit class="delete" onclick="return confirm('Are you sure?');" value="Delete" /></span>
                </div>
            </g:form>
        </div>
    </body>
</html>
