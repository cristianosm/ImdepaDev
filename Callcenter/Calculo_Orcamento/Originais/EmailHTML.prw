#include "rwmake.ch"
#include "ap5mail.ch"
#Include "TopConn.ch"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥EmailHtml     ∫ Edivaldo GonÁalves Cordeiro      01/11/2004 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Envia OrÁamento em Html para Rep/Coordenador/Cliente       ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Call Center                                                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/                        //MANUTEN«’ES
******************************************************************************************
*//  ALTERADO EM : 05/11/2004                                                                       *
*//- Quando  Filial = SP. O Sistema passa a perguntar sobre o envio do e-mail                       *
*//- Devido aos REP's Free Lance que trabalham para a IMDEPA                                        *
*//- Alterado o Recebimento de Par‚metros, foi incluso o Par‚metro (tipo)                           *
*                                                                                                   *
******************************************************************************************
*// ALTERADO EM : 08/12/2004  ·s 10:52                                                              *
* // - A funÁ„o (U_EmailHtml) passa a enviar mais vari·veis : FRETE,CONTATO,CODIGO CLIENTE e LOJA.  *
* // - A aplicaÁ„o passa a tratar a loja para o cliente na hora de enviar o email.                  *
* // - Foi implementado para que quando a previs„o de entrega estiver em branco,                    *
* //  significa que n„o possui estoque da mercadoria, imprimindo IndisponÌvel na previs„o de entrega*
* //  Edivaldo GonÁalves Cordeiro                                                                   *
*                                                                                                   *
******************************************************************************************
*// ALTERADO EM : 12/06/2006  as 10:56                                                              *
*// - Modificado nTotGeral (Tot.C/IPI) buscando do UA_VLRLIQ                                        *
******************************************************************************************
*// Alterado em 03/02/2007 as 15:48                                                                 *
*  //Corrigido o problema de falha no envio do e-mail                                               *
*----------------------------------------------------------------------------------------*

User Function EmailHtml(orc,cliente,codLoja,codfil,pedido,tipo,oc,frete,contact,codcontact,lFlag)
Return()

