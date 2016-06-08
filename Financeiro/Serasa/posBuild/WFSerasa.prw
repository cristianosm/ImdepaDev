#Include "Protheus.ch"
#INCLUDE "tbiconn.ch"

#Define _Enter    CHR(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WFSerasa  ºAutor  ³Cristiano Machado   º Data ³  11/28/11    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gerencia tabela Z01 - SERASA. Incluindo Novos Titulos e      º±±
±±º          ³Deletando os Pagos que nao foram enviados. Altera os Status  º±±
±±º          ³dos mesmo informando o Financeiro sobre acoes a serem Tomadasº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CHAMADO: AAZU4Q - SERASA PEFIN   SOLICITANTE: Juliano SF    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*********************************************************************
User Function WFSerasa()
*********************************************************************
Private cMailFin 		:= ""
Private lTeste   		:= .F. //| Em modo teste os email serao enviados apenas para conta abaixo
Private cMailTest 		:= "cristiano.machado@imdepa.com.br"
Private aMenAction		:= {"","podem ser Incluidos no SERASA","devem ser Retirados do SERASA","",""} //| Mensagem Email conforme N da action
Private nAct					:= 0
Private cMailFrom 		:= ""
Private lContinua		:= .T.
Private dDataVenc 		//| Dia que sera avaliado
Private dDataAlte		//| Monta datar de alteracoes ...
Private dtUltExec		//| Data do Ultimo dia analisado por esta rotina...
Private dtFinExec		//| Data Limite de execucao

PREPARE ENVIRONMENT EMPRESA '01' FILIAL '05' FUNNAME 'WFSerasa' TABLES 'Z01','SX6'

cMailFin  :=  cMailFrom := GetMv( "IM_SERASAM" , .F. , "pefin@imdepa.com.br" )
dtUltExec := GetMv("IM_UEWFSER",,dtoc(dDatabase-5))	//| Data do Ultimo dia analisado por esta rotina...
dtFinExec := dDatabase - 5 						   		//| Data Limite de execucao
dDataVenc := dtUltExec									//| Dia que sera avaliado
dDataAlte := dDataVenc + 5

Iif(lTeste, cMailFin:=cMailTest,"")
While lContinua          //| Chamado : AAZV28

	If dDataVenc <= dtFinExec  //| Dia a Ser avaliado eh menor que Limite de Execucao ?

		Conout('WFSERASA - '+Dtoc(DDATABASE)+' - '+Time()+' Inicio do Processamento! Parametro DtVencto:'+Dtoc(dDataVenc))
		ExecutaProc()
		dDataVenc := dDataVenc + 1 //| Pula para Proximo Dia
		dDataAlte := dDataAlte + 1
	Else
		dDataVenc := dDataVenc - 1 //| Retorna Ultima data Executada...  para salvar no parametro
		lContinua := .F.
    EndIf

EndDo        //| Fim Chamado AAZV28
Conout('WFSERASA - '+Dtoc(DDATABASE)+' - '+Time()+' Fim do Processamento! Parametro DtVencto:'+Dtoc(dDataVenc))

GrvUExec()//| Atualiza o Parametro "IM_SERASAM"

RESET ENVIRONMENT

Return()
*********************************************************************
Static Function ExecutaProc()//|Executa o Processamento
*********************************************************************


Conout('WFSERASA - '+Dtoc(DDATABASE)+' - '+Time()+' Passo 1 - 5 : Deletando Titulos Pagos que estao como DISPONIVEIS na Z01.');nAct:=1
ActDelTit()//| Deleta Titulos Pagos que estao como DISPONIVEIS na Z01.

Conout('WFSERASA - '+Dtoc(DDATABASE)+' - '+Time()+' Passo 2 - 5 : Disponibilizando Novo Titulos para a Tabela Z01 e informando Financeiro.');nAct:=2
ActDisTit()//| Disponibiliza NOVOS Titulos para a Tabela Z01 e Informa o Financeiro.

Conout('WFSERASA - '+Dtoc(DDATABASE)+' - '+Time()+' Passo 3 - 5 : Procurando Pagamentos de Clientes e informando financeiro sobre Retiradas.');nAct:=3
ActPgtTit()//| Identifica Pagamentos dos Clientes e Informa Financeiro sobre Retiradas.

Conout('WFSERASA - '+Dtoc(DDATABASE)+' - '+Time()+' Passo 4 - 5 : Informando Clientes Sobre Inclusoes no SERASA.');nAct:=4
ActInfCli()//| Informa Clientes sobre Inclusoes no Serasa.

Conout('WFSERASA - '+Dtoc(DDATABASE)+' - '+Time()+' Passo 5 - 5 : Informando Clientes Sobre Exclusoes do SERASA.');nAct:=5
ActRetCli()//| Informa Cliente Sobre Exclusao do SERASA.


