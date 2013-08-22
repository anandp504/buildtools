package com.tumri.buildtools;

import java.io.*;
import java.util.Properties;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by IntelliJ IDEA.
 * User: snawathe
 * Date: Jan 30, 2008
 * Time: 4:46:37 PM
 * To change this template use File | Settings | File Templates.
 * Modifies src property/xml file, based on tokens within the files.
 * These tokens are defined in override file as properties.
 * Override properties have syntax: filename.key=value, where filename is used as a namespace separator
 * The tools makes sure that all the keys in the Override properties are consumed and all the token
 * in src file are also consumed.
 * The general syntax of the tokens in src file name "mysource.xml" is as given:
 * ${a.b.c}
 * Correspondingly the token definition in the override property file is stated as:
 * mysource.a.b.c = ThisMachineSpecificValue
 * As a result of the merger a new file destination file is constructed and the the token string
 * ${a.b.c} is replaced by 'ThisMachineSpecificValue'
 */
public class PropertyMerger {
	private static final String XML = ".xml";
	private static final String PROPERTIES = ".properties";
	private static final Pattern XmlPattern = Pattern.compile("\\$\\{[\\w\\.]+\\}"); // ${a.b.c}
	private static final Pattern AmpPattern = Pattern.compile("\\&");
	private static final Pattern QuotPattern = Pattern.compile("\\\"");
	private static final Pattern AposPattern = Pattern.compile("\\'");
	private static final Pattern LTPattern = Pattern.compile("<");
	private static final Pattern GTPattern = Pattern.compile(">");

	private static final String AmpEntity = "&amp;";
	private static final String QuotEntity = "&quot;";
	private static final String AposEntity = "&apos;";
	private static final String LTEntity = "&lt;";
	private static final String GTEntity = "&gt;";

	private boolean ignore = false;
	private File src;
	private File override;
	private File dest;

	public PropertyMerger() {
	}

	private void usage(String error) {
		System.out.println("Error: " + error);
		System.out.print(ignore ? "\t-i\n" : "");
		System.out.println("\tsrc=" + src.getAbsolutePath());
		System.out.println("\toverride=" + override.getAbsolutePath());
		System.out.println("\tdest=" + dest.getAbsolutePath());
		System.out.println("PropertyMerger: -i src override dest");
		System.out.println("-i  ignore unused definitions");
		System.out.println("    src: source property/xml file");
		System.out.println("    override: overriding property file");
		System.out.println("    dest: destination of resultant property/xml file\n");
		System.out.println("Modifies src property/xml file, based on tokens within the files.");
		System.out.println("These tokens are defined in override file as properties.");
		System.out.println("Override properties have syntax: filename.key=value, where filename is used as a namespace separator");
		System.out.println("The tools makes sure that all the keys in the Override properties are consumed and all the token");
		System.out.println("in src file are also consumed.");
		System.out.println("The general syntax of the tokens in src file name mysource.xml is as given:");
		System.out.println("\t${a.b.c}");
		System.out.println("Correspondingly the token definition in the override property file is stated as:");
		System.out.println("\tmysource.a.b.c = ThisMachineSpecificValue");
		System.out.println("As a result of the merger a new file destination file is constructed and the the token string");
		System.out.println("\t${a.b.c} is replaced by 'ThisMachineSpecificValue'");
		System.exit(-1);
	}

	private void merge(String argv[]) {
		if (argv.length < 3)
			usage("Too few arguments");
		ignore = argv[0].equals("-i");
		int i = (argv.length == 4 ? 1 : 0);
		src = new File(argv[i]);
		override = new File(argv[i + 1]);
		dest = new File(argv[i + 2]);
		if (!src.exists()) usage("File " + src.getPath() + " does not exist");
		if (!override.exists()) usage("File " + override.getPath() + " does not exist");
		if (dest.exists()) usage("File " + dest.getPath() + " exists");
		merge();
	}

	private boolean isXML(File src) {
		return src.getPath().endsWith(XML);
	}

	private String getNamespace(String filename) {
		int index = filename.lastIndexOf('.');
		return (index > 0 ? filename.substring(0, index) : filename);
	}

	private Properties readProperties(File f) {
		Properties p = new Properties();
		InputStream is = null;
		try {
			is = new FileInputStream(f);
			p.load(is);
		} catch (IOException e) {
			usage("Can not open file " + f.getPath());
		} finally {
			close(is);
		}
		return p;
	}

