package com.tumri.buildtools;

/**
 * Created by IntelliJ IDEA.
 * User: snawathe
 * Date: Nov 12, 2007
 * Time: 11:53:47 PM
 * To change this template use File | Settings | File Templates.
 */
public class BuildCommand extends PerlCommand {
    //private static final String Command = "build.pl build -component $1 -depotPath $2 $3 $4 $5 $6 $7 $8";
    private static final String Command = "build.pl build $1 $2";

    private String component;
    private String depotpath;
    private String branchname;
    private String version;
    private String base;
    private String tickets;
    private String notes;
    private String user;
    private String id;
    private String attachmentInfo;

    private static final String e_VERSION = "version";
    private static final String e_STAGING_URL = "stagingUrl";

    public BuildCommand() {
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

    public String getBranchName() {
        return branchname;
    }

    public void setBranchName(String aBranchName) {
        branchname = aBranchName;
    }

    public String getVersion() {
        return version;
    }
    public String getBuildVersion() {
        return getTextContent(e_VERSION);
    }

    public void setVersion(String aVersion) {
        if (aVersion != null)
            version = aVersion.trim();
    }

    public String getBase() {
        return base;
    }

    public void setBase(String aBase) {
        if (aBase != null)
            base = aBase.trim();
    }

    public String getTickets() {
        return tickets;
    }

    public void setTickets(String aTickets) {
        if (aTickets != null)
            tickets = aTickets.trim();
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String aNotes) {
        if (aNotes != null)
            notes = aNotes.trim();
    }

    public String getUser() {
        return user;
    }

    public void setUser(String aUser) {
        user = aUser;
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
        //argv[1] = depotpath;
        //argv[2] = (((branchname != null) && (branchname.length() > 0)) ? "-branchname " + branchname : "");
        //argv[3] = (version != null && version.length() > 0 ? "-version " + version : "");
        //argv[4] = (base != null && base.length() > 0       ? "-base " + base       : "");
        //argv[5] = (tickets != null && tickets.length() > 0 ? "-tickets " + tickets : "");
        //argv[6] = (((user != null) && (user.length() > 0)) ? "-user "+user : "");
        //argv[7] = (notes != null && notes.length() > 0 ? "-notes \'" + notes + "\'": "");
        return argv;
    }

    public String getStagingUrl() {
        return getTextContent(e_STAGING_URL);
    }

    public static void main(String argv[]) {
        BuildCommand dc = new BuildCommand();
        dc.setComponent("comp");
        dc.setDepotpath("path");
        dc.setBase("bse");
        dc.setNotes("This is a test string only.");
        dc.exec();
    }

}
