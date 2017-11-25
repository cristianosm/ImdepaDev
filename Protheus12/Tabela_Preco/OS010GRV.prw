#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#DEFINE  ENTER CHR(13)+CHR(10)

#Define __P12 "12"
#Define __P11 "11"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OS010GRV ºAutor  ³ Cesar Mussi        º Data ³  07/08/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Forca a gravacao da alteração na Tabela de preço por       º±±
±±º          ³ Ponto de entrada após a gravação da tabela de preço.	 	  º±±  
±±º          ³                                                            º±±  
±±º          ³                                                            º±±  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Imdepa                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
********************************************************************
User Function OS010GRV()
********************************************************************

Local aLog		:= {}
Local cLog		:= ''
Local cTipo		:= ParamIxb[01]			//	Tipo (1-Tabela/2-Produto)
Local cOpcao	:= ParamIxb[02]			//	Opção(1-Inclusao/2-Alteracao/3-Exclusao)
Local nPosRecno := Ascan(_aHeader, {|z| AllTrim(z[2]) == "DA1_REC_WT"})
Local  _cVersao_ := GetVersao(.F.)


If Altera .And. nPosRecno > 0

	If  cOpcao != 3 //cTipo == 2 .And. cOpcao != 3

		Begin Transaction

			For nX := 1 To Len(_aCols)
	
				nRecnoDA1 	:=	_aCols[nX][nPosRecno]
				DbSelectArea("DA1")
				DbGoTo(nRecnoDA1)
				lGrava	  := IIF(DA1->(Recno()) == nRecnoDA1, .F., .T.)
				lDeletado := _aCols[nX][Len(_aHeader)+1]


				If !lDeletado
			
					RecLock('DA1', lGrava)
						For nY := 1 To Len(_aHeader)
							If _aHeader[nY][10] != "V"                                    
								cCampo 		:= 	_aHeader[nY][02]
								cConteudo 	:=	_aCols[nX][nY]
								DA1->(FieldPut(FieldPos(cCampo), cConteudo))
							EndIf
						Next
						
						DA1->DA1_FILIAL := xFilial('DA1')
						DA1->DA1_INDLOT := StrZero(DA1->DA1_QTDLOT,18,2)
						
						// APENAS ITENS INCLUSOS ENVIARA EMAIL
						If lGrava
		                	Aadd(aLog, DA1->DA1_FILIAL+';'+AllTrim(DA1->DA1_CODPRO)+';'+cValToChar(DA1->DA1_PRCVEN)+';'+cValToChar(DA1->DA1_MOEDA)+';'+IIF(lGrava, 'INCLUSAO', 'ALTERACAO'))
						EndIf
						
					MsUnlock()
					
				Else

					If !lGrava					//	!lGrava ENCONTROU REGISTRO NO DA1.
						
						//cLog  += DA1->DA1_FILIAL+';'+AllTrim(DA1->DA1_CODPRO)+';'+cValToChar(DA1->DA1_PRCVEN)+';'+cValToChar(DA1->DA1_MOEDA)+';DELETADO'+ENTER
						
						RecLock('DA1', lGrava)					
							DbDelete()
						MsUnlock()
	
					EndIf

				EndIf
			
				
				
			Next


		End Transaction
	

		If Len(aLog) > 0
			LogEmail(aLog)
		EndIf
	
	EndIf

EndIf
	

	
_aHeader := {}
_aCols   := {}
	

Return()   
********************************************************************
Static Function LogEmail(aLog)
********************************************************************
cDateTime 	:= 	DtoS(dDataBase)+'__'+StrTran(Time(),':','_')
cDirSrv  	:= 	'\csv_import\'
cNomeArq	:=	cDirSrv+'_'+cDateTime+'_GRAVA_DA1.TXT'
cArqLog		:=	FCREATE(cNomeArq)	//MemoWrite(cArqLog, cLog)

FWRITE( cArqLog, 'FILIAL;PRODUTO;PRECO;MOEDA'+ENTER)
For nL := 1 To Len(aLog)        
	FWRITE(cArqLog, aLog[nL]+ENTER)
Next
FCLOSE(cArqLog)
FT_FUSE()	


cHtml := '<html>'
cHtml += '<head>'
cHtml += '<h3 align = Left><font size="2" face="Verdana" color="#483D8B">Log Gravação .csv X Tabela de Preço</h3></font>'
cHtml += '<br></br>'
cHtml += '<b><font size="2" face="Verdana">Filial: '+cFilAnt+'-'+AllTrim(SM0->M0_FILIAL)+' </font></b>'
cHtml += '<br></br>'
cHtml += '<b><font size="2" face="Verdana">Tabela: '+DA0->DA0_CODTAB+'-'+AllTrim(DA0->DA0_DESCRI)+' </font></b>'
cHtml += '<br></br>'
cHtml += '<br></br>'
cHtml += '<b><font size="2" face="Verdana">Gravado em: </font></b>'
cHtml += '<b><font size="2" face="Verdana">'+Dtoc(Date())+' às '+Time()+'</font></b>'	//	color="#0000FF"
cHtml += '<br></br>'
cHtml += '</head>'
cHtml += '<body bgcolor = white text=black>'
cHtml += '<hr width=100% noshade>'
cHtml += '<br></br>'


IIF(!ExisteSX6('IMD_CSVDA1'),	CriarSX6('IMD_CSVDA1', 'C','Envia e-mail ao importar .csv x DA1', 'luana' ),)	
cParEnvia := AllTrim(GetMv('IMD_CSVDA1'))

cRotina		:=	'OS010GRV'
cAssunto	:=	'Log Gravação .csv X Tabela de Preço'
cPara		:=  cParEnvia
cCopia		:=	''
cCopOcult	:=	'' //'fabiano.pereira@solutio.inf.br'
cCorpoEmail	:=	cHtml
cAtachado	:=	cNomeArq

U_ENVIA_EMAIL(cRotina, cAssunto, 'cristiano.machado@imdepa.com.br' /*cPara*/, /*cCopia*/, /*cCopOcult*/, cCorpoEmail, cAtachado)
FErase(cNomeArq)

Return()
********************************************************************
User Function GATFAT()
********************************************************************
//  Velho Fator	
If aCols[n,7] > 0
    // Preciso desfazer o fator antigo
	// Atualiza novo preco (desfazendo o fator antigo)
	aCols[n,5]:= Round(aCols[n,5] / aCols[n,7],4)
EndIf

// Novo Fator 
If M->DA1_PERDES > 0 
	aCols[n,5]:= Round(aCols[n,5] * M->DA1_PERDES,4)
EndIf

Return(.T.)