package com.tumri.buildtools;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.logging.Logger;
import java.util.List;
import java.util.ArrayList;
import java.util.StringTokenizer;

/**
 * Created by IntelliJ IDEA.
 * User: snawathe
 * Date: Nov 12, 2007
 * Time: 9:37:40 PM
 * To change this template use File | Settings | File Templates.
 */
public class PerlCommand {
    static Logger log = Logger.getLogger("PerlCommand");
    //private static final String SCRIPT = (new File("scripts").isDirectory() ? "scripts" : "../scripts");
    private static final String SCRIPT = "/opt/Tumri/buildui/current/tomcat5/scripts";
    private static final String PERL = "/usr/bin/perl";


    public static final String e_ERROR = "error"; // Element tag of the type <error>info</error>
    public static final String e_SUCCESS = "success"; // Element tag of the type <success>info</success>

    private String m_command;
    private String[] m_command_array;
    private File m_workingDirectory;
    private Document m_OutputDocument;
    protected String m_error;
    private boolean m_success = false;

    public PerlCommand() {
    }

    public PerlCommand(String aCommand) {
        m_command = aCommand;
        m_workingDirectory = new File(SCRIPT);
        if (!m_workingDirectory.exists() || !m_workingDirectory.isDirectory()) {
            m_error = "Script Directory not found " + SCRIPT;
            log.warning("Current dir is "+ System.getProperty("user.dir"));
        }
        else
            log.info("script working directory is :" + SCRIPT);
        log.info("Script command is :" + m_command);
    }

    public void exec() {
        if (m_error != null)
            return;
        m_command = createCommand(m_command);
        m_command_array = splitArgs(m_command);

        log.info("script command is :" + m_command);
        InputStream is = null;
        InputStream es = null;
        try {
            //Process p = Runtime.getRuntime().exec(m_command, null, m_workingDirectory);
            Process p = Runtime.getRuntime().exec(m_command_array, null, m_workingDirectory);
            is = p.getInputStream();
            es = p.getErrorStream();

            InputReader inr = new InputReader(is);
            Thread inReader = new Thread(inr);

            InputReader err = new InputReader(es);
            Thread erReader = new Thread(err);

            inReader.start();
            erReader.start();
            try {
                erReader.join(getTimeout());
                inReader.join(getTimeout());
            } catch (InterruptedException e) {
                m_error = "Command Timed out!!";
            } catch (Throwable t) {
                m_error = "Internal error encountered!!";
            }
            m_OutputDocument = parse(new ByteArrayInputStream(inr.getBytes()));
            setError(m_OutputDocument);
            setSuccess(m_OutputDocument);
            if (m_error == null)
              m_error = "";
            if (err.getBytes() != null)
              m_error = m_error + "\n" + new String(err.getBytes());
        } catch (IOException e) {
            m_error = e.getMessage();
        } finally {
            close(is);
            close(es);
        }
    }

    public Document getOutputDocument() {
        return m_OutputDocument;
    }

    public String getError() {
        return m_error;
    }

    public boolean getSuccess() {
        return m_success;
    }

    protected long getTimeout() {
        return 1200000; // time in milli seconds - 20 minutes
    }

    protected String createCommand(String cmd) {
        String argv[] = getArguments();
        return commandParser(cmd, argv);
    }

    protected String[] getArguments() {
        return new String[]{};
    }

    private String[] splitArgs(String cmd) {
       StringBuilder sb = new StringBuilder();
       String regex = "\'.*\'";
       Pattern pattern = Pattern.compile(regex, Pattern.DOTALL);
       Matcher matcher = pattern.matcher(cmd);
       String quotedstr;
       String tmpstr;
       StringTokenizer st;
       String[] result;
       List<String> strList = new ArrayList<String>();
       int start = 0;
       while (matcher.find()) {
          quotedstr = matcher.group();
          tmpstr = cmd.substring(start, matcher.start());
          start = matcher.start() + quotedstr.length();
          st = new StringTokenizer(tmpstr, " ");
          while (st.hasMoreTokens()) {
              strList.add(st.nextToken());
          }
          st = new StringTokenizer(quotedstr.substring(1, quotedstr.length()-1), "\n");
          while (st.hasMoreTokens()) {
              sb.append(st.nextToken());
              sb.append("\\n");
          }
          strList.add(sb.toString());
       }
       if (start < cmd.length()) {
          tmpstr = new String(cmd.substring(start));
          st = new StringTokenizer(tmpstr, " ");
          while (st.hasMoreTokens()) {
              strList.add(st.nextToken());
          }
       }
       result = strList.toArray(new String[]{});
       return (result);
    }

    private String commandParser(String cmd, String[] argv) {
        StringBuilder sb = new StringBuilder();
        if (cmd != null) {
            sb.append(PERL).append(" ");
            String regex = "\\$\\d+";
            Pattern pattern = Pattern.compile(regex);
            Matcher matcher = pattern.matcher(cmd);
            int start = 0;
            while (matcher.find()) {
                String val = matcher.group();
                try {
                    int index = Integer.parseInt(val.substring(1)) - 1;
                    sb.append(cmd.substring(start, matcher.start()));
                    if (index < argv.length) {
                        sb.append(argv[index]);
                        sb.append(" ");
                    }
                    start = matcher.start() + val.length();
                } catch (NumberFormatException e) {
                }
            }
            if (start < cmd.length()) {
                sb.append(cmd.substring(start));
            }
        }
        return sb.toString();
    }

    private void setError(Document errorDoc) {
        if (errorDoc != null && errorDoc.getDocumentElement() != null) {
            Element error = DOMUtils.getElementChild(errorDoc.getDocumentElement(), e_ERROR);
            if (error != null) {
                m_error = error.getTextContent();
            }
        }
    }

    public void setSuccess(Document outputDoc) {
        if (outputDoc != null && outputDoc.getDocumentElement() != null) {
            Element success = DOMUtils.getElementChild(outputDoc.getDocumentElement(), e_SUCCESS);
            if (success != null) {
                m_success = true;
            }
        }
    }

    public String toString() {
        return m_command;
    }

    private Document parse(InputStream is) {
        try {
            BufferedInputStream bi = new BufferedInputStream(is);
            DocumentBuilder db = DocumentBuilderFactory.newInstance().newDocumentBuilder();
            return db.parse(bi);
        } catch (Exception e) {
            m_error = e.getMessage();
        }
        return null;
    }


    private void close(InputStream is) {
        try {
            if (is != null)
                is.close();
        } catch (IOException e) {
        }
    }

    class InputReader implements Runnable {
        InputStream m_is;
        byte[] m_bytes;

        public InputReader(InputStream aIs) {
            m_is = aIs;
        }

        public byte[] getBytes() {
            return (m_bytes == null ? new byte[]{} : m_bytes);
        }

        public void run() {
            log.info("Thread started");
            m_bytes = readStream(m_is);
            if (m_bytes != null)
                log.info(new String(m_bytes));
        }

        private byte[] readStream(InputStream is) {
            try {
                ByteArrayOutputStream out = new ByteArrayOutputStream();
                byte[] buf = new byte[8192];
                int len;
                while ((len = is.read(buf)) > 0) {
                    out.write(buf, 0, len);
                }
                out.close();
                return out.toByteArray();
            } catch (Exception e) {
                m_error = e.getMessage();
            }
            return null;
        }
    }
    protected String getTextContent(String elem) {
        Element e = DOMUtils.getElementChild(m_OutputDocument.getDocumentElement(),elem);
        return (e == null ? "" : e.getTextContent().trim());
    }

}
