#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "Tbiconn.ch"
#Include "Totvs.ch"

#Define _ENTER_  CHR(13) + CHR(10)


*******************************************************************************
User function QUERYTST()
*******************************************************************************
	Local cBody := ''
	Local cItem := ''

	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '05' FUNNAME "QUERYTST" TABLES 'SX6'

	U_ExecMySql('SELECT DTEHR, PASSO, SUBPAS, TEXTO FROM LOG_VE3 ORDER BY DTEHR, PASSO, SUBPAS','TLOG','Q',.F.,.F.)

	cBody += TratHtml('Cab')

	DbSelectArea('TLOG')
	DbGotop()
	While !EOF()

		cItem := ''
		cItem += '<tr>'

		cItem += '<td>'	+ TLOG->DTEHR  			  	+ '</td>'
		cItem += '<td>'	+ cValToChar(TLOG->PASSO)  	+ '</td>'
		cItem += '<td>'	+ cValToChar(TLOG->SUBPAS) 	+ '</td>'
		cItem += '<td id="Texto">'	+ TLOG->TEXTO  	+ '</td>'

		cItem += '</tr>'

		cBody += cItem

		DbSkip()
	EndDO

	cBody += TratHtml('Rod')

	
	U_EnvMyMail('','cristiano.machado@imdepa.com.br',,'teste',cBody,'',.F.)

	If Iw_MsgBox('Ver Texto','Atencao','YESNO')
		U_ExecMySql( cBody ,'','Q',.T.,.T.)
	EndIf
	
	Reset Environment

return Nil
*******************************************************************************
Static Function TratHtml(cPar)
*******************************************************************************
	Local cHtml := ''

	If cPar == 'Cab'

		//cHtml += '<!DOCTYPE html>'
		
		cHtml += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional //EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
		cHtml += '<html>'
		cHtml += '<head>'
		//cHtml += '<meta content="text/html; charset=ISO-8859-1" http-equiv="content-type"> '
		cHtml += '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"</meta>'
		
		// Estilos
		cHtml += '<style> '
		cHtml += 'table {width:100%;} '
		cHtml += 'th, td { padding: 3px; text-align: center; } '
		cHtml += 'table tr:nth-child(even) {background-color: #eee;} '
		cHtml += 'table tr:nth-child(odd) {background-color:#fff;} '
		cHtml += 'table th {background-color: black;color: white;} '
		cHtml += 'td#Texto {text-align: left;} '
		cHtml += '</style> '
		cHtml += '</head> '

		cHtml += '<br><br> '
		cHtml += '<h1>Abaixo segue Log de execucao da Procedure VE3 ...</h1> '
		cHtml += '<br><br><br> '

		// Corpo
		cHtml += '<body style="width: 920px;"> '
		


		// Tabela e Cabecalho
		cHtml += '<table>' 
		cHtml += '<tr>'
		cHtml += '<th width: 150px;>DATA-HORA</th>'
		cHtml += '<th width: 50px;>PASSO</th>'
		cHtml += '<th width: 50px;> SUB-PASSO</th>'
		cHtml += '<th width: 514px;>TAREFA</th>'
		cHtml += '</tr>'

	ElseIf cPar == 'Rod'

		
		cHtml += '<tbody></tbody></table><br><br>'
		cHtml += '</body>'
		cHtml += '</html>'

	EndIf

Return cHtml