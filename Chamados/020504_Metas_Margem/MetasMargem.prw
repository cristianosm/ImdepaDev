
#Include 'Totvs.ch'
#Include "Tbiconn.ch"

#Define _PRI 1 
#Define _ULT 0

//| Hash Table Principal
#Define P_NGE 'N' //| Nome Gerente 
#Define P_CGE 'C' //| Codigo Gerente
#Define P_TIP 'T' //| Tipo 
#Define P_GRU 'G' //| Grupo
#Define P_DES 'D' //| Descricao
#Define P_VAL 'V' //| Valor
#Define P_PER 'P' //| Percentual

//| Estrutura Base Metas Margem 
/// Definicao Tipos ....Alias => Grupo..............Alias => Descricao  
#Define FAT_MET "01" // FAT => Faturamento s/ IPI	MET => Meta Mês
#Define FAT_TOD "02" //	FAT => Faturamento s/ IPI	TOD => Realizado Total Dia
#Define FAT_TOM "03" //	FAT => Faturamento s/ IPI	TOM => Realizado Total Mês
#Define FAT_DIM "04" //	FAT => Faturamento s/ IPI	DIM => Diferença Mês
#Define FAT_DMA "05" //	FAT => Faturamento s/ IPI	DMA => Diferença Meta Ano Acum.
#Define MAR_MET "06" //	MAR => Margem				MET => Meta Mês
#Define MAR_TOD "07" //	MAR => Margem Realizado 	TOD => Total Dia
#Define MAR_TOM "08" //	MAR => Margem Realizado 	TOM => Total Mês
#Define MRE_MET "09" //	MRE => Margem Reposicao		MET => Meta Mês
#Define MRE_TOD "10" //	MRE => Margem Reposicao		TOD => Realizado Total Dia
#Define MRE_TOM "11" //	MRE => Margem Reposicao		TOM => Realizado Total Mês
#Define IMC_MET "12" //	IMC => % Indice MC			MET => Meta Mês
#Define IMC_TOD "13" //	IMC => % Indice MC	 		TOD => RealizadoTotal Dia
#Define IMC_TOM "14" //	IMC => % Indice MC	 		TOM => RealizadoTotal Mês
#Define IMR_MET "15" //	IMR => % Indice MCR			MET => Meta Mês
#Define IMR_TOD "16" //	IMR => % Indice MCR  		TOD => RealizadoTotal Dia
#Define IMR_TOM "17" //	IMR => % Indice MCR  		TOM => RealizadoTotal Mês

#Define TTIPOS 17 //|  Numero total de Tipos  

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : MetasMargem.prw | AUTOR : Cristiano Machado | DATA : 05/03/2018**
**---------------------------------------------------------------------------**
** DESCRIÇÃO:  ** Relatorio de envio das Metas / Faturamento e Margens       **
**---------------------------------------------------------------------------**
** USO : Especifico para Imdepa                                              **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                         **
**---------------------------------------------------------------------------**
** PROGRAMADOR | DATA | MOTIVO DA ALTERACAO                                  **
**---------------------------------------------------------------------------**
**             |      |                                                      **
**             |      |                                                      **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User function MetasMargem()
*******************************************************************************

	Private dDataRef
	
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "05" FUNNAME 'MetasMargem'  TABLES 'SM0'
	
	dDataRef := dDataBase 	//| Data Referencia Utilizada no Relatorio
	
	//| Prepara Variaveis
	ConLog("Iniciando Relatorio...")
	PrepVar()
	
	
	//|Obtem Gerentes
	ConLog("Obtendo Gerentes...")
	Gerentes()

	//| Dias Uteis
	ConLog("Montando Dias Uteis...")
	DiaUtil()

	//| Prepara Estruturas
	ConLog("Preparando Estruturas...")
	PrepEst()
	
	//| Faturamento
	ConLog("Obtendo Faturamento...")
	Faturamento()
	
	//| Metas
	ConLog("Obtendo Metas...")
	Metas()
	
	//| Calcula Indices  
	ConLog("Calculando Indices...")
	Indices()
	
	//| Monta o Html para Envio
	ConLog("Montando o Html do eMail...")
	MontaHtml()
	
	//|Send e-mails
	ConLog("Enviando eMails...")
	SendMail() 
	
	ConLog("Fim da Execucao do Relatorio...")
	
	RESET ENVIRONMENT
	
Return()
*******************************************************************************
Static Function PrepVar() // Prepara Variaveis
*******************************************************************************
	
	
	
	_SetOwnerPrvt( 'cFiltraGer', Getmv("MV_FILGMOL") ) 	//| Nao mostra as movimentacoes de Clientes do Gerente informado nesse parametro, no Metas On-Line.

	_SetOwnerPrvt( 'dDtMovI', LastDay(dDataRef ,_PRI) ) //| Data Movimento Inicial 
	_SetOwnerPrvt( 'dDtMovF', LastDay(dDataRef ,_ULT) ) //| Data Movimento Final
	
	_SetOwnerPrvt( 'oHaDias',HMNew()                 ) //| Tabela Hash Dias Uteis [Chave: FILIAL + U (Obtem Uteis por Filial)  FILIAL + P (Obtem Uteis Passados) FILIAL + R (Obtem Uteis Restantes)]

	_SetOwnerPrvt( 'oHaPri' ,HMNew()                 ) //| Tabela Hash Principal [Chave: Cod Ger + Sequencia ]
	
	_SetOwnerPrvt( 'cGerImd' ,'999999'               )  //| Gerente que Representa a Imdepa

	_SetOwnerPrvt( 'cHtmMail' ,''               )  //| Gerente que Representa a Imdepa
	
	
