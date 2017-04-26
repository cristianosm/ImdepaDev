#include 'protheus.ch'
#include 'parmtype.ch'

*******************************************************************************
User function TesteSF() // Teste de POST para Projeto SIM FRETE -> Funcionou!
*******************************************************************************	

  Local cHtmlPage := ""
  Local cPar := ""

  cPar += "&wsemp=" 	+ Escape('demo')
  cPar += "&wsusr=" 	+ Escape('Imdepa')
  cPar += "&wspwd=" 	+ Escape('50607080')
  cPar += "&origem=" 	+ Escape('Porto Alegre/RS')
  cPar += "&destino=" 	+ Escape('Sao Paulo/SP')
  cPar += "&modal=" 	+ Escape('Rod')
  cPar += "&ciffob=" 	+ Escape('C')
  cPar += "&remCNPJ=" 	+ Escape('99999999999999')
  cPar += "&remNome=" 	+ Escape('MedilarS/A')
  cPar += "&desCNPJ=" 	+ Escape('99999999999999')
  cPar += "&desNome=" 	+ Escape('Cliente')
  cPar += "&totalNF=" 	+ Escape('1.834,56')
  cPar += "&pesoNF=" 	+ Escape('33,123456')
  cPar += "&volNF=" 	+ Escape('0,430000')
  cPar += "&qtdNF=" 	+ Escape('123,123456')
 
  cHtmlPage := Httpget("http://demo.simfrete.com/consultafrete.jsp?",cPar)
 
  VarInfo('cHtmlPage:',cHtmlPage)
  
 	
Return()