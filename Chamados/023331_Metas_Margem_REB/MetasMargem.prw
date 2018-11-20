
#Include 'Totvs.ch'
#Include "Tbiconn.ch"

#Define _TESTE_ .F.  //| Habilita modo teste envia emails apenas para a conta teste .... 
#Define _CONTATESTE_ 'cristiano.machado@imdepa.com.br' 
#Define _DATABASE	CToD("12/11/2018")

#Define FVEN 'FVEN' //| Faturamento Vendas
#Define FMAR 'FMAR' //| Faturamento Margem
#Define MVEN 'MVEN' //| Metas Vendas
#Define MMAR 'MMAR' //| Metas Margem
#Define DVEN 'DVEN' //| Devolucao Vendas
#Define DMAR 'DMAR' //| Devolucao Margem

#Define DIAANTERIOR 1 // 
#Define _PRI 1 
#Define _ULT 0

// Funcao VerDDia
#Define DINI	1
#Define DFIM	2

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
//#Define MRE_MET "09" //	MRE => Margem Reposicao		MET => Meta Mês
//#Define MRE_TOD "10" //	MRE => Margem Reposicao		TOD => Realizado Total Dia
//#Define MRE_TOM "11" //	MRE => Margem Reposicao		TOM => Realizado Total Mês
#Define IMC_MET "09" //	IMC => % Indice MC			MET => Meta Mês
#Define IMC_TOD "10" //	IMC => % Indice MC	 		TOD => RealizadoTotal Dia
#Define IMC_TOM "11" //	IMC => % Indice MC	 		TOM => RealizadoTotal Mês
//#Define IMR_MET "15" //	IMR => % Indice MCR			MET => Meta Mês
//#Define IMR_TOD "16" //	IMR => % Indice MCR  		TOD => RealizadoTotal Dia
//#Define IMR_TOM "17" //	IMR => % Indice MCR  		TOM => RealizadoTotal Mês

#Define REB_TOD "91" //	ReB => Receita Bruta 	TOD => Realizado Total Dia
#Define REB_TOM "92" //	ReB => Receita Bruta	TOM => Realizado Total Mês


#Define TTIPOS 11 //|  Numero total de Tipos  

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
	Private lTeste := _TESTE_
	
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "05" FUNNAME 'MetasMargem'  TABLES 'SM0'
	
	If lTeste
		dDataBase := _DATABASE
	Endif
	
	dDataRef := dDataBase - DIAANTERIOR 	//| Data Referencia Utilizada no Relatorio
	
	// Verifica se eh Feriano Nacional Apenas... 
	If DataValida(dDataBase) <> dDataBase .And. Day(dDataBase) <> 1
		ConLog("Feriado - Relatorio não sera executado - Abortando!!!")
	Else
	
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
	
		//| Devolucoes
		ConLog("Obtendo Devolucoes...")
		Devolucao()
	
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
	
	EndIf
	
	RESET ENVIRONMENT
	
