#Include 'Protheus.ch'
#include "Totvs.ch"

// --------------------------------------
// Função Chamada para o teste da chamada via RPC
// --------------------------------------
*******************************************************************************
User Function ServerCon()
*******************************************************************************
  
	// Efetua Conexão ao Serviço e Ambiente ...
	RpcConection("192.168.1.5", 1010, "COMPILACAO", 0 )
	
	RpcConection("192.168.1.5", 5020, "CRISTIANO" , 0 )

Return()
*******************************************************************************
Static Function RpcConection(cServer, nPort, cEnv, nTimeOut )
*******************************************************************************
	Local oRpcSrv := TRpc():New( cEnv )
	Local lSucess := .F.
	Local cRetorno:= ""
	
	Conout("conectando ao Servico : "+cServer+":"+cValToChar(nPort))
	lSucess := oRpcSrv:Connect( cServer, nPort, nTimeout ) 

	If lSucess
		Conout("Conexão efetuada com Sucesso...")
		
		cTime := Time() //oRpcSrv:CallProc('Time')
		ConOut(cTime)
		
		cRetorno := oRpcSrv:CallProcEX('U_RpcCall', 'Parametro 01', 'Parametro 02')
		ConOut( "Retorno U_RpcCall:" + cRetorno )

		conout("Desconectando do : "+cServer+":"+cValToChar(nPort)  )
		oRpcSrv:Disconnect()

	Else
		conout("Conexao RPC "+cServer+":"+cValToChar(nPort) +" Falhou...")
	Endif

Return()
// ------------------------------------
// Função a ser Chamada via RPC CallProcEx
// ------------------------------------
*******************************************************************************
User Function RpcCall(param1,param2)
*******************************************************************************

	Local aIniSession := GetIniSessions("APPSERVER.INI")
	Local aLen := Len(aIniSession)

	conout(" Total Sessions: " + cValToChar(aLen) )

	AlterChave()
/*
	If ( aLen > 0 )
		For nI := 1 to aLen
			conout( aIniSession[nI] )
		Next nI
	Endif
*/

Return ("Verificar o console.log...")
*******************************************************************************
Static Function AlterChave()
*******************************************************************************

Local cChave := "", cValor := "", cRecuperado := "", cMensagem := ""
 
  //+----------------------------------------------------------------------------+
  //|Exemplifica o uso da função WriteSrvProfString                              |
  //+----------------------------------------------------------------------------+
  cChave := "SOURCEPATH"
  cValor := "/totvs11/protheus/apo/compilacao"
 
  WriteSrvProfString(cChave, cValor)
 
  cRecuperado := GetSrvProfString(cChave, "undefined?")
  
  lret := ChkRpoChg()
  
  //cMensagem += "Chave [" + cChave + "] e conteúdo [" + cValor + "] " + IIf(!(cRecuperado == cValor), "não ", " ") + "gravado com sucesso!"
  //conout(cMensagem)
  If lret
  	cMensagem += "RPO alterado com Sucesso "
  Else
  	cMensagem += "RPO não alterado com Sucesso "
  EndIf
  
  conout("Validacao Alteracao de RPO: " + cMensagem)
 
  //+----------------------------------------------------------------------------+
  //|Apresenta uma mensagem com os resultados obtidos                            |
  //+----------------------------------------------------------------------------+

Return conout("Exemplo do WriteSrvProfString")