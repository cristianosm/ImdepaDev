#INCLUDE 'RWMAKE.CH'

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ M440FIL     ³ Autor ³ Marcio Q. Borges   ³ Data ³ 07/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ponto de entrada p/  filtro dos pedidos na tela de         ³±±
±±³          ³ liberacao de pedidos. Uso para filtro de alcadas.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_M440FIL()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet -> Retorna uma string com os Pedidos para mostrar     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jorge Oliveria³26/04/11³Ajustes para Projeto Carta Negocios            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
*****************************************************************************
User Function M440FIL()
*****************************************************************************

	Local cFiltro_    := "  "
	Local aLibPedTrf  := {}
	Local cCliImdepa  := GetMV('MV_IMDEPA')

	//Cristiano
	Local cMarc 		:= ""

	// Jorge Oliveira - 28/02/2011 - Indica se a Filial atual, trabalha com as Liberacao Comercial utilizando Carta de Negocio
	Local lCartLib    := IIF( Upper( SuperGetMV( "MV_CARTLIB",, "N" ) ) == "S", .T., .F. )
	Local cPedLib     := ''

	cUsuarioLib := AllTrim(SubStr(cusuario,7,15))
	cCodUsuLib  := RetCodUsr(Upper(AllTrim(SubStr(cUsuario,7,15))))

	DbSelectArea('SA3')
	DbSetOrder(7)

	If !DbSeek(xFilial('SA3')+cCodUsuLib)
		MsgBox('Usuario sem permissao para liberacao')
		cFiltro_ += " C5_NUM  = ' ' "
		Return( cFiltro_ )

	Endif

	cCodVend 		:= SA3->A3_COD
	cDiretores  	:= GETMV("MV_DIRETOR")
	aLibPedTrf  	:= GETMV("MV_USLIMDE")

	If cCodUsuLib $  aLibPedTrf
		//Alert("Lib Tranf")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄcias\¿
		//³Inserido por  Edivaldo Gonçalves Cordeiro em 08/12/2005                                    ³Ä
		//³Usuário Conectado possui permissão para Visualizar apenas os Pedidos de Transferências³    Ä
		//³Estes usuarios estão Setados no Parâmetro : MV_USLIMDE                                    ³Ä
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄcias\Ù
		//Devolvo o Filtro com os Pedidos de Liberação de Transferência , baseado no usuario conectado X Parâmetro MV_USLIMDE

		cFiltro_ := "C5_FILIAL == '"+XFILIAL('SC5')+"' .AND. C5_CLIENTE == '"+cCliImdepa+"' .AND. C5_LIBEROK <> 'S'"

	Else //Entra Rotina de Alcada de Vendas

		If cCodVend $ cDiretores // Temporario. Para testar diretores
		//Alert("Lib Diretor")
			cFiltro_ := "C5_LIBEROK <> 'S' .AND. C5_NOTA == Space(09)"
		//Alert("Lib Dir")
		//C	cQuery := "  SELECT C5_NUM "
		//C	cQuery += " FROM "+ RetSqlName( 'SC5' ) + " SC5 "
		//C	cQuery += " WHERE C5_FILIAL = '"+xFilial('SC5')+"' AND "
		//C	cQuery += " C5_NOTA = ' ' AND "  //So os que nao foram FINALIZADOS
		//C	cQuery += " C5_LIBEROK <> 'S' AND " //So os que nao estao liberados
		//C	cQuery += " SC5.D_E_L_E_T_ = ' ' "
		//C
		//C	cQuery := ChangeQuery(cQuery)
		//C	dbUseArea( .T., 'TOPCONN', TCGenQry(,, cQuery ), 'SC5TMP', .T., .T. )
		//C
		//C	cPedLib := ' '
		//C	DbSelectArea('SC5TMP')
		//C	//DbGoTop()
		//C
		//C	//CWhile SC5TMP->(!Eof())
		//C	//C	cnumSC5 := SC5TMP->C5_NUM
		//C	//C	cPedLib += cnumSC5 + "/"
		//C	//C
		//C	//C	SC5TMP->(DBSKIP())
		//C	//CEnd
		//C
		//C	//C SC5TMP->(dbCloseArea())
		//C	//C cFiltro_ += " C5_NUM  $ '"+cPedLib+"' "
		//C
		//C	IF LEN(cFiltro_) >= 2000 // Limite de 2000 bytes = 2000 caracteres
		//C		cFiltro_ :=  " C5_LIBEROK <> 'S' .AND. C5_NOTA = ' '"
		//C	ENDIF

		Else
			//Alert("Lib Gerente")
			//cCodVend := '000541'

			// Jean Rehermann - 22/09/2009 - Pesquisa se vendedor pode efetuar liberações como gerente (AAZQQM)
			//_aArea := GetArea()
			//DbSelectArea('SX5')

			If SX5->( DbSeek( xFilial('SX5') +'75'+ SA3->A3_GEREN ) )
				cVendGestor := SX5->X5_DESCRI + SX5->X5_DESCSPA + SX5->X5_DESCENG
				If ( cCodVend $ cVendGestor )
					cCodVend := SA3->A3_GEREN  // Se estou cadastrado como gestor, altero meu código de vendedor para o código do meu gerente.
				EndIf
			EndIf
			//RestArea( _aArea )
			// Jean Rehermann - 22/09/2009

			// Jorge Oliveira - 28/02/2011 - Indica se a Filial atual, trabalha com as Liberacao Comercial utilizando Carta de Negocio
			If lCartLib
				//Alert("Lib Carta")
				cPedLib := BuscaCarta( cCodVend )
			Else
				//Alert("Lib Ger")

				cQuery := "SELECT C6_NUM, C6_PRODUTO,  C6_DESCREA ,A3_ALC_DESC "
				cQuery += "  FROM " + RetSqlName( 'SC6' ) + " SC6, "
				cQuery +=   		    RetSqlName( 'SC5' ) + " SC5, "
				cQuery +=   		    RetSqlName( 'SA1' ) + " SA1, "
				cQuery +=   	"( SELECT B1_COD,B1_ALCDESC,A3_ALCDESC,A3_ALCDES2, DECODE( B1_ALCDESC  ,'1', A3_ALCDESC, A3_ALCDES2 )  A3_ALC_DESC"
				cQuery +=		"	  FROM " + RetSqlName( 'SB1' ) + " B1, " + RetSqlName( 'SA3' ) + " A3 "
				cQuery +=		"	 WHERE B1_FILIAL = '05' AND "
				cQuery +=		"	  		 B1.D_E_L_E_T_ <> '*' AND"
				cQuery +=		"			 A3_COD = '" + cCodVend + "' AND "
				cQuery +=		"			 A3.D_E_L_E_T_ <> '*'  ORDER BY B1_COD) SB1 "
				cQuery += " WHERE C6_FILIAL = '"+xFilial('SC6')+"' AND "
				cQuery += " C6_CLI  = A1_COD AND "
				cQuery += " C6_LOJA = A1_LOJA AND "
				cQuery += " C6_FILIAL = C5_FILIAL AND "
				cQuery += " C6_NUM  = C5_NUM AND "
				cQuery += " C5_NOTA = ' ' AND "  //SÓ OS QUE NÃO FORAM FINALIZADOS
				cQuery += " C5_LIBEROK <> 'S' AND " //SÓ OS QUE NÃO ESTÃO LIBERADOS
				cQuery += " C6_PRODUTO = B1_COD AND "
				cQuery += " A1_FILIAL = '"+xFilial('SA1')+"' AND "
				//cQuery += " A1_VENDEXT||A1_VEND||A1_VENDCOO||A1_CHEFVEN||A1_GERVEN LIKE '%"+cCodVend+"%' AND " // ALTERADO ESTA LINHA EM FUNÇÃO DE PERFORMANCE E CRIADO INDICE NO SC5
				cQuery += " (A1_VENDEXT = '"+cCodVend+"' OR  A1_VEND = '"+cCodVend+"' OR A1_VENDCOO = '"+cCodVend+"' OR A1_CHEFVEN = '"+cCodVend+"' OR A1_GERVEN = '"+cCodVend+"' ) AND "
				cQuery += " SC6.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ' "
				cQuery += "  GROUP BY C6_NUM,C6_PRODUTO,C6_DESCREA, A3_ALC_DESC "
				cQuery += "  ORDER BY C6_NUM,C6_PRODUTO "

				//cQuery := ChangeQuery(cQuery)

				//memowrit( "M440FIL.txt", cQuery )

				//dbUseArea( .T., 'TOPCONN', TCGenQry(,, cQuery ), 'SC6TMP', .T., .T. )

				U_ExecMySql( cQuery, "SC6TMP" , "Q" , .F. )

				TCSetField( 'SC6TMP', 'C6_DESCREA'   , 'N', 5, 2 )
				TCSetField( 'SC6TMP', 'A3_ALC_DESC'  , 'N', 5, 2 )

				cPedLib 	:= ""
				lflag		:= .T.
				//
				//DbGoTop()

				DbSelectArea('SC6TMP')
				cNumAnt := SC6TMP->C6_NUM
				While !Eof()

					While cNumAnt = SC6TMP->C6_NUM .And. !EOF()

						If SC6TMP->C6_DESCREA > SC6TMP->A3_ALC_DESC //  EXLUI DOS ITENS QUE FAZEM PARTE DO FILTRO SE DESCONTO REAL
							lflag := .F.						// 	FOR MAIOR QUE A ALÇADA
						Endif

						cNumAnt := SC6TMP->C6_NUM

						DbSkip()

					End

					IF lflag .And. !Empty(cNumAnt)
						//Cristiano
						//cPedLib += cnumant + "/"
						cPedLib += cnumant + "','"

					EndIF

					lflag := .T.
					cNumAnt := SC6TMP->C6_NUM

				End

				SC6TMP->( DbCloseArea() )
			EndIf



			// Marca os Pedido para Filtro posterior...
			cMarc 	:= Upper(GetMark( .F., "SC5" ,  "C5_OK" ))

			//Alert("Marca : "+ cMarc)
			cUpd 	:= "Update SC5010 Set C5_OK = '"+cMarc+"' Where C5_Filial = '"+xFilial('SC5')+"' and C5_LIBEROK <> 'S' and c5_num in ('"+cPedLib+"') and d_e_l_e_t_ = ' ' "
			U_ExecMySql( cUpd , "" , "E" , .F. )

			//cFiltro_ += " .AND. C5_NUM  $ '"+cPedLib+"' "
			//cFiltro_ += " C5_OK == '"+cMarc+"' "

			cFiltro_ := "C5_FILIAL == '"+XFILIAL('SC5')+"' .AND. C5_OK == '"+cMarc+"' .AND. C5_LIBEROK <> 'S' .AND. C5_NOTA == Space(09)"

		Endif
	Endif
