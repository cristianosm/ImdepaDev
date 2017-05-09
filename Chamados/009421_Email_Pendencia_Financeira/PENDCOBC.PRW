#INCLUDE 'RwMake.ch'
#INCLUDE 'TbiConn.ch'
#INCLUDE 'TopConn.ch'
#INCLUDE 'Protheus.ch'
#INCLUDE 'FileIO.ch'

/* Exemplo: MV_DIAPFIN
{	{">=","30"	,"<="	,"180"	,"financeiro.cobranca4@imdepa.com.br"}
	{">=","15"	,"<="	,"30"	,"financeiro.cobranca30@imdepa.com.br"}
	{">=","3"	,"<="	,"3"		,"boletos@imdepa.com.br"}
	{">=","5"	,"<="	,"5"		,"boletos@imdepa.com.br"}}
*/

#Define _OPMAIOR	1	//| Operador Maior ou igual, contido no MV_DIAPFIN
#Define _DIASI		2	//| Dias Inicial, contido no MV_DIAPFIN
#Define _OPMENOR	3	//| Operador Menor ou igual, contido no MV_DIAPFIN
#Define _DIASF		4	//| Dias Final, contido no MV_DIAPFIN
#Define _EMAIL		5	//| Email Financeiro, contido no MV_DIAPFIN

#Define _EMAILBOL "boletos@imdepa.com.br"

#Define _2VIA_SEMPRE  		1 //|  Envia email 2via para clientes que sempre devem receber. A1_2VIA = SEMPRE
#Define _2VIA_HOJE  			2 //|  Envia email 2via para Clientes que Hoje devem receber. A1_2via = HOJE
#Define _2VIA_GREVE  			3 //|  Envia email 2via para Clientes que possuem Banco em Greve e A1_2Via = NUNCA
#Define _2VIA_PENDENTES 	4 //|  Envia email 2via para Clientes que est�o com titulos atrasados...
#Define _PROCESSO_				3 //| Contem o Numero de vezes que deve ser executa o For para atender os defines _2VIA....

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PENDCOBC  �Autor  �   AGOSTINHO LIMA   � Data �  18/01/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �GERA RELATORIO DE PENDENCIAS DE COBRANCA PARA OS CLIENTES   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8 IMDEPA ROLAMENTOS - FINANCEIRO                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

*********************************************************************
User Function PENDCOBC()
*********************************************************************

	Private cLink				:= ""
	Private cBanco				:= ""
	Private lmodoTeste 			:= .F.
	Private cEmailTeste			:= "cristiano.machado@imdepa.com.br"
	Private aParMV   				  		//| Dados em Formato Array, contem os parametros de execucao nos pendentes...
	Private nFreq				:= 0  		//| Posicao da array do Parametro (MV_DIAPFIN) que deve ser utilizado.
	Private aParFreq	  		:= {} 		//| Conteudo do parametro que deve ser utilizado conforme selecionado o (nFreq)

	Private l2V_SEMPRE 		:= .F. 	//|  Envia email 2via para clientes que sempre devem receber. A1_2VIA = SEMPRE
	Private l2V_HOJE  		:= .F.		//|  Envia email 2via para Clientes que Hoje devem receber. A1_2via = HOJE
	Private l2V_GREVE  		:= .F. 	//|  Envia email 2via para Clientes que possuem Banco em Greve e A1_2Via = NUNCA
	Private l2V_PENDENTES	:= .F. 	//|  Envia email 2via para Clientes que est�o com titulos atrasados...
	Private aFreq				:= {3,4}	//| Informar as posicoes no Array do Parametro MV_DIAPFIN que serao usados no Modo: _2VIA_PENDENTES para avaliar as datas dos titulos em atraso

	//If !lmodoTeste
		Prepare Environment Empresa '01' Filial '09' FunName 'PENDCOBF' Tables 'SE1','SA1'
	//EndIf

	aParMV   		:= SX6->(&( U_GetSx6("MV_DIAPFIN") ))  //| Dados em Formato Array, contem os parametros de execucao nos pendentes...

	Conout("PENCOBC - Inicio Processamento ........................................"+DtoC(dDataBase) + " " + Time() )
	
	If ( Time() >= '12:00:00' .And. Time() <= '14:00:00' ) // Pendentes...

		nTpExec := _2VIA_PENDENTES

		Controle(nTpExec) //| Controle para Definir Qual Tipo de Execucao esta em Processo...

		Processa() //| Executa a Query para obter os clientes que devem ser informados sobre pendencias...

	ElseIf ( Time() >= '18:00:00' .And. Time() <= '20:00:00' ) // Demais Execucoes...
	
		For nTpExec := 1 To _PROCESSO_ //Executa uma avaliacao para cada tipo de execucao ... _2VIA_etc..

			Controle(nTpExec) //| Controle para Definir Qual Tipo de Execucao esta em Processo...

			Processa() //| Executa a Query para obter os clientes que devem ser informados sobre pendencias...

		Next

	EndIf

	Conout("PENCOBC - Fim Processamento ..........................................."+DtoC(dDataBase) + " " + Time() )

	If !lmodoTeste
		Reset Environment
	EndIf

