package com.tumri.buildtools;

/**
 * Created by IntelliJ IDEA.
 * User: snawathe
 * Date: Jun 12, 2008
 * Time: 10:52:34 PM
 * To change this template use File | Settings | File Templates.
 */
public class RemoveCommand extends PerlCommand {
    //private static final String Command =  "build.pl remove -component $1 -depotPath $2 -version $3 $4";
    private static final String Command =  "build.pl remove $1";

    private String component;
    private String depotpath;
    private String version;
    private String branchname;
    private String id;


    public RemoveCommand() {
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

    public String getBranchName() {
        return branchname;
    }

    public void setBranchName(String aBranchName) {
        branchname = aBranchName;
    }

    protected String[] getArguments() {
        String argv[] = new String[1];
        argv[0] = (((id != null) && (id.length() > 0)) ? "-id " + id : "");
        //argv[0] = component;
        //argv[1] = depotpath;
        //argv[2] = version;
        //argv[3] = (((branchname != null) && (branchname.length() > 0)) ? "-branchname " + branchname : "");
        return argv;
    }    
}
