/**
 *
 */
package com.tumri;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * @author Ajay
 * @version 1.0.0
 *
 */
public class LoadProperties {

	private Properties properties;
	private boolean propertiesExists;
	private String filetoLoad = "ldap.properties";

	private static LoadProperties instance = new LoadProperties();

	public static LoadProperties getInstance() {
		return instance;
	}

	private LoadProperties() {
		InputStream is = null;
		is = LoadProperties.class.getClassLoader().getResourceAsStream(
				filetoLoad);

		if (is == null) {
			is = Thread.currentThread().getContextClassLoader()
					.getResourceAsStream(filetoLoad);
		}

		if (is != null) {
			try {
				try {
					Properties props = new Properties();
					BufferedInputStream bis = new BufferedInputStream(is);
					props.load(bis);
					properties = props;
					propertiesExists = true;
				} finally {
					is.close();
				}
			} catch (IOException e) {
				throw new RuntimeException(
						"ldap.properties file not found", e);
			}
		} else {
			throw new RuntimeException("ldap.properties file not found");
		}
	}

	public String get(String key) {
		String value;
		if (propertiesExists) {
			value = properties.getProperty(key);
			if (value != null) {
				value = value.trim();
			}
		} else {
			throw new RuntimeException(
					"ldap.properties file not found during initialization");
		}
		return value;
	}
}
