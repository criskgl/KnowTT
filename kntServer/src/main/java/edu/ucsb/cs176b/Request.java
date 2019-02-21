package edu.ucsb.cs176b;

public class Request{
	String opCode;	//SEND,CONNECT,DISCONNECT,REGISTER,UNREGISTER,GET
	String userId;
	String latitude;
	String longitude;
	String message;

	public Request(String opCode, String userId, String latitude, String longitude, String message){
		this.opCode = opCode;
		this.userId = userId;
		this.latitude = latitude;
		this.longitude = longitude;
		this.message = message;
	}
}
