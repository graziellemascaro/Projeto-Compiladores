grammar IsiLang;

@header{
	import br.com.professorisidro.isilanguage.datastructures.IsiSymbol;
	import br.com.professorisidro.isilanguage.datastructures.IsiVariable;
	import br.com.professorisidro.isilanguage.datastructures.IsiSymbolTable;
	import br.com.professorisidro.isilanguage.exceptions.IsiSemanticException;
	import br.com.professorisidro.isilanguage.ast.IsiProgram;
	import br.com.professorisidro.isilanguage.ast.AbstractCommand;
	import br.com.professorisidro.isilanguage.ast.CommandLeitura;
	import br.com.professorisidro.isilanguage.ast.CommandEscrita;
	import br.com.professorisidro.isilanguage.ast.CommandAtribuicao;
	import br.com.professorisidro.isilanguage.ast.CommandDecisao;
	import br.com.professorisidro.isilanguage.ast.CommandRepeticao;
	import java.util.ArrayList;
	import java.util.Stack;
	import java.util.HashMap;
	import java.util.Set;
	import java.util.Hashtable;
}

@members{
	private int _tipo;
	private int TIPO;
	private String _varName;
	private String _varValue;
	private IsiSymbolTable symbolTable = new IsiSymbolTable();
	private IsiSymbol symbol;
	private IsiProgram program = new IsiProgram();
	private ArrayList<AbstractCommand> curThread;
	private Stack<ArrayList<AbstractCommand>> stack = new Stack<ArrayList<AbstractCommand>>();
	private String _readID;
	private String _writeID;
	private String _writeTEXT;
	private String _exprID;
	private String _exprContent;
	private String _exprDecision;
	private String _exprRep;
	private ArrayList<AbstractCommand> listaTrue;
	private ArrayList<AbstractCommand> listaFalse;
	private Hashtable<String, Boolean> temValorInicial = new Hashtable<String, Boolean>();
	private Hashtable<String, Boolean> variavelNaoUsada = new Hashtable<String, Boolean>();
	
	
	public void verificaID(String id){
		if (!symbolTable.exists(id)){
			throw new IsiSemanticException("Symbol "+id+" not declared");
		}
	}
	
	
	public void exibeComandos(){
		for (AbstractCommand c: program.getComandos()){
			System.out.println(c);
		}
	}
	
	public void generateCode(){
		program.generateTarget();
	}
}

prog	: 'programa' decl bloco  'fimprog;'
           {  program.setVarTable(symbolTable);
           	  program.setComandos(stack.pop());
           	  
           	  Set<String> keys = temValorInicial.keySet();
		        for(String key: keys){
		            System.out.println("WARNING! Variavel "+key+" sem valor inicial");
		        }
		        
		     keys = variavelNaoUsada.keySet();
		        for(String key: keys){
		            System.out.println("WARNING! Variavel "+key+" nao usada");
		        }
           	 
           } 
		;
		
decl    :  (declaravar)+
        ;
        
        
declaravar :  tipo ID  {
	                  _varName = _input.LT(-1).getText();
	                  _varValue = null;
	                  symbol = new IsiVariable(_varName, _tipo, _varValue);
	                  if (!symbolTable.exists(_varName)){
	                     symbolTable.add(symbol);	
	                     temValorInicial.put(_varName, false);
	                     variavelNaoUsada.put(_varName, false);
	                  }
	                  else{
	                  	 throw new IsiSemanticException("Symbol "+_varName+" already declared");
	                  }
                    } 
              (  VIR 
              	 ID {
	                  _varName = _input.LT(-1).getText();
	                  _varValue = null;
	                  symbol = new IsiVariable(_varName, _tipo, _varValue);
	                  if (!symbolTable.exists(_varName)){
	                     symbolTable.add(symbol);
	                     temValorInicial.put(_varName, false);
	                     variavelNaoUsada.put(_varName, false);
	                  }
	                  else{
	                  	 throw new IsiSemanticException("Symbol "+_varName+" already declared");
	                  }
                    }
              )* 
               SC
           ;
           
