
<div class="dialog">
    <h1> Configure override values for this branch </h1>
    <table>
        <tbody>
            <tr class="prop">
                <td valign="top" class="name">
                    <label for="component">Dev Build Directory:</label>
                </td>
                <td valign="top" class="value ${hasErrors(bean:branch,field:'devbuilddir','errors')}">
                    <input type="text" id="devbuilddir" name="devbuilddir" value="${fieldValue(bean:branch,field:'devbuilddir')}"/>
                </td>
            </tr> 
            <tr class="prop">
                <td valign="top" class="name">
                    <label for="component">Stage Directory:</label>
                </td>
                <td valign="top" class="value ${hasErrors(bean:branch,field:'stagedir','errors')}">
                    <input type="text" id="stagedir" name="stagedir" value="${fieldValue(bean:branch,field:'stagedir')}"/>
                </td>
            </tr> 
            <tr class="prop">
                <td valign="top" class="name">
                    <label for="component">Release Directory:</label>
                </td>
                <td valign="top" class="value ${hasErrors(bean:branch,field:'releasedir','errors')}">
                    <input type="text" id="releasedir" name="releasedir" value="${fieldValue(bean:branch,field:'releasedir')}"/>
                </td>
            </tr> 
        </tbody>
    </table>
</div>