Return()
*******************************************************************************
Static Function PrepVar() // Prepara Variaveis
*******************************************************************************
	
	_SetOwnerPrvt( 'cFiltraGer', Getmv("MV_FILGMOL") ) 	//| Nao mostra as movimentacoes de Clientes do Gerente informado nesse parametro, no Metas On-Line.

	//_SetOwnerPrvt( 'dDtMovI', LastDay(dDataRef ,_PRI) ) //| Data Movimento Inicial 
	_SetOwnerPrvt( 'dDtMovI', SToD( Substr(DToS(dDataRef),1,6)+'01') ) //| Data Movimento Inicial
	_SetOwnerPrvt( 'dDtMovF', LastDay(dDataRef ,_ULT) ) //| Data Movimento Final
	_SetOwnerPrvt( 'dDtMoAI', CToD('01/01/'+StrZero(Year(dDataRef),4))) //| Data Movimento Inicial Ano
	
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
	cSql += "						AND UA_EMISSAO <= '" + DToS(dDataRef) + "' "
	cSql += "						AND D_E_L_E_T_ = ' ' ) " 
	cSql += "AND SA3.A3_COD > '      ' "
	cSql += "AND SA3.A3_COD < '999999' "
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
		
		dDataAux := cToD(DUR->DDATA)
		
		HMGet( oHaDias, DUR->FILIAL+'U', @nDiaU  ) // Obtem dias Uteis
		
		If DataValida(dDataAux) == dDataAux // Só desconta o Feriado Estadual/Municipal caso nao seja final de semana ou feriado nacional
			
			HMSet( oHaDias, DUR->FILIAL+'U', nDiaU-1 ) // Desconta Feriado dos Dias Uteis
		
			If dDataAux <= dDataRef // Se Data do Feriado for menor que data Referencia é passado senao restante.
				HMGet( oHaDias, DUR->FILIAL+'P', @nDiaP  ) // Obtem dias Passados
				HMSet( oHaDias, DUR->FILIAL+'P', nDiaP-1 ) // Desconta Feriado dos Dias Passados
			Else
				HMGet( oHaDias, DUR->FILIAL+'R', @nDiaR  ) // Obtem dias Restantes
				HMSet( oHaDias, DUR->FILIAL+'R', nDiaR-1 ) // Desconta Feriado dos Dias Restantes
			EndIf
		
		EndIf
		
		DbSelectArea("DUR")
		DbSkip()
		
	EndDo

	ConLog("Gerente: "+GER->FILGER+" Total de dias Uteis: "+ cValToChar(nDiaU) )
	ConLog("Gerente: "+GER->FILGER+" Total de dias Passados: "+ cValToChar(nDiaP) )
	ConLog("Gerente: "+GER->FILGER+" Total de dias Restantes: "+ cValToChar(nDiaR) )

	
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
		 	
		 	// Para Calculo do FAT_DMA precisa armazenar o Faturamento / Meta e Devolucao para cada Gerente
		 	// So precisa do Campo Valor. Nao eh utilizado no HTML
		 	If cTipo == FAT_DMA 
		 		HMSet( oHaPri, GER->CODGER + cTipo + "F" + P_VAL, 0 					) // 'V' //| Valor
		 		HMSet( oHaPri, GER->CODGER + cTipo + "M" + P_VAL, 0 					) // 'V' //| Valor
		 	 	HMSet( oHaPri, GER->CODGER + cTipo + "D" + P_VAL, 0 					) // 'V' //| Valor	 	
		 	Endif

		 	// Armazenar Receita Bruta apenas para Calculo Interno
		 	If cTipo == FAT_TOD // "02" //	FAT => Faturamento s/ IPI	TOD => Realizado Total Dia
		 		HMSet( oHaPri, GER->CODGER + REB_TOD + P_VAL, 0 					) // 'V' //| Valor	
		 	ElseIf cTipo ==  FAT_TOM  //"03" //	FAT => Faturamento s/ IPI	TOM => Realizado Total Mês
		 		HMSet( oHaPri, GER->CODGER + REB_TOM + P_VAL, 0 					) // 'V' //| Valor
		 	EndIf
		 	
			HMSet( oHaPri, GER->CODGER + cTipo + P_PER, 0 					) // 'P' //| Percentual
			
		Next

        DbSelectArea("GER")
        DbSkip()
		   
	EndDo

	//| Cria o Gerente Imdepa para Armazenar os Totais    
	For nS := 1 To TTIPOS
		 	
		cTipo := StrZero(nS,2)
		 		
	 	HMSet( oHaPri, cGerImd + cTipo + P_NGE, "TOTAL" 			) // 'N' //| Nome Gerente 
	 	HMSet( oHaPri, cGerImd + cTipo + P_CGE, cGerImd 			) // 'C' //| Codigo Gerente
	 	HMSet( oHaPri, cGerImd + cTipo + P_TIP, cTipo        		) // 'S' //| Tipo 
	 	HMSet( oHaPri, cGerImd + cTipo + P_GRU, GTexto("G",cTipo)	) // 'G' //| Grupo
	 	HMSet( oHaPri, cGerImd + cTipo + P_DES, GTexto("D",cTipo)	) // 'D' //| Descricao
	 	HMSet( oHaPri, cGerImd + cTipo + P_VAL, 0 					) // 'V' //| Valor

	 	// Para Calculo do FAT_DMA precisa armazenar o Faturamento / Meta e Devolucao para cada Gerente
		// So precisa do Campo Valor. Nao eh utilizado no HTML
		If cTipo == FAT_DMA 
			HMSet( oHaPri, cGerImd + cTipo + "F" + P_VAL, 0 					) // 'V' //| Valor
			HMSet( oHaPri, cGerImd + cTipo + "M" + P_VAL, 0 					) // 'V' //| Valor
		 	HMSet( oHaPri, cGerImd + cTipo + "D" + P_VAL, 0 					) // 'V' //| Valor	 	
		Endif
		
		
		// Armazenar Receita Bruta apenas para Calculo Interno "90" e "91"
		If cTipo == FAT_TOD // "02" //	FAT => Faturamento s/ IPI	TOD => Realizado Total Dia
			HMSet( oHaPri, cGerImd + REB_TOD + P_VAL, 0 					) // 'V' //| Valor
		ElseIf cTipo ==  FAT_TOM  //"03" //	FAT => Faturamento s/ IPI	TOM => Realizado Total Mês
			HMSet( oHaPri, cGerImd + REB_TOM + P_VAL, 0 					) // 'V' //| Valor
		EndIf
	
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
			//Case cTipo == MRE_MET  .Or. cTipo == MRE_TOD  .Or. cTipo == MRE_TOM
			//	cTexto := "Margem Reposição"
			Case cTipo == IMC_MET  .Or. cTipo == IMC_TOD  .Or. cTipo == IMC_TOM
				cTexto := "% Indice MC"
			//Case cTipo == IMR_MET  .Or. cTipo == IMR_TOD  .Or. cTipo == IMR_TOM
			//	cTexto := "% Indice MCR "					
			OtherWise
				cTexto := ""	
		End Case

	ElseIf cCol == "D" // Descricao

		Do Case
			Case cTipo == FAT_MET .Or. cTipo == MAR_MET /*.Or. cTipo == MRE_MET */ .Or. cTipo == IMC_MET //.Or. cTipo == IMR_MET
				cTexto := "Meta Or&ccedil;. M&ecirc;s"
			Case cTipo == FAT_TOD .Or. cTipo == MAR_TOD /*.Or. cTipo == MRE_TOD */ .Or. cTipo == IMC_TOD //.Or. cTipo == IMR_TOD
				cTexto := "Realizado Total Dia"
			Case cTipo == FAT_TOM .Or. cTipo == MAR_TOM /*.Or. cTipo == MRE_TOM */ .Or. cTipo == IMC_TOM //.Or. cTipo == IMR_TOM
				cTexto := "Realizado Total M&ecirc;s" 
			Case cTipo == FAT_DIM
				cTexto := "Diferen&ccedil;a M&ecirc;s"
			Case cTipo == FAT_DMA
				cTexto := "Dif. Meta Or&ccedil;. Ano Acum."
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
	ConNotas(cQual := FVEN, cPer := 'M');SlvDados(cQual, cPer)
	
	ConNotas(cQual := FMAR, cPer := 'M');SlvDados(cQual, cPer)
	
	
	// Consulta Notas Dia
	ConNotas(cQual := FVEN, cPer := 'D');SlvDados(cQual, cPer)
	
	ConNotas(cQual := FMAR, cPer := 'D');SlvDados(cQual, cPer)
	
	
	// Consulta Notas Ano
	ConNotas(cQual := FVEN, cPer := 'A');SlvDados(cQual, cPer)

	
