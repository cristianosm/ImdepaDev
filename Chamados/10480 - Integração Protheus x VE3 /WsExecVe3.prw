#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "Tbiconn.ch"
#Include "Totvs.ch"

//|****************************************************************************
//| Projeto:
//| Modulo :
//| Fonte : WsExecVe3
//| 
//|************|******************|*********************************************
//|    Data    |     Autor        |                   Descricao
//|************|******************|*********************************************
//| 25/01/2017 | Cristiano Machado| Funcao responsavel por disparar a execucao do exporte dos arquivos VE3
//|            |                  | Ele chama a execucao da Procedure principal .
//|            |                  |  
//|            |                  |  
//|            |                  |  
//|************|***************|***********************************************
*******************************************************************************
User Function WsExecVe3()
*******************************************************************************
	
	//Variaveis Environment
	Local cEmp := '01'			//| Codigo da empresa
	Local cFil := '05'			//| Codigo da Filial
	Local cFun := 'WsExecVe3'	//| Nome da funcao 
	
	//Variaveis Procedure
	Local cNameProc := 'IVE3_0_PRINCIAL' 
	Local aRetProc  := {}				//| Armazena o retorno da Execucao da Procedure
	Local cRetProc  := ''				
 	
 	//PREPARE ENVIRONMENT EMPRESA '01' FILIAL '05' FUNNAME "QUERYTST" TABLES 'SX6'
 	 	
 	Prepare Environment Empresa cEmp Filial cFil FunName cFun Tables 'SX6'  

 		Conout( cNameProc + 'Inicio do Processo ' + cValToChar(dDatabase) + '  ' + Time() )
	  

 		// Dispara a execucao da Procedure Principal da VE3....
 		//aRetProc := TCSPEXEC(cNameProc)

 		IF Len(aRetProc) < 0 
 			cRetProc := cNameProc + ' Erro na execucao da Procedure : ' + TcSqlError() 
 		   	Conout(cRetProc)
 		Else
 			cRetProc := cNameProc + ' Procedure Executada '
 			Conout(cRetProc)
 		Endif
 		
 		//cCorpo += cRetProc

 		// Obtem o log e envia email com informacoes do log...
 		MLogMail()
 		
 		Conout( cNameProc + 'Fim do Processo ' + cValToChar(dDatabase) + '  ' + Time() )
 	 
	Reset Environment 

Return Nil
*******************************************************************************
Static Function MLogMail()// Obtem o log e envia email com informacoes do log...
*******************************************************************************
	//Variaveis Email 
	Local cPara     := 'cristiano.machado@imdepa.com.br'
	Local cAssunto  := 'Integracao VE3'
	Local cIMAgVe3  := AllTrim(GetMv('IM_EAGEVE3'))
	

 	Local cCorpo	:= ' '
	Local cItem 	:= ' '
	
	U_ExecMySql('SELECT DTEHR, PASSO, SUBPAS, TEXTO FROM LOG_VE3 ORDER BY DTEHR, PASSO, SUBPAS','TLOG','Q',.F.,.F.)

	TratHtml('Cab', @cCorpo)

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

		cCorpo += cValToChar(cItem)

		DbSkip()
	EndDO

	TratHtml('Rod', @cCorpo)

	
	U_EnvMyMail( Nil, 'cristiano.machado@imdepa.com.br', Nil, 'teste', cCorpo, Nil, .F.)

Return Nil
*******************************************************************************
Static Function TratHtml(cPar, cCorpo)
*******************************************************************************
	Local cHtml := ''

	If cPar == 'Cab'

		
		cHtml += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional //EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
		cHtml += '<html>'
		cHtml += '<head>'

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
		cHtml += '<th width: 50px; >PASSO</th>'
		cHtml += '<th width: 50px; >SUB-PASSO</th>'
		cHtml += '<th width: 514px;>TAREFA</th>'
		cHtml += '</tr>'

	ElseIf cPar == 'Rod'

		cHtml += '<tbody></tbody></table><br><br>'
		cHtml += '</body>'
		cHtml += '</html>'

	EndIf
	
	cCorpo += cValToChar(cHtml)
	
Return cHtml 