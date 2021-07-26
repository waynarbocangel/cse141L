import java.io.*;
import java.util.Scanner;
import java.util.HashMap;

/**
 * Assembler class definition
 * Uses file assembly.txt and translates it into machine code
 * and then stores the machine code into a machine_code.txt
 * file.
 */ 
public class Assembler{
	public static void main (String[] args){
		try {
			FileInputStream assemblyCode = new FileInputStream("assembly.txt");
			Scanner assemblyScanner = new Scanner(assemblyCode);
			Parser instructionParser = new Parser();
			String machineCodeText = "";
			int lineCounter = 1;
			while (assemblyScanner.hasNextLine()){
				String currentInstruction = instructionParser.parse(assemblyScanner.nextLine(), lineCounter);
				if (!Character.isDigit(currentInstruction.charAt(0))){
					assemblyScanner.close();
					throw new Exception(currentInstruction);
				}
				if (!currentInstruction.equals("")){
					if (assemblyScanner.hasNextLine()){
						machineCodeText = machineCodeText + currentInstruction + "\n";
					} else {
						machineCodeText = machineCodeText + currentInstruction;
					}
				} else {
					lineCounter--;
				}

				lineCounter++;
			}
			assemblyScanner.close();
			File machineCodeFile = new File("machine_code.txt");
			machineCodeFile.createNewFile();
			FileWriter machineCodeWriter = new FileWriter("machine_code.txt");
			machineCodeWriter.write(machineCodeText);
			machineCodeWriter.close();
		} catch (Exception e) {
			System.err.println(e.getMessage());
		}
	}
}

class Parser{

	private HashMap<String, Integer> labelTracker = new HashMap<String, Integer>();

	public Parser(){}

	public String parse(String assemblyString, int lineNumber){
		String[] instructionComponents = assemblyString.split("\\W+");
		if (instructionComponents[0].equals("bne")) {
			return translateBranch(instructionComponents);
		} else if (instructionComponents[0].equals("st")) {
			return translateSetSpecial(instructionComponents);
		} else if (instructionComponents[0].equals("ls")) {
			return translateLoadStore(instructionComponents);
		} else if (instructionComponents[0].equals("add") || instructionComponents[0].equals("sub") 
		|| instructionComponents[0].equals("div") || instructionComponents[0].equals("mult")) {
			return translateArithmetic(instructionComponents);
		} else {
			labelTracker.put(instructionComponents[0], lineNumber);
			return "";
		}
	}

	private String translateArithmetic(String[] components){
		try {
			if (components.length != 3){
				return "Error Invalid Arithmetic Instruction: all arithmetic instructions must have two parameters";
			}

			String opCode = getArithmeticOpcode(components[0]);
			int parameter1Value = Integer.parseInt(components[1]);
			int parameter2Value = Integer.parseInt(components[2]);
			if (parameter2Value > 3 || parameter2Value < -4){
				System.out.println("Immediate warning! Your second parameter could overflow if it is an immediate");
			}
			String parameter1 = "000" + Integer.toBinaryString(parameter1Value);
			parameter1 = parameter1.substring(parameter1.length() - 3);
			String parameter2 = "000" + Integer.toBinaryString(parameter2Value);
			parameter2 = parameter2.substring(parameter2.length() - 3);
			return opCode + parameter1 + parameter2;

		} catch (Exception e) {
			return "Error Invalid Arithmetic Instruction: one of the parameters contained a letter";
		}
	}

	private String translateLoadStore(String[] components){
		try {
			if (components.length != 3){
				return "Error Invalid Load/Store Instruction: all load/store instructions must have two parameters";
			}

			String opCode = "000";
			int parameter1Value = Integer.parseInt(components[1]);
			int parameter2Value = Integer.parseInt(components[2]);
			if (parameter2Value > 3 || parameter2Value < -4){
				return "Error Overflow in Load/Store Instruction: your second parameter has overflowed";
			}
			String parameter1 = "000" + Integer.toBinaryString(parameter1Value);
			parameter1 = parameter1.substring(parameter1.length() - 3);
			String parameter2 = "000" + Integer.toBinaryString(parameter2Value);
			parameter2 = parameter2.substring(parameter2.length() - 3);
			return opCode + parameter1 + parameter2;

		} catch (Exception e) {
			return "Error Invalid Load/Store Instruction: one of the parameters contained a letter";
		}
	}

	private String translateSetSpecial(String[] components){
		try {
			if (components.length != 2){
				return "Error Invalid Set Instruction: all set instructions must have one parameter";
			}

			String opCode = "001";
			int parameterValue = Integer.parseInt(components[1]);
			if (parameterValue > 31 || parameterValue < -32){
				return "Error Overflow in Set Instruction: your parameter has overflowed";
			}
			String parameter = "000000" + Integer.toBinaryString(parameterValue);
			parameter = parameter.substring(parameter.length() - 6);
			return opCode + parameter;

		} catch (Exception e) {
			return "Error Invalid Set Instruction: the parameter contained a letter";
		}
	}

	private String translateBranch(String[] components){
		if (components.length != 2){
			return "Error Invalid Branch Instruction: all set instructions must have one parameter";
		}

		String opCode = "110";
		String parameter = components[1];
		if (labelTracker.containsKey(parameter)){
			Integer referencedLine = labelTracker.get(parameter);
			if (parameterValue > 31 || parameterValue < -32){
				return "Error Overflow in Branch Instruction: your parameter has overflowed";
			}
			parameter = "000000" + Integer.toBinaryString(referencedLine);
			parameter = parameter.substring(parameter.length() - 6);
		} else {
			return "Error Unspecified Label in Branch Instruction: the given label does not exist or has not been defined before this branch instruction";
		}
		return opCode + parameter;
	}

	private String getArithmeticOpcode(String instruction){
		if (instruction.equals("add")) {
			return "010";
		} else if (instruction.equals("sub")) {
			return "011";
		} else if (instruction.equals("div")) {
			return "101";
		} else if (instruction.equals("mult")) {
			return "100";
		} else {
			return "Invalid arithmetic operation";
		}
	}
}