Return
*******************************************************************************
Static Function Gerentes() // Obtem Gerentes
*******************************************************************************

	Local cSql := ""

	

	cSql += "SELECT SA3.A3_COD CODGER, Upper(Trim(SA3.A3_DESCMOL)) NOMGER, SA3.A3_CODFIL FILGER, Lower(SA3.A3_EMAIL) MAIGER "
	cSql += "FROM " + RetSqlName('SA3') + " SA3 "
	cSql += "WHERE  SA3.A3_COD IN  ( SELECT  UA_GERVEN COD_GER " 
	cSql += "						FROM  SUA010 "
	cSql += "						WHERE UA_GERVEN <> '      ' "
	cSql += "						AND UA_GERVEN NOT IN (" + cFiltraGer + ") "  
	cSql += "						AND UA_EMISSAO >= '" + DToS(dDtMovI) + "' "
	cSql += "						AND UA_EMISSAO <= '" + DToS(dDtMovF) + "' "
	cSql += "						AND D_E_L_E_T_ = ' ' ) " 
	cSql += "AND SA3.A3_COD >= '      ' "
	cSql += "AND SA3.A3_COD <= '999999' "
	cSql += "AND SA3.D_E_L_E_T_ = ' ' " 
	cSql += "GROUP BY SA3.A3_COD, SA3.A3_DESCMOL, SA3.A3_CODFIL,SA3.A3_EMAIL " 
	cSql += "ORDER BY SA3.A3_CODFIL " 

	U_ExecMySql( cSql , cCursor := "GER" , cModo := "Q", lMostra := .F.,  lChange := .F.)

Return
*******************************************************************************
Static Function DiaUtil() // Monta os Dias Uteis, Passados e Restantes 
*******************************************************************************
	
	Local dDataAux 	:= dDtMovI
	Local nDiaU 	:= 0 // Dias Uteis Totais
	Local nDiaP 	:= 0 // Dias Uteis Passados
	Local nDiaR 	:= 0 // Dias Uteis Restantes
	Local cSql  	:= ""
	Local cYEAR		:= StrZero(Year(dDtMovI),4)
	
	// Verifica Dias Uteis,Dias Passados e Dias Restantes baseado em Ferianos Nacionais (Tabela 63 do SX5) e Sabados/Domingos
	While dDataAux <= dDtMovF
		
		If DataValida(dDataAux) == dDataAux
			nDiaU += 1
			If dDataAux <= dDataRef
				nDiaP += 1
			Else
				nDiaR += 1
			EndIf
		EndIf
		
		dDataAux += 1 

	EndDo

	// Monta a Hash Table com os dias uteis, passados e restantes 
	DbSelectArea("GER");DbGotop()
	While !Eof()
		
		HMSet( oHaDias, GER->FILGER+'U', nDiaU ) // Total dias Uteis
		HMSet( oHaDias, GER->FILGER+'P', nDiaP ) // Total Dias Passados
		HMSet( oHaDias, GER->FILGER+'R', nDiaR ) // Total Dias Restantes
	
		DbSelectArea("GER")
		DbSkip()
	EndDo


	//| Monta Feriados Regionais por Filial
	cSql += "SELECT Substr(X5_CHAVE,1,2) FILIAL,  Substr(X5_CHAVE,3,3) SEQ,  Substr(X5_DESCRI,1,5) || '/"+cYEAR+"' DDATA, Substr(X5_DESCRI,7) DESCRI  FROM " + RetSqlName('SX5') + " "
	cSql += "WHERE x5_tabela = 'I8' AND D_E_L_E_T_ = ' ' "
	cSql += "AND   '"+cYEAR+"'||Substr(X5_DESCRI,4,2)||Substr(X5_DESCRI,1,2) BETWEEN '"+DToS(dDtMovI)+"' AND '"+DToS(dDtMovF)+"' " 

	U_ExecMySql( cSql , cCursor := "DUR", cModo := "Q", lMostra := .F., lChange := .F.)

	
	// Abate os feriados regionais 
	DbSelectArea("DUR");DbGoTop()
	While !EOF() 
	
		HMGet( oHaDias, DUR->FILIAL+'U', @nDiaU  ) // Obtem dias Uteis
		HMSet( oHaDias, DUR->FILIAL+'U', nDiaU-1 ) // Desconta Feriado dos Dias Uteis
		
		If cToD(DUR->DDATA) <= dDataRef // Se Data Feriado for menor que data Referencia é passado senao restante.
		
			HMGet( oHaDias, DUR->FILIAL+'P', @nDiaP  ) // Obtem dias Passados
			HMSet( oHaDias, DUR->FILIAL+'P', nDiaP-1 ) // Desconta Feriado dos Dias Passados
		
		Else
		
			HMGet( oHaDias, DUR->FILIAL+'R', @nDiaR  ) // Obtem dias Restantes
			HMSet( oHaDias, DUR->FILIAL+'R', nDiaR-1 ) // Desconta Feriado dos Dias Restantes
		
		EndIf
		
		DbSelectArea("DUR")
		DbSkip()
		
	EndDo
	
	DbSelectArea("DUR")
	DbCloseArea()