ALERT("FIM-PENDCOBC")

Return()
*******************************************************************************
Static Function Controle(nTpExec)//| Controle para Definir Qual Tipo de Execucao esta em Processo...
*******************************************************************************


	l2V_SEMPRE := l2V_HOJE := l2V_GREVE := l2V_PENDENTES := .F.

	If nTpExec == _2VIA_SEMPRE
		Conout("PENCOBC - Executando Modo: SEMPRE......................................"+DtoC(dDataBase) + " " + Time() )
		l2V_SEMPRE := .T.
	ElseIf nTpExec == _2VIA_HOJE
		Conout("PENCOBC - Executando Modo: HOJE........................................"+DtoC(dDataBase) + " " + Time() )
		l2V_HOJE 	:= .T.
	ElseIf nTpExec == _2VIA_GREVE
		Conout("PENCOBC - Executando Modo: GREVE......................................."+DtoC(dDataBase) + " " + Time() )
		l2V_GREVE 	:= .T.
	ElseIf nTpExec == _2VIA_PENDENTES
		Conout("PENCOBC - Executando Modo: PENDENTE...................................."+DtoC(dDataBase) + " " + Time() )
		l2V_PENDENTES	:= .T.
	EndIf

Return()
*******************************************************************************
Static Function Processa()//| Executa a Query para obter os clientes que devem ser informados sobre pendencias...
*******************************************************************************

	//| Processo de Titulos Pendentes....
	If l2V_PENDENTES

		For nA := 1 To Len(aFreq) //| aFreq possui o Numero de Dias em atraso que devem ser avaliados... 1,2,3 e etc....
			nFreq			:= aFreq[nA]
			aParFreq		:= aParMV[nFreq]

			// Executa a Query para obter os clientes que devem ser informados sobre pendencias...
			DisparaQuery()

			// Processa os Dados obtido na Query....
			ProcessaDados()
		Next

	//| Processo Normal ... Titulos em dia...Clientes que recebem intrucoes por email
	Else
		// Executa a Query para obter os clientes que devem ser informados sobre pendencias...
		DisparaQuery()

		// Processa os Dados obtido na Query....
		ProcessaDados()
	EndIf


