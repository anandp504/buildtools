package com.tumri.buildtools;

/**
 * Created by IntelliJ IDEA.
 * User: snawathe
 * Date: Jun 12, 2008
 * Time: 11:12:15 PM
 * To change this template use File | Settings | File Templates.
 */
public class CleanCommand extends PerlCommand {
    private static final String Command =  "build.pl clean";


    public CleanCommand() {
        super(Command);
    }
}
