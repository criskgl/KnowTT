/*
Client
*/
package edu.ucsb.cs176b;

import java.io.*;
import java.net.*;
import java.util.Arrays;
import java.util.Scanner;
import com.google.gson.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

// Client class
public class Client {


	public static void main(String[] args) throws IOException {

		//Client attributes
		String clientId = "";
		boolean connected = false;
		String latitude = "0.0";
		String longitude = "9.9";

		//Message passing aux variables
		String op;
		String userName;
		String reqAck_s;
		ReqAck reqAck;
		Request myRequest;
		String note_s;
		Note note;
		String message="";

		String[] myNoteSet;

		byte[] bufr = new byte[1024];


		try {
			Scanner scn = new Scanner(System.in);

			// getting localhost ip
			InetAddress ip = InetAddress.getByName("localhost");

			// establish the connection with server port 5056
			Socket s = new Socket(ip, 5056);

			// obtaining input and out streams
			DataInputStream dis = new DataInputStream(s.getInputStream());
			DataOutputStream dos = new DataOutputStream(s.getOutputStream());

			Gson gson = new Gson();

			System.out.println("\nWELCOME TO KNOWT");

			// the following loop performs the exchange of
			// information between client and client handler
			while (true) {
				Arrays.fill(bufr, (byte)0);
				//System.out.println(dis.readUTF());
				System.out.print("\nCommand list:\nr to REGISTER - u to UNREGISTER - c to CONNECT - d to DISCONNECT - p to POST - g to GET - Exit to EXIT\n> ");
				op = scn.nextLine();

				// If client sends exit,close this connection
				// and then break from the while loop
				if(op.equals("Exit")) {
					myRequest = new Request("EXIT",clientId,"","","");
					dos.write(gson.toJson(myRequest).getBytes());	//Send request

					System.out.println("Closing this connection : " + s);
					s.close();
					System.out.println("Connection closed");
					break;
				}

				switch(op){
					case "r":
						if(!clientId.equals("")){
							System.out.println("[ERROR] You are already registered");
							break;
						}

						System.out.print("Insert your user name\n> ");
						userName = scn.nextLine();
						myRequest = new Request("REGISTER",userName,"","","");
						dos.write(gson.toJson(myRequest).getBytes());	//Send request

						// printing date or time as requested by client
						dis.read(bufr);
						reqAck_s = new String(bufr);
						reqAck = gson.fromJson(reqAck_s.trim(),ReqAck.class);

						if(reqAck.getResult().equals("ACK")){
							clientId = userName;
							System.out.println("Register success");
						}
						else{	//TODO: Consider different errors
							System.out.println("[ERROR] Error registering user name");
						}

					break;
					case "u":
						if(clientId.equals("")){
							System.out.println("[ERROR] You are not registered yet");
							break;
						}

						myRequest = new Request("UNREGISTER",clientId,"","","");
						dos.write(gson.toJson(myRequest).getBytes());	//Send request

						// printing date or time as requested by client
						dis.read(bufr);
						reqAck_s = new String(bufr);
						reqAck = gson.fromJson(reqAck_s.trim(),ReqAck.class);

						if(reqAck.getResult().equals("ACK")){
							clientId = "";
							System.out.println("Unregister success");
						}
						else{	//TODO: Consider different errors
							System.out.println("[ERROR] Error unregistering");
						}

					break;
					case "c":

						if(connected){
							System.out.println("[ERROR] Already Connected");
							break;
						}

						myRequest = new Request("CONNECT",clientId,"","","");
						dos.write(gson.toJson(myRequest).getBytes());	//Send request

						// printing date or time as requested by client
						dis.read(bufr);
						reqAck_s = new String(bufr);
						reqAck = gson.fromJson(reqAck_s.trim(),ReqAck.class);

						if(reqAck.getResult().equals("ACK")){
							connected = true;
							System.out.println("Connection success");
						}
						else{	//TODO: Consider different errors
							System.out.println("[ERROR] Error connecting");
						}

					break;
					case "d":

						if(!connected){
							System.out.println("[ERROR] Already Disconnected");
							break;
						}

						myRequest = new Request("DISCONNECT",clientId,"","","");
						dos.write(gson.toJson(myRequest).getBytes());	//Send request

						// printing date or time as requested by client
						dis.read(bufr);
						reqAck_s = new String(bufr);
						reqAck = gson.fromJson(reqAck_s.trim(),ReqAck.class);

						if(reqAck.getResult().equals("ACK")){
							connected=false;
							System.out.println("Disonnection success");
						}
						else{	//TODO: Consider different errors
							System.out.println("[ERROR] Error disconnecting");
						}

					break;
					case "p":
						if(!connected || clientId.equals("")){
							System.out.println("[ERROR] Not registered or connected");
							break;
						}

						System.out.print("Type the message of your note\n> ");
						message = scn.nextLine();

						myRequest = new Request("POST",clientId,latitude,longitude,message);
						dos.write(gson.toJson(myRequest).getBytes());	//Send request

						// printing date or time as requested by client
						dis.read(bufr);
						reqAck_s = new String(bufr);
						reqAck = gson.fromJson(reqAck_s.trim(),ReqAck.class);

						if(reqAck.getResult().equals("ACK")){
							System.out.println("Sending success");
						}
						else{	//TODO: Consider different errors
							System.out.println("[ERROR] Error sending note");
						}
					break;
					case "g":
						if(!connected || clientId.equals("")){
							System.out.println("[ERROR] Not registered or connected");
							break;
						}

						myRequest = new Request("GET",clientId,latitude,longitude,message);
						dos.write(gson.toJson(myRequest).getBytes());	//Send request

						// printing date or time as requested by client
						note = new Note();
						dis.read(bufr);
						note_s = new String(bufr);
						myNoteSet = note_s.split("(?<=})");

						for (String a : myNoteSet){
							try{
								note = gson.fromJson(a,Note.class);
								System.out.println(note);
							}
							catch(Exception e){

							}
						}


						while(!note.getMessage().equals("[END]")){	//TODO: CHANGE CODE AND PREVENT USER FROM WRITTING THIS MESSAGE

							dis.read(bufr);
							note_s = new String(bufr);	//Get next note

							myNoteSet = note_s.split("(?<=})");
							for (String a : myNoteSet){
								try{
									note = gson.fromJson(a,Note.class);
									System.out.println(note);
								}
								catch(Exception e){

								}
							}

						}

						System.out.println("END");
					break;
					default:
						System.out.println("[ERROR] Unknown command\n");
				}


				//Test request
				//String jsonTest = "{\"latitude\": -23.1102, \"longitude\": 12.345, \"message\": \"test message\", \"creationTime\": \"" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("MM-dd-yyyy HH:mm:ss.SSS")) +"\"}";

			}

			// closing resources
			scn.close();
			dis.close();
			dos.close();
		}catch(Exception e){
			e.printStackTrace();
		}
	}
}
