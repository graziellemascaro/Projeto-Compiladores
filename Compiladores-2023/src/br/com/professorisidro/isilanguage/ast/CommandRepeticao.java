package br.com.professorisidro.isilanguage.ast;

import java.util.ArrayList;

import br.com.professorisidro.isilanguage.datastructures.IsiVariable;

public class CommandRepeticao extends AbstractCommand {
	
	private String condition;
	private ArrayList<AbstractCommand> listaTrue;
	private int n;
	// N == 1 = WHILE
	// N == 2 = DO WHILE
	
	public CommandRepeticao(String condition, ArrayList<AbstractCommand> lt, int n) {
		this.condition = condition;
		this.listaTrue = lt;
		this.n = n;
	}
	
	@Override
	public String generateJavaCode() {
		// TODO Auto-generated method stub
		
		if(n==1) {
			
			StringBuilder str = new StringBuilder();
			str.append("while ("+condition+") {\n");
			for (AbstractCommand cmd: listaTrue) {
				str.append(cmd.generateJavaCode());
			}
			str.append("\n}\n");
			return str.toString();
			
		} else {
			
			StringBuilder str = new StringBuilder();
			str.append("do {\n");
			for (AbstractCommand cmd: listaTrue) {
				str.append(cmd.generateJavaCode());
			}
			str.append("\n} ");
			str.append("while ("+condition+");\n");
			return str.toString();
			
		}
	}
	@Override
	public String toString() {
		if(n==1) {
			return "CommandRepeticao WHILE [condition=" + condition + ", listaTrue=" + listaTrue +"]";
		} else {
			return "CommandRepeticao DO WHILE [condition=" + condition + ", listaTrue=" + listaTrue +"]";
		}
	}

}