Return
*******************************************************************************
Static Function PrepEst() // Prepara a Estrutura Hash Principal para Receber os Dados
*******************************************************************************
	
	Local cTipo := ""
	
	DbSelectArea("GER");DbGoTop()
	While !EOF()
		
		For nS := 1 To TTIPOS
		 	
			cTipo := StrZero(nS,2)
		 		
		 	HMSet( oHaPri, GER->CODGER + cTipo + P_NGE, GER->NOMGER 		) // 'N' //| Nome Gerente 
		 	HMSet( oHaPri, GER->CODGER + cTipo + P_CGE, GER->CODGER 		) // 'C' //| Codigo Gerente
		 	HMSet( oHaPri, GER->CODGER + cTipo + P_TIP, cTipo        		) // 'S' //| Sequencia 
		 	HMSet( oHaPri, GER->CODGER + cTipo + P_GRU, GTexto("G",cTipo)	) // 'G' //| Grupo
		 	HMSet( oHaPri, GER->CODGER + cTipo + P_DES, GTexto("D",cTipo)	) // 'D' //| Descricao
		 	HMSet( oHaPri, GER->CODGER + cTipo + P_VAL, 0 					) // 'V' //| Valor
		 	HMSet( oHaPri, GER->CODGER + cTipo + P_PER, 0 					) // 'P' //| Percentual
			
		Next

        DbSelectArea("GER")
        DbSkip()
		   
	EndDo

	//| Cria o Gerente Imdepa para Armazenar os Totais    
	For nS := 1 To TTIPOS
		 	
		cTipo := StrZero(nS,2)
		 		
	 	HMSet( oHaPri, cGerImd + cTipo + P_NGE, "GerVen Imdepa" 	) // 'N' //| Nome Gerente 
	 	HMSet( oHaPri, cGerImd + cTipo + P_CGE, cGerImd 			) // 'C' //| Codigo Gerente
	 	HMSet( oHaPri, cGerImd + cTipo + P_TIP, cTipo        		) // 'S' //| Tipo 
	 	HMSet( oHaPri, cGerImd + cTipo + P_GRU, GTexto("G",cTipo)	) // 'G' //| Grupo
	 	HMSet( oHaPri, cGerImd + cTipo + P_DES, GTexto("D",cTipo)	) // 'D' //| Descricao
	 	HMSet( oHaPri, cGerImd + cTipo + P_VAL, 0 					) // 'V' //| Valor
	 	HMSet( oHaPri, cGerImd + cTipo + P_PER, 0 					) // 'P' //| Percentual
			
	Next

Return Nil
*******************************************************************************
Static Function GTexto(cCol, cTipo) // Monta os Textos de acordo com as Colunas 
*******************************************************************************


	Local cTexto := ""

	If cCol == "G" // Grupos 

		Do Case
			Case cTipo == FAT_MET .Or. cTipo == FAT_TOD .Or. cTipo == FAT_TOM .Or. cTipo == FAT_DIM .Or. cTipo == FAT_DMA
				cTexto := "Faturamento s/ IPI"
			Case cTipo == MAR_MET  .Or. cTipo == MAR_TOD  .Or. cTipo == MAR_TOM 
				cTexto := "Margem"
			Case cTipo == MRE_MET  .Or. cTipo == MRE_TOD  .Or. cTipo == MRE_TOM
				cTexto := "Margem Reposição"
			Case cTipo == IMC_MET  .Or. cTipo == IMC_TOD  .Or. cTipo == IMC_TOM
				cTexto := "% Indice MC"
			Case cTipo == IMR_MET  .Or. cTipo == IMR_TOD  .Or. cTipo == IMR_TOM
				cTexto := "% Indice MCR "					
			OtherWise
				cTexto := ""	
		End Case

	ElseIf cCol == "D" // Descricao

		Do Case
			Case cTipo == FAT_MET .Or. cTipo == MAR_MET .Or. cTipo == MRE_MET .Or. cTipo == IMC_MET .Or. cTipo == IMR_MET
				cTexto := "Meta Mês"
			Case cTipo == FAT_TOD .Or. cTipo == MAR_TOD .Or. cTipo == MRE_TOD .Or. cTipo == IMC_TOD .Or. cTipo == IMR_TOD
				cTexto := "Realizado Total Dia"
			Case cTipo == FAT_TOM .Or. cTipo == MAR_TOM .Or. cTipo == MRE_TOM .Or. cTipo == IMC_TOM .Or. cTipo == IMR_TOM
				cTexto := "Realizado Total Mês" 
			Case cTipo == FAT_DIM
				cTexto := "Diferença Mês"
			Case cTipo == FAT_DMA
				cTexto := "Dif. Meta Ano Acum."
			OtherWise
				cTexto := ""	
		End Case

	EndIf

Return cTexto
*******************************************************************************
Static Function Faturamento()//| Executa a Query Nf's Emitidas,  com Parametro D-Dia, M-Mes ou T-Trimestre
*******************************************************************************
	Local cQual := ""
	Local cPer  := ""

	// Consulta Notas Mes
	ConNotas(cQual := 'VEN', cPer := 'M');SlvDados(cQual, cPer)
	
	ConNotas(cQual := 'MAR', cPer := 'M');SlvDados(cQual, cPer)
	
	ConNotas(cQual := 'REP', cPer := 'M');SlvDados(cQual, cPer)

	// Consulta Notas Dia
	ConNotas(cQual := 'VEN', cPer := 'D');SlvDados(cQual, cPer)
	
	ConNotas(cQual := 'MAR', cPer := 'D');SlvDados(cQual, cPer)
	
	ConNotas(cQual := 'REP', cPer := 'D');SlvDados(cQual, cPer)

	
