#INCLUDE "RWMAKE.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FATANUAL   ³ Autor ³ Agostinho Lima       ³ Data ³10.11.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Faturamento anual em modo grafico              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FATANUAL()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LOCAL oDlg 		:= NIL
	LOCAL cString		:= "CT2"
	PRIVATE titulo 	:= ""
	PRIVATE nLastKey	:= 0
	PRIVATE cPerg	:= "FATANU"
	PRIVATE nomeProg	:= FunName()

	AjustaSx1()
	If ! Pergunte(cPerg,.T.)
	Return
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros					  		³
//³ mv_par01				// Numero da PT                   		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel := FunName()            //Nome Default do relatorio em Disco

	PRIVATE cTitulo := "Impressão do Faturamento Anual"
	PRIVATE oPrn    := NIL
	PRIVATE oFont1  := NIL
	PRIVATE oFont2  := NIL
	PRIVATE oFont3  := NIL
	PRIVATE oFont4  := NIL
	PRIVATE oFont5  := NIL
	PRIVATE oFont6  := NIL
	Private nLastKey := 0
	Private  oBrush  := TBrush():New(,CLR_LIGHTGRAY)

	DEFINE FONT oFont1 NAME "Times New Roman" SIZE 0,20 BOLD  OF oPrn
	DEFINE FONT oFont2 NAME "Times New Roman" SIZE 0,14 BOLD OF oPrn
	DEFINE FONT oFont3 NAME "Times New Roman" SIZE 0,14 OF oPrn
	DEFINE FONT oFont4 NAME "Times New Roman" SIZE 0,14 ITALIC OF oPrn
	DEFINE FONT oFont5 NAME "Times New Roman" SIZE 0,14 OF oPrn
	DEFINE FONT oFont6 NAME "Courier New" BOLD

	oFont08	 := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
	oFont08N := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
	oFont10	 := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
	oFont11  := TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)
	oFont14	 := TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
	oFont16	 := TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)
	oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
	oFont12  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
	oFont12N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
	oFont16N := TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
	oFont14N := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
	oFont06	 := TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
	oFont06N := TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela de Entrada de Dados - Parametros                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLastKey  := IIf(LastKey() == 27,27,nLastKey)

	If nLastKey == 27
	Return
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do lay-out / impressao                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oPrn := TMSPrinter():New(cTitulo)
//IF ! oPrn:Setup()
//   RETURN
//ENDIF
	oPrn:SetLandscape()
//oPrn:SetPortrait()

	oPrn:SetpaperSize(9) // <==== AJUSTE PARA PAPEL a4
	oPrn:StartPage()
	Imprimir()
	oPrn:EndPage()
	oPrn:End()

	DEFINE MSDIALOG oDlg FROM 264,182 TO 441,613 TITLE cTitulo OF oDlg PIXEL
	@ 004,010 TO 082,157 LABEL "" OF oDlg PIXEL

	@ 015,017 SAY "Esta rotina tem por objetivo imprimir"	OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
	@ 030,017 SAY "o impresso customizado:"					OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
	@ 045,017 SAY "Faturamento Anual " 						OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE

	@ 06,167 BUTTON "&Imprime" 		SIZE 036,012 ACTION oPrn:Print()   	OF oDlg PIXEL
	@ 28,167 BUTTON "Pre&view" 		SIZE 036,012 ACTION oPrn:Preview() 	OF oDlg PIXEL
	@ 49,167 BUTTON "Sai&r"    		SIZE 036,012 ACTION oDlg:End()     	OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

	oPrn:End()


Return

	/*/
	_____________________________________________________________________________
	¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
	¦¦+-----------------------------------------------------------------------+¦¦
	¦¦¦Funçào    ¦ IMPRIMIR  ¦ Autor ¦ Agostinho Lima  ¦ Data ¦10.11.2008     ¦¦¦
	¦¦+----------+------------------------------------------------------------¦¦¦
	¦¦¦Descriçào ¦ Impressao Pedido de Vendas   					          ¦¦¦
	¦¦+----------+------------------------------------------------------------¦¦¦
	¦¦¦Uso       ¦                                                            ¦¦¦
	¦¦+-----------------------------------------------------------------------+¦¦
	¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
	¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	/*/
