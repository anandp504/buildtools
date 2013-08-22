<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Component List</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'/component/list')}">Home</a></span>
            <span class="menuButton"><g:link class="create" action="create">New Component</g:link></span>
            <span class="menuButton"><g:link class="show" action="displaylog">Build Log</g:link></span>
            <span class="menuButton"><modalbox:createLink url="popup.gsp" title="Message" width="400" linkname="Clean" />
            <%-- <span class="menuButton"><g:link class="show" action="clean">Clean</g:link></span> --%>
            <g:if test="${session.email}">
                <span class="menuButton"><g:link class="show" controller="user" action="logout">Logout</g:link></span>
            </g:if>           
            <g:else>
                <span class="menuButton"><g:link class="show" controller="user" action="login">Login</g:link></span>
            </g:else>
        </div>
        <div class="body">
            <h1>Component List</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                   	        <g:sortableColumn property="id" title="Id" />
                        
                   	        <g:sortableColumn property="component" title="Component" />
                        
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${componentList}" status="i" var="component">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${component.id}">${component.id?.encodeAsHTML()}</g:link></td>
                        
                            <td><g:link action="show" id="${component.id}">${component.component?.encodeAsHTML()}</g:link></td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${Component.count()}" />
            </div>
        </div>
    </body>
</html>
