package com.tumri.buildtools.file;

import java.util.Set;
import java.util.HashMap;
import java.util.Properties;
import java.io.*;

/**
 * Merges Two Property Files. 
 *
 * @author nraman
 * @version 1.0.0
 * @since   1.0.0
 */
public class FileMerger {

    private File src;
    private File override;
    private File defaultValues;
    public FileMerger(){

    }

    private void replaceWithDefault(Properties defaultProperties ) {
        FileWriter writer = null;
        FileInputStream fis = null;
        try {

            fis = new FileInputStream(override);
            InputStreamReader isr = new InputStreamReader(fis, "utf8");
            BufferedReader br = new BufferedReader(isr);
            String line;
            Set<Object> set = defaultProperties.keySet();
            String oldText= "";
            String newtext ="";
            while((line = br.readLine()) != null)
            {
                oldText += line + "\r\n";
            }

            for (Object k : set) {
                String key = (String) k;
                newtext = oldText.replaceAll(key+"=",key+"="+defaultProperties.get(key));
            }

            writer = new FileWriter(override+"1");
            writer.write(newtext);writer.close();


        } catch (IOException e) {
            System.out.println("IO Exception encountered ");
        } finally {
            close(fis);
            close (writer);
        }
    }

    private void merge(String argv[]) {
        if (argv.length < 3)
            System.out.println("Too few arguments");

        src = new File(argv[0]);
        override = new File(argv[1]);
        defaultValues = new File(argv[2]);

        /* // This is for testing
        src = new File("/test/local.properties");
        override = new File("/test/local_tm.properties");
        defaultValues = new File("/test/tm_default.properties");
        */

        if (!src.exists()) System.out.println("File " + src.getPath() + " does not exist");
        if (!override.exists()) System.out.println("File " + override.getPath() + " does not exist");

        Properties defaultProperties = readProperties(defaultValues);
        replaceWithDefault(defaultProperties);

        override = new File(argv[1]+"1");

        merge();
        deleteFile(override);

    }

    private Properties readProperties(File f) {
        Properties p = new Properties();
        InputStream is = null;
        try {
            is = new FileInputStream(f);
            p.load(is);
        } catch (IOException e) {
            System.out.println("IO Exception encountered " + e);
        } finally {
            close(is);
        }
        return p;
    }


    public static void main(String argv[]) {
        FileMerger pm = new FileMerger();
        pm.merge(argv);
    }

    private void merge() {
        FileInputStream fis = null;
        FileOutputStream fos = null;
        try {
            fis = new FileInputStream(override);
            InputStreamReader isr = new InputStreamReader(fis, "utf8");
            BufferedReader br = new BufferedReader(isr);
            String line;

            fos = new FileOutputStream(src,true);
            OutputStreamWriter osr = new OutputStreamWriter(fos, "utf8");
            BufferedWriter bw = new BufferedWriter(osr);

            while ((line = br.readLine()) != null) {
                bw.write(line);
                bw.newLine();
            }
            bw.flush();
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

    private void deleteFile(File f ) {
        f.delete();
    }

}