tipo       : 'numero'  { _tipo = IsiVariable.NUMBER;  }
           | 'texto'   { _tipo = IsiVariable.TEXT;    }
           | 'inteiro' { _tipo = IsiVariable.INTEIRO; }
           ;
        
bloco	: { curThread = new ArrayList<AbstractCommand>(); 
	        stack.push(curThread);  
          }
          (cmd)+
		;
		

cmd		:  cmdleitura  
 		|  cmdescrita 
 		|  cmdattrib
 		|  cmdselecao 
 		|  cmdrepeticao 
		;
		
cmdleitura	: 'leia' AP
                     ID { verificaID(_input.LT(-1).getText());
                     	  _readID = _input.LT(-1).getText();
                        } 
                     FP 
                     SC 
                     
              {
              	IsiVariable var = (IsiVariable)symbolTable.get(_readID);
              	CommandLeitura cmd = new CommandLeitura(_readID, var);
              	stack.peek().add(cmd);
              	if(temValorInicial.containsKey(_readID)) temValorInicial.remove(_readID);
              }   
			;
			
cmdescrita	: 'escreva' 
                 AP 
                 ( 
                 	ID { verificaID(_input.LT(-1).getText());
	                  _writeID = _input.LT(-1).getText();
                     } 
                 FP 
                 SC
               {
               	  CommandEscrita cmd = new CommandEscrita(_writeID);
               	  stack.peek().add(cmd);
               }
               
               |
               
               TEXTO {_writeTEXT = _input.LT(-1).getText();}
               FP
               SC
               {
               	CommandEscrita cmd = new CommandEscrita(_writeTEXT);
               	stack.peek().add(cmd);
               }
               
               )
			;
			
cmdattrib	:  ID { verificaID(_input.LT(-1).getText());
                    _exprID = _input.LT(-1).getText();
                    TIPO = ((IsiVariable) symbolTable.get(_input.LT(-1).getText())).getType();
                    if(temValorInicial.containsKey(_exprID)) temValorInicial.remove( _exprID );
                   } 
               ATTR { _exprContent = ""; } 
               expr 
               SC
               {
               	 CommandAtribuicao cmd = new CommandAtribuicao(_exprID, _exprContent);
               	 stack.peek().add(cmd);
               }
			;
			
			
cmdselecao  :  'se' AP
                    ID    { _exprDecision = _input.LT(-1).getText();
                    	if(variavelNaoUsada.containsKey(_exprDecision)) variavelNaoUsada.remove(_exprDecision);
                    }
                    OPREL { _exprDecision += _input.LT(-1).getText(); }
                    (ID {
                    	_exprDecision += _input.LT(-1).getText();
                    	if(variavelNaoUsada.containsKey(_exprDecision)) variavelNaoUsada.remove(_exprDecision);
                    	}
                    | NUMBER {_exprDecision += _input.LT(-1).getText(); } 
                    | TEXT {_exprDecision += _input.LT(-1).getText(); }
                    | INTEIRO {_exprDecision += _input.LT(-1).getText(); }
                    )
                    FP 
                    ACH 
                    { curThread = new ArrayList<AbstractCommand>(); 
                      stack.push(curThread);
                    }
                    (cmd)+ 
                    
                    FCH 
                    {
                       listaTrue = stack.pop();	
                    } 
                   ('senao' 
                   	 ACH
                   	 {
                   	 	curThread = new ArrayList<AbstractCommand>();
                   	 	stack.push(curThread);
                   	 } 
                   	(cmd+) 
                   	FCH
                   	{
                   		listaFalse = stack.pop();
                   		CommandDecisao cmd = new CommandDecisao(_exprDecision, listaTrue, listaFalse);
                   		stack.peek().add(cmd);
                   	}
                   )?
            ;
            
