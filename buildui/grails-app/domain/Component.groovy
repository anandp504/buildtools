class Component {
    String component;
    String versionfile;
    String builddir;
    String installdir;
    String buildtoolsdir;
    String libdir;
    String projectdirs;
    String stagedir = "";
    String devbuilddir = "";
    String releasedir = "";
    String mailto;
    String type;

    static hasMany = [ branches : Branch ];

    static optionals = ['projectdirs', 'libdir', 'mailto']

    public String toString() {
      return component;
    }

    static constraints = {
       component(unique:true);
       component(blank:false);
       type(validator: { val, obj ->
          if ((val.equalsIgnoreCase("application")) || 
              (val.equalsIgnoreCase("library")) )
             return true;
          else
             return false;
       });
    }
}
