#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'tbiconn.ch'

#Define CRLF ( chr(13) + chr(10) )

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNCAO   : ISendTaf     | AUTOR : Cristiano Machado  | DATA : 30/04/2003  **
**---------------------------------------------------------------------------**
** DESCRICAO: Workflow para envio do Lembrete da agenda do vendedor          **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente Imdepa Rolamentos                    **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
** Marcio Q. Borges|05/09/2007|Considerar todas as filiais cadastradas no    **
**                 |          |sistema sem necessidade de config. parametros **
**---------------------------------------------------------------------------**
**                 |          |                                              **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function ISendTaf()
*******************************************************************************

	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "05" FUNNAME 'ISendTaf'  TABLES 'SM0','AD8'

	Private cArqTab := "STAV"
	
	Conout('ISENTAF - Inicio - ' + DToC(dDataBase) + ' ' + Time() )
	Conout('ISENTAF - Verificando Tarefas - ' + DToC(dDataBase) + ' ' + Time() )
	
	If SelTarefas(cArqTab) //| Seleciona os Lembretes das Tarefas dos Vendedores.

		EnvTarefas(cArqTab)//| Envia os Lembretes aos Vendedores.
		Conout('ISENTAF - Enviando Tarefas - ' + DToC(dDataBase) + ' ' + Time() )

	EndIf
	
	Conout('ISENTAF - Fim - ' + DToC(dDataBase) + ' ' + Time() ) 
	RESET ENVIRONMENT

Return()
*******************************************************************************
Static Function SelTarefas(cArqTab)
*******************************************************************************

	Local cSql 		:= ""
	Local lReturn 	:= .T.

	cSql += "SELECT AD8_TAREFA TAREFA,AD8_TOPICO ASSUNTO,AD8_NROPOR OPORTUNIDADE,AD8_DTINI INICIO,AD8_DTFIM TERMINO,AD8_DTREMI LEMBRETE,AD8_HRREMI HRLEMBRE, "
	cSql += "      CASE  "
	cSql += "        WHEN AD8_STATUS = '1' THEN 'NAO INICIADA' "
	cSql += "        WHEN AD8_STATUS = '2' THEN 'EM ANDAMENTO' "
	cSql += "        WHEN AD8_STATUS = '3' THEN 'COMPLETADA' "
	cSql += "        WHEN AD8_STATUS = '4' THEN 'SUSPENCA' "
	cSql += "        WHEN AD8_STATUS = '5' THEN 'ENCERRADA' "
	cSql += "        ELSE 'INDEFINIDA' "
	cSql += "      END SITUACAO, "
	cSql += "      CASE  "
	cSql += "        WHEN AD8_PRIOR = '1' THEN 'BAIXA' "
	cSql += "        WHEN AD8_PRIOR = '2' THEN 'NORMAL' "
	cSql += "        WHEN AD8_PRIOR = '3' THEN 'ALTA' "
	cSql += "      END PRIORIDADE, "
	cSql += "      AD8_PERC COMPLETO, "
	cSql += "      CASE  "
	cSql += "        WHEN AD8_CODCLI > ' ' THEN 'C:' || AD8_CODCLI || '.' || AD8_LOJCLI || '-' || SA1.A1_NOME "
	cSql += "        WHEN AD8_PROSPE > ' ' THEN 'P:' || AD8_PROSPE || '.' || AD8_LOJPRO || '-' || SUS.US_NOME "
	cSql += "        ELSE 'NAO INFORMADO' "
	cSql += "      END ENTIDADE, "
	cSql += "      NVL(AD8_COMENTARIO, ' ') COMENTARIO, "
	cSql += "      AD8.R_E_C_N_O_ AD8RECNO, "
	cSql += "      SA3.A3_NOME NOMEVEN, "
	cSql += "      SA3.A3_EMAIL    EMAIL "

	cSql += "FROM AD8010 AD8 LEFT JOIN "
	cSql += "    ( SELECT YP_CHAVE, LISTAGG(REPLACE(TRIM(YP_TEXTO),'\13\10',' '), ' ') "
	cSql += "      WITHIN GROUP (ORDER BY YP_SEQ) AD8_COMENTARIO "
	cSql += "      FROM SYP010  "
	cSql += "      WHERE D_E_L_E_T_ = ' ' "
	cSql += "      GROUP BY YP_CHAVE) COM "
	cSql += "ON  AD8.AD8_CODMEM = COM.YP_CHAVE "

	cSql += "	LEFT JOIN SA1010 SA1 "
	cSql += "ON  AD8_CODCLI = SA1.A1_COD "
	cSql += "AND AD8_LOJCLI = SA1.A1_LOJA "

	cSql += "   LEFT JOIN SUS010 SUS  "
	cSql += "ON  AD8.AD8_PROSPE = SUS.US_COD "
	cSql += "AND AD8.AD8_LOJPRO = SUS.US_LOJA "

	cSql += "LEFT JOIN SA3010 SA3 "
	cSql += "ON  SA3.A3_CODUSR = AD8.AD8_CODUSR "

	cSql += "WHERE AD8.D_E_L_E_T_ = ' ' "
	cSql += "AND AD8.AD8_DTREMI = '"+DTOS(DDataBase)+"' "
	cSql += "AND AD8.AD8_HRREMI < '"+Substr(Time(),1,5)+"' "
	cSql += "AND AD8.AD8_WFST = ' ' "
	cSql += "AND SA3.D_E_L_E_T_ = ' ' "

	cSql += "ORDER BY AD8.AD8_TAREFA "

	U_ExecMySql(cSql, cArqTab, "Q"  , lShowSql := .F., .F. )

	TCSetField ( cArqTab, "INICIO"  , "D", 8, 0 )
	TCSetField ( cArqTab, "TERMINO" , "D", 8, 0 )
	TCSetField ( cArqTab, "LEMBRETE", "D", 8, 0 )

	DbSelectArea(cArqTab)
	If EOF()
		lReturn := .F.
	End

