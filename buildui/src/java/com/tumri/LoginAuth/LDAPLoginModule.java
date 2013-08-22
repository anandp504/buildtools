package com.tumri.LoginAuth;

import com.tumri.LoadProperties;
import java.util.Enumeration;
import java.util.Hashtable;

import javax.naming.Context;
import javax.naming.NamingException;
import javax.naming.directory.Attribute;
import javax.naming.directory.Attributes;
import javax.naming.directory.DirContext;
import javax.naming.directory.InitialDirContext;
import javax.naming.directory.SearchResult;

class LDAPLoginModule {
	
	private Hashtable<String, String> env;
	private DirContext ctx;
        String ldapUrl = LoadProperties.getInstance().get("ldap.url");
        String email;
	
	public String authenticateUserInLDAP(String userName,String password) {

		try {		
			// Set up the environment for creating the initial context
			env = new Hashtable<String, String>();

			env.put(Context.INITIAL_CONTEXT_FACTORY,"com.sun.jndi.ldap.LdapCtxFactory");
			env.put(Context.PROVIDER_URL, ldapUrl);
			env.put(Context.SECURITY_AUTHENTICATION, "simple");
			env.put(Context.SECURITY_PRINCIPAL, "uid=" + userName+ ",ou=People,dc=tumri,dc=net");
			env.put(Context.SECURITY_CREDENTIALS, password);

			// Create the initial context
			ctx = new InitialDirContext(env);

			Attributes attributes = null;
			Attribute uniqueMember = null;
			String memberString = null;

			Enumeration<SearchResult> enums = ctx.search("ou=People", null);

			for (; enums.hasMoreElements();) {
				SearchResult sr = enums.nextElement();
				attributes = sr.getAttributes();
				uniqueMember = attributes.get("uid");
				Attribute attr2 = attributes.get("mail");

				if (uniqueMember != null && attr2 != null) {
					for (int i = 0; i < uniqueMember.size(); i++) {
						memberString = uniqueMember.get(i).toString();

						if (memberString.equals(userName)) {
							System.out.println("Member logged in is " + memberString);
							System.out.println("Email of user is "+ attr2.get(i).toString());
							email = attr2.get(i).toString();
							return email;
						}
					}
				}
			}
			ctx.close();
		} catch (NamingException ne) {
                        System.err.println(ne.getMessage());
                        //ne.printStackTrace();
			return email;
		}
		return email;
	}
}