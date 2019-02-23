package edu.ucsb.cs176b;

import java.util.List;

public class User{
	private String userId;
	private boolean connected;
	private List<Note> myNotes;

	public User(){
		this.userId="0";
		this.connected=false;
	}

	public User(String userId, boolean connected){
		this.userId=userId;
		this.connected=connected;
	}

	public String getUserId(){
		return this.userId;
	}

	public boolean getConnected(){
		return this.connected;
	}

	public void setUserId(String userId){
		this.userId = userId;
	}

	public void setConnected(boolean connected){
		this.connected = connected;
	}
}