Return()
*******************************************************************************
Static Function DisparaQuery()// Executa a Query para obter os clientes que devem ser informados sobre pendencias...
*******************************************************************************

	Local cQuery 			:= ""
	local cFiltro			:= ""

	cFiltro := Filtro()

	//| Monta a Query Conforme o Caso......
	cQuery += "   SELECT   E1_CLIENTE, 	E1_LOJA, 	E1_NOMCLI, 	A1_PESSOA, 	A1_CGC, "
	cQuery += "   					A1_DDD, 			A1_TEL, 		A1_EMAIL, 		A1_MAILFIN, 	A1_MAILNFE, "
	cQuery += "   					E1_PORTADO, 	E1_AGEDEP,	E1_CONTA, 		E1_NUMBCO,  "
	cQuery += "   					E1_PREFIXO, 	E1_NUM, 		E1_PARCELA, 	E1_EMISSAO,  "
	cQuery += "   					E1_VENCTO, 	E1_SALDO, 	E1_FILORIG, 	E1_DEMACOB ,  "
	cQuery += "   					TRUNC(SYSDATE) - TO_DATE(E1_VENCTO,'YYYYMMDD') ATRASO "

	cQuery += "	FROM  SE1010 E1 INNER JOIN SA1010 A1 "
	cQuery += "	ON    E1.E1_FILIAL   = A1.A1_FILIAL "
	cQuery += "	AND   E1.E1_CLIENTE  = A1.A1_COD "
	cQuery += "	AND   E1.E1_LOJA     = A1.A1_LOJA "

	cQuery += "	WHERE E1_FILIAL      = ' ' " 
	cQuery += "	AND A1.D_E_L_E_T_    = ' ' "
	cQuery += " AND E1.D_E_L_E_T_ 	 = ' ' "

	cQuery += cFiltro

	//cQuery += "   ORDER BY ATRASO DESC  "
	cQuery += "   ORDER BY   A1_CGC, E1_PORTADO, E1_VENCREA   "

	U_ExecMySql(cQuery,"PEND1","Q",lmodoTeste) //TCQUERY cQuery NEW ALIAS ("PEND1")

Return()
*******************************************************************************
Static Function Filtro()// Filtro utilizado no where da query Conforme tipo execucao
*******************************************************************************

	Local cPortadores 	:= "" // Obtem os Bancos que estao em greve....
	Local cFiltro			:= ""
	Local cTipoAtraso	:= U_GetSx6("MV_TIPOATR")
	Local cDtVencNova	:= ""
	Local cDtVencVelha	:= ""
	Local cDthoje			:= Dtos( dDatabase )

	If  l2V_SEMPRE 	//|  Envia email 2via para clientes que sempre devem receber. A1_2VIA = SEMPRE

		cFiltro += "   AND   A1.A1_RECBOLE  = 'S' "
		cFiltro += "   AND   E1.E1_EMISSAO  < '"+cDthoje+"' "
		cFiltro += "   AND   E1.E1_VENCREA  > '"+cDthoje+"' "
		cFiltro += "   AND   E1.E1_DEMACOB  = ' ' "

	ElseIf l2V_HOJE 	//|  Envia email 2via para Clientes que Hoje devem receber. A1_2via = HOJE

		cFiltro += "   AND   A1.A1_RECBOLE  = 'H' "
		cFiltro += "   AND   E1.E1_VENCREA  >= '"+cDthoje+"' "
		cFiltro += "   AND   E1.E1_DEMACOB  <  '"+cDthoje+"' "

	ElseIf l2V_GREVE	//|  Envia email 2via para Clientes que possuem Banco em Greve e A1_2Via =	 NUNCA

		cPortadores 	:= BancosGreve() // Obtem os Bancos que estao em greve....
		cFiltro += "   AND   E1.E1_PORTADO  IN("+cPortadores+")"
		cFiltro += "   AND   E1.E1_VENCREA  >= '"+cDthoje+"' "
		cFiltro += "   AND   E1.E1_DEMACOB  = ' ' "

	EndIf

	If l2V_PENDENTES	//|  Envia email 2via para Clientes que estao com titulos atrasados...

		cDtVencNova		:= Dtos( dDatabase - Val(aParFreq[_DIASI]) )
		cDtVencVelha	:= Dtos( dDatabase - Val(aParFreq[_DIASF]) )

		cFiltro += "   AND   E1.E1_VENCREA     BETWEEN  '"+cDtVencVelha+"' AND  '"+cDtVencNova+"' "
		cFiltro += "   AND   E1.E1_DEMACOB    <  '"+cDtVencVelha+"' "

	EndIf

	cFiltro += "   AND   E1.E1_EMISSAO    < E1.E1_VENCTO "
	cFiltro += "   AND   E1.E1_SALDO      >  0 "
	cFiltro += "   AND   E1.E1_OCORREN  		> ' ' "
	cFiltro += "   AND   E1.E1_DATABOR  		> ' ' "
	cFiltro += "   AND   E1.E1_TIPO       IN  " + cTipoAtraso +  " "
	