//Local aArea       :=  GetArea()
//Local cMensagem   := ''
//Local aLista      := {}
//Local CRLF        := chr(13)+chr(10)
//Local cMSG        := ""
//
//Local cCliente    :=""
//Local cIDClient   :=""
//Local cLoja       :=""
//Local cEnd        :=""
//Local cNEnd       :=0
//Local cBairro     :=""
//Local cCidade     :=""
//Local cEst        :=""
//Local cCep        :=""
//Local cFone       :=""
//Local cDDD        :=""
//Local cFax        :=""
//Local cCNPJ       :=""
//Local cINSC       :=""
//Local cEmail      :=""
//Local cContato    :=""
//Local cOperado    :=""
//Local nTotProd    :=0
//Local cOc         :=""
//Local cTpfrete    :=""
//Local cRep        :=""
//Local cCodRep     :=""
//Local cCodCo      :=""
//Local trans       :=""
//Local flag        :=""
//Local cServer     := GetMV('MV_RELSERV')
//Local cUser       := GetMV('MV_RELACNT')
//Local cPass       := GetMV('MV_RELPSW')
//Local lAuth       := Getmv("MV_RELAUTH")
//Local lResult     := .F.
//Local cError 
//Local op
//Local cTipoVenda
//
//Local nTotIcmsRet := 0
//
//Private aDados    := {}
//Private oper      :=""
//Private lEnvia    := .F.
//Private cPara     := "" 
//Private nTotGeral := 0
//Private nPesol    := 0
//Private nPesob    := 0
//Private DescCond  :=""
//Private DescTrans :=""
//Private ValDesp   :=0
//
//Private aImposto  := {} 
//Private nvST      := 0
//Private nVlrSu    := 0
//Private nTOTSUFRAMA := 0
//
//Private ValMerc1  := 0
//Private nTotLiq   := 0
//Private nTotIpi   := 0
//Private nTotGeral := 0
//Private nTotST    := MAFISRET(,"NF_VALSOL")
//
//cMsg += '<html>' + CRLF
//cMsg += '<head>' + CRLF
//cMsg += '<title> OrÁamento </title>' + CRLF
//cMsg += '</head>' 
//
////Captura o CabeÁalho do OrÁamento(SUA)
//IF SELECT( "CONSUA" ) <> 0
//   dbSelectArea("CONSUA")
//   CONSUA->(DbCLoseArea())
//Endif 
//
//cQuery :=" SELECT SA1.A1_FILIAL,SA1.A1_COD,SA1.A1_NOME,SA1.A1_VENDEXT,SA1.A1_LOJA,SA1.A1_END,SA1.A1_CEP,"
//cQuery +=" SA1.A1_CGC,SA1.A1_INSCR,SA1.A1_TIPO,SA1.A1_BAIRRO,SA1.A1_EST,SA1.A1_FAX,SA1.A1_TEL,SA1.A1_DDD,SA1.A1_EMAIL,"
//cQuery +=" SA1.A1_VEND,SA1.A1_VENDCOO,SA1.A1_NUMEND,SA1.A1_MUN,SUA.UA_FILIAL,SUA.UA_NUM,SUA.UA_CLIENTE,"
//cQuery +=" SUA.UA_OPERADO,SUA.UA_VLRLIQ,SUA.UA_VALMERC,SUA.UA_VALBRUT,SUA.UA_ACRESCI,SUA.UA_DESCONT,SUA.UA_FRETE,"
//cQuery +=" SUA.UA_DESPESA,SUA.UA_VEND,SUA.UA_CONDPG,SUA.UA_TRANSP,SUA.UA_OCCLI,SUA.UA_TPFRETE,SU7.U7_COD,SU7.U7_NOME FROM "
//cQuery += RetSqlName( "SA1" )+ " SA1, " + RetSqlName( "SUA" ) + " SUA, " + RetSqlName( "SU7" ) + " SU7 "
//cQuery +=" WHERE "
//cQuery +=" A1_FILIAL = '" + xFilial("SA1") + "'"
//cQuery +=" AND A1_COD = '" +cliente + "'"
//cQuery +=" AND A1_LOJA = '" +codLoja+ "'"
//cQuery +=" AND UA_NUM = '" +orc + "'"
//cQuery +=" AND UA_CLIENTE ='"+cliente +"'"
//cQuery +=" AND UA_FILIAL ='"+codfil +"'"
//cQuery +=" AND U7_COD = UA_OPERADO "
//cQuery +=" AND SUA.D_E_L_E_T_ = ' '"
//cQuery +=" AND SA1.D_E_L_E_T_ = ' '"
//cQuery +=" AND SU7.D_E_L_E_T_ = ' ' "
//
//TCQUERY cQuery NEW ALIAS "CONSUA"
//
//
//TCSetField("CONSUA","UA_VLRLIQ" ,"N",14, 2)
//TCSetField("CONSUA","UA_VALMERC","N",14, 2)
//TCSetField("CONSUA","UA_ACRESCI","N",10, 2)
//TCSetField("CONSUA","UA_FRETE"  ,"N",14, 2)
//TCSetField("CONSUA","UA_DESPESA","N",14, 2)
//TCSetField("CONSUA","UA_DESCONT","N",10, 2)
//
//DBSELECTAREA("CONSUA")
//DBGOTOP()
//
//cCliente      := CONSUA->A1_NOME
//cIDClient     := CONSUA->A1_COD
//cLoja         := CONSUA->A1_LOJA
//cEnd          := U_ALTEND(CONSUA->A1_END)
//cNEnd         := CONSUA->A1_NUMEND
//cCep          := CONSUA->A1_CEP
//cFone         := CONSUA->A1_TEL
//cDDD          := CONSUA->A1_DDD
//cCNPJ         := CONSUA->A1_CGC
//cINSC         := CONSUA->A1_INSCR
//cCliTipo      := CONSUA->A1_TIPO
//cEmailCliente := CONSUA->A1_EMAIL
//cBairo        := CONSUA->A1_BAIRRO
//cCidade       := CONSUA->A1_MUN
//cEst          := CONSUA->A1_EST
//cCep          := CONSUA->A1_CEP
//cFax          := CONSUA->A1_FAX
//cOperado      := CONSUA->U7_NOME
//cCodRep       := CONSUA->A1_VEND
//cCodCo        := CONSUA->A1_VENDCOO
//condPg        := CONSUA->UA_CONDPG
//trans         := CONSUA->UA_TRANSP
//ValDesp       := CONSUA->UA_DESPESA
//cOc           := CONSUA->UA_OCCLI
//ValFrete      := CONSUA->UA_FRETE 
//cNumOrca      := CONSUA->UA_NUM
//
//
//If CONSUA->UA_TPFRETE='F'
//	cTpfrete :="FOB"
//Else
//	cTpfrete :="CIF"
//Endif
//
////CondiÁ„o de Pagamento
// DescCond    := Posicione("SE4",1,xFilial("SE4")+condPg,"E4_DESCRI")
////Transportadora
//DescTrans    := Posicione("SA4",1,xFilial("SA4")+trans,"A4_NOME")
////E-mail do Representante
//cMailRep     := Posicione("SA3",1,xFilial("SA3")+cCodRep,"A3_EMAIL")
////Email do Coordenador      
//cMailCoord   := Posicione("SA3",1,xFilial("SA3")+cCodCo,"A3_EMAIL")
//
//
//If tipo='1'
// cTipoVenda='Pedido'
// Else
//  cTipoVenda='OrÁamento'
// Endif
// 
// //Tratamento para e-mail do Cliente
// If tipo='1'   .and. !Empty(cEmailCliente)
//	
//	op:=IW_MsgBox ("Confirma o envio do "+cTipoVenda + " Autom·tico para o Cliente ?"," Email Autom·tico","YESNO")
//
//    If op =.T.
//		cPara:=Alltrim(cEmailCliente)+";"	
//	
//	Endif
//		
//Endif
//
// 
////Tratamento para e-mail do Representante 
// If  !Empty(cMailRep)
//	   
//	   op:=IW_MsgBox ("Confirma o envio do "+cTipoVenda + " Autom·tico para o Representante ?"," Email Autom·tico","YESNO")
//		
//		If op=.T.
//			cPara:=cPara+Alltrim(cMailRep)+";"
//		Endif
//Endif
//
//If ! op
//   Return .F.
//Endif
//
//
//If !Empty(cMailCoord)
// cPara:=cPara+Alltrim(cMailCoord)+";"
//Endif
// 
//cPara := Left(cPara,Len(cPara)-1)  //retira o ultimo caracter da string, no caso o ";" do final	
//
//If Empty(cPara)
//  Return.F.
//Endif
//
///*
//cQueryUA := " SELECT SUM(UA_VALBRUT+UA_ACRESCI+UA_DESPESA+UA_FRETE-UA_DESCONT)as ValLiq "
//cQueryUA += " FROM "+RetSQLName("SUA")+"  "
//cQueryUA += " WHERE "
//cQueryUA += " UA_FILIAL = '" +codFil+"'"
//cQueryUA += " AND UA_NUM = '" +orc+ "'"
//cQueryUA += " AND D_E_L_E_T_ = ' ' "
//cQueryUA := ChangeQuery(cQueryUA)
//dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQueryUA),"cQuery1",.F.,.T.)
//
//DBSELECTAREA("cQuery1")
//nTotLiq:=cQuery1->ValLiq
//DbCloseArea()
//*/
//
//cQuery := " SELECT SUM(UB_QUANT) TOTREG "
//cQuery += " FROM "+RetSQLName("SUB")+"  "
//cQuery += " WHERE "
//cQuery += " UB_FILIAL = '" +codFil+"' "
//cQuery += " AND UB_NUM = '" +orc+ "'"
//cQuery += " AND D_E_L_E_T_ = ' ' "
//cQuery := ChangeQuery(cQuery)
//dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"cQuery",.F.,.T.)
//
//DBSELECTAREA("cQuery")
//
//nTotProd	:=cQuery->TOTREG
//nTotGeral	:=CONSUA->UA_VLRLIQ
//
//
//DBCLOSEAREA()
//DBSELECTAREA("CONSUA")
//DbCloseArea()
//
//
//cMsg += '<b><font size="3" face="Courier">*** Esse È um e-mail autom·tico.N„o respondÍ-lo ***</font></b>'+ CRLF
//cMsg += '<hr width=100% noshade>'
//
//cMsg +='<pre>'
//
//cMsg += '<b><font size="2" face="Courier">Cliente : </font></b>'+ALLTRIM(cCliente)+" - "+'<b><font size="2" face="Courier">'+ALLTRIM(cIDClient)+'</font></b>'+"/"+'<b><font size="2" face="Courier">'+cLoja+'</font></b>'+CRLF// +oper2
//cMsg += '<b><font size="2" face="Courier">EndereÁo : </font></b>'+ALLTRIM(cEnd) +" -  "+ALLTRIM(Str(cNEnd))+ CRLF
//cMsg += '<b><font size="2" face="Courier">Bairo    : </font></b>'+cBairro+ CRLF
//cMsg += '<b><font size="2" face="Courier">Cidade   : </font></b>'+ALLTRIM(cCidade)+" /"+ cEst+CRLF
//
//cMsg += '<b><font size="2" face="Courier">Fone     : </font></b>'+'('+cDDD+')'+ALLTRIM(cFone)+'<b><font size="2" face="Courier">    Fax: </font></b>'+cFax+ CRLF
//cMsg += '<b><font size="2" face="Courier">CNPJ     : </font></b>'+cCNPJ+'<b><font size="2" face="Courier">  Insc.Estadual: </font></b>'+cINSC+ CRLF
//cMsg += '<b><font size="2" face="Courier">Email    : </font></b>'+cEmailCliente+CRLF
//cMsg += '<b><font size="2" face="Courier">Contato  : </font></b>'+contact+ CRLF
//cMsg += '<b><font size="2" face="Courier">Operador : </font></b>'+cOperado+ CRLF
//cMsg += '<b><font size="2" face="Courier">O.Compra : </font></b>'+ALLTRIM(cOc)+"           "+'<b><font size="2" face="Courier">Frete : </font></b>'+ALLTRIM(cTpfrete)+ CRLF// +oper2
//
//
//
//If tipo='1'
//	cMsg += '<b><font size="2" face="Courier">Pedido   : </font></b>'+pedido+ CRLF
//	Flag='Pedido de Venda'
//Else
//	cMsg += '<b><font size="2" face="Courier">OrÁamento: </font></b>'+orc+ CRLF
//	Flag='Orcamento de Venda'
//Endif
//
//cMsg +='</pre>'
//
//cMsg +='<MARQUEE BEHAVIOR=SCROLL DIRECTION=RIGHT><font size="4" color="#000066"><i><b>GOODYEAR</b></i></font> </MARQUEE>'+ CRLF
//cMsg +='<MARQUEE BEHAVIOR=SCROLL WIDTH=30%><font size="4" color="#FF0000"><i><b>SABO</b></i></font> </MARQUEE>'+CRLF
//cMsg +='<MARQUEE BEHAVIOR=SCROLL DIRECTION=RIGHT><font size="4" color="#FF6600"><i><b>TIMKEN</b></i></font> </MARQUEE>'+CRLF
//cMsg +='<MARQUEE BEHAVIOR=SCROLL WIDTH=30%><font size="4" color="#00CC00"><i><b>INA</b></i></font> </MARQUEE>'+CRLF
//cMsg +='<MARQUEE BEHAVIOR=SCROLL DIRECTION=RIGHT><font size="4" color="#000000"><i><b>LUK</b></i></font> </MARQUEE>'+CRLF
//cMsg +='<MARQUEE BEHAVIOR=SCROLL WIDTH=30%><font size="4" color="#FF0000"><i><b>FAG</b></i></font> </MARQUEE>'//+CRLF
//cMsg += '<hr width=1003% noshade>'
//
////Abre Tabela
//cMsg += '<table border="1" width="103%" bgcolor="#0080C0">'
//cMsg += '<tr>'
//
//cMsg += '<td width="10%">'
//cMsg += '<font size="2" face="Arial">Codigo</font></td>'
//
//cMsg += '<td width="16%">'
//cMsg += '<font size="2" face="Arial">DescriÁ„o</font></td>'
//cMsg += '<td width="3%">'
//cMsg += '<font size="2" face="Arial">Un</font></td>'
//cMsg += '<td width="7%">'
//cMsg += '<font size="2" face="Arial">Qtd</font></td>'
//cMsg += '<td width="8%">'
//cMsg += '<font size="2" face="Arial">Vlr. Unit</font></td>'
//
//cMsg += '<td width="3%">'
//cMsg += '<font size="2" face="Arial">IPI</font></td>'
//
//cMsg += '<td width="3%">'
//cMsg += '<font size="2" face="Arial">ST</font></td>'
//
//cMsg += '<td width="3%">'
//cMsg += '<font size="2" face="Arial">Pr.Un.c/IPI e ST</font></td>'
//
//cMsg += '<td width="06%">'
//cMsg += '<font size="2" face="Arial">NCM</font></td>'
//
//cMsg += '<td width="5%">'
//cMsg += '<font size="2" face="Arial">P.Entrega</font></td>'
//
//
//cMsg += '<td width="6%">'
//cMsg += '<font size="2" face="Arial">Tot c/IPI e ST</font></td>'
//
//cMsg += '</tr>'
//
//aDados := BuscaDados(orc,codFil)
//
//For x:= 1 to Len(aDados)
//	
//	item    := alltrim(aDados[x,1]) 
//	nQTDVEN := val(alltrim(aDados[x,2]))
//	prec    := val(alltrim(aDados[x,3])) //PreÁo com AcrÈscimo
//	DescProd:= alltrim(aDados[x,4])
//
//	cPRODUTO:= alltrim(aDados[x,8])
//	NCM     := alltrim(aDados[x,9])
//	
//	cCLIENTE:= alltrim(aDados[x,10]) 
//	cLOJCLI := alltrim(aDados[x,11]) 
//	cTIPCLI := alltrim(aDados[x,12]) 
//	cTES    := alltrim(aDados[x,13]) 
//	nVLRITEM:= val(alltrim(aDados[x,14]))
//   nTDepesa := val(alltrim(aDados[x,15])) 
//	cIPI    := alltrim(aDados[x,16]) 
//	nIpiSB1 := val(alltrim(aDados[x,6])) 
//
//				
//	nPRCVEN := NoRound(nVLRITEM/nQTDVEN,4) //SUB->UB_VRCACRE
//   nVALOR  := nQTDVEN * NOROUND(prec,4) 
//
//	cQuery := "SELECT TRUNC( SUM( UB_VRCACRE * UB_QUANT ), 2 ) AS VAL_MERC "
//	cQuery += "  FROM " + RetSqlName("SUB") + " "
//	cQuery += " WHERE D_E_L_E_T_ = ' ' "
//	cQuery += "   AND UB_FILIAL  = '" + xFilial("SUB") + "' "
//	cQuery += "   AND UB_NUM     = '" + cNumOrca + "' "
//
//	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY_SUB1",.F.,.T.)
//	DbSelectArea("QRY_SUB1")
//	DbGoTop()
//
//	nTotQtd := 0
//	If QRY_SUB1->( !EOF() )
//		nTotMerc := QRY_SUB1->VAL_MERC
//	EndIf
//	QRY_SUB1->( DbCloseArea() )
//
//
//
//	nLiq     := NoRound( prec * nQTDVEN, 4 )
//	nVRatDes := NoRound(( nTDepesa / nTotMerc ) * nLiq , 6)
//			
//	NDESPESA:= NVRATDES
//
//	aImposto    := U_xImposto(cCliente,cLojCli,cTipCli,cPRODUTO,cTES,nQTDVEN,nPRCVEN,nVALOR,NDESPESA,x)
//	nvST        := NoRound(aImposto[1],4)  	//MAFISRET(NITEM,"LF_ICMSRET")//NoRound(aImposto[1],4)
//                
//   ///para pegar o valor da suframa por item (se houver)
//	nVlrSu      := NoRound(aImposto[2],4)
//	nTOTICMSRET += nvST
//				
//
//
//
//	nTOTSUFRAMA := 0 //nSUF //MAFISRET(,"NF_DESCZF") //nSUF  //VINDO DIRETO
//			
//			
//	// Jorge Oliveira - 31/01/2011 - Ajustes para mostrar o valor Unitario c/IPI
//
//
//	///Julio Jacovenko, 24/04/2012
//	nLIQ1 := prec
//		
//	// Jorge Oliveira - 31/01/2011 - Ajustes para mostrar o valor Unitario c/IPI
//	If ValDesp > 0
//		nVRatDes := ( ValDesp / nTotMerc ) * nLiq
//		VRatDes1 := ( ValDesp / nTotMerc ) * nLiq1
//		Else
//		   nVRatDes := 0
//		   VRatDes1 := 0
//	EndIf
//	
//	// Jorge Oliveira - 31/01/2011 - Ajustes para mostrar o valor Unitario c/IPI
//	If ValFrete > 0
//		nVRatFre := ( ValFrete   / nTotMerc ) * nLiq
//		VRatFre := ( ValFrete   / nTotMerc ) * nLiq1
//
//		Else
//			nVRatFre := 0
//			VRatFre  := 0
//	EndIf
//
//	nValIpi := 0
//	nValIpi1:= 0
//	If cIPI = "S"
//				// Jorge Oliveira - 31/01/2011 - Ajustes para mostrar o valor Unitario c/IPI
//				//nValIpi := Round( ( nLiq + nVRatDes + nVRatFre ) * ( SB1->B1_IPI/100 ), 2 )
//				//Inserido por Edivaldo Goncalves Cordeiro em 16/06/11 Valor com IPI eh o Liquido + % IPI
//				//nValIpi := Round(  nLiq  * ( SB1->B1_IPI/100 ), 2 )  
//				
//				///JULIO JACOVENKO - 20/02/2012
//				///Ajustado para calcular o imp sobre o frete e outras 
//				///despesas NO TOTAL, estava usando somente o NLIQ (Vlr sem despesas)
//		nValIpi := Round(  (nVRatDes+nVRatFre+nLiq)  * ( nIpiSB1/100 ), 2 )
//		nValIpi1:= Round(  (VRatDes1+VRatFre+nLiq1)  * ( nIpiSB1/100 ), 2 )
//				
//	EndIf
//
//	nValMerc  := nLiq  + nValIpi  + nvST   //U_FValIcmsRet()
//			
//	ValMerc1  := nLiq1 + nValIpi1 + NOROUND(nvST/nQTDVEN,4)
//	nTotLiq   += nLiq
//	nTotIpi   += nValIpi
////	nTotGeral += nValMerc
//
//
//
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
//
//    nVlrST:=NOROUND(nvST/nQTDVEN,4)
//
//
//	cMsg += '<tr>'
//
//	cMsg += '<td width="10%">'
//	cMsg += '<font size="2" Color="#FFFFFF" face="Arial">' +cPRODUTO+ '</font></td>'
//
//	cMsg += '<td width="16%">'
//	cMsg += '<font size="2" Color="#FFFFFF" face="Arial">' +Substring(DescProd,1,16) + '</font></td>'
//	cMsg += '<td width="3%">'
//	cMsg += '<font size="2" Color="#FFFFFF" face="Arial">' + item + '</font></td>'
//	cMsg += '<td width="7%">'
//	cMsg += '<font size="2" Color="#FFFFFF" face="Arial">' +Transform(nQTDVEN,'@E 999,999.99') + '</font></td>'
//	cMsg += '<td width="8%">'
//	cMsg += '<font size="2" Color="#FFFFFF" face="Arial">' +Transform(prec,'@E 9,999,999.9999') + '</font></td>'
//	cMsg += '<td width="3%">'
//	cMsg += '<font size="2" Color="#FFFFFF" face="Arial">' +Transform(ipi,'@E 99.99')+'</font></td>'
//
//	cMsg += '<td width="8%">'
//	cMsg += '<font size="2" Color="#FFFFFF" face="Arial">' +Transform(nVlrST,'@E 9,999,999.9999') + '</font></td>'
//
//	cMsg += '<td width="8%">'
//	cMsg += '<font size="2" Color="#FFFFFF" face="Arial">' +Transform(NValMerc/nQTDVEN,'@E 9,999,999.9999') + '</font></td>'
//
//	cMsg += '<td width="10%">'
//	cMsg += '<font size="2" Color="#FFFFFF" face="Arial">' +NCM+ '</font></td>'
//
//	
//	cMsg += '<td width="5%">'
//	cMsg += '<font size="2" Color="#FFFFFF" face="Arial">' +PrEntreg + '</font></td>'
//	
//	cMsg += '<td width="6%">'
//	cMsg += '<font size="2" Color="#FFFFFF" face="Arial">' +Transform(NValMerc,'@E 9,999,999.99')+'</font></td>'
//	cMsg += '</tr>'
//	
//Next
//
//
//cMsg +='<TABLE BORDER=1 bgcolor="#0080C0">'
//cMsg += '<b><font size="2" face="Courier">Totais : </font></b>'
//cMsg +='<TR><TH>Qtd Total</TH><TH>P.Liq</TH><TH>P.Bruto</TH><TH>Despesa</TH><TH>Valor IPI</TH><TH>Valor ST</TH><TH>Valor Frete</TH><TH>Tot.Liq</TH><TH>Valor Total</TH></TR>'
//cMsg +='<TR><TD>'+Transform(nTotProd,'@E 99999.99')+'</TD><TD>'+Transform(nPesol,'@E 99999.99')+'</TD><TD>'+Transform(nPesob,'@E 99999.99')+'</TD>'
//cMsg +='<TD>'+Transform(ValDesp,'@E 9,999,999.99')+'</TD>'
//cMsg +='<TD>'+Transform(nTotIpi,'@E 9,999,999.99')+'</TD>'
//cMsg +='<TD>'+Transform(nTotST,'@E 9,999,999.99')+'</TD>'
//cMsg +='<TD>'+Transform(ValFrete,'@E 9,999,999.99')+'</TD>'
//cMsg +='<TD>'+Transform(nTotLiq,'@E 9,999,999.99')+'</TD>'
//cMsg +='<TD>'+Transform(nTotGeral,'@@E 9,999,999.99')+'</TD></TR>'
//cMsg +='</TABLE>'+ CRLF
//
//cMsg +='<pre>'
//
//cMsg += '<b><font size="2" face="Courier">Cond. Pagto :'+DescCond +'</font></b>'+ CRLF
//cMsg += '<b><font size="2" face="Courier">Despesa     :'+Alltrim(Transform(ValDesp,'@E 99,999,999,999.99'))+'</font></b>'+ CRLF// +oper2
//
//
//cMsg += '<b><font size="2" face="Courier">Transport.  : </font></b>'+Alltrim(DescTrans)+ CRLF
//
//cMsg += '<b><font size="2" face="Courier">Validade da Proposta : 02 (dois dias) </font></b>'+ CRLF
//
//cMsg += '<hr width=100% noshade>'
//
//cMsg += '<font size="2" face="Courier">N„o aceitamos devoluÁıes de mercadorias sem prÈvio </font>'+CRLF
//cMsg += '<font size="2" face="Courier">entendimento com nosso departamento de vendas. </font>'+CRLF
//cMsg += '<font size="2" face="Courier">Ser· acrescida despesa banc·ria por duplicata. </font>'+CRLF
//
//cMsg +='</pre>'
//
//cMsg += '</table>'
//
////cMsg += '<br><br><img src="http://www.portalimdepa.com.br/50anos/images/logo_selo_menor_50.jpg" hspace="10"><FONT size="3" COLOR="#23238E" face ="Arial">PARTICIPE DA CAMPANHA IMDEPA 50 ANOS. ACESSE O PORTAL <a href="http://www.portalimdepa.com.br/50anos">WWW.PORTALIMDEPA.COM.BR/50ANOS</a>, CADASTRE-SE E CONCORRA A UM CRUZEIRO PELA COSTA BRASILEIRA.</FONT>'+ CRLF
//
//cMsg += '</body>' + CRLF
//cMsg += '</html>' + CRLF
//
//Aadd( aLista, cPara )
//
//CONNECT SMTP SERVER cServer ACCOUNT cUser PASSWORD cPass RESULT lResult
//
//
//// fazendo autenticacao 
//If lResult .And. lAuth
//	lResult := MailAuth(cUser,cPass)
//	If !lResult
//		lResult := QADGetMail() // Funcao que abre uma janela perguntando o usuario e senha para fazer autenticacao
//	EndIf
//	If !lResult
//		//Erro na conexao com o SMTP Server
//		GET MAIL ERROR cError
//		MsgInfo("Erro de Autenticacao no Envio de e-mail: "+cError)
//		Return Nil
//	Endif
//	
//EndIf
// 
// //Inserido por Edivaldo GonÁalves Cordeiro em 09/09/2009
// //O e-mail do orÁamento È originado pelo usu·rio logado no sistema
// cUserMail := Alltrim(UsrRetMail(SA3->(Retcodusr()))) 
// cFromEmail:= Iif(!Empty(cUserMail),cUserMail ,cUser)              
//
//
//SEND MAIL FROM cFromEmail ;
//     TO aLista[1];
//     BCC ' ';  
//     SUBJECT flag;
//     BODY cMsg;
//     RESULT lResult
// 
//If ! lResult
//	//Erro no envio do email
//	GET MAIL ERROR cError
//	Msginfo("Erro no envio de e-mail: "+cError)
//EndIf
//
//DISCONNECT SMTP SERVER
//
//RestArea(aArea)
//
//Return Nil
//
//
//Static Function BuscaDados(orcamento,FILIAL)
////Vari·veis de controle Local
//nLiq     := 0
//nValIpi  := 0  
//lCalcIpi := .F.
//
//aStru:={}
//cQueryUB := ""
//aEval( aStru, { |x| cQueryUB += "," + AllTrim( x[ 1 ] ) } )
//
//// PESQUISO OS ITENS DO OR«AMENTO EM QUEST√O
//cQueryUB :=" SELECT SUB.UB_FILIAL,SUB.UB_EMISSAO,SUB.UB_NUM,SUB.UB_PRODUTO,SUB.UB_ITEM,SUB.UB_QUANT,SUB.UB_VRCACRE,"
//cQueryUB += "SUB.UB_DTENTRE,SUB.UB_VLRITEM,SUB.UB_TES,SB1.B1_COD,SB1.B1_DESC,SB1.B1_UM,SB1.B1_FILIAL,SB1.B1_IPI,SB1.B1_PESO,"
//cQueryUB += "SUA.UA_CLIENTE,SUA.UA_LOJA,SUA.UA_DESPESA,SA1.A1_TIPO,"
//cQueryUB += "SB1.B1_PESBRU,SB1.B1_PESBRU,SB1.B1_POSIPI,SF4.F4_FILIAL,SF4.F4_CODIGO,SF4.F4_IPI FROM "
//cQueryUB += RetSqlName( "SUB" )+ " SUB, "+RetSqlName( "SUA" )+ " SUA, " +RetSqlName( "SA1" )+ " SA1, "+ RetSqlName( "SB1" ) + " SB1, " + RetSqlName( "SF4" ) + " SF4 "
//cQueryUB +=" WHERE "
//cQueryUB +=" UB_FILIAL = '" +FILIAL + "'"
//cQueryUB +=" AND UB_NUM = '" +orcamento + "'"
//cQueryUB +=" AND UA_FILIAL = UB_FILIAL  "
//cQueryUB +=" AND UA_NUM = UB_NUM  "
//cQueryUB +=" AND UA_CLIENTE = A1_COD "
//cQueryUB +=" AND UA_LOJA = A1_LOJA "
//cQueryUB +=" AND B1_FILIAL = UB_FILIAL  "
//cQueryUB +=" AND F4_FILIAL = UB_FILIAL  "
//cQueryUB +=" AND B1_COD = UB_PRODUTO  "
//cQueryUB +=" AND F4_CODIGO = UB_TES  "
//cQueryUB +=" AND SUB.D_E_L_E_T_ = ' ' "
//cQueryUB +=" AND SB1.D_E_L_E_T_ = ' ' "
//cQueryUB +=" AND SF4.D_E_L_E_T_ = ' '"
//cQueryUB +=" ORDER BY UB_ITEM"
//cQueryUB := ChangeQuery(cQueryUB)
//
//dbUseArea( .t., "TOPCONN", TCGenQry( ,, cQueryUB ), "CITENS", .F., .T. )
//
//
//For ni := 1 to Len( aStru )
//	If aStru[ ni, 2 ] <> 'C'
//		TCSetField( 'CITENS', aStru[ni,1], aStru[ni,2], aStru[ni,3], aStru[ni,4] )
//	Endif
//Next
//
//TCSetField( "CITENS", "UB_DTENTRE", "D", 8, 0 ) 
//
//DBSELECTAREA('CITENS')
//DBGOTOP()
//
//While !Eof()
//	
//	
//	If CITENS->F4_IPI = 'S'
//		lCalcIpi := .T.
//	Else
//		lCalcIpi := .F.
//	EndIf
//	
//	nLiq := A410Arred(CITENS->UB_VRCACRE * CITENS->UB_QUANT, "UB_VLRITEM")
//	
//	// calculo valor liquido + IPI
//	If lCalcIpi
//		nValIpi := NoRound(nLiq + NoRound(((nLiq * CITENS->B1_IPI)/100),2), 2)
//	Else
//		nValIpi:=nLiq
//	Endif
//
//	// calcula peso
//	nPesol := nPesol + (CITENS->B1_PESO   * CITENS->UB_QUANT)
//	nPesob := nPesob + (CITENS->B1_PESBRU * CITENS->UB_QUANT)
//	
//	AADD( aDados, {CITENS->B1_UM,Str(CITENS->UB_QUANT),Str(CITENS->UB_VRCACRE),CITENS->B1_DESC,Dtoc(CITENS->UB_DTENTRE),Str(CITENS->B1_IPI),Str(nValIpi),CITENS->UB_PRODUTO,CITENS->B1_POSIPI,;
//	CITENS->UA_CLIENTE,CITENS->UA_LOJA,CITENS->A1_TIPO,CITENS->UB_TES,Str(CITENS->UB_VLRITEM),Str(CITENS->UA_DESPESA),CITENS->F4_IPI} )
//	       
//	DbSkip()
//Enddo
//
//
//DBSELECTAREA('CITENS')
//DbCloseArea()
//
//Return(aDados)
