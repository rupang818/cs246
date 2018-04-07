import java.io.*;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import java.util.Arrays;

public class ParseJSON {
  public static void main(String[] args) throws Exception {
    String index = args[0];
    String outFile = args[1];
    String type = "wikipage";

    System.out.println("Index: " + index + ", Type: " + type + ", OutFile: " + outFile);

    // Read the given json file and parse it using JSONParser
    JSONParser parser = new JSONParser();
    JSONObject jsonObject = (JSONObject)parser.parse(new FileReader("data/simplewiki-abstract.json"));

    // Once we have the JSONObject, we can access the different fields by using the 'get' method.
    // The 'get' method returns a value of type Object. We must cast the returned value to the correct type.
    JSONObject simplewiki = (JSONObject)jsonObject.get("simplewiki");
    JSONArray pages = (JSONArray)simplewiki.get("page");

    //Create a file that contains the documents in a format that can be indexed using the Elasticsearch bulk API.
    PrintWriter writer = new PrintWriter(outFile, "UTF-8");

    int i = 1;
    for(Object page : pages) {

      // Use the bulk indexing api from elasticsearch to index the file.
      // Ensure that the _id for the entry in the index matches the line number of that document.
      writer.println("{\"index\":{\"_index\" : \"" + index + "\", \"_type\": \"" + type + "\", \"_id\":\"" + i + "\"}}");
      // Write Json Page entry to file
      writer.println(page);
      i++;
    }

    writer.close();
  }
}
