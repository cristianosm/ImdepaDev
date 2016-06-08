#include "TopConn.ch"
#include "rwmake.ch"
#include "ap5mail.ch"
#include 'tbiconn.ch'

#IFNDEF CRLF
	#DEFINE CRLF ( chr(13)+chr(10) )
#ENDIF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMDA940       ºAutor ³Edivaldo G.Cordeiro º Data ³  26/01/15º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Orçamentos Pendente PROMO                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Work-Flow                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*******************************************************************************
User Function IMDA940()
*******************************************************************************

	Local   	nRecNo
	Local   	aVendedores	:={}
	Local   	cHtml

	Private 	aLista  	:= {}
	Private 	lResult 	:= .F.
	Private 	cError
	Private 	nDiasConsiderado
 
	Prepare Environment Empresa '01' Filial '05' FunName 'IMDA940' Tables 'SA3','SU5','SU7','SF4','SA1','SUA'

	cServer          := GetMV('MV_RELSERV')
	cUser            := GetMV('MV_RELACNT')
	cPass            := GetMV('MV_RELPSW')
	lAuth            := Getmv("MV_RELAUTH")
	nDiasConsiderado := GetMv('MV_IMDA940')

	ConsultaGer()//Gerente

	DbSelectArea("TMK3")
	While (!Eof())

		If !Empty(TMK3->A1_GERVEN)
			aAdd(aVendedores,{TMK3->A1_GERVEN,'A1_GERVEN'})
		Endif
 
		DbSkip()
	EndDo

  
	For i=1 to Len(aVendedores)
    	
		IMDA940B(aVendedores[i,1],aVendedores[i,2])
		
	Next i
 
	aVendedores:={}
	
	//Vendedores Interno
	 ConsultaVend()
	 
	DbSelectArea("TMK3")
	While (!Eof())

		If !Empty(TMK3->A1_VENDEXT)
			aAdd(aVendedores,{TMK3->A1_VENDEXT,'A1_VENDEXT'})
		Endif
 
		DbSkip()
	EndDo

  
	For i=1 to Len(aVendedores)
    	
		IMDA940B(aVendedores[i,1],aVendedores[i,2])
		
	Next i
 
	aVendedores:={}	
		

	Reset Environment

Return
*******************************************************************************
Static Function ConsultaGer()//Gerente
*******************************************************************************

	cQuery := " SELECT A1_GERVEN" 
	cQuery +=" FROM " + RetSqlName("SUB" )+ " SUB, "
	cQuery +=         	 RetSQLName("SUA" )+ " SUA, "
	cQuery +=  	   		 RetSQLName("SB1" )+ " SB1, "
	cQuery +=  	   		 RetSQLName("SA1" )+ " SA1  "

	cQuery +=" WHERE A1_FILIAL = '"+xFilial("SA1")+"' "	
	cQuery +=" AND UA_FILIAL=UB_FILIAL"
	cQuery +=" AND B1_FILIAL=UB_FILIAL"
	cQuery +=" AND UA_NUM=UB_NUM"
	cQuery +=" AND B1_COD=UB_PRODUTO"
	cQuery +=" AND B1_OBSTPES <>' '"     // Item PROMMO

	cQuery += " AND UA_CANC <> 'S' "
	cQuery += " AND UA_EMISSAO >='"+ DTOS(DDATABASE-nDiasConsiderado) + "'"
	cQuery += " AND UA_STATUS <> 'NF.' "
	cQuery += " AND UA_NUMSC5 = ' ' "
	cQuery += " AND A1_COD=UA_CLIENTE"
	cQuery += " AND A1_LOJA=UA_LOJA"

	cQuery += " AND SUB.D_E_L_E_T_  =' ' "
	cQuery += " AND SUA.D_E_L_E_T_  =' ' "
	cQuery += " AND SA1.D_E_L_E_T_  =' ' "

	cQuery += " GROUP BY A1_GERVEN"
		
	U_ExecMySql(cQuery , "TMK3" , "Q", .F. ) 

Return()