Return Nil
*******************************************************************************
Static Function Metas() //| Consulta Metas
*******************************************************************************

	// Consulta Metas Mes
	ConsMetas(cQual := MVEN, cPer := 'M');SlvDados(cQual, cPer)
	
	ConsMetas(cQual := MMAR, cPer := 'M');SlvDados(cQual, cPer)
	
	// Metas Ano
	ConsMetas(cQual := MVEN, cPer := 'A');SlvDados(cQual, cPer)
	
	
Return Nil	
*******************************************************************************
Static Function Devolucao() //| Consulta Metas
*******************************************************************************

	// Devolucao Mes
	ConDev(cQual := DVEN, cPer := 'M');SlvDados(cQual := DVEN, cPer)
	//ConDev(cQual := DMAR, cPer := 'M');SlvDados(cQual, cPer)
	

	// Devolucao Dia
	ConDev(cQual := DVEN, cPer := 'D');SlvDados(cQual := DVEN, cPer)
	//ConDev(cQual := DMAR, cPer := 'D');SlvDados(cQual, cPer)
	
	// Devolucao Ano
	ConDev(cQual := DVEN, cPer := 'A');SlvDados(cQual := DVEN, cPer)

Return Nil
*******************************************************************************
Static Function Indices() // Calcula os Indices 
*******************************************************************************
	
	Local nFatMet := 0 	// "01" // FAT => Faturamento s/ IPI	MET =>	Meta Mês
	Local nFatTod := 0 	// "02" // FAT => Faturamento s/ IPI	TOD => Realizado Total Dia
	Local nFatTom := 0 	// "03" // FAT => Faturamento s/ IPI	TOM => Realizado Total Mês
	Local nFatDim := 0 	// "04" // FAT => Faturamento s/ IPI	DIM => Diferença Mês
	Local nFatDma := 0 	// "05" // FAT => Faturamento s/ IPI	DMA => Diferença Meta Ano Acum.
	Local nMarMet := 0 	// "06" // MAR => Margem				MET => Meta Mês
	Local nMarTod := 0 	// "07" // MAR => Margem  				TOD => Realizado Total Dia
	Local nMarTom := 0 	// "08" // MAR => Margem 				TOM => Realizado Total Mês
	Local nImcMet := 0 	// "09" // IMC => % Indice MC			MET => Meta Mês
	Local nImcTod := 0 	// "10" // IMC => % Indice MC	 		TOD => Realizado Total Dia
	Local nImcTom := 0 	// "11" // IMC => % Indice MC	 		TOM => Realizado Total Mês

	Local nRebTod := 0  // "91" //	REB => Receita Bruta 	TOD => Realizado Total Dia
	Local nRebTom := 0 //| "92" //  REB => Receita Bruta	TOM => Realizado Total Mês

	Local nFatDmaF:= 0	// "05" // FAT => Faturamento s/ IPI	DMA => Diferença Meta Ano Acum. (F->Faturamento)
	Local nFatDmaM:= 0	// "05" // FAT => Faturamento s/ IPI	DMA => Diferença Meta Ano Acum. (M->Metas)
	Local nFatDmaD:= 0	// "05" // FAT => Faturamento s/ IPI	DMA => Diferença Meta Ano Acum. (D->Devolucao)
	
	Local lFirst  := .T.
	Local cCpoGer := ""
	
	// 
	Local nMDFatRea := 0 // Faturamento Realizado  por Dia Util Gerente
	Local nMDFatMet := 0 // Faturamento Meta por Dia Util Gerente
	
	Local nMDMarRea := 0 // Margem Realizado por Dia Util Gerente
	Local nMDMarMet := 0 // Margem Meta por Dia Util Gerente
	
	Local nMAFatRea := 0 // Faturamento Acumulado Realizado por Dia Util Imdepa
	Local nMAFatMet := 0 // Faturamento Acumulado Meta por Dia Util Imdepa
	
	Local nMAMarRea := 0 // Margem Acumulado Realizado por Dia Util Imdepa
	Local nMAMarMet := 0 // Margem Acumulado Meta por Dia Util Imdepa
	
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
		nImcMet := Round( nMarMet / nFatMet  * 100, 4 ) 
		HMSet( oHaPri, &cCpoGer.+IMC_MET+P_PER, nImcMet ) 		// % Indice MC			| Meta Mês		
		

		//| Calcula Indice MC Total Dia (IMC)(TOD)
		HMGet( oHaPri, &cCpoGer.+FAT_TOD+P_VAL, @nFatTod  ) 	// Faturamento s/ IPI	| Realizado Total Dia
		HMGet( oHaPri, &cCpoGer.+REB_TOD+P_VAL, @nRebTod  ) 	// REB => Receita Bruta 	TOD => Realizado Total Dia
		HMGet( oHaPri, &cCpoGer.+MAR_TOD+P_VAL, @nMarTod  ) 	// Margem               | Realizado Total Dia
		nImcTod := Round( nMarTod / nRebTod * 100, 4 ) 
		HMSet( oHaPri, &cCpoGer.+IMC_TOD+P_PER, nImcTod   ) 	// % Indice MC			| Realizado Total Dia	
		
		
		//| Calcula Indice Margem Total Mes (IMC)(TOM)
		HMGet( oHaPri, &cCpoGer.+FAT_TOM+P_VAL, @nFatTom  ) 	// Faturamento s/ IPI	| Realizado Total Mes	
		HMGet( oHaPri, &cCpoGer.+REB_TOM+P_VAL, @nRebTom  )		// REB => Receita Bruta	TOM => Realizado Total Mês 
		HMGet( oHaPri, &cCpoGer.+MAR_TOM+P_VAL, @nMarTom  ) 	// Margem     			| Realizado Total Mes	
		nImcTom := Round( nMarTom / nRebTom * 100, 4 ) 
		HMSet( oHaPri, &cCpoGer.+IMC_TOM+P_PER, nImcTom   ) 	// % Indice MC			| Realizado Total Mes	


		//| Calculo TIPO 03 FAT => Faturamento s/ IPI	TOM => Realizado Total Mês
		HMGet( oHaPri, &cCpoGer.+FAT_TOM+P_VAL, @nFatTom  ) 	// Faturamento s/ IPI	| Realizado Total Mes	
		
		//| Calcula TIPO 04 - Faturamento Diferença Mês
		HMSet( oHaPri, &cCpoGer.+FAT_DIM+P_VAL, (nFatMet - nFatTom) ) 


		//| Calula TIPO 05 -  Diferença Meta Ano Acum.
		HMGet( oHaPri, &cCpoGer.+FAT_DMA+"F"+P_VAL, @nFatDmaF ) 
		HMGet( oHaPri, &cCpoGer.+FAT_DMA+"M"+P_VAL, @nFatDmaM ) 
		HMGet( oHaPri, &cCpoGer.+FAT_DMA+"D"+P_VAL, @nFatDmaD ) 
		nFatDma := Round(nFatDmaM - (nFatDmaF + nFatDmaD) , 4 )
		HMSet( oHaPri, &cCpoGer. + FAT_DMA + P_VAL, nFatDma ) 
		
		
		//| Calculo Percecntual das Metas Mes
		nDiaUT := nDiaUP := 0 // Dias Uteis e Dias Passados
		HMGet( oHaDias, GER->FILGER+'U', nDiaUT ) // Total dias Uteis
		HMGet( oHaDias, GER->FILGER+'P', nDiaUP ) // Total Dias Passados
		//HMSet( oHaDias, GER->FILGER+'R', nDiaR ) // Total Dias Restantes
		
	
		nMDFatRea := Round( nFatTom / nDiaUP ,4)  // Faturamento Realizado por Dia Util Gerente
		nMDFatMet := Round( nFatMet / nDiaUT ,4) // Faturamento Meta por Dia Util Gerente
	
		nMDMarRea := Round( nMarTom / nDiaUP ,4) // Margem Realizado por Dia Util Gerente
		nMDMarMet := Round( nMarMet / nDiaUT ,4) // Margem Meta por Dia Util Gerente
		
		ConLog("Calculo Realizados / Meta Gerente: " + &cCpoGer.)
		ConLog("nMDFatRea["+cValToChar( nMDFatRea )+"] := ( nFatTom["+cValToChar( nFatTom )+"] / nDiaUP["+cValToChar( nDiaUP )+"] )")
		ConLog("nMDFatMet["+cValToChar( nMDFatMet )+"] := ( nFatMet["+cValToChar( nFatMet )+"] / nDiaUT["+cValToChar( nDiaUT )+"] )")
		//ConLog("nMDMarRea["+cValToChar( nMDMarRea )+"] := ( nMarTom["+cValToChar( nMarTom )+"] / nDiaUP["+cValToChar( nDiaUP )+"] )")
		//ConLog("nMDMarMet["+cValToChar( nMDMarMet )+"] := ( nMarMet["+cValToChar( nMarMet )+"] / nDiaUT["+cValToChar( nDiaUT )+"] )")
	
		HMSet( oHaPri, &cCpoGer.+FAT_MET+P_PER, Round( nMDFatRea / nMDFatMet * 100, 4 )   )  // 'P' //| Percentual
		
		HMSet( oHaPri, &cCpoGer.+MAR_MET+P_PER, Round( nMDMarRea / nMDMarMet * 100, 4 )   )  // 'P' //| Percentual
		
		//| HMSet( oHaPri, &cCpoGer.+IMC_MET+P_PER, Round( ( nImcTom / nDiaUP ) / ( nImcMet / nDiaUT ) * 100, 4 )   )  // 'P' //| Percentual

		If !lFirst
			nMAFatRea += nMDFatRea // Faturamento Acumulado Realizado por Dia Util Imdepa
			nMAFatMet += nMDFatMet // Faturamento Acumulado Meta por Dia Util Imdepa
	
			nMAMarRea += nMDMarRea // Margem Acumulado Realizado por Dia Util Imdepa
			nMAMarMet += nMDMarMet // Margem Acumulado Meta por Dia Util Imdepa
		EndIf
		
		DbSelectArea("GER")
		If lFirst
			lFirst := .F.
		Else
			DbSkip()
		EndIF
	EndDo
	
	// Deve Atualizar o Valor Percentual Atingido para o TOTAL Imdepa... 
	HMSet( oHaPri, cGerImd+FAT_MET+P_PER, Round( nMAFatRea / nMAFatMet * 100, 4 )   )  // 'P' //| Percentual
	HMSet( oHaPri, cGerImd+MAR_MET+P_PER, Round( nMAMarRea / nMAMarMet * 100, 4 )   )  // 'P' //| Percentual
		
	
	