Return()
*********************************************************************
Static Function ActDelTit()//|Action 1 - Deleta Titulos Pagos que estao como DISPONIVEIS na Z01.
*********************************************************************

RodaQuery(nAct)

DbSelectArea("SER")
While !EOF()

	DbSelectArea("Z01")

	IncAltDel(SER->R_E_C_N_O_)//| Inclui Titulo, Altera Legenda ou Deleta Titulo. |Inclusao: Recno = 0 ou Nil |Alteracao=Recno e Legenda Preenchidos |Exlusao: Legenda Vazia ou Nil

	DbSelectArea("SER")
	DbSkip()
EndDo

DbSelectArea("SER")
DbCloseArea()

Return()
*********************************************************************
Static Function ActDisTit()//|Action 2 - Disponibiliza NOVOS Titulos para a Tabela Z01 e Informa o Financeiro.
*********************************************************************
Local cTitulos 	:= ""
Local cCab		:= MenEmail("FIN-C")  //| Cabecalho
Local cMen		:= ""
Local nConTit	:= 0
Local cRod		:= ""

RodaQuery(nAct)

DbSelectArea("SER");DbGoTop()
While !EOF()

	nConTit  += 1

	IncAltDel()//| Inclui Titulo, Altera Legenda ou Deleta Titulo. |Inclusao: Recno = 0 ou Nil |Alteracao=Recno e Legenda Preenchidos |Exlusao: Legenda Vazia ou Nil

	cGerenc := Posicione("SA1",1,xFilial("SA1")+SER->Z01_CLIENT + SER->Z01_LOJA,"A1_GERVEN")

	cTitulos += '<tr>'
	cTitulos += '<td style="vertical-align: top; text-align: center;">'+Iif(Empty(cGerenc),"000000",cGerenc)+'</td>'
	cTitulos += '<td style="vertical-align: top; text-align: center;">'+SER->Z01_CLIENT +"-"+SER->Z01_LOJA +'</td>'
	cTitulos += '<td style="vertical-align: top; text-align: Left;	">'+SER->Z01_NOME+'</td>'
	cTitulos += '<td style="vertical-align: top; text-align: center;">'+SER->Z01_PREFIX+"&nbsp;"+SER->Z01_NUMERO+"&nbsp;"+SER->Z01_PARCEL+'</td>'
	cTitulos += '<td style="vertical-align: top; text-align: center;">'+dToC(StoD(SER->Z01_VENCTO))+'</td>'
	cTitulos += '<td style="vertical-align: top; text-align: center;">R$ '+Transform(SER->Z01_VALOR, "@R 9,999,999.99")+'</td>'
	cTitulos += '</tr>'

	DbSelectArea("SER")
	DbSkip()

EndDo

DbSelectArea("SER")
DbCloseArea()

If nConTit > 0
	cRod := MenEmail("FIN-R") //| Rodape

	cMen := cCab + cTitulos + cRod

	//| Dispara Email ao FINANCEIRO
	U_EnvMyMail(cMailFrom,cMailFin,"","SERASA - "+Alltrim(Str(nConTit,0))+" Título(s) a Incluir no SERASA",cMen,"")//| U_EnvMyMail(De, Para, Copia, Assunto, Corpo, Anexo )
EndIf

Return()
*********************************************************************
Static Function ActPgtTit()//|Action 3 - Identifica Pagamentos dos Clientes e Informa Financeiro sobre Retiradas.
*********************************************************************
Local cTitulos 	:= ""
Local cCab		:= MenEmail("FIN-C")
Local cMen		:= ""
Local nConTit	:= 0
Local cRod		:= ""
Local cGerenc	:= ""

RodaQuery(nAct)

DbSelectArea("SER");DbGotop()
While !EOF()

	nConTit  += 1

	IncAltDel(SER->R_E_C_N_O_, "R")//| Inclui Titulo, Altera Legenda ou Deleta Titulo. |Inclusao: Recno = 0 ou Nil |Alteracao=Recno e Legenda Preenchidos |Exlusao: Legenda Vazia ou Nil

	cGerenc := Posicione("SA1",1,xFilial("SA1")+SER->Z01_CLIENT + SER->Z01_LOJA,"A1_GERVEN")



	cTitulos += '<tr>'
	cTitulos += '<td style="vertical-align: top; text-align: center;">'+Iif(Empty(cGerenc),"000000",cGerenc)+'</td>'
	cTitulos += '<td style="vertical-align: top; text-align: center;">'+SER->Z01_CLIENT +"-"+SER->Z01_LOJA +'</td>'
	cTitulos += '<td style="vertical-align: top; text-align: Left;	">'+SER->Z01_NOME+'</td>'
	cTitulos += '<td style="vertical-align: top; text-align: center;">'+SER->Z01_PREFIX+"&nbsp;"+SER->Z01_NUMERO+"&nbsp;"+SER->Z01_PARCEL+'</td>'
	cTitulos += '<td style="vertical-align: top; text-align: center;">'+dToC(StoD(SER->Z01_VENCTO))+'</td>'
	cTitulos += '<td style="vertical-align: top; text-align: center;">R$ '+Transform(SER->Z01_VALOR, "@R 9,999,999.99")+'</td>'
	cTitulos += '</tr>'

	DbSelectArea("SER")
	DbSkip()

