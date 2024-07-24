<%@ page contentType="text/html; charset=utf-8" language="java"
import="org.ecocean.*,
org.ecocean.servlet.ServletUtilities,
java.io.IOException,
javax.servlet.jsp.JspWriter,
javax.servlet.http.HttpServletRequest,
java.nio.file.Files,
java.sql.Timestamp,
java.sql.*,
java.io.File,
java.util.ArrayList,
java.util.List,
java.util.Map,
java.util.HashMap,
java.util.Set,
java.util.HashSet,
java.util.Properties,
javax.jdo.Query,
org.json.JSONObject,
org.json.JSONArray,
org.ecocean.media.*
    "
%>

<%!

private static Object siteSetting(String key, Connection conn) throws SQLException, IOException {
    Statement st = conn.createStatement();
    ResultSet res = st.executeQuery("SELECT * FROM site_setting WHERE key='" + key + "'");
    if (!res.next()) return null;
    String data = res.getString("data");
    if (data == null) return null;
    data = data.replaceAll("\\\\", "");
    data = data.substring(1, data.length() - 1);
    try {
        return new JSONObject(data);
    } catch (Exception ex) {}
    try {
        return new JSONArray(data);
    } catch (Exception ex) {}
    return data;
}


private static Map<String,String> taxonomyMap(Connection conn) throws SQLException, IOException {
    Object ss = siteSetting("site.species", conn);
    Map<String,String> rtn = new HashMap<String,String>();
    if (ss == null) return rtn;
    JSONArray arr = (JSONArray)ss;
    for (int i = 0 ; i < arr.length() ; i++) {
        JSONObject tx = arr.getJSONObject(i);
        rtn.put(tx.optString("id", "_FAIL"), tx.optString("scientificName", "_FAIL"));
    }
    return rtn;
}

private static JSONObject locationJson(Connection conn) throws SQLException, IOException {
    Object ss = siteSetting("site.custom.regions", conn);
    if (ss == null) return null;
    try {
        return (JSONObject)ss;
    } catch (Exception ex) {}
    return null;
}

private static Map<String,String> locationMap(Connection conn) throws SQLException, IOException {
    Map<String,String> map = new HashMap<String,String>();
    return locationMap(locationJson(conn), map);
}

private static Map<String,String> locationMap(JSONObject data, Map<String,String> map) {
    if (data == null) return map;
    String id = data.optString("id", null);
    String name = data.optString("name", id);
    if (id != null) map.put(id, name);
    JSONArray sub = data.optJSONArray("locationID");
    if (sub != null) for (int i = 0 ; i < sub.length() ; i++) {
        JSONObject subObj = sub.optJSONObject(i);
        if (subObj == null) continue;
        locationMap(subObj, map);
    }
    return map;
}


private static int batchMax() {
    return 20;
}

private static void migrateUsers(JspWriter out, Shepherd myShepherd, Connection conn) throws SQLException, IOException {
    out.println("<h2>Users</h2><ol>");
    Statement st = conn.createStatement();
    ResultSet res = st.executeQuery("SELECT * FROM \"user\"");
    int ct = 0;
    while (res.next()) {
        String guid = res.getString("guid");
        int staticRoles = res.getInt("static_roles");
        out.println("<li>" + guid + ": ");
        Set<String> roles = new HashSet<String>();
        if ((staticRoles & 0x04000) > 0) {
            roles.add("admin");
            roles.add("orgAdmin");
            roles.add("researcher");
            roles.add("rest");
            roles.add("machinelearning");
        }
        if ((staticRoles & 0x80000) > 0) roles.add("orgAdmin");
        //if ((staticRoles & 0x10000) > 0)  exporter == "N/A"
        if ((staticRoles & 0x20000) > 0) roles.add("researcher");
        if ((staticRoles & 0x40000) > 0) {
            roles.add("rest");
            roles.add("machinelearning");
        }
        User user = myShepherd.getUserByUUID(guid);
        if (user != null) {
            out.println("<i>user exists; skipping</i>");
        } else {
            user = new User(guid);
            String username = res.getString("email");
            user.setUsername(username);
            user.setAffiliation(res.getString("affiliation"));
            // location seems to often have value in codex
            user.setUserURL(res.getString("website"));
            user.setEmailAddress(res.getString("email"));
            user.setFullName(res.getString("full_name"));
            myShepherd.getPM().makePersistent(user);

            for (String roleName : roles) {
                Role role = new Role();
                role.setRolename(roleName);
                role.setUsername(username);
                role.setContext("context0");
                myShepherd.getPM().makePersistent(role);
            }

            // TODO Organizations

            String msg = "created user [" + ct + "] [" + String.join(",", roles) + "] " + user;
            out.println("<b>" + msg + "</b>");
            System.out.println(msg);
        }
        out.println("</li>");
        ct++;
    }
    out.println("</ol>");
}


