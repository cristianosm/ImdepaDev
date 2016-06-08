#include "topconn.ch"
#include "ap5mail.ch"
#include "rwmake.ch"

#DEFINE X_DESCNEG		30  // Dias para vencimento dos acrescimos/descontos negociados
#DEFINE ACRESCIMO		3	// Valor do acrescimo financeiro da condicao de pagamento

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTLVENT    บAutor  ณEdivaldo Gon็alves  บ Data ณ  09/13/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de Entrada ap๓s sele็ใo do Histขrico das ligacoes     นฑฑ
ฑฑบ          ณatendidas pelo Televendas                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Call Center                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออัอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAlteracao ณ Mแrcio Q. Borges ณRodar Valid de campo VRUNIT somente      บฑฑ
ฑฑบ 27/10/07 ณ                  ณquando alterar o preco de tabela e PV    บฑฑ
ฑฑบ          ณ                  ณestiver aberto.                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออฯอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

**********************************************************************
User Function TLVENT()
**********************************************************************
Local cDisplay:=''

If M->UA_OPER='1'
	cDisplay='Pedido'
Else
	If M->UA_OPER='2'
		cDisplay='Or็amento'
	Endif
Endif

//Inserido por Edivaldo Gon็alves Cordeiro em 01/09/2009 - Atualiza variแveis de Mem๓ria no cabe็alho no Or็amento
M->UA_VENDINT 	:= SUA->(U_PesqVend(M->UA_CLIENTE,M->UA_LOJA))
M->UA_DESATIV	:= SUA->(U_PesqAtiv(M->UA_CLIENTE,M->UA_LOJA))
//M->UA_OPERADO   := SUA->(TKOPERADOR())
M->UA_DESCOPE   := SUA->(Posicione("SU7",1,xFilial("SU7") + M->UA_OPERADO, "U7_NOME"))
M->UA_CODROTA	:= ""

//Caso Emitiu NF, nao roda atualizacoes do Historico
If  !Empty(SUA->UA_EMISNF)
	Return .T.
EndIf

MsAguarde({||SF4->(LoadOrc()) },'Hist๓rico','Estruturando '+cDisplay+' ...')

Return(.T.)
**********************************************************************
Static Function LoadOrc() // Atualiza Valores puxando Hist๓rico
**********************************************************************
Local nAnt, nPrcTabAtu
Local lDesNegVencido,lOrcVencido := .F.
Local cOperAtivo  :=""
Local aArea       := Getarea()
Local lAtuPrcTab2 := .F.
Local nDesAcreFil :=0
Local uBcf        :=' '
Local nAcreMva    := 0  //Acr้scimo do MVA
Local cEstATU     := GETMV("MV_ESTADO")