STATIC FUNCTION Imprimir()
	PROCESSA( {|| Fatura() }, "AGUARDE...", "Processando...")
	Ms_Flush()
Return

	/*/
	_____________________________________________________________________________
	¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
	¦¦+-----------------------------------------------------------------------+¦¦
	¦¦¦Funçào    ¦ FATURA ¦ Autor ¦ Agostinho  Lima         ¦ Data ¦10.11.2008¦¦¦
	¦¦+----------+------------------------------------------------------------¦¦¦
	¦¦¦Descriçào ¦ Impressao 										          ¦¦¦
	¦¦+----------+------------------------------------------------------------¦¦¦
	¦¦¦Uso       ¦                                                            ¦¦¦
	¦¦+-----------------------------------------------------------------------+¦¦
	¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
	¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	/*/
STATIC FUNCTION FATURA()

	LOCAL nLin     := 0
	LOCAL nCol     := 0
	LOCAL aItem    := {}
	LOCAL aAno     := Array(12)
	LOCAL nANO     := VAL(LEFT(MV_PAR01,4))
	LOCAL nMESPAR  := VAL(RIGHT(MV_PAR01,2))
	LOCAL nMES     := 1
	LOCAL nItem    := 1

	LOCAL aVrM01   := Array(11)
	LOCAL aVrM02   := Array(11)
	LOCAL aVrM03   := Array(11)
	LOCAL aVrM04   := Array(11)
	LOCAL aVrM05   := Array(11)
	LOCAL aVrM06   := Array(11)
	LOCAL aVrM07   := Array(11)
	LOCAL aVrM08   := Array(11)
	LOCAL aVrM09   := Array(11)
	LOCAL aVrM10   := Array(11)
	LOCAL aVrM11   := Array(11)
	LOCAL aVrM12   := Array(11)

	LOCAL nTotMes  := 0
	LOCAL nAculMes := 0
	LOCAL nTotFil  := 0

	LOCAL aFilFat  := {}
	LOCAL aFilFat1 := ALLTRIM(GETMV("MV_FATANUL"))
	LOCAL aFilFat  := &aFilFat1


	FOR nfil := 1 TO LEN(aFilFat)

		AADD( aItem , {"1"+aFilFat[nfil][1],aFilFat[nfil][2]} )

	NEXT