Return Nil
*******************************************************************************
Static Function Metas() //| Consulta Metas
*******************************************************************************

	// Consulta Metas Mes
	ConsMetas(cQual := 'MVEN', cPer := 'M');SlvDados(cQual, cPer)
	
	ConsMetas(cQual := 'MMAR', cPer := 'M');SlvDados(cQual, cPer)
	
	ConsMetas(cQual := 'MREP', cPer := 'M');SlvDados(cQual, cPer)

Return Nil	


*******************************************************************************
Static Function Indices() // Calcula os Indices 
*******************************************************************************
	
	Local nFatMet := 0 		// "01" // FAT => Faturamento s/ IPI	MET =>	Meta Mês
	Local nFatTod := 0 		// "02" // FAT => Faturamento s/ IPI	TOD => Realizado Total Dia
	Local nFatTom := 0 		// "03" // FAT => Faturamento s/ IPI	TOM => Realizado Total Mês
	Local nFatDim := 0 		// "04" // FAT => Faturamento s/ IPI	DIM => Diferença Mês
	Local nFatDma := 0 		// "05" // FAT => Faturamento s/ IPI	DMA => Diferença Meta Ano Acum.
	Local nMarMet := 0 		// "06" // MAR => Margem				MET => Meta Mês
	Local nMarTod := 0 		// "07" // MAR => Margem  				TOD => Realizado Total Dia
	Local nMarTom := 0 		// "08" // MAR => Margem 				TOM => Realizado Total Mês
	Local nMreMet := 0 		// "09" // MRE => Margem Reposicao		MET => Meta Mês
	Local nMreTod := 0		// "10" // MRE => Margem Reposicao		TOD => Realizado Total Dia
	Local nMreTom := 0 		// "11" // MRE => Margem Reposicao		TOM => Realizado Total Mês
	Local nImcMet := 0 		// "12" // IMC => % Indice MC			MET => Meta Mês
	Local nImcTod := 0 		// "13" // IMC => % Indice MC	 		TOD => Realizado Total Dia
	Local nImcTom := 0 		// "14" // IMC => % Indice MC	 		TOM => Realizado Total Mês
	Local nImrMet := 0 		// "15" // IMR => % Indice MCR			MET => Meta Mês
	Local nImrTod := 0 		// "16" // IMR => % Indice MCR  		TOD => RealizadoTotal Dia
	Local nImrTom := 0 		// "17" // IMR => % Indice MCR  		TOM => RealizadoTotal Mês

	Local lFirst  := .T.
	Local cCpoGer := ""
	
	DbSelectArea("GER");DbGoTop()
	While !EOF()
		
		If lFirst // Tratamento para Calcular Gerente Imdepa Que nao esta no Arquivo de Trabalho GER 
			cCpoGer := "cGerImd"
		Else	
			cCpoGer := "GER->CODGER"
		EndIf
		
		//| Calcula Indice MC Meta Mes (IMC)(MET)
		
		HMGet( oHaPri, &cCpoGer.+FAT_MET+P_VAL, @nFatMet  ) 	// Faturamento s/ IPI	| Meta Mês
		HMGet( oHaPri, &cCpoGer.+MAR_MET+P_VAL, @nMarMet  ) 	// Margem               | Meta Mês
		nImcMet := Round( nFatMet / nMarMet , 4 ) 
		HMSet( oHaPri, &cCpoGer.+IMC_MET+P_VAL, nImcMet ) 		// % Indice MC			| Meta Mês		
		
		Conout('Gerente : ' + &cCpoGer. + ', nFatMet: ' + cValToChar(nFatMet) + ', nMarMet: ' + cValToChar(nMarMet) ) 

		//| Calcula Indice MCR Meta Mes (IMR)(MET)
		
		HMGet( oHaPri, &cCpoGer.+FAT_MET+P_VAL, @nFatMet  ) 	// Faturamento s/ IPI	| Meta Mês
		HMGet( oHaPri, &cCpoGer.+MRE_MET+P_VAL, @nMreMet  ) 	// Margem Reposicao     | Meta Mês
		nImrMet := Round( nFatMet / nMreMet , 4 ) 
		HMSet( oHaPri, &cCpoGer.+IMR_MET+P_VAL, nImrMet ) 	// % Indice MC			| Meta Mês		


		//| Calcula Indice MC Total Dia (IMC)(TOD)

		HMGet( oHaPri, &cCpoGer.+FAT_TOD+P_VAL, @nFatTod  ) 	// Faturamento s/ IPI	| Realizado Total Dia
		HMGet( oHaPri, &cCpoGer.+MAR_TOD+P_VAL, @nMarTod  ) 	// Margem               | Realizado Total Dia
		nImcTod := Round( nFatTod / nMarTod , 4 ) 
		HMSet( oHaPri, &cCpoGer.+IMC_TOD+P_VAL, nImcTod ) 	// % Indice MC			| Realizado Total Dia	
		
		
		//| Calcula Indice MCR Total Dia (IMR)(TOD)

		HMGet( oHaPri, &cCpoGer.+FAT_TOD+P_VAL, @nFatTod  ) 	// Faturamento s/ IPI	| Realizado Total Dia	
		HMGet( oHaPri, &cCpoGer.+MRE_TOD+P_VAL, @nMreTod  ) 	// Margem Reposicao     | Realizado Total Dia	
		nImrTod := Round( nFatTod / nMreTod , 4 ) 
		HMSet( oHaPri, &cCpoGer.+IMR_TOD+P_VAL, nImrTod 	 ) 	// % Indice MC			| Realizado Total Dia	
		

		//| Calcula Indice Margem Total Mes (IMC)(TOM)

		HMGet( oHaPri, &cCpoGer.+FAT_TOM+P_VAL, @nFatTom  ) 	// Faturamento s/ IPI	| Realizado Total Mes	
		HMGet( oHaPri, &cCpoGer.+MAR_TOM+P_VAL, @nMarTom  ) 	// Margem     			| Realizado Total Mes	
		nImcTom := Round( nFatTom / nMarTom , 4 ) 
		HMSet( oHaPri, &cCpoGer.+IMC_TOM+P_VAL, nImcTom 	 ) 	// % Indice MC			| Realizado Total Mes	


		//| Calcula Indice MCR Total Mes (IMR)(TOM)

		HMGet( oHaPri, &cCpoGer.+FAT_TOM+P_VAL, @nFatTom  ) 	// Faturamento s/ IPI	| Realizado Total Mes	
		HMGet( oHaPri, &cCpoGer.+MRE_TOM+P_VAL, @nMreTom  ) 	// Margem Reposicao     | Realizado Total Mes	
		nImrTom := Round( nFatTom / nMreTom , 4 ) 
		HMSet( oHaPri, &cCpoGer.+IMR_TOM+P_VAL, nImrTom 	 ) 	// % Indice MC			| Realizado Total Mes	
		

		DbSelectArea("GER")
		If lFirst
			lFirst := .F.
		Else
			DbSkip()
		EndIF
	EndDo

