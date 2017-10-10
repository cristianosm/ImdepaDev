#include 'protheus.ch'
#include 'parmtype.ch'

*******************************************************************************
User Function SSL_TLS_CONECTION()
*******************************************************************************
	Local oServer
	Local xret
	
	oServer := TMailManager():New()
	xret	:= writePProString( "MAIL", "Protocol", "POP3", getsrvininame() )
	
	if xRet == .F.
		cMsg := "Nao foi possivel definir " + cProtocol + " em " + getsrvininame() + CRLF
		
		Alert( cMsg )
		return
	endif

	oServer:SetUseTLS( .T. )
	oServer:SetUseSSL( .T. )                                 

	xRet := oServer:Init( "mail.imdepa.com.br", "", "cte@imdepa.com.br", "cte606",7995) 

	lTeste:=.F.
	IF lTeste
		cSenhaa  := "imd606!@#"
		cConta  := "cteteste@imdepa.com.br"  ///para teste de homologacao
		xRet := oServer:Init( "mail.imdepa.com.br", "", cConta, cSenhaa, 995)
	ENDIF

	if xRet <> 0
		Alert( "Não foi possível inicializar servidor de correio: " + oServer:GetErrorString( xRet ) )
		return
	endif

	If oServer:SetPopTimeOut( 60 ) != 0
		Conout( "Falha ao setar o time out" )
		Return .F.
	EndIf

	xRet := oServer:POPConnect()

	if xRet <> 0
		Alert( "Não foi possível conectar no servidor *POP3: " + oServer:GetErrorString( xRet ) )
		return
	Endif

Return()