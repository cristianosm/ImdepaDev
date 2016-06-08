#include "totvs.ch"
#include "Ap5mail.CH"

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : NomeProg    | AUTOR : Cristiano Machado  | DATA : 19/06/2015   **
**---------------------------------------------------------------------------**
** DESCRIÇÃO:                                                                **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente  XXXXXX                              **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
**                 |          |                                              **
**                 |          |                                              **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function Pop3_Con(lPergunte,cServer,cUser,cPass,nTimeOut,lUseTLSMail,lUseSSLMail )
*******************************************************************************


//User Classe TMailMessage -> http://tdn.totvs.com/display/tec/Classe+TMailMessage

	Local cServer 			:= ""
	Local cUser 				:= ""
	Local cPass 				:= ""

	Local nTimeOut 		:= .F.
	Local lUseTLSMail 	:= .F.
	Local lUseSSLMail 	:= .F.

	Local lRet 				:= .F.

	Default lPergunte 	:= .T.

	IF lPergunte
		Pergunte ("POP3TST" , .T. )
	EndIf

 cServer 			:= Alltrim(Mv_Par01)
 cUser 				:= Alltrim(Mv_Par02)
 cPass 				:= Alltrim(Mv_Par03)
 nTimeOut 			:= Val(Alltrim(Mv_Par04))
 lUseTLSMail 	:= if(cValToChar(Mv_Par05)=='1',.T.,.F.)
 lUseSSLMail 	:= if(cValToChar(Mv_Par06)=='1',.T.,.F.)

	lRet := MailPopOn( cServer, cUser, cPass, nTimeOut, lUseTLSMail, lUseSSLMail )

	If lRet
		ApMsgInfo("Conexão POP Ok")

	Else
		ApMsgInfo("Não conseguiu efetuar a conexão com o servidor POP")

	EndIf


Return()