#Include "rwmake.ch"

#Define _ENTER_ CHR(13)+CHR(10)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ IMDF240  º AutOr ³ Marllon Figueiredo º Data ³  06/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Manutencao da tabela de desconto de ICMS                   º±±
±±º          ³ Gatilhos e validacoes usadas na customizacao do desconto   º±±
±±º          ³ de ICMS                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*********************************************************************
User Function IMDF240(cPar)
*********************************************************************

	Local cVldAlt   := ".T."
	Local cVldExc   := ".T."
	Private cString := "SZW"


	DbSelectArea("SZW")
	dbSetOrder(1)

	AxCadastro(cString, "Desconto de ICMS", cVldAlt, cVldExc)

	Return()
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºGATILHO   ³ IMDG240  º AutOr ³ AP6 IDE            º Data ³  06/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gatilho para preechimento do campo UB_DESCICM              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
	*********************************************************************
User Function IMDG240()
	*********************************************************************

	Local aArea    := GetArea()
	Local aAreaSA1 := SA1->( GetArea() )
	Local cImdepa  := GetMv('MV_IMDEPA')
	Local nPrUnit, nDesc
	Local nDescIcm := GDFieldGet('UB_DESCICM', n)
	Local nPrcTab2 := GDFieldGet('UB_PRCTAB2',n)
	Local nP_VLIT  := GDFieldGet('UB_VLRITEM', n)
	Local nDescCom := GDFieldGet('UB_DESC2',n)
	Local nAcreCom := GDFieldGet('UB_ACRE2',n)
	Local nQuant   := GDFieldGet('UB_QUANT', n)
	Local cOrigem, cDestino
	Local nPrccDesCom

// Recupero a UF de Origem
	DbSelectArea('SA1')
	DbSeek(xFilial('SA1')+cImdepa+cFilAnt)
	cOrigem := SA1->A1_EST
	RestArea(aAreaSA1)

// Testo se eh cliente ou prospect
// Recupero a UF de dewstino
	If ! M->UA_PROSPEC
		cDestino := SA1->A1_EST
	Else
		cDestino := SUS->US_EST
	EndIf

// Preco unitario (sem acrescimo financeiro) com desconto comercial
	If nDescCom > 0
		nPrccDesCom := A410Arred(nPrcTab2 * (1 - (nDescCom / 100)),"UB_VRUNIT")
	Elseif nAcreCom > 0
		nPrccDesCom := A410Arred(nPrcTab2 * (1 + (nAcreCom / 100)),"UB_VRUNIT")
	Else
		nPrccDesCom := nPrcTab2
	EndIf


// Preco unitario (sem acrescimo financeiro) com desconto comercial e com desconto de ICMS
	nPrUnit := A410Arred(nPrccDesCom * (1 - (nDescIcm / 100)),"UB_VRUNIT")
// ValOr do desconto de icms
	nDesc := nPrccDesCom - nPrUnit

// Atualiza os campos
	GDFieldPut('UB_VRUNIT'	,nPrUnit,n)
	GDFieldPut('UB_VLRITEM'	,A410Arred(nPrUnit*nQuant,"UB_VLRITEM"), n)
	GDFieldPut('UB_PRCTAB'	,nPrUnit,n)


	If(Type("lTk271Auto")="U" .Or. !lTk271Auto)
//Tk271Trigger("UB_VLRITEM", n)  // VERSAO 6.09
		Tk273Trigger("UB_VLRITEM", n)    // VERSAO 8.11
	EndIf

	U_LinAtPrAcr()    // atualiza UB_VRCACRE preco com acrescimo financeiro

	RestArea(aAreaSA1)
	RestArea(aArea)

	Return(nDesc)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMDG240A  ºAutOr  ³Marcio Q. BOrges    º Data ³  10/26/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua a replicação do valOr unitário (UB_VRUNIT) para o   º±±
±±º          ³ preco de tabela (UB_PRCTAB)                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
	*********************************************************************
