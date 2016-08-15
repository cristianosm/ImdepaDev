#Include "Protheus.ch"

#DEFINE POS_MARCADO	  		1
#DEFINE POS_FILIAL	  		2
#DEFINE POS_CLIENTE	  		3
#DEFINE POS_LOJA	  		4
#DEFINE POS_NUMORC	  		5
#DEFINE POS_PRODUTO	  		6
#DEFINE POS_DESC	  		7
#DEFINE POS_QUANTD	  		8
#DEFINE POS_QUANTD_ORIG		9
#DEFINE POS_QOFERT	   		10
#DEFINE POS_QOFERT_ORIG		11
#DEFINE POS_VOFERT			12
#DEFINE POS_VOFERT_ORIG		13
#DEFINE POS_DATAHORA		14
#DEFINE POS_PRECO			15
#DEFINE POS_RECNO			16

/*/
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
HH?Programa  : IMDA630     ? Autor ?Jorge Oliveira      ? Data ? 18/08/10 HH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH?JHH
HH?DescriHHo : Ajustar as quantidades do Orcado X Ofertado.               HH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH?JHH
HH?Sintaxe   : U_IMDA630()                                                HH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH?JHH
HH?Parametros: Nenhum                                                     HH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH?JHH
HH?Retorno   : NIL                                                        HH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH?JHH
HH?Uso       : Call Center                                                HH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH?JHH
HH? ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     HH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH?JHH
HH? PROGRAMADOR  | DATA   | DESCRICAO                                     HH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH?JHH
HH?              |        |                                               HH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
/*/

*******************************************************************************
User Function IMDA630()
*******************************************************************************

	Private oDlg, oDlg1, oLbx, oCombo
	Private oOk      	:= Loadbitmap( GetResources(), 'LBOK' )
	Private oNo      	:= Loadbitmap( GetResources(), 'LBNO' )
	Private aDados		:= {}
	Private aPerg		:= {}
	Private aCombo		:= {}
	Private cFiltro		:= ""
	Private cCombo		:= "Cliente"
	Private cHora		:= Space( 4 )
	Private cPerg		:= "IMDA63"
	Private dEntrega	:= CtoD( "" )
	Private nNumPed		:= 0
	Private nTotPes		:= 0

	X1Pergunta()

	If !Pergunte( cPerg, .T. )
		Return()
	EndIf

	If MV_PAR10 < MV_PAR09
		Alert("Periodo Invalido")
		Return()
	Endif

	aAdd( aCombo, "Cliente"   	)
	aAdd( aCombo, "Orcamento" 	)
	aAdd( aCombo, "Produto"   	)
	aAdd( aCombo, "Data"      )

	//| Consulta e carrega os dados no array utilizado na rotina.
	MsAguarde( {|| A630LEDADO() }, "Aguarde...", "Consultando registros..." )


	If Len( aDados ) == 0
		Aviso( "Orcado X Ofertado", "O Filtro nao Retornou Dados", {"Ok"} )
		Return()
	Endif

	// Monta Janela Principal...
	JanelaPrincipal()