Return(cFiltro)
*******************************************************************************
Static Function 	ProcessaDados() // Processa os Dados obtido na Query....
*******************************************************************************

	Private 	lEnvCli			:= SX6->( U_GetSx6("MV_ENVPCLI") )//
	Private 	cNomeCli 		:= AllTrim(PEND1->E1_NOMCLI)
	Private 	cFone			:= AllTrim("("+RIGHT(AllTrim(PEND1->A1_DDD),2)+") "+PEND1->A1_TEL)
	Private 	cTabCodLj 		:= "PEND1->E1_CLIENTE+PEND1->E1_LOJA"
	Private 	cGetMailCli		:= "IF(!Empty(PEND1->A1_MAILFIN),AllTrim(PEND1->A1_MAILFIN),IF(!Empty(PEND1->A1_MAILNFE),AllTrim(PEND1->A1_MAILNFE),AllTrim(PEND1->A1_EMAIL)))"
	Private 	cHtml     		:= ""
	Private 	cHtmlCab		:= ""
	Private 	cHtmldet		:= ""
	Private 	cHtmlRod		:= ""
	Private 	cCgc 			:= PEND1->A1_CGC //AllTrim(Transform(PEND1->A1_CGC,LEFT(PicPes(PEND1->A1_PESSOA),LEN(PicPes(PEND1->A1_PESSOA))-2)))
	Private 	cEMailcli 		:= ""				// Salva o email do cliente para posterior envio
	Private	cCorLin				:= "White" 	// Cor que vai ser utilizada na Linha...
	Private 	nTotalCli		:= 0					// Armazena saldo total do cliente....
	Private 	aMarkTitCl		:= {} 				// Array com Titulos que devem ser Marcados como enviados aos clientes...

	DbSelectArea("PEND1");DbGotop()
	While !( Eof() )

		// Atualiza Variaveis Cliente...
		cCodCli			:= PEND1->E1_CLIENTE+PEND1->E1_LOJA
		cCgc 				:= PEND1->A1_CGC //If(PEND1->A1_PESSOA=="J",Transform(PEND1->A1_CGC,"@R 999.999.999/9999-99"),Transform(PEND1->A1_CGC,"@R 999.999.999-99") )
		cNomeCli 		:= AllTrim(PEND1->E1_NOMCLI)
		cFone				:= Transform( PEND1->A1_DDD + PEND1->A1_TEL, "@R (99) 9999-99999")
		cEMailcli		:= &cGetMailCli.
		nTotalCli 		:= 0
		cHtml				:= cHtmlCab				:= cHtmldet				:= cHtmlRod				:= ""
		cCorLin    	:= "#E2E2E2"

		// Adiciona Cliente no HTML
		cHtmlCab += MontaHtml("CLI", cCgc, cNomeCli, cFone)

		DbSelectArea("PEND1")
		While !Eof() .And. cCodCli = &cTabCodLj. // Verifica Titulos do respectivo cliente...

			// Define Cor da linha
			cCorLin := If(cCorLin == "White","#E2E2E2","White")

			// inclue o Titulo no Html...
			cHtmldet += MontaHtml("TIT")

			// Salva Titulos que devem ser marcados como enviados...
			If !Empty(cEMailcli).And. lEnvCli
				Conout("PENCOBC - Titulo Selecionado para Envio: "+ PEND1->E1_PREFIXO+PEND1->E1_NUM+PEND1->E1_PARCELA +"................."+DtoC(dDataBase) + " " + Time() )
				AADD ( aMarkTitCl , { cEMailcli , XFILIAL("SE1") , cCodCli , PEND1->E1_PREFIXO , PEND1->E1_NUM , PEND1->E1_PARCELA } )
			EndIf

			DbSelectArea("PEND1")
			DbSkip()

		EndDo

			// Monta os Totais no Html...
		cHtmlRod += MontaHtml("TOT")

		// Monta Html e Envia email...
		If !Empty(cEMailcli) .And. lEnvCli

			cHtmlCli := MontaHtml("CAB")  //|  Montas Html de Cabecalho...
			cHtmlCli += cHtmlCab + cHtmldet + cHtmlRod//cHtml
			cHtmlCli += MontaHtml("ROD")  //|  Montas Html de Cabecalho...

			SendMail() // Envia o Email ao Cliente...

		EndIf

	EndDo

	DbCloseArea("PEND1")


