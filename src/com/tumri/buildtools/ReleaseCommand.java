package com.tumri.buildtools;

/**
 * Created by IntelliJ IDEA.
 * User: snawathe
 * Date: Jun 12, 2008
 * Time: 10:47:59 PM
 * To change this template use File | Settings | File Templates.
 */
public class ReleaseCommand extends PerlCommand {
    //private static final String Command =  "build.pl release -component $1 -depotPath $2 -version $3 $4 $5 $6";
    private static final String Command =  "build.pl release $1 $2";

    private String component;
    private String depotpath;
    private String branchname;
    private String version;
    private String notes;
    private String user;
    private String id;
    private String attachmentInfo;

    private static final String e_RELEASE_URL = "releaseUrl";


    public ReleaseCommand() {
        super(Command);
    }


    public String getComponent() {
        return component;
    }

    public void setComponent(String aComponent) {
        component = aComponent;
    }

    public String getId() {
        return id;
    }

    public void setId(String aId) {
        id = aId;
    }

    public String getDepotpath() {
        return depotpath;
    }

    public void setDepotpath(String aDepotpath) {
        depotpath = aDepotpath;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String aVersion) {
        version = aVersion;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String aNotes) {
        notes = aNotes;
    }

    public String getUser() {
        return user;
    }

    public void setUser(String aUser) {
        user = aUser;
    }

    public String getBranchName() {
        return branchname;
    }

    public void setBranchName(String aBranchName) {
        branchname = aBranchName;
    }

    public String getAttachmentInfo() {
        return attachmentInfo;
    }

    public void setAttachmentInfo(String aInfo) {
        attachmentInfo = aInfo;
    }

    protected String[] getArguments() {
        String argv[] = new String[2];
        argv[0] = (((id != null) && (id.length() > 0)) ? "-id " + id : "");
        argv[1] = (((attachmentInfo != null) && (attachmentInfo.length() > 0)) ? "-attach \'" + attachmentInfo + "\'" : "");
        //argv[0] = component;
        //argv[1] = depotpath;
        //argv[2] = version;
        //argv[3] = (((branchname != null) && (branchname.length() > 0)) ? "-branchname " + branchname : "");
        //argv[4] = (((user != null) && (user.length() > 0)) ? "-user "+user : "");
        //argv[5] = (((notes != null) && (notes.length() > 0)) ? "-notes \'"+notes+"\'" : "");
        return argv;
    }

    public String getReleaseUrl() {
        return getTextContent(e_RELEASE_URL);
    }

    public static void main(String argv[]) {
        ReleaseCommand dc = new ReleaseCommand();
        dc.setComponent("ics");
        dc.setDepotpath("path");
        dc.setVersion("1.2.3.4");
        dc.setNotes("This is line 1\nThis is line 2\nThis is line 3\nThis is line 4\n");
        dc.exec();
    }
}
