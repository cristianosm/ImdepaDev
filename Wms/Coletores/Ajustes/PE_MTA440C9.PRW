#INCLUDE 'RWMAKE.CH'
//
//
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA440C9  ºAutor  ³Microsiga           º Data ³ 16/04/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualizacao de campos no SUA e SC5 apos a liberacao do     º±±
±±º          ³ pedido de vendas                                           º±±
±±º          ³ Observacao: OS REGISTROS DO SC5,SC6,SC9 E SB2 ENTRAM NESTE º±±
±±º          ³             PONTO DE ENTRADA POSICIONADOS E TRAVADOS CON-  º±±
±±º          ³             FORME CONSULTA AO FONTE FATXFUN.PRX            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico para o cliente IMDEPA                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUltimas Alteracoes                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAutor     ³ Data     Ø  Descricao                                      º±±
±±º          ³          Ø                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*********************************************************************
User Function MTA440C9()
*********************************************************************
///Local aAreaSUA := SUA->(getarea())//| aArea[1]= Alias | aArea[2]= Indice | aArea[3]= Recno
Local aArea := GetArea()       //area atual
Local cAliasAnt
Local lRetWMS
Local nUltRec
Local cBlEst	:= SC9->C9_BLEST
Local cBlCred	:= Ver_Cod_Bloq(SC9->C9_BLCRED)// Verifica Codigo de Bloquei Customizado Atraves de Variavel Publica BLK_IMD criada em PE_MaAvCrPr

//| CAMPOS WMS
Local cBlWms	:= SC9->C9_BLWMS
Local cServic   := SC9->C9_SERVIC
Local cStServ   := SC9->C9_STSERV
Local cEndPad   := SC9->C9_ENDPAD
Local cTpCarg   := SC9->C9_TPCARGA
//Local cTpEstR   := SC9->C9_TPESTR

Local lRecLock	:= .F.


lCheck	:=	GetMv('IM_LOGSC9')
If lCheck
	If ExistBlock('ChkLogSC9')
		ExecBlock('ChkLogSC9', .F., .F., {'MTA440C9',SC9->C9_PRCVEN*SC9->C9_QTDLIB, 0})
	EndIf
EndIf


//Roda a Trava para correção de Pedidos com Divergência de Preço         
checkPrcVen()

/* Desabilitado por Edivaldo Gonçalves em 11/02/2016

//MATA455 - liberacao Estoque
If FUNNAME() == "IMDF260" .Or. FUNNAME() == "MATA455"
	Reposiciona() //| Reposiciona no Primeiro Registro Criado no SC9
EndIf 
*/

DbSelectArea("SC9")
lRecLock := Reclock("SC9",.F.)


If Empty(SC9->C9_DATENT) // 08/06/2018 - Correcao para o C9_DATENT em branco que faz com que o item nao aparece no faturamento do pedido
   SC9->C9_DATENT := DDATABASE
Endif

//| LIBERACAO COMERCIAL
IF Empty(SC9->C9_DTLCOM)
	
	If FUNNAME() == 'TMKA271'
		SC9->C9_TPLCOM  := "A"
	Else
		SC9->C9_TPLCOM  := "M"
	Endif
	SC9->C9_DTLCOM  := Date()
	SC9->C9_HRLCOM  := Time()
	SC9->C9_USRLCOM := SubStr( cUsuario, 7, 15 )

EndIf

If FUNNAME() == "IMDF260" //.Or. FUNNAME() == "MATA455"   
  Atu_HistSC9()// Atualiza o Histórico da Liberação Comercial quando se tiver uma liberação de crédito Manual 
Endif

//| LIBERACAO CREDITO
If Empty(cBlCred) .And. Empty(SC9->C9_USRLCRE)

	SC9->C9_BLCRED  := "  "
	SC9->C9_DTLCRE  := Date()
	SC9->C9_HRLCRE  := Time()
	
	If FUNNAME() == "A450LibAut" .Or.  FUNNAME() == 'TMKA271' .Or. PROCNAME(8) == "U_IMDF263" .or. FUNNAME() == "MATA455"
		SC9->C9_TPLCRE  := 'A'
	ElseIf FUNNAME() == "IMDF260"
		SC9->C9_TPLCRE  := 'M'
	Endif
	
	SC9->C9_USRLCRE := SubStr( cUsuario, 7, 15 )

