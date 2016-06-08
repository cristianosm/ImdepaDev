#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE 'Tbiconn.ch'
#Include "Totvs.ch"

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : NomeProg    | AUTOR : Cristiano Machado  | DATA : 17/08/2015   **
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
User Function Baca_Saldo_PV()
*******************************************************************************
Private cSQl 		:= ""
Private cRetorno := ""
Private lCaptura := .F.
Private lRoda		:= .T.
Private nSleep		:= 5 // Segundos...
PREPARE ENVIRONMENT EMPRESA "01" FILIAL "05" FUNNAME 'BACASLDPV'  TABLES 'SM0','SC9'

Conout("BACA DUPLICADOS - ENTROU - "+ DtoC(dDatabase)+" "+Time() )

While lRoda

	If Time() > '22:00:00' .OR. ( Time() > '13:15:00' .AND. Time() < '13:16:00' )

		lRoda := .F.
	EndIf


	Roda() // executa processo

	Sleep(nSleep * 1000 )

EndDo

Conout("BACA DUPLICADOS - SAIU   - "+ DtoC(dDatabase)+" "+Time() )

RESET ENVIRONMENT

Return()
*******************************************************************************
Static Function Roda()
*******************************************************************************

Conout("BACA DUPLICADOS - INICIO - "+ DtoC(dDatabase)+" "+Time() )


cSQL := ""
//cSQl += "update sc9010 set D_E_L_E_T_ = '*' where r_e_c_n_o_ in ( "


cSQl += "select SC9.c9_filial, SC9.c9_pedido, SC9.c9_item, SC9.c9_produto, SC9.c9_qtdlib, SC9.c9_local, SC9.r_e_c_n_o_ from sc9010 sc9, ( "

cSQl += "                        SELECT "
cSQl += "                           c9_filial, c9_pedido, c9_item, c9_produto, c9_qtdlib, c9_local, Max(R_E_C_N_O_) recno "
cSQl += "                        FROM "
cSQl += "                           SC9010 "
cSQl += "                        WHERE "
cSQl += "                           C9_DATALIB > '20150701' "
cSQl += "                           AND D_E_L_E_T_ = ' ' "
cSQl += "                        GROUP BY "
cSQl += "                           c9_filial, c9_pedido, c9_item, c9_produto, c9_qtdlib, c9_local "
cSQl += "                        HAVING "
cSQl += "                           COUNT( 1 ) > 1 "
cSQl += "                        ORDER BY c9_filial, c9_pedido, c9_item, c9_produto "
cSQl += "                         "
cSQl += "                        ) AUX "

cSQl += "   Where 	sc9.c9_filial = aux.c9_filial "
cSQl += "   and  	sc9.c9_pedido 	= aux.c9_pedido "
cSQl += "   and 		sc9.c9_item 		= aux.c9_item "
cSQl += "   and 		sc9.c9_produto = aux.c9_produto "
cSQl += "   and 		sc9.c9_qtdlib 	= aux.c9_qtdlib "
cSQl += "   and 		sc9.c9_local 	= aux.c9_local "
cSQl += "   and 		sc9.R_E_C_N_O_ = aux.recno "
cSQl += "   and 		sc9.D_E_L_E_T_ = ' ' "
//cSQl += "   ) "

cRetorno := U_ExecMySql(cSQl, "AUX", "Q", lCaptura)

DbSelectArea("AUX");DbGotop()
While !Eof()

	cError := U_ExecMySql("UPDATE SC9010 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_, C9_BLINF = 'DELETADO POR BACADUPLI' where r_e_c_n_o_ = "+cValToChar(AUX->R_E_C_N_O_) + " ","","E", lCaptura)

	If Alltrim( cError ) == "Executado Com Sucesso"

		Conout("BACA DUPLICADOS - FILIAL: "+ cValToChar(AUX->C9_FILIAL) +" PEDIDO: "+ cValToChar(AUX->C9_PEDIDO) +" ITEM: "+ cValToChar(AUX->C9_ITEM) +" PRODUTO:" + Alltrim(cValToChar(AUX->C9_PRODUTO)) + " RECNO - " + cValToChar(AUX->r_e_c_n_o_) + " - DELETADO - " + DtoC(dDatabase)+" "+Time())

	Else

		Conout("BACA DUPLICADOS - ERRO NA DELECAO: " + cError + " - " + DtoC(dDatabase)+" "+Time())

	EndIf

	DbSelectArea("AUX")
	DbSkip()

EndDo

	Conout("BACA DUPLICADOS - FIM    - " + DtoC(dDatabase)+" "+Time() )

DbCloseArea("AUX")

Return()