/*
AADD( aItem , {"102","CUIABA"})
AADD( aItem , {"104","GOIANIA"})
AADD( aItem , {"105","PORTO ALEGRE (CD)"})
AADD( aItem , {"107","VITORIA"})
AADD( aItem , {"109","SAO PAULO"})
AADD( aItem , {"113","CURITIBA"})
AADD( aItem , {"110","BETIM"})
AADD( aItem , {"107","VITORIA"})
AADD( aItem , {"112","PORTO ALEGRE"})
//AADD( aItem , {"111","SAO LUIS"})

*/



	PROCREGUA(12*len(aItem))

	FOR nMES := 1 TO 12

		IF nMESPAR > 12 .AND. nMES <> 12
			nANO    := nANO + 1
			nMESPAR := 1
		ENDIF

		cMes:= STRZERO(nANO,4) + STRZERO(nMESPAR,2)
		nMESPAR := nMESPAR + 1
		aAno[nMES]  := RIGHT(cMes,2)+"/"+LEFT(cMes,4)

		FOR nItem := 1 to len(aItem)

			INCPROC(aItem[nItem,1]+" - "+aItem[nItem,2]+" - "+RIGHT(cMes,2)+"/"+LEFT(cMes,4))


			cQuery := ""
			cQuery += "SELECT ABS(SUM(VRDC)) VALOR FROM "
			cQuery += "( "
			cQuery += " SELECT SUM(CT2_VALOR) VRDC  FROM CT2010 WHERE D_E_L_E_T_ = ' ' "
			cQuery += " AND CT2_FILIAL = '  ' "
			cQuery += " AND SUBSTR(CT2_DATA,1,6) = '"+cMes+"' "

			IF MV_PAR02 < 3
				cQuery += "	AND CT2_DEBITO BETWEEN '31101010' AND '31101040' "
			ELSE
				cQuery += "	AND CT2_DEBITO BETWEEN '31102040' AND '31102041' "
			ENDIF
			cQuery += " AND CT2_MOEDLC = '01' "
			cQuery += "	AND CT2_ITEMD = '"+aItem[nItem,1]+"' "
			cQuery += " AND CT2_HP <> '999' "

			cQuery += " UNION ALL "

			cQuery += "	SELECT SUM(CT2_VALOR) * -1 VRDC FROM CT2010 WHERE D_E_L_E_T_ = ' ' "
			cQuery += " AND CT2_FILIAL = '  ' "
			cQuery += " AND SUBSTR(CT2_DATA,1,6) = '"+cMes+"' "

			IF MV_PAR02 < 3
				cQuery += "	AND CT2_CREDIT BETWEEN '31101010' AND '31101040' "
			ELSE
				cQuery += "	AND CT2_CREDIT BETWEEN '31102040' AND '31102041' "
			ENDIF
			cQuery += " AND CT2_MOEDLC = '01' "
			cQuery += "	AND CT2_ITEMC = '"+aItem[nItem,1]+"' "
			cQuery += " AND CT2_HP <> '999' "

			IF MV_PAR02 <> 2

				cQuery += "	) "

			ELSE

				cQuery += " UNION ALL "

				cQuery += "SELECT ABS(SUM(VRDC)) VRDC FROM "
				cQuery += "( "
				cQuery += " SELECT SUM(CT2_VALOR) VRDC  FROM CT2010 WHERE D_E_L_E_T_ = ' ' "
				cQuery += " AND CT2_FILIAL = '  ' "
				cQuery += " AND SUBSTR(CT2_DATA,1,6) = '"+cMes+"' "
				cQuery += "	AND CT2_DEBITO BETWEEN '31102040' AND '31102041' "
				cQuery += " AND CT2_MOEDLC = '01' "
				cQuery += "	AND CT2_ITEMD = '"+aItem[nItem,1]+"' "
				cQuery += " AND CT2_HP <> '999' "

				cQuery += " UNION ALL "

				cQuery += "	SELECT SUM(CT2_VALOR) * -1 VRDC FROM CT2010 WHERE D_E_L_E_T_ = ' ' "
				cQuery += " AND CT2_FILIAL = '  ' "
				cQuery += " AND SUBSTR(CT2_DATA,1,6) = '"+cMes+"' "
				cQuery += "	AND CT2_CREDIT BETWEEN '31102040' AND '31102041' "
				cQuery += " AND CT2_MOEDLC = '01' "
				cQuery += "	AND CT2_ITEMC = '"+aItem[nItem,1]+"' "
				cQuery += " AND CT2_HP <> '999' "
				cQuery += "	) "
				cQuery += "	) "

			ENDIF
			TCQUERY cQuery NEW ALIAS TRBFAT

			IF ! (TRBFAT->( bof() ) .and. TRBFAT->( eof() ))

				nTotMes  := nTotMes  + TRBFAT->VALOR
				nAculMes := nAculMes + TRBFAT->VALOR


				DO CASE

				CASE nMES = 1  ; aVrM01[nItem]  := TRBFAT->VALOR
				CASE nMES = 2  ; aVrM02[nItem]  := TRBFAT->VALOR
				CASE nMES = 3  ; aVrM03[nItem]  := TRBFAT->VALOR
				CASE nMES = 4  ; aVrM04[nItem]  := TRBFAT->VALOR
				CASE nMES = 5  ; aVrM05[nItem]  := TRBFAT->VALOR
				CASE nMES = 6  ; aVrM06[nItem]  := TRBFAT->VALOR
				CASE nMES = 7  ; aVrM07[nItem]  := TRBFAT->VALOR
				CASE nMES = 8  ; aVrM08[nItem]  := TRBFAT->VALOR
				CASE nMES = 9  ; aVrM09[nItem]  := TRBFAT->VALOR
				CASE nMES = 10 ; aVrM10[nItem]  := TRBFAT->VALOR
				CASE nMES = 11 ; aVrM11[nItem]  := TRBFAT->VALOR
				CASE nMES = 12 ; aVrM12[nItem]  := TRBFAT->VALOR

