#include "rwmake.ch"
#include "ap5mail.ch"
#include 'tbiconn.ch'
#INCLUDE "TOPCONN.CH"

#IFNDEF CRLF
	#DEFINE CRLF ( chr(13)+chr(10) )
#ENDIF

/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: IMDA800      || Autor: Edivaldo Gonçalves    || Data: 23/08/12  ||
||-------------------------------------------------------------------------||
|| Descrição: Envia e-mail automático de Pedido/Orçamento de Vendas        ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/


User Function IMDA800(orc,cliente,codLoja,codfil,pedido,tipo,oc,frete,contact,codcontact,lFlag)

Return()
//
//	Local lCor            :=.T.
//	Local cHtml           :=' '
//	Local cSubJect        :=Iif(SUA->UA_OPER=='1','Pedido de Vendas','Orçamento de Venda')
//	Local cMailSend       :=' ' //Lista de endereco de e-mails a serem enviados
//	Local cMailAssist     :=' ' //E-mail da assistente comercial
//	Local cMailVint       :=' ' //E-mail do vendedor interno
//	Local cMailVendExt    :=' ' //E-mail do representante
//	Local cMailVendCo     :=' ' //E-mail do coordenador de venda
//
//	Local nSavNF          := MaFisSave()
//
//	Local cVendResp       :=' '
//	Local cCliente        :=' '
//	Local cCGC            :=' '
//	Local cRg             :=' '
//	Local cAccount        :=' '
//
//	Local cEmailBcc       :=' '
//	Local _cUserLog       := SUA->(RetCodUsr())  //Usuario Logado no Sistema
//	Local cMailAdic       := GETMV("MV_IMDA800") //Email Adicional para Itens promocionais
//
//	Local aArea		      := GetArea()
//
////Condição de Pagamento
//	Local DescCond        := SUA->(Posicione("SE4",1,xFilial("SE4")+SUA->UA_CONDPG,"E4_DESCRI"))
//
////Transportadora
//	Local DescTrans       := SUA->(Posicione("SA4",1,xFilial("SA4")+SUA->UA_TRANSP,"A4_NOME"))
//
//	Local nTotGeral	      := SUA->UA_VLRLIQ
//
////Private nTotLiq       := (SUA->UA_VALBRUT+SUA->UA_ACRESCI+SUA->UA_DESPESA+SUA->UA_FRETE)-SUA->UA_DESCONT
//	Private nTotLiq       := 0
//
//	Private nTotGeral     := SUA->UA_VLRLIQ
//
//	Private  nPesol    := 0
//	Private  nPesob    := 0
//	Private  nTotProd  := 0
//
//	Private aDados   := {}
//	Private cImdepa  := GetMV('MV_IMDEPA')
//
//	Private nTotIcmsRet := 0
//	Private ValDesp  := SUA->UA_DESPESA
//	Private ValFrete := SUA->UA_FRETE
//	Private cNumOrca := SUA->UA_NUM
//	Private aImposto  := {}
//	Private nvST      := 0
//	Private nVlrSu    := 0
//	Private nTOTSUFRAMA := 0
//
//	Private ValMerc1  := 0
//	Private nTotIpi   := 0
//	Private nTotST    := 0
//
//	Private lTemPromo:=.F.
//
//	If  SUA->UA_PROSPEC
//		Return
//	Endif
//
//
//	PswOrder(1)
//
//	If PswSeek(_cUserLog,.T.)
//		If !Empty(PswRet()[1][14])
//			cAccount:=Alltrim(PswRet()[1][14]) //conta de e-mail do usuário logado no sistema
//		Endif
//	Endif
//
//
////ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
////³Posiciona no cadastro da IMDEPA ³
////ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	dbSelectArea("SA1")
//	dbSeek(xfilial('SA1')+cImdepa+SM0->M0_CODFIL)
//	cTitEmp   := AllTrim(SA1->A1_NOME)
//	cEmail    := AllTrim(SA1->A1_EMAIL)
//	cWww      := AllTrim(SA1->A1_HPAGE)
// 
// /*
// If File( 'c:\email.html')
// 	  fErase( 'c:\email.html' )
//  EndIf
//        
//   nArq := fCreate( 'c:\email.html' )
//  */ 
// 	
//
////cHtml :='<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN "http://www.w3.org/TR/html4/loose.dtd">'
//	cHtml := '<html>'
//	cHtml += '<head>'
//	cHtml+='<title>Orçamento de Venda</title>'
//	cHtml+='</head>'
//
//	cHtml+='<center><h1>IMDEPA ROLAMENTOS IMP E COMERCIO LDTA</h1></center>'
//  
//	cHtml+='<body>'
//
//	cHtml+='<table width="900" border="0" cellpadding="0" cellspacing="2" bordercolor="#FFFFFF" bgcolor="#FFFFFF">'
//
//
//	cHtml+='<tr bgcolor="#F3F3F3"><td bgcolor="#ECF0EE" class="formulario">De:</td>'
//	cHtml+='<td bgcolor="#F7F9F8" class="formulario2">'+Alltrim(SA1->A1_NOME)+'</td>'
//
//// posiciona nos dados do contato
//	SU5->( dbseek(xFilial('SU5')+SUA->UA_CODCONT) )
//	SUM->( dbseek(xFilial('SUM')+SU5->U5_FUNCAO) )
//
//	If ! SUA->UA_PROSPEC
//	
//	// Recupera os dados do Cliente
//		dbSelectArea("SA1")
//		dbSeek(xfilial('SA1')+SUA->UA_CLIENTE+SUA->UA_LOJA)
//
//		cCliente := SA1->A1_COD + " - " + SA1->A1_NOME
//		cCGC     := SA1->A1_CGC
//		cRg      := IIf(!Empty(SA1->A1_INSCR),SA1->A1_INSCR,SA1->A1_RG)
//	
//	 // Envia e-mail automático para o cliente em caso de Faturamento	 
//	// If SUA->UA_OPER=='1' .AND. !Empty(SA1->A1_EMAIL) 
//		If   !Empty(SA1->A1_EMAIL)
//	
//			If IW_MsgBox ("Confirma o envio do Orçamento de Venda Automático para o Cliente ?"," Email Automático","YESNO")
//				cMailSend:= IIf(!Empty(SA1->A1_EMAIL),Alltrim(SA1->A1_EMAIL)+";",' ')
//			Endif
// 		
//		Endif
//     
//     //Envia e-mail para o Representante e Coordenador 
//     //If SUA->UA_OPER=='2'
//		cMailVendExt:=Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND,"A3_EMAIL")
//		If !Empty(cMailVendExt)
//			cMailSend:=cMailSend+Alltrim(cMailVendExt)+";"
//		Endif
//         
//		cMailVendCo:=Posicione("SA3",1,xFilial("SA3")+SA1->A1_VENDCOO,"A3_EMAIL")
//                      
//		If !Empty(cMailVendCo)
//			cMailSend:=cMailSend+Alltrim(cMailVendCo)+";"
//		Endif
//     //Endif 
//     
//
//		If SUA->UA_OPER = '1'     // Atendimento eh um Faturamento
//			cVendResp := Posicione("SA3",1,xFilial("SA3")+SA1->A1_VENDEXT,"A3_NOME")
//			If Empty(cVendResp)//Pedido do Call Center nao possui vendedor ligado ao cliente |Inserido por Edivaldo Goncalves em 25/06/2010
//	                       //Pega o usuario que gravou o Orcamento
//				cVendResp := Posicione("SU7",1,xFilial("SU7")+SUA->UA_OPERADO,"U7_NOME")
//			Endif
//		Else
//			cVendResp := Posicione("SU7",1,xFilial("SU7")+SUA->UA_OPERADO,"U7_NOME")
//		
//		EndIf
//	
//	Endif
//
//	cHtml+='<tr bgcolor="#F3F3F3"> <td bgcolor="#ECF0EE" class="formulario">Vendedor:</td>'
//	cHtml+='<td bgcolor="#F7F9F8" class="formulario2">'+cVendResp+'</td>'
//
//	cHtml+='<tr bgcolor="#F3F3F3"><td bgcolor="#ECF0EE" class="formulario">Cliente:</td>'
//	cHtml+='<td bgcolor="#F7F9F8" class="formulario2">'+Alltrim(cCliente)+'</td>'
//
//	cHtml+='<td bgcolor="#ECF0EE" class="formulario">Orçamento/Pedido:</td>'
//	cHtml+='<td bgcolor="#F7F9F8" class="formulario2">'+SUA->UA_NUM+'</td>'
//
//
//	cHtml+='<tr bgcolor="#F3F3F3"> <td bgcolor="#ECF0EE" class="formulario">Endereço:</td>'
//	cHtml+='<td bgcolor="#F7F9F8" class="formulario2">'+AllTrim(SA1->A1_TLOGEND)+" "+AllTrim(U_ALTEND(SA1->A1_END))+" "+AllTrim(Str(SA1->A1_NUMEND,6))+" "+AllTrim(SA1->A1_COMPEND)+CRLF+AllTrim(SA1->A1_MUN)+' - '+SA1->A1_EST+' - CEP: '+SA1->A1_CEP+'</td>'
//
//	cHtml+='<tr bgcolor="#F3F3F3"> <td bgcolor="#ECF0EE" class="formulario">Fone:</td>'
//	cHtml+='<td bgcolor="#F7F9F8" class="formulario2">('+SA1->A1_DDD+') '+SA1->A1_TEL+'</td>'
//
//	cHtml+='<td bgcolor="#ECF0EE" class="formulario">Fax:</td>'
//	cHtml+='<td bgcolor="#F7F9F8" class="formulario2">('+SA1->A1_DDD+')'+SA1->A1_FAX+'</td>'
//
//
//	cHtml+='<tr bgcolor="#F3F3F3"> <td bgcolor="#ECF0EE" class="formulario">CNPJ/CPF:</td>'
//	cHtml+='<td bgcolor="#F7F9F8" class="formulario2">'+cCGC+'</td>'
//
//	cHtml+='<td bgcolor="#ECF0EE" class="formulario">Insc. Estadual:</td>'
//	cHtml+='<td bgcolor="#F7F9F8" class="formulario2">'+cRg+'</td>'
//
//	cHtml+='<tr bgcolor="#F3F3F3"> <td bgcolor="#ECF0EE" class="formulario">Email:</td>'
//	cHtml+='<td bgcolor="#F7F9F8" class="formulario2">'+Alltrim(SA1->A1_EMAIL)+'</td>'
//
//
//	cHtml+='<tr bgcolor="#F3F3F3"> <td bgcolor="#ECF0EE" class="formulario">Contato:</td>'
//	cHtml+='<td bgcolor="#F7F9F8" class="formulario2">'+SubStr(SU5->U5_CONTAT,1,25)+'</td>'
//
//	cHtml+='<td bgcolor="#ECF0EE" class="formulario">Cargo:</td>'
//	cHtml+='<td bgcolor="#F7F9F8" class="formulario2">'+SubStr(SUM->UM_DESC,1,25)+'</td></tr>'
//
//
//	cHtml+='</table>'+CRLF
//
//	cHtml+='<br>
//
//	cHtml+='<table width="1000" border="1"  cellpadding="0" cellspacing="3" bordercolor="#CCCCCC"> <tr bgcolor="#B9D3EE"> <td width="20%" bgcolor="#B9D3EE" class="formulario">Produto</td>'
//
//	cHtml+='<td width="150%" bgcolor="#B9D3EE" class="formulario">Descrição.</td>'
//
//
//	cHtml+='<td width="10%" bgcolor="#B9D3EE" class="formulario">Um.</td>'
//
//	cHtml+='<td width="50%" bgcolor="#B9D3EE" class="formulario">Qtd</td>'
//	cHtml+='<td width="50%" bgcolor="#B9D3EE" class="formulario">Vlr. Unit</td>'
//	cHtml+='<td width="20%" bgcolor="#B9D3EE" class="formulario">IPI</td>'
//	cHtml+='<td width="50%" bgcolor="#B9D3EE" class="formulario">ST</td>'
//	cHtml+='<td width="50%" bgcolor="#B9D3EE" class="formulario">Pr.Un.c/IPI e ST</td>'
//	cHtml+='<td width="20%" bgcolor="#B9D3EE" class="formulario">NCM</td>'
//	cHtml+='<td width="11%" bgcolor="#B9D3EE" class="formulario">P.Entrega </td>'
//	cHtml+='<td width="50%" bgcolor="#B9D3EE" class="formulario">Tot c/IPI e ST</td> </tr>'
//
//
// //Carrega dados do Orçamento
//	aDados := BuscaDados(orc,codFil)
//
//	If Len(aDados)=0
//		Return
//	Endif
//
//	nTotST := MAFISRET(,"NF_VALSOL")
//
//	For x:= 1 to Len(aDados)
//
///*	
//	item    := alltrim(aDados[x,1]) 
//	qtd     :=val(alltrim(aDados[x,2]))
//	prec    :=val(alltrim(aDados[x,3])) //Preço com Acréscimo
//	cProd   := alltrim(aDados[x,4])
//	
//	
//	If Empty(aDados[x,5]) .OR. aDados[x,5]=" "
//		PrEntreg="Indisponivel"
//	Else
//		PrEntreg:=alltrim(aDados[x,5])
//	Endif
//	
//	ipi     :=VAL(alltrim(aDados[x,6]))
//	PrecIPI :=VAL(alltrim(aDados[x,7]))
//*/	
//	
//		item    := alltrim(aDados[x,1])
//		nQTDVEN := val(alltrim(aDados[x,2]))
//		prec    := val(alltrim(aDados[x,3])) //Preço com Acréscimo
//		DescProd:= alltrim(aDados[x,4])
//
//		cPRODUTO:= alltrim(aDados[x,8])
//		NCM     := alltrim(aDados[x,9])
//	
//		cCLIENTE:= alltrim(aDados[x,10])
//		cLOJCLI := alltrim(aDados[x,11])
//		cTIPCLI := alltrim(aDados[x,12])
//		cTES    := alltrim(aDados[x,13])
//		nVLRITEM:= val(alltrim(aDados[x,14]))
//		nTDepesa := val(alltrim(aDados[x,15]))
//		cIPI    := alltrim(aDados[x,16])
//		nIpiSB1 := val(alltrim(aDados[x,6]))
//
//				
//		nPRCVEN := NoRound(nVLRITEM/nQTDVEN,4) //SUB->UB_VRCACRE
//		nVALOR  := nQTDVEN * NOROUND(prec,4)
//
//		cQuery := "SELECT TRUNC( SUM( UB_VRCACRE * UB_QUANT ), 2 ) AS VAL_MERC "
//		cQuery += "  FROM " + RetSqlName("SUB") + " "
//		cQuery += " WHERE D_E_L_E_T_ = ' ' "
//		cQuery += "   AND UB_FILIAL  = '" + xFilial("SUB") + "' "
//		cQuery += "   AND UB_NUM     = '" + cNumOrca + "' "
//
//		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY_SUB1",.F.,.T.)
//		DbSelectArea("QRY_SUB1")
//		DbGoTop()
//
//		nTotQtd := 0
//		If QRY_SUB1->( !EOF() )
//			nTotMerc := QRY_SUB1->VAL_MERC
//		EndIf
//		QRY_SUB1->( DbCloseArea() )
//
//		nLiq     := NoRound( prec * nQTDVEN, 4 )
//		nVRatDes := NoRound(( nTDepesa / nTotMerc ) * nLiq , 6)
//			
//		NDESPESA:= NVRATDES
//
//		aImposto    := U_xImposto(cCliente,cLojCli,cTipCli,cPRODUTO,cTES,nQTDVEN,nPRCVEN,nVALOR,NDESPESA,x)
//
//		nvST        := NoRound(aImposto[1],4)  	//MAFISRET(NITEM,"LF_ICMSRET")//NoRound(aImposto[1],4)
//                
//   ///para pegar o valor da suframa por item (se houver)
//		nVlrSu      := NoRound(aImposto[2],4)
//		nTOTICMSRET += nvST
//				
//		nTOTSUFRAMA := 0 //nSUF //MAFISRET(,"NF_DESCZF") //nSUF  //VINDO DIRETO
//			
//			
//	// Jorge Oliveira - 31/01/2011 - Ajustes para mostrar o valor Unitario c/IPI
//
//
//	///Julio Jacovenko, 24/04/2012
//		nLIQ1 := prec
//		
//	// Jorge Oliveira - 31/01/2011 - Ajustes para mostrar o valor Unitario c/IPI
//		If ValDesp > 0
//			nVRatDes := ( ValDesp / nTotMerc ) * nLiq
//			VRatDes1 := ( ValDesp / nTotMerc ) * nLiq1
//		Else
//			nVRatDes := 0
//			VRatDes1 := 0
//		EndIf
//	
//	// Jorge Oliveira - 31/01/2011 - Ajustes para mostrar o valor Unitario c/IPI
//		If ValFrete > 0
//			nVRatFre := ( ValFrete   / nTotMerc ) * nLiq
//			VRatFre := ( ValFrete   / nTotMerc ) * nLiq1
//
//		Else
//			nVRatFre := 0
//			VRatFre  := 0
//		EndIf
//
//		nValIpi := 0
//		nValIpi1:= 0
//		If cIPI = "S"
//				// Jorge Oliveira - 31/01/2011 - Ajustes para mostrar o valor Unitario c/IPI
//				//nValIpi := Round( ( nLiq + nVRatDes + nVRatFre ) * ( SB1->B1_IPI/100 ), 2 )
//				//Inserido por Edivaldo Goncalves Cordeiro em 16/06/11 Valor com IPI eh o Liquido + % IPI
//				//nValIpi := Round(  nLiq  * ( SB1->B1_IPI/100 ), 2 )  
//				
//				///JULIO JACOVENKO - 20/02/2012
//				///Ajustado para calcular o imp sobre o frete e outras 
//				///despesas NO TOTAL, estava usando somente o NLIQ (Vlr sem despesas)
//			nValIpi := Round(  (nVRatDes+nVRatFre+nLiq)  * ( nIpiSB1/100 ), 2 )
//			nValIpi1:= Round(  (VRatDes1+VRatFre+nLiq1)  * ( nIpiSB1/100 ), 2 )
//				
//		EndIf
//
//		nValMerc  := nLiq  + nValIpi  + nvST   //U_FValIcmsRet()
//			
//		ValMerc1  := nLiq1 + nValIpi1 + NOROUND(nvST/nQTDVEN,4)
//		nTotLiq   += nLiq
//		nTotIpi   += nValIpi
////	nTotGeral += nValMerc
//
//		If Empty(aDados[x,5]) .OR. aDados[x,5]=" "
//			PrEntreg:="Indisponivel"
//		Else
//			PrEntreg:=alltrim(aDados[x,5])
//		Endif
//	
//		ipi     :=VAL(alltrim(aDados[x,6]))
//		PrecIPI :=VAL(alltrim(aDados[x,7]))
//
//		nVlrST:=NOROUND(nvST/nQTDVEN,4)
//
//
//		If lCor
//			lCor:=.F.
//		Else
//			lCor:=.T.
//		Endif
//      
//		If lCor
//			cHtml+='<tr bgcolor="#F3F3F3"> <td class="formulario2">'+cPRODUTO+'</td>'
//		Else
//			cHtml+='<tr> <td class="formulario2">'+cPRODUTO+'</td>'
//		Endif
//  
//		cHtml+='<td class="formulario2">'+DescProd+'</td>'
//		cHtml+='<td class="formulario2">'+item+'</td>'
//		cHtml+='<td class="formulario2">'+Transform(nQTDVEN,'@E 999,999.99')+'</td>'
//		cHtml+='<td class="formulario2">'+Transform(prec,'@E 9,999,999.9999')+'</td>'
//		cHtml+='<td class="formulario2">'+Transform(ipi,'@E 99.99')+'</td>'
//		cHtml+='<td class="formulario2">'+Transform(nvST,'@E 9,999,999.9999')+'</td>'
//		cHtml+='<td class="formulario2">'+Transform(NValMerc/nQTDVEN,'@E 9,999,999.9999')+'</td>'
//		cHtml+='<td class="formulario2">'+NCM+'</td>'
//		cHtml+='<td class="formulario2">'+PrEntreg +'</td>'
//		cHtml+='<td class="formulario2">'+Transform(NValMerc,'@E 9,999,999.99') +'</td></tr>'
//
//   
//	Next x
//  
//	cHtml+='</table>'+CRLF
//	cHtml+='<table width="500" border="0" cellpadding="0" cellspacing="2" bordercolor="#FFFFFF" bgcolor="#FFFFFF">'
//
//
//	cHtml+='<tr bgcolor="#F3F3F3"><td bgcolor="#ECF0EE" class="formulario">Total de Peças:</td>'
//	cHtml+='<td align="right"  bgcolor="#F7F9F8" class="formulario2">'+Transform(nTotProd,'@E 9,999,999.99')+'</td>'
//
//	cHtml+='<tr bgcolor="#F3F3F3"><td bgcolor="#ECF0EE" class="formulario">Peso Liquido :</td>'
//	cHtml+='<td align="right" bgcolor="#F7F9F8" class="formulario2">'+Transform(nPesol,'@E 9,999,999.99')+'</td>'
//
//	cHtml+='<tr bgcolor="#F3F3F3"><td bgcolor="#ECF0EE" class="formulario">Peso Bruto :</td>'
//	cHtml+='<td align="right" bgcolor="#F7F9F8" class="formulario2">'+Transform(nPesob,'@E 9,999,999.99')+'</td>'
//
//	cHtml+='<tr bgcolor="#F3F3F3"><td bgcolor="#ECF0EE" class="formulario">Despesa :</td>'
//	cHtml+='<td align="right" bgcolor="#F7F9F8" class="formulario2">'+Transform(ValDesp,'@E 9,999,999.99')+'</td>'
//
//	cHtml+='<tr bgcolor="#F3F3F3"><td bgcolor="#ECF0EE" class="formulario">Valor IPI :</td>'
//	cHtml+='<td align="right" bgcolor="#F7F9F8" class="formulario2">'+Transform(nTotIpi,'@E 9,999,999.99')+'</td>'
//
//	cHtml+='<tr bgcolor="#F3F3F3"><td bgcolor="#ECF0EE" class="formulario">Valor ST :</td>'
//	cHtml+='<td align="right" bgcolor="#F7F9F8" class="formulario2">'+Transform(nTotST,'@E 9,999,999.99')+'</td>'
//
//	cHtml+='<tr bgcolor="#F3F3F3"><td bgcolor="#ECF0EE" class="formulario">Valor Frete :</td>'
//	cHtml+='<td align="right" bgcolor="#F7F9F8" class="formulario2">'+Transform(ValFrete,'@E 9,999,999.99')+'</td>'
//
//	cHtml+='<tr bgcolor="#F3F3F3"><td bgcolor="#ECF0EE" class="formulario">Total Liquido   :</td>'
//	cHtml+='<td align="right" bgcolor="#F7F9F8" class="formulario2">'+Transform(nTotLiq,'@E 9,999,999.99')+'</td>'
//
//	cHtml+='<tr bgcolor="#F3F3F3"><td bgcolor="#ECF0EE" class="formulario">Total C/IPI  :</td>'
//	cHtml+='<td align="right" bgcolor="#F7F9F8" class="formulario2">'+Transform(nTotGeral,'@E 9,999,999.99')+'</td></tr>'+CRLF
//
//	cHtml+='</table>'+CRLF
//
// 
//	cHtml += '<b><font size="2" face="Courier">Cond. Pagto :'+DescCond +'</font></b>'+ CRLF
//	cHtml += '<b><font size="2" face="Courier">Despesa     :'+Alltrim(Transform(ValDesp,'@E 99,999,999,999.99'))+'</font></b>'+ CRLF// +oper2
//
//
//	cHtml += '<b><font size="2" face="Courier">Transport.  : </font></b>'+Alltrim(DescTrans)+ CRLF
//
//	cHtml += '<b><font size="2" face="Courier">Validade da Proposta : 02 (dois dias) </font></b>'+ CRLF
//
//	cHtml += '<hr width=100% noshade>'
//
//	cHtml += '<font size="2" face="Courier">Não aceitamos devoluções de mercadorias sem prévio </font>'+CRLF
//	cHtml += '<font size="2" face="Courier">entendimento com nosso departamento de vendas. </font>'+CRLF
//	cHtml += '<font size="2" face="Courier">Será acrescida despesa bancária por duplicata. </font>'+CRLF
//
//	cHtml+='</body>'
//	cHtml+='</html>'
//
////U_CAIXATEXTO(cHtml)
//
//
////cHtml += '</p>'
//
//
//// 	fWrite( nArq, cHtml )
//// 	fClose( nArq )
//
//
//  
//	If lTemPromo .AND. SUA->UA_OPER = '2' //Orçamento  com itens de promoção envia e-mail para assistente comercial e vendedor interno
//  
//		cMailAssist := SX5->(Posicione("SX5",1,xFilial("SX5")+"78"+SA1->A1_GERVEN,"X5_DESCRI"))
//		cMailVint   := SA3->(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VENDEXT,"A3_EMAIL"))
//      
//		If !Empty(cMailAssist)
//			cMailSend:=cMailSend+Alltrim(cMailAssist)+";"
//		Endif
//      
//		If !Empty(cMailVint)
//			cMailSend:=cMailSend+Alltrim(cMailVint)+";"
//		Endif
//      
//		If !Empty(cMailAdic)
//      
//			cMailSend:=cMailSend+Alltrim(cMailAdic)+";"
//		Endif
//     
//	Endif
//  
//	cMailSend := lower(Left(cMailSend,Len(cMailSend)-1))  //retira o ultimo caracter da string, no caso o ";" do final
//
//	MaFisRestore(nSavNF)
//      
//	If Empty(cMailSend)
//       RestArea(aArea)
//		Return
//	Endif
//  
//
//	CONNECT SMTP SERVER GETMV("MV_RELSERV") ACCOUNT GETMV("MV_RELACNT") PASSWORD GETMV("MV_RELPSW")
//
//	If cAccount=' '
//		cAccount:=GETMV("MV_RELACNT")
//	Endif
//
//
//	SEND MAIL FROM cAccount ;
//		TO          cMailSend   ;
//		BCC     	cEmailBcc   ;
//		SUBJECT     cSubJect    ;
//		BODY cHtml
//	DISCONNECT SMTP SERVER
//
//
//	RestArea(aArea)
//
//Return( )
//
//Static Function BuscaDados(orcamento,FILIAL)
//
//	Local nLiq     := 0
//	Local nValIpi  := 0
//	Local lCalcIpi := .F.
//	Local cDescProd:=' '
//	Local cText       :=''
//
//	Local cRetorno    := ' '
//	Local cMsgObs     := SubStr(SuperGetMV( "MV_MSGOBS",, "" ),1,Len(SuperGetMV( "MV_MSGOBS",, "" )))
//	Local nTamamMSGOBS:= Len(cMsgObs)
//
//	ZA7->( dbSetOrder( 1 ) ) //ZA7_FILIAL+ZA7_CODPRO
//
//	aStru:={}
//	cQueryUB := ""
//	aEval( aStru, { |x| cQueryUB += "," + AllTrim( x[ 1 ] ) } )
//
//// PESQUISO OS ITENS DO ORÇAMENTO 
//
///*
//cQueryUB :=" SELECT SUB.UB_FILIAL,SUB.UB_EMISSAO,SUB.UB_NUM,SUB.UB_PRODUTO,SUB.UB_ITEM,SUB.UB_QUANT,SUB.UB_VRCACRE,SUB.UB_DTENTRE,SUB.UB_VLRITEM,SUB.UB_TES,SB1.B1_COD,SB1.B1_DESC,SB1.B1_UM,SB1.B1_FILIAL,SB1.B1_IPI,SB1.B1_PESO,SB1.B1_OBSTPES,SB1.B1_PESBRU,SB1.B1_PESBRU,SF4.F4_FILIAL,SF4.F4_CODIGO,SF4.F4_IPI FROM "
//cQueryUB += RetSqlName( "SUB" )+ " SUB, " + RetSqlName( "SB1" ) + " SB1, " + RetSqlName( "SF4" ) + " SF4 "
//cQueryUB +=" WHERE "
//cQueryUB +=" UB_FILIAL = '" +FILIAL + "'"
//cQueryUB +=" AND UB_NUM = '" +orcamento + "'"
//cQueryUB +=" AND B1_FILIAL = UB_FILIAL  "
//cQueryUB +=" AND F4_FILIAL = UB_FILIAL  "
//cQueryUB +=" AND B1_COD = UB_PRODUTO  "
//cQueryUB +=" AND F4_CODIGO = UB_TES  "
//cQueryUB +=" AND SUB.D_E_L_E_T_ = ' ' "
//cQueryUB +=" AND SB1.D_E_L_E_T_ = ' ' "
//cQueryUB +=" AND SF4.D_E_L_E_T_ = ' '"
//cQueryUB +=" ORDER BY UB_ITEM"
////cQueryUB := ChangeQuery(cQueryUB)
//*/
//
//	cQueryUB := " SELECT SUB.UB_FILIAL,SUB.UB_EMISSAO,SUB.UB_NUM,SUB.UB_PRODUTO,SUB.UB_ITEM,SUB.UB_QUANT,SUB.UB_VRCACRE,"
//	cQueryUB += "SUB.UB_DTENTRE,SUB.UB_VLRITEM,SUB.UB_TES,SB1.B1_COD,SB1.B1_DESC,SB1.B1_UM,SB1.B1_FILIAL,SB1.B1_IPI,SB1.B1_PESO,SB1.B1_OBSTPES,"
//	cQueryUB += "SUA.UA_CLIENTE,SUA.UA_LOJA,SUA.UA_DESPESA,SA1.A1_TIPO,"
//	cQueryUB += "SB1.B1_PESBRU,SB1.B1_PESBRU,SB1.B1_POSIPI,SF4.F4_FILIAL,SF4.F4_CODIGO,SF4.F4_IPI FROM "
//	cQueryUB += RetSqlName( "SUB" )+ " SUB, "+RetSqlName( "SUA" )+ " SUA, " +RetSqlName( "SA1" )+ " SA1, "+ RetSqlName( "SB1" ) + " SB1, " + RetSqlName( "SF4" ) + " SF4 "
//	cQueryUB +=" WHERE "
//	cQueryUB +=" UB_FILIAL = '" +FILIAL + "'"
//	cQueryUB +=" AND UB_NUM = '" +orcamento + "'"
//	cQueryUB +=" AND UA_FILIAL = UB_FILIAL  "
//	cQueryUB +=" AND UA_NUM = UB_NUM  "
//	cQueryUB +=" AND UA_CLIENTE = A1_COD "
//	cQueryUB +=" AND UA_LOJA = A1_LOJA "
//	cQueryUB +=" AND B1_FILIAL = UB_FILIAL  "
//	cQueryUB +=" AND F4_FILIAL = UB_FILIAL  "
//	cQueryUB +=" AND B1_COD = UB_PRODUTO  "
//	cQueryUB +=" AND F4_CODIGO = UB_TES  "
//	cQueryUB +=" AND SUB.D_E_L_E_T_ = ' ' "
//	cQueryUB +=" AND SB1.D_E_L_E_T_ = ' ' "
//	cQueryUB +=" AND SF4.D_E_L_E_T_ = ' '"
//	cQueryUB +=" ORDER BY UB_ITEM"
//	cQueryUB := ChangeQuery(cQueryUB)
//
//	dbUseArea( .t., "TOPCONN", TCGenQry( ,, cQueryUB ), "CITENS", .F., .T. )
//
//
//	For ni := 1 to Len( aStru )
//		If aStru[ ni, 2 ] <> 'C'
//			TCSetField( 'CITENS', aStru[ni,1], aStru[ni,2], aStru[ni,3], aStru[ni,4] )
//		Endif
//	Next
//
//	TCSetField( "CITENS", "UB_DTENTRE", "D", 8, 0 )
//
//	DBSELECTAREA('CITENS')
//	DBGOTOP()
//
//	While !Eof()
//	
//	
//		If CITENS->F4_IPI = 'S'
//			lCalcIpi := .T.
//		Else
//			lCalcIpi := .F.
//		EndIf
//	
//		nLiq := A410Arred(CITENS->UB_VRCACRE * CITENS->UB_QUANT, "UB_VLRITEM")
//	
//		nTotProd+=CITENS->UB_QUANT
//	
//	
//	// calculo valor liquido + IPI
//		If lCalcIpi
//			nValIpi := NoRound(nLiq + NoRound(((nLiq * CITENS->B1_IPI)/100),2), 2)
//		Else
//			nValIpi:=nLiq
//		Endif
//	
//		cRetorno:=CITENS->B1_OBSTPES
//		
//	//Verifica se o produto é PROMO
//		If SubStr(Alltrim(cRetorno),1,nTamamMSGOBS) == cMsgObs
//		      
//			If ZA7->( dbSeek( FILIAL + CITENS->B1_COD, .f. ) )
//				If !Empty(ZA7->ZA7_TPPROM)
//					For i=1 to val(ZA7->ZA7_TPPROM)
//						cText+='*'
//					Next i
//				Endif
//			EndIf
//	      
//			cDescProd:=cText+' '+CITENS->B1_DESC
//			lTemPromo:=.T. //Identifica que este orçamento/pedido possui itens na Promoção
//			cText:=' '
//		Else
//			cDescProd:=CITENS->B1_DESC
//		Endif
//	
//
//
//	// calcula peso
//		nPesol := nPesol + (CITENS->B1_PESO   * CITENS->UB_QUANT)
//		nPesob := nPesob + (CITENS->B1_PESBRU * CITENS->UB_QUANT)
//	
//	
////	AADD( aDados, {CITENS->B1_UM,Str(CITENS->UB_QUANT),Str(CITENS->UB_VRCACRE),cDescProd,Dtoc(CITENS->UB_DTENTRE),Str(CITENS->B1_IPI),Str(nValIpi)} )
//
//		AADD( aDados, {CITENS->B1_UM,Str(CITENS->UB_QUANT),Str(CITENS->UB_VRCACRE),cDescProd,Dtoc(CITENS->UB_DTENTRE),Str(CITENS->B1_IPI),Str(nValIpi),CITENS->UB_PRODUTO,CITENS->B1_POSIPI,;
//			CITENS->UA_CLIENTE,CITENS->UA_LOJA,CITENS->A1_TIPO,CITENS->UB_TES,Str(CITENS->UB_VLRITEM),Str(CITENS->UA_DESPESA),CITENS->F4_IPI} )
//
//	
//		DbSkip()
//	Enddo
//
//
//	DBSELECTAREA('CITENS')
//	DbCloseArea()
//
//Return(aDados)



