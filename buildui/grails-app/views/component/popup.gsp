<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main" />
        <title>Popup</title>
    </head>
    <body>
        <div class="body" style="margin-left: 20px; margin-top: 20px; border: 1px solid #ccc; width:400px">
            <h1 style="background:#fff url(../images/skin/shadow.jpg) repeat-x">Information</h1>
            <hr/>
                <p style="text-align:justify">Clean will delete the entire build workspace. This means that the next build will require a P4 sync of the full workspace. This will increase the time it takes to complete the build and may not be necessary. </p> <p style="text-align:justify">When you invoke a new build, it will automatically clean out all project specific directories and refresh them from P4 before building. </p> <p>Please consider whether you really need to clean.</p>
            <div class="buttons" style="vertical-align:bottom">
                <span class="menuButton"><g:link class="show" controller="component" action="clean">Clean</g:link></span>
                <span class="menuButton"><g:link class="show" controller="component" action="list">Cancel</g:link></span>
            </div>
        </div>
    </body>
</html>