Return Nil 
*******************************************************************************
Static Function ConNotas(cQual, cPer )//| Consulta Nf's Emitidas,  com Parametro D-Dia, M-Mes ou T-Trimestre
*******************************************************************************

	Local cSql := ""

	cSql += "SELECT  SC5.C5_VEND5 GERENTE, "
	
	// VENDAS - MARGEM - MARGEM REPOSICAO
	If 	cQual == "VEN"
		cSql += "SUM(D2_TOTAL) VEN"
	ElseIf cQual == "MAR"
		cSql += "SUM(D2_MC) MAR"
	ElseIf cQual == "REP"
		cSql += "SUM(D2_MCR) REP"
	EndIf
	
	cSql += " FROM "+RetSqlName("SD2")+" SD2, "+RetSqlName("SF4")+" SF4 ," +RetSqlName("SC5")+" SC5 "
	cSql += " WHERE SD2.D2_FILIAL > '  ' "

	If  cPer == "D" // Dia
		cSql += "   AND SD2.D2_EMISSAO = '"+ DToS(dDataRef) +"'

	ElseIf 	cPer == "M" // Mes
		cSql += "   AND SD2.D2_EMISSAO >= '"+ DToS(dDtMovI) +"'
		cSql += "   AND SD2.D2_EMISSAO <= '"+ DToS(dDtMovF) +"'

	ElseIf 	cPer == "T" // Trimestre
		cSql += "   AND SD2.D2_EMISSAO >= '"+ DToS(dDtMovI) +"'
		cSql += "   AND SD2.D2_EMISSAO <= '"+ DToS(dDtMovF) +"'

	ElseIf 	cPer == "A" // Ano
		cSql += "   AND SD2.D2_EMISSAO >= '"+ DToS(dDtMovI) +"'
		cSql += "   AND SD2.D2_EMISSAO <= '"+ DToS(dDtMovF) +"'

	EndIf

	cSql += "   AND F4_FILIAL = D2_FILIAL 	"
	cSql += "   AND F4_CODIGO = D2_TES 		"
	cSql += "   AND D2_FILIAL = C5_FILIAL		"
	cSql += "   AND SD2.D2_PEDIDO = SC5.C5_NUM	"

	cSql += "   AND SC5.C5_VEND5 NOT IN (" + cFiltraGer + ") "

	cSql += "   AND SD2.D2_TIPO NOT IN ( 'B', 'D','P','I') "

	cSql += "   AND SD2.D2_ORIGLAN <> 'LF'	"
	cSql += "   AND SF4.F4_DUPLIC = 'S'		"
	cSql += "   AND SF4.F4_ESTOQUE = 'S' 	" 
	cSql += "   AND SD2.D_E_L_E_T_ = ' '	"
	cSql += "   AND SF4.D_E_L_E_T_  = ' '	"
	cSql += "   AND SC5.D_E_L_E_T_  = ' '	" 
	cSql += " GROUP BY SC5.C5_VEND5  "
	cSql += " ORDER BY SC5.C5_VEND5  "

	U_ExecMySql( cSql , cCursor := "TAUX" , cModo := "Q", lMostra := .F., lChange := .F. )
	
