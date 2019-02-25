package edu.ucsb.cs176b;

import java.util.*;
import java.lang.*;
import java.sql.*;
import java.text.SimpleDateFormat;

public class DBHandler {
	private Connection connect = null;
	private Statement statement = null;
	private PreparedStatement preparedStatement = null;
	private ResultSet resultSet = null;

	public List<Note> getNotes(double userLat, double userLon) throws Exception{
		List<Note> noteSet = new ArrayList<Note>();

		try {
			//Class.forName("com.mysql.cj.jdbc.Driver");
			connect = DriverManager
					.getConnection("jdbc:mysql://localhost/kntDB?"
					+ "user=kntadmin&password=");

			statement = connect.createStatement();

			resultSet = statement.executeQuery("SELECT * FROM kntDB.notes WHERE (latitude BETWEEN "
			+(userLat-0.0001)+" AND "+(userLat+0.0001)+
			") AND (longitude BETWEEN "+(userLon-0.0001)+" AND "+(userLon+0.0001)+")");

			noteSet = writeResultSet(resultSet);
		}
		catch (Exception e){
			throw e;
		}
		finally{
			close();
			return noteSet;
		}
	}

	public void insertNote(Note note) throws Exception{
		try {
			//Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager
					.getConnection("jdbc:mysql://localhost/kntDB?"
					+ "user=kntadmin&password=&&serverTimezone=UTC");

			preparedStatement = connect.prepareStatement("INSERT INTO kntDB.notes VALUES"+
								"(default, ?, ?, ?, ?, ?)");
			System.out.println(note.getCreationTime());
			preparedStatement.setString(1,note.getUserId());
			preparedStatement.setDouble(2,note.getLatitude());
			preparedStatement.setDouble(3,note.getLongitude());
			preparedStatement.setString(4,note.getMessage());
			preparedStatement.setString(5,note.getCreationTime());
			preparedStatement.executeUpdate();
		}
		catch (Exception e){
			throw e;
		}
		finally{
			close();
		}
	}

	public void registerUser(User user) throws Exception{
		try {
			//Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager
					.getConnection("jdbc:mysql://localhost/kntDB?"
					+ "user=kntadmin&password=&&serverTimezone=UTC");

			preparedStatement = connect.prepareStatement("INSERT INTO kntDB.users VALUES"+
								"(?, ?)");
			preparedStatement.setString(1,user.getUserId());
			preparedStatement.setBoolean(2,user.getConnected());
			preparedStatement.executeUpdate();
		}
		catch (Exception e){
			throw e;
		}
		finally{
			close();
		}
	}

	private List<Note> writeResultSet(ResultSet resultSet) throws SQLException{
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		List<Note> result = new ArrayList<Note>();

		while(resultSet.next()){
			String userId = resultSet.getString("user_id");
			double latitude = resultSet.getDouble("latitude");
			double longitude = resultSet.getDouble("longitude");
			String message = resultSet.getString("message");
			String creationTime = dateFormat.format(resultSet.getTimestamp("creation_time"));

			result.add(new Note(latitude, longitude, message, creationTime, userId));
		}
		return result;
	}

	private void close() {
		try {
			if (resultSet != null) {
				resultSet.close();
			}

			if (statement != null) {
				statement.close();
			}

			if (connect != null) {
				connect.close();
			}
		} catch (Exception e) {
		}
	}

}
