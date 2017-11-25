/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MBRWBTN  ³ Autor ³ Luciano Correa        ³ Data ³ 02/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Ponto de Entrada para controlar um botao pressionado na    ³±±
±±³          ³ MBROWSE. Sera acessado em qualquer programa que utilize    ³±±
±±³          ³ esta funcao.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Enviado ao Ponto de Entrada um vetor com 3 informacoes:    ³±±
±±³          ³ PARAMIXB[1] = Alias atual;                                 ³±±
±±³          ³ PARAMIXB[2] = Registro atual;                              ³±±
±±³          ³ PARAMIXB[3] = Numero da opcao selecionada                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Se retornar .T. executa a funcao relacionada ao botao.     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MBrwBtn()


Local nRec_SM0, lRet := .t.
Local cFunName := FunName()


If cFunName == 'MATA010'		// cadastro de produtos...
	
	If ParamIxb[ 3 ] == 3 .or. ParamIxb[ 3 ] == 7		// opcao incluir ou copia
		
		If ( cEmpAnt == '01' .and. cFilAnt <> '05' ) .or. ( cEmpAnt == '51' .and. cFilAnt <> '12' )
			
			nRec_SM0 := SM0->( RecNo() )
			
			SM0->( dbSeek( cEmpAnt + If( cEmpAnt == '01', '05', '12' ), .f. ) )
			
			MsgStop( 'Utilize a filial ' + AllTrim( SM0->M0_FILIAL ) + ' para incluir produtos !' )
			lRet := .f.
			
			SM0->( dbGoTo( nRec_SM0 ) )
		EndIf
	EndIf
	
ElseIf cFunName == 'EICPO400'		// consulta/manutencao purchase order...
	
	If ParamIxb[ 3 ] >= 4 .and. ParamIxb[ 3 ] <= 6	// opcoes alterar, estornar ou cancelar...
		
		If SW2->( FieldPos( 'W2_FILREC' ) ) <> 0
			
			If !Empty( SW2->W2_FILREC ) .and. SW2->W2_FILREC <> cFilAnt
				
				MsgStop( 'Este PO só poderá ser alterado na filial ' + SW2->W2_FILREC + ' !', cCadastro )
				lRet := .f.
			EndIf
		EndIf
	EndIf
	
ElseIf cFunName == 'MATA110'		// manutencao de solicitacao compras...
	
	If ParamIxb[ 3 ] == 4 .or. ParamIxb[ 3 ] == 6	// opcoes alterar ou excluir...
		
		If !Empty( SC1->C1_MSFIL ) .and. SC1->C1_MSFIL <> cFilAnt
			
			MsgStop( 'Esta SC só poderá ser alterada na filial ' + SC1->C1_MSFIL + ' !', cCadastro )
			lRet := .f.
		EndIf
	EndIf

ElseIf cFunName == 'TMKA310'		// manutencao de campanha

	If ParamIxb[ 3 ] == 4 .or. ParamIxb[ 3 ] == 5	// opcoes alterar ou excluir...
		
		If dDataBase >= SUO->UO_DTINI .and. dDataBase <= SUO->UO_DTFIM
			
//			MsgStop( 'Esta campanha já está em andamento, não deve ser alterada !', cCadastro )
			MsgStop( 'Esta campanha já está em andamento, não deve ser alterada !', "Manutencao de Campanha" )


//			lRet := .f.
		EndIf
	EndIf	
	
EndIf

Return( lRet )
