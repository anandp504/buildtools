package com.tumri.buildtools;

/**
 * Created by IntelliJ IDEA.
 * User: snawathe
 * Date: Jun 12, 2008
 * Time: 11:13:37 PM
 * To change this template use File | Settings | File Templates.
 */
public class DisplaylogCommand extends PerlCommand {
    private static final String Command =  "build.pl displaylog";
    public static final String e_LOG = "log";


    public DisplaylogCommand() {
        super(Command);
    }

    public String getLog() {
        return getTextContent(e_LOG);
    }

    public static void main(String argv[]) {
        DisplaylogCommand dc = new DisplaylogCommand();
        dc.exec();
        dc.getLog();
    }
}
