

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Build List</title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLinkTo(dir:'/component/list')}">Home</a></span>
        </div>
        <div class="body">
            <h1>Build List</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                   	        <g:sortableColumn property="id" title="Id" params="[bid: branch]"/>
                        
                   	        <th>Component</th>

                   	        <th>Branch</th>

                   	        <g:sortableColumn property="release" title="Release" params="[bid: branch]"/>
                        
                   	        <g:sortableColumn property="date" title="Date" params="[bid: branch]"/>
                        
                   	        <g:sortableColumn property="base" title="Label" params="[bid: branch]"/>
                        
                   	        <g:sortableColumn property="tickets" title="Changelist(s)" params="[bid: branch]"/>

                   	        <g:sortableColumn property="user" title="By" params="[bid: branch]"/>

                   	        <g:sortableColumn property="released" title="Released?" params="[bid: branch]"/>
                        
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${buildList}" status="i" var="build">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${build.id}">${build.id?.encodeAsHTML()}</g:link></td>

                            <td><g:link controller="component" action="show" id="${build?.component?.id}">${build.component?.encodeAsHTML()}</g:link></td>

                            <td><g:link controller="branch" action="show" id="${build?.branch?.id}">${build.branch?.encodeAsHTML()}</g:link></td>

                            <td>${build.release?.encodeAsHTML()}</td>
                        
                            <td>${build.date?.encodeAsHTML()}</td>
                        
                            <td>${build.base?.encodeAsHTML()}</td>

                            <td>${build.tickets?.encodeAsHTML()}</td>

                            <td>${build.user?.encodeAsHTML()}</td>

                            <td>${(build.released == true ? "Yes" : "No").encodeAsHTML()}</td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <% def b = Branch.get(branch);
               def c = Build.countByBranch(b); %>
            <div class="paginateButtons">
                <g:paginate params="[bid: branch]" total="$c" /> 
            </div>
        </div>
    </body>
</html>