*******************************************************************************
Static Function ConsultaVend()//Vendedor Interno
*******************************************************************************

	cQuery := " SELECT A1_VENDEXT" 
	cQuery +=" FROM " + RetSqlName("SUB" )+ " SUB, "
	cQuery +=         	RetSQLName("SUA" )+ " SUA, "
	cQuery +=  	   		RetSQLName("SB1" )+ " SB1, "
	cQuery +=  	   		RetSQLName("SA1" )+ " SA1  "

	cQuery +=" WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
	cQuery +=" AND UA_FILIAL=UB_FILIAL"
	cQuery +=" AND B1_FILIAL=UB_FILIAL"
	cQuery +=" AND UA_NUM=UB_NUM"
	cQuery +=" AND B1_COD=UB_PRODUTO"
	cQuery +=" AND B1_OBSTPES <>' '"     // Item PROMMO

	cQuery += " AND UA_CANC <> 'S' "
	cQuery += " AND UA_EMISSAO >='"+ DTOS(DDATABASE-nDiasConsiderado) + "'"
	cQuery += " AND UA_STATUS <> 'NF.' "
	cQuery += " AND UA_NUMSC5 = ' ' "
	cQuery += " AND A1_COD=UA_CLIENTE"
	cQuery += " AND A1_LOJA=UA_LOJA"

	cQuery += " AND SUB.D_E_L_E_T_  =' ' "
	cQuery += " AND SUA.D_E_L_E_T_  =' ' "
	cQuery += " AND SA1.D_E_L_E_T_  =' ' "

	cQuery += " GROUP BY A1_VENDEXT"
		
	U_ExecMySql(cQuery , "TMK3" , "Q", .F. ) 

Return()



*******************************************************************************
Static  Function IMDA940B(cVend,cTipo)
*******************************************************************************
Local aDadosMov
Local cPara      	:= ' '
Local CEMAILBCC  	:= 'edivaldo@imdepa.com.br'
Local cMailDir   	:= ALLTRIM(GETMV("MV_EGERGV"))
Local cEndMail   	:= ' '
Local cMailAssist	:= ' '

Local cHtml
Local cId_vend
Local nTotal				:= 0
Local nOfert				:= 0
Local cServer
Local cUser
Local cPass
Local lAuth
Local cNivel
Local cSubject 		    := ' '
Local cAlerta  		    := ' '
Local nX1 				:= 1
Local aArea
Local nX2 				:= 1
Local aFilGer 			:= {}
Local cFrom             :=' '
Local cCodigo
Local cDescri

 
Do Case
Case cTipo = 'A1_VENDEXT'
		cNivel = 'Vendedor Interno'
Case cTipo = 'A1_VENDCOO'
		Nivel = 'Gestor de Contas'
Case cTipo = 'A1_CHEFVEN'
		cNivel = 'Chefe de Vendas'
Case cTipo = 'A1_GERVEN'
		cNivel = 'Gerente'
End Case  

If cTipo <> 'A1_GERVEN' //Só envia para o Diretor se for lista do Gerente
  cMailDir:=' '
Endif
  
cServer  := GetMV('MV_RELSERV')
cUser    := GetMV('MV_RELACNT')
cPass    := GetMV('MV_RELPSW')
lAuth    := Getmv("MV_RELAUTH")

cHtml :='<html>'
cHtml +='<head>'
cHtml +='<title>Lista de Orçamentos Pendente Promo</title>'
cHtml +='</head>'
cHtml +='<body bgcolor=white text=black  >'
cHtml +='<h3 align=Left>Orçamentos Pendente - PROMO </h3>'+ CRLF

cId_vend := Alltrim(Posicione("SA3",1,xFilial("SA3")+cVend,"A3_NOME"))

cHtml +='<font size="4" face="Courier">'+cAlerta+' </font>'+ CRLF

cHtml +='<font size="3" face="Courier">'+cId_vend+',</font>'+ CRLF
cHtml +='<font size="3" face="Courier">Você Está recebendo a Lista dos Orçamentos c/ Item Promo </font>'+ CRLF
cHtml +='<font size="3" face="Courier">que estão pendentes a partir de : </font>'+'<b>'+Dtoc(DDATABASE-nDiasConsiderado)+'</b>'+ CRLF
cHtml +='<hr width=100% noshade>' + CRLF
 