Return Nil 
*******************************************************************************
Static Function ConNotas(cQual, cPer )//| Consulta Nf's Emitidas,  com Parametro D-Dia, M-Mes ou T-Trimestre
*******************************************************************************

	Local cSql := ""

	cSql += "SELECT  SC5.C5_VEND5 GERENTE, "
	
	// VENDAS - MARGEM
	If 	cQual == FVEN
		cSql += "SUM(D2_TOTAL) FVEN, " // FAT -> FATURAMENTO SEM IPI
		cSql += "SUM(D2_TOTAL + D2_VALFRE) RVEN " // REB -> RECEBITA BRUTA
	
	ElseIf cQual == FMAR
		cSql += "SUM(D2_MC) FMAR"
	EndIf
	
	cSql += " FROM "+RetSqlName("SD2")+" SD2, "+RetSqlName("SF4")+" SF4 ," +RetSqlName("SC5")+" SC5 "
	cSql += " WHERE SD2.D2_FILIAL > '  ' "

	If  cPer == "D" // Dia
	
		aDia := VerDDia(dDataRef)
		
		cSql += "   AND SD2.D2_EMISSAO >= '"+ DToS( aDia[DINI] 	) +"'
		cSql += "   AND SD2.D2_EMISSAO <= '"+ DToS( aDia[DFIM]	) +"'

	ElseIf 	cPer == "M" // Mes
		cSql += "   AND SD2.D2_EMISSAO >= '"+ DToS(dDtMovI) +"'
		cSql += "   AND SD2.D2_EMISSAO <= '"+ DToS(dDataRef) +"'

	ElseIf 	cPer == "T" // Trimestre
		cSql += "   AND SD2.D2_EMISSAO >= '"+ DToS(dDtMovI) +"'
		cSql += "   AND SD2.D2_EMISSAO <= '"+ DToS(dDataRef) +"'

	ElseIf 	cPer == "A" // Ano
		cSql += "   AND SD2.D2_EMISSAO >= '"+ DToS(dDtMoAI) +"'
		cSql += "   AND SD2.D2_EMISSAO <= '"+ DToS(dDataRef) +"'

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
	cSql += "   AND SC5.C5_VEND5 > ' '      "
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
	If 	cQual == MVEN
		cSql += " SUM(CT_VALOR) MVEN "
	ElseIf cQual ==MMAR
		cSql += " SUM(CT_MARGVLR ) MMAR "
	EndIf
	
	cSql += "  FROM "+RetSqlName('SCT')
	cSql += " WHERE D_E_L_E_T_  = ' ' "

	If 	cPer == "M" // Mes
		cSql += "   AND CT_DATA >= '"+ DToS(dDtMovI) +"' "
		cSql += "   AND CT_DATA <= '"+ DToS(dDtMovF) +"' "

	ElseIf 	cPer == "T" // Trimestre

		cSql += "   AND CT_DATA >= '"+ DToS(dDtMovI) +"' "
		cSql += "   AND CT_DATA <= '"+ DToS(dDtMovF) +"' "

		ElseIf 	cPer == "A" // Ano

		cSql += "   AND CT_DATA >= '"+ DToS(dDtMoAI) +"' "
		cSql += "   AND CT_DATA <= '"+ DToS(dDtMovF) +"' "

	EndIf
	
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
	
	//cSql += "   AND CT_RELAUTO  = '9'"
	cSql += "   GROUP BY CT_VEND "

	U_ExecMySql( cSql , cCursor := "TAUX" , cModo := "Q", lMostra := .F., lChange := .F. )
	
