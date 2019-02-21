package edu.ucsb.cs176b;

import java.util.List;

public class User{
	private int userId;
	private boolean connected;
	private List<Note> myNotes;

	public User(){
		this.userId=0;
		this.connected=false;
	}

	public User(int userId, boolean connected){
		this.userId=userId;
		this.connected=connected;
	}

	public int getUserId(){
		return this.userId;
	}

	public boolean getConnected(){
		return this.connected;
	}

	public void setUserId(int userId){
		this.userId = userId;
	}

	public void setConnected(boolean connected){
		this.connected = connected;
	}
}