/*
				CASE nMES = 1  ; aVrM01[nItem]  := 9999999.99
				CASE nMES = 2  ; aVrM02[nItem]  := 9999999.99
				CASE nMES = 3  ; aVrM03[nItem]  := 9999999.99
				CASE nMES = 4  ; aVrM04[nItem]  := 9999999.99
				CASE nMES = 5  ; aVrM05[nItem]  := 9999999.99
				CASE nMES = 6  ; aVrM06[nItem]  := 9999999.99
				CASE nMES = 7  ; aVrM07[nItem]  := 9999999.99
				CASE nMES = 8  ; aVrM08[nItem]  := 9999999.99
				CASE nMES = 9  ; aVrM09[nItem]  := 9999999.99
				CASE nMES = 10 ; aVrM10[nItem]  := 9999999.99
				CASE nMES = 11 ; aVrM11[nItem]  := 9999999.99
				CASE nMES = 12 ; aVrM12[nItem]  := 9999999.99
*/


				ENDCASE

			ENDIF

			dbCloseArea("TRBFAT")

		NEXT nItem

		DO CASE

		CASE nMES = 1  ; aVrM01[nItem] := nTotMes ; aVrM01[nItem+1] := nAculMes
		CASE nMES = 2  ; aVrM02[nItem] := nTotMes ; aVrM02[nItem+1] := nAculMes
		CASE nMES = 3  ; aVrM03[nItem] := ntotMes ; aVrM03[nItem+1] := nAculMes
		CASE nMES = 4  ; aVrM04[nItem] := ntotMes ; aVrM04[nItem+1] := nAculMes
		CASE nMES = 5  ; aVrM05[nItem] := nTotMes ; aVrM05[nItem+1] := nAculMes
		CASE nMES = 6  ; aVrM06[nItem] := nTotMes ; aVrM06[nItem+1] := nAculMes
		CASE nMES = 7  ; aVrM07[nItem] := nTotMes ; aVrM07[nItem+1] := nAculMes
		CASE nMES = 8  ; aVrM08[nItem] := nTotMes ; aVrM08[nItem+1] := nAculMes
		CASE nMES = 9  ; aVrM09[nItem] := nTotMes ; aVrM09[nItem+1] := nAculMes
		CASE nMES = 10 ; aVrM10[nItem] := nTotMes ; aVrM10[nItem+1] := nAculMes
		CASE nMES = 11 ; aVrM11[nItem] := nTotMes ; aVrM11[nItem+1] := nAculMes
		CASE nMES = 12 ; aVrM12[nItem] := nTotMes ; aVrM12[nItem+1] := nAculMes