Else
	SC9->C9_BLCRED := cBlCred
Endif

//| LIBERACAO ESTOQUE
If Empty(cBLEST) .And. Empty(SC9->C9_USRLEST)

    SC9->C9_BLEST	:= '  '
	SC9->C9_DTLEST	:= Date()
	SC9->C9_HRLEST	:= Time()
	If FUNNAME() == "MATA455"
		SC9->C9_TPLEST	:= 'M'
	Else
		SC9->C9_TPLEST	:= 'A'
	EndIf
	SC9->C9_USRLEST	:= SubStr( cUsuario, 7, 15 )

Else
	SC9->C9_BLEST	:= cBLEST
Endif

//| LIBERACAO WMS
//| Inserido por Edivaldo Gonçalves Cordeiro em 21/10/06 Verifica se o Produto é Gerenciado pelo WMS
//| Alterado por Agostinho em 08/07/08 / Correção de bloqueios em função do tipo de pedido
//| Habilita o apanhe do produto pelo WMS - Edivaldo Gonçalves Cordeiro 21/10/2006
//| Inserido por Edivaldo Goncalves Cordeiro em 12/01/2009 - Ajuste para gravar o historico das liberacoes

//| Mantem os Valores do WMS do registro Novo
SC9->C9_BLWMS 	:= cBlWms
SC9->C9_SERVIC	:= cServic
SC9->C9_STSERV	:= cStServ
SC9->C9_ENDPAD	:= cEndPad
SC9->C9_TPCARGA	:= cTpCarg
//SC9->C9_TPESTR	:= cTpEstR

If ! SC5->C5_TIPO $"C/I/P" .AND. SF4->F4_ESTOQUE == 'S' //.AND.  FUNNAME()='MATA410' //Se movimentar Estoque verifico se trata Controle de Localização
	
	MsAguarde({|| lRetWMS := SF4->(U_CheckWMS(SC9->C9_PRODUTO))},"WMS","Verificando se o item é Gerenciado pelo WMS...")

	If lRetWMS
        If Empty(SC9->C9_ENDPAD) .Or. Empty(SC9->C9_SERVIC) .Or. SC9->C9_BLWMS <> "01"
		
			If DC8->(dbSeek(xFilial('DC8')+'5'+SC9->C9_LOCAL, .F.))
				cTpEstFis      := DC8->DC8_CODEST
				cEPadDC8       := Alltrim(DC8->DC8_DESEST)
				If SBE->(dbSeek(xFilial('SBE')+SC9->C9_LOCAL + cEPadDC8, .F.)) // Verificar se endereco EXISTE
					SC9->C9_ENDPAD := cEPadDC8
					SC9->C9_SERVIC := SuperGetMv("IMD_SVCONF" , .F. , "001" , xFilial("SC6")) //DC5->(Posicione("DC5",2,xFilial("DC5") +'002',"DC5_SERVIC"))
				EndIf
			EndIf
			
			SC9->C9_BLWMS :='01' //Inserido em 16/12/06 o status de Bloqueio WMS, por Edivaldo Gonçalves Cordeiro
			//SC9->C9_ENDPAD:=SBE->(Posicione("SBE",1,xFilial("SBE") +SC9->C9_LOCAL+'DOCA',"BE_LOCALIZ"))
			//SC9->C9_SERVIC:=DC5->(Posicione("DC5",2,xFilial("DC5") +'002',"DC5_SERVIC"))
			
        EndIF
	Endif

Endif

If lRecLock
	lRecLock := .F.
	DbSelectArea("SC9")
	MsUnlock()
EndIf