Return Nil
*******************************************************************************
Static Function ConDev(cQual, cPer )//| Consulta Nf's Emitidas,  com Parametro D-Dia, M-Mes ou T-Trimestre
*******************************************************************************
	Local cSql := ""

	
	cSql += "SELECT A1_GERVEN GERENTE, "
	 
	If 	cQual == DVEN
		cSql += " ( SUM(D1_TOTAL)* -1 ) DVEN "
	ElseIf cQual == DMAR
		cSql += " ( SUM(D2_MC/D1_QUANT)   * -1 ) DMAR "
	EndIf
		
	cSql += " FROM "+RetSqlName("SD1")+" SD1, "+RetSqlName("SF1")+" SF1 ," +RetSqlName("SF2")+" SF2, "+RetSqlName("SF4")+ " SF4 , "+RetSqlName("SD2")+ " SD2, "+RetSqlName("SA1")+ " SA1 "
	cSql += " WHERE D1_FILIAL = F1_FILIAL "
	cSql += "	  AND D1_FILIAL = F2_FILIAL "
	cSql += "	  AND D1_FILIAL = F4_FILIAL "

	If  cPer == "D" // Dia
		
		aDia := VerDDia(dDataRef)
		
		cSql += "   AND D1_DTDIGIT >= '"+ DToS( aDia[DINI] 	) +"' "
		cSql += "   AND D1_DTDIGIT <= '"+ DToS( aDia[DFIM]	) +"' "
		
	ElseIf 	cPer == "M" // Mes
		cSql += "   AND D1_DTDIGIT >= '"+ DToS(dDtMovI) +"' "
		cSql += "   AND D1_DTDIGIT <= '"+ DToS(dDataRef) +"' "

	ElseIf 	cPer == "T" // Trimestre

		cSql += "   AND D1_DTDIGIT >= '"+ DToS(dDtMovI) +"' "
		cSql += "   AND D1_DTDIGIT <= '"+ DToS(dDataRef) +"' "

	ElseIf 	cPer == "A" // Ano
	
		cSql += "   AND D1_DTDIGIT >= '"+ DToS(dDtMoAI) +"' "
		cSql += "   AND D1_DTDIGIT <= '"+ DToS(dDataRef) +"' "
		
	EndIf

	cSql += "   AND D1_TIPO = 'D'"
	cSql += "   AND F4_CODIGO  = D1_TES"

	cSql += "   AND F4_ESTOQUE = 'S'   "
	cSql += "   AND F4_DUPLIC = 'S'   "
	cSql += "   AND F2_DOC     = D1_NFORI   "
	cSql += "   AND F2_SERIE   = D1_SERIORI "
	cSql += "   AND F2_CLIENTE = D1_FORNECE "
	cSql += "   AND F2_LOJA    = D1_LOJA "
	cSql += "   AND F1_DOC     = D1_DOC     "
	cSql += "   AND F1_SERIE   = D1_SERIE"
	cSql += "   AND F1_FORNECE = D1_FORNECE"
	cSql += "   AND F1_LOJA    = D1_LOJA"
	
	cSql += "   AND D2_COD     = D1_COD"
	cSql += "   AND D2_ITEM    = D1_ITEMORI"
	
	cSql += "   AND F2_FILIAL = D2_FILIAL "
	cSql += "   AND F2_DOC = D2_DOC "
	cSql += "   AND F2_SERIE = D2_SERIE "
	cSql += "   AND F2_CLIENTE = D2_CLIENTE "
	cSql += "   AND F2_LOJA = D2_LOJA "
	
	cSql += "   AND SF2.F2_CLIENTE = SA1.A1_COD "
	cSql += "   AND SF2.F2_LOJA = SA1.A1_LOJA "
	cSql += "   AND A1_GERVEN NOT IN (" + cFiltraGer + ") "
	
	cSql += "   AND SD1.D_E_L_E_T_ = ' '"
	cSql += "   AND SF4.D_E_L_E_T_ = ' '"
	cSql += "   AND SF2.D_E_L_E_T_ = ' '"
	cSql += "   AND SF1.D_E_L_E_T_ = ' '"
	cSql += "   AND SD2.D_E_L_E_T_ = ' '"
	cSql += "   AND SA1.D_E_L_E_T_ = ' '"
	cSql += " GROUP BY A1_GERVEN "

	U_ExecMySql( cSql , cCursor := "TAUX" , cModo := "Q", lMostra := .F., lChange := .F. )
	