Return()
*****************************************************************************************
Static Function JanelaPrincipal()
*****************************************************************************************

	DEFINE MSDIALOG oDlg TITLE "Orcado X Ofertado" FROM 000,000 TO 500,900 PIXEL

	@ 005,005 LISTBOX oLbx FIELDS HEADER ;
		""                   , OemToAnsi("Filial"), OemToAnsi("Cliente"), OemToAnsi("Orcamento"),;
		OemToAnsi("Produto"), OemToAnsi("Qtde. Orcado"), OemToAnsi("Qtde. Ofertado"),;
		OemToAnsi("Valor Ofertado"), OemToAnsi("Data / Hora" ), OemToAnsi("Preco");
		SIZE 442,210 of oDlg PIXEL ON DBLCLICK( A630MARCA( oLbx:nAt ) )

	oLbx:SetArray( aDados )
	oLbx:bLine := {|| {IIF(aDados[ oLbx:nAt, POS_MARCADO ], oOk, oNo),;
		aDados[ oLbx:nAt, POS_FILIAL ],;
		AllTrim( aDados[ oLbx:nAt, POS_CLIENTE ] + " - " + aDados[ oLbx:nAt, POS_LOJA ] ),;
		aDados[ oLbx:nAt, POS_NUMORC ],;
		AllTrim( AllTrim( aDados[ oLbx:nAt, POS_PRODUTO ] ) + " - " + aDados[ oLbx:nAt, POS_DESC ] ),;
		AllTrim( Transform( aDados[ oLbx:nAt, POS_QUANTD ], "@R 99999" ) ),;
		AllTrim( Transform( aDados[ oLbx:nAt, POS_QOFERT ], "@R 99999" ) ),;
		AllTrim( Transform( aDados[ oLbx:nAt, POS_VOFERT ], "@R 9,999,999.99" ) ),;
		AllTrim( Transform( aDados[ oLbx:nAt, POS_DATAHORA ], "@R 99/99/99 99:99" ) ),;
		AllTrim( Transform( aDados[ oLbx:nAt, POS_PRECO ], "@R 9,999,999.99" ) ) }}

	@ 222,005 SAY "Ordenacao:"             SIZE  65, 8 PIXEL OF oDlg
	@ 220,035 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 55,10 PIXEL OF oDlg ON CHANGE A630TELA()

	@ 220,355 BUTTON "&Gravar"	SIZE 40,13 ACTION {|| Grava(), oDlg:End() }	PIXEL Of oDlg
	@ 220,400 BUTTON "&Sair"		SIZE 40,13 ACTION {|| oDlg:End() }				PIXEL Of oDlg

	ACTIVATE MSDIALOG oDlg CENTER

Return()
*****************************************************************************************
Static Function A630MARCA( nPos )
*****************************************************************************************

	Local oButton1
	Local oButton2
	Local oQuant
	Local nQuant := aDados[ nPos, POS_QUANTD ]
	Local oOfert
	Local nOfert := aDados[ nPos, POS_QOFERT ]
	Local oSay1
	Local oSay2
	Local lAtualiza := .F.

	aDados[ nPos, POS_MARCADO ] := !aDados[ nPos, POS_MARCADO ]

	If aDados[ nPos, POS_MARCADO ]

		DEFINE MSDIALOG oDlg1 TITLE "Alteracao" FROM 000, 000  TO 150, 150 PIXEL

		@ 010, 025 SAY oSay1 		PROMPT "Quantidade:"	SIZE 036, 008 PIXEL OF oDlg1
		@ 025, 015 MSGET oQuant VAR nQuant Picture "@E 999,999,999" Valid nQuant > 0	SIZE 050, 010 PIXEL OF oDlg1

//		@ 053, 029 SAY oSay2 		PROMPT "Ofertado:"		SIZE 036, 008 PIXEL OF oDlg1
//		@ 051, 075 MSGET oOfert VAR nOfert 					SIZE 058, 010 READONLY PIXEL OF oDlg1

		@ 050, 005 BUTTON oButton1 PROMPT "Confirma" 		SIZE 030, 012 ACTION {|| lAtualiza := .T., oDlg1:End() } 	PIXEL OF oDlg1
		@ 050, 041 BUTTON oButton2 PROMPT "Cancela" 			SIZE 030, 012 ACTION {|| oDlg1:End() } 						PIXEL OF oDlg1

		ACTIVATE MSDIALOG oDlg1 CENTERED

		If lAtualiza .And. nQuant <> aDados[ nPos, POS_QUANTD ]
			aDados[ nPos, POS_QUANTD ] := nQuant

		//	If nQuant < aDados[ nPos, POS_QOFERT ]
		//		aDados[ nPos, POS_QOFERT ] := nQuant
		//	EndIf

		//	aDados[ nPos, POS_VOFERT ] := aDados[ nPos, POS_QOFERT ] * aDados[ nPos, POS_PRECO  ]
		EndIf

	Else

		// Caso tenha desmarcado, volta a quantidade original
		aDados[ nPos, POS_QUANTD ] := aDados[ nPos, POS_QUANTD_ORIG ]
		//aDados[ nPos, POS_QOFERT ] := aDados[ nPos, POS_QOFERT_ORIG ]
		//aDados[ nPos, POS_VOFERT ] := aDados[ nPos, POS_VOFERT_ORIG ]

	EndIf

	oLbx:Refresh()
	oLbx:SetFocus(.T.)

