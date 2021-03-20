/*
 * The Shepherd Project - A Mark-Recapture Framework
 * Copyright (C) 2011 Jason Holmberg
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

package org.ecocean.servlet;


import org.ecocean.Shepherd;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;

import io.prometheus.client.Counter;
import io.prometheus.client.Gauge;
import io.prometheus.client.CollectorRegistry; 
import io.prometheus.client.exporter.common.TextFormat;
import java.util.*;
//import com.oreilly.servlet.multipart.FilePart;
//import com.oreilly.servlet.multipart.MultipartParser;
//import com.oreilly.servlet.multipart.ParamPart;
//import com.oreilly.servlet.multipart.Part;
//import org.ecocean.CommonConfiguration;
//import org.ecocean.Encounter;
//import javax.ws.rs.core.StreamingOutput;
//import java.io.File;
//import java.io.FileOutputStream;
//import java.io.OutputStreamWriter;
//import javax.xml.bind.DatatypeConverter;
//import io.prometheus.client.exporter.MetricsServlet;
//import com.sun.net.httpserver.HttpServer;
//import org.eclipse.jetty.server.Server;
//import org.eclipse.jetty.servlet.ServletContextHandler;
//import org.eclipse.jetty.servlet.ServletHolder;

/**
 *
 * This servlet allows the user to upload an extracted, processed patterning file that corresponds to
 * a previously uploaded set of spots. This file is then used for visualization of the extracted pattern
 * and visualizations of potentially matched spots.
 * @author jholmber
 *
 */
public class TestPrometheusClient extends HttpServlet {


	/*Initialize variables*/
  Shepherd myShepherd; 
  boolean pageVisited = false; 	
  Counter encs;
  Gauge numUsersInWildbook; 
  Gauge numUsersWithLogin;


  public void init(ServletConfig config) throws ServletException {
    super.init(config);
    encs = Counter.build().name("number_encounters").help("Number encounters").register();
    numUsersInWildbook = Gauge.build().name("number_users").help("Number users").register();
    numUsersWithLogin = Gauge.build().name("number_users_w_login").help("Number users with Login").register();
  }


  public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    doPost(request, response);
  }


  public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    
    String context="context0";
    context=ServletUtilities.getContext(request);
    this.myShepherd = new Shepherd(context);
    this.myShepherd.setAction("TestPrometheusSevlet.class");

    //set up for response
    response.setContentType("text/html");
    PrintWriter out = response.getWriter();
    
    //Set up endpoint
    this.metrics(request, response);
    
    //begin db connection
    myShepherd.beginDBTransaction();
    try 
    { 
      //put the data into the database as a double
      if(!pageVisited)
      {
        this.setNumberOfUsers(out);
        this.setNumberOfEncounters(out);
        pageVisited = true; 
      }	
    } 
    catch (Exception lEx) 
    {
    //gracefully catch any errors  
      lEx.printStackTrace();
      out.println(ServletUtilities.getHeader(request));
      out.println("<strong>Error:</strong> I was unable to upload your file.");
      out.println(ServletUtilities.getFooter(context));
      response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
    finally 
    {
      //always close DB connections  
      this.myShepherd.rollbackDBTransaction();
      this.myShepherd.closeDBTransaction();
    }

    out.close();
  }

  public void setNumberOfUsers(PrintWriter out)
  {
    //Getting number of users by wildbook
    int numUsers = this.myShepherd.getNumUsers();
    this.numUsersInWildbook.set((double)numUsers);
    //out.println("<p> Number of users is: "+this.numUsersInWildbook.get()+"</p>");

    //get number of users w/ login privileges
   // int numUsersUsername = this.myShepherd.getWithUsername();
   // int numUsersEmail = this.myShepherd.getUsersWithEmailAddresses();
    //this.numUsersWithLogin.set((double)numUsersUsername);
    //out.println("<p> Number of users is: "+this.numUsersWithLogin.get()+"</p>");
  }

  public void setNumberOfEncounters(PrintWriter out)
  {
    //get the data from the database
    /*Number of encounters */
    int numEncounters=this.myShepherd.getNumEncounters(); //in aggregate
    this.encs.inc((double)numEncounters);
    //out.println("<p> Number of encounters is: "+this.encs.get()+"</p>");

  }
  
  //Implementation borrowed from MetricsServlet class
  public void metrics(HttpServletRequest request, HttpServletResponse response) throws IOException
  {
    Writer writer = new BufferedWriter(response.getWriter());
    response.setStatus(HttpServletResponse.SC_OK);
    String contentType = TextFormat.chooseContentType(request.getHeader("Accept"));
    response.setContentType(contentType);
    try
    {
      TextFormat.writeFormat(contentType, writer, CollectorRegistry.defaultRegistry.filteredMetricFamilySamples(parse(request)));
      writer.flush();
    }
    finally
    {
      writer.close();
    }
  }
  
  //Helper method for metrics()
  private Set<String> parse(HttpServletRequest req)
  {
    String[] includedParam = req.getParameterValues("name[]");
    if(includedParam == null)
    {
      return Collections.emptySet();
    }
    else
    {
      return new HashSet<String>(Arrays.asList(includedParam));
    }
  }

  //Method for printing prometheus objects standardly 
  public void printMetrics(PrintWriter out)
  {
    out.println("<p> Number of users is: "+this.numUsersInWildbook.get()+"</p>"); 
   
    out.println("<p> Number of encounters is: "+this.encs.get()+"</p>");
  }
}