/*
//| Inicio Expedito
//| Atualizar dados da NF no atendimento do Call Center    	     ³
cAliasAnt := alias()
DbSelectarea("SUA");DbSetOrder(8)
If MsSeek(xFilial("SUA")+SC9->C9_PEDIDO)
	If SUA->UA_STATUS != "LIB"
		Reclock("SUA",.F.)
			SUA->UA_STATUS:= "LIB"
		MsUnlock()
	Endif
Endif
*/

//³ Atualizar o usuario que liberou o pedido de venda.     	     ³
If SC5->C5_FILIAL+SC5->C5_NUM == xFilial("SC5")+SC9->C9_PEDIDO
	SC5->C5_LIBERAD := SC5->(RetCodUsr())
Else
	Alert("Nao foi possivel gravar o usuario que liberou o pedido de venda. Favor acionar o Depto. de Tecnologia Imdepa!")
Endif

//Restarea(aAreaSUA)
RestArea(aArea)

//DbSelectarea(cAliasAnt)
// Fim Expedito

Return()
*********************************************************************
Static Function Reposiciona() //| Reposiciona no Primeiro Registro Criado no SC9
*********************************************************************
/*
Private  nSC9NewRec := Recno()
Private  nSC9OldRec := 0

//|Levanta Recno do Primeiro REGISTRO SC9 Criado para Este Pedido/Item
cSql := " SELECT Min(R_E_C_N_O_) PRIRECNO "
cSql += " FROM SC9010 "
cSql += " WHERE C9_FILIAL  =  '"+C9_FILIAL  +"' "
cSql += " AND   C9_PEDIDO  =  '"+C9_PEDIDO  +"' "
cSql += " AND   C9_ITEM    =  '"+C9_ITEM    +"' "
cSql += " AND   C9_CLIENTE =  '"+C9_CLIENTE +"' "
cSql += " AND   C9_LOJA    =  '"+C9_LOJA    +"' "
cSql += " AND   C9_PRODUTO =  '"+C9_PRODUTO +"' "
cSql += " AND   C9_QTDLIB  =   "+Alltrim(Str(C9_QTDLIB ))+" "
cSql += " AND   C9_PRCVEN  =   "+Alltrim(Str(C9_PRCVEN ))+" "
cSql += " And   R_E_C_N_O_ <>  "+Alltrim(Str(nSC9NewRec))+" "

U_ExecMySql(cSql, "PRI", "Q")

If PRI->PRIRECNO > 0

	nSC9OldRec := PRI->PRIRECNO
    DbCloseArea("PRI")
	ExtornaReg()
	
Endif

*/
Return()
*********************************************************************
Static Function ExtornaReg() //| Reposiciona no Primeiro Registro Criado no SC9
*********************************************************************
/*
Local lLock := .F.

//| Apaga Novo Registro Criado Pelo Protheus
DbSelectArea("SC9")
lLock := RecLock("SC9",.F.)
DBDElETE()

If lLock
	MsUnlock()
Endif
//| Recupera Registro Antigo 
U_ExecMySql(" UPDATE SC9010 SET D_E_L_E_T_ = ' ', R_E_C_D_E_L_ = 0 WHERE  R_E_C_N_O_ = '"+Alltrim(Str(nSC9OldRec))+"' " ,"" ,"E" )

//|Deleta Registro Novo Criado
U_ExecMySql(" UPDATE SC9010 SET D_E_L_E_T_ = '*', C9_BLINF = 'DELETADO POR MTA440C9' WHERE  R_E_C_N_O_ = '"+Alltrim(Str(nSC9NewRec))+"' " ,"" ,"E" )

//| Se Pociciona no Velho Registro para Manter Historico
SC9->(DbGoto(nSC9OldRec))

 */
Return()
*********************************************************************
Static Function Ver_Cod_Bloq(cCodPadrao) //| Verifica Codigo de Bloquei Customizado Atraves de Variavel Publica BLK_IMD criada em PE_MaAvCrPr
*********************************************************************
Local cBlCred 	:= cCodPadrao
Local nPesq 	:= 0

If Type("aBLK_IMD") == "U"
	Return(cBlCred)
EndIf

