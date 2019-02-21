package edu.ucsb.cs176b;

public class Note{
	private double GPSLocationLatitude;
	private double GPSLocationLongitude;
	private String message;
	private int timeTillDestroy;

	public Note(){
		GPSLocationLatitude=0.0;
		GPSLocationLongitude=0.0;
		message="";
		timeTillDestroy=0;
	}

	public Note(double GPSLocationLatitude, double GPSLocationLongitude, String message, int timeTillDestroy){
		this.GPSLocationLatitude=GPSLocationLatitude;
		this.GPSLocationLongitude=GPSLocationLongitude;
		this.message=message;
		this.timeTillDestroy=timeTillDestroy;
	}

	public double getGPSLocationLatitude(){
		return this.GPSLocationLatitude;
	}

	public void setGPSLocationLatitude(double GPSLocationLatitude){
		this.GPSLocationLatitude=GPSLocationLatitude;
	}

	public double getGPSLocationLongitude(){
		return this.GPSLocationLongitude;
	}

	public void setGPSLocationLongitude(double GPSLocationLongitude){
		this.GPSLocationLongitude=GPSLocationLongitude;
	}

	public String getMessage(){
		return this.message;
	}

	public void setMessage(String message){
		this.message=message;
	}

	public int getTimeTillDestroy(){
		return this.timeTillDestroy;
	}

	public void setTimeTillDestroy(int timeTillDestroy){
		this.timeTillDestroy=timeTillDestroy;
	}
}
