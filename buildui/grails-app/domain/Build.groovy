class Build implements Comparable {
  static belongsTo = [ branch : Branch ];
  Component component;
  Date date;
  String release;
  String base;
  String tickets;
  String stagingUrl;
  String releaseUrl;
  String notes;
  String user;
  Boolean released = false;

  public int compareTo(Object o) {
   return date.compareTo(((Build)o).date);
  }

  public String toString() {
    return release;
  }

  static optionals = ['notes', 'user']

  static constraints = {
     branch();
     component();
     release(matches:"v?[\\d+\\.]*");
     release(unique:['branch','component']);
     tickets(matches:"[\\d+\\,]*");
     releaseUrl(blank:true);
     notes(blank:true);
  }
}
