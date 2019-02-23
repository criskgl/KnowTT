package edu.ucsb.cs176b;

public class ReqAck{
	private String opCode;
	private String result;

	public ReqAck(){
		this.opCode = "";
		this.result = "";
	}

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

	public void setOpCode(String opCode){
		this.opCode = opCode;
	}
	public void setResult(String result){
		this.result = result;
	}
}