Return
*******************************************************************************
Static Function ConsMetas(cQual, cPer ) //| Consulta Metas,  com Parametro D-Dia, M-Mes ou T-Trimestre
*******************************************************************************
	Local cSql := ""

	cSql += "SELECT CT_VEND GERENTE, "

	// METAS VENDAS - METAS MARGEM - METAS MARGEM REPOSICAO
	If 	cQual == "MVEN"
		cSql += " SUM(CT_VALOR) MVEN "
	ElseIf cQual == "MMAR" 
		cSql += " SUM(CT_MARGVLR ) MMAR "
	ElseIf cQual == "MREP"
		cSql += " SUM(CT_MARGVLR ) MREP "
	EndIf
	
	cSql += "  FROM "+RetSqlName('SCT')
	cSql += " WHERE D_E_L_E_T_  = ' ' "

	If 	cPer == "M" // Mes
		cSql += "   AND CT_DATA >= '"+ DToS(dDtMovI) +"'
		cSql += "   AND CT_DATA <= '"+ DToS(dDtMovF) +"'

	ElseIf 	cPer == "T" // Trimestre

		cSql += "   AND CT_DATA >= '"+ DToS(dDtMovI) +"'
		cSql += "   AND CT_DATA <= '"+ DToS(dDtMovF) +"'

		ElseIf 	cPer == "A" // Ano

		cSql += "   AND CT_DATA >= '"+ DToS(dDtMovI) +"'
		cSql += "   AND CT_DATA <= '"+ DToS(dDtMovF) +"'

	EndIf
	/*
	cSql += "   AND CT_MARCA   = '"+Space(Len(SCT->CT_MARCA))+"'"
	cSql += "   AND CT_REGIAO  = '"+Space(Len(SCT->CT_REGIAO))+"'"
	cSql += "   AND CT_CCUSTO  = '"+Space(Len(SCT->CT_CCUSTO))+"'"
	cSql += "   AND CT_VEND   <> '"+Space(Len(SCT->CT_VEND))+"'"
	cSql += "   AND CT_CIDADE  = '"+Space(Len(SCT->CT_CIDADE))+"'"
	cSql += "   AND CT_SEGMEN  = '"+Space(Len(SCT->CT_SEGMEN))+"'"
	cSql += "   AND CT_TIPO    = '"+Space(Len(SCT->CT_TIPO))+"'"
	cSql += "   AND CT_GRUPO   = '"+Space(Len(SCT->CT_GRUPO))+"'"
	cSql += "   AND CT_PRODUTO = '"+Space(Len(SCT->CT_PRODUTO))+"'"
	cSql += "   AND CT_CLVL    = '"+Space(Len(SCT->CT_CLVL))+"'"
	cSql += "   AND CT_GRPSEGT = '"+Space(Len(SCT->CT_GRPSEGT))+"'"
	cSql += "   AND CT_CLIENTE = '"+Space(Len(SCT->CT_CLIENTE))+"'"
	cSql += "   AND CT_MARCA3  = '"+Space(Len(SCT->CT_MARCA3))+"'"
	*/
	cSql += "   AND CT_RELAUTO  = '9'"
	cSql += "   GROUP BY CT_VEND "

	U_ExecMySql( cSql , cCursor := "TAUX" , cModo := "Q", lMostra := .F., lChange := .F. )
	
Return Nil
*******************************************************************************
Static Function SlvDados( cQual, cPer) // Salva os Dados das Notas/Metas no Hash Principal
*******************************************************************************
	
	Local cCampo 	:= ""
	Local cTipo 	:= ""
	Local nValor 	:= -1 
	Local nValTot	:= 0

	AjTpCpo(cQual, cPer, @cTipo, @cCampo) // Ajuta o nome do Campo e o Tipo de dado a ser alimentado 

	DbSelectArea("TAUX");DbGotop()
	While !EOF()

		nValor := nValTot := 0
		If HMGet( oHaPri, TAUX->GERENTE + cTipo + P_VAL, @nValor )

			// Alimenta Gerente
			nValor := &cCampo.
			HMSet( oHaPri, TAUX->GERENTE + cTipo + P_VAL, nValor )
			
			// Alimenta Gerente Totais 
			HMGet( oHaPri, cGerImd + cTipo + P_VAL, @nValTot 		)
			HMSet( oHaPri, cGerImd + cTipo + P_VAL, nValTot + nValor )
			
		EndIf
	
		DbSelectArea("TAUX")
		DbSkip()
	
	EndDo

Return Nil
*******************************************************************************
Static Function AjTpCpo(cQual, cPer, cTipo, cCampo ) // Ajuta o nome do Campo e o Tipo de dado a ser alimentado 
*******************************************************************************


	//| Atualiza Dados Referente a Vendas 
	If cQual == "VEN" //| Vendas 

		If cPer == "D"
			cTipo := FAT_TOD   // Faturamento s/ IPI	| Realizado Total Dia
		ElseIf cPer == "M"
			cTipo := FAT_TOM   // Faturamento s/ IPI 	| Realizado Total Mês
		EndIf

		cCampo := "TAUX->VEN"

	ElseIf cQual == "MAR" //| Margem

		If cPer == "D"
			cTipo := MAR_TOD	// Margem				| Realizado Total Dia
		ElseIf cPer == "M"
			cTipo := MAR_TOM	// Margem 				| Realizado Total Mês
		EndIf

		cCampo := "TAUX->MAR"

	ElseIf cQual == "REP" //| Reposicao

		If cPer == "D"
			cTipo := MRE_TOD	// Margem Reposicao		| Realizado Total Dia
		ElseIf cPer == "M"
			cTipo := MRE_TOM	// Margem Reposicao		| Realizado Total Mês
		EndIf

		cCampo := "TAUX->REP"

	EndIf

	//| Atualiza Dados Referente a Vendas
	If cQual == "MVEN" //| Vendas 
	
		If cPer == "M"
			cTipo := "01"   // Faturamento s/ IPI	| Meta Mês
		EndIf

		cCampo := "TAUX->MVEN"
	
	ElseIf cQual == "MMAR" //| Margem
	
		If cPer == "M"
			cTipo := MAR_MET	//Margem				| Meta Mês
		EndIf

		cCampo := "TAUX->MMAR"
	
	ElseIf cQual == "MREP" //| Reposicao
	
		If cPer == "M"
			cTipo := MRE_MET	//| Margem Reposicao	| Meta Mês
		EndIf

		cCampo := "TAUX->MREP"
	
	EndIf