EndDo

DbSelectArea("SER")
DbCloseArea()

If nConTit > 0
	cRod := MenEmail("FIN-R")
	cMen := cCab + cTitulos + cRod

	//| Dispara Email ao FINANCEIRO
	U_EnvMyMail(cMailFrom,cMailFin,"","SERASA - "+Alltrim(Str(nConTit,0))+" Título(s) a Retirar do SERASA",cMen,"")//| U_EnvMyMail(De, Para, Copia, Assunto, Corpo, Anexo )
EndIf

Return()
*********************************************************************
Static Function ActInfCli()//|Action 4 -  Informa Clientes sobre Inclusoes no Serasa.
*********************************************************************
Local cCli 		:= ""
Local nConTit  	:= 0
Local cCab		:= MenEmail("CLI-C")
Local cTitulos	:= ""
Local cRod		:= ""
Local cCnpj		:= ""
//Local cClimail	:= ""

RodaQuery(nAct)//| Titulos Incluidos no SERASA

DbSelectArea("SER");DbGotop()
While !EOF()

	cTitulos 	:= ""
	nConTit  	:= 0
	cCli 		:= SER->Z01_CLIENT + SER->Z01_LOJA
	While cCli == SER->Z01_CLIENT + SER->Z01_LOJA

		nConTit += 1
		cCnpj 	:= Posicione("SA1",1,xFilial("SA1") + SER->Z01_CLIENT + SER->Z01_LOJA						,"A1_CGC"		)
		cAgenc 	:= Posicione("SE1",1,xFilial("SE1") + SER->Z01_PREFIX + SER->Z01_NUMERO + SER->Z01_PARCEL	,"E1_AGEDEP"	)
		cConta 	:= Posicione("SE1",1,xFilial("SE1") + SER->Z01_PREFIX + SER->Z01_NUMERO + SER->Z01_PARCEL	,"E1_CONTA"		)
		cNosso 	:= Posicione("SE1",1,xFilial("SE1") + SER->Z01_PREFIX + SER->Z01_NUMERO + SER->Z01_PARCEL	,"E1_NUMBCO"	)

		cTitulos += '<tr>'
		cTitulos += '<td style="vertical-align: top; text-align: Left;">'+SER->Z01_NOME+'</td>'
		cTitulos += '<td style="vertical-align: top; text-align: center;">'+cCnpj+'</td>'
		cTitulos += '<td style="vertical-align: top; text-align: center;">'+SER->Z01_PREFIX+"&nbsp;"+SER->Z01_NUMERO+"&nbsp;"+SER->Z01_PARCEL+'</td>'
		cTitulos += '<td style="vertical-align: top; text-align: center;">'+dToC(StoD(SER->Z01_VENCTO))+'</td>'
		cTitulos += '<td style="vertical-align: top; text-align: center;">R$ '+Transform(SER->Z01_VALOR, "@R 9,999,999.99")+'</td>'
		cTitulos += '<td style="vertical-align: top; text-align: center;">'+cAgenc+"/"+cConta+'</td>'
		cTitulos += '<td style="vertical-align: top; text-align: center;">'+cNosso+'</td>'
		cTitulos += '</tr>'


		DbSelectArea("SER")
		DbSkip()

	EndDo

//	cClimail :=

	If nConTit > 0

		cRod := MenEmail("CLI-R")
		cMen :=   cCab + cTitulos + cRod

		//| Dispara Email ao CLIENTE
		U_EnvMyMail(cMailFrom, RetEmail(cCli) ,"","COMUNICADO - Inclusão de Débito",cMen,"")//| U_EnvMyMail(De, Para, Copia, Assunto, Corpo, Anexo )
	EndIf

EndDo

DbSelectArea("SER")
DbCloseArea()

Return()
*********************************************************************
Static Function ActRetCli()//|Action 5 - Informa Cliente Sobre Exclusao do SERASA.
*********************************************************************
Local cCli 		:= ""
Local nConTit  	:= 0
Local cCab		:= MenEmail("CLU-C")
Local cTitulos	:= ""
Local cRod		:= ""
Local cCnpj		:= ""

