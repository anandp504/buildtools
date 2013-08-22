<div class="dialog">
 <h1>Configure Component</h1>
 <table>
     <tbody>
         <tr class="prop">
             <td valign="top" class="name">
                 <label for="component">Component Type</label>
             </td>
             <td valign="top" class="value ${hasErrors(bean:component,field:'type','errors')}">
                 <input type="text" id="type" name="type" value="${fieldValue(bean:component,field:'type')}"/>
             </td>
         </tr>
         <tr class="prop">
             <td valign="top" class="name">
                 <label for="component">Version File:</label>
             </td>
             <td valign="top" class="value ${hasErrors(bean:component,field:'versionfile','errors')}">
                 <input type="text" id="versionfile" name="versionfile" value="${fieldValue(bean:component,field:'versionfile')}"/>
             </td>
         </tr>
         <tr class="prop">
             <td valign="top" class="name">
                 <label for="component">Build Directory:</label>
             </td>
             <td valign="top" class="value ${hasErrors(bean:component,field:'builddir','errors')}">
                 <input type="text" id="builddir" name="builddir" value="${fieldValue(bean:component,field:'builddir')}"/>
             </td>
         </tr>
         <tr class="prop">
             <td valign="top" class="name">
                 <label for="component">Install Directory:</label>
             </td>
             <td valign="top" class="value ${hasErrors(bean:component,field:'installdir','errors')}">
                 <input type="text" id="installdir" name="installdir" value="${fieldValue(bean:component,field:'installdir')}"/>
             </td>
         </tr>
         <tr class="prop">
             <td valign="top" class="name">
                 <label for="component">BuildTools Directory:</label>
             </td>
             <td valign="top" class="value ${hasErrors(bean:component,field:'buildtoolsdir','errors')}">
                 <input type="text" id="buildtoolsdir" name="buildtoolsdir" value="${fieldValue(bean:component,field:'buildtoolsdir')}"/>
             </td>
         </tr>
         <tr class="prop">
             <td valign="top" class="name">
                 <label for="component">Ext Lib Directory:</label>
             </td>
             <td valign="top" class="value ${hasErrors(bean:component,field:'libdir','errors')}">
                 <input type="text" id="libdir" name="libdir" value="${fieldValue(bean:component,field:'libdir')}"/>
             </td>
         </tr>
         <tr class="prop">
             <td valign="top" class="name">
                 <label for="component">Project Directories:<br/>(comma separated)</label>
             </td>
             <td valign="top" class="value ${hasErrors(bean:component,field:'projectdirs','errors')}">
                 <input type="text" id="projectdirs" name="projectdirs" value="${fieldValue(bean:component,field:'projectdirs')}"/>
             </td>
         </tr>
         <tr class="prop">
             <td valign="top" class="name">
                 <label for="component">Staging Directory:</label>
             </td>
             <td valign="top" class="value ${hasErrors(bean:component,field:'stagedir','errors')}">
                 <input type="text" id="stagedir" name="stagedir" value="${fieldValue(bean:component,field:'stagedir')}"/>
             </td>
         </tr>
         <tr class="prop">
             <td valign="top" class="name">
                 <label for="component">Development Build Directory:</label>
             </td>
             <td valign="top" class="value ${hasErrors(bean:component,field:'devbuilddir','errors')}">
                 <input type="text" id="devbuilddir" name="devbuilddir" value="${fieldValue(bean:component,field:'devbuilddir')}"/>
             </td>
         </tr>
         <tr class="prop">
             <td valign="top" class="name">
                 <label for="component">Release Directory:</label>
             </td>
             <td valign="top" class="value ${hasErrors(bean:component,field:'releasedir','errors')}">
                 <input type="text" id="releasedir" name="releasedir" value="${fieldValue(bean:component,field:'releasedir')}"/>
             </td>
         </tr>
         <tr class="prop">
             <td valign="top" class="name">
                 <label for="component">Mailing List: <br/>(comma separated)</label>
             </td>
             <td valign="top" class="value ${hasErrors(bean:component,field:'mailto','errors')}">
                 <input type="text" id="mailto" name="mailto" value="${fieldValue(bean:component,field:'mailto')}"/>
             </td>
         </tr>

     </tbody>
 </table>
</div>
