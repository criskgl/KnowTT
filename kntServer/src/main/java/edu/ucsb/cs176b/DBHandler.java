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

	public void getNotes(double userLat, double userLon, List<Note> result) throws Exception{

		try {
			//Class.forName("com.mysql.cj.jdbc.Driver");
			connect = DriverManager
					.getConnection("jdbc:mysql://localhost/kntDB?"
					+ "user=kntadmin&password=&&serverTimezone=UTC");

			String query = "SELECT * FROM kntDB.notes WHERE (latitude BETWEEN ? AND ? ) AND (longitude BETWEEN ? AND ? )";
			preparedStatement = connect.prepareStatement(query);
			preparedStatement.setDouble(1,(userLat-0.0001));
			preparedStatement.setDouble(2,(userLat+0.0001));
			preparedStatement.setDouble(3,(userLon-0.0001));
			preparedStatement.setDouble(4,(userLon+0.0001));

			ResultSet rs = preparedStatement.executeQuery();

			writeResultSet(rs,result);
		}
		catch (Exception e){
			throw e;
		}
		finally{
			close();
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


	public void unregisterUser(String userId) throws Exception{
		try {
			//Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager
					.getConnection("jdbc:mysql://localhost/kntDB?"
					+ "user=kntadmin&password=&&serverTimezone=UTC");

			preparedStatement = connect.prepareStatement("DELETE FROM kntDB.users WHERE user_id="+
			"(?)");
			preparedStatement.setString(1,userId);
			preparedStatement.executeUpdate();
		}
		catch (Exception e){
			throw e;
		}
		finally{
			close();
		}
	}

	public void connectUser(String userId) throws Exception{
		try {
			//Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager
					.getConnection("jdbc:mysql://localhost/kntDB?"
					+ "user=kntadmin&password=&&serverTimezone=UTC");

			preparedStatement = connect.prepareStatement("UPDATE kntDB.users SET connected="+
								"(?)"+"WHERE user_id="+"(?)");
			preparedStatement.setBoolean(1,true);
			preparedStatement.setString(2,userId);
			preparedStatement.executeUpdate();
		}
		catch (Exception e){
			throw e;
		}
		finally{
			close();
		}
	}

	public boolean isConnected(String userId) throws Exception{
		try {
			//Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager
					.getConnection("jdbc:mysql://localhost/kntDB?"
					+ "user=kntadmin&password=&&serverTimezone=UTC");

			String query = "SELECT connected FROM kntDB.users WHERE user_id = ?";

			preparedStatement = connect.prepareStatement(query);
			preparedStatement.setString(1,userId);

			ResultSet rs = preparedStatement.executeQuery();
			rs.next();
			return rs.getObject(1, Boolean.class);
		}
		catch (Exception e){
			throw e;
		}
		finally{
			close();
		}
	}

	public void disconnectUser(String userId) throws Exception{
		try {
			//Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager
					.getConnection("jdbc:mysql://localhost/kntDB?"
					+ "user=kntadmin&password=&&serverTimezone=UTC");

			preparedStatement = connect.prepareStatement("UPDATE kntDB.users SET connected="+
								"(?)"+"WHERE user_id="+"(?)");
			preparedStatement.setBoolean(1,false);
			preparedStatement.setString(2,userId);
			preparedStatement.executeUpdate();
		}
		catch (Exception e){
			throw e;
		}
		finally{
			close();
		}
	}

	private void writeResultSet(ResultSet resultSet, List<Note> result) throws SQLException{
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		while(resultSet.next()){
			String userId = resultSet.getObject(2,String.class);
			double latitude = resultSet.getObject(3,Double.class);
			double longitude = resultSet.getObject(4,Double.class);
			String message = resultSet.getObject(5,String.class);
			String creationTime = dateFormat.format(resultSet.getTimestamp("creation_time"));
			result.add(new Note(latitude, longitude, message, creationTime, userId));
		}
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