Return Nil 
*******************************************************************************
Static Function SlvDados( cQual, cPer) // Salva os Dados das Notas/Metas no Hash Principal
*******************************************************************************
	
	Local cCampo 	:= ""
	Local cTipo 	:= ""
	Local nValAtu 	:= 0
	Local nValor 	:= 0 
	Local nValTot	:= 0

	AjTpCpo(cQual, cPer, @cTipo, @cCampo) // Ajusta o nome do Campo e o Tipo de dado a ser alimentado 

	DbSelectArea("TAUX");DbGotop()
	While !EOF()

		nValAtu := nValor := nValTot := 0
		If HMGet( oHaPri, TAUX->GERENTE + cTipo + P_VAL, @nValAtu )
		
			// Alimenta Gerente
			nValor := &cCampo.
			HMSet( oHaPri, TAUX->GERENTE + cTipo + P_VAL, nValAtu + nValor )
			
			// Alimenta Gerente Totais 
			HMGet( oHaPri, cGerImd + cTipo + P_VAL, @nValTot 		)
			HMSet( oHaPri, cGerImd + cTipo + P_VAL, nValTot +  nValor )

			ConLog( TAUX->GERENTE + " Lanc em Totais: " + cGerImd + cTipo + P_VAL + " " +cValToChar(nValTot +  nValor))
	
			// Monta os Valores da Receita Bruta que é utilizado internamente no calculo dos indices das margens
			
			IF cTipo == FAT_TOD .And. cQual == FVEN
				ConOut("Entrou REB_TOD Gravacao ")
				If HMGet( oHaPri, TAUX->GERENTE + REB_TOD + P_VAL, @nValAtu )
					ConOut("Entrou REB_TOD Calculo ")
					// Alimenta Gerente
					nValor := TAUX->RVEN
					HMSet( oHaPri, TAUX->GERENTE + REB_TOD + P_VAL, nValAtu + nValor )
					
					// Alimenta Total 
					HMGet( oHaPri, cGerImd + REB_TOD + P_VAL, @nValTot 		)
					HMSet( oHaPri, cGerImd + REB_TOD + P_VAL, nValTot + nValor )
				Endif
			
			ElseIf cTipo == FAT_TOM .And. cQual == FVEN
				ConOut("Entrou REB_TOM Gravacao ")
				If HMGet( oHaPri, TAUX->GERENTE + REB_TOM + P_VAL, @nValAtu )
					ConOut("Entrou REB_TOM Calculo ")
					// Alimenta Gerente
					nValor := TAUX->RVEN
					HMSet( oHaPri, TAUX->GERENTE + REB_TOM + P_VAL, nValAtu + nValor )
			
					// Alimenta Gerente Totais 
					HMGet( oHaPri, cGerImd + REB_TOM + P_VAL, @nValTot 		)
					HMSet( oHaPri, cGerImd + REB_TOM + P_VAL, nValTot + nValor )
				EndIf
			Endif
			
		EndIf
	
		DbSelectArea("TAUX")
		DbSkip()
	
	EndDo