	private void merge() {
		boolean xml = isXML(src);
		String namespace = getNamespace(src.getName());
		Properties poverride = readProperties(override);
		Properties used = new Properties();
		FileInputStream fis = null;
		FileOutputStream fos = null;
		try {
			fis = new FileInputStream(src);
			fos = new FileOutputStream(dest);
			OutputStreamWriter osr = new OutputStreamWriter(fos, "utf8");
			InputStreamReader isr = new InputStreamReader(fis, "utf8");
			BufferedReader br = new BufferedReader(isr);
			BufferedWriter bw = new BufferedWriter(osr);
			String line;
			while ((line = br.readLine()) != null) {
				Matcher m = XmlPattern.matcher(line);
				StringBuffer sb = new StringBuffer();
				while (m.find()) {
					String origKey = m.group();
					String key = origKey;
					key = namespace + "." + key.substring(2, key.length() - 1); // ${a.b.c} -> namespace.a.b.c
					if (!poverride.containsKey(key)) {
						if (!ignore) {
							usage("No override provided for key: " + key);
						}
					} else {
						String ovalue = poverride.getProperty(key);
						used.setProperty(key, ovalue);
						m.appendReplacement(sb, xml ? entityFixup(ovalue) : ovalue);
					}
				}
				m.appendTail(sb);
				sb.append("\n");
				bw.write(sb.toString());
			}
			bw.flush();
			compare(used, poverride, namespace);
		} catch (IOException e) {
			usage("IO Exception encountered ");
		} finally {
			close(fis);
			close(fos);
		}
	}

	/**
	 * Verify of all properties were used or not
	 *
	 * @param used     properties
	 * @param override properties
	 */
	private void compare(Properties used, Properties override, String namespace) {
		String tmpNameSpace = namespace + ".";
		if (used.size() != override.size()) {
			Set<Object> set = override.keySet();
			for (Object k : set) {
				String key = (String) k;
				if (key.startsWith(tmpNameSpace) && !used.containsKey(key)) {
					usage("The property " + key + " not used");
				}
			}
		}
	}

	private void close(Closeable io) {
		if (io != null) {
			try {
				io.close();
			} catch (IOException e) {
				usage("Failed to close stream ");
			}
		}
	}

	public static void main(String argv[]) {
		PropertyMerger pm = new PropertyMerger();
		pm.merge(argv);
	}

	private String entityFixup(String line) {
		if (line.startsWith("\"") && line.endsWith("\"")) {
			line = line.substring(1, line.length() - 1);
		}
		if (line.startsWith("\'") && line.endsWith("\'")) {
			line = line.substring(1, line.length() - 1);
		}
		line = entityFixup(line, AmpPattern, AmpEntity);
		line = entityFixup(line, QuotPattern, QuotEntity);
		line = entityFixup(line, AposPattern, AposEntity);
		line = entityFixup(line, LTPattern, LTEntity);
		line = entityFixup(line, GTPattern, GTEntity);
		return line;
	}

	private String entityFixup(String line, Pattern p, String replace) {
		Matcher m = p.matcher(line);
		return m.replaceAll(replace);
	}

	/*
		@Test
		public void test() {
			new File("dest.properties").delete();
			Properties src = new Properties();
			src.setProperty("a.b", "${a.b}");
			src.setProperty("a.b.c", "${a.b.c}");
			src.setProperty("a.b.c.d", "${a.b.c.d}");
			Properties override = new Properties();
			override.setProperty("src.a.b", "b=a");
			override.setProperty("src.a.b.c", "c=b=a");
			override.setProperty("src.a.b.c.d", "d=c=b=a");
			writeProperties(new File("src.properties"), src);
			writeProperties(new File("override.properties"), override);

			main(new String[]{"src.properties", "override.properties", "dest.properties"});
			Properties dest = readProperties(new File("dest.properties"));
			Assert.assertTrue(dest.getProperty("a.b.c").equals("c=b=a"));
			Assert.assertTrue(dest.getProperty("a.b.c.d").equals("d=c=b=a"));
			Assert.assertTrue(dest.getProperty("a.b").equals("b=a"));
		}

		@Test
		public void test1() {
			new File("dest1.xml").delete();
			Properties src = new Properties();
			src.setProperty("a.b", "ab${a.b}");
			src.setProperty("a.b.c", "${a.b.c}abc");
			src.setProperty("a.b.c.d", "${a.b.c.d}abcd${a.b.c.d}");
			Properties override = new Properties();
			override.setProperty("src1.a.b", "\"ba\"");
			override.setProperty("src1.a.b.c", "\'cb'a\'");
			override.setProperty("src1.a.b.c.d", "<dc&ba>");
			writeProperties(new File("src1.xml"), src);
			writeProperties(new File("override1.properties"), override);

			main(new String[]{"src1.xml", "override1.properties", "dest1.xml"});
			Properties dest = readProperties(new File("dest1.xml"));
			Assert.assertTrue(dest.getProperty("a.b").equals("abba"));
			Assert.assertTrue(dest.getProperty("a.b.c").equals("cb&apos;aabc"));
			Assert.assertTrue(dest.getProperty("a.b.c.d").equals("&lt;dc&amp;ba&gt;abcd&lt;dc&amp;ba&gt;"));
		}
		*/
}