cmdrepeticao :   'enquanto' AP
							ID    { _exprRep = _input.LT(-1).getText();
								    if(variavelNaoUsada.containsKey(_exprRep)) variavelNaoUsada.remove(_exprRep);
							}
                    	    OPREL { _exprRep += _input.LT(-1).getText(); }
                   		    (ID {
                   		    	_exprRep += _input.LT(-1).getText();
                   		    	if(variavelNaoUsada.containsKey(_exprRep)) variavelNaoUsada.remove(_exprRep);
                   		    }
                   		    | NUMBER { _exprRep += _input.LT(-1).getText(); }
                   		    | INTEIRO { _exprRep += _input.LT(-1).getText(); } 
                   		    )
                            FP
                            ACH 
		                    { curThread = new ArrayList<AbstractCommand>(); 
		                      stack.push(curThread);
		                    }
		                    (cmd)+ 
		                    
		                    FCH 
		                    {
		                       listaTrue = stack.pop();	
		                       CommandRepeticao cmd = new CommandRepeticao( _exprRep, listaTrue, 1 );
                   		       stack.peek().add(cmd);
		                    }
		         | 'faça' ACH 
		                    { curThread = new ArrayList<AbstractCommand>(); 
		                      stack.push(curThread);
		                    }
		                    (cmd)+ 
		                    
		                    FCH 
		                    'enquanto'
		                    AP
							ID    { _exprRep = _input.LT(-1).getText();
								if(variavelNaoUsada.containsKey(_exprRep)) variavelNaoUsada.remove(_exprRep);
							}
                    	    OPREL { _exprRep += _input.LT(-1).getText(); }
                   		    (ID {
                   		    	_exprRep += _input.LT(-1).getText();
								if(variavelNaoUsada.containsKey(_exprRep)) variavelNaoUsada.remove(_exprRep);
                   		    }
                   		    | NUMBER { _exprRep += _input.LT(-1).getText(); }
                   		    | INTEIRO { _exprRep += _input.LT(-1).getText(); })
                            FP
                            SC
                            {
                            	listaTrue = stack.pop();
                            	CommandRepeticao cmd = new CommandRepeticao( _exprRep, listaTrue, 2 );
                   		        stack.peek().add(cmd);
                            }
             ;
			
expr		:  termo ( 
	             OP  { _exprContent += _input.LT(-1).getText(); }
	            termo
	            )*
			;
			
termo		: ID { verificaID(_input.LT(-1).getText());
	               _exprContent += _input.LT(-1).getText();
	               if (TIPO != ((IsiVariable) symbolTable.get(_input.LT(-1).getText())).getType()) {
	               	throw new IsiSemanticException("Tipos diferentes");
	               }
	               else if( temValorInicial.containsKey(_input.LT(-1).getText()) ) {
	               	throw new IsiSemanticException("Variavel sem valor inicial");
	               }
	               if(variavelNaoUsada.containsKey( _exprContent)) variavelNaoUsada.remove(_exprContent);
                 } 
            | 
              INTEIRO
              {
              	_exprContent += _input.LT(-1).getText();
              	if(TIPO == 1) throw new IsiSemanticException("Incopativel (tipo "+TIPO+") (int tipo 2)");
              }
            |
              TEXT
              {
              	_exprContent += _input.LT(-1).getText();
              	if(TIPO != 1) throw new IsiSemanticException("Incompativel (tipo "+TIPO+") (String tipo 1)");
              }
            |
              NUMBER
              {
              	_exprContent += _input.LT(-1).getText();
              	if(TIPO != 0) throw new IsiSemanticException("Incompativel (tipo "+TIPO+") (double tipo 0)");
              }
			;
			
	
AP	: '('
	;
	
FP	: ')'
	;
	
SC	: ';'
	;
	
OP	: '+' | '-' | '*' | '/'
	;
	
ATTR : '='
	 ;
	 
VIR  : ','
     ;
     
ACH  : '{'
     ;
     
FCH  : '}'
     ;
	 
	 
OPREL : '>' | '<' | '>=' | '<=' | '==' | '!='
      ;
      
ID	: [a-z] ([a-z] | [A-Z] | [0-9])*
	;
	
TEXT : '"' ( [a-z] | [A-Z] | [0-9] )* '"'
	 ;
	 
INTEIRO : [0-9]+
		;
	
NUMBER	: [0-9]+ ('.' [0-9]+)?
		;
		
		
TEXTO : '"' ( [a-z] | [A-Z] | [0-9] | ' ' )* '"'
	 ;
		
		
WS	: (' ' | '\t' | '\n' | '\r') -> skip;