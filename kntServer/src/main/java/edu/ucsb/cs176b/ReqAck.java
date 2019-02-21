package edu.ucsb.cs176b;

public class ReqAck{
	private String opCode;
	private String result;

	public ReqAck(String opCode, String result){
		this.opCode = opCode;
		this.result = result;
	}

	public String getOpCode(){
		return this.opCode;
	}

	public String getResult(){
		return this.result;
	}
}
