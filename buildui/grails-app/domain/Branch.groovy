class Branch {
    static belongsTo = [ component: Component ];
    String name;
    String path;
    String stagedir = "";
    String releasedir = "";
    String devbuilddir = "";
    SortedSet builds;
    static hasMany =  [ builds:Build ]

    public String toString() {
      return name;
    }

    static optionals = ['stagedir', 'releasedir', 'devbuilddir'];

    static constraints = {
      component();
      name(blank:false);
      path(blank:false);
      name(unique:'component');
      path(unique:true);
    }
}
