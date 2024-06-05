package org.ecocean;

import org.ecocean.OpenSearch;
import org.json.JSONObject;

/**
 * Base class for other classes such as Encounter.java, Occurrence.java, and MarkedIndividual.java
 *
 * @author nishanth_nattoji
 */
public abstract class Base {
    /**
     * Retrieves Id, such as:
     *
     * <li>Catalog Number for an Encounter</li>
     * <li>Occurrence ID for an Occurrence</li>
     * <li>Individual ID for a Marked Individual</li>
     * <br>
     *
     * @return Id String
     */
    public abstract String getId();

    /**
     * Sets Id, such as:
     *
     * <li>Catalog Number for an Encounter</li>
     * <li>Occurrence ID for an Occurrence</li>
     * <li>Individual ID for a Marked Individual</li>
     * <br>
     *
     * @param id to set
     */
    public abstract void setId(final String id);

    /**
     * The computed version, such as a value computed using the 'modified' property of Encounter.java
     *
     * @return Version long value
     */
    public abstract long getVersion();

    /**
     * Retrieves the recorded comments such as for an Occurrence or a Marked Individual and occurrence remarks for an Encounter.
     *
     * @return Comments String
     */
    public abstract String getComments();

    /**
     * Sets the recorded comments such as for an Occurrence or a Marked Individual and occurrence remarks for an Encounter.
     *
     * @param comments to set
     */
    public abstract void setComments(final String comments);

    /**
     * Adds to the comments recorded for an Occurrence or a Marked Individual and to researcher comments for an Encounter.
     *
     * @param newComments to add
     */
    public abstract void addComments(final String newComments);

    public abstract String opensearchIndexName();

    public JSONObject opensearchDocument() {
        JSONObject json = new JSONObject();

        json.put("id", this.getId());
        json.put("bar", 123);
        return json;
    }

    public void opensearchCreateIndex()
    throws java.io.IOException {
        OpenSearch opensearch = new OpenSearch();

        opensearch.createIndex(opensearchIndexName());
    }

    public void opensearchIndex()
    throws java.io.IOException {
        OpenSearch opensearch = new OpenSearch();

        opensearch.index(this.opensearchDocument(), this.opensearchIndexName());
    }
}