Return()
*******************************************************************************
Static Function MontaHtml(cQuem) // Monta o Html Conforme parametros..
*******************************************************************************
	Local cHtmAux	:= ""

	If cQuem == "CAB" // Html Cabecalho ...

		cHtmAux += '<html><body><pre width="800"><IMG SRC="http://www.gbrparts.com.br/ass/logo.gif" align="middle">'
		cHtmAux += '<font face="Arial"><b>&nbsp;&nbsp;&nbsp;&nbsp;Imdepa Rolamentos Importa&ccedil;&atilde;o e Com&eacute;rcio LTDA</b></font></pre><br>'
		cHtmAux += '<pre><font face="Arial">Porto Alegre, ' + RIGHT(DTOS(DDATABASE),2) + ' de ' + MES(DDATABASE) + ' de ' + LEFT(DTOS(DDATABASE),4)+'.<font></pre>'
		cHtmAux += '<pre width="800"><font face="Arial">Prezados Senhores:<br>'

		If l2V_PENDENTES
			cHtmAux += 'Consta(m) aberto(s) em nosso controle a(s) duplicata(s) abaixo relacionada(s): </font></pre><br>'
		Else
			cHtmAux += 'Estamos enviando os dados do(s) titulo(s) abaixo para facilitar o pagamento no caso de nao recebimento do Boleto Impresso:</font></pre><br>'
		EndIf
	EndiF

	If cQuem == "CLI" // Html Cliente...

		cHtmAux += '<table border="0" width="750">'  // Formato para envio para o cliente
		cHtmAux += '<tr valign  = "middle" bgcolor="#FF7575">'
		cHtmAux += '<td colspan = "3" align="center"><font size = "2" face="Verdana"><b>CNPJ Sacado '+cCgc+'</b></font></td>'

		If l2V_PENDENTES
			cHtmAux += '<td colspan = "6" align="center"><font size = "2" face="Verdana"><b>'+cNomeCli+'</b></font></td>'
		Else
			cHtmAux += '<td colspan = "5" align="center"><font size = "2" face="Verdana"><b>'+cNomeCli+'</b></font></td>'
		Endif

		cHtmAux += '<td colspan = "2" align="center"><font size = "2" face="Verdana"><b>'+cFone+'</b></font></td>'

		cHtmAux += '</tr>'
		cHtmAux += '<tr bgcolor="#E2E2E2">'
		cHtmAux += '<th align="center"><font size = "2" face="Arial"><b>Filial</b></font></td>'

		If l2V_PENDENTES
			cHtmAux += '<th align="center"><font size = "2" face="Arial"><b>Qt Dias Atraso</b></font></td>'
		EndIf

		cHtmAux += '<th align="center"><font size = "2" face="Arial"><b>Banco</b></font></td>'
		cHtmAux += '<th align="center"><font size = "2" face="Arial"><b>Agencia</b></font></td>'
		cHtmAux += '<th align="center"><font size = "2" face="Arial"><b>Conta</b></font></td>'
		cHtmAux += '<th align="center"><font size = "2" face="Arial"><b>Nosso Numero</b></font></td>'
		cHtmAux += '<th align="center"><font size = "2" face="Arial"><b>Nota Fiscal</b></font></td>'
		cHtmAux += '<th align="center"><font size = "2" face="Arial"><b>Numero Titulo</b></font></td>'
		cHtmAux += '<th align="center"><font size = "2" face="Arial"><b>Emissao</b></font></td>'
		cHtmAux += '<th align="center"><font size = "2" face="Arial"><b>Vcto</b></font></td>'

		If l2V_PENDENTES
			cHtmAux += '<th align="center"><font size = "2" face="Arial"><b>Valor em Atraso</b></font></td>'
		Else
			cHtmAux += '<th align="center"><font size = "2" face="Arial"><b>Valor Titulo</b></font></td>'
		EndIf

		cHtmAux += '</tr>'

	EndIf

	If cQuem == "TIT" // Html Titulos...

		ObtemLink(@cLink, @cBanco) // Grava o Link e Banco

		cHtmAux+='<tr nowrap align="center" bgcolor='+cCorLin+'>'
		cHtmAux+='<td><font size="2" face="Arial">'+PEND1->E1_FILORIG+"-"+Posicione("SM0",1,cEmpAnt+PEND1->E1_FILORIG,"M0_FILIAL")+'</font></td>'

		If l2V_PENDENTES
			cHtmAux+='<td><font size="2" face="Arial">'+cValToChar(PEND1->ATRASO)+'</font></td>'
		EndIf

		If !Empty(cLink)
			cHtmAux+='<td><font size="2" face="Arial"><a href="'+ cLink +'">'+ cBanco +'</a></font></td>'
		Else
			cHtmAux+='<td><font size="2" face="Arial">'+ cBanco +'</font></td>'
		EndIf

		cHtmAux+='<td><font size="2" face="Arial">'+PEND1->E1_AGEDEP+'</font></td>'
		cHtmAux+='<td><font size="2" face="Arial">'+PEND1->E1_CONTA+'</font></td>'
		cHtmAux+='<td><font size="2" face="Arial">'+IF(PEND1->E1_PORTADO <> "237",PEND1->E1_NUMBCO,SUBSTR(PEND1->E1_NUMBCO,1,LEN(AllTrim(PEND1->E1_NUMBCO))-1))+'</font></td>'
		cHtmAux+='<td><font size="2" face="Arial">'+PEND1->E1_NUM+'</font></td>'
		cHtmAux+='<td><font size="2" face="Arial">'+PEND1->E1_PREFIXO+PEND1->E1_NUM+PEND1->E1_PARCELA+'</font></td>'
		cHtmAux+='<td><font size="2" face="Arial">'+RIGHT(PEND1->E1_EMISSAO,2)+"/"+SUBSTR(PEND1->E1_EMISSAO,5,2)+"/"+LEFT(PEND1->E1_EMISSAO,4)+'</font></td>'
		cHtmAux+='<td><font size="2" face="Arial">'+RIGHT(PEND1->E1_VENCTO,2)+"/"+SUBSTR(PEND1->E1_VENCTO,5,2)+"/"+LEFT(PEND1->E1_VENCTO,4)+'</font></td>'
		cHtmAux+='<td><font size="2" face="Arial">'+TRANSFORM(PEND1->E1_SALDO,'@E 999,999,999.99')+'</font></td>'
		cHtmAux+='</tr>'

				// Atualiza Totais...
		nTotalCli += PEND1->E1_S/**/ALDO

	EndIf


	If cQuem == "TOT" /// Html Totais...

		cHtmAux+='<tr nowrap align="center" >'
		If l2V_PENDENTES
			cHtmAux+='<td colspan = "10" nowrap align="center">'+" "+'</td>'
		Else
			cHtmAux+='<td colspan = "09" nowrap align="center">'+" "+'</td>'
		EndIf
		cHtmAux+='<td  bgcolor="#FF7575"><font size="2" face="Arial"><b>'+Transform(nTotalCli,'@E 999,999,999.99')+'</b></font></td>'
		cHtmAux+='</tr>'
		cHtmAux+='</table>'
		cHtmAux+='<br>'

	EndIf


	If cQuem == "ROD" // Html Rodape...

		cHtmAux += '<pre width="800"><font face= "Arial" ><b>CNPJ Cedente: 88613922001278 - Imdepa Rolamentos.</b></font></pre>'
		cHtmAux += '<pre width="800"><font face= "verdana" color="red"><b>SE O PAGAMENTO J&Aacute; FOI EFETUADO, FAVOR DESCONSIDERAR ESTE E-MAIL.</b></font></pre><br><br>'

		cHtmAux += '<pre width="800"><p><font face= "verdana" color="blue">***AP&Oacute;S 5 DIAS CORRIDOS DO VENCIMENTO, O ENVIO DO BOLETO PARA CART&Oacute;RIO &Eacute; AUTOMATICO***</font><br>'

		cHtmAux += '<pre width="800"><p><font face="Arial">Em caso de necessidade de segunda via de boleto, favor </font><font face= "verdana" color="blue">&nbsp;CLICAR NO NOME DO BANCO</font><font face="Arial">.<br><br>'
		cHtmAux += 'Se preferir, solicitar a Segunda Via no email boletos@imdepa.com.br ou &nbsp; entre em contato pelo telefone: (51) 2121-0025.<br><br>
		cHtmAux += 'BOLETOS &Aacute; VENCER OU COM VENCIMENTO NO DIA, FAVOR SOLICITAR PARA A FILIAL DA COMPRA, DIRETO COM O SEU VENDEDOR</font>.</pre>'
		cHtmAux += '<br>'
		cHtmAux += '<pre width="800"><font face="Arial">Atenciosamente,</pre>'
		cHtmAux += '<pre width="800">Imdepa Rolamentos<br><br>'
		cHtmAux += 'Departamento Financeiro</font></p></pre>'
		cHtmAux += '</html></body>'

	Endif


