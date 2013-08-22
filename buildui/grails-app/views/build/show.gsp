

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Show Build</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'/component/list')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list" params="[bid: build.branch.id]">Build List</g:link></span>
        </div>
        <div class="body">
            <h1>Show Build</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:if test="${build?.released == true}">
                <g:set var="releasemsg" value="Released by:" />
            </g:if>
            <g:else>
                <g:set var="releasemsg" value="Built by:" />
            </g:else>
            <div class="dialog">
                <table>
                    <tbody>

                    
                        <tr class="prop">
                            <td valign="top" class="name">Id:</td>
                            
                            <td valign="top" class="value">${build.id}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name">Component:</td>

                            <td valign="top" class="value"><g:link controller="component" action="show" id="${build?.component?.id}">${build?.component}</g:link></td>

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
                            <td valign="top" class="name">${releasemsg}</td>
                            
                            <td valign="top" class="value">${build.user}</td>
                        </tr>

                        <tr class="prop">
                            <td valign="top" class="name">Notes:</td>
                            
                            <td valign="top" class="value"><pre>${build.notes.encodeAsHTML()}</pre></td>

                        </tr>
                    
                    </tbody>
                </table>
            </div>
            <div class="buttons">
                <g:form action="edit2release" method="post" >
                    <input type="hidden" name="id" value="${build?.id}" />
                    <span class="button"><g:actionSubmit class="delete" onclick="return confirm('Are you sure?');" value="Delete" /></span>
                    <span class="button"><input class="save" type="submit" value="Release" /></span>
                </g:form>
            </div>
        </div>
    </body>
</html>