nPesq := ascan(aBLK_IMD, SC9->C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM ) 

If nPesq > 0 
	cBlCred := Substr(aBLK_IMD[nPesq],11,2) //| Recupera Codigo de Bloqueio
	ADel (aBLK_IMD , nPesq 				)	  //| Deleta Item do Array
	ASize(aBLK_IMD , Len(aBLK_IMD) - 1 	)	  //| Redimensiona o Array
EndIf		

Return(cBlCred)

Static Function Atu_HistSC9()  
Local cSql :=' '

 //Informações da Liberação de Estoque , considera o último usuario que Liberou o Estoque
 cSql:=" SELECT MAX(C9_DTLCOM) AS DT_LIBCOM,MAX(C9_HRLCOM) AS HR_LIBCOM ,C9_USRLCOM AS USR_LIBCOM"  
 cSql+=" FROM "+RetSqlName("SC9") +" SC9 "
 cSql+=" WHERE C9_FILIAL = '"+xFilial("SC9")+"'"
 cSql+=" AND   C9_PEDIDO ='"+SC9->C9_PEDIDO+"'"
 cSql+=" AND   C9_PRODUTO='"+SC9->C9_PRODUTO+"'"  
 cSql+=" AND   C9_ITEM   ='"+SC9->C9_ITEM+"'"  
  cSql+=" AND   C9_DTLCOM <> ' ' "      
 cSql+=" AND   D_E_L_E_T_='*'"
 cSql+=" GROUP BY C9_USRLCOM "
 
 Iif( Select("QRY_SC9") <> 0, QRY_SC9->( dbCloseArea() ), ) // Verifico se a area não está em uso.
 
 U_ExecMySql(cSql, "QRY_SC9", "Q")
 
 DbSelectArea( "QRY_SC9" )
	
While !QRY_SC9->( Eof() )
//Se a Liberação de Estoque tiver ocorrido mais de uma vez , vale a última
   	SC9->C9_DTLCOM  := STOD(QRY_SC9->DT_LIBCOM)
	SC9->C9_HRLCOM  := QRY_SC9->HR_LIBCOM 
	SC9->C9_USRLCOM := QRY_SC9->USR_LIBCOM 
	
	QRY_SC9->( dbSkip() )
End

QRY_SC9->( dbCloseArea() )

Return 

********************************
Static Function checkPrcVen()   
********************************
Local nE4Acresc  :=SC5->(Posicione("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_ACRSFIN"))  
Local lAjustPrec :=.F.
Local aProds     :={}


  	  //Verifica se é necessário o ajuste no preço de venda em caso de divergência
	  lAjustPrec:= Iif(A410Arred(SC6->C6_PRCACRE/(1+(nE4Acresc/100)),"UB_VRUNIT") <> SC6->C6_PRCVEN,.T.,.F.)     
	  
	  nTolerancia:= A410Arred(SC6->C6_PRCACRE/(1+(nE4Acresc/100)),"UB_VRUNIT")-SC6->C6_PRCVEN
		
		//Tolerância para executar o ajuste do preço quando estiver com divergência
		If (nTolerancia<=0.0005 .OR. nTolerancia<=-0.0005 .OR. nTolerancia<0 ) 
		  lAjustPrec:=.F.		
	    Endif 
	    	
	   	If lAjustPrec 
		 aAdd(aProds,{SC6->C6_ITEM,SC6->C6_PRODUTO,SC6->C6_PRCVEN,A410Arred(SC6->C6_PRCACRE/(1+(nE4Acresc/100)),"UB_VRUNIT")})
		 Reclock("SC6",.F.)
		 SC6->C6_PRCVEN:=A410Arred(SC6->C6_PRCACRE/(1+(nE4Acresc/100)),"UB_VRUNIT") 
		 SC6->( MsUnlock() )
		Endif		


 If Len(aProds)>0  
  U_TmkMailPed(SC5->C5_NUM,SC5->C5_FILIAL,SC5->C5_EMISSAO,aProds)
  aProds:={}
 Endif
 

Return