package com.tumri.buildtools.version;

import java.io.*;
import java.util.Properties;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by IntelliJ IDEA.
 * User: nraman
 * Date: Dec 15, 2010
 * Time: 2:11:46 PM
 * To change this template use File | Settings | File Templates.
 */
public class VersionReplace {
    private File src;
    private String version;
    String pattern =  "${version}";
    private File copyAs;

    private void merge(String argv[]) {
        if (argv.length < 3)
            System.out.println("Too few arguments");

        src = new File(argv[0]);
        copyAs = new File(argv[1]);
        version = argv[2];
        /* This is for testing
        src = new File("/test/index.txt");
        version = "trs_1.0.0.0";
        */

        if (!src.exists()) System.out.println("File " + src.getPath() + " does not exist");
        if (version == null || version.isEmpty()) System.out.println("version cannot be empty");

        merge();
    }

    private String entityFixup(String line, Pattern p, String replace) {
        Matcher m = p.matcher(line);
        return m.replaceAll(replace);
    }

    private void merge() {
        FileInputStream fis = null;
        FileOutputStream fos = null;
        try {
            fis = new FileInputStream(src);
            InputStreamReader isr = new InputStreamReader(fis, "utf8");
            BufferedReader br = new BufferedReader(isr);
            String line, text="";

            while ((line = br.readLine()) != null) {
                text += line + "\r\n";;
            }
            br.close();
            //System.out.println("pattern "+pattern);
            String replaceText = text.replace(pattern,version);
            //System.out.println(replaceText);
            FileWriter writer = new FileWriter(copyAs);
            writer.write(replaceText);
            writer.close();

        } catch (IOException e) {
            System.out.println("IO Exception encountered "+ e);
        } finally {
            close(fis);
            close (fos);
        }
    }

    private void close(Closeable io) {
        if (io != null) {
            try {
                io.close();
            } catch (IOException e) {
                System.out.println(e.getMessage());
            }
        }
    }
    public static void main(String argv[]) {
        VersionReplace pm = new VersionReplace();
        pm.merge(argv);
    }
}
