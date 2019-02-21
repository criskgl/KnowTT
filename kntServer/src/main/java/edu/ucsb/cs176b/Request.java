package edu.ucsb.cs176b;

public class Request{
	private String opCode;	//SEND,CONNECT,DISCONNECT,REGISTER,UNREGISTER,GET
	private String userId;
	private String latitude;
	private String longitude;
	private String message;

	public Request(String opCode, String userId, String latitude, String longitude, String message){
		this.opCode = opCode;
		this.userId = userId;
		this.latitude = latitude;
		this.longitude = longitude;
		this.message = message;
	}

	public String getOpCode(){
		return this.opCode;
	}
}