cHtml +='<table border="1">'
cHtml +='<tr bgcolor="#99CCFF">'
cHtml +='<td>'
cHtml +='<font size="2" face="Arial"><b>Filial</b></font></td>'
cHtml +='<td>'
cHtml +='<font size="2" face="Arial"><b>Orçamento</b></font></td>'
cHtml +='<td>'
cHtml +='<font size="2" face="Arial"><b>Data</b></font></td>'
cHtml +='<td>'
cHtml +='<font size="2" face="Arial"><b>Produto</b></font></td>'
cHtml +='<td>'
cHtml +='<font size="2" face="Arial"><b>Consultado R$</b></font></td>'
cHtml += '<td>'
cHtml += '<font size="2" face="Arial"><b>Ofertado R$</b></font></td>'
cHtml += '<td>'
cHtml += '<font size="2" face="Arial"><b>Cliente</b></font></td>'
cHtml += '<td>'
cHtml += '<font size="2" face="Arial"><b>Segmento</b></font></td>'
cHtml += '<td>'
cHtml += '<font size="2" face="Arial"><b>Contato</b></font></td>'
cHtml += '<td >'
cHtml += '<font size="2" face="Arial"><b>Operador </b></font></td>'
cHtml += '<td>'
cHtml += '<font size="2" face="Arial"><b>Vend Int</b></font></td>'
cHtml += '<td>'
cHtml += '<font size="2" face="Arial"><b>Promo</b></font></td>'
cHtml += '<td>'
cHtml += '<font size="2" face="Arial"><b>% PROMO</b></font></td>'
cHtml += '</tr>'

aDadosMov := BuscaDados(cVend,cTipo)

If Len(aDadosMov) == 0 //Se não possuir Itens de Orçamento abandona a Rotina
	Return.F.
Endif
 
For x:= 1 to Len(aDadosMov)
 
	cFilIMD     	:= Alltrim(aDadosMov[x,6])
	cNumOrc     	:= aDadosMov[x,1]
	dEmissao		:= aDadosMov[x,2]
	nValMerc		:= aDadosMov[x,14]
	
	nPerPromo		:= aDadosMov[x,18] // nova coluna
	
	cCliente    	:= aDadosMov[x,3]+'/'+aDadosMov[x,4]+' '+SubStr(AllTrim(aDadosMov[x,5]),1,18)
	cContato    	:= Posicione("SU5",1,xFilial("SU5") + alltrim(aDadosMov[x,8]), "U5_CONTAT")
	cOperador   	:= POSICIONE("SU7",1,XFILIAL("SU7") + Alltrim(aDadosMov[x,9]), "U7_NOME")
	cVendInt    	:= aDadosMov[x,10]
	//cRep        	:= aDadosMov[x,11]	
	cCoord      	:= aDadosMov[x,12]
	nOfertado   	:= aDadosMov[x,15]
	cSegmento   	:= aDadosMov[x,16]
	cPromo       :=Alltrim(aDadosMov[x,17])
    
	cVendInt    	:=Iif(!Empty(cVendInt),Posicione("SA3",1,xFilial("SA3")+Alltrim(aDadosMov[x,10]),"A3_NOME"),"Não Possui")
	//cRep        	:=Iif(!Empty(cRep)    ,Posicione("SA3",1,xFilial("SA3")+Alltrim(aDadosMov[x,11]),"A3_NOME"),"Não Possui")
	cCoord      	:=Iif(!Empty(cCoord)  ,Posicione("SA3",1,xFilial("SA3")+Alltrim(aDadosMov[x,12]),"A3_NOME"),"Não Possui")
    

	cCodigo			:= aDadosMov[x,19] + " - "
	cDescri			:= aDadosMov[x,20]
	cChave 			:= Alltrim(aDadosMov[x,13])
	cObsTMK			:= SUA->(MSMM(cChave,,,,3,,,"SUA","SUA_OBS"))



	nTotal:=nTotal+nValMerc
	nOfert:=nOfert+nOfertado

	cHtml +='<tr>'
	cHtml +='<td>'
	cHtml +='<font size="2"  face="Arial">' +cFilIMD+'</b></td>'
	cHtml +='<td>'
	cHtml +='<font size="2"  face="Arial">' +cNumOrc+'</b></td>'
	cHtml +='<td>'
	cHtml +='<font size="2"  face="Arial">' +dEmissao+'</font></td>'
	cHtml +='<td>'
	cHtml +='<font size="2"  face="Arial">' +Alltrim(cCodigo) + " " + Alltrim(cDescri)+'</font></td>'
	cHtml +='<td>'
	cHtml +='<font size="2"  face="Arial">' +Transform(nValMerc,'@E 999,999,999.99')+'</font></td>'
	cHtml +='<td>'
	cHtml +='<font size="2"  face="Arial">' +Transform(nOfertado,'@E 999,999,999.99')+'</font></td>'
	cHtml +='<td>'
	cHtml +='<font size="2"  face="Arial">' +cCliente+ '</font></td>'
	cHtml +='<td>'
	cHtml +='<font size="2"  face="Arial">' +cSegmento+'</font></td>'
	cHtml +='<td>'
	cHtml +='<font size="2"  face="Arial">' +SubStr(cContato,1,15)+ '</font></td>'
	cHtml +='<td>'
	cHtml +='<font size="2"  face="Arial">' +SubStr(cOperador,1,8) + '</font></td>'
	cHtml +='<td>'
	cHtml +='<font size="2"  face="Arial">' +SubStr(cVendInt,1,8)+'</font></td>'
	cHtml +='<td>'
	//cHtml +='<font size="2"  face="Arial">' +SubStr(cRep,1,8)+'</font></td>'
	cHtml +='<font size="2"  face="Arial">' +cPromo+'</font></td>'
	
	cHtml +='<td>'
	cHtml +='<font size="2"  face="Arial">' +cValToChar(nPerPromo) +' % </font></td>'
	cHtml +='</tr>'
 