Return Nil
*******************************************************************************
Static Function MontaHtml()
*******************************************************************************
	Local cBody 	:= ""		// Corpo da mensagem
	Local lTotal	:= .T.
	Local cGerente  := ''
	
	// Cores Utilizadas no CSS 
	Static Cor_Border := '#646464' // Cinza Escuro 	//| Cor das Bordas da Tabela
	Static Cor_TitTot := '#B4AABE' // Cinza 		//| Cor de Fundo do Titulo e Totais da Tabela
	Static Cor_LinImp := '#EBEBEB' // Cinza Claro 	//| Cor Utilizada nas Linhas Impares para Zebra
	Static Cor_FraCab := '#FF6E6E' // Vermelho		//| Cor Utilizada na Fresa Inicial e Cabecalho da Tabela
	
	StartBody(@cBody) //| Inicia
	
	ImpCab(@cBody ) 

	DbSelectArea("GER");DbGotop()
	While !EOF()
	
		If lTotal
			cGerente := cGerImd
		Else
			cGerente := GER->CODGER
		EndIf
		
			
		For nTipo := 1 To TTIPOS

			ImpItem(cGerente, @cBody, StrZero(nTipo,2),)
	
		Next
		
		If lTotal
			lTotal := .F.
		Else
			DbSelectArea("GER")
			DbSkip()
		EndIf
		
	EndDo
	
	EndBody(@cBody)
	
	cHtmMail := cBody
	
	MemoWrite( "C:\mp11\metas_margem_" + Dtos(dDatabase) + "_" + StrTran(Time(),':',".") + ".html", cBody )
	

Return Nil
*******************************************************************************
Static Function StartBody(cBody) // Inicializa o Corpo do e-mail 
*******************************************************************************

	cBody += '<!DOCTYPE html>'
	cBody += '<html>'
	cBody += '<head><style></style></head>'
	cBody += '<body>'
	cBody += '<br><br><font color="' + Cor_FraCab + '" face="Arial" size="5"><strong>Analise de Metas Margem - Data/Hora Referencia: '+cValToChar(dDataBase)+' / '+Time()+'</strong></font><br><br>'

Return Nil
*******************************************************************************
Static Function ImpCab(cBody ) //| Monta Html com Cabecalho dos itens 
*******************************************************************************

	cBody += '<table style="font-family:Lucida Grande,sans-serif;border-collapse:collapse;width:100%;background-color:white;border:2px solid ' + Cor_Border+ ';max-width:1000px;align: center; ">'

	cBody += '<tr style="text-transform:uppercase;background-color:' + Cor_TitTot + ';color:white;border:2px solid' + Cor_Border+ ';height: 27px;">'
	cBody +=    '<th>Nome Gerente</th>'
	cBody +=    '<th>Codigo Gerente</th>'
	cBody +=    '<th>Tipo</th>'
	cBody +=    '<th>Grupo</th>'
	cBody +=    '<th>Descrição</th>'
	cBody +=    '<th>Valor</th>'    
	cBody +=    '<th>Percentual</th>'
	cBody += '</tr>'

Return Nil
*******************************************************************************
Static Function ImpItem(cGerente, cBody, cTipo) //| Monta Html do Item 
*******************************************************************************

	Local lPar    := Mod( Val(cTipo) , 2 ) == 0 // Retorna ZERO se o Numero eh PAR 
	Local cCssTrP := 'style="border:1px solid ' + Cor_Border+ ';background-color:' + Cor_LinImp + ';height:25px;' //| CSS para Linhas Pares 
	Local cCssTrI := 'style="border:1px solid ' + Cor_Border+ ';height:25px;' //| CSS para Linhas Impares
	Local cCssTdC := 'style="border:1px solid ' + Cor_Border+ ';padding:6px;text-align:' //| CSS cada Campo
 	
	Local cNome 	:= ''
	Local cCodigo 	:= ''
	Local cGrupo 	:= ''
	Local cDesc 	:= ''
	Local nValor 	:= 0
	Local nPerc 	:= 0
	
	cBody += '<tr ' + If(lPar,cCssTrP,cCssTrI) + If(cTipo==cValToChar(TTIPOS),'border-bottom:5px solid '+Cor_Border+'; "',' "') + '> '
	
	HMGet( oHaPri, cGerente + cTipo + P_NGE, @cNome   ) // 'N' //| Nome Gerente 
	HMGet( oHaPri, cGerente + cTipo + P_CGE, @cCodigo ) // 'C' //| Codigo Gerente
