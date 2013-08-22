

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Branch List</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'/component/list')}">Home</a></span>
            <!--span class="menuButton"><g:link class="create" action="create">New Branch</g:link></span-->
        </div>
        <div class="body">
            <h1>Branch List</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                   	        <g:sortableColumn property="id" title="Id" />
                        
                   	        <th>Component</th>
                   	    
                   	        <g:sortableColumn property="name" title="Name" />
                        
                   	        <g:sortableColumn property="path" title="Path" />
                        
                   	        <th>Builds</th>
                   	    
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${branchList}" status="i" var="branch">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${branch.id}">${branch.id?.encodeAsHTML()}</g:link></td>
                        
                            <td><g:link controller="component" action="show" id="${branch?.component?.id}">${branch.component?.encodeAsHTML()}</g:link></td>
                        
                            <td><g:link action="show" id="${branch.id}">${branch.name?.encodeAsHTML()}</g:link></td>
                        
                            <td>${branch.path?.encodeAsHTML()}</td>
                        
                            <td>${branch.builds?.encodeAsHTML()}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${Branch.count()}" />
            </div>
        </div>
    </body>
</html>