Next

cHtml += '</table>'
cHtml += '<b><font size="3" face="Courier">Resumo</font></b>'

//Totalizador com quantidade de orçamentos//
cHtml +='<table width="200" cellspacing="1" cellpadding="3" border="0" bgcolor="#99CCFF">'
cHtml +='<tr>'
cHtml +='<td bgcolor=#99CCFF>'
cHtml +='<font size=1 face="verdana, arial, helvetica">'
cHtml +='<b>Quantidade de Orçamentos</b>'
cHtml +='</font>'
cHtml +='</td>'
cHtml +='</tr>'

cHtml +='<tr>'
cHtml +='<td bgcolor=white> '
cHtml +='<font face="verdana, arial, helvetica" size=1>'
cHtml += Str(Len(aDadosMov))
cHtml +='</font>'
cHtml +='</td>'
cHtml +='</tr>'
cHtml +='</table>'

//Totalizador do Orçado//
cHtml +='<table width="200" cellspacing="1" cellpadding="3" border="0" bgcolor="#99CCFF">'
cHtml +='<tr>'
cHtml +='<td bgcolor=#99CCFF>'
cHtml +='<font size=1 face="verdana, arial, helvetica">'
cHtml +='<b>Valor Total Orçado</b>'
cHtml +='</font>'
cHtml +='</td>'
cHtml +='</tr>'
cHtml +='<tr>'
cHtml +='<td bgcolor=white>'
cHtml +='<font face="verdana, arial, helvetica" size=1>'
cHtml +='R$ '+Transform(nTotal,'@E 999,999,999.99')
cHtml +='</font>'
cHtml +='</td>'
cHtml +='</tr>'
cHtml +='</table>'

//Totalizador do Ofertado//
cHtml +='<table width="200" cellspacing="1" cellpadding="3" border="0" bgcolor="#99CCFF">'
cHtml +='<tr>'
cHtml +='<td bgcolor=#99CCFF>'
cHtml +='<font size=1 face="verdana, arial, helvetica">'
cHtml +='<b>Valor Total Ofertado</b>'
cHtml +='</font>'
cHtml +='</td>'
cHtml +='</tr>'
cHtml +='<tr>'
cHtml +='<td bgcolor=white>'
cHtml +='<font face="verdana, arial, helvetica" size=1>'
cHtml += 'R$ '+Transform(nOfert,'@E 999,999,999.99')
cHtml +=' </font>'
cHtml +='</td>'
cHtml +='</tr>'
cHtml +='</table>'
cHtml +='</body>' + CRLF
cHtml +='</html>' + CRLF
cHtml += CRLF

cEndMail    := Posicione("SA3",1,xFilial("SA3")+cVend,"A3_EMAIL")                           //Email do gerente
cMailAssist := SX5->(Posicione("SX5",1,xFilial("SX5")+"78"+cVend,"X5_DESCRI"))              //Email da Assistente
//cPara       := AllTrim(cEndMail)+","+cMailDir+","+Alltrim(cMailAssist)                      //Destinatários do e-mail

If cTipo = 'A1_GERVEN'
 cPara       := AllTrim(cEndMail)+","+cMailDir+","+Alltrim(cMailAssist)                      //Destinatários do e-mail
  Else
 cPara       := AllTrim(cEndMail)
