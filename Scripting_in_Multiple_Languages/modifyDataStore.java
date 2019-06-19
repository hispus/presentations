// modifyDataStore.java, a Java script by Vladimer Shioshvili,
// modified slightly by Ben Guaraldi

// Note that it's more normal to capitalize the first letter in Java classes
// (i.e., ModifyDataStore.java), but the same format is used as the other scripts

// In order to run this code, use these commands:
// javac -classpath 'java_classes/*' modifyDataStore.java
// java -classpath 'java_classes/*:.' modifyDataStore modifyDataStore.class

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.Charset;
import java.util.TreeSet;

import org.apache.commons.codec.binary.Base64;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;

public class modifyDataStore {
	public static void main(String[] args) throws IOException{

		// Customize for you
		String yourname = "";
		if (yourname.length() == 0) {
			System.err.println("Please enter your name in the code");
			System.exit(1);
		}
		String key = "Java_" + yourname;

		// Get parameters from dish.json
		JsonNode config = new ObjectMapper().readTree(new File("dish.json")).get("dhis");
		URL url = new URL(config.get("baseurl").asText() + 
				  "/api/dataStore/assignments/organisationUnitLevels");
		String auth = new String(new Base64().encode((
				config.get("username").asText() + ":" + 
				config.get("password").asText()
			).getBytes()));

		// Get the current JSON from the organisationUnitLevels key of the assignments namespace 
		// in the data store
		HttpURLConnection connection = (HttpURLConnection) (url.openConnection());
		connection.setRequestProperty("Authorization", "Basic " + auth);
		connection.setRequestProperty("Accept", "application/json");
		connection.setRequestMethod("GET");

		if(connection.getResponseCode() != 200){
			System.err.println("Expected 200 when reading data store, instead got " + 
				connection.getResponseCode());
			System.exit(1);
		}

		ObjectNode firstJson = (ObjectNode)new ObjectMapper().readTree(connection.getInputStream());

		// Construct a new JSON from the current JSON, adding a new key and resorting it
		ObjectNode newCountry = firstJson.get("Angola").deepCopy();

		newCountry.put("name3", key);
		firstJson.set(key, newCountry);

		TreeSet<String> keys = new TreeSet<String>();

		firstJson.fieldNames().forEachRemaining(keys::add);

		ObjectNode secondJson = new ObjectMapper().createObjectNode();

		for(String k : keys) 
			secondJson.set(k, firstJson.get(k));

		// Replace the old JSON with the new JSON
		connection = (HttpURLConnection) (url.openConnection());
		connection.setRequestProperty("Authorization", "Basic " + auth);
		connection.setRequestProperty("Content-type", "application/json");
		connection.setRequestMethod("PUT");
		connection.setDoOutput(true);
		OutputStream os = connection.getOutputStream();
		os.write(secondJson.toString().getBytes(Charset.forName("UTF-8")));
		os.close();

		// Report completion and exit with status 0
		if(connection.getResponseCode() != 200){
			System.err.println("Expected 200 when putting to data store, instead got " + 
				connection.getResponseCode());
			System.exit(1);
		} else {
			System.out.println("Exiting normally");
			System.exit(0);
		}
	}
}