RodaQuery(nAct)//| Titulos Incluidos no SERASA

DbSelectArea("SER");DbGotop()
While !EOF()

	cTitulos 	:= ""
	nConTit  	:= 0
	cCli 		:=  SER->Z01_CLIENT + SER->Z01_LOJA
	cCnpj 		:= Posicione("SA1",1,xFilial("SA1") + SER->Z01_CLIENT + SER->Z01_LOJA,"A1_CGC"	)
	While cCli == SER->Z01_CLIENT + SER->Z01_LOJA

		nConTit  += 1

		cTitulos += '<tr>'
		cTitulos += '<td style="vertical-align: top; text-align: Left;">'+SER->Z01_NOME+'</td>'
		cTitulos += '<td style="vertical-align: top; text-align: center;">'+cCnpj+'</td>'
		cTitulos += '<td style="vertical-align: top; text-align: center;">'+SER->Z01_PREFIX+"&nbsp;"+SER->Z01_NUMERO+"&nbsp;"+SER->Z01_PARCEL+'</td>'
		cTitulos += '<td style="vertical-align: top; text-align: center;">'+dToC(StoD(SER->Z01_VENCTO))+'</td>'
		cTitulos += '<td style="vertical-align: top; text-align: center;">R$ '+Transform(SER->Z01_VALOR, "@R 9,999,999.99")+'</td>'
		cTitulos += '</tr>'

		DbSelectArea("SER")
		DbSkip()

	EndDo


	If nConTit > 0

		cRod := MenEmail("CLU-R")
		cMen := cCab + cTitulos + cRod

		//| Dispara Email ao CLIENTE
		U_EnvMyMail(cMailFrom, RetEmail(cCli) ,"","COMUNICADO - Exclusão de Débito",cMen,"")//| U_EnvMyMail(De, Para, Copia, Assunto, Corpo, Anexo )

	EndIf

EndDo

DbSelectArea("SER")
DbCloseArea()

Return()
*********************************************************************
Static Function RodaQuery()//| Incluidos
*********************************************************************
cQuery := ""

Do Case
	Case nAct == 1 //|Action 1 - Deleta Titulos Pagos que estao como DISPONIVEIS na Z01.

		cQuery += "SELECT  Z1.Z01_FILIAL, "
		cQuery += "        Z1.Z01_PREFIX,  "
		cQuery += "        Z1.Z01_NUMERO,  "
		cQuery += "        Z1.Z01_PARCEL,  "
		cQuery += "        Z1.R_E_C_N_O_ "
		cQuery += "FROM Z01010 Z1, SE1010 E1 "
		cQuery += "WHERE Z1.Z01_FILIAL = ' ' "
		cQuery += "AND   Z1.Z01_LEGEND = 'D' " //| Disponivel
		cQuery += "AND   Z1.Z01_DATALT < '"+DToS(dDataAlte)+"'
		cQuery += "AND   Z1.D_E_L_E_T_ = ' ' "
		cQuery += "AND   E1.E1_FILIAL  = ' '  "
		cQuery += "AND   E1.E1_TIPO    = 'NF' " //| So Verifica NF
		cQuery += "AND   E1.E1_PREFIXO = Z1.Z01_PREFIX "
		cQuery += "AND   E1.E1_NUM     = Z1.Z01_NUMERO "
		cQuery += "AND   E1.E1_PARCELA = Z1.Z01_PARCEL "
		cQuery += "AND   E1.E1_CLIENTE = Z1.Z01_CLIENT "
		cQuery += "AND   E1.E1_LOJA    = Z1.Z01_LOJA "
		cQuery += "AND   E1.E1_BAIXA  != ' '  " //| Pago
		cQuery += "AND   E1.E1_SALDO   = 0  "   //| Pago
		cQuery += "AND   E1.D_E_L_E_T_ = ' ' "

	Case nAct == 2 //|Action 2 - Disponibiliza NOVOS Titulos para a Tabela Z01 e Informa o Financeiro.

		cQuery += "SELECT  E1_FILIAL   Z01_FILIAL, "
		cQuery += "        E1_PREFIXO  Z01_PREFIX, "
		cQuery += "        E1_NUM      Z01_NUMERO, "
		cQuery += "        E1_PARCELA  Z01_PARCEL, "
		cQuery += "        E1_VENCREA  Z01_VENCTO, "
		cQuery += "        E1_VALOR    Z01_VALOR, "
		cQuery += "        SUBSTR(E1_NUMBCO,1,9)   Z01_NUMBC, "
		cQuery += "        E1_CLIENTE  Z01_CLIENT,  "
		cQuery += "        E1_LOJA     Z01_LOJA,  "
		cQuery += "        E1_NOMCLI   Z01_NOME "
		cQuery += "FROM SE1010 "
		cQuery += "WHERE E1_FILIAL   = ' ' "
		cQuery += "AND   E1_TIPO     = 'NF' "
		cQuery += "AND   E1_VENCTO   = '"+DToS(dDataVenc)+"' "
		cQuery += "AND   E1_SITUACA  = 'H' " //| Cobranca SERASA