//Alert("Filtro: "+cFiltro_)
Return( cFiltro_ )


	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ BuscaCarta  ³ Autor ³ Jorge Oliveira     ³ Data ³ 26/04/11 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³ Busca as cartas para comparar com os Pedidos               ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ BuscaCarta()                                               ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ NIL                                                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ cRet -> Retorna uma string com os Pedidos para mostrar     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Faturamento                                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ PROGRAMADOR  ³ DATA   ³ DESCRICAO                                     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³              ³        ³                                               ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	/*/
Static Function BuscaCarta( cCodVend )

	Local cQuery   := ""
	Local cRet     := ""
	Local aArea    := GetArea()
	Local aAreaSA3 := SA3->( GetArea() )

	DbSelectArea( "SA3" )
	DbSetOrder(1)
	If SA3->( DbSeek( xFilial( "SA3" ) + cCodVend ) )

		cQuery := "SELECT DISTINCT SC5.C5_NUM "
		cQuery += "  FROM " + RetSqlName( 'SC5' ) + " SC5 "
		cQuery += "     , " + RetSqlName( 'SA1' ) + " SA1 "
		cQuery += " WHERE SC5.C5_FILIAL = '"+xFilial('SC5')+"' "
		cQuery += "   AND SA1.A1_FILIAL = '"+xFilial('SA1')+"' "
		cQuery += "   AND SC5.C5_CLIENTE = SA1.A1_COD "
		cQuery += "   AND SC5.C5_LOJAENT = SA1.A1_LOJA "
		cQuery += "   AND SC5.C5_NOTA = ' ' "     //So os que nao tem NF emitida
		cQuery += "   AND SC5.C5_LIBEROK <> 'S' " //So os que nao estao liberados
		cQuery += "   AND ( SA1.A1_VENDEXT = '"+cCodVend+"' "
		cQuery += "    OR   SA1.A1_VEND    = '"+cCodVend+"' "
		cQuery += "    OR   SA1.A1_VENDCOO = '"+cCodVend+"' "
		cQuery += "    OR   SA1.A1_CHEFVEN = '"+cCodVend+"' "
		cQuery += "    OR   SA1.A1_GERVEN  = '"+cCodVend+"' ) "
		cQuery += "   AND SC5.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY SC5.C5_NUM "

		//cQuery := ChangeQuery(cQuery)
		//memowrit( "M440FIL_BuscaCarta.txt", cQuery )

		//dbUseArea( .T., 'TOPCONN', TCGenQry(,, cQuery ), 'QRY_PED', .T., .T. )

		U_ExecMySql( cQuery , "QRY_PED"	, "Q" , .F. )

		DbSelectArea('QRY_PED')
		While QRY_PED->( !EOF() )

			//cRISTIANO
			//cRet += QRY_PED->C5_NUM + "/"
			If !Empty(QRY_PED->C5_NUM)
				cRet += QRY_PED->C5_NUM + "','"
			EndIF

			QRY_PED->( DbSkip() )
		EndDo
		dbCloseArea()

	EndIf

	RestArea( aAreaSA3 )
	RestArea( aArea    )

Return( cRet )