Return( cHtmAux )
*******************************************************************************
Static Function ObtemLink(cLink, cBanco)// Obtem Link e Banco  Conforme o Banco...
*******************************************************************************
	Local aLink  := {}
	Local cPar	 :=  SuperGetMV("MV_LINK"+PEND1->E1_PORTADO, .F., "{'http://www.imdepa.com.br/','Contate a Imdepa'}", Nil ) //( SX6->(U_GetSx6("MV_LINK"+PEND1->E1_PORTADO,""," ")) )
    
	//Alert("cLink: " + cLink + " cBanco: " + cBanco + " cPar: " + cPar )

	If !Empty(cPar) .And. Alltrim(cPar) <> "X"
		aLink := &cPar
	EndIf

	If !Empty(aLink)
		cLink  := aLink[1]
		cBanco := aLink[2]
	Else
		cLink  := ""
		cBanco	:=  AllTrim( Posicione("SA6",1,XFILIAL("SA6")+PEND1->E1_PORTADO,"A6_NOME") )
	EndIf

Return()
*******************************************************************************
Static Function SendMail() // Envia o Email ao Cliente...
*******************************************************************************

	Local cFrom 			:= _EMAILBOL
	Local cTo				:= cEMailcli
	Local cCopia    	:= SX6->(U_GetSx6("MV_ECONTTI"))
	Local cBcc				:= cCopia
	Local cSubject		:= ""
	Local cBody			:= cHtmlCli
	Local cAttach		:= ""
	Local cRet				:= ""


	Do Case
	Case l2V_SEMPRE
		cSubject		:= "Boleto Automatico"
	Case l2V_HOJE
		cSubject		:= "Boleto Solicitado"
	Case l2V_GREVE
		cSubject		:= "Segunda via Boleto"
	Case l2V_PENDENTES
		cSubject		:= "Pendencias Financeiras"
	End Do

	Conout("PENCOBC - Enviando EMail Para: "+ PadR(cTo,40,".") +DtoC(dDataBase) + " " + Time() )
	Conout("PENCOBC - Enviando EMail Copia: "+ PadR(cCopia,39,".") +DtoC(dDataBase) + " " + Time() )

	If lmodoTeste
		cTo		:= cEmailTeste
		cCopia	:= cEmailTeste

	EndIf

	U_EnvMyMail(cFrom,cTo,cBcc,cSubject,cBody,cAttach)

	If Empty(cRet)

		MarcaTitulos()

	EndIf