//		chamado AAZV27
//		cQuery += "AND   E1_BAIXA    = ' ' "
		cQuery += "AND(  E1_BAIXA    = ' ' OR E1_SALDO > 1 ) "   //| Pago Parcialmente
//| Fim Chamado AAZV27
		cQuery += "AND   D_E_L_E_T_  = ' ' "
		cQuery += "AND 	 E1_PREFIXO||E1_NUM||E1_PARCELA NOT IN( SELECT Z01_PREFIX||Z01_NUMERO||Z01_PARCEL "
		cQuery += "                                               FROM Z01010 "
		cQuery += "                                              WHERE Z01_FILIAL = '  ' "
		cQuery += "                                                AND D_E_L_E_T_ = ' '  ) "


	Case nAct == 3 //|Action 3 - Identifica Pagamentos dos Clientes e Informa Financeiro sobre Retiradas.

		cQuery += "SELECT  E1_FILIAL   Z01_FILIAL, "
		cQuery += "        E1_PREFIXO  Z01_PREFIX, "
		cQuery += "        E1_NUM      Z01_NUMERO, "
		cQuery += "        E1_PARCELA  Z01_PARCEL, "
		cQuery += "        E1_VENCREA  Z01_VENCTO, "
		cQuery += "        E1_VALOR    Z01_VALOR, "
		cQuery += "        SUBSTR(E1_NUMBCO,1,9)   Z01_NUMBC, "
		cQuery += "        E1_CLIENTE  Z01_CLIENT,  "
		cQuery += "        E1_LOJA     Z01_LOJA,  "
		cQuery += "        E1_NOMCLI   Z01_NOME, "
		cQuery += "        Z1.R_E_C_N_O_ "
		cQuery += "FROM Z01010 Z1, SE1010 E1 "
		cQuery += "WHERE Z1.Z01_FILIAL = ' ' "
		cQuery += "AND   Z1.Z01_LEGEND = 'I' " //| Incluido
		cQuery += "AND   Z1.Z01_DATALT < '"+DToS(dDataAlte)+"'
		cQuery += "AND   Z1.D_E_L_E_T_ = ' ' "
		cQuery += "AND   E1.E1_FILIAL  = ' '  "
		cQuery += "AND   E1.E1_TIPO    = 'NF' " //| So Verifica NF
		cQuery += "AND   E1.E1_PREFIXO = Z1.Z01_PREFIX "
		cQuery += "AND   E1.E1_NUM     = Z1.Z01_NUMERO "
		cQuery += "AND   E1.E1_PARCELA = Z1.Z01_PARCEL "
		cQuery += "AND   E1.E1_CLIENTE = Z1.Z01_CLIENT "
		cQuery += "AND   E1.E1_LOJA    = Z1.Z01_LOJA "
		cQuery += "AND   E1.E1_BAIXA  != ' '  " //| Pago
		cQuery += "AND   E1.E1_SALDO   = 0  "   //| Pago
		cQuery += "AND   E1.D_E_L_E_T_ = ' ' "

	Case nAct == 4 //|Action 4 -  Informa Clientes sobre Inclusoes no Serasa.

		cQuery += "	SELECT Z01_FILIAL, "
		cQuery += "        Z01_PREFIX,  "
		cQuery += "        Z01_NUMERO,  "
		cQuery += "        Z01_PARCEL,  "
		cQuery += "        Z01_VENCTO,  "
		cQuery += "        Z01_VALOR,  "
		cQuery += "        Z01_NUMBC,  "
		cQuery += "        Z01_CLIENT,  "
		cQuery += "        Z01_LOJA,  "
		cQuery += "        Z01_NOME "
		cQuery += "FROM Z01010 "
		cQuery += "WHERE Z01_FILIAL   	= ' ' "
		cQuery += "AND   Z01_LEGEND   	= 'I' "
		cQuery += "AND   Z01_DATALT	 	= '"+DToS(dDataAlte-1)+"' "
		cQuery += "AND   D_E_L_E_T_  	= ' ' "
		cQuery += "ORDER BY Z01_CLIENT || Z01_LOJA "

	Case nAct == 5 //|Action 5 - Informa Cliente Sobre Exclusao do SERASA.

		cQuery += "	SELECT  Z01_FILIAL, "
		cQuery += "        Z01_PREFIX,  "
		cQuery += "        Z01_NUMERO,  "
		cQuery += "        Z01_PARCEL,  "
		cQuery += "        Z01_VENCTO,  "
		cQuery += "        Z01_VALOR,  "
		cQuery += "        Z01_NUMBC,  "
		cQuery += "        Z01_CLIENT,  "
		cQuery += "        Z01_LOJA,  "
		cQuery += "        Z01_NOME "
		cQuery += "FROM Z01010 "
		cQuery += "WHERE Z01_FILIAL   	= ' ' "
		cQuery += "AND   Z01_LEGEND   	= 'E' "
		cQuery += "AND   Z01_DATALT	 	= '"+DToS(dDataAlte-1)+"' "
		cQuery += "AND   D_E_L_E_T_  	= ' ' "
		cQuery += "ORDER BY Z01_CLIENT || Z01_LOJA "

