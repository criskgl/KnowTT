package edu.ucsb.cs176b;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Note{
	private String creationTime;
	private double latitude;
	private double longitude;
	private String message;
	private String userId;

	public Note(){
		this.latitude = 0.0;
		this.longitude = 0.0;
		this.message = "";
		this.creationTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
		this.userId = "";
	}

	public Note(double latitude, double longitude, String message, String userId){
		this.latitude=latitude;
		this.longitude=longitude;
		this.message=message;
		this.creationTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
		this.userId = userId;
	}

	public Note(double latitude, double longitude, String message, String creationTime, String userId){
		this.latitude=latitude;
		this.longitude=longitude;
		this.message=message;
		this.creationTime = creationTime;
		this.userId = userId;
	}

	public double getLatitude(){
		return this.latitude;
	}

	public void setLatitude(double latitude){
		this.latitude=latitude;
	}

	public double getLongitude(){
		return this.longitude;
	}

	public void setLongitude(double longitude){
		this.longitude=longitude;
	}

	public String getMessage(){
		return this.message;
	}

	public void setMessage(String message){
		this.message=message;
	}

	public String getUserId(){
		return this.userId;
	}

	public void setUserId(String userId){
		this.userId=userId;
	}

	public String getCreationTime(){
		return this.creationTime;
	}

	public void setCreationTime(String creationTime){
		this.creationTime=creationTime;
	}

	@Override
	public String toString(){
		return "Latitude: " + latitude
			+ "\nLongitude: " + longitude
			+ "\nMessage:\n\t"+ message
			+ "\nCreation time: " + creationTime + "\n";
	}
}
