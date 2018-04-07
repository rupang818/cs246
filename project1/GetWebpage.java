import java.net.*;
import java.io.*;

public class GetWebpage {
  public static void main(String args[]) throws Exception {

      // args[0] has the URL passed as the command parameter.
      // You need to retrieve the webpage corresponding to the URL and print it out on console
      // Here, we simply printout the URL
  		try {
  			String address = args[0];
  			URL url = new URL(address);
  			URLConnection conn = url.openConnection();

  			BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));

  			String inputLine;
            while ((inputLine = br.readLine()) != null) {
                    System.out.println(inputLine);
            }
            br.close();

        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