/*
		CASE nMES = 1  ; aVrM01[nItem] := 99999999.99 ; aVrM01[nItem+1] := 999999999.99
		CASE nMES = 2  ; aVrM02[nItem] := 99999999.99 ; aVrM02[nItem+1] := 999999999.99
		CASE nMES = 3  ; aVrM03[nItem] := 99999999.99 ; aVrM03[nItem+1] := 999999999.99
		CASE nMES = 4  ; aVrM04[nItem] := 99999999.99 ; aVrM04[nItem+1] := 999999999.99
		CASE nMES = 5  ; aVrM05[nItem] := 99999999.99 ; aVrM05[nItem+1] := 999999999.99
		CASE nMES = 6  ; aVrM06[nItem] := 99999999.99 ; aVrM06[nItem+1] := 999999999.99
		CASE nMES = 7  ; aVrM07[nItem] := 99999999.99 ; aVrM07[nItem+1] := 999999999.99
		CASE nMES = 8  ; aVrM08[nItem] := 99999999.99 ; aVrM08[nItem+1] := 999999999.99
		CASE nMES = 9  ; aVrM09[nItem] := 99999999.99 ; aVrM09[nItem+1] := 999999999.99
		CASE nMES = 10 ; aVrM10[nItem] := 99999999.99 ; aVrM10[nItem+1] := 999999999.99
		CASE nMES = 11 ; aVrM11[nItem] := 99999999.99 ; aVrM11[nItem+1] := 999999999.99
		CASE nMES = 12 ; aVrM12[nItem] := 99999999.99 ; aVrM12[nItem+1] := 999999999.99
*/

		ENDCASE

		nTotMes := 0

	NEXT nMES

	oPrn:StartPage()

	cBitMap := 'LGRL'+cEmpAnt+'.BMP'
	oPrn:SayBitmap(030,050,cBitMap,340,090)	// Imprime logo da Empresa: comprimento X altura

	oPrn:Say(0030,1200,SM0->M0_NOMECOM           ,oFont12N)
	oPrn:Say(0100,1400,"CNPJ 88.613.922/0001-15" ,oFont12N)
	oPrn:Say(0170,0800,"RELATÓRIO DE FATURAMENTO - DE "+aAno[1]+" A "+aAno[12]+" - EM REAIS" ,oFont14N)
	IF MV_PAR02 = 1
		oPrn:Say(0300,1400,"FATURAMENTO BRUTO C/I.P.I." ,oFont12N)
	ELSEIF MV_PAR02 = 2
		oPrn:Say(0300,1400,"FATURAMENTO BRUTO S/I.P.I." ,oFont12N)
	ELSE
		oPrn:Say(0300,1450,"VALOR DO I.P.I." ,oFont12N)
	ENDIF
	oPrn:Say(0340,0085,"MÊS" ,oFont12N)

//oPrn:Say(0385,0290, "CUIABÁ" ,oFont12N)
//oPrn:Say(0385,0530, "GOIANIA" ,oFont12N)
//oPrn:Say(0385,0850, "P. ALEGRE(CD)" ,oFont12N)
//oPrn:Say(0385,1140, "SÃO PAULO" ,oFont12N)
//oPrn:Say(0385,1440, "CURITIBA" ,oFont12N)
//oPrn:Say(0385,1770, "BETIM" ,oFont12N)
//oPrn:Say(0385,2060, "CARIACICA" ,oFont12N)
//oPrn:Say(0385,2305, "PORTO ALEGRE" ,oFont12N)
//oPrn:Say(0385,2600, "SAO LUIS" ,oFont12N)

	oPrn:Say(0385,0280, aItem[1][2] ,oFont12N)
	oPrn:Say(0385,0530, aItem[2][2] ,oFont12N)
	oPrn:Say(0385,0755, aItem[3][2] ,oFont12N)
	oPrn:Say(0385,1125, aItem[4][2] ,oFont12N)
	oPrn:Say(0385,1435, aItem[5][2] ,oFont12N)
	oPrn:Say(0385,1720, aItem[6][2] ,oFont12N)
	oPrn:Say(0385,2020, aItem[7][2] ,oFont12N)
	oPrn:Say(0385,2262, aItem[8][2] ,oFont12N)
	oPrn:Say(0385,2600, aItem[9][2] ,oFont12N)


	oPrn:Say(0385,2870, "TOTAL-MÊS" ,oFont12N)
	oPrn:Say(0385,3120, "ACUMULADO" ,oFont12N)

	oPrn:Say(0480,0060, aAno[1] ,oFont12N)
	oPrn:Say(0580,0060, aAno[2] ,oFont12N)
	oPrn:Say(0680,0060, aAno[3] ,oFont12N)
	oPrn:Say(0780,0060, aAno[4] ,oFont12N)
	oPrn:Say(0880,0060, aAno[5] ,oFont12N)
	oPrn:Say(0980,0060, aAno[6] ,oFont12N)
	oPrn:Say(1080,0060, aAno[7] ,oFont12N)
	oPrn:Say(1180,0060, aAno[8] ,oFont12N)
	oPrn:Say(1280,0060, aAno[9] ,oFont12N)
	oPrn:Say(1380,0060, aAno[10] ,oFont12N)
	oPrn:Say(1480,0060, aAno[11] ,oFont12N)
	oPrn:Say(1580,0060, aAno[12] ,oFont12N)

	oPrn:Say(1680,0070, "TOTAL" ,oFont12N)

	if MV_PAR03 == 1

		oPrn:Say(2120,0840, "Rafael Bacchin Schneider" ,oFont10N)
		oPrn:Say(2160,0980, "Diretor" ,oFont10)
		oPrn:Say(2200,0880, "CPF - 382.527.910-34" ,oFont10)

	else

		oPrn:Say(2120,0840, Alltrim(MV_PAR04)	,oFont10N)
		oPrn:Say(2160,0980, Alltrim(MV_PAR05) ,oFont10)
		oPrn:Say(2200,0880,"CPF - "+MV_PAR06 	,oFont10)
	EndIf

	oPrn:Say(2120,2340, "Arioberto Dorneles Leal"  ,oFont10N)
	oPrn:Say(2160,2480, "Contador",oFont10)
	oPrn:Say(2200,2380, "CRC-RS n.º 53.781/O-8",oFont10)