Return Nil
*******************************************************************************
Static Function AjTpCpo(cQual, cPer, cTipo, cCampo ) // Ajuta o nome do Campo e o Tipo de dado a ser alimentado 
*******************************************************************************


	//| Atualiza Dados Referente a Vendas 
	If cQual == FVEN //| Faturamento Vendas

		If cPer == "D"
			cTipo := FAT_TOD   // Faturamento s/ IPI	| Realizado Total Dia
		ElseIf cPer == "M"
			cTipo := FAT_TOM   // Faturamento s/ IPI 	| Realizado Total Mês
		ElseIf cPer == "A"
			cTipo := FAT_DMA+"F"   // Faturamento s/ IPI 	| Diferne
		EndIf
			
		cCampo := "TAUX->FVEN"

	ElseIf cQual == FMAR //| Faturamento Margem

		If cPer == "D"
			cTipo := MAR_TOD	// Margem				| Realizado Total Dia
		ElseIf cPer == "M"
			cTipo := MAR_TOM	// Margem 				| Realizado Total Mês
		EndIf

		cCampo := "TAUX->FMAR"
	
	EndIf

	//| Atualiza Dados Referente a Metas
	If cQual == MVEN //| Metas Vendas 
	
		If cPer == "M"
			cTipo := FAT_MET   // Faturamento s/ IPI	| Meta Mês
		ElseIf cPer == "A"
			cTipo := FAT_DMA+"M"   // Faturamento s/ IPI 	| Diferne
		EndIf

		cCampo := "TAUX->MVEN"
	
	ElseIf cQual == MMAR //| Metas Margem
	
		If cPer == "M"
			cTipo := MAR_MET	//Margem				| Meta Mês
		EndIf

		cCampo := "TAUX->MMAR"
	
	EndIf
	
	
	//| Atualiza Dados Referente a Devolucao
	If cQual == DVEN //| Devolucao Vendas 

		If cPer == "D"
			cTipo := FAT_TOD   // Faturamento s/ IPI	| Realizado Total Dia
		ElseIf cPer == "M"
			cTipo := FAT_TOM   // Faturamento s/ IPI 	| Realizado Total Mês
		ElseIf cPer == "A"
			cTipo := FAT_DMA+"D"   // Faturamento s/ IPI 	| Diferne
		EndIf

		cCampo := "TAUX->DVEN"

	ElseIf cQual == DMAR //| Devolucao Margem

		If cPer == "D"
			cTipo := MAR_TOD	// Margem				| Realizado Total Dia
		ElseIf cPer == "M"
			cTipo := MAR_TOM	// Margem 				| Realizado Total Mês
		EndIf

		cCampo := "TAUX->DMAR"

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
	cBody += '<br><br><font color="' + Cor_FraCab + '" face="Arial" size="5"><strong>An&aacute;lise de Metas Margem - Data Refer&ecirc;ncia: '+cValToChar(dDataRef)+ /*' - '+Time()+ */ '</strong></font><br><br>'