//  HMGet( oHaPri, TAUX->GERENTE + cTipo + P_TIP, @cTipo ) // 'T' //| Tipo 
	HMGet( oHaPri, cGerente + cTipo + P_GRU, @cGrupo  ) // 'G' //| Grupo
	HMGet( oHaPri, cGerente + cTipo + P_DES, @cDesc   ) // 'D' //| Descricao
	HMGet( oHaPri, cGerente + cTipo + P_VAL, @nValor  ) // 'V' //| Valor
	HMGet( oHaPri, cGerente + cTipo + P_PER, @nPerc   ) // 'P' //| Percentual
	

	cBody += '<td ' + cCssTdC + 'Left";>' 	+ Alltrim(cNome) 						+ '</td>'
	cBody += '<td ' + cCssTdC + 'center";>' + Alltrim(cCodigo) 						+ '</td>'
	cBody += '<td ' + cCssTdC + 'center";>' + Alltrim(cTipo) 						+ '</td>'
	cBody += '<td ' + cCssTdC + 'Left";>'  	+ Alltrim(cGrupo) 						+ '</td>'
	cBody += '<td ' + cCssTdC + 'Left";>'  	+ Alltrim(cDesc) 						+ '</td>'
	cBody += '<td ' + cCssTdC + 'right";>'  + Transform(nValor,"@E 99,999,999.99")	+ '</td>'
	cBody += '<td ' + cCssTdC + 'center";>' + Transform(nPerc ,"@E 999.99 %") 		+ '</td>'
	cBody += '</tr>'
	

Return Nil
*******************************************************************************
Static Function EndBody(cBody) // Finaliza o Corpo do e-mail 
*******************************************************************************

cBody += '</table>'
cBody += '</body>'
cBody += '<br><br><br><br><br><br>'
cBody += '</html>'

Return Nil 
*******************************************************************************
Static Function SendMail() //| Envia os email aos envolvidos ...
*******************************************************************************
	Local cSubject 	:= "Metas Margem" // Assunto da Mensagem 
	Local cTo		:= ""		// Destinatario da Mensagem
	Local cCo		:= ""		// Copia da Mensagem 
	Local lSend		:= .T.		// Se deve ou nao enviar o email
	
	Local cMailRTI	:= SuperGetMv( "MV_ECONTTI", .F., "", "" ) //| E-mail de controle dos relatorios usado pela TI : mp10.relatorios@imdepa.com.br 
	Local cMailAss	:= "" //| E-mail da Assistente de Vendas de cada Filial. Este Parametro Utiliza o Codigo da Filial ...  
	Local cMailGer  := "" //| Email dos Gerentes 	
	Local cMailURM  := "" //| E-mail dos Usuarios que receberao o Metas   // "MV_EMMOL01" "MV_EMMOL02" "MV_EMMOL03" "MV_EMMOL04"
	
	Local aAreaSX6  := SX6->( GetArea() )
	Local cRetPos   := "" // Guarda o Retorno do Posicione()
	 
	 
	If lSend 
		
		//| Envia para Gerente e Assistentes ... 
		cTo := cCo := ""
		DbSelectArea("GER");DbGotop()
		While !EOF()
		
			cTo := GER->MAIGER
			cCo := Alltrim( Posicione( "SX6", 1, GER->FILGER + "MV_EASSV" , "X6_CONTEUDO" ) ) //| E-mail da Assistente de Vendas de cada Filial. Este Parametro Utiliza o Codigo da Filial ...			
			cCo += "," + cMailRTI
			
			ConLog("Enviando eMail para:" + cTo )
			U_EnvMyMail( Nil , Lower('cristiano.machado@imdepa.com.br') , '' ,cSubject, 'Gerente: ' + cTo + ' Assistente:' + cCo + '     ' + cHtmMail , '' , .F.,.F.,.F.,.F.,.F.,.F.)

			DbSelectArea("GER")
			DbSkip()

		EndDo
		
		
		//| Envia para Usuarios que tambem recebem o Relatorio 
		cTo := cCo := ""
		For nP := 1 To 99
		
			cRetPos := Posicione( "SX6", 1, Space(02) + "MV_EMMOL" + StrZero(nP,2), "X6_CONTEUDO" ) //| E-mail dos Usuarios que receberao o Metas   // "MV_EMMOL01" "MV_EMMOL02" "MV_EMMOL03" "MV_EMMOL04"
			ConOut('METAS_MARGEM : cRetPos -> ' +  cRetPos )
			If !Empty(cRetPos)
				cTo := Alltrim(cRetPos)
				cCo := Alltrim(cMailRTI)
			
				ConLog("Enviando eMail para:" + cTo )
				U_EnvMyMail( Nil , Lower('cristiano.machado@imdepa.com.br') , '' ,cSubject, 'cTo: ' + cTo + ' cCo:' + cCo + '     ' + cHtmMail , '' , .F.,.F.,.F.,.F.,.F.,.F.)

				cTo := cCo := ""
			Else
				nP := 99
			EndIf

		Next 

	EndIf

Return Nil 
*******************************************************************************
Static Function ConLog(cTxt)
*******************************************************************************

ConOut("METAS_MARGEM - > " + PadR( cTxt , 100 ) + dToc(dDataRef) + " - " + Time() )

Return Nil 