private static void migrateMediaAssets(JspWriter out, Shepherd myShepherd, Connection conn, HttpServletRequest request, File assetGroupDir) throws SQLException, IOException {
    out.println("<h2>MediaAssets</h2><ol>");
    Statement st = conn.createStatement();
    ResultSet res = st.executeQuery("SELECT * FROM asset ORDER BY git_store_guid, guid");
    AssetStore targetStore = AssetStore.getDefault(myShepherd);
    List<Integer> maIds = new ArrayList<Integer>();
    int ct = 0;

    while (res.next()) {
        ct++;
        if (ct > batchMax()) break;
        String guid = res.getString("guid");
        out.println("<li>" + guid + ": ");
        MediaAsset ma = MediaAssetFactory.loadByUuid(guid, myShepherd);
        if (ma != null) {
            ct--;
            out.println("<i>asset exists; skipping</i>");
        } else {
            String ext = "unknown";
            String mimeType = res.getString("mime_type");
            if ((mimeType != null) && mimeType.contains("/")) ext = mimeType.split("\\/")[1];
            if ("jpeg".equals(ext)) ext = "jpg";
            String assetGroupGuid = res.getString("git_store_guid");
            File sourceFile = new File(assetGroupDir, assetGroupGuid + "/_assets/" + guid + "." + ext);
            String userFilename = res.getString("path");
            if (!Util.stringExists(userFilename)) userFilename = guid + "." + ext;
            //out.println(sourceFile.toString());
            if (!sourceFile.exists()) {
                out.println("<b>" + sourceFile + " does not exist</b>");
                break;
            }
            File tmpFile = new File("/tmp", guid + "." + ext);
            Files.copy(sourceFile.toPath(), tmpFile.toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
            String grouping = Util.hashDirectories(assetGroupGuid, File.separator);
            JSONObject params = targetStore.createParameters(tmpFile, grouping);
            params.put("userFilename", userFilename);
            params.put("_codexMigration", System.currentTimeMillis());
            ma = targetStore.create(params);
            try {
                ma.copyIn(sourceFile);
            } catch (Exception ex) {
                out.println("<b>failed to copyIn " + sourceFile + " => " + ex.toString() + "</b>");
                break;
            }
            ma.setUUID(guid);
            // TODO revision from codex?
            ma.setAcmId(res.getString("content_guid"));
            ma.updateMetadata();
            ma.addLabel("_original");
            ma.setAccessControl(request);
            MediaAssetFactory.save(ma, myShepherd);
            maIds.add(ma.getId());
            String msg = "created [" + ct + "] " + ma;
            out.println("<b>" + msg + "</b>");
            System.out.println(msg);
        }
        out.println("</li>");
    }
    myShepherd.commitDBTransaction(); // necessary for backgrounding
    myShepherd.beginDBTransaction();
    MediaAsset.updateStandardChildrenBackground(ServletUtilities.getContext(request), maIds);
    out.println("</ol>");
}


private static void migrateAnnotations(JspWriter out, Shepherd myShepherd, Connection conn) throws SQLException, IOException {
    out.println("<h2>Annotations</h2><ol>");
    Statement st = conn.createStatement();
    ResultSet res = st.executeQuery("SELECT * FROM annotation ORDER BY guid");
    FeatureType.initAll(myShepherd);
    int ct = 0;

    while (res.next()) {
        ct++;
        if (ct > batchMax()) break;
        String guid = res.getString("guid");
        Annotation ann = myShepherd.getAnnotation(guid);
        if (ann != null) {
            ct--;
            out.println("<li>" + guid + ": <i>annotation exists; skipping</i>");
        } else {
            String maId = res.getString("asset_guid");
            MediaAsset ma = MediaAssetFactory.loadByUuid(maId, myShepherd);
            if (ma == null) {
                //out.println("<b>" + guid + ": failed due to missing MediaAsset id=" + maId + "</b>");
                //System.out.println(guid + " failed due to missing MediaAsset id=" + maId);
                ct--;
                continue;
            }
            out.println("<li>" + guid + ": ");
            String bstr = res.getString("bounds");
            if (bstr.substring(0,1).equals("\"")) bstr = bstr.substring(1, bstr.length() - 1);
            bstr = bstr.replaceAll("\\\\", "");
System.out.println("bstr=>" + bstr);
            JSONObject bounds = new JSONObject(bstr);
            JSONArray rect = bounds.getJSONArray("rect");
            JSONObject params = new JSONObject();
            params.put("theta", bounds.optDouble("theta"));
            params.put("x", rect.optInt(0, 0));
            params.put("y", rect.optInt(1, 0));
            params.put("width", rect.optInt(2, 0));
            params.put("height", rect.optInt(3, 0));
            Feature feat = new Feature("org.ecocean.boundingBox", params);
            ma.addFeature(feat);
            // 99.9% sure species doesnt matter any more, so setting as null
            ann = new Annotation(null, feat, res.getString("ia_class"));
            ann.setId(guid);
            // TODO id status?
            ann.setAcmId(res.getString("content_guid"));
            ann.setViewpoint(res.getString("viewpoint"));
            ann.setMatchAgainst(true);
            myShepherd.getPM().makePersistent(ann);

            String msg = "created annot [" + ct + "] " + ann;
            out.println("<b>" + msg + "</b>");
            System.out.println(msg);
        }
        out.println("</li>");
    }
    out.println("</ol>");
}

private static void migrateEncounters(JspWriter out, Shepherd myShepherd, Connection conn) throws SQLException, IOException {
    out.println("<h2>Encounters</h2><ol>");
    Map<String,String> txmap = taxonomyMap(conn);
    Statement st = conn.createStatement();
    Statement st2 = conn.createStatement();
    ResultSet res = st.executeQuery("SELECT encounter.*, complex_date_time.datetime, complex_date_time.timezone, complex_date_time.specificity FROM encounter JOIN complex_date_time ON (time_guid = complex_date_time.guid) ORDER BY guid");
    int ct = 0;

    while (res.next()) {
        ct++;
        if (ct > batchMax()) break;
        String guid = res.getString("guid");
        out.println("<li>" + guid + ": ");
        Encounter enc = myShepherd.getEncounter(guid);
        if (enc != null) {
            ct--;
            out.println("<i>encounter exists; skipping</i>");
        } else {
            enc = new Encounter();
            enc.setId(guid);
            Timestamp ts = res.getTimestamp("created");
            if (ts != null) enc.setDWCDateAdded(ts.toString());
            ts = res.getTimestamp("updated");
            if (ts != null) enc.setDWCDateLastModified(ts.toString());
            String txguid = res.getString("taxonomy_guid");
            if (txguid != null) enc.setTaxonomyFromString(txmap.get(txguid));
            User owner = myShepherd.getUser(res.getString("owner_guid"));
            if (owner != null) {
                enc.addSubmitter(owner);
                enc.setSubmitterID(owner.getUsername());
            }
            Double d = res.getDouble("decimal_latitude");
            if (res.wasNull()) d = null;
            enc.setDecimalLatitude(d);
            d = res.getDouble("decimal_longitude");
            if (res.wasNull()) d = null;
            enc.setDecimalLongitude(d);
            enc.setSex(res.getString("sex"));
            enc.setVerbatimLocality(res.getString("verbatim_locality"));
            enc.setLocationID(res.getString("location_guid"));

            // date/time madness
            ts = res.getTimestamp("datetime");
            String tz = res.getString("timezone");
            String spec = res.getString("specificity");
            Timestamp adjusted = ts; // FIXME adjust for tz
            enc.setYear(adjusted.getYear() + 1900);
            if (!"year".equals(spec)) {
                enc.setMonth(adjusted.getMonth());
                if (!"month".equals(spec)) {
                    enc.setDay(adjusted.getDay());
                    if (!"day".equals(spec)) {
                        enc.setHour(adjusted.getHours());
                        enc.setMinutes(Integer.toString(adjusted.getMinutes())); // ygbkm
                    }
                }
            }

/*
            // loop thru annotations
            ResultSet subRes = st2.executeQuery("SELECT guid FROM annotation WHERE encounter_guid='" + guid + "'");
            while (subRes.next()) {
                String annId = subRes.getString("guid");
                Annotation ann = myShepherd.getAnnotation(annId);
                if (ann == null) {
                    System.out.println("could not load ann " + annId + " for enc " + guid);
                } else {
                    enc.addAnnotation(ann);
                }
            }
*/

            myShepherd.storeNewEncounter(enc, guid);

            String msg = "created encounter [" + ct + "] " + enc;
            out.println("<b>" + msg + "</b>");
            System.out.println(msg);
        }
        out.println("</li>");
    }
    out.println("</ol>");

    // annotation joins after
    ct = 0;
    res = st.executeQuery("SELECT guid, encounter_guid FROM annotation ORDER BY encounter_guid, guid");
    while (res.next()) {
        String annGuid = res.getString("guid");
        String encGuid = res.getString("encounter_guid");
        Encounter enc = myShepherd.getEncounter(encGuid);
        Annotation ann = myShepherd.getAnnotation(annGuid);
        if ((enc == null) || (ann == null)) {
            System.out.println("migrateEncounterss: cannot join due to null; enc=" + enc + "; ann=" + ann);
            continue;
        }
        ct++;
        enc.addAnnotation(ann);
    }
    out.println("<p>joined " + ct + " enc/ann pairs</p>");
}


private static void migrateOccurrences(JspWriter out, Shepherd myShepherd, Connection conn) throws SQLException, IOException {
    out.println("<h2>Occurrences</h2><ol>");
    Statement st = conn.createStatement();
    Statement st2 = conn.createStatement();
    ResultSet res = st.executeQuery("SELECT sighting.*, complex_date_time.datetime, complex_date_time.timezone, complex_date_time.specificity FROM sighting JOIN complex_date_time ON (time_guid = complex_date_time.guid) ORDER BY guid");
    int ct = 0;

    while (res.next()) {
        ct++;
        if (ct > batchMax()) break;
        String guid = res.getString("guid");
        out.println("<li>" + guid + ": ");
        Occurrence occ = myShepherd.getOccurrence(guid);
        if (occ != null) {
            ct--;
            out.println("<i>occurrence exists; skipping</i>");
        } else {
            occ = new Occurrence();
            occ.setId(guid);
            Timestamp ts = res.getTimestamp("created");
            if (ts != null) occ.setDateTimeCreated(ts.toString());
            ts = res.getTimestamp("updated");
            if (ts != null) occ.setDWCDateLastModified(ts.toString());

            Double d = res.getDouble("decimal_latitude");
            if (res.wasNull()) d = null;
            occ.setDecimalLatitude(d);
            d = res.getDouble("decimal_longitude");
            if (res.wasNull()) d = null;
            occ.setDecimalLongitude(d);
            occ.setComments(res.getString("comments"));
            //occ.setVerbatimLocality(res.getString("verbatim_locality"));
            //occ.setLocationID(res.getString("location_guid"));
            myShepherd.storeNewOccurrence(occ);

            String msg = "created occurrence [" + ct + "] " + occ;
            out.println("<b>" + msg + "</b>");
            System.out.println(msg);
        }
        out.println("</li>");
    }
    out.println("</ol>");

    ct = 0;
    res = st.executeQuery("SELECT guid, sighting_guid FROM encounter ORDER BY sighting_guid");
    while (res.next()) {
        String encGuid = res.getString("guid");
        String occGuid = res.getString("sighting_guid");
        Encounter enc = myShepherd.getEncounter(encGuid);
        Occurrence occ = myShepherd.getOccurrence(occGuid);
        if ((enc == null) || (occ == null)) {
            System.out.println("migrateOccurrences: cannot join due to null; enc=" + enc + "; occ=" + occ);
            continue;
        }
        occ.addEncounter(enc);
        enc.setOccurrenceID(occ.getId());
    }
    out.println("<p>joined " + ct + " occ/enc pairs</p>");

}

private static void migrateMarkedIndividuals(JspWriter out, Shepherd myShepherd, Connection conn) throws SQLException, IOException {
    out.println("<h2>MarkedIndividuals</h2><ol>");
    Map<String,String> txmap = taxonomyMap(conn);
    Statement st = conn.createStatement();
    Statement st2 = conn.createStatement();
    ResultSet res = st.executeQuery("SELECT * FROM individual ORDER BY guid");
    int ct = 0;

    while (res.next()) {
        ct++;
        if (ct > batchMax()) break;
        String guid = res.getString("guid");
        out.println("<li>" + guid + ": ");
        MarkedIndividual indiv = myShepherd.getMarkedIndividual(guid);
        if (indiv != null) {
            ct--;
            out.println("<i>indiv exists; skipping</i>");
        } else {
            indiv = new MarkedIndividual();
            indiv.setId(guid);
            Timestamp ts = res.getTimestamp("created");
            if (ts != null) indiv.setDateTimeCreated(ts.toString());
            //ts = res.getTimestamp("updated");
            //if (ts != null) occ.setDWCDateLastModified(ts.toString());
            String txguid = res.getString("taxonomy_guid");
            if (txguid != null) indiv.setTaxonomyString(txmap.get(txguid));
            ts = res.getTimestamp("time_of_birth");
            if (ts != null) indiv.setTimeOfBirth(ts.getTime());
            ts = res.getTimestamp("time_of_death");
            if (ts != null) indiv.setTimeOfDeath(ts.getTime());
            indiv.setSex(res.getString("sex"));
            indiv.setComments(res.getString("comments"));

            ResultSet res2 = st2.executeQuery("SELECT * FROM name WHERE individual_guid='" + guid + "'");
            while (res2.next()) {
                String nameContext = res2.getString("context");
                String nameValue = res2.getString("value");
                if ("FirstName".equals(nameContext)) {
                    indiv.addName(nameValue);
                } else {
                    indiv.addName(nameContext, nameValue);
                }
            }

            myShepherd.storeNewMarkedIndividual(indiv);

            String msg = "created indiv [" + ct + "] " + indiv;
            out.println("<b>" + msg + "</b>");
            System.out.println(msg);
        }
        out.println("</li>");
    }
    out.println("</ol>");

    ct = 0;
    res = st.executeQuery("SELECT guid, individual_guid FROM encounter WHERE individual_guid IS NOT NULL ORDER BY individual_guid");
    while (res.next()) {
        String encGuid = res.getString("guid");
        String indivGuid = res.getString("individual_guid");
        Encounter enc = myShepherd.getEncounter(encGuid);
        MarkedIndividual indiv = myShepherd.getMarkedIndividual(indivGuid);
        if ((enc == null) || (indiv == null)) {
            System.out.println("migrateMarkedIndividuals: cannot join due to null; enc=" + enc + "; indiv=" + indiv);
            continue;
        }
        enc.setIndividual(indiv);
    }
    out.println("<p>joined " + ct + " enc/indiv pairs</p>");

}

%>


<%

String context = ServletUtilities.getContext(request);
Shepherd myShepherd = new Shepherd(context);
myShepherd.beginDBTransaction();

Properties props = ShepherdProperties.getProperties("codexMigration.properties", "", context);
String dbUrl = props.getProperty("codexDbUrl", context);
String dbUsername = props.getProperty("codexDbUsername", context);
String dbPassword = props.getProperty("codexDbPassword", context);

// this is under data-dir
String assetGroupDir = props.getProperty("assetGroupDir", context);
File dataDir = CommonConfiguration.getDataDirectory(getServletContext(), context);


Connection conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);

JSONObject locJson = locationJson(conn);
// hard-coded file path, but life is rough
if (locJson != null) Util.writeToFile(locJson.toString(4), "/usr/local/tomcat/webapps/wildbook_data_dir/WEB-INF/classes/bundles/locationID.json");


migrateUsers(out, myShepherd, conn);

migrateMediaAssets(out, myShepherd, conn, request, new File(dataDir, assetGroupDir));

migrateAnnotations(out, myShepherd, conn);

migrateEncounters(out, myShepherd, conn);

migrateOccurrences(out, myShepherd, conn);

migrateMarkedIndividuals(out, myShepherd, conn);

myShepherd.commitDBTransaction();
myShepherd.closeDBTransaction();

%>