USER FUNCTION IMDG240A()
	*********************************************************************
	Local nPrUnit := 0

	IF 'UB_VRUNIT' $ ReadVar()
		nPrUnit := M->UB_VRUNIT
	ELSE
		nPrUnit := GDFieldGet('UB_VRUNIT', n)
	EndIf

	GDFieldPut('UB_PRCTAB',nPrUnit,n)

	Return .T.
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºVALID     ³IMDV240AC º AutOr ³ AP6 IDE            º Data ³  27/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza os valOres no aCols (SUB) de acOrdo com o percen- º±±
±±º          ³ tual de desconto de ICMS infOrmado no cabecalho (SUA)      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
	*********************************************************************
User Function IMDV240AC(cPar)
	*********************************************************************

/*
Local nOld  	:= N
Local cSegmento := ""
Local cArea     :=GetArea()
Local cOrigem
Local cImdepa  := GetMv('MV_IMDEPA')
Local cCliAtu  := SA1->A1_COD
Local cLojAtu  := SA1->A1_LOJA
Local cVar     := ReadVar()

If ! lProspect
cDestino  := SA1->A1_EST
cTpCliFOr := SA1->A1_TIPO
cSegmento := substr(SA1->A1_GRPSEG,3,1)
Else
cDestino  := SUS->US_EST
cTpCliFOr := SUS->US_TIPO
cSegmento := substr(SUS->US_GRPSEG,3,1)
EndIf


DbSelectArea('SA1')
DbSeek(xFilial('SA1')+cImdepa+cFilAnt)
cOrigem := SA1->A1_EST

DbSelectArea('SA1')
DbSeek(xFilial('SA1')+cCliAtu+cLojAtu)

For N := 1 To Len(aCols)

cProduto := gdFieldGet( "UB_PRODUTO", N ) //SB1->B1_COD
cImpNac  := SA1->(POSICIONE('SB1',1,XFILIAL('SB1')+CPRODUTO,'B1_ORIGEM'))

If U_cHeckGrpTRib(cProduto) // Checa se o grupo de Tributacao do Produto nao eh cOrrente

////// JULIO JACOVENKO, 27/12/2012
////// busco no SZW pOr se fOr impOrtado

nDesc := M->UA_DESCICM

lImp  := ( cImpNac='1' .Or. cImpNac='2' )

DbSelectArea('SZW')
If DbSeek(xFilial('SZW') + cOrigem + cDestino)

If ReadVar() = "M->UA_DESCICM"
IF lImp .And. cPar<>'2'
nDesc := 0 //M->UA_DESCICM  //SZW->ZW_DESCIMP //gdFieldGet( "UA_DESCICM", N )
Elseif !lImp .And. cPar<>'2'
nDesc := &cVar
EndIf

ELSE
IF lImp .And. cPar='2'
nDesc := &cVar
Elseif !lImp .And. cPar = '2'
nDesc := M->UA_DESCICM
EndIf
EndIf

EndIf

//GDFieldPut("UB_DESCICM", M->UA_DESCICM, N)
If gdFieldGet( "UB_DESCICM", N ) <> 0 .And.  NDESC == 0 .And. M->UA_DESICMI <> 0
NDESC := gdFieldGet( "UB_DESCICM", N )
EndIf


//Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_GRTRIB")=='001'
//ALERT('..ENTROU ERRADO...'+gdFieldGet( "UB_PRODUTO", N ))
GDFieldPut("UB_DESCICM", NDESC      , N)
GDFieldPut("UB_VDESICM", U_IMDG240(), N)      // declarada em IMDF240.PRW

Else

//ALERT('...ALERTA...'+gdFieldGet( "UB_PRODUTO", N ))

GDFieldPut("UB_DESCICM", 0      	, N)
GDFieldPut("UB_VDESICM", U_IMDG240(), N)      // declarada em IMDF240.PRW

EndIf

Next


N := nOld
oGetTLV:Refresh()

RestArea(cAREA)
*/
	Return(.T.)

/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: cHeckGrpTRib || AutOr: Edivaldo Gonçalves    || Data: 04/11/11  ||
||-------------------------------------------------------------------------||
|| Descrição: Nao permite dar desconto de ICMS para Grupo de tributacao    ||
|| de cOrrentes (B1_GRTRIB)                                                ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function cHeckGrpTRib(cProduto)

	Local lReturn := .F.

	DbSelectArea("SB1")
	DbSeek(xFilial("SB1")+cProduto, .F.)
	If Alltrim(SB1->B1_GRTRIB) =='001'
		lReturn:=.F.
	Else
		lReturn := .T.
	EndIf

	Return (lReturn)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºVALID     ³ IMDV240  º AutOr ³ AP6 IDE            º Data ³  06/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao da digitacao do campo UB_DESCICM e UA_DESCICM    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
	*********************************************************************
