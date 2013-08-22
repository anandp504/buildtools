package com.tumri.buildtools;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import java.util.ArrayList;

/**
 * Created by IntelliJ IDEA.
 * User: snawathe
 * Date: Nov 13, 2007
 * Time: 1:14:22 PM
 * To change this template use File | Settings | File Templates.
 */
public class DOMUtils {

  public static Element getElementChild(Element parent) {
    if (parent != null) {
      NodeList nlist = parent.getChildNodes();
      for(int i=0;i<nlist.getLength();i++) {
        Node child = nlist.item(i);
        if (child.getNodeType() == Node.ELEMENT_NODE)
          return (Element)child;
      }
    }
    return null;
  }

  public static Element getElementChild(Element parent, String nodename) {
    if (parent != null) {
      NodeList nlist = parent.getChildNodes();
      for(int i=0;i<nlist.getLength();i++) {
        Node child = nlist.item(i);
        if (child.getNodeType() == Node.ELEMENT_NODE && child.getNodeName().equals(nodename))
          return (Element)child;
      }
    }
    return null;
  }

  public static Element[] getElementChildren(Element parent, String nodename) {
    ArrayList<Element> alist = new ArrayList<Element>();
    getElementChildren(parent, nodename, alist, false);
    return alist.toArray(new Element[alist.size()]);
  }

  public static Element[] getElementDescendents(Element parent, String nodename) {
    ArrayList<Element> alist = new ArrayList<Element>();
    getElementChildren(parent, nodename, alist,true);
    return alist.toArray(new Element[alist.size()]);
  }

  private static void getElementChildren(Element parent, String nodename, ArrayList<Element> alist, boolean recursive) {
    if (parent != null) {
      NodeList nlist = parent.getChildNodes();
      for(int i=0;i<nlist.getLength();i++) {
        Node child = nlist.item(i);
        if (child.getNodeType() == Node.ELEMENT_NODE) {
          if (child.getNodeName().equals(nodename)) {
            alist.add((Element)child);
          }
          if (recursive) {
            getElementChildren((Element)child,nodename,alist,recursive);
          }
        }
      }
    }
  }
}