Return()
*******************************************************************************
Static Function MarcaTitulos()// Marca os Titulos Enviados aos clientes Por alguma Raz�o
*******************************************************************************

	Local	cUpdate := ""

	For N:= 1 To Len ( aMarkTitCl )
		// Atualiza no Titutlo o Ultimo Envio ao Cliente....
		cUpdate	:= "Update "
		cUpdate 	+= "SE1010 Set E1_DEMACOB = '"+ Dtos(DDATABASE) + "' "
		cUpdate 	+= "Where "
		cUpdate 	+= " E1_FILIAL =  '"	 					+ aMarkTitCl[N][2] + "' And "
		cUpdate 	+= " E1_CLIENTE||E1_LOJA  =  '"	+ aMarkTitCl[N][3] + "' And "
		cUpdate 	+= " E1_PREFIXO =  '"	 					+ aMarkTitCl[N][4] + "' And "
		cUpdate 	+= " E1_NUM =  '"	 						+ aMarkTitCl[N][5] + "' And "
		cUpdate 	+= " E1_PARCELA =  '"	 					+ aMarkTitCl[N][6] + "' And "
		cUpdate 	+= " D_E_L_E_T_ =  ' ' "

		if !lmodoTeste
			U_ExecMySql(cUpdate,"","E",lmodoTeste)
		EndIf
	 	
	 	// Desmarca em os Cliente nas execucoes ... Apenas Hoje...
		If  l2V_HOJE //
			cUpdate	:= "Update "
			cUpdate 	+= "SA1010 Set A1_RECBOLE = 'N' "
			cUpdate 	+= "Where "
			cUpdate 	+= " A1_FILIAL = '"+xFilial("SA1")+"'  And "
			cUpdate 	+= " A1_COD||A1_LOJA  =  '"	+ aMarkTitCl[N][3] + "' And "
			cUpdate 	+= " D_E_L_E_T_ =  ' ' "

			U_ExecMySql(cUpdate,"","E",lmodoTeste)

		EndIf

	Next

	aMarkTitCl	:= {}