User Function IMDV240(cPar)
	*********************************************************************

	Local aArea    := GetArea()
	Local nDesc    := 0
	Local lRet     := .T.
	Local cImdepa  := GetMv('MV_IMDEPA')
	Local cOrigem
	Local cDestino
	Local cVar     := ReadVar()
	Local cSegmento:= ""
	Local cCliAtu  := SA1->A1_COD
	Local cLojAtu  := SA1->A1_LOJA
	Local nDesc    := 0
	Local aMen	   := {}
	Local nMaxDesI := 0 //| Maior Desconto Importado
	Local nMaxDesN := 0 //| Maior Desconto Nacional

//	If ( &cVar ) == 0 //| Zero Nao necessita Validar
//		Return lRet
//	EndIf

// Recupero a UF de Origem
	DbSelectArea('SA1')
	DbSeek(xFilial('SA1') + cImdepa + cFilAnt)
	cOrigem := SA1->A1_EST

	DbSelectArea('SA1')
	DbSeek(xFilial('SA1') + cCliAtu + cLojAtu)


// testo se eh cliente ou prospect recupero a UF de destino
	If !lProspect
		cDestino  := SA1->A1_EST
		cTpCliFOr := SA1->A1_TIPO
		cSegmento := substr(SA1->A1_GRPSEG,3,1)
	Else
		cDestino :=  SUS->US_EST
		cTpCliFOr := SUS->US_TIPO
		cSegmento := substr(SUS->US_GRPSEG,3,1)
	EndIf

	nOld := N // Salva Posicao



	For N := 1 To Len(aCols)

		DbSelectArea('SZW')
//| Verifica O Desconto que Pode Ser Concedido
		If DbSeek(xFilial('SZW') + cOrigem + cDestino)

			cProduto 	:= gdFieldGet( "UB_PRODUTO", N )

			cImpNac 	:= SZW->(Posicione('SB1',1,XFILIAL('SB1')+cProduto,'B1_ORIGEM'))

			lImp 		:= ( cImpNac == '1' .Or. cImpNac == '2' )

			If cVar == "M->UA_DESICMI"   //| Desconto Importado Cabecalho

				If lImp //| Importado
					nDesc := SZW->ZW_DESCIMP
				Else  //| Nacional
					nDesc := 0 //&cVar
				EndIf

			Elseif cVar == "M->UA_DESCICM"	//| Desconto ICM Cabecalho

				IF !lImp // Nacional
					nDesc := SZW->ZW_DESCONT
				Else //lImp ///.And. cPar <> '2'
					nDesc := 0
				EndIf

			Elseif  cVar == "M->UB_DESCICM"	//| Desconto ICM Item

				IF lImp
					nDesc := SZW->ZW_DESCIMP
				Else
					nDesc := SZW->ZW_DESCONT
				EndIf

			EndIf

		EndIf

		//| Salva o Maior Desconto ....Imnportado e Nacional Disponivel
		If lImp
			If nDesc >= nMaxDesI
				nMaxDesI := nDesc
			EndIf
		Else
			If nDesc >= nMaxDesN
				nMaxDesN := nDesc
			EndIf
		EndIf




		If !U_cHeckGrpTRib(cProduto) //| Valida o Grupo de Tributacao - Graxa

			Aadd( aMen , { 1 , N } ) 	// Adiciona Mensagem

			If ( cVar == "M->UB_DESCICM" ) //| Valida como Falso apenas nas Linhas
				lRet := .F.
			EndIf

			///JULIO E CRISTIANO, 28/12/2012
			GDFieldPut("UB_DESCICM", 0          , N)
			GDFieldPut("UB_VDESICM", U_IMDG240(), N)

		ElseIf ( &cVar > nDesc )//| Valida Valor do Desconto ....

			Aadd( aMen , { 2 , N } ) 		// Adiciona Mensagem

			If ( cVar == "M->UB_DESCICM"  ) //| Valida como Falso apenas nas Linhas
				lRet := .F.
			EndIf

			If gdFieldGet( "UB_DESCICM", N ) == 0 .Or. gdFieldGet( "UB_DESCICM", N ) < nDesc  .And. nDesc <> 0//| So aplica Maximo se o UB for Zero .... Senao Mantem....

				GDFieldPut("UB_DESCICM", nDesc       , N) // Aplica Desconto Maximo
				GDFieldPut("UB_VDESICM", U_IMDG240() , N)

			EndIf

		ElseIf &cVar == 0 //| Zerando o Desconto deve zerar so os Correspondentes

			If cVar == "M->UA_DESCICM" .And. !lImp //| Nacional
				GDFieldPut("UB_DESCICM", 0          , N)
				GDFieldPut("UB_VDESICM", U_IMDG240(), N)

			Elseif cVar == "M->UA_DESICMI" .And. lImp //| Importado
				GDFieldPut("UB_DESCICM", 0          , N)
				GDFieldPut("UB_VDESICM", U_IMDG240(), N)

			EndIf

		Else  //| Tudo Certo Aplica Desconto

			GDFieldPut("UB_DESCICM", &cVar      , N)
			GDFieldPut("UB_VDESICM", U_IMDG240(), N)

		EndIf

	Next

