

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Release Build</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'/component/list')}">Home</a></span>
        </div>
        <div class="body">
            <h1>Release Build</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${build}">
            <div class="errors">
                <g:renderErrors bean="${build}" as="list" />
            </div>
            </g:hasErrors>
            <g:form action="release" method="post" enctype="multipart/form-data">
                <input type="hidden" name="id" value="${build?.id}" />
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">Id:</td>
                                <td valign="top" class="value">${build.id}</td>
                            </tr>
                    
                            <tr class="prop">
                                <td valign="top" class="name">Component:</td>
                                <td valign="top" class="value">
                                    <g:link controller="component" action="show" id="${build?.component?.id}">${build?.component?.component}</g:link></td>
                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">Branch:</td>
                                <td valign="top" class="value"><g:link controller="branch" action="show" id="${build?.branch?.id}">${build?.branch}</g:link></td>
                            
                            </tr>
                    
                            <tr class="prop">
                                <td valign="top" class="name">Release:</td>
                                <td valign="top" class="value"><a href="${build.stagingUrl}">${build.release}</a></td>
                            </tr>
                    
                            <tr class="prop">
                                <td valign="top" class="name">Date:</td>
                                <td valign="top" class="value">${build.date}</td>
                            </tr>
                    
                            <tr class="prop">
                                <td valign="top" class="name">Label:</td>
                                <td valign="top" class="value">${build.base}</td>
                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">Changelist(s):</td>
                                <td valign="top" class="value">${build.tickets}</td>
                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="notes">Notes:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:build,field:'notes','errors')}">
                                    <g:textArea name="notes" value="${build.notes}" rows="5" cols="40"/> 
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
                    <span class="button"><input class="save" type="submit" value="Release" /></span>
                </div>
            </g:form>
        </div>
    </body>
</html>
