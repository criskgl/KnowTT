package edu.ucsb.cs176b;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Note{
	private String creationTime;
	private double latitude;
	private double longitude;
	private String message;

	public Note(){
		latitude = 0.0;
		longitude = 0.0;
		message = "";
		creationTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("MM-dd-yyyy HH:mm:ss.SSS"));
	}

	public Note(double latitude, double longitude, String message){
		this.latitude=latitude;
		this.longitude=longitude;
		this.message=message;
		creationTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("MM-dd-yyyy HH:mm:ss.SSS"));
	}

	public double getlatitude(){
		return this.latitude;
	}

	public void setlatitude(double latitude){
		this.latitude=latitude;
	}

	public double getlongitude(){
		return this.longitude;
	}

	public void setlongitude(double longitude){
		this.longitude=longitude;
	}

	public String getMessage(){
		return this.message;
	}

	public void setMessage(String message){
		this.message=message;
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