// Ordena Array
	Aadd( aMen , { 9 , 0 } ) //| Linha Auxiliar ....
	aMen := ASort( aMen,,,{ |x,y| x[1] < y[1] } )

//| Prepara Disparo de Mensagens....
	cMenTitu  := "Atenção"
	cMenHelp  := ""
	cMensagem := ""

	If Len(aMen) > 1

		nAux := aMen[1][1]
		For I := 1 To Len(aMen) // Apresenta Mensagens de Erro....

			//If aMen[I][1] == nAux
				//cMensagem += Alltrim(gdFieldGet( "UB_PRODUTO", aMen[I][2] )) + ", "

			//ElseIf aMen[I][1] <> nAux // Neste Caso Dispara Mensagem na Tela
			If aMen[I][1] <> nAux // Neste Caso Dispara Mensagem na Tela

				If nAux == 1
					cMenHelp := "O Grupo de Tributaçao do(s) Produto(s) abaixo não Permite DESCONTO ICMS."
				ElseIf nAux == 2
					cMenHelp := "Algun(s) Produto(s) abaixo não podem receber este DESCONTO ICMS."
				EndIf

				//Iw_MsgBox( cMenHelp + _ENTER_ + cMensagem , cMenTitu , "INFO" )
				//Iw_MsgBox( cMenHelp  , cMenTitu , "INFO" )

				nAux := aMen[I][1]
				If nAux <> 9 // Nao deve entrar no caso de ser o Auxiliar....
					//cMensagem := Alltrim(gdFieldGet( "UB_PRODUTO", aMen[I][2] )) + ", "
				EndIf
			EndIf

		Next

	EndIf


	//| Salva o Maior Desconto se Valor Digitado pelo usuario for Maior
	If cVar == "M->UA_DESICMI"   //| Desconto Importado Cabecalho
		If nMaxDesI < &cVar
			&cVar := nMaxDesI
			cMenHelp := "O Desconto foi reajustado ao LIMITE MAXIMO Disponivel !!! R$ " + cValToChar(nMaxDesI)
			//Iw_MsgBox( cMenHelp , cMenTitu , "INFO" )
		EndIF
	Elseif cVar == "M->UA_DESCICM"	//| Desconto ICM Cabecalho
		If nMaxDesN < &cVar
			&cVar := nMaxDesN
			cMenHelp := "O Desconto foi reajustado ao LIMITE MAXIMO Disponivel !!! R$ " + cValToChar(nMaxDesN)
			//Iw_MsgBox( cMenHelp , cMenTitu , "INFO" )
		EndIF
	EndIf


	//| Restaura Area e posicao
	N := nOld

	////REFRESH

    oGetTLV:Refresh()
	RestArea(aArea)

	Return(lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºVALID     ³ IMDV240  º AutOr ³ AP6 IDE            º Data ³  06/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao gatilho de inclusão de novo item...  Se o item   º±±
±±º          ³ nao fOr Subs Trib pode receber UA_DESCICM senao eh Zero    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
	*********************************************************************
User Function GDESCICM()
	*********************************************************************

	Local	cSegmento := " "

	nRecno := Recno("SX7")

	If !lProspect
		cDestino  	:= SA1->A1_EST
		cTpCliFOr 	:= SA1->A1_TIPO
		cSegmento 	:= substr(SA1->A1_GRPSEG,3,1)
	Else
		cDestino 	:= SUS->US_EST
		cTpCliFOr 	:= SUS->US_TIPO
		cSegmento 	:= substr(SUS->US_GRPSEG,3,1)
	EndIf

	IF U_Fsubtrib(xFilial("SUA"),"S","N",cTpCliFOr,cDestino,SB1->B1_POSIPI,cSegmento,3)
		nReturn := 0
	Elseif Alltrim(SB1->B1_GRTRIB) = '001'
		nReturn := 0
	else
		nReturn	:= U_IMDG240()
	EndIf

	DbSelectArea("SX7")
	Dbgoto(nRecno)

	Return(nReturn)

/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: IMDG240D     || AutOr: Edivaldo Gonçalves    || Data: 19/06/12  ||
||-------------------------------------------------------------------------||
|| Descrição: Gatilho para dar Acréscimo ao Preço de Tabela de acOrdo com  ||
|| a Tabela 77 (arquivo do SX5)                                            ||
||-------------------------------------------------------------------------||
|| Sintaxe IMDG240D(.T.,TES)                                               ||
||-------------------------------------------------------------------------||
|| Parâmetros:(modo gatilho[verdadeiro ou falso],TES)                      ||
||-------------------------------------------------------------------------||
|| RetOrno:Preço de tabela c/acréscimo MVA [Modo Gatilho]                  ||
||                           Acréscimo MVA [modo função ]                  ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function IMDG240D(lModGat,cTes)
	Local aArea    := GetArea()
	Local nPrecTab := 0
	Local nNewPrec := 0
	Local nNewAcres:= 0
	Local cEstATU  := GETMV("MV_ESTADO")

// Se a execução não fOr no modo gatilho posiciona o arquivo de TES SF4 , caso contrário a TES já vem posicionada
	If !lModGat
		If (SF4->(DbSeek(xFilial("SF4")+cTes,.F.)))
		Else
			IW_MSGBOX('A tes '+cTes+' não foi Localizada no sistema ' ,'Tes Inválida',"ALERT")
		EndIf
	EndIf

//Verifica se é uma operação dentro do Estado e o Codigo Fiscal da Operacao seja 5405
	If SA1->A1_EST==cEstATU .And. Alltrim(SF4->F4_CF) $ "5405"

		M->UB_PRODUTO := gdFieldGet("UB_PRODUTO",n)
		M->UB_QUANT   := gdFieldGet("UB_QUANT",n)
		nPrecTab      := MaTabPrVen(M->UA_TABELA,M->UB_PRODUTO,M->UB_QUANT,M->UA_CLIENTE,M->UA_LOJA,M->UA_MOEDA)

//Verifica se a filial atual tem o Acréscimo no Preço de Tabela devido ao novo MVA na Respectiva Filial
		If SX5->(DbSeek(xFilial("SX5") + "77" +cFilant,.F.))
			nNewAcres:=Val(SX5->X5_DESCRI)
			If lModGat
				nNewPrec :=nPrecTab*nNewAcres
				GDFieldPut('UB_PRCTAB2'	,nNewPrec,n)
				Return(nNewPrec)
			Else
//Se a execução não fOr em modo gatilho retOrno o percentual para acréscimo no Preço de Tabela
				Return(nNewAcres)
			EndIf
		Else
//Operação dentro do estado e filial não possui o desconto MVA
			Do Case
			Case lModGat
				Return(nPrecTab) //RetOrna pro Gatilho preço de Tabela sem Desconto
			Otherwise
				Return(nNewAcres)   //RetOrna para a função o acréscimo MVA=0
			EndCase
		EndIf
	Else
//Operação fOra do Estado não possui o acréscimo MVA
		Do Case
		Case lModGat //Se a execução fOr modo gatilho e a CFOP fOr diferente de "5405" , retOrna o preço de Tabela
			Return(nPrecTab)
		Otherwise   //Se a execução não fOr modo gatilho e a CFOP fOr diferente de "5405" , RetOrna para a função o acréscimo MVA=0
			Return(nNewAcres)
		EndCase
	EndIf

	RestArea(aArea)
	Return






/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºVALID     ³ IMDV240B º AutOr ³ AP6 IDE            º Data ³  06/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao da digitacao do campo UB_DESCICM e UA_DESCICM    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
	*********************************************************************
User Function IMDV240B(cPar)
	*********************************************************************

	Local aArea    := GetArea()
//Local aAreaSA1 := SA1->( GetArea() )
	Local nDesc    := 0
	Local lRet     := .T.
	Local cImdepa  := GetMv('MV_IMDEPA')
	Local cOrigem
	Local cDestino
	Local cVar     := ReadVar()
	Local cSegmento:= ""
	Local cCliAtu  := SA1->A1_COD
	Local cLojAtu  := SA1->A1_LOJA
	Local nDesc    := 0
	Local cVar1    := ReadVar()


//If ReadVar() = "M->UB_DESICMI"
//cVar1:= ReadVar()
//EndIf

//ALERT(CCLIATU)
//ALERT(CLOJATU)


// recupero a UF de Origem
	DbSelectArea('SA1')
	DbSeek(xFilial('SA1')+cImdepa+cFilAnt)
	cOrigem := SA1->A1_EST
//RestArea(aAreaSA1)
	RestArea(aArea)

	DbSelectArea('SA1')
	DbSeek(xFilial('SA1')+cCliAtu+cLojAtu)



// testo se eh cliente ou prospect
// recupero a UF de destino
	If ! lProspect
		cDestino  := SA1->A1_EST
		cTpCliFOr := SA1->A1_TIPO
		cSegmento := substr(SA1->A1_GRPSEG,3,1)
	Else
		cDestino :=  SUS->US_EST
		cTpCliFOr := SUS->US_TIPO
		cSegmento := substr(SUS->US_GRPSEG,3,1)
	EndIf

	nold := N


//ALERT(COrIGEM)
//ALERT(CDESTINO)

//FOr N := 1 To Len(aCols)


	DbSelectArea('SZW')
	If DbSeek(xFilial('SZW') + cOrigem + cDestino)
//ALERT('DENTRO DA FUNCAO IMDV240 ...')
//ALERT(SB1->B1_COD)
		CPRODUTO:=gdFieldGet( "UB_PRODUTO", N )
//cDESC:=SZW->(POSICIONE('SB1',1,XFILIAL('SB1')+CPRODUTO,'B1_DESC'))
//ALERT(CDESC)
//ALERT('SAI DA FUNCAO  IMDV240')
		cImpNac:=SZW->(POSICIONE('SB1',1,XFILIAL('SB1')+CPRODUTO,'B1_OrIGEM'))

//ALERT(cImpNac)

		lImp := (cImpNac='1' .Or. cImpNac='2')

//ALERT(lImp)

//.Or. ReadVar() = "M->UB_DESCICM"
		If ReadVar() = "M->UA_DESICMI"
			IF lImp .And. cPar='2'
				nDesc := SZW->ZW_DESCIMP
			Elseif !lImp .And. cPar='2'
				nDesc := &cVar
			EndIf

		Elseif ReadVar() = "M->UA_DESCICM"
			IF !lImp .And. cPar<>'2'
				nDesc := SZW->ZW_DESCONT
			Elseif lImp .And. cPar <>'2'
				nDesc := &cVar
			EndIf

		Elseif  ReadVar() = "M->UB_DESCICM"
			IF lImp
				nDesc := SZW->ZW_DESCIMP
			Elseif !lImp
				nDesc := SZW->ZW_DESCONT
			EndIf


		EndIf




/*
IF lImp .And. cPar<>'2'
//ALERT('POSICISAO HUM')
nDesc := 0 //SZW->ZW_DESCIMP
Elseif lImp .And. cPar='2'
//ALERT('POSICISAO DOIS')
nDesc1 := SZW->ZW_DESCIMP
//nDesc := SZW->ZW_DESCONT
Elseif !lImp .And. cPar<>'2'
//ALERT('POSICISAO TRES')
nDESC := SZW->ZW_DESCONT
Elseif !lImp .And. cPar='2'
//ALERT('POSICISAO QUATRO')
nDESC :=SZW->ZW_DESCONT  //&cVar  //SZW->ZW_DESCONT
EndIf
*/

	EndIf

	cMenTitu  := "Atenção"

	If !U_cHeckGrpTRib(gdFieldGet( "UB_PRODUTO", N ))

		lRet := .F.
		cMenHelp := "O Grupo de Tributaçao deste Produto não Permite DESCONTO ICMS."

		Iw_MsgBox( cMenHelp , cMenTitu , "INFO" )


//		Help(' ', 1, 'Atenção',,'Este grupo de Tributacao não permite o Desconto de ICMS , pressione a tecla <ESC> para cancelar',1,1)
		Return(lRet)
	EndIf

	If &cVar > nDesc
		lRet := .F.

		cMenHelp := "Este produto não podem receber este DESCONTO ICMS."
		//Iw_MsgBox( cMenHelp , cMenTitu , "INFO" )
        //Help(' ', 1, 'Atenção',,'Este produto não podem receber este DESCONTO ICMS.',1,1)

		//Help(' ', 1, 'Atenção',,'Este desconto não pode ser Concedido!',1,1)
	EndIf



//N := nOld



	RestArea(aArea)

	Return(lRet)

/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: IMDG240E     || AutOr: Edivaldo Gonçalves    || Data: 22/04/13  ||
||-------------------------------------------------------------------------||
|| Descrição: Gatilho para dar Desconto/Acréscimo ao Preço de Tabela       ||
|| de acordo com a filial na tabela ZA7                                    ||
||-------------------------------------------------------------------------||
|| Sintaxe IMDG240E(lModGat,cProduto)                                      ||
||-------------------------------------------------------------------------||
|| Parâmetros:                                                             ||
||-------------------------------------------------------------------------||
|| Retorno: via Gatilho -> Preco de Tabela com Desconto/Acrescimo          ||
||          via funcao  -> % de Desconto ou % de Acrescimo                 ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function IMDG240E(lModGat,cCodPro)
Local aArea     := GetArea()
Local nPrecTab  := 0
Local nNewPrec  := 0
Local nNewAcres := 0
Local cEstFilCli:=  Iif(!Empty(SA1->A1_ESTQFIL), SA1->A1_ESTQFIL,xFilial( 'SB1' ))


DbSelectArea("SB1")
SB1->( dbSetOrder( 1 ) ) //SB1_FILIAL+SB1->B1_COD

DbSelectArea("ZA7")
ZA7->( dbSetOrder( 1 ) ) //ZA7_FILIAL+ZA7_CODPRO

If lModGat  //Modo gatilho, atualiza o preco com Acrescimo/Desconto na Tela de Vendas
  M->UB_PRODUTO := gdFieldGet("UB_PRODUTO",n)
  M->UB_QUANT   := gdFieldGet("UB_QUANT",n)
  nPrecTab      := MaTabPrVen(M->UA_TABELA,M->UB_PRODUTO,M->UB_QUANT,M->UA_CLIENTE,M->UA_LOJA,M->UA_MOEDA)
  cCodPro       := M->UB_PRODUTO
Endif

If SB1->( dbSeek( xFilial( 'SB1' ) + cCodPro, .f. ) )
  If SB1->B1_CLASSVE='3' //Produto com Desconto por Filial
        //Pega o Acrescimo/Desconto baseado no estoque padrao do cliente
      If ZA7->( dbSeek( cEstFilCli + cCodPro, .f. ) )
	        nNewAcres:=ZA7->ZA7_PROMES
	        Iif(nNewAcres<>0, nNewAcres, 1)
      EndIf
  Endif
Endif


  If lModGat  //Modo Gatilho
	nNewPrec :=A410Arred(nPrecTab    +((nPrecTab*nNewAcres)/100))
	//nNewPrec :=nPrecTab    +((nPrecTab*nNewAcres)/100)
	GDFieldPut('UB_PRCTAB'	,nNewPrec,n)
	GDFieldPut('UB_PRCTAB2'	,nNewPrec,n)
	  Return(nNewPrec)
  Else
    //Se a execução não fOr em modo gatilho retOrno o percentual para Desconto/Acréscimo no Preço de Tabela (via IMDF190)
	Return(nNewAcres)
  EndIf


	RestArea(aArea)
Return

