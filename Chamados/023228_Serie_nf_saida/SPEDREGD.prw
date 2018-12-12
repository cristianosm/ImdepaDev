#Include 'Totvs.ch'

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : SPEDREGD     | AUTOR : Cristiano Machado | DATA : 10/12/2018   **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** DESCRICAO : Este ponto  de  entrada  foi  disponibilizado para Geração do **
** bloco documentos  fiscais II serviço (ICMS) conforme layout  sped fiscal. **
** Bloco de  registros dos dados relativos à emissão  ou  ao  recebimento de **
** documentos fiscais que acobertam as prestações de serviço de comunicação, **
** transporte intermunicipais e interestadual.                               **
**                                                                           **
** Execblock("SPEDREGD", .F., .F., {cAlias,aLisFil})                         **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                         **
**---------------------------------------------------------------------------**
** PROGRAMADOR | DATA | MOTIVO DA ALTERACAO **
**---------------------------------------------------------------------------**
**   |  | **
**   |  | **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function SPEDREGD()
*******************************************************************************
	
	Local cAliasTRB := PARAMIXB[1] 	 //|Alias Contendo o Arquivo de Trabalho ja pronto para ser exportado....	
	Local lEnd		:=	.F.
	Local aAreaATU	:= GetArea()
	Local aAreaTRB  := (cAliasTRB)->(GetArea())

	Processa( {|lEnd|AjusSer(cAliasTRB)},"Alterando Série Nfs Imdepa" ) 	
	
	RestArea(aAreaTRB)
	RestArea(aAreaATU)
	
Return Nil
*******************************************************************************			
Static Function AjusSer(cAliasTRB)
*******************************************************************************
					
	Local cTpREg	:= SuperGetMv("IM_TPRSPED",,"C100/C110",) 			// Quais os tipos de Registros serão avaliados para Troca da Serie							// Quais Registros serao modificados ??? C100-> Notas Fiscais
	Local cSerie	:= "I"+xFilial("SFT")								// Série que deve ser Substituida
	Local cNewSer	:= SuperGetMv("IM_SERSPED",,"001",xFilial("SFT")) 	// Parametro Contendo a nova Serie a ser utilizada para Substituicao.
	Local nTamSer	:= Len(cSerie)										// Numero de caracteres que corresponde a serie
	
	Local nAlt		:= 0 
	Local nTamLin	:= 0 		//| Tamanho da Linha do tipo de Registro
	Local nPosSer 	:= 0  		//| Armazena Posicao Inicial da Serie
	Local nPosAnt 	:= 0 		//| Armazena a posicao anterior a inicial da serie
	Local nPosPos 	:= 0 		//| Armazena a posicao posterior a serie
	
	Local cTRB_CONT := ""		//| Conteudo da linha no arquivo de trabalho que sera alterado
	
	ProcRegua(0)
	
	DbSelectArea(cAliasTRB);DbGotop()
	While !EOF()
		
		IncProc("De : " + cSerie + " Para : " + cNewSer + ". " + cValToChar(nAlt) + " Alterações efetudas..." )	
		
		cTRB_CONT := (cAliasTRB)->TRB_CONT
		
		nTamLin	:= nPosSer := nPosAnt := nPosPos := 0
		
		If Alltrim((cAliasTRB)->TRB_TPREG) $ cTpREg 
		
			
			nPosSer 	:= AT(cSerie,cTRB_CONT) 
			nPosAnt 	:= nPosSer-1
			nPosPos 	:= nPosSer + nTamSer
			nTamLin		:= Len( cTRB_CONT )
			
			If nPosSer > 0 

				cTRB_CONT := Substr( cTRB_CONT , 1 , nPosAnt ) + cNewSer + Substr( cTRB_CONT ,nPosPos ,nTamLin-nPosPos )
			
				If RecLock(cAliasTRB,.F.)
					(cAliasTRB)->TRB_CONT := cTRB_CONT
					MsUnlock()
					
					nAlt += 1
					ConOut("SPEDREGD -->> ["+Alltrim(cTRB_CONT)+"] " )
					
				EndIf
				
			EndIf
		EndIf

		DbSelectArea(cAliasTRB)
		DbSkip()
		
	EndDo

Return Nil