//LINHAS
	oPrn:Line(0280,0050,0280,3380)
	oPrn:Line(0350,0200,0350,3380)
	oPrn:Line(0450,0050,0450,3380)
	oPrn:Line(0550,0050,0550,3380)
	oPrn:Line(0650,0050,0650,3380)
	oPrn:Line(0750,0050,0750,3380)
	oPrn:Line(0850,0050,0850,3380)
	oPrn:Line(0950,0050,0950,3380)
	oPrn:Line(1050,0050,1050,3380)
	oPrn:Line(1150,0050,1150,3380)
	oPrn:Line(1250,0050,1250,3380)
	oPrn:Line(1350,0050,1350,3380)
	oPrn:Line(1450,0050,1450,3380)
	oPrn:Line(1550,0050,1550,3380)
	oPrn:Line(1650,0050,1650,3380)
	oPrn:Line(1750,0050,1750,3380)
	oPrn:Line(1850,0200,1850,3100)

	oPrn:Line(2100,0690,2100,1430)
	oPrn:Line(2100,2170,2100,2910)

//COLUNAS

	oPrn:Line(0280,0050,1750,0050)
	oPrn:Line(0280,0200,1850,0200)

	oPrn:Line(0350,0450,1850,0450)
	oPrn:Line(0350,0750,1850,0750)

	oPrn:Line(0350,1050,1850,1050)
	oPrn:Line(0350,1350,1850,1350)
	oPrn:Line(0350,1650,1850,1650)
	oPrn:Line(0350,1950,1850,1950)

	oPrn:Line(0350,2250,1850,2250)

	oPrn:Line(0350,2550,1850,2550)

	oPrn:Line(0350,2830,1850,2830)
	oPrn:Line(0350,3100,1850,3100)


	oPrn:Line(0280,3380,1750,3380)

	nLin := 0490
//nCol := 0380
//nCol := 0230


	FOR nItem := 1 TO LEN(aItem)

		DO CASE

		CASE nItem =  1  ; nCol := 0210
		CASE nItem =  2  ; nCol := 0510
		CASE nItem =  3  ; nCol := 0810
		CASE nItem =  4  ; nCol := 1110
		CASE nItem =  5  ; nCol := 1410
		CASE nItem =  6  ; nCol := 1730
		CASE nItem =  7  ; nCol := 2030
		CASE nItem =  8  ; nCol := 2330
		CASE nItem =  9  ; nCol := 2610

		ENDCASE


		oPrn:Say(nLin     ,nCol,Transform(aVrM01[nItem] ,"@E 999,999,999.99"),oFont10)
		oPrn:Say(nLin+0100,nCol,Transform(aVrM02[nItem] ,"@E 999,999,999.99"),oFont10)
		oPrn:Say(nLin+0200,nCol,Transform(aVrM03[nItem] ,"@E 999,999,999.99"),oFont10)
		oPrn:Say(nLin+0300,nCol,Transform(aVrM04[nItem] ,"@E 999,999,999.99"),oFont10)
		oPrn:Say(nLin+0400,nCol,Transform(aVrM05[nItem] ,"@E 999,999,999.99"),oFont10)
		oPrn:Say(nLin+0500,nCol,Transform(aVrM06[nItem] ,"@E 999,999,999.99"),oFont10)
		oPrn:Say(nLin+0600,nCol,Transform(aVrM07[nItem] ,"@E 999,999,999.99"),oFont10)
		oPrn:Say(nLin+0700,nCol,Transform(aVrM08[nItem] ,"@E 999,999,999.99"),oFont10)
		oPrn:Say(nLin+0800,nCol,Transform(aVrM09[nItem] ,"@E 999,999,999.99"),oFont10)
		oPrn:Say(nLin+0900,nCol,Transform(aVrM10[nItem] ,"@E 999,999,999.99"),oFont10)
		oPrn:Say(nLin+1000,nCol,Transform(aVrM11[nItem] ,"@E 999,999,999.99"),oFont10)
		oPrn:Say(nLin+1100,nCol,Transform(aVrM12[nItem] ,"@E 999,999,999.99"),oFont10)

		nTotFil:=aVrM01[nItem]+aVrM02[nItem]+aVrM03[nItem]+aVrM04[nItem]+aVrM05[nItem]+aVrM06[nItem]+aVrM07[nItem]+aVrM08[nItem]+aVrM09[nItem]+aVrM10[nItem]+aVrM11[nItem]+aVrM12[nItem]

		nCol := nCol - 5
		oPrn:Say(nLin+1200,nCol,Transform(nTotFil,"@E 999,999,999.99"),oFont10)

		oPrn:Say(nLin+1300,nCol,Transform(Round((nTotFil * 100)/aVrM12[LEN(aItem)+2],2) ,"@E 999,999,999.99")+"%",oFont10)


//	nCol := nCol + IF(nItem = 1,300,300)// + IF(nItem = 4,50,0) + IF(nItem = 6,50,0)
//	nCol := nCol + 250



	NEXT nItem

	nCol :=  2850

	oPrn:Say(nLin     ,nCol ,Transform(aVrM01[nItem] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+0100,nCol ,Transform(aVrM02[nItem] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+0200,nCol ,Transform(aVrM03[nItem] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+0300,nCol ,Transform(aVrM04[nItem] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+0400,nCol ,Transform(aVrM05[nItem] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+0500,nCol ,Transform(aVrM06[nItem] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+0600,nCol ,Transform(aVrM07[nItem] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+0700,nCol ,Transform(aVrM08[nItem] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+0800,nCol ,Transform(aVrM09[nItem] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+0900,nCol ,Transform(aVrM10[nItem] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+1000,nCol ,Transform(aVrM11[nItem] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+1100,nCol ,Transform(aVrM12[nItem] ,"@E 999,999,999.99"),oFont10)

	nTotFil:=aVrM01[nItem]+aVrM02[nItem]+aVrM03[nItem]+aVrM04[nItem]+aVrM05[nItem]+aVrM06[nItem]+aVrM07[nItem]+aVrM08[nItem]+aVrM09[nItem]+aVrM10[nItem]+aVrM11[nItem]+aVrM12[nItem]

	oPrn:Say(nLin+1200,nCol ,Transform(nTotFil,"@E 999,999,999.99"),oFont10)

	oPrn:Say(nLin+1300,nCol ,Transform(Round((nTotFil * 100) /aVrM12[LEN(aItem)+2],2) ,"@E 999,999,999.99")+"%",oFont10)

	nCol :=  3120

	oPrn:Say(nLin     ,nCol,Transform(aVrM01[nItem+1] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+0100,nCol,Transform(aVrM02[nItem+1] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+0200,nCol,Transform(aVrM03[nItem+1] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+0300,nCol,Transform(aVrM04[nItem+1] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+0400,nCol,Transform(aVrM05[nItem+1] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+0500,nCol,Transform(aVrM06[nItem+1] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+0600,nCol,Transform(aVrM07[nItem+1] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+0700,nCol,Transform(aVrM08[nItem+1] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+0800,nCol,Transform(aVrM09[nItem+1] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+0900,nCol,Transform(aVrM10[nItem+1] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+1000,nCol,Transform(aVrM11[nItem+1] ,"@E 999,999,999.99"),oFont10)
	oPrn:Say(nLin+1100,nCol,Transform(aVrM12[nItem+1] ,"@E 999,999,999.99"),oFont10)

	oPrn:EndPage()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-¿±±
±±³Fun‡…o    ³ AjustaSX1    ³Autor ³ Agostinho Lima  ³    10.11.2006      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-´±±
±±³Descri‡…o ³ Ajusta perguntas do SX1                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1()
	Local aArea := GetArea()
	Local aHelp01,aHelp02,aHelp03,aHelp04,aHelp05,aHelp06

	aHelp01 := aHelp02 := aHelp03 := aHelp04 :=aHelp05 := aHelp06 := {}

	AADD(aHelp01, "Informe o ano e mes inicial"  )
	AADD(aHelp02, "Informe com IPI, sem IPI ou apenas IPI")
	AADD(aHelp03, "Representante Legal. Escolha entre Padrão - Rafael Bacchin Schneider ou Customizado, preencher parametros abaixo."  )
	AADD(aHelp04, "Informe o nome do Representante Legal."  )
	AADD(aHelp05, "Informe o Cargo do Representante Legal."  )
	AADD(aHelp06, "Informe o CPF do Representante Legal. Formato: 999.999.999-99"  )

//		 	cPerg,"00","cPergunt"						,"","",cVar	 ,"C",00,0,0,"G","",F3,cGrpSxg		,Py,V1,cDef01		,cDefSpa1	,cDefEng1	,t1	,DF				,cDefSpa2		,cDefEng2		,cDef03		,cDefSpa3		,cDefEng3		,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)
	PutSx1(	cPerg,"01","Data inicial?"					,"","","mv_ch1","C",06,0,0,"G","","","mv_par01"	,"","",""      	,""			,""			,""	,""				,""      		,""				,""				,""				,""				,""	,""	,""	,"","","",aHelp01, aHelp01, aHelp01, "" )
	PutSx1(	cPerg,"02","Com IPI, sem ou apenas IPI ?"	,"","","mv_ch2","N",01,0,1,"C","","","mv_par02"	,"","","Com IPI"	,"Com IPI"	,"Com IPI"	,""	,"Sem IPI"		,"Sem IPI"		,"Sem IPI"		,"Apenas IPI"	,"Apenas IPI"	,"Apenas IPI"	,""	,""	,""	,"","","",aHelp02, aHelp02, aHelp02, "" )
	PutSx1(	cPerg,"03","Rep. Legal ?"					,"","","mv_ch3","N",01,0,1,"C","","","mv_par03"	,"","","Padrão"	,"Padrão"	,"Padrão"	,""	,"Customizado","Customizado","Customizado",""				,""				,""				,""	,""	,""	,"","","",aHelp03, aHelp03, aHelp03, "" )
	PutSx1(	cPerg,"04","Nome ?"							,"","","mv_ch4","C",50,0,0,"G","","","mv_par04"	,"","",""      	,""			,""			,""	,""				,""      		,""				,""				,""				,""				,""	,""	,""	,"","","",aHelp04, aHelp04, aHelp04, "" )
	PutSx1(	cPerg,"05","Cargo ?"							,"","","mv_ch5","C",20,0,0,"G","","","mv_par05"	,"","",""      	,""			,""			,""	,""				,""      		,""				,""				,""				,""				,""	,""	,""	,"","","",aHelp05, aHelp05, aHelp05, "" )
	PutSx1(	cPerg,"06","CPF ?"							,"","","mv_ch6","C",14,0,0,"G","","","mv_par06"	,"","",""      	,""			,""			,""	,""				,""      		,""				,""				,""				,""				,""	,""	,""	,"","","",aHelp06, aHelp06, aHelp06, "" )

	RestArea(aArea)

Return

