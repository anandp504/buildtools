package com.tumri;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class LoadBuildProperties {

	private static final String VERSION_FILE = "buildui_version.properties";

	private static Properties props = new Properties();

	static {
		InputStream is = null;
		is = LoadBuildProperties.class.getClassLoader().getResourceAsStream(VERSION_FILE);
		if (is == null) {
			is = Thread.currentThread().getContextClassLoader().getResourceAsStream(VERSION_FILE);
		}
		if (is != null) {
			try {
				props = new Properties();
				BufferedInputStream bis = new BufferedInputStream(is);
				props.load(bis);
			} catch (IOException e) {
				throw new RuntimeException("buildui_version.properties file not found", e);
			} finally {
				if (is != null) {
					try {
						is.close();
					} catch (Exception e) {
						// TODO
					}
				}
			}
		} else {
			throw new RuntimeException("buildui_version.properties file not found/loaded");
		}
	}

	public static String getbuildProperty(String key) {
		String propValue="";
		try {
		propValue = props.getProperty(key).trim();
		}
		catch(Exception e){
			return propValue;
		}
		return (propValue != null ? propValue:"");
	}
}