EndCase

U_ExecMySql( cQuery, "SER", "Q" )

Return()
*********************************************************************
Static Function IncAltDel(nRecno,cLeg)//| Inclui Titulo, Altera Legenda ou Deleta Titulo. |Inclusao: Recno = 0 ou Nil |Alteracao=Recno e Legenda Preenchidos |Exlusao: Legenda Vazia ou Nil
*********************************************************************

DbSelectArea("Z01")

If nRecno == Nil .Or. nRecno == 0

	IF !DbSeek(xFilial("Z01")+SER->Z01_PREFIX+SER->Z01_NUMERO+SER->Z01_PARCEL,.F.)

		RecLock("Z01",.T.)
		Z01->Z01_FILIAL 		:= SER->Z01_FILIAL
		Z01->Z01_PREFIX 		:= SER->Z01_PREFIX
		Z01->Z01_NUMERO 		:= SER->Z01_NUMERO
		Z01->Z01_PARCEL 		:= SER->Z01_PARCEL
		Z01->Z01_VENCTO 		:= SToD(SER->Z01_VENCTO)
		Z01->Z01_VALOR 		:= SER->Z01_VALOR
		Z01->Z01_NUMBC 		:= SER->Z01_NUMBC
		Z01->Z01_CLIENT 		:= SER->Z01_CLIENT
		Z01->Z01_LOJA 			:= SER->Z01_LOJA
		Z01->Z01_NOME 			:= SER->Z01_NOME
		Z01->Z01_LEGEND		:= "D" 		//|Disponivel
		Z01->Z01_DATALT		:= dDataAlte
		Z01->Z01_HORALT		:= Substr(Time(),1,5)
		Z01->Z01_SITUAC		:= "Incluido Via WorkFlow"
		MsUnlock()

	EndIf

Else

	DbGoto(nRecno)

	RecLock("Z01",.F.)

	If cLeg == NIl .Or. Empty(cLeg)

		DBDelete()
	Else
		Z01->Z01_LEGEND 	:= cLeg
		Z01->Z01_DATALT		:= dDataAlte
		Z01->Z01_HORALT		:= Substr(Time(),1,5)
		Z01->Z01_SITUAC		:= "Alterado Via WorkFlow"
	EndIf

	MsUnlock()

EndIf

Return()
*********************************************************************
Static Function RetEmail(cCliente)//| Obtem Email Cliente
*********************************************************************
Local cMail := ""

If !Empty(cCliente)

	//| Email Financeiro
	cMail := Posicione("SA1",1,xFilial('SA1')+cCliente,"A1_MAILFIN")

	If Empty(cMail)

		//| Email Fiscal
		//		cMail := Posicione("SA1",1,xFilial('SA1')+cCliente,"A1_EMAILNFE")

		If EmpTy(cMail)

			//| Email Comercial
			cMail := Posicione("SA1",1,xFilial('SA1')+cCliente,"A1_EMAIL")

		EndIf
	EndIf
EndIf

If Empty(cMail)
	cMail := cMailFin
EndIf

If lTeste
	cMail := cMailTest
EndIf

Return(cMail)
*********************************************************************
Static Function LevDtVenc()//| Verifica os 5 dias que devem ser contados
*********************************************************************
Local dDataHoje := dDataAlte
Local nDia		:= 0
Local nPulo		:= 0

While lContinua

	nPulo += 1

	If cDow (dDataHoje - nPulo) $ "Monday/Tuesday/Wednesday/Thursday/Friday"
		nDia += 1
	EndIf

	If nDia == 5
		dDataHoje := ( dDataHoje - nPulo )
		Exit
	EndIf

EndDo

Return(dDataHoje)
*********************************************************************
Static Function MenEmail(cQuem)//| Monta Cabecalho e Rodapes para os emails
*********************************************************************
Local cTxt := ""