Return(lReturn)
*******************************************************************************
Static Function EnvTarefas(cArqTab)
*******************************************************************************
	Local cHtml := ""
	
	DbSelectArea(cArqTab);DbGotop()
	While !EOF()

		MontaHTML(@cHtml)

		SendMail(cHtml)

		DbSelectArea(cArqTab)
		DbSkip()

	EndDo

Return()
*******************************************************************************
Static Function MontaHTML(cHtml)
*******************************************************************************
	Local cHtml := ""

	cHtml := '<html>'	+ CRLF
	cHtml += '<head>'	+ CRLF
	cHtml += '<title>Tarefas do Vendedor</title>' + CRLF
	cHtml += '</head>' + CRLF

	cHtml += '<body bgcolor=white text=black  >' + CRLF
	
	cHtml += '<h3 align=center>Tarefas do Vendedor   ' + Alltrim((cArqTab)->NOMEVEN) + '</h3>' + CRLF
	
	cHtml += '<br><hr>'
	cHtml += '<br> Lembrete Agendado Para : <b>' 	+ cValToChar((cArqTab)->LEMBRETE)+' '+cValToChar((cArqTab)->HRLEMBRE)+ '</b>' + CRLF
	cHtml += '<br><hr>'
	cHtml += '<br>N.Tarefa: <b>' 	+ cValToChar( (cArqTab)->TAREFA			) + '</b>' + CRLF
	cHtml += '<br>Oportunidade: <b>'+ cValToChar( (cArqTab)->OPORTUNIDADE	) + '</b>' + CRLF
	cHtml += '<br>Assunto: <b>' 	+ cValToChar( (cArqTab)->ASSUNTO		) + '</b>' + CRLF
	cHtml += '<br>Inicio: <b>' 		+ cValToChar( (cArqTab)->INICIO			) + '</b>' + CRLF
	cHtml += '<br>Termino: <b>' 	+ cValToChar( (cArqTab)->TERMINO		) + '</b>' + CRLF
	cHtml += '<br>Situacao: <b>' 	+ cValToChar( (cArqTab)->SITUACAO		) + '</b>' + CRLF
	cHtml += '<br>Prioridade: <b>' 	+ cValToChar( (cArqTab)->PRIORIDADE		) + '</b>' + CRLF
	cHtml += '<br>Completo: <b>' 	+ cValToChar( (cArqTab)->COMPLETO  )+' %' + '</b>' + CRLF
	cHtml += '<br>Entidade: <b>' 	+ cValToChar( (cArqTab)->ENTIDADE		) + '</b>' + CRLF
	cHtml += '<br>Comentario: <b>' 	+ cValToChar( (cArqTab)->COMENTARIO		) + '</b>' + CRLF
	cHtml += '<br><hr>'

	cHtml += '<br></a>' + CRLF

	cHtml += '</body></html>' + CRLF
/*
	If File( '\Workflow\ImdF100b.html')
		fErase( '\Workflow\ImdF100b.html' )
	EndIf

	nArq := fCreate( '\Workflow\ImdF100b.html' )
	fWrite( nArq, cHtml )
	fClose( nArq )
*/
Return()
*******************************************************************************
Static Function SendMail(cHtml)
*******************************************************************************

	Local cFrom 	:= 'protheus@imdepa.com.br'
	Local cTo 		:= (cArqTab)->EMAIL 
	//Local cTo 		:= 'cristiano.machado@imdepa.com.br'
	Local cCC 		:= ''
	Local cSubject 	:= 'Agenda Imdepa - ' + DtoC( dDataBase ) + ' ' + Time()
	Local cBody		:= cHtml
	Local cAtach	:= ''
	Local cErro		:= ''
	
	
	cErro := U_EnvMyMail(cFrom,cTo,cCC,cSubject,cBody,cAtach,.F.)//| U_EnvMyMail(De, Para, Copia, Assunto, Corpo, Anexo )
	
	If Empty(cErro) // Enviado com Sucesso...
		MarkLembrete((cArqTab)->AD8RECNO)
	EndIf
	
Return()
*******************************************************************************
Static Function MarkLembrete(nRecno)
*******************************************************************************

	DbSelectArea("AD8");Dbgoto(nRecno)
	
	AD8->( RecLock( 'AD8', .F. ) )
	AD8->AD8_WFST := 'S'
	AD8->( MsUnlock() )

Return()