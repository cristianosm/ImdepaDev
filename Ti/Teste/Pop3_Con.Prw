#include "totvs.ch"
#include "Ap5mail.CH"

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUN��O   : NomeProg    | AUTOR : Cristiano Machado  | DATA : 19/06/2015   **
**---------------------------------------------------------------------------**
** DESCRI��O:                                                                **
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
		ApMsgInfo("Conex�o POP Ok")

	Else
		ApMsgInfo("N�o conseguiu efetuar a conex�o com o servidor POP")

	EndIf


Return()