Do Case

	Case cQuem == "FIN-C" //| Financeiro Cabecalho

		cTxt += '<html>'
		cTxt += '<head>'
		cTxt += '<meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">'
		cTxt += '<title></title>'
		cTxt += '</head>'
		cTxt += '<body style="width: 1024px;"><br><br>'
		cTxt += '<span style="font-weight: bold; font-family: Arial;">Pefin Serasa,</span><br>'
		cTxt += '<span style="font-family: Arial;">Informamos que na data de hoje('+DtoC(dDataAlte)+') os títulos abaixo '+aMenAction[nAct]+':</span><br><br>'
		cTxt += '<span style="font-weight: bold; font-family: Arial;"></span><br>'

		cTxt += '<table style="text-align: left; height: 80px; width: 1024px; font-family: Arial;" border="0" cellpadding="0" cellspacing="0">'
		cTxt += '<tbody>'
		cTxt += '<tr>'
		cTxt += '<td style="vertical-align: top; text-align: center;	width: 96px;	"><span style="font-weight: bold;">Gerencia		</span><br></td>'
		cTxt += '<td style="vertical-align: top; text-align: center;	width: 96px;	"><span style="font-weight: bold;">Cliente		</span><br></td>'
		cTxt += '<td style="vertical-align: top; text-align: Left; 		width: 396px;	"><span style="font-weight: bold;">Nome			</span><br></td>'
		cTxt += '<td style="vertical-align: top; text-align: center; 	width: 122px;	"><span style="font-weight: bold;">Nf/Parcela	</span><br></td>'
		cTxt += '<td style="vertical-align: top; text-align: center; 	width: 93px;	"><span style="font-weight: bold;">Vencimento	</span><br></td>'
		cTxt += '<td style="vertical-align: top; text-align: center; 	width: 221px;	"><span style="font-weight: bold;">Valor		</span><br></td>'
		cTxt += '</tr>'


	Case cQuem == "FIN-R" //| Financeiro Rodape

		cTxt += '</tbody>'
		cTxt += '</table>'
		cTxt += '<br>'
		cTxt += '<br>'
		cTxt += '<br>'
		If nAct == 2
			cTxt += '<span style="font-family: Arial;">Obs.: Somente os Títulos Vencidos a 5 dias.</span><br>'
			cTxt += '<br>'
		EndIf
		cTxt += '<br>'
		cTxt += '<br>'
		cTxt += '<img style="width: 283px; height: 149px;" alt="" src="http://farm8.staticflickr.com/7035/6511431979_4870f54cbb.jpg"><br>'
		cTxt += '<br>'
		cTxt += '</body>'
		cTxt += '</html>'

	Case cQuem == "CLI-C" //| Cliente Inclusao Cabecalho

		cTxt += '<html>'
		cTxt += '<head>'
		cTxt += '<meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">'
		cTxt += '<title></title>'
		cTxt += '</head>'
		cTxt += '<body style="width: 1024px;"><br><br>'
		cTxt += '<span style="font-weight: bold; font-family: Arial;">Porto Alegre, '+StrZero(Day(dDataAlte),2)+'  de '+Mes(dDataAlte)+' de '+StrZero(Ano(dDataAlte),4)+'.'+' </span><br><br>'
		cTxt += '<span style="font-family: Arial;">Prezado(a) senhor(a):</span><br><br>'
		cTxt += '<span style="font-family: Arial;">Informamos V.Sa, que até o presente momento não localizamos a quitação do(s) título(s) relacionado(s) abaixo, e para que não seja(m) encaminhado(s) </span><br>'
		cTxt += '<span style="font-family: Arial;">ao Serasa Experian, solicitamos sua manifestação para regularização do(s) débito(s) pelo telefone (51) 2121.00.25 Setor Financeiro.</span><br>'
		cTxt += '<span style="font-weight: bold; font-family: Arial;"></span><br>'


		cTxt += '<table style="text-align: left; height: 80px; width: 1024px; font-family: Arial;" border="0" cellpadding="0" cellspacing="0">'
		cTxt += '<tbody>'
		cTxt += '<tr>'
		cTxt += '<td style="vertical-align: top; text-align: Left;		width: 300px;	"><span style="font-weight: bold;">Razao		</span><br></td>'
		cTxt += '<td style="vertical-align: top; text-align: center;	width: 96px;	"><span style="font-weight: bold;">Cnpj			</span><br></td>'
		cTxt += '<td style="vertical-align: top; text-align: center; 	width: 122px;	"><span style="font-weight: bold;">Nf/Parcela	</span><br></td>'
		cTxt += '<td style="vertical-align: top; text-align: center; 	width: 93px;	"><span style="font-weight: bold;">Vencimento	</span><br></td>'
		cTxt += '<td style="vertical-align: top; text-align: center; 	width: 121px;	"><span style="font-weight: bold;">Valor		</span><br></td>'
		cTxt += '<td style="vertical-align: top; text-align: center; 	width: 100px;	"><span style="font-weight: bold;">Agencia/Conta</span><br></td>'
		cTxt += '<td style="vertical-align: top; text-align: center; 	width: 192px;	"><span style="font-weight: bold;">Nosso Numero </span><br></td>'
		cTxt += '</tr>'

	Case cQuem == "CLI-R" //| Cliente Inclusao Rodape

		cTxt += '</tbody>'
		cTxt += '</table>'
		cTxt += '<br><br><br>'
		cTxt += '<span style="font-family: Arial;">Em caso de necessidade de segunda via de boleto, favor emitir no site: <a href="http://www.itau.com.br/">www.itau.com.br</a>, clicar em 2ª Via de Boleto, </span><br>'
		cTxt += '<span style="font-family: Arial;">digitar os dados de Agência/Conta e Nosso número, ou solicitar pelo e-mail: boletos@imdepa.com.br.</span><br>'
		cTxt += '<br><br>'
		cTxt += '<span style="font-family: Arial;">Caso já tenha efetuado o pagamento, favor desconsiderar este comunicado.</span><br>'
		cTxt += '<br><br>'
		cTxt += '<img style="width: 283px; height: 149px;" alt="" src="http://farm8.staticflickr.com/7035/6511431979_4870f54cbb.jpg"><br>'
		cTxt += '<br>'
		cTxt += '</body>'
		cTxt += '</html>'

	Case cQuem == "CLU-C" //| Cliente Exclusao Cabecalho

		cTxt += '<html>'
		cTxt += '<head>'
		cTxt += '<meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">'
		cTxt += '<title></title>'
		cTxt += '</head>'
		cTxt += '<body style="width: 1024px;"><br><br>'
		cTxt += '<span style="font-weight: bold; font-family: Arial;">Porto Alegre, '+StrZero(Day(dDataAlte),2)+'  de '+Mes(dDataAlte)+' de '+StrZero(Ano(dDataAlte),4)+'.'+' </span><br><br>'
		cTxt += '<span style="font-family: Arial;">Prezado(a) senhor(a):</span><br><br>'
		cTxt += '<span style="font-family: Arial;">Informamos a V. Sa, que na data de hoje, o(s) título(s) relacionado(s) abaixo foi(ram) excluídos(s) da Serasa Experian:</span><br>'
		cTxt += '<span style="font-weight: bold; font-family: Arial;"></span><br>'

		cTxt += '<table style="text-align: left; height: 80px; width: 1024px; font-family: Arial;" border="0" cellpadding="0" cellspacing="0">'
		cTxt += '<tbody>'
		cTxt += '<tr>'
		cTxt += '<td style="vertical-align: top; text-align: Left;		width: 300px;	"><span style="font-weight: bold;">Razao		</span><br></td>'
		cTxt += '<td style="vertical-align: top; text-align: center;	width: 96px;	"><span style="font-weight: bold;">Cnpj			</span><br></td>'
		cTxt += '<td style="vertical-align: top; text-align: center; 	width: 122px;	"><span style="font-weight: bold;">Nf/Parcela	</span><br></td>'
		cTxt += '<td style="vertical-align: top; text-align: center; 	width: 93px;	"><span style="font-weight: bold;">Vencimento	</span><br></td>'
		cTxt += '<td style="vertical-align: top; text-align: center; 	width: 121px;	"><span style="font-weight: bold;">Valor		</span><br></td>'
		cTxt += '</tr>'

	Case cQuem == "CLU-R" //| Cliente Exclusao Rodape

		cTxt += '</tbody>'
		cTxt += '</table>'
		cTxt += '<br><br><br>'
		cTxt += '<span style="font-family: Arial;">Agradecemos pela quitação do débito.</span>'
		cTxt += '<br><br>'
		cTxt += '<span style="font-family: Arial;">Atenciosamente,</span>'
		cTxt += '<br><br>'
		cTxt += '<img style="width: 283px; height: 149px;" alt="" src="http://farm8.staticflickr.com/7035/6511431979_4870f54cbb.jpg"><br>'
		cTxt += '<br>'
		cTxt += '</body>'
		cTxt += '</html>'

EndCase

Return(cTxt)

*********************************************************************
Static Function GrvUExec()  //| Salva ultimo vencimento analisado
*********************************************************************

DbSelectArea("SX6")

If DbSeek(xFilial("SX6")+"IM_UEWFSER",.F.)
	RecLock("SX6",.F.)
	SX6->X6_CONTEUD := alltrim(dtoc(dDataVenc))
	Msunlock()
EndIf

Return()