Return()
*******************************************************************************
Static Function A630TELA()//Ordenar os dados da tela conforme a selecao.
*******************************************************************************

	Do Case
	Case cCombo == "Cliente"
		ASort( aDados,,, {|x,y| x[POS_CLIENTE]+x[POS_DATAHORA]+x[POS_NUMORC] < y[POS_CLIENTE]+y[POS_DATAHORA]+y[POS_NUMORC] } )
	Case cCombo == "Orcamento"
		ASort( aDados,,, {|x,y| x[POS_NUMORC]+x[POS_DATAHORA] < y[POS_NUMORC]+y[POS_DATAHORA] } )
	Case cCombo == "Produto"
		ASort( aDados,,, {|x,y| x[POS_PRODUTO]+x[POS_NUMORC] < y[POS_PRODUTO]+y[POS_NUMORC] } )
	Case cCombo == "Data"
		ASort( aDados,,, {|x,y| x[POS_DATAHORA]+x[POS_NUMORC] < y[POS_DATAHORA]+y[POS_NUMORC] } )
	EndCase

	oLbx:nAt := 1
	oLbx:Refresh()
	oLbx:SetFocus(.T.)

Return()
*******************************************************************************
Static Function Grava()// Grava Dados..
*******************************************************************************
	Local nTotReg := 0
	Local nQtde   := 0
	Local _A63Atu := cFilAnt
	Local _FilA63 := cFilAnt

	aScan( aDados, {|x| If( x[ POS_MARCADO ], nQtde++, nQtde ) } )

	If nQtde <= 0
		MsgInfo( "Nao foram selecionados nenhum registro para alteracao." )
		Return
	EndIf

	If MsgYesNo( "Confirma a atualizacao do Orcado X Ofertado ?", "Atualizacao" )

		DbSelectArea( "ZA0" )

		For _i := 1 To Len( aDados )

			// Se o registro esta marcado para atualizar
			If aDados[ _i, POS_MARCADO ]

				// Posiciona na Filial de Origem do ORCAMENTO !!!
				If cFilAnt <> aDados[ _i, POS_FILIAL ]
					cFilAnt := aDados[ _i, POS_FILIAL ]
				EndIf

				ZA0->( DbGoTo( aDados[ _i, POS_RECNO ] ) )
				
				If RecLock( "ZA0", .F. )
					ZA0->ZA0_QUANTD := aDados[ _i, POS_QUANTD ]
