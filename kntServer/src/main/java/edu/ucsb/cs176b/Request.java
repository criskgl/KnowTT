package edu.ucsb.cs176b;

public class Request{
	private String latitude;
	private String longitude;
	private String message;
	private String opCode;	//SEND,CONNECT,DISCONNECT,REGISTER,UNREGISTER,GET
	private String userId;

	public Request(){
		this.opCode = "";
		this.userId = "";
		this.latitude = "";
		this.longitude = "";
		this.message = "";
	}

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

	public String getUserId(){
		return this.userId;
	}

	public String getLatitude(){
		return this.latitude;
	}

	public String getLongitude(){
		return this.longitude;
	}

	public String getMessage(){
		return this.message;
	}
}
