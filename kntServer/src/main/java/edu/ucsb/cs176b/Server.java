/*
* Server
*/
package edu.ucsb.cs176b;

import java.io.*;
import java.text.*;
import java.util.*;
import java.net.*;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

//Server class
public class Server{


	public static void main(String[] args) throws IOException{

		ServerSocket ss = new ServerSocket(5056);

		//MOCK databases
		List<Note> notesDB = Collections.synchronizedList(new ArrayList<Note>());
		List<User> usersDB = Collections.synchronizedList(new ArrayList<User>());

		while(true){
			Socket s = null;

			try{
				//System.out.println(LocalDateTime.now().format(DateTimeFormatter.ofPattern("MM-dd-yyyy HH:mm:ss.SSS")));
				//Accept connection
				s = ss.accept();

				System.out.println("A new client is connected : " + s);

				// obtaining input and out streams
				DataInputStream dis = new DataInputStream(s.getInputStream());
				DataOutputStream dos = new DataOutputStream(s.getOutputStream());

				System.out.println("Assigning new thread for this client");

				// create a new thread object
				Thread t = new ClientHandler(s, dis, dos, notesDB, usersDB);

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
	List<Note> notesDB;
	List<User> usersDB;

	DBHandler dbHandler = new DBHandler();


	// Constructor
	public ClientHandler(Socket s, DataInputStream dis, DataOutputStream dos, List<Note> notesDB, List<User> usersDB){
		this.s = s;
		this.dis = dis;
		this.dos = dos;
		this.notesDB = notesDB;
		this.usersDB = usersDB;
	}

	@Override
	public void run() {
		String received = "";
		String toreturn;

		Request request;
		ReqAck reqAck = new ReqAck();

		int user_i;
		int note_i;

		byte[] bufr = new byte[1024];
		String bufs = "";

		Gson gson = new Gson();

		while (true){
			try {
				Arrays.fill(bufr, (byte)0);
				bufs = "";
				// Ask user what he wants
				//dos.writeUTF("HOLA\n");

				// receive the answer from client
				//received = dis.readUTF();
				//TODO: Case when it's not a good formatted request
				dis.read(bufr);
				bufs = new String(bufr);
				System.out.println(bufs);
				request = gson.fromJson(bufs.trim(), Request.class);
				System.out.println(gson.toJson(request));	//DELETE


				if(request.getOpCode().equals("EXIT")) {
					System.out.println("Client " + this.s + " sends exit...");
					System.out.println("Closing this connection.");
					this.s.close();
					System.out.println("Connection closed");
					break;
				}

				reqAck.setOpCode(request.getOpCode());
				user_i = getUserIndex(request.getUserId());
				System.out.println(request.getUserId() + "\tindex: " + user_i);

				switch(request.getOpCode()){
					case "REGISTER":
						if(user_i>=0){
							reqAck.setResult("ERROR");
						}
						else{	//Register
							try{
								usersDB.add(new User(request.getUserId(),false));
								dbHandler.registerUser(new User(request.getUserId(),false));
								reqAck.setResult("ACK");
							}
							catch(Exception e){
								System.out.println(e);
								reqAck.setResult("ERROR");
							}
						}

					break;
					case "UNREGISTER":
						if(user_i<0){
							reqAck.setResult("ERROR");
						}
						else{
							usersDB.remove(user_i);
							reqAck.setResult("ACK");
						}
					break;
					case "CONNECT":
						if(user_i<0){	//Not registered
							reqAck.setResult("ERROR");
						}
						else if(usersDB.get(user_i).getConnected()){	//Already connected
							reqAck.setResult("ERROR");
						}
						else{
							usersDB.get(user_i).setConnected(true);
							reqAck.setResult("ACK");
						}
					break;
					case "DISCONNECT":
						System.out.println("1");
						if(user_i<0){	//Not registered
							reqAck.setResult("ERROR");
						}
						else if(!usersDB.get(user_i).getConnected()){	//Already disconnected
							reqAck.setResult("ERROR");
						}
						else{
							System.out.println("2");
							usersDB.get(user_i).setConnected(false);
							reqAck.setResult("ACK");
						}
					break;
					case "POST":
						if(user_i<0){
							reqAck.setResult("ERROR");
						}
						else if(!usersDB.get(user_i).getConnected()){	//Disconnected
							reqAck.setResult("ERROR");
						}
						else{
							notesDB.add(new Note(Double.parseDouble(request.getLatitude()),Double.parseDouble(request.getLongitude()),request.getMessage(),request.getUserId()));
							try{
								dbHandler.insertNote(new Note(Double.parseDouble(request.getLatitude()),Double.parseDouble(request.getLongitude()),request.getMessage(),request.getUserId()));
								reqAck.setResult("ACK");
							}
							catch (Exception e){
								reqAck.setResult("ERROR");
								System.out.println(e);
							}
						}
					break;
					case "GET":
						if(user_i<0){
							reqAck.setResult("ERROR");
						}
						else if(!usersDB.get(user_i).getConnected()){	//Disconnected
							reqAck.setResult("ERROR");
						}
						else{
							for(Note note : notesDB){
								dos.write(gson.toJson(note).getBytes());
							}
							dos.write(gson.toJson(new Note(0.0,0.0,"[END]","")).getBytes());
						}
					break;
					default:
						System.out.println("[ERROR] Unknown operation code");
				}

				//System.out.println(received);
				//Note newNote = new Note();
				//Note newNote = gson.fromJson(received, Note.class);
				//System.out.println(newNote);
				if(!request.getOpCode().equals("GET"))
					dos.write(gson.toJson(reqAck).getBytes());

				// creating Date object
				//Date date = new Date();

				// write on output stream based on the
				// answer from the client


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


	//METHODS

	//Return index. -1 if not present
	public int getUserIndex(String id){	//HASH TABLES

		for(int i = 0; i<usersDB.size();i++){
			if(usersDB.get(i).getUserId().equals(id)) return i;
		}

		return -1;
	}



}