//					ZA0->ZA0_QOFERT := aDados[ _i, POS_QOFERT ]
//					ZA0->ZA0_VOFERT := aDados[ _i, POS_VOFERT ]
					MsUnlock()
				Else
					MsgInfo( "Nao foi possivel alterar o Atendimento: " + aDados[ _i, POS_NUMORC ] )
					conout( "IMDA630 => Nao foi possivel alterar o Atendimento: " + aDados[ _i, POS_NUMORC ] )
				Endif

				// Volta para Filial onde o usuario estah no sistema
				If cFilAnt <> _A63Atu
					cFilAnt := _A63Atu
				EndIf

				aDados[ _i, POS_MARCADO ]  := .F.

				// Grava LOG
				DbSelectArea( "ZAJ" )
				If RecLock( "ZAJ", .T. )

					ZAJ->ZAJ_FILIAL		:= xFilial( "ZAJ" )
					ZAJ->ZAJ_FILORC		:= aDados[ _i, POS_FILIAL ]
					ZAJ->ZAJ_NUMORC		:= aDados[ _i, POS_NUMORC ]
					ZAJ->ZAJ_PRODUTO		:= aDados[ _i, POS_PRODUTO ]
					ZAJ->ZAJ_QTDORIG		:= aDados[ _i, POS_QUANTD_ORIG ]
					ZAJ->ZAJ_QUANT		:= aDados[ _i, POS_QUANTD ]
					ZAJ->ZAJ_QOFEOR		:= aDados[ _i, POS_QOFERT_ORIG ]
					ZAJ->ZAJ_QOFERT		:= aDados[ _i, POS_QOFERT ]
					ZAJ->ZAJ_VOFEOR		:= aDados[ _i, POS_VOFERT_ORIG ]
					ZAJ->ZAJ_VOFERT		:= aDados[ _i, POS_VOFERT ]
					ZAJ->ZAJ_USUARIO	:= SubStr( cUsuario, 7, 15 )
					ZAJ->ZAJ_DATA		:= dDataBase
					ZAJ->ZAJ_HORA		:= Time()

				Else
					MsgInfo( "Nao foi possovel gravar log do Atendimento: " + aDados[ _i, POS_NUMORC ] )
					conout( "IMDA630 => Nao foi possivel gravar log do Atendimento: " + aDados[ _i, POS_NUMORC ] )
				Endif

			Endif

		Next

		oLbx:Refresh()
		oLbx:SetFocus(.T.)

	EndIf

	cFilAnt := _A63Atu

Return
*******************************************************************************
Static Function A630LEDADO()//| Consulta e carrega os dados no array utilizado na rotina.
*******************************************************************************

	Local aEntrega := {}

	//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH?
	//? Monta a query                                                ?
	//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
	cQuery := "SELECT DISTINCT ZA0.ZA0_FILIAL, ZA0.ZA0_NUMORC, ZA0.ZA0_PRODUT, SB1.B1_DESC, ZA0.ZA0_QUANTD "
	cQuery += "     , ZA0.ZA0_QOFERT, ZA0.ZA0_VOFERT, ZA0.ZA0_DTNECL, ZA0.ZA0_HRNECL, ZA0.ZA0_PRECO "
	cQuery += "     , ZA0.R_E_C_N_O_ RECZA0, SUA.UA_CLIENTE, SUA.UA_LOJA "
	cQuery += "  FROM " + RetSqlName("ZA0") + " ZA0 "
	cQuery += "     , " + RetSqlName("SB1") + " SB1 "
	cQuery += "     , " + RetSqlName("SUA") + " SUA "
	cQuery += " WHERE ZA0.ZA0_FILIAL BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "' "
	cQuery += "   AND SUA.UA_FILIAL  = ZA0.ZA0_FILIAL "
	cQuery += "   AND ZA0.ZA0_PRODUT = SB1.B1_COD "
	cQuery += "   AND SUA.UA_NUM     = ZA0.ZA0_NUMORC "
	cQuery += "   AND SUA.UA_CLIENTE BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
	cQuery += "   AND SUA.UA_LOJA    BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
	cQuery += "   AND ZA0.ZA0_NUMORC BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "
	cQuery += "   AND ZA0.ZA0_PRODUT BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' "
	cQuery += "   AND ZA0.ZA0_DTNECL BETWEEN '" + DtoS( mv_par09 ) + "' AND '" + DtoS( mv_par10 ) + "' "
	cQuery += "   AND ZA0.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SUA.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY ZA0.ZA0_NUMORC, ZA0.ZA0_PRODUT "

	cQuery := ChangeQuery( 	cQuery )

	MEMOWRIT( "IMDA630.SQL", cQuery )

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY_ZA0",.F.,.T.)

	DbSelectArea( "QRY_ZA0" )
	DbGoTop( "QRY_ZA0" )

	// Preenche array com as notas fiscais
	aDados := {}
	While QRY_ZA0->( !Eof() )

		aAdd( aDados, {	.F.,;
			QRY_ZA0->ZA0_FILIAL,;
			QRY_ZA0->UA_CLIENTE,;
			QRY_ZA0->UA_LOJA,;
			QRY_ZA0->ZA0_NUMORC,;
			QRY_ZA0->ZA0_PRODUT,;
			QRY_ZA0->B1_DESC,;
			QRY_ZA0->ZA0_QUANTD,;	// Quantidade Digitada que serah recalculada
		QRY_ZA0->ZA0_QUANTD,;	// Quantidade Digitada Original
		QRY_ZA0->ZA0_QOFERT,;	// Quantidade Ofertada que serah recalculada
		QRY_ZA0->ZA0_QOFERT,;	// Quantidade Ofertada Original
		QRY_ZA0->ZA0_VOFERT,;	// Valor Ofertado que serah recalculada
		QRY_ZA0->ZA0_VOFERT,;	// Valor Ofertado Original
		DtoC( StoD( QRY_ZA0->ZA0_DTNECL ) ) + QRY_ZA0->ZA0_HRNECL,;
			QRY_ZA0->ZA0_PRECO,;
			QRY_ZA0->RECZA0;
			})

		QRY_ZA0->( DbSkip() )
	Enddo
	dbCloseArea( "QRY_ZA0" )

