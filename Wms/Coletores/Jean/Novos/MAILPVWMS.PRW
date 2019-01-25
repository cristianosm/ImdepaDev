#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "IMDEPA.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*
Jean Rehermann - SOLUTIO IT - 09/01/2019
Envio de e-mail informando que o pedido está apto a ser faturado
*/

User Function MailPvWms( cPedido )

	Local cServer   := Alltrim( GetMV("MV_RELSERV") )
	Local cAccount  := Alltrim( GetMV("MV_RELACNT") )
	Local cPassword := Alltrim( GetMV("MV_RELPSW") )
	Local lAuth     := Getmv("MV_RELAUTH")
	Local cAssunto  := cPedido +" | PEDIDO LIBERADO PARA FATURAMENTO"
	Local cMensagem := ""
	Local cEmailTo  := ""
	Local cEmailBcc := ""
	Local lResult   := .F.
	Local cError    := ""
	
	Local aAreaATU := GetArea()
	Local aAreaSA1 := SA1->( GetArea() )
	Local aAreaSC5 := SC5->( GetArea() )
	Local aAreaSUA := SUA->( GetArea() )
	
	cEmailTo := SuperGetMV("IMD_MAILPVL", .F., "cristiano.machado@imdepa.com.br", xFilial("SC5"))
	
	// Posiciona arquivo de pedidos de venda (SC5)
	dbSelectArea("SC5")
	dbSetOrder(1)
	DbSeek( xFilial("SC5") + cPedido )
	
	// Posiciona arquivo de clientes (SA1)
	dbSelectArea("SA1")
	dbSetOrder(1)
	DbSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI )
	
	dbSelectArea("SUA")
	dbSetOrder(8)
	DbSeek( xFilial("SUA") + cPedido )
	
	
	// corpo do e-mail
	cMensagem := "PEDIDO LIBERADO PARA FATURAMENTO - "+ SC5->C5_NUM + CRLF + CRLF
	cMensagem += "Seguem abaixo os dados do pedido:" + CRLF + CRLF
	cMensagem += "Número: "+ SC5->C5_NUM + CRLF
	cMensagem += "Emissão: "+ DtoC( SC5->C5_EMISSAO ) + CRLF
	cMensagem += "Código/Loja do Cliente....: "+ SA1->A1_COD +"/"+ SA1->A1_LOJA + CRLF
	cMensagem += CRLF
	cMensagem += "Obs.Expedição................: "+ SUA->UA_OBSEXP + CRLF
	cMensagem += CRLF
	cMensagem += CRLF
	If SC5->C5_PEDGUIA == "1"
		cMensagem += "ATENCAO, Pedido com ST. Por Favor Imprimir Guia de Pagamento" + CRLF
	Else
		cMensagem += "Pedido não possui ST." + CRLF
	EndIf
	
	// conectando-se com o servidor de e-mail
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult
	
	// fazendo autenticacao
	If lResult .And. lAuth

		lResult := MailAuth( cAccount, cPassword )

		If !lResult
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError
			MsgAlert("Erro de Autenticacao no envio de e-mail: "+ cError )
			Return Nil
		Endif
	
	Else

		If !lResult
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError
			MsgAlert("Erro de conexao no envio de e-mail: "+ cError )
			Return Nil
		Endif

	EndIf
	
	If lResult

		SEND MAIL FROM cAccount ;
		TO             cEmailTo;
		BCC            cEmailBcc;
		SUBJECT        cAssunto;
		BODY           cMensagem;
		RESULT         lResult

		If !lResult
			//Erro no envio do email
			GET MAIL ERROR cError
			MsgAlert("Erro no envio de e-mail: "+ cError )
			Return Nil
		EndIf
		
		DISCONNECT SMTP SERVER
		
	EndIf
	
	
	
	RestArea( aAreaSA1 )
	RestArea( aAreaSC5 )
	RestArea( aAreaSUA )
	RestArea( aAreaATU )
	
Return( lResult )