Endif


If Empty(cPara)
	cPara:= ALLTRIM(GETMV("MV_EOPCONT"))
	cSubject:= 'Orcamentos Pendente PROMO '+cNivel+' sem e-mail'
	cAlerta := 'Orcamentos Pendente PROMO '+cNivel+' sem e-mail'
Endif
  
//cSubject  := 'Orcamentos Pendente c/ Item PROMO - Gerente : '+cId_vend
cSubject  := 'Orcamentos Pendente c/ Item PROMO - '+cNivel+' :'+cId_vend

cFrom := ''
// cPara:='cristiano.machado@imdepa.com.br'                       

U_EnvMyMail(cFrom,cPara,cEmailBcc,cSubject,cHtml,'')//| U_EnvMyMail(De, Para, Copia, Assunto, Corpo, Anexo ) 

Return .T.
*******************************************************************************
Static Function BuscaDados(cVend,cTipo) // Obtem os valores dos orcamentos...
******************************************************************************* 
Local aDados := {}
Local cQuery :=' '



cQuery += " SELECT "
cQuery += "    SA1.A1_FILIAL, " 
cQuery += "    SA1.A1_COD,  "
cQuery += "    SA1.A1_LOJA,  "
cQuery += "    SA1.A1_NOME,  "
cQuery += "    SA1.A1_VENDEXT, " 
cQuery += "    SA1.A1_VEND,  "
cQuery += "    SA1.A1_EST,  "
cQuery += "    SA1.A1_FAX,  "
cQuery += "    SA1.A1_EMAIL,  "
cQuery += "    SA1.A1_VEND,  "
cQuery += "    SA1.A1_VENDCOO, " 
cQuery += "    SA1.A1_GRPSEG,  "
   
cQuery += "    SUA.UA_FILIAL,  "
cQuery += "    SUA.UA_NUM,  "
cQuery += "    SUA.UA_CLIENTE, " 
cQuery += "    SUA.UA_LOJA,  "
cQuery += "    SUA.UA_OPERADO, " 
cQuery += "    SUM( SUA.UA_VLRLIQ ) UA_VLRLIQ, " 
cQuery += "    SUM( SUA.UA_VALMERC ) UA_VALMERC, " 
cQuery += "    SUM( SUA.UA_VALBRUT ) UA_VALBRUT,  "
cQuery += "    SUM( SUB.UB_VLRITEM ) UB_VLRITEM,  "
cQuery += "    ROUND( SUM( SUB.UB_VLRITEM ) / SUM( SUA.UA_VALMERC ), 2 ) * 100 PERCPROMO, " 
cQuery += "    SUA.UA_CODCONT,  "
cQuery += "    SUA.UA_CODOBS,  "
cQuery += "    SUA.UA_EMISSAO, "
   
cQuery += "    SB1.B1_COD, "
cQuery += "    SB1.B1_DESC, "
cQuery += "    SB1.B1_OBSTPES "
   
cQuery += " FROM "
cQuery += "    SUB010 SUB, SUA010 SUA, SB1010 SB1, SA1010 SA1 "
cQuery += " WHERE "
cQuery += "    A1_FILIAL = '  ' "
cQuery += "    AND A1_COD = UA_CLIENTE "
cQuery += "    AND A1_LOJA = UA_LOJA "
cQuery += "    AND "+cTipo+"='" +cVend + "' "
cQuery += "    AND UA_EMISSAO >='"+ DTOS(DDATABASE-nDiasConsiderado) + "'"
cQuery += "    AND UA_CANC <> 'S' "
cQuery += "    AND UA_STATUS <> 'NF.' "
cQuery += "    AND UA_NUMSC5 = ' ' "
cQuery += "    AND UB_FILIAL = UA_FILIAL "
cQuery += "    AND UB_NUM = UA_NUM "
cQuery += "    AND UB_PRODUTO = B1_COD "
cQuery += "    AND UB_FILIAL = B1_FILIAL "
cQuery += "    AND B1_OBSTPES > ' ' "
cQuery += "    AND B1_OBSTPES NOT LIKE( 'SAIU%' ) "
cQuery += "    AND B1_OBSTPES NOT LIKE( 'PESO 1%' ) "
cQuery += "    AND SUB.D_E_L_E_T_ = ' ' "
cQuery += "    AND SUA.D_E_L_E_T_ = ' ' "
cQuery += "    AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "    AND SA1.D_E_L_E_T_ = ' ' "
   