Return Nil
*******************************************************************************
Static Function ImpCab(cBody ) //| Monta Html com Cabecalho dos itens 
*******************************************************************************

	cBody += '<table style="font-family:Lucida Grande,sans-serif;border-collapse:collapse;width:100%;background-color:white;border:2px solid ' + Cor_Border+ ';max-width:1000px;align: center; ">'

	cBody += '<tr style="text-transform:uppercase;background-color:' + Cor_TitTot + ';color:white;border:2px solid' + Cor_Border+ ';height: 27px;">'
	cBody +=    '<th>Nome Gerente</th>'
	cBody +=    '<th>C&oacute;digo Gerente</th>'
	cBody +=    '<th>Tipo</th>'
	cBody +=    '<th>Grupo</th>'
	cBody +=    '<th>Descri&ccedil;&atilde;o</th>'
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
			
			ConLog("Enviando eMail para:" + cTo + cCo )
			
			If !lTeste /// Caso nao for Teste
				U_EnvMyMail( Nil , Lower(cTo),  Lower(cCo) ,cSubject, cHtmMail , '' , .F.,.F.,.F.,.F.,.F.,.F.)
			Else
				U_EnvMyMail( Nil , Lower(_CONTATESTE_),  ,cSubject, cHtmMail , '' , .F.,.F.,.F.,.F.,.F.,.F.)
				
			EndIf
			
			DbSelectArea("GER")
			DbSkip()

		EndDo
		
		If !lTeste /// Caso nao for Teste
		
			//| Envia para Usuarios que tambem recebem o Relatorio 
			cTo := cCo := ""
			For nP := 1 To 99
		
				cRetPos := Posicione( "SX6", 1, Space(02) + "MV_EMMOL" + StrZero(nP,2), "X6_CONTEUDO" ) //| E-mail dos Usuarios que receberao o Metas   // "MV_EMMOL01" "MV_EMMOL02" "MV_EMMOL03" "MV_EMMOL04"
				ConOut('METAS_MARGEM : cRetPos -> ' +  cRetPos )
				If !Empty(cRetPos)
					cTo := Alltrim(cRetPos)
					cCo := Alltrim(cMailRTI)
			
					ConLog("Enviando eMail para:" + cTo + cCo )
					U_EnvMyMail( Nil , Lower(cTo) , Lower(cCo) ,cSubject, cHtmMail , '' , .F.,.F.,.F.,.F.,.F.,.F.)

					cTo := cCo := ""
				Else
					nP := 99
				EndIf

			Next 
	
		EndIf
		
	EndIf

Return Nil 

*******************************************************************************
Static Function VerDDia(dDataRef) // Verifica se o dia a ser considerado no relatório deve ser expandido devido ao dia anterior ser Feriado/Sabado ou Domingo
*******************************************************************************

	Local aDia 		:= { dDataRef , dDataRef }
	Local dIni	 	:= dDataRef
	Local dAux	 	:= dIni
	Local lAvalia	:= .T.

	While lAvalia 
	
		dAux := DataValida(dIni,.F.)
		if dAux == dIni
			lAvalia := .F.
			aDia[DINI] := dAux
		Else
			dIni := dAux
		EndIf
	
	EndDo
	

Return aDia
*******************************************************************************
Static Function ConLog(cTxt)
*******************************************************************************
	
	
		ConOut("METAS_MARGEM - > " + PadR( cTxt , 100 ) + dToc(ddatabase) + " - " + Time() )
	
	
Return Nil 