// Campos virtuais Customizados pela IMDEPA
M->UA_OBSCLI  := IIF(SUA->UA_PROSPEC,"",SA1->(POSICIONE("SA1",1,XFILIAL("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA,"A1_OBSVEND")))
//M->UA_VENDINT := U_PesqVend(M->UA_CLIENTE,M->UA_LOJA) //Inserido por Edivaldo G. Cordeiro em 20/07/06

aHeader  := {}
aCols    := {}
aHeader  := aClone(aSvFolder[2][1])
aCols    := aClone(aSvFolder[2][2])
n		 := aSvFolder[2][3]

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza dados especificos do aCols  			     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nAcreCond 	:= 1+(Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_ACRSFIN")/100)
nP_VRUNIT   := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VRUNIT"} )
nP_PRTB   	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_PRCTAB"} )
nP_PRTB2  	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_PRCTAB2"} )
nP_VLIT   	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VLRITEM"} ) // VALOR TOTAL
nP_BICM   	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_BASEICM"} )
nP_DESCICM	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DESCICM"} )
nP_DESC2  	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DESC2"} )
nP_VALDESC	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VALDESC"} )
nP_DESC   	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DESC"} )
nP_ACRE   	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_ACRE"} )
nP_ACRE2  	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_ACRE2"} )
nP_VALACRE	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VALACRE"} )
nP_DESCICM	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DESCICM"} )
nP_VDESICM	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VDESICM"} )


nP_OBS 			:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_OBS"} )  //Observacao - Mensagem
nP_VRCACRE 	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VRCACRE"} )  //Prc.c/ Acres
nP_ACREIPI 	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_ACREIPI"} )  //Preco c/ IPI
nP_ALIQIPI 	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_ALIQIPI"} )	// % IPI
nP_VALIPI  	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_VALIPI"} )   // VALOR DO IPI

nP_DATA   	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DTNECLI"} )
nP_HORA   	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_HRNECLI"} )
nP_Prod   	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_PRODUTO"} )
nP_QTDA   	:= Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_QUANT"} )
uBcf        := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_CF"} )

//VERIFICA SE O ORCAMENTO COPIADO ESTA VENCIDO (vencimento dos pre็os acertados).
lOrcVencido 	:= (DDATABASE >  M->UA_DTLIM )   // 3 dias ap๓s a database
lDesNegVencido	:= DDATABASE > (SUA->UA_EMISSAO + X_DESCNEG)  //ENTRE(SUA->UA_EMISSAO,(SUA->UA_EMISSAO + X_DESCNEG), DDATABASE)  // Descontos Negociados vencem em 30 dias

// Array com a amarracao produtoxcampanha para posterior gravacao da tabela ZZI
__aProdCamp := {}
__aItDigPrd := {}

nAnt := n

//|Analista: Cristiano Machado   Data: 18/09/2010   Obs: Correcao Mensagem "SEMDADOS"
If MaFisFound()
	MaFisClear()
Endif

//|Fim Cristiano

For I:= 1 To Len(aCols)
	n := I
	
	//|Analista: Cristiano Machado   Data: 18/09/2010   Obs: Correcao Mensagem "SEMDADOS"
	If MaFisFound()
		
		MaFisAlt("IT_QUANT"		,aCols[n][nP_QTDA]		,n)
		MaFisAlt("IT_PRCUNI"	,aCols[n][nP_VRUNIT]	,n)
		MaFisAlt("IT_VALMERC"	,aCols[n][nP_VLIT] 		,n)
		
		MaColsToFis(aHeader,aCols,n,"TK271",.T.,NIL,NIL,NIL)
		
		//#DEFINE SUFRAMA			7	// Valor total da Suframa
		If aValores[7] > 0
			Tk273Recalc(n)
		Endif
		
	Endif
	//|Fim Cristiano
	
	***********************************************************************************************************
	//Projeto F11 - Usado para armazenar o estado anterior dos produtos para saber quando houver uma altera็ใo//
	***********************************************************************************************************
	
	
	AADD(__aItDigPrd,{I,gdFieldGet("UB_PRODUTO",I),gdFieldGet("UB_LOCAL",I)}) //Carrega o Vetor __aItDigPrd{} com os produtos do Acols
	AADD(__aItDigQtd,I)
	
	
	SB1->(dbSeek(xFilial('SB1')+gdFieldGet("UB_PRODUTO",I)))
	
	aCols[I,nP_OBS]:= SB1->B1_OBSTPES //MENSAGEM PROMO
	
	
	aCols[I,nP_ACREIPI]:= gdFieldGet("UB_VRCACRE",I)*(1+(MaFisRet(I,"IT_ALIQIPI")/100)) //Preco c/ IPI
	aCols[I,nP_ALIQIPI]:= MaFisRet(I,"IT_ALIQIPI")  //  % IPI
	aCols[I,nP_VALIPI] := SB1->B1_IPI   // VALOR DO IPI
	
	
	
	aCols[I,nP_DATA]   := DDATABASE  //Data da Necessidade do Cliente
	aCols[I,nP_HORA]   := StrZero(Val(Substr(TIME(),1,2))+1,2)+Substr(TIME(),4,2)//Hora da Necessidade do Cliente
	
	// Verifica se o produto possui Desconto/Acr้scimo especial
	nDesAcreFil :=SB1->(U_IMDG240E(.F.,gdFieldGet("UB_PRODUTO",I)))
	
	
	nPrcTabAtu := DA1->(MaTabPrVen(M->UA_TABELA,aCols[I,nP_Prod],aCols[I,nP_QTDA],M->UA_CLIENTE,M->UA_LOJA,M->UA_MOEDA))
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualiza preco do item se foi modificado o preco da Tabela de Precoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	//Aplica o Desconto/Acr้scimo Especial
	If nDesAcreFil <>0
		nPrcTabAtu :=A410Arred(nPrcTabAtu +((nPrcTabAtu*nDesAcreFil)/100))
	Endif
	
	/*
	// Verifica se o produto possui Desconto MVA
	If SA1->A1_EST==cEstATU .AND. Alltrim(SF4->F4_CF) $ "5405/5403"
	nAcreMva:=GETMV('MV_ACREMVA',,0)
	nPrcTabAtu :=A410Arred(nPrcTabAtu +((nPrcTabAtu*nAcreMva)/100))
	Endif
	*/
	
	If ((SA1->A1_EST==cEstATU .AND. cEstATU=='SP' .AND.  Alltrim(gdFieldGet("UB_CF",I)) == "5405") .OR.;
		(SA1->A1_EST==cEstATU .AND. cEstATU=='PR' .AND. gdFieldGet("UB_TES",I)=='723' .AND. (Alltrim(SB1->B1_ORIGER) <> "F/NCZADO" .AND. Alltrim(SB1->B1_ORIGER) <> "IMPORTADO"  )) .OR. ;
		(SA1->A1_EST==cEstATU .AND. cEstATU=='RS' .AND. gdFieldGet("UB_TES",I)=='721' .AND. (Alltrim(SB1->B1_ORIGER) <> "F/NCZADO" .AND. Alltrim(SB1->B1_ORIGER) <> "IMPORTADO"  )))
		
		//Verifica se a filial atual possui o Acr้scimo MVA ou outros Descontos/Acrescimos
		If SX5->(DbSeek(xFilial("SX5") + "77" +cFilant,.F.))
			nAcreMva:= Val(StrTran(SX5->X5_DESCRI,",","."))
			
			nPrcTabAtu := A410Arred(nPrcTabAtu*nAcreMva,"UB_VRUNIT")
		Endif
	Endif
	
	
	If nPrcTabAtu != aCols[I,nP_PRTB2]
		lAtuPrcTab2 := .T.
	Else
		lAtuPrcTab2 := .F.
	EndIf
	
	If lAtuPrcTab2
		aCols[I,nP_PRTB2] := nPrcTabAtu
	Endif
	
	If lOrcVencido		// Tratamento para orcamento vencido
		//Aviso('Or็amento Vencido','O Sistema Ajustou variแveis para Or็amento Vencido  !:'+CHR(10)+CHR(13)+CHR(10)+CHR(13)+'Vencido em : '+Dtoc(M->UA_DTLIM),{'Ok'})
		
		If lDesNegVencido
			
			aCols[I,nP_DESC]    := 0
			aCols[I,nP_DESC2]   := 0
			aCols[I,nP_VALDESC] := 0
			aCols[I,nP_ACRE]    := 0
			aCols[I,nP_ACRE2]   := 0
			aCols[I,nP_VALACRE] := 0
			aCols[I,nP_DESCICM] := 0
			aCols[I,nP_VDESICM] := 0
			M->UA_DESCICM 		 := 0	// zera o desconto de icm se o orcamento estiver vencido
			
		EndIf
		
		If lAtuPrcTab2
			aCols[I,nP_PRTB]    := nPrcTabAtu
			aCols[I,nP_VLIT]    := (nPrcTabAtu * aCols[I,nP_QTDA])  // TOTAL  (QTD X VALOR)
			aCols[I,nP_BICM]    := aCols[I,nP_VLIT]
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza descontos e acrescimosณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			
			// Preenche Valor do Pre็o Unitแrio
			__ReadVar := 'M->UB_VRUNIT'
			M->UB_VRUNIT := SF4->(AtuVrUnit())
			GDFieldPut('UB_VRUNIT',M->UB_VRUNIT, N)
			
			// Validacao do Preco unitario sem a apresentacao da tela para digitacao do valor.
			SF4->(U_AtuDesAcr())
			
			
			// MARCIO -> MUDANCA VALIDACAO BUILD 27/10/07
			// Roda Gatilhos do Campo
			SX3->(Posicione("SX3",2,'UB_VRUNIT','X3_CAMPO'))
			CheckSX3('UB_VRUNIT',M->UB_VRUNIT)
			RunTrigger(2,n,PADR('UB_VRUNIT',10))
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza campo UB_VRCCAMP (Preco minimo de campanha de vendas)ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			
			SF4->(U_MsgCamp(aCols[I,nP_Prod],.T.,.F.,.F.,.T.,nAcreCond))
			
		EndIf
		
	EndIf
	
Next

n := nAnt

// Indica que neste atendimento, ao se passar pelo campo UA_TABELA, a validacao nao atualizar os precos dos itens do atendimento
__cTabAtu	:= M->UA_TABELA

Restarea(aArea)
Return
**********************************************************************
Static Function AtuVrUnit()
**********************************************************************
Local nVrUnit   := GdFieldGet("UB_VRUNIT" ,n)
Local nPrcTab2  := GdFieldGet("UB_PRCTAB2",n)
Local nPrcAcre  := GdFieldGet("UB_VRCACRE",n)
Local nPDesc    := GdFieldGet("UB_DESC2"  ,n)
Local nPAcre    := GdFieldGet("UB_ACRE2"  ,n)
Local nPDesICM  := GdFieldGet("UB_DESCICM",n)
Local nAcreCond := 1 + (SE4->( Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_ACRSFIN")) / 100 )  // Acrescimo Financeiro


IF  nPAcre > 0
	// Preco unitario (sem acrescimo financeiro) com acrescimo comercial
	nPrccAcrDescCom := A410Arred(nPrcTab2 * (1 + (nPAcre/ 100)),"UB_VRUNIT")
	
	// Preco unitario (sem acrescimo financeiro) com acrescimo comercial e com desconto de ICMS
	nPrccDesIcm := A410Arred(nPrccAcrDescCom * (1 - (nPDesICM / 100)),"UB_VRUNIT")
	
ELSEIF nPDesc > 0
	// Preco unitario (sem acrescimo financeiro) com desconto comercial
	nPrccAcrDescCom := A410Arred(nPrcTab2 * (1 - (nPDesc / 100)),"UB_VRUNIT")
	
	// Preco unitario (sem acrescimo financeiro) com desconto comercial e com desconto de ICMS
	nPrccDesIcm := A410Arred(nPrccAcrDescCom * (1 - (nPDesICM / 100)),"UB_VRUNIT")
ELSE
	// Se nao existe acresimo nem desonto comercial, serแ igual ao preco de tabela
	// Preco unitario (sem acrescimo financeiro) com desconto comercial
	
	nPrccAcrDescCom := nPrcTab2
	
	// Preco unitario (sem acrescimo financeiro) com desconto comercial e com desconto de ICMS
	nPrccDesIcm := A410Arred(nPrccAcrDescCom * (1 - (nPDesICM / 100)),"UB_VRUNIT")
ENDIF

// Preco unitario com desconto comercial, desconto de ICMS e acrescimo financeiro
nPrcAcres := A410Arred(nPrccDesIcm * nAcreCond , "UB_VRUNIT" )

// Atribui o valor do desconto ou acrescimo a variavel de memoria
M->UB_VRUNIT := A410Arred(nPrcAcres / nAcreCond,"UB_VRUNIT")

// Ajusta arredondamento
nSimPrcAcres := A410Arred( M->UB_VRUNIT * nAcreCond ,"UB_VRUNIT" )
nIncremento := IIF(nSimPrcAcres < nPrcAcres , 0.0001, -0.0001)
lSitInic := (nSimPrcAcres < nPrcAcres)
While ( nSimPrcAcres := A410Arred( M->UB_VRUNIT * nAcreCond ,"UB_VRUNIT") ) != nPrcAcres
	If lSitInic != (nSimPrcAcres < nPrcAcres)
		Exit
	Endif
	M->UB_VRUNIT += nIncremento
End

nVrUnit := M->UB_VRUNIT

Return nVrUnit