cQuery += " GROUP BY "
cQuery += "    a1_filial, a1_cod, a1_loja, a1_nome, a1_vendext, a1_vend, a1_est, a1_fax, a1_email, a1_vend, a1_vendcoo, a1_grpseg, ua_filial, ua_num, ua_cliente, ua_loja, ua_operado, ua_codcont, ua_codobs, ua_emissao, b1_cod, b1_desc, B1_OBSTPES "
  
	U_ExecMySql(cQuery , 'CONSTMK', 'Q', .F. ) 
  
	TCSetField("CONSTMK","UA_VLRLIQ" ,"N",14, 2)
	TCSetField("CONSTMK","UA_VALMERC","N",14, 2)
  TCSetField("CONSTMK","UA_EMISSAO","D", 8, 2)
  

	DbSelectArea("CONSTMK");DbGoTop()
  
	While (!Eof()) 
		AADD(aDados,{CONSTMK->UA_NUM,;
			Dtoc(CONSTMK->UA_EMISSAO)   ,;
			CONSTMK->UA_CLIENTE         ,;
			CONSTMK->UA_LOJA            ,;
			CONSTMK->A1_NOME            ,;
			CONSTMK->UA_FILIAL          ,;
			CONSTMK->A1_NOME            ,;
			CONSTMK->UA_CODCONT         ,;
			CONSTMK->UA_OPERADO         ,;
			CONSTMK->A1_VENDEXT         ,;
			CONSTMK->A1_VEND            ,;
			CONSTMK->A1_VENDCOO         ,;
			CONSTMK->UA_CODOBS          ,;
			SF4->(nRetQtdConsul(CONSTMK->UA_NUM,CONSTMK->UA_FILIAL)),;
			SF4->(nRetQtdOfert(CONSTMK->UA_NUM,CONSTMK->UA_FILIAL)),;
			CONSTMK->A1_GRPSEG,;
			CONSTMK->b1_obstpes,;
			CONSTMK->PERCPROMO,;
			CONSTMK->B1_COD,;
			CONSTMK->B1_DESC})
		DbSkip()
	Enddo
	aSort( aDados,,, { |x,y| x[ 15 ] > y[ 15 ] } )

	DbSelectArea("CONSTMK")
	DbCloseArea()

Return(aDados)
*******************************************************************************
Static Function nRetQtdOfert(nOrc,Filial) //Nova Versao do Valor Ofertado //
*******************************************************************************

	cQuery :=" SELECT SUM(ZA0_VOFERT) nTotOfert "
	cQuery +=" FROM "+RetSqlName( "ZA0" )+ " ZA0 "
	cQuery +=" WHERE "
	cQuery +=" ZA0_FILIAL='"+Filial+"'"
	cQuery +=" AND ZA0_NUMORC='"+nOrc+"'"
	cQuery +=" AND ZA0.D_E_L_E_T_ <> '*'"

	U_ExecMySql(cQuery ,'TMK_ZA0' ,'Q' ,.F. )
	 
	TCSetField("TMK_ZA0","nTotOfert" ,"N",12, 4)
	
	DbSelectArea("TMK_ZA0")
 	nTotRet := TMK_ZA0->nTotOfert
	DbCloseArea()

Return(nTotRet)
*******************************************************************************               
Static Function nRetQtdConsul(nOrc,Filial)  //Nova Versao do Valor Consultado //
*******************************************************************************

	cQuery :=" SELECT SUM(ZA0_QUANTD*ZA0_PRECO) nTotConsul "
	cQuery +=" FROM "+RetSqlName( "ZA0" )+ " ZA0 "
	cQuery +=" WHERE "
	cQuery +=" ZA0_FILIAL='"+Filial+"'"
	cQuery +=" AND ZA0_NUMORC='"+nOrc+"'"
	cQuery +=" AND ZA0.D_E_L_E_T_ <> '*'"

	U_ExecMySql(cQuery ,'TMK_ZA0' ,'Q' ,.F. )
	 
	TCSetField("TMK_ZA0","nTotConsul" ,"N",12, 4)

	DbSelectArea("TMK_ZA0")
	nTotRet := TMK_ZA0->nTotConsul
	DbCloseArea()

Return(nTotRet)