Return()
*******************************************************************************
Static Function BancosGreve()// Obtem Informacoes de Bancos que estao em Greve ... Para Envio dos seus respectivos titulos aos clientes.
*******************************************************************************

	Local 	aStruFile 		:= { { "BANCO" , "C" , 3, 0},{ "DESC" , "C" , 50, 0},{ "GREVE" , "C" , 3, 0},{ "DATAA" , "D" , 8, 0} }
	Local aStruIndex		:= { "BANCO" }
	Local cPath				:= Nil
	Local cNameFile		:= "CAD2VIAG"
	Local cDriver			:= Nil
	Local lReplace			:= .F.
	Local cPath				:= "\banco\"
	local cAliasGrev		:= "TGRE" //GetNextAlias()
	local cRetorno			:= ""
	local lFirst				:= .T.

	cAliasGrev := U_MyFile( aStruFile, aStruIndex, cPath, cNameFile, cAliasGrev, cDriver, lReplace )

	DbSelectArea("TGRE");DbGotop()
	While !Eof()

		If ( TGRE->GREVE ) == "SIM"

			If lFirst
				lFirst := .F.
			Else
				cRetorno += ","
			EndIf

			cRetorno += "'" + TGRE->BANCO + "'"

		EndIf

		DbSelectArea("TGRE")
		DbSkip()

	EndDo

	If Empty(cRetorno)
		cRetorno := "'XXX'"
	Endif

Return(cRetorno)