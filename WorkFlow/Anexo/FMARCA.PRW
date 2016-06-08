
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE 'TBICONN.CH'
#INCLUDE 'protheus.ch'

#DEFINE  ENTER CHR(10)+CHR(13)
#IFNDEF CRLF
	#DEFINE CRLF ( CHR(13)+CHR(10) )
#ENDIF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FMARCA    ºAutor  ³Fabiano Pereira     º Data ³  08/05/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Foco Marca                                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  DATA    ³ ANALISTA ³ ALTERACOES                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±º          ³          ³                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Imdepa                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
05/11/2007 	       MARCIO Q.BORGES   Envia emails para Ana, Giba e Dani quanto forem enviado para o Gilberto.
20/02/2008 AAZNMD  MARCIO Q.BORGES   Alterado forma de pesquisa da Meta geral do vendedor/gerente, usado no calculo da meta OUTROS
*/
*********************************************************************
USER FUNCTION FMARCA()
*********************************************************************
	Local   ctitulo	:= "RELATORIO FOCO MARCA "
	Private cDesc1		:= "Este programa tem como objetivo imprimir relatorio "
	Private cDesc2		:= "de acordo com os parametros informados pelo usuario."
	Private cDesc3		:= "RELATORIO FOCO MARCA"
	Private cPict		:= ""
	Private nLin   	:= 80
	Private Cabec2  	:= ""
	Private imprime 	:= .T.
	Private aOrd 		:= {}
	Private nOrdem,dDtAnoMes
	Private lEnd    	:= .F.
	Private lAbortPrint  := .F.
	Private CbTxt   	:= ""
	Private limite  	:= 30//220
	Private tamanho 	:= "G"
	Private NomeProg	:= "FMARCA"
	Private nTipo   	:= 18
	Private aReturn 	:= { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey	:= 0
	Private cbtxt   	:= Space(10)
	Private cbcont  	:= 00
	Private CONTFL  	:= 01
	Private m_pag   	:= 01
	Private wnrel   	:= "FMARCA"
	Private dUltDia 	:= dPriDia := cMarca := cConsidera := cNick := cTexto := cTipo := cTipoVen := cTpGrupo := ""
	Private CPERG		:= "RFOCOM"
	Private cString 	:= "SD2"
	Private nX:=nTotalMeta	:= 0
// 10/07/2009 - Jean Rehermann - Usará a tabela Z8 do SX5 (Grupo de Marcas 3)
//Private aMarcas 	:= {"LUK","INA","FAG","FRM","BG","GOODYEAR","SABO","FCM","DS","TIMKEN","GBR","GBR-R","GBR-C","NTN","BRB","NSK","OUTROS"}
	Private aMarcas 	:= {}
	Private aMetas		:= {}
	Private aMetGeral	:= {} // Metas gerais do vendedor/Gerente
	Private aDados  	:= {}
	Private aAnoMes 	:= {}
	Private aDatas  	:= {}
	Private aDiasUt 	:= {}
	Private nDiasuMA	:= 0 //Dias uteis total do mês atual
	Private aTotalMes	:= {}
	Private aTotalGeral	:= {}
	Private lWorkFlow	:= .F.
	Private NCOUNT    	:=  1
	Private lpassou  	:= .F.
	Private EndArqRel	:= '\RELATO\WORKFLOW\'

	Private lTeste		:= .F. // se teste envia somente para os e-mail definidos no teste

//³ Monta a interface padrao com o usuario...                           ³

	If Type("dDatabase") == "U"

		lWorkFlow := .T.
		Conout(  "FMARCA -  VIA WORKFLOW - Preparando Environment")

	//Inserido por Edivaldo Gonçalves Cordeiro em 30/06/2007
		cEmp := '01'
		cFil := '05'

		PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil MODULO "FAT" USER "WORK" PASSWORD "WORK" FUNNAME 'FMARCA'  TABLES 'SF2','SX5', 'SX6'

	//| Parametro Para Rodar Retroativo
		If !Empty(Alltrim(GetMv("MV_DTWORKF")))
			dDatabase := Stod(GetMv("MV_DTWORKF"))
		Endif

		DbSelectArea('SX1')
		Pergunte(CPERG,.F.,"PARAMETROS FOCO MARCA ")
	//Fim da Inserção por Edivaldo

		dDataConsiderada := dDatabase -1

		nX := 1

		FOR nX := 1 TO 4

			MV_PAR01 := nX


			MV_PAR02 := MV_PAR04 := MV_PAR06  := Space(06)
			MV_PAR03 := MV_PAR05 := MV_PAR07  := "ZZZZZZ"

		// USADO PARA TESTES
		/*
		MV_PAR02 :=	"000458"
		MV_PAR03 :=	"000458"
		MV_PAR08 := "000642"
		MV_PAR09 := "000642"
		*/
			Conout(  "FMARCA - Gerando Foco Marca "+AllTrim(Str(nX)))

			aMetas	:= {}
			aDados  := {}
			aMarcas := {}

		// 10/07/2009 - Jean Rehermann - Não utiliza marcas e sim o grupo de marcas 3
			Dbselectarea("SX5")
			Dbseek( xFilial("SX5") + "Z8",.F.) // Tabela de Grupos de Marcas 3
			While( SX5->X5_TABELA == "Z8" .AND. !SX5->( EoF() ) )
			If SubStr( SX5->X5_DESCRI, 1, 8 ) != "(N USAR)" // Jean Rehermann - 31/07/2009 - Desconsidera não usados
				aAdd( aMarcas, SX5->X5_CHAVE )
			EndIf
			SX5->( dbSkip() )
		EndDo

		wnrel := SetPrint(cString,NomeProg,cPerg,ctitulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

		If nLastKey == 27
			Return
		Endif

		SetDefault(aReturn,cString)

		If nLastKey == 27
			Return
		Endif

		nTipo := If(aReturn[4]==1,15,18)

		Conout(  "FMARCA - VALIDANDO DATAS...          ")
		DTVALIDA()
		Conout(  "FMARCA - VERIFICANDO VENDAS...       ")
		QUERYVENDAS()
		Conout(  "FMARCA - VERIFICANDO DEVOLUÇÕES...   ")
		QUERYDEVOLUCAO()
		Conout(  "FMARCA - IMPRIMINDO RELATORIO...     ")
		PRINTREL()

	Next nX

	If lWorkFlow
		//		Reset Environment
		Conout(  "FMARCA -  VIA WORKFLOW - Job Executado com sucesso...")
	EndIf

Return

Else

	lWorkFlow := .F.
	//	lWorkFlow := .T.	// MARCIO - USADO PARA enviar email para a estrutura de vendas, rodando via menu
	dDataConsiderada := dDatabase -1

	Conout( " FMARCA -  VIA MENU    - Preparando Environment ")
	AJUSTASX1()
	PERGUNTE(CPERG,.T.,"PARAMETROS FOCO MARCA ")

	wnrel := SetPrint(cString,NomeProg,cPerg,ctitulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
	Return
	Endif

	SetDefault(aReturn,cString)
	If nLastKey == 27
	Return
	Endif

	// 10/07/2009 - Jean Rehermann - Não utiliza marcas e sim o grupo de marcas 3
	_aAreaAtu = GetArea()
	aMarcas 	:= {}
	Dbselectarea("SX5")
	Dbseek( xFilial("SX5") + "Z8",.F.) // Tabela de Grupos de Marcas 3
	While( SX5->X5_TABELA == "Z8" .AND. !SX5->( EoF() ) )
	If SubStr( SX5->X5_DESCRI, 1, 8 ) != "(N USAR)"
		aAdd( aMarcas, SX5->X5_CHAVE )

	EndIf
	SX5->( dbSkip() )
EndDo
RestArea( _aAreaAtu )

nTipo := If(aReturn[4]==1,15,18)
Conout(  "FMARCA - VALIDANDO DATAS...          ")
MsAguarde( {||  DTVALIDA()        }," FOCO MARCA    " ,"VALIDANDO DATAS...          ")
Conout(  "FMARCA - VERIFICANDO VENDAS...       ")
Processa ( {||  QUERYVENDAS()     }," FOCO MARCA    " ,"VERIFICANDO VENDAS...       ")
Conout(  "FMARCA - VERIFICANDO DEVOLUÇÕES...   ")
Processa ( {||  QUERYDEVOLUCAO()  }," FOCO MARCA    " ,"VERIFICANDO DEVOLUÇÕES...   ")
Conout(  "FMARCA - IMPRIMINDO RELATORIO...     ")
Processa ( {||  PRINTREL()        }," FOCO MARCA    " ,"IMPRIMINDO RELATORIO...     ")

Return()

EndIf


Return()
*********************************************************************
STATIC FUNCTION DTVALIDA()	// FUNCAO DE DATAS
*********************************************************************
	nSpaceCol:= y := 0
	dHoje 	 := dDataConsiderada
	dUltDia  := LastDay(dDataConsiderada)
	dPriDia	 := FirstDay(dDataConsiderada)
	nMes	 := Substr(DtoS(dPriDia),5,2)
	nAno  	 := Year(dDataConsiderada)

//marcio------
	cTexto := ""
	aTotalGeral := {}
	aTotalMes	:= {}
	aDiasUt		:= {}
	aAnoMes     := {}

//------------
	nDiasuMA	:= DiasUteis(dPriDia, dUltDia )

	FOR i := 1 TO 13
		nDiasUtil := 0
		nSpaceCol += 10

		IF  i == 1
			dUltDia := dHoje
		ENDIF

		DO WHILE  dPriDia <= dUltDia
			IF DataValida(dUltDia) == dUltDia
				nDiasUtil++
			ENDIF
			dUltDia--
		ENDDO

		AADD(aAnoMes,ALLTRIM(Str(nAno,6,0))+nMes)      //	ANO MES
		AADD(aDiasUt,nDiasUtil)                         //	DIAS UTEIS
		AADD(aTotalMes,{aAnoMes[i],0}) 	 			//	TOTAL MENSAL
		dPriDia--
		dUltDia := LastDay(dPriDia)
		dPriDia	:= FirstDay(dPriDia)
		nMes	:= Substr(DtoS(dPriDia),5,2)
		nAno 	:= Year(dPriDia)

	NEXT
	aSort(aAnoMEs)											// ORDEN DECRESCENTE


	For k:=1 To Len(aMarcas)
		AADD(aTotalGeral,{aMarcas[K],0})	 				//	TOTAL GERAL
	Next

	FOR k:= 2 TO 13
//	cTexto+= SUBSTR(MesExtenso(Substr(aAnoMes[K],5,2)),1,3)+"/"+ Substr(aAnoMes[K],3,2)+ "  | "

		cTexto+= SUBSTR(MesExtenso(Substr(aAnoMes[K],5,2)),1,3)+"/"+ Substr(aAnoMes[K],3,2)+ "    "

	NEXT
//cTexto+= "  Meta  | Meta %  | Mês Ant.%| MMAA % |  12Meses % |   Peso %  |"		//        cTexto+= "  Meta     | Mês Ant.%| MMAA % | 12Meses% "

	cTexto+= "  Meta    Meta %    Mês Ant.%  MMAA %    12Meses %     Peso %   "		//        cTexto+= "  Meta     | Mês Ant.%| MMAA % | 12Meses% "


Return
*********************************************************************
STATIC FUNCTION QUERYVENDAS()
*********************************************************************
	nVlrMeta := k :=0
	CMARCA   :=""
	PROCREGUA(3)
	INCPROC()

	Processa ( {|| }," FOCO MARCA    " ,"PROCESSANDO METAS...     ")

	cQuery:= " "

	cQuery += " SELECT "
	IF MV_PAR01 == 4 //DIRETOR
//	cQuery += " '000141' "
		cQuery += "'"+ ALLTRIM(GETMV("MV_DIRVEND")) +"'"
	ELSE
		cQuery += " SCT.CT_VEND "
	ENDIF

	cQuery += " VEND, SUBSTR(CT_DATA,1,6) DDATA, SCT.CT_MARCA3 MARCA ,SCT.CT_GRUPO GRUPO , SUM(SCT.CT_VALOR)  AS META"
	cQuery += " FROM "  + RetSqlName("SCT") + " SCT "

	IF MV_PAR01 == 4 //DIRETOR
		cQuery += ", "  + RetSqlName("SA3") + " SA3 "
	ENDIF

	cQuery += "              WHERE CT_DATA >= '"+DTOS(FirstDay(dDataConsiderada))+"'"
	cQuery += "                AND CT_DATA <= '"+DTOS(LastDay(dDataConsiderada))+"'"
	cQuery += " 				  AND SCT.CT_VEND <> ' ' "
	cQuery += " 				  AND CT_MARCA3 <> ' '"
	cQuery += "                AND CT_REGIAO = ' '"
	cQuery += "                AND CT_CCUSTO = ' '"
	cQuery += "                AND CT_CIDADE = ' '"
	cQuery += "                AND CT_SEGMEN = ' '"
	cQuery += "                AND CT_TIPO = ' '"
	cQuery += "                AND CT_PRODUTO = ' '"
	cQuery += "                AND CT_CLVL = ' '"
	cQuery += "                AND CT_GRPSEGT = ' '"
	cQuery += "                AND SCT.D_E_L_E_T_ <> '*'"
	cQuery += " 		         AND SCT.CT_CLIENTE = ' '"
	cQuery += " 		         AND SCT.CT_LOJACLI = ' '"

	IF MV_PAR01 == 4 //DIRETOR
		cQuery += "	 AND SCT.CT_VEND = SA3.A3_COD"
		cQuery += "	 AND SA3.A3_FILIAL = '  '"
		cQuery += "	 AND SA3.A3_GRPREP IN (" + GETMV("MV_EISGEVE") + ") "
		cQuery += "	 AND SA3.D_E_L_E_T_  = ' '	"
	ENDIF

	cQuery += " 		  		GROUP BY "
	IF MV_PAR01 == 4 //DIRETOR
		cQuery += " "
	ELSE
		cQuery += "	 SCT.CT_VEND, "
	ENDIF
	cQuery += "	 SUBSTR(SCT.CT_DATA,1,6) , SCT.CT_MARCA3 ,SCT.CT_GRUPO "

	cQuery += "           	ORDER BY "
	IF MV_PAR01 == 4 //DIRETOR
		cQuery += " "
	ELSE
		cQuery += "	 SCT.CT_VEND, "
	ENDIF
	cQuery += " SUBSTR(SCT.CT_DATA,1,6) , SCT.CT_MARCA3 ,SCT.CT_GRUPO"

	MEMOWRIT("C:\SQLSIGA\FMARCA_META.TXT", cQUERY)

	cQuery := ChangeQuery(cQuery)
	TCQUERY cQuery NEW ALIAS "META"

	Conout("Rodei Query META")

	aMetas := {}
	DO WHILE META->(!EOF())
		AADD(aMetas, {META->VEND,META->DDATA,META->MARCA,META->GRUPO,META->META})

		META->(DBSKIP())
	ENDDO

	META->(DBCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca Meta dos Vendedores/Gerentes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MetaVend()

	IF MV_PAR01 == 1
	//	cConsidera := 'F2_VEND5'   // GERENTE DE VENDAS"
		cConsidera := 'A1_GERVEN'   // GERENTE DE VENDAS"
		cNick	   := " AS GERE "
		cTipo	   :=	"GERE"
		cTipoVen   := "GERENTE"
	ELSEIF  MV_PAR01 == 2
	//	cConsidera := 'F2_VEND3'   // Gestor de Contas
		cConsidera := 'A1_VENDCOO' // Gestor de Contas
		cNick	   := " AS COOR "
		cTipo	   :=	"COOR"
		cTipoVen   := "GESTOR DE CONTAS"
	/*	Case MV_PAR01 == 2
	cConsidera := 'F2_VEND2'   // VENDEDOR EXTERNO
	cNick	   := " AS REPR "
	cTipo	   :=	"REPR"
	*/
	ELSEIF MV_PAR01 == 3
	//	cConsidera := 'F2_VEND1'   // VENDEDOR INTERNO
		cConsidera := 'A1_VENDEXT' // VENDEDOR INTERNO
		cNick	   := " AS VEND "
		cTipo	   :=	"VEND"
		cTipoVen   := "VENDEDOR"
	ELSEIF MV_PAR01 == 4
//	cConsidera := "'000141'"
		cConsidera := "'"+ ALLTRIM(GETMV("MV_DIRVEND")) +"'"
		cNick	   := " AS DIRE "
		cTipo	   :=	"DIRE"
		cTipoVen   := "DIRETOR"
	ENDIF

	Conout(  "FMARCA - QueryVendas - FOCO MARCA - "+ cTipoVen)

	IF SELECT("VENDA") <> 0
		VENDA->( DBCLOSEAREA() )
	END

	CQUERY := ""
	CQUERY += "	SELECT "+cConsidera+cNick+",						"
	CQUERY += "		 SUBSTR(SF2.F2_EMISSAO,1,6) AS DDATA,			"
//CQUERY += "		 SB1.B1_MARCA AS MARCA,             			"
	CQUERY += "		 SB1.B1_GRMAR3 AS MARCA,             			"
	CQUERY += "		 SB1.B1_GRUPO AS GRUPO,  						"
//CQUERY += "	         SUM (D2_PRCVEN * (D2_QUANT - D2_QTDEDEV) ) AS VLR_VENDA  " // Considerando a devolução diretamente na  venda
//CQUERY += "	         SUM (D2_PRCVEN * (D2_QUANT ) ) AS VLR_VENDA  " // Considerando a devolução diretamente na  venda
	CQUERY += "	         SUM (D2_TOTAL) AS VLR_VENDA  "
	CQUERY += " FROM " +RETSQLNAME("SF2")+" SF2 					"

	CQUERY += "			   INNER JOIN  " +RETSQLNAME("SD2")+" SD2 	"
	CQUERY += "		 	   ON  SF2.F2_FILIAL   = SD2.D2_FILIAL  	"
	CQUERY += "			   AND SF2.F2_DOC      = SD2.D2_DOC			"
	CQUERY += "     	   AND SF2.F2_SERIE    = SD2.D2_SERIE       "
	CQUERY += "     	   AND SF2.F2_CLIENTE  = SD2.D2_CLIENTE     "

//Inserido por Edivaldo Goncalves Cordeiro em 24/02/11
	CQUERY += "     	   AND SF2.F2_CLIENTE <> '014824'           "

	CQUERY += "     	   AND SF2.F2_LOJA     = SD2.D2_LOJA	    "

	CQUERY += "			   INNER JOIN  " +RETSQLNAME("SF4")+" SF4 	"
	CQUERY += "			   ON  SD2.D2_TES 		= SF4.F4_CODIGO     "
	CQUERY += "     	   AND SD2.D2_FILIAL 	= SF4.F4_FILIAL     "

	CQUERY += "			   INNER JOIN  " +RETSQLNAME("SB1")+" SB1 	"
	CQUERY += "			   ON  SD2.D2_FILIAL = SB1.B1_FILIAL		"
	CQUERY += "			   AND SD2.D2_COD = SB1.B1_COD		        "

	CQUERY += "			   INNER JOIN " +RETSQLNAME("SA1")+" SA1 "
	CQUERY += "			   ON SF2.F2_CLIENTE = A1_COD  "
	CQUERY += "			   AND SF2.F2_LOJA   = A1_LOJA "

	CQUERY += " WHERE SF2.F2_EMISSAO BETWEEN '"+DTOS(dPriDia)+"' AND '"+DTOS(dDataConsiderada)+"'"

	INCPROC()

	CQUERY += " AND SD2.D2_TIPO NOT IN ('B', 'D', 'P', 'I')         "
	CQUERY += " AND SD2.D2_ORIGLAN  != 'LF'                         "
	CQUERY += " AND SF4.F4_DUPLIC    = 'S'                          "
	CQUERY += " AND SF4.F4_ESTOQUE   = 'S'                          "

	If MV_PAR01 == 1         // GERENTE
		CQUERY += " AND SA1." + cConsidera + " BETWEEN '"+MV_PAR02+ "' AND '"+MV_PAR03+"' "
	ElseIf MV_PAR01 == 2     // Gestor de Contas
		CQUERY += " AND SA1." + cConsidera + " BETWEEN '"+MV_PAR04+ "' AND '"+MV_PAR05+"' "
	ElseIf MV_PAR01 == 3	// VEND. INT
		CQUERY += " AND SA1." + cConsidera + " BETWEEN '"+MV_PAR06+ "' AND '"+MV_PAR07+"' "
	ElseIf MV_PAR01 == 4	// DIRETOR
		CQUERY += " "
	Endif

	CQUERY += " AND SF2.R_E_C_D_E_L_ = 0	"
	CQUERY += " AND SB1.R_E_C_D_E_L_ = 0	"
	CQUERY += " AND SD2.R_E_C_D_E_L_ = 0	"
	CQUERY += " AND SF4.R_E_C_D_E_L_ = 0	"
	CQUERY += " AND SA1.A1_FILIAL = ' '	    "
	CQUERY += " AND SA1.D_E_L_E_T_ <> '*'   "

	CQUERY += " GROUP BY "+cConsidera+", SB1.B1_GRMAR3, SB1.B1_GRUPO, SUBSTR(SF2.F2_EMISSAO,1,6) "
	CQUERY += " ORDER BY "+cConsidera+", SB1.B1_GRMAR3, SB1.B1_GRUPO, SUBSTR(SF2.F2_EMISSAO,1,6) "

	IF !lWorkFlow
		MEMOWRIT("C:\SQLSIGA\FMARCA_VENDA.TXT", cQUERY)
	ELSE
		MEMOWRIT("\WORKFLOW\FMARCA_VENDA.TXT", cQUERY)
	ENDIF

	cQuery       := ChangeQuery(cQuery)
	cQueryVenda  := "VENDA"
	TCQUERY cQuery NEW ALIAS cQueryVenda
	INCPROC()

	Conout( "Rodei Query Venda" )

	Processa ( {|| }," FOCO MARCA    " ,"PROCESSANDO VENDAS...     ")
	cQueryVenda->(DBGOTOP())
	PROCREGUA(RecCount())
	While cQueryVenda->(!eof())

		/* GBR - Classif. 3 Grupos: GBR, GBR-R(Rolamentos-06), GBR-C (Correntes-11/12/13) */
	// 16/07/2009 - Jean Rehermann - Não precisa mais deste tratamento pois utiliza o grupo de marcas 3
	/*
	If ALLTRIM(cQueryVenda->MARCA) $ "GBR" .Or. ALLTRIM(Substr(cQueryVenda->MARCA,1,3)) $ "GBR"
	If cQueryVenda->GRUPO == "0006"
	CMARCA := "GBR-R"
	cMetaMarca := "GBR"
	cGrupo := AllTrim(cQueryVenda->GRUPO)
	Elseif cQueryVenda->GRUPO $ "0011/0012/0013"
	CMARCA := "GBR-C"
	cMetaMarca := "GBR"
	cGrupo := AllTrim(cQueryVenda->GRUPO)
	Else
	CMARCA := "GBR"
	cMetaMarca := "GBR"
	cGrupo := SPACE(LEN(cQueryVenda->GRUPO))//AllTrim(cQueryVenda->GRUPO)
	Endif
	Else
	CMARCA := ALLTRIM(cQueryVenda->MARCA)
	cMetaMarca := ALLTRIM(cQueryVenda->MARCA)
	cGrupo := SPACE(LEN(cQueryVenda->GRUPO))
	Endif
	*/
		CMARCA     := ALLTRIM(cQueryVenda->MARCA)
		cMetaMarca := ""
		cGrupo     := SPACE(LEN(cQueryVenda->GRUPO))

		/* Busca no Array aDados GERE/REPR/COOR/VEND + Marca */
		nPos := AScan(aDados,{ |X| AllTrim(x[1]) +AllTrim(x[2]) ==  ALLTRIM(cQueryVenda->&cTipo.)+CMARCA } )
		If nPos == 0
		// 16/07/2009 - Jean Rehermann - OUTROS já está incluso em GRUPOS DE MARCAS 3
		//		nPos  := AScan(aDados,{ |X| AllTrim(x[1]) +AllTrim(x[2]) ==  ALLTRIM(cQueryVenda->&cTipo.)+"OUTROS" } )
			//		IF nPos == 0	/* Se nao achou nada, inclui um item em aDados */
			For k := 1 To Len(aMarcas)
				For i:=1 To Len(aAnoMes)
					AADD(aDatas,aAnoMes[i])
					AADD(aDatas,0)
					AADD(aDatas,0)
				Next
				AADD(aDados,{cQueryVenda->&cTipo.,aMarcas[k],aDatas,cMetaMarca,cGrupo})
				aDatas:={}
			Next
			/* Faz nova busca (GERE/REPR/COOR/VEND + Marca) e inclui no Array */
			nPos  := AScan(aDados,{ |X| AllTrim(x[1]) +AllTrim(x[2]) ==  ALLTRIM(cQueryVenda->&cTipo.)+CMARCA } )

		// 16/07/2009 - Jean Rehermann - OUTROS já está incluso em GRUPOS DE MARCAS 3
		//		If nPos == 0
		//			nPos  := AScan(aDados,{ |X| AllTrim(x[1]) +AllTrim(x[2]) ==  ALLTRIM(cQueryVenda->&cTipo.)+"OUTROS" } )
		//		EndIf
		//		ENDIF
		Endif

	//³vendas³
		X_META := 5	//	j:=1
		For j:=1 To Len(aDados[nPos][3])	// Verifica se a Data e igual e inclui Valor
			IF ValType(aDados[nPos][3][j]) == "C"
				IF aDados[nPos][3][j] == cQueryVenda->DDATA

					aDados[nPos][3][j+1] += cQueryVenda->VLR_VENDA
					aDados[nPos][4]	:=	""
					aDados[nPos][5]	:=	cGrupo

				ENDIF
			ENDIF
		Next j

		cQueryVenda->(dbskip())
		Incproc()
	Enddo

//³METAS ³//	AADD(aMetas, {META->VEND,META->DDATA,META->MARCA,META->GRUPO,META->META})
	FOR nPos := 1 TO LEN(aDados)
		X_META := 5
		j:=1
		For j:=1 To LEN(aDados[nPos][3])	// Verifica se a Data e igual e inclui Valor + Meta
			IF ValType(aDados[nPos][3][j]) == "C"
			//			IF  aDados[nPos][3][j] == cQueryVenda->DDATA
			//				nPosMeta := aScan(aMetas, {|x| AllTrim(x[1])+ AllTrim(x[2])+ AllTrim(x[3])+ AllTrim(x[4]) == AllTrim(aDados[nPos][1])+ AllTrim(Substr(DtoS(dDataConsiderada),1,6)) + AllTrim(cMetaMarca)+ AllTrim(cGRUPO) })
			//| Cristiano MAchado Data: 28/08/2009 Problema: Metas Zeradas
			//|nPosMeta := aScan(aMetas, {|x| AllTrim(x[1])+ AllTrim(x[2])+ AllTrim(x[3])+ AllTrim(x[4]) == AllTrim(aDados[nPos][1])+ AllTrim(aDados[nPos][3][j] ) + AllTrim(aDados[nPos][4])+ AllTrim(aDados[nPos][5]) })
				nPosMeta := aScan(aMetas, {|x| AllTrim(x[1])+ AllTrim(x[2])+ AllTrim(x[3]) == AllTrim(aDados[nPos][1])+ AllTrim(aDados[nPos][3][j] ) + AllTrim(aDados[nPos][2])  })

				IF nPosMeta > 0
				//| Cristiano MAchado Data: 28/08/2009 Problema: Metas Zeradas
				//| aDados[nPos][3][j+2] := aMetas[nPosMeta][X_META]
					aDados[nPos][3][j+2] := aMetas[nPosMeta][5]
				ENDIF
			ENDIF
		//		ENDIF
		Next j
	Next nPos

	cQueryVenda->(DBCLOSEAREA())

	INCPROC()

Return
*********************************************************************
STATIC FUNCTION QUERYDEVOLUCAO()
*********************************************************************
	k		:= 0
	CMARCA	:= ""
	PROCREGUA(3)
	INCPROC()

	IF MV_PAR01 == 1						// GERENTE
		cConsidera    	:=	" A1_GERVEN "
		cNick			:=	" AS GERE "
		cTipo			:=	"GERE"
		cTipoVen		:= "GERENTE"
	ELSEIF MV_PAR01 == 2					// Gestor de Contas
		cConsidera    	:=	" A1_VENDCOO "
		cNick			:=	" AS COOR "
		cTipo			:=	"COOR"
		cTipoVen		:= "GESTOR DE CONTAS"
	ELSEIF MV_PAR01 == 3  				// VEND.INT
		cConsidera    	:=	" A1_VENDEXT "
		cNick			:=	" AS VEND "
		cTipo			:=	"VEND"
		cTipoVen		:= "VENDEDOR"
	ENDIF

	INCPROC()

	IF SELECT("cQueryDev") <> 0
		cQueryDev->( DBCLOSEAREA() )
	END

	CQUERY := ""
	CQUERY +=" SELECT "+cConsidera+cNick+" ,		"
	CQUERY += "		SUBSTR(SD1.D1_DTDIGIT,1,6) AS DDATA,			"
	CQUERY +=" 		SB1.B1_GRMAR3 AS MARCA ,  	"
	CQUERY +=" 		SB1.B1_GRUPO AS GRUPO ,  	"
	CQUERY +=" 		SUM (D1_TOTAL) VLR_DEV		"

	CQUERY +=" FROM "+RetSQLName("SD1")+" SD1 ," +RetSQLName("SF1")+" SF1  ,"+RetSqlName("SA1")+" SA1, "+RetSqlName("SF4")+" SF4, "+RetSqlName("SB1")+" SB1 "  //+" , "+RetSqlName("SA3")+" SA3 "
	CQUERY +=" WHERE  D1_FILIAL = F1_FILIAL "
	CQUERY +=" AND	  D1_FILIAL = F4_FILIAL"

	CQUERY += " AND D1_DTDIGIT BETWEEN '"+DTOS(dPriDia)+"' AND '"+DTOS(dDataConsiderada)+"'"
//	CQUERY +=" AND D1_DTDIGIT BETWEEN '20070420' AND '20070513' "

	CQUERY +=" AND D1_TIPO = 'D' "
	CQUERY +=" AND F4_FILIAL  = D1_FILIAL "
	CQUERY +=" AND F4_CODIGO  = D1_TES "
// Jorge Oliveira - 10/02/2011 - Pega as devolucoes que movimentaram Estoque
	CQUERY +=" AND F4_ESTOQUE = 'S' "
	CQUERY +=" AND F1_DOC     = D1_DOC   "
	CQUERY +=" AND F1_SERIE   = D1_SERIE "
	CQUERY +=" AND F1_FORNECE = D1_FORNECE "
	CQUERY +=" AND F1_LOJA    = D1_LOJA
	CQUERY +=" AND A1_COD     = D1_FORNECE "

//Inserido por Edivaldo Gonçalves Cordeiro em 24/11/02
	CQUERY +=" AND A1_COD     <> '014824' "


	CQUERY +=" AND A1_LOJA    = D1_LOJA "

	CQUERY +=" AND D1_FILIAL  = B1_FILIAL "
	CQUERY +=" AND D1_COD     = B1_COD "
	CQUERY +=" AND B1_TIPO IN('PA','PP','MP')"

//CQUERY +=" AND A3_COD ="+ cConsidera
//CQUERY +=" AND "+ cConsidera+" = A3_COD "

	If MV_PAR01 == 1         // GERENTE
		CQUERY += " AND SA1.A1_GERVEN  BETWEEN '"+MV_PAR02+"'  AND '"+MV_PAR03+"'  "
	ElseIf MV_PAR01 == 2     // Gestor Contas
		CQUERY += " AND SA1.A1_VENDCOO BETWEEN '"+MV_PAR04+"'  AND '"+MV_PAR05+"'  "
	ElseIf MV_PAR01 == 3					// VEND. INT
		CQUERY += " AND SA1.A1_VENDEXT BETWEEN '"+MV_PAR06+"'  AND '"+MV_PAR07+"'  "
	Endif

	CQUERY +=" AND SD1.D_E_L_E_T_ = ' ' "
	CQUERY +=" AND SF4.D_E_L_E_T_ = ' ' "
	CQUERY +=" AND SF1.D_E_L_E_T_ = ' ' "
//CQUERY +=" AND SA3.D_E_L_E_T_ = ' ' "
	CQUERY +=" AND SA1.D_E_L_E_T_ = ' ' "

	CQUERY +=" GROUP BY "+cConsidera+", SB1.B1_GRMAR3, SB1.B1_GRUPO, SUBSTR(SD1.D1_DTDIGIT,1,6) "
	CQUERY +=" ORDER BY "+cConsidera+", SB1.B1_GRMAR3, SB1.B1_GRUPO ,SUBSTR(SD1.D1_DTDIGIT,1,6) "

	IF !lWorkFlow
		MEMOWRIT("C:\SQLSIGA\FMARCA_DEVOL.TXT", cQuery)
	ELSE
		MEMOWRIT("\WORKFLOW\FMARCA_DEVOL.TXT", cQuery)
	ENDIF

	cQuery	   := ChangeQuery(cQuery)
	cQueryDev  := "DEVOL"
	TCQUERY cQuery NEW ALIAS cQueryDev
	IncProc()

	Conout(  "FMARCA - QueryDevolucao ")

	Processa ( {||         }," FOCO MARCA    " ,"PROCESSANDO DEVOLUÇÃO...     ")
	cQueryDev->(DBGOTOP())
	while !eof()

	// 16/07/2009 - Jean Rehermann - Já está incluso em GRUPOS DE MARCAS 3
	/*
	If ALLTRIM(cQueryDev->MARCA) $ "GBR" .Or. ALLTRIM(Substr(cQueryDev->MARCA,1,3)) $ "GBR"
	If cQueryDev->GRUPO == "0006"
	CMARCA := "GBR-R"
	Elseif cQueryDev->GRUPO $ "0011/0012/0013"
	CMARCA := "GBR-C"
	Else
	CMARCA := "GBR"
	Endif
	Else
	CMARCA := ALLTRIM(cQueryDev->MARCA)
	Endif
	*/

		CMARCA := ALLTRIM(cQueryDev->MARCA)

		nPos  := AScan(aDados,{ |X| AllTrim(x[1]) +AllTrim(x[2]) ==  ALLTRIM(cQueryDev->&cTipo.)+CMARCA } )
		If nPos == 0
		// 16/07/2009 - Jean Rehermann - Já está incluso em GRUPOS DE MARCAS 3
		//		nPos  := AScan(aDados,{ |X| AllTrim(x[1]) +AllTrim(x[2]) ==  ALLTRIM(cQueryDev->&cTipo.)+"OUTROS" } )
		//		IF nPos == 0		// Se nao existir nas QueryVenda criara a partir da QueryDev
			For k := 1 To len(aMarcas)
				For i:=1 To Len(aAnoMes)
					AADD(aDatas,aAnoMes[i])
					AADD(aDatas,0)
					AADD(aDatas,0)
				Next
				AADD(aDados,{cQueryDev->&cTipo.,aMarcas[k],aDatas})
				aDatas:={}
			Next

			nPos  := AScan(aDados,{ |X| AllTrim(x[1]) +AllTrim(x[2]) ==  ALLTRIM(cQueryDev->&cTipo.)+CMARCA } )
		// 16/07/2009 - Jean Rehermann - Já está incluso em GRUPOS DE MARCAS 3
		//If nPos == 0
		//	nPos  := AScan(aDados,{ |X| AllTrim(x[1]) +AllTrim(x[2]) ==  ALLTRIM(cQueryDev->&cTipo.)+"OUTROS" } )
		//EndIf
		//		EndIf
		Endif

		j:=1
		For j:=1 To LEN(aDados[nPos][3])	/* Verifica se a Data e igual e inclui Valor + Meta */
			IF ValType(aDados[nPos][3][j]) == "C"
				IF  aDados[nPos][3][j] == cQueryDev->DDATA
					aDados[nPos][3][j+1] -= cQueryDev->VLR_DEV
				ENDIF
			ENDIF
		Next j

	/*
	For j:=1 To 39
	if aDados[nPos][3][j] == cQueryDev->DDATA
	j++
	aDados[nPos][3][j] -= cQueryDev->VLR_DEV
	exit
	else
	j:= j+2
	Endif
	Next
	*/
		cQueryDev->(dbskip())
		IncProc()
	enddo

	cQueryDev->(DBCLOSEAREA())

	INCPROC()

Return
*********************************************************************
Static Function PRINTREL()
*********************************************************************
	Local ctitulo	:= " " //"RELATORIO FOCO MARCA - "+cTipo+" - PERIODO: "+ DTOC(dUltDia) +" - "+ DTOC(dDataConsiderada)
	Local Cabec1    := " " //"  MARCA      "+cTexto

	Private cDestinatario:=""

	Store 0  To nVlr12M,nTotalGMeta,nMeta,nVlrMMAA,nTMMAA,nValorMM,nTotalMA,nMeta,nVlrMeta,nValor,nMesAnter,nMesAtual,nTotal12Mes,nVlrOutros,nTotG12Mes,nCount

	cController := ""
	QueryMarca	:= ""
	aVlr12M		:= {}
	y := k  	:= 1
	nCol    	:= 20
	lPrint  	:= .T.
	lPassou 	:= .F.

	Conout(  "FMARCA - PrintRel ")

//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	ProcRegua(Len(aDados))

	k := 1

	For k:=1 to Len(aDados)
		ctitulo   := 'Foco Marca - ' + cTipoVen + ': ' + aDados[k][1] + '- Data da Geração: '+ DTOC(dDatabase) //"RELATORIO FOCO MARCA - "+cTipo+" - PERIODO: "+ DTOC(dUltDia) +" - "+ DTOC(dDataConsiderada)
		Cabec1    := " GRP.MARCAS-3                 "+cTexto

		If nCount >= 2 .AND. lWorkFlow == .T. .AND. lPrint == .T.

		//		ctitulo   := 'FOCO MARCA - ' + cTipoVen + ': ' + aDados[k][1] + '- Data da Geração: '+ DTOC(dDatabase) //"RELATORIO FOCO MARCA - "+cTipo+" - PERIODO: "+ DTOC(dUltDia) +" - "+ DTOC(dDataConsiderada)
		//		Cabec1    := "  MARCA    "+cTexto

			Store "" To cDestinatario,QueryMarca,cController
			Store 0  To nVlr12M,nTotalGMeta,nMeta,nVlrMMAA,nTMMAA,nValorMM,nTotalMA,nMeta,nVlrMeta,nValor,nMesAnter,nMesAtual,nTotal12Mes,nVlrOutros

			aVlr12M:= {}
			nTvlr12M := 0

			wnrel := SetPrint(cString,wnrel,cPerg,ctitulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

			If nLastKey == 27
				Return
			Endif

			SetDefault(aReturn,cString)

			If nLastKey == 27
				Return
			Endif

			nTipo := If(aReturn[4]==1,15,18)

		Endif

		nCol := 22

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		IF lPrint == .T.

		//³PRE-CALULO DO TOTAL GERAL DO R$ 12 MESES  ³
		//³Que sera usado para calculo das % 12Meses ³
			nTotG12Mes 	:= 0
			klinha		:=1
			FOR klinha:=1 TO Len(aDados)
				cCodVen := aDados[k][1]
				IF  aDados[klinha][1] == cCodVen
					nKTotal12Mes := 0
					ncount:=0

					ilinha:=1
					For ilinha:=1 to 39
						IF ValType(aDados[kLinha][3][ilinha]) == "C"  .AND. ilinha > 3  // desconsiera MMAA
							cMes := aDados[klinha][3][ilinha]
							nPos 	  := AScan(aTotalMes,  { |X| AllTrim(x[1])  == cMes  } )

							nVenda := aDados[klinha][3][ilinha+1]

							nKTotal12Mes 	+= nVenda / aDiasUt[nPos]
							ncount++
						ENDIF
					Next ilinha
					nTotG12Mes +=  nKTotal12Mes
				ENDIF
			NEXT klinha

			nTotG12Mes :=  nTotG12Mes / 12

		//³Fim Pre-Calculo³

			IF lWorkFlow
				CabecIMD(cTitulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			ELSE
				Cabec(cTitulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			ENDIF

			nLin   := 8
			lPrint := .F.
			@ nLin,00 PSAY	 __PrtFatLine()
			nLin++
//		@ nLin,01 PSAY   cTipoVen + " : " + aDados[k][1]+  " - " +  POSICIONE("SA3",1,Space(2)+aDados[k][1],"A3_NOME")

			@ nLin,01 PSAY   cTipoVen + " : " + aDados[k][1]+  "-" +  POSICIONE("SA3",1,Space(2)+aDados[k][1],"A3_NOME")

			If lWorkFlow == .T.
				cDestinatario := POSICIONE("SA3",1,Space(2)+aDados[k][1],"A3_EMAIL")
			// ENVIA EMAIL PARA O GERENTE DO VENDEDOR
				cGerente := SA3->A3_GEREN
				IF !EMPTY(cGerente)
					cGerMail := Posicione("SA3",1,xFilial("SA3")+ cGerente,"A3_EMAIL")
					IF !Empty(cGerMail)
						IF !EMPTY(cDestinatario)
							cDestinatario += ", "
						ENDIF
						cDestinatario += cGerMail
					ENDIF
				ENDIF
			Endif

			nLin++
			@ nLin,00 PSAY	 __PrtFatLine()
		Endif
		nLin++

		/* Imprime Marca */
//	@ nLin,02 PSAY SubStr( Tabela( "Z8", aDados[k][2] ), 1, 25 )

		@ nLin,02 PSAY Replace( SubStr( Tabela( "Z8", aDados[k][2] ), 1, 25 ) ," ", "" )


		nTotal12Mes := 0

		i:=1
		For i:=1 to 39
			IF ValType(aDados[k][3][i]) == "C"
				cMes := aDados[k][3][i]

				nPos 	  := AScan(aTotalMes,  { |X| AllTrim(x[1])  == cMes } )
				nPosMarca := AScan(aTotalGeral,{ |X| AllTrim(x[1])  == aDados[k][2]    } )

				nVenda := aDados[k][3][i+1]

				nSaldo :=  nVenda / aDiasUt[nPos]

				aTotalMes[nPos][2]        += nSaldo
				aTotalGeral[nPosMarca][2] += nSaldo

				IF i== 1
					nMesAnoAnt	:=  aDados[k][3][i+1] / aDiasUt[nPos]
				ELSE

					iif(i==4,nCol+=07,nCol+=10)

					@ nLin,nCol PSAY TRANSFORM(nSaldo,'@E 9,999,999')


					If i==34
						nMesAnter	:= nSaldo
					Elseif i ==  37
						nMesAtual	:= nSaldo
						nMeta 		:= aDados[k][3][i+2]

						If K == Len( aDados )
						// Indice 3 := CT_VEND+ CT_DATA
						// Indice 4 := CT_VEND+ DATA  + MARCA + GRUPO
						//nXMeta 	 := POSICIONE("SCT",3,aDados[k][1]+DtoS(FirstDay(dDataConsiderada)),"CT_VALOR")
							nPos 	  := AScan(aMetGeral,  { |X| x[1]  == aDados[k][1] } )
							IF nPos > 0
								nXMeta := aMetGeral[nPos][2]
							ELSE
								nXMeta := 0
							ENDIF
							nVlrMeta :=	 (nXMeta / nDiasuMA) - nTotalGMeta
						Else
							nVlrMeta :=  (nMeta /nDiasuMA)
						Endif

						nTotalGMeta += nVlrMeta

					Endif

					nTotal12Mes 	+= nSaldo

				ENDIF
			ENDIF
		Next i

		/* ---------- METAS R$ ---------- */
		nCol+=11
		@ nLin,nCol PSAY TRANSFORM(nVlrMeta,'@E 9,999,999')

		/* ---------- % METAS ---------- */
		nCol+=10
		IF nVlrMeta == 0
			nPercMeta := 0
		ELSE
			nPercMeta := (((nMesAtual / nVlrMeta)-1)*100 )

			IF  nPercMeta > 0
				nPercMeta := MIN(nPercMeta, 9999 )
			ELSE
				nPercMeta := MAX(nPercMeta, -9999 )
			ENDIF

		ENDIF
		@ nLin,nCol+03 PSAY	 TRANSFORM(nPercMeta,'@E 99999')
		/* ---------- MES ANTERIOR % ---------- */
		IF nMesAnter == 0
			nValorMM := 0
		ELSE
			nValorMM := (((nMesAtual / nMesAnter ) - 1 )* 100 )

			IF  nValorMM > 0
				nValorMM := MIN(nValorMM, 9999 )
			ELSE
				nValorMM := MAX(nValorMM, -9999 )
			ENDIF

		ENDIF

		@ nLin,nCol+14 PSAY  TRANSFORM(nValorMM,'@E 99999')
		/* ---------- % Mesmo Mês Ano Anteior ( % MMAA) ---------- */
		IF nMesAnoAnt == 0
			nVlrMMAA := 0
		ELSE
			nVlrMMAA := (((nMesAtual / nMesAnoAnt ) - 1 )* 100 )

			IF  nVlrMMAA > 0
				nVlrMMAA := MIN(nVlrMMAA, 9999 )
			ELSE
				nVlrMMAA := MAX(nVlrMMAA, -9999 )
			ENDIF
		ENDIF

		@ nLin,nCol+24 PSAY PADL(TRANSFORM(nVlrMMAA,'@E 99999') ,05," ")
		nTMMAA		+= nVlrMMAA
	// mudado para valor 12 meses para % dos 12 meses
	/*
	// ----------R$ SOMATARIO MêS ATUAL + OS ULTIMO 11 MESES / 12  ----------

	nVlr12M :=  nTotal12Mes / 12
	@ nLin,nCol+33 PSAY	PADL(TRANSFORM(nVlr12M,'@E 999,999'),07," ")

	*/
	// ---------- SOMATARIO MêS ATUAL + OS ULTIMO 11 MESES / 12 , EM % ----------

		nVlr12M :=  nTotal12Mes / 12

		IF nVlr12M == 0
			nPerc12M := 0
		ELSE
			nPerc12M := (((nMesAtual / nVlr12M ) - 1 )* 100 )

			IF  nPerc12M > 0
				nPerc12M := MIN(nPerc12M, 9999 )
			ELSE
				nPerc12M := MAX(nPerc12M, -9999 )
			ENDIF

		ENDIF

		@ nLin,nCol+35 PSAY	PADL(TRANSFORM(nPerc12M,'@E 99999') ,05," ")

// Jean Rehermann - 14/09/2009 - Coloquei estas duas linhas mais para baixo para não interferir no cálculo do peso
//	nVlr12M	+= nVlr12M
//	AADD(aVlr12M,{nLin,nCol+33,nVlr12M})

	// modificado % dos 12 meses para PESO dos 12 meses
	// ----------% percentagem ultimos 12 meses ----------
	/*
	IF nTotG12Mes == 0
	nPerc12M := 0
	ELSE
	nPerc12M := (nVlr12M/nTotG12Mes ) * 100
	ENDIF

	@ nLin,nCol+43 PSAY PADL(TRANSFORM(nPerc12M,'@E 999.99') ,08," ")
	*/

		IF nTotG12Mes == 0
			nPeso := 0
		ELSE
			nPeso := (nVlr12M/nTotG12Mes ) * 100
		ENDIF

		@ nLin,nCol+45 PSAY PADL(TRANSFORM(nPeso,'@E 999.99') ,08," ")


// Jean Rehermann - 14/09/2009 - As duas linhas que trouxe logo de cima
		nVlr12M	+= nVlr12M
		AADD(aVlr12M,{nLin,nCol+33,nVlr12M})

	**********************************************************************

		nTotal12Mes := 0
		nCol+=10

	//	If aDados[K][2] == "OUTROS"
		If Mod( K, Len(aMarcas) ) == 0
			nLin++
			nLin++
			@ nLin,00 PSAY	 __PrtFatLine()
			nLin++
			@ nLin,00 PSAY "TOTAL"
			nCol:= 28

			x:=1
			For x:=1 To 13
				y:=x
				IF x== 1
					nPos := Ascan(aTotalMes,{ |X| AllTrim(x[1]) == aAnoMes[y] } )
					nTGMMAA :=  aTotalMes[nPos][2]
				ELSE
					nPos := Ascan(aTotalMes,{ |X| AllTrim(x[1]) == aAnoMes[y] } )
					nTotalMes := aTotalMes[nPos][2]
					iif(y == 2,nCol+=1,nCol+=0)

					@ nLin,nCol PSAY TRANSFORM(nTotalMes,'@E 9,999,999')
					nCol += 10
				// ARMAZENA TOTAL PARA TOTAL DA %

					IF  y == 13 // mes atual
						nTGMAt := nTotalMes
					ELSEIF y == 12 // mes anteior
						nTGMAnt	:= nTotalMes
					ENDIF
				ENDIF

				aTotalMes[nPos][2] := 0
				nTotalMes			:= 0
			Next

		/*		For x:=2 To 13
		y:=x
		nPos := Ascan(aTotalMes,{ |X| AllTrim(x[1]) == aAnoMes[y] } )
		nTotalMes := aTotalMes[nPos][2]
		iif(y == 2,nCol+=1,nCol+=0)
		If Len(AllTrim(Str(nTotalMes))) >= 4
		@ nLin,nCol PSAY Stuff(AllTrim(Str(nTotalMes)),Len(AllTrim(Str(nTotalMes)))-2,0,".")
		Else
		@ nLin,nCol PSAY nTotalMes
		Endif
		// ARMAZENA TOTAL PARA TOTAL DA %

		IF  y == 13 // mes atual
		nTGMAt := nTotalMes
		ELSEIF y == 12 // mes anteior
		nTGMAnt	:= nTotalMes
		ENDIF

		aTotalMes[nPos][2] := 0
		nTotalMes			:= 0
		nCol += 10
		Next
		*/

		//³TOTAL META³
			@ nLin,nCol+1 PSAY TRANSFORM(nTotalGMeta,'@E 9,999,999')

		//³TOTAL % META        ³
			IF nTotalGMeta == 0
				nTot := 0
			ELSE
				nTot := (((nTGMAt / nTotalGMeta ) - 1 )* 100 )

				IF  nTot > 0
					nTot := MIN(nTot, 9999 )
				ELSE
					nTot := MAX(nTot, -9999 )
				ENDIF
			ENDIF

			nCol+= 16
			@ nLin,nCol PSAY TRANSFORM(nTot,'@E 9999') //		@ nLin,nCol PSAY Round(nTotalMA,0) PICTURE "@R 99999"
		//³TOTAL % MES ANTERIOR³
			IF nTGMAnt == 0
				nTot := 0
			ELSE
				nTot := (((nTGMAt / nTGMAnt ) - 1 )* 100 )
			ENDIF

			nCol+=11
			@ nLin,nCol PSAY TRANSFORM(nTot,'@E 9999') //		@ nLin,nCol PSAY Round(nTotalMA,0) PICTURE "@R 99999"

		//³TOTAL MMAA %³
			IF nTGMMAA == 0
				nTot := 0
			ELSE
				nTot := (((nTGMAt / nTGMMAA ) - 1 )* 100 )
			ENDIF

			nCol+=08
			@ nLin,nCol PSAY TRANSFORM(nTot,'@E 99999') //@ nLin,nCol PSAY Round(nTMMAA,0)   PICTURE "@R 99999"

		// ALTERADO TOTAL GERAL DOS 12 MESES DE VALOR PARA %
		/*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³TOTAL 12MESES³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nCol+=07
		@ nLin,nCol PSAY TRANSFORM(nTotG12Mes,'@E 9,999,999') //@ nLin,nCol PSAY Round(nTMMAA,0)   PICTURE "@R 99999"
		*/
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ % 12MESES   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			IF nTotG12Mes == 0
				nTot := 0
			ELSE
				nTot := (((nTGMAt / nTotG12Mes ) - 1 )* 100 )
			ENDIF

			nCol+=07
			@ nLin,nCol PSAY TRANSFORM(nTot,'@E 9,999,999') //@ nLin,nCol PSAY Round(nTMMAA,0)   PICTURE "@R 99999"

			nTotalMA:=nTMMAA:=nTotalGMeta:= 0

			nLin++
			@ nLin,00 PSAY	 __PrtFatLine()
			nLin++
			@ nLin,00 PSAY "DIAS UTEIS"
			nCol:= 30

			x := 1
			For x := 1 To Len(aDiasUt)
				iif(x == 1,nCol+=6,nCol+=0)
				if (Len(aDiasUt)-x) >=  1
					@ nLin,nCol PSAY aDiasUt[(Len(aDiasUt))-x]
					nCol += 10
				Endif
			Next
			nLin++
			@ nLin,00 PSAY	 __PrtFatLine()

			nLin++
			@ nLin,00 PSAY "Data de Geração : " + DTOC(dDatabase)+ " "
			nLin++
			@ nLin,00 PSAY "DataBase : " + DTOC(dDataConsiderada) + " "
			nLin++
			nLin++
			nLin++
			nLin++
		//		Roda(,"Foco Marca",Tamanho) // MARCIO
			lPrint 		:= .T.
			Store 0 To nVlrMMAA,nTMMAA,nValorMM,nTotalMA,nTvlr12M
		//---- WORKFLOW ----

			IF lWorkFlow == .T.

				//Cristiano - Inicio
				cChave := Substr(dtos(dDatabase) + StrTran(Time(),':',''),1,12)
   				aFile := ''

				OurSpool(Wnrel)/**********************///MV_RELT

				aFiles := Directory(EndArqRel + '*.spl')

				For n :=1 To Len(aFiles)

					If Substr(dTos(aFiles[n][3]) + StrTran(aFiles[n][4],':',''),1,12) == cChave
						aFile := 	aFiles[n][1]
						exit
					EndIF
				Next

				fRename(EndArqRel + aFile , EndArqRel + wnrel + '.##r' )

				//Cristiano - Fim

				IF File(EndArqRel+wnrel+".html")
					fErase(EndArqRel+wnrel+".html")
				Endif

				If !ExistBlock("MSRELTOHTML")
					CONOUT("FOCO MARCA - Função MSRELTOHTML não compilada. Não irá gerar HTML para envio")
				Endif

				U_MsRelToHtml( EndArqRel+wnrel+".##r" )

				ENVIAEMAIL(cDestinatario,EndArqRel+wnrel+".html")  //FMARCA.##r)

				IF File(EndArqRel+wnrel+".##r")
					FErase(EndArqRel+wnrel+".##r")
				Endif

				NCOUNT++
				MS_FLUSH()

			ENDIF

		Endif
		IncProc()
	Next


	IF lWorkFlow == .F.

	//	Roda(,"Foco Marca",Tamanho)
	//³ Finaliza a execucao do relatorio...                                 ³

		SET DEVICE TO SCREEN

	//³ Se impressao em disco, chama o gerenciador de impressao...          ³

		If aReturn[5]==1
			dbCommitAll()
			SET PRINTER TO
			OurSpool(wnrel)
		Endif

		MS_FLUSH()

	ENDIF

RETURN
*********************************************************************
STATIC FUNCTION ENVIAEMAIL(CPARA,CANEXO)
*********************************************************************
	LOCAL CSERVER  := GETMV('MV_RELSERV')	// Nome do Servidor de E-mail
	LOCAL CUSER    := GETMV('MV_RELACNT')	// Conta a ser usada no envio do E-mail. protheus@imdepa.com.br
	LOCAL CPASS    := GETMV('MV_RELPSW')   // Senha de Autentificacao do E-mail
	LOCAL LAUTH    := GETMV("MV_RELAUTH")	// Se servidor de e-mail necessita de autentificacao
	LOCAL CHTML

	LOCAL aFilGer   := {}
	LOCAL nX1       := 1
	LOCAL nX2       := 1
	LOCAL cEmailBcc := ""

	PRIVATE CERROR    := ""
	PRIVATE CPASS     := SPACE(25)


	cHtml := '<html>'
	cHtml += '<head>'
	cHtml += '<title>FOCO MARCA </title>'	+ CRLF
	cHtml += '<h3 align=Left>FOCO MARCA</h3>'+ CRLF
	cHtml += '</head>'
	cHtml += '<body bgcolor=white text=black  >'
	cHtml += '<hr width=100% noshade>' + CRLF

	cHtml += '<font size="3" face="Courier">Processamento :</font>'+'<b><font size="3" face="Courier">Automático</font></b>'+ CRLF
	cHtml += '<font size="3" face="Courier">Processado em :</font>'+'<b><font size="3" face="Courier">'+Dtoc(dDataConsiderada)+' às '+Time()+'</font></b>'+ CRLF+CRLF

	cHtml += '<font size="4" color="#23238E"><b>Prezados srs. !  </b></font>'+ CRLF+ CRLF
	cHtml += '<font size="3" color="#23238E"><b>Vamos analisar o relatorio em Anexo </b></font>'+ CRLF

	cHtml += '</body>'
	cHtml += '</html>'
	cHtml += CRLF

	CENVIA 		:= cDestinatario

	CMENSAGEM 	:= "RELATóRIO FOCO MARCA"
	CSUBJECT 	:= "FOCO MARCA "
	NI        	:= 1
	N 			:= 1
	CPATHARQ 	:= EndArqRel + wnrel+".HTML" //FMARCA.##r"

	ALISTA := {}
	AADD( ALISTA, CENVIA )

	CSERVER	:= GETMV("MV_RELSERV")
	CCONTA 	:= GETMV("MV_RELACNT")
	CPASS  	:= GETMV("MV_RELPSW")

	CONNECT SMTP SERVER CSERVER ACCOUNT CUSER PASSWORD CPASS RESULT LRESULT
	IF LRESULT .AND. LAUTH
		LRESULT := MAILAUTH(CUSER,CPASS)
		IF !LRESULT
			LRESULT := MAILAUTH(CUSER,CPASS)
		ENDIF
		IF !LRESULT
		//ERRO NA CONEXAO COM O SMTP SERVER
			GET MAIL ERROR CERROR
			CONOUT("FMARCA - ERRO DE AUTENTICACAO DE E-MAIL NO JOB DE AçAO DE VENDAS "+CERROR)
		RETURN NIL
		ENDIF
	ELSE
		IF !LRESULT
		//ERRO NA CONEXAO COM O SMTP SERVER
			GET MAIL ERROR CERROR
			CONOUT("FMARCA - ERRO DE CONEXAO NO ENVIO DE E-MAIL: "+CERROR)
		RETURN NIL
		ENDIF
	ENDIF

	aArea := GetArea()

	DBSELECTAREA("SX6")
	DBSETORDER(1)

	IF cTipoVen == 'DIRETOR'

		nX1:= 1

		WHILE DBSEEK(xFilial("SX6")+"MV_FMDI_"+STRZERO(nX1,2)) // E-mail dos que recebem o relatorio do diretor

			cEmailBcc += ","+ALLTRIM(X6_CONTEUD)
			nX1 += 1

		END

		cEmailBcc += ","+ALLTRIM(GETMV("MV_ECONTTI")) // E-mail de controle da TI

		IF !EMPTY(GETMV("MV_EGERGV")) .AND. AT(ALLTRIM(GETMV("MV_EGERGV")),ALISTA[1]) == 0  // E-mail do gerente geral de vendas
			cEmailBcc += ","+ALLTRIM(GETMV("MV_EGERGV"))
		ENDIF


	ELSEIF cTipoVen == 'GERENTE'

		nX1:= 1

		WHILE DBSEEK(xFilial("SX6")+"MV_FMGE_"+STRZERO(nX1,2)) // E-mail dos que recebem o relatorio do gerente

			cEmailBcc += ","+ALLTRIM(X6_CONTEUD)
			nX1 += 1

		END

		cEmailBcc += ","+ALLTRIM(GETMV("MV_ECONTTI"))  // E-mail de controle da TI

		IF !EMPTY(GETMV("MV_EGERGV")) .AND. AT(ALLTRIM(GETMV("MV_EGERGV")),ALISTA[1]) == 0  // E-mail do gerente geral de vendas
			cEmailBcc += ","+ALLTRIM(GETMV("MV_EGERGV"))
		ENDIF


	ELSE
		cEmailBcc := ","+ALLTRIM(GETMV("MV_ECONTTI")) // E-mail de controle da TI
	ENDIF

	aFilGer  := {}

	SX6->(DBGOTOP())

	WHILE  !EOF()

		IF ALLTRIM(SX6->X6_VAR) = "MV_EGERV"  .AND. !EMPTY(SX6->X6_CONTEUD)

			AADD(aFilGer,SX6->X6_FIL)

		ENDIF

		DBSKIP()

	ENDDO

	FOR nX2 := 1 TO LEN(aFilGer)

		IF AT(ALLTRIM(SUPERGETMV("MV_EGERV",.F.,, aFilGer[nX2])),ALISTA[1]+cEmailBcc) <> 0
			cEmailBcc += ","+ALLTRIM(SUPERGETMV("MV_EASSV",.F.,, aFilGer[nX2]))  // E-mail da assistente de vendas
		ENDIF

	NEXT

	RestArea(aArea)

	IF lTeste
		SEND MAIL FROM CCONTA   ;
			TO ALLTRIM(GETMV("MV_ECONTTI")) ;
			SUBJECT 'Foco Marca  - ' + cTipoVen + ': ' + aDados[k][1] + '- Data da Geração: '+ DTOC(dDatabase)  ; //SUBJECT 'Relatório Foco Marca  - Gerado: '+ DTOC(dDatabase)  ;
			BODY CHTML ;
			ATTACHMENT  EndArqRel + wnrel+".HTML"
		DISCONNECT SMTP SERVER
	ELSE

		SEND MAIL FROM CCONTA   ;
			TO ALISTA[1] ;
			CC cEmailBcc ;
			SUBJECT 'Foco Marca  - ' + cTipoVen + ': ' + aDados[k][1] + '- Data da Geração: '+ DTOC(dDatabase)  ; //SUBJECT 'Relatório Foco Marca  - Gerado: '+ DTOC(dDatabase)  ;
			BODY CHTML ;
			ATTACHMENT  EndArqRel + wnrel + ".HTML" //FMARCA.##r'
		DISCONNECT SMTP SERVER

	ENDIF

	CONOUT("FMARCA - E-MAIL FOCO MARCA ENVIANDO COM SUCESSO para " + ALISTA[1]+ ","+ cEmailBcc)

RETURN()
*********************************************************************
STATIC FUNCTION AJUSTASX1()
*********************************************************************

	LOCAL aHelp01 := {}, aHelp02 := {}, aHelp03 := {}, aHelp04 := {}, aHelp05 := {}, aHelp06 := {}, aHelp07 := {}

	IF ! SX1->(DBSEEK(CPERG,.F.))

		AADD(AHELP01, "GERENTE"+ENTER+"GESTOR DE CONTAS"+ENTER+"VEND.INT"  )
		AADD(AHELP02, "DO GERENTE: ?" 			)
		AADD(AHELP03, "ATé GERENTE: ?" 			)
		AADD(AHELP04, "DO GESTOR DE CONTAS: ?"	)
		AADD(AHELP05, "ATé GESTOR DE CONTAS: ?" )
		AADD(AHELP06, "DO VEND.INTERNO: ?" 		)
		AADD(AHELP07, "ATé VEND.INTERNO: ?" 	)


	//PutSx1( cGrupo  ,cOrdem,cPergunt         ,cPerSpa ,cPerEng ,cVar ,cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3
	//, cGrpSxg ,cPyme,cVar01 ,cDef01  ,cDefSpa1,cDefEng1,cCnt01,cDef02  ,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)

		PUTSX1( "RFOCOM","01", "CONSIDERA:", "", "","MV_CH1","N",01,0,0,"C","","",;
			"","","MV_PAR01","GERENTE","","","","GESTOR DE CONTAS","","","VEND.INTERNO",NIL,NIL,"",NIL,NIL,NIL,NIL,NIL,aHelp01,NIL, NIL )

		PUTSX1( "RFOCOM","02", "DO GERENTE:", "", "","MV_CH2","C",06,0,0,"G","","SA3",;
			"","","MV_PAR02","","","","","","","",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,aHelp02,NIL, NIL )

		PUTSX1( "RFOCOM","03", "ATé GERENTE:", "", "","MV_CH3","C",06,0,0,"G","","SA3",;
			"","","MV_PAR03","","","","","","","",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,aHelp03,NIL, NIL )

		PUTSX1( "RFOCOM","04", "DO GESTOR DE CONTAS:", "", "","MV_CH4","C",06,0,0,"G","","SA3",;
			"","","MV_PAR04","","","","","","","",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,aHelp04,NIL, NIL )

		PUTSX1( "RFOCOM","05", "ATé GESTOR DE CONTAS:", "", "","MV_CH5","C",06,0,0,"G","","SA3",;
			"","","MV_PAR05","","","","","","","",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,aHelp05,NIL, NIL )

		PUTSX1( "RFOCOM","06", "DO VEND.INTERNO:", "", "","MV_CH6","C",06,0,0,"G","","SA3",;
			"","","MV_PAR08","","","","","","","",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,aHelp06,NIL, NIL )

		PUTSX1( "RFOCOM","07", "ATé VEND.INTERNO:", "", "","MV_CH7","C",06,0,0,"G","","SA3",;
			"","","MV_PAR09","","","","","","","",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,aHelp07,NIL, NIL )

	ENDIF

RETURN()
*********************************************************************
Static Function DiasUteis( dDataInicial,dataLimite)
*********************************************************************

	Local 	area   := GetArea()
	Private ndUtil := 0   // total de dias uteis
	Private lregional // Feriado regional
	Private dDtIni

	DEFAULT dDataInicial := FirstDay(dataLimite)

	dDtIni := dDataInicial

	While   dDtIni <= datalimite
		If DataValida(dDtIni) == dDtIni
		// Consulta tabela de feriados regionais

		//		dbSelectArea('SX5')
		//		dbSetOrder(1)
		//		dbSeek(XFilial('SX5')+'I8'+ __filialAtual )
			lregional := .F.
		//		Do While !Eof() .AND. SX5->X5_TABELA == 'I8' .AND.  Left( SX5->X5_CHAVE,2 )== __filialAtual
		//			If Left(SX5->X5_DESCRI,5) == Left( DTOC( dDtIni ),5 )  // verificar dia e mes
		//				lregional := .T.
		//				Exit
		//			Endif
		//			dbSkip()
		//		Enddo
		//		If !lregional
			ndUtil++  //somatorio de dias úteis considerando os feriados regionais
		//		Endif
		Endif
		dDtIni++
	EndDo

	RestArea( area )

Return nDUtil
*********************************************************************
Static Function MetaVend()
*********************************************************************

	cQuery:= " "

	cQuery += " SELECT "

	IF MV_PAR01 == 4 //DIRETOR
//	cQuery += " '000141' "
		cQuery += "'"+ ALLTRIM(GETMV("MV_DIRVEND")) +"'"

	ELSE
		cQuery += " SCT.CT_VEND "
	ENDIF

	cQuery += " VEND, SUM(SCT.CT_VALOR)  AS META "
	cQuery += " FROM "  + RetSqlName("SCT") + " SCT "

	IF MV_PAR01 == 4 //DIRETOR
		cQuery += ", "  + RetSqlName("SA3") + " SA3 "
	ENDIF

	cQuery += "              WHERE CT_DATA >= '"+DTOS(FirstDay(dDataConsiderada))+"'"
	cQuery += "                AND CT_DATA <= '"+DTOS(LastDay(dDataConsiderada))+"'"
	cQuery += " 				  AND SCT.CT_VEND <> ' ' "
	cQuery += " 				  AND CT_MARCA3 = ' '"
	cQuery += "                AND CT_REGIAO = ' '"
	cQuery += "                AND CT_CCUSTO = ' '"
	cQuery += "                AND CT_CIDADE = ' '"
	cQuery += "                AND CT_SEGMEN = ' '"
	cQuery += "                AND CT_TIPO = ' '"
	cQuery += "                AND CT_PRODUTO = ' '"
	cQuery += "                AND CT_CLVL = ' '"
	cQuery += "                AND CT_GRPSEGT = ' '"
	cQuery += "                AND SCT.D_E_L_E_T_ <> '*'"
	cQuery += " 		         AND SCT.CT_CLIENTE = ' '"
	cQuery += " 		         AND SCT.CT_LOJACLI = ' '"
	IF MV_PAR01 == 4 //DIRETOR
		cQuery += "	 AND SCT.CT_VEND = SA3.A3_COD"
		cQuery += "	 AND SA3.A3_FILIAL = '  '"
		cQuery += "	 AND SA3.A3_GRPREP IN (" + GETMV("MV_EISGEVE") + ") "
		cQuery += "	 AND SA3.D_E_L_E_T_  = ' '	"
	ENDIF

	IF MV_PAR01 == 4 //DIRETOR

	ELSE
		cQuery += " 		  		GROUP BY SCT.CT_VEND "
		cQuery += "           	ORDER BY SCT.CT_VEND "
	ENDIF

	MEMOWRIT("C:\SQLSIGA\FMARCA_METAgeral.TXT", cQUERY)

	cQuery       := ChangeQuery(cQuery)
	TCQUERY cQuery NEW ALIAS "META"

	aMetGeral := {}
	DO WHILE META->(!EOF())
		AADD(aMetGeral, {META->VEND,META->META})

		META->(DBSKIP())
	ENDDO

	META->(DBCloseArea())

Return


//------------------------------------------------------------------------------------//
Static FUNCTION cabecIMD(cTitulo,cCabec1,cCabec2,cNomPrg,nTamanho,nChar,aCustomText,lPerg)
	Local nLin    := 0
	Local xStr    := 0
	Local nCont   := 0
	Local nI      := 0
	Local nRecuo  := 20
	Local lWin    := .f.
	Local aDriver := ReadDriver()
	Local nRow
	Local nCol
	Local cAlias
	Local nLargura
	Local cVar
	Local uVar
	Local cPicture

	Local INICABEC:=Chr(27)+Chr(01)+Chr(01)
	Local FIMCABEC:=Chr(27)+Chr(01)+Chr(02)
	Local INIFIELD:=Chr(27)+Chr(02)+Chr(01)
	Local FIMFIELD:=Chr(27)+Chr(02)+Chr(02)
	Local IMP_DISCO:= 1
	Local IMP_SPOOL:= 2


	Local lFirst := .t.


	Default aCustomText := Nil // Parâmetro que se passado suprime o texto padrao desta função por outro customizado

	If lPerg == Nil
		lPerg := If(GetMv("MV_IMPSX1") == "S" ,.T.,.F.)
	Endif

	cNomPrg := Alltrim(cNomPrg)

	Private cSuf:=""

//DEFAULT lFirst := .t.
	If TYPE("__DRIVER") == "C"
		If "DEFAULT"$__DRIVER
			lWin := .t.
		EndIf
	EndIf

	nLargura:=Iif(nTamanho=="P",80,Iif(nTamanho=="G",220,132))
	cTitulo :=Iif(TYPE("NewHead")!="U",NewHead,cTitulo)

	IF aReturn[5] == IMP_DISCO
		lWin := .f.    // Se eh disco , nao eh windows
	Endif

	If lFirst
		nRow := PRow()
		nCol := PCol()
		SetPrc(0,0)
	// Caso seja 80 colunas, sempre imprime Retrato, 220 Coluna sempre imrime Paisagem, já 132 colunas pode imprimir das duas maneiras
		If aReturn[5] <> IMP_SPOOL // Se não for via Windows manda os caracteres para setar a impressora
			If nChar == NIL .and. !lWin .and. __cInternet == Nil
				@ 0,0 PSAY &(If(nTamanho=="P",aDriver[1],If(nTamanho=="G",aDriver[5],(If(aReturn[4]=1,aDriver[3],aDriver[4])))))
			ElseIf !lWin .and. __cInternet == Nil
				If nChar == 15
					@ 0,0 PSAY &(If(nTamanho=="P",aDriver[1],If(nTamanho=="G",aDriver[5],(If(aReturn[4]=1,aDriver[3],aDriver[4])))))
				Else
					@ 0,0 PSAY &(If(nTamanho=="P",aDriver[2],If(nTamanho=="G",aDriver[6],aDriver[4])))
				EndIf
			EndIf
		EndIF
		If GetMV("MV_CANSALT",,.T.) // Saltar uma página na impressão
			If GetMv("MV_SALTPAG",,"S") != "N"
				Setprc(nRow,nCol)
			EndIf
		Endif
	EndIf

// Impressão da lista de parâmetros quando solicitada
	If Type("cPerg")!="U" .and. lPerg .and. Substr(cAcesso,101,1) == "S"
		If lFirst
		// Imprime o cabeçalho padrão
			nLin := QSendCab(lWin, nLargura, cNomPrg, RptParam+" - "+Alltrim(cTitulo), "", "", .F.)

			cAlias := Alias()
			DbSelectArea("SX1")
			DbSeek(cPerg)
			@ nLin+=2, 5 PSAY INIPARAM
			While !EOF() .AND. X1_GRUPO = cPerg
				cVar := "MV_PAR"+StrZero(Val(X1_ORDEM),2,0)
				@(nLin+=2),5 PSAY INIFIELD+RptPerg+" "+ X1_ORDEM + " : "+ AllTrim(X1Pergunt())+FIMFIELD
				If X1_GSC == "C"
					xStr:=StrZero(&cVar,2)
					If ( &(cVar)==1 )
						@ nLin,Pcol()+3 PSAY INIFIELD+X1Def01()+FIMFIELD
					ElseIf ( &(cVar)==2 )
						@ nLin,Pcol()+3 PSAY INIFIELD+X1Def02()+FIMFIELD
					ElseIf ( &(cVar)==3 )
						@ nLin,Pcol()+3 PSAY INIFIELD+X1Def03()+FIMFIELD
					ElseIf ( &(cVar)==4 )
						@ nLin,Pcol()+3 PSAY INIFIELD+X1Def04()+FIMFIELD
					ElseIf ( &(cVar)==5 )
						@ nLin,Pcol()+3 PSAY INIFIELD+X1Def05()+FIMFIELD
					Else
						@ nLin,Pcol()+3 PSAY INIFIELD+''+FIMFIELD
					EndIf
				Else
					uVar := &(cVar)
					If ValType(uVar) == "N"
						cPicture:= "@E "+Replicate("9",X1_TAMANHO-X1_DECIMAL-1)
						If( X1_DECIMAL>0 )
							cPicture+="."+Replicate("9",X1_DECIMAL)
						Else
							cPicture+="9"
						EndIf
						@nLin,Pcol()+3 PSAY INIFIELD+Transform(Alltrim(Str(uVar)),cPicture)+FIMFIELD
					Elseif ValType(uVar) == "D"
						@nLin,Pcol()+3 PSAY INIFIELD+DTOC(uVar)+FIMFIELD
					Else
						@nLin,Pcol()+3 PSAY INIFIELD+uVar+FIMFIELD
					EndIf
				EndIf
				DbSkip()
			End

			cFiltro := Iif (!Empty(aReturn[7]),MontDescr(cAlias,aReturn[7]),"")
			nCont := 1
			If !Empty(cFiltro)
				@(nLin+=2),5  PSAY  OemtoAnsi("Filtro      : ") + Substr(cFiltro,nCont,nLargura-19)  // "Filtro      : "
				While Len(AllTrim(Substr(cFiltro,nCont))) > (nLargura-19)
					nCont += nLargura - 19
					@(nLin+=1),19	PSAY	Substr(cFiltro,nCont,nLargura-19)
				End
				nLin++
			EndIf
			@(++nLin),00  PSAY REPLI("*",nLargura)+FIMPARAM
			DbSelectArea(cAlias)
		EndIf
	EndIf

//////////// Imprime Cabecalho
	nLin:=0

	@nLin,0 PSAY INICABEC //Token para identificar o inicio de uma cabec
	nLin++
	@nLin,0 PSAY Iif(!lWin,Chr(13),"")+REPLI("*",nLargura)

// Nome da Empresa
//@(++nLin), 0 PSAY "*"+INIFIELD+AllTrim(SM0->M0_NOME)+If(ExistFilial()," / "+AllTrim(SM0->M0_FILIAL),"")+FIMFIELD
	@(++nLin), 0 PSAY "*"+INIFIELD+"IMDEPA - Relatório Foco Marca via Workflow"+FIMFIELD
// Folha
	If __SetCentury()
		nRecuo := 20
	else
		nRecuo := 18
	endif

	@nLin,nLargura-nRecuo  PSAY INIFIELD+RptFolha+" "+TRANSFORM(m_pag,'999999')+FIMFIELD
	@nLin,nLargura-1	 PSAY "*"

// Versão
	@(++nLin), 0 PSAY "*"+INIFIELD+"IMDEPA /"+cNomPrg+"/v."+cVersao+FIMFIELD

// Título do relatório
	@nLin,(xStr:=(Len(cNomPrg)+Len(cVersao)+10)) PSAY INIFIELD+PADC(Trim(cTitulo),nLargura-xStr-nRecuo)+FIMFIELD
	@nLin,(nLargura - (Len(RptDtRef+" "+DTOC(dDataBase)))-1) PSAY INIFIELD+RptDtRef+" "+DTOC(dDataBase)+FIMFIELD

	@nLin,nLargura-1	 PSAY "*"

// Hora da emissão
	@(++nLin),0 PSAY "*"+INIFIELD+RptHora+" "+time()+FIMFIELD

// Data de emissão
	@nLin,nLargura-nRecuo PSAY INIFIELD+RptEmiss+" "+DToC(MsDate())+FIMFIELD

	@nLin,nLargura-1	 PSAY "*"
	LI:=6

	If aCustomText == Nil // Imprime o cabeçalho padrão dos relatórios
		If LEN(Trim(cCabec1)) != 0
			LI:=8
			@(++nLin),00 PSAY REPLICATE("*",nLargura)
			@(++nLin),00 PSAY INIFIELD+cCabec1+FIMFIELD

			If LEN(Trim(cCabec2)) != 0
				@(++nLin),00  PSAY INIFIELD+cCabec2+FIMFIELD
				LI:=9
			EndIf
			@(++nLin),00  PSAY REPLICATE("*",nLargura)
		Endif
		@nLin,0 PSAY FIMCABEC //Token para identificar o final de uma cabec
	Else
		@++nLin,0 PSAY FIMCABEC //Token para identificar o final de uma cabec
		@(++nLin),00  PSAY REPLICATE("*",nLargura)
		For nI := 1 to Len(aCustomText)
			@(++nLin),0 PSAY aCustomText[nI]
		Next nI
		LI := Len(aCustomText)+8
		@(++nLin),00  PSAY REPLICATE("*",nLargura)
	EndIf

	m_pag++
	lFirst := .f.
	If Subs(__cLogSiga,4,1) == "S"
		__LogPages()
	EndIf

Return nLin


//------------------------------------------------------------------------------------//
Static Function ExistFilial()
	Local cAlias := Alias()
	Local nRecno, lRet := .f.
	Local cCodigo

	DbSelectArea("SM0")
	cCodigo := M0_CODIGO
	nRecno := Recno()
	DbSeek(cCodigo)
	DbSkip()
	If M0_CODIGO == cCodigo
		lRet := .t.
	EndIf
	DbGoTo(nRecno)
	DbSelectArea(cAlias)
Return lRet