Return
*******************************************************************************
Static Function X1Pergunta()
*******************************************************************************

	cPerg := Pad( cPerg, Len( SX1->X1_GRUPO ) )

	aAdd(aPerg,{ "Do Cliente ?"   	,"Do Cliente ?"   ,"Do Cliente ?"   ,"mv_ch1","C", 6,0,0,"G",""		  ,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","" })
	aAdd(aPerg,{ "Ate Cliente ?"	,"Ate Cliente ?"  ,"Ate Cliente ?"  ,"mv_ch2","C", 6,0,0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","" })
	aAdd(aPerg,{ "Da Loja ?"   		,"Da Loja ?" 	  ,"Da Loja ?"      ,"mv_ch3","C", 2,0,0,"G",""		  ,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","" })
	aAdd(aPerg,{ "Ate Loja ?"		,"Ate Loja ?" 	  ,"Ate Loja ?"     ,"mv_ch4","C", 2,0,0,"G","NaoVazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","" })
	aAdd(aPerg,{ "Do Or?amento ?"	,"Do Or?amento ?" ,"Do Or?amento ?" ,"mv_ch5","C", 6,0,0,"G",""		  ,"mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","" })
	aAdd(aPerg,{ "Ate Or?amento ?"	,"Ate Or?amento ?","Ate Or?amento ?","mv_ch6","C", 6,0,0,"G","NaoVazio()","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","" })
	aAdd(aPerg,{ "Do Produto ?"		,"Do Produto ?"   ,"Do Produto ?"   ,"mv_ch7","C",14,0,0,"G",""		  ,"mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","" })
	aAdd(aPerg,{ "Ate Produto ?"	,"Ate Produto ?"  ,"Ate Produto ?"  ,"mv_ch8","C",14,0,0,"G","NaoVazio()","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","" })
	aAdd(aPerg,{ "Da Consulta ?"	,"Da Consulta ?"  ,"Da Consulta ?"  ,"mv_ch9","D", 8,0,0,"G",""		  ,"mv_par09","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","" })
	aAdd(aPerg,{ "Ate Consulta ?"	,"Ate Consulta ?" ,"Ate Consulta ?" ,"mv_chA","D", 8,0,0,"G",""		  ,"mv_par10","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"","" })
	aAdd(aPerg,{ "Da Filial ?"		,"Da Filial ?"	  ,"Da Filial ?"	,"mv_chB","C", 2,0,0,"G",""			  ,"mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","" })
	aAdd(aPerg,{ "Ate Filial ?"		,"Ate Filial ?"	  ,"Ate Filial ?"	,"mv_chC","C", 2,0,0,"G","NaoVazio()","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","" })

	AjustaSx1( cPerg, aPerg )

Return()