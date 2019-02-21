/*
* Server
*/
package edu.ucsb.cs176b;

import java.io.*;
import java.text.*;
import java.util.*;
import java.net.*;
//import com.google.gson.Gson;

//Server class
public class Server{

	public static void main(String[] args) throws IOException{

		ServerSocket ss = new ServerSocket(5057);

		while(true){
			Socket s = null;

			try{
				//Accept connection
				s = ss.accept();

				System.out.println("A new client is connected : " + s);

				// obtaining input and out streams
				DataInputStream dis = new DataInputStream(s.getInputStream());
				DataOutputStream dos = new DataOutputStream(s.getOutputStream());

				System.out.println("Assigning new thread for this client");

				// create a new thread object
				Thread t = new ClientHandler(s, dis, dos);

				// Invoking the start() method
				t.start();

			}
			catch(Exception e){
				s.close();
				e.printStackTrace();
			}
		}
	}
}

// ClientHandler class
class ClientHandler extends Thread {

	//DateFormat fordate = new SimpleDateFormat("yyyy/MM/dd");
	//DateFormat fortime = new SimpleDateFormat("hh:mm:ss");
	final DataInputStream dis;
	final DataOutputStream dos;
	final Socket s;


	// Constructor
	public ClientHandler(Socket s, DataInputStream dis, DataOutputStream dos){
		this.s = s;
		this.dis = dis;
		this.dos = dos;
	}

	@Override
	public void run() {
		String received;
		String toreturn;
		while (true){
			try {

				// Ask user what he wants
				dos.writeUTF("HELLO WORLD! Escribete algo\n");

				// receive the answer from client
				received = dis.readUTF();

				if(received.equals("Exit")) {
					System.out.println("Client " + this.s + " sends exit...");
					System.out.println("Closing this connection.");
					this.s.close();
					System.out.println("Connection closed");
					break;
				}

				System.out.println(received);

				dos.writeUTF("GOOOOOTEEEEEEM\n");

				// creating Date object
				//Date date = new Date();

				// write on output stream based on the
				// answer from the client
				/*switch (received) {

					case "deez nuts" :
						//toreturn = fordate.format(date);
						dos.writeUTF("Go for it my man. Tell me the name of the file.");
						break;

					case "n" :
						//toreturn = fortime.format(date);
						dos.writeUTF("Such a badasss");
						break;
					case "json" :
						//toreturn = fortime.format(date);
						dos.writeUTF("Such a badasss");
						break;
					default:
						dos.writeUTF("Invalid input");
						break;
				}*/

			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		try {
			// closing resources
			this.dis.close();
			this.dos.close();

		}catch(IOException e){
			e.printStackTrace();
		}
	}
}
