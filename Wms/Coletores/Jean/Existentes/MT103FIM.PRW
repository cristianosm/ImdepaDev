#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#DEFINE  ENTER CHR(13)+CHR(10)

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³MT103FIM  |Autor  |Fabiano Pereira        |Data  | 16.05.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao |Operação após gravação da NFE.                               ³±±
±±|          |O ponto de entrada MT103FIM encontra-se no final da função   ³±±
±±|          |A103NFISCAL. 												   ³±±
±±|          |Após o destravamento de todas as tabelas envolvidas na       ³±±
±±|          |gravação do documento de entrada, depois de fechar a operação³±±
±±|          |realizada neste, é utilizado para realizar alguma operação   ³±±
±±|          |após a gravação da NFE. 									   ³±±
±±|          |                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       |IMDEPA - P11                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
**********************************************************************
User Function MT103FIM()
**********************************************************************
	Local aArea		:= 	GetArea()
	Local cImdepa	:=	GetMv('MV_IMDEPA')
	Local lExclui	:=	!INCLUI .And. !ALTERA

	// Jean Rehermann - Solutio IT - 27/07/2017
	Local _nOpcX  := PARAMIXB[1] // Operação (2=Visual/3=Inclui/4=Classifica/5=Exclui)
	Local _nOpc   := PARAMIXB[2] // Confirmação da tela [operação] (1=Tela confirmada/0=Tela cancelada)
	Local _cSeek  := "SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA" // Seek para loop
	Local _cChav  := SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA   // Chave para loop
	Local _lAchou := .F. // Resultado do Seek
	Local nPosDCF := 0 // Criar o DCF

	If lExclui .And. AllTrim(SF1->F1_FORNECE) == AllTrim(cImdepa)

		IIF(Select('TMPB') != 0, TMPB->( DbCloseArea()),)
		cQuery := " SELECT  SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, D1_PEDIDO, D1_ITEMPC,						"+ENTER
		cQuery += "         SC7.C7_NUM, SC7.C7_ITEM, SC7.C7_PLANILH,                             				"+ENTER
		cQuery += "         SZE.ZE_NUMPLAN, SZE.ZE_FLAGNF, SZE.R_E_C_N_O_ SZE_RECNO, SD1.R_E_C_N_O_ SD1_RECNO  	"+ENTER          
		
		cQuery += " FROM     "+RetSqlName("SD1")+" SD1 												 	 		"+ENTER
		
		cQuery += "                    INNER JOIN "+RetSqlName("SC7")+" SC7    									"+ENTER
		cQuery += "                    ON   SC7.C7_FILIAL  	=  SD1.D1_FILIAL									"+ENTER            
		cQuery += "                    AND  SC7.C7_NUM     	=  SD1.D1_PEDIDO									"+ENTER    
		cQuery += "                    AND  SC7.C7_ITEM    	=  SD1.D1_ITEMPC   									"+ENTER
		cQuery += "                    AND  SC7.C7_PRODUTO	=  SD1.D1_COD      									"+ENTER
		cQuery += "                    AND  SC7.C7_PLANILH !=  '"+Space(TamSx3('C7_PLANILH')[01])+"' 			"+ENTER
		cQuery += "                    AND  SC7.D_E_L_E_T_ !=  '*'        										"+ENTER               
		
		cQuery += "                    INNER JOIN "+RetSqlName("SZE")+" SZE   									"+ENTER
		cQuery += "                    ON   SZE.ZE_FILIAL   =   '"+xFilial('SZE')+"'         					"+ENTER
		cQuery += "                    AND  SZE.ZE_NUMPLAN  =   SC7.C7_PLANILH 									"+ENTER      
		cQuery += "                    AND  SZE.ZE_PRODUTO  =   SC7.C7_PRODUTO 									"+ENTER
		cQuery += "                    AND  SZE.ZE_DESTINO  =   SC7.C7_FILIAL 								 	"+ENTER
		cQuery += "                    AND  SZE.D_E_L_E_T_ !=  '*'         	  									"+ENTER
		
		cQuery += " WHERE	SD1.D1_FILIAL   =   '"+SF1->F1_FILIAL+"'           									"+ENTER
		cQuery += " AND		SD1.D1_DOC      =   '"+SF1->F1_DOC+"'    											"+ENTER    
		cQuery += " AND   	SD1.D1_SERIE    =   '"+SF1->F1_SERIE+"'           									"+ENTER
		cQuery += " AND		SD1.D1_FORNECE  =   '"+SF1->F1_FORNECE+"'        									"+ENTER
		cQuery += " AND		SD1.D1_LOJA     =   '"+SF1->F1_LOJA+"'            									"+ENTER
		cQuery += " AND		SD1.D_E_L_E_T_  =   '*' 															"+ENTER	// REGISTRO JA ESTA DELETADO
		
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPB",.T.,.T.)
		DbSelectArea('TMPB')
		Do While !Eof()	

			DbSelectArea('SZE')
			DbGoTo(TMPB->SZE_RECNO)		
			If SZE->(Recno()) == TMPB->SZE_RECNO
				RecLock('SZE', .F.)
					SZE->ZE_FLAGNF := Space(TamSx3('ZE_FLAGNF')[01])
				MsUnLock()
			EndIf

			DbSelectArea('TMPB')
			DbSkip()
		EndDo
	EndIf

	IIF(Select('TMPB') != 0, TMPB->( DbCloseArea()),)

   // 14/11/2018 - Atualizacao do campo FT_CONTA das notas com rateio - Chamado 21121 e 22027
   
	cQuery := " SELECT  D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA , D1_COD, D1_ITEM, B1_CONTA	"+ENTER
	cQuery += " FROM " + RetSqlName("SD1") + " SD1, " + RetSqlName("SB1") + " SB1  			 	 	    "+ENTER
	cQuery += " WHERE	SD1.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' '                                   "+ENTER 
	cQuery += " AND     D1_FILIAL   =   '"+SF1->F1_FILIAL+"'                                            "+ENTER
	cQuery += " AND		D1_DOC      =   '"+SF1->F1_DOC+"'    										    "+ENTER    
	cQuery += " AND   	D1_SERIE    =   '"+SF1->F1_SERIE+"'           								    "+ENTER
	cQuery += " AND		D1_FORNECE  =   '"+SF1->F1_FORNECE+"'        								    "+ENTER
	cQuery += " AND		D1_LOJA     =   '"+SF1->F1_LOJA+"'            								    "+ENTER
	cQuery += " AND		D1_DTDIGIT  =   '"+DTOS(SF1->F1_DTDIGIT)+"'          						    "+ENTER
	cQuery += " AND		D1_RATEIO   =   '1'                         								    "+ENTER
	cQuery += " AND		B1_FILIAL   =    D1_FILIAL                  								    "+ENTER
	cQuery += " AND		B1_COD      =    D1_COD                      								    "+ENTER


	U_ExecMySql(cQuery,"TP01","Q")
	DbSelectArea('TP01')

	IF ! ( TP01->( bof() ) .and. TP01->( eof() ) )

			While ! Eof()

				cQuery := " UPDATE " + RetSqlName("SFT")    + "                "+ENTER
				cQuery += " SET FT_CONTA = '"+TP01->B1_CONTA+"'                "+ENTER 
				cQuery += " WHERE D_E_L_E_T_ =  ' '                            "+ENTER
				cQuery += " AND FT_FILIAL = '"+SF1->F1_FILIAL+"'               "+ENTER
				cQuery += " AND FT_NFISCAL = '"+SF1->F1_DOC+"'                 "+ENTER      
				cQuery += " AND FT_SERIE =  '"+SF1->F1_SERIE+"'                "+ENTER
				cQuery += " AND FT_CLIEFOR = '"+SF1->F1_FORNECE+"'             "+ENTER
				cQuery += " AND FT_LOJA = '"+SF1->F1_LOJA+"'                   "+ENTER 
				cQuery += " AND FT_ENTRADA = '"+DTOS(SF1->F1_DTDIGIT)+"'       "+ENTER
				cQuery += " AND FT_PRODUTO = '"+TP01->D1_COD+"'                "+ENTER
				cQuery += " AND FT_ITEM = '"+TP01->D1_ITEM+"'                  "+ENTER

				U_ExecMySql(cQuery,"","E",.F.)

				DbSkip()

			Enddo

	Endif

	TP01->( DbCloseArea())
	RestArea(aArea)

	// Jean Rehermann - Solutio IT - 27/07/2017
	// Gravação de campos extras ao final da inclusão ou classificação (D1_SERVIC e D1_ENDER)

	// Se for inclusão ou classificação e a tela for confirmada e o tipo da nota for normal
	If ( _nOpcX == 3 .Or. _nOpcX == 4 ) .And. _nOpc == 1 .And. SF1->F1_TIPO == "N" .And. IntDL()

		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSeek( _cChav )
		
		// Verificar cada item da nota
		While !SD1->( Eof() ) .And. _cChav == &( _cSeek )
			
			// Se NAO foi informado o endereço e o serviço, se o status do serviço for '1' e o TES atualiza estoque
			If Empty( SD1->D1_ENDER ) .And. Empty( SD1->D1_SERVIC ) .And. SD1->D1_STSERV == "1" .And. Posicione("SF4", 1, xFilial("SF4") + SD1->D1_TES, "F4_ESTOQUE") == "S"
				
				SB5->( DbSetOrder(1) )
				_lAchou := SB5->( dbSeek( xFilial("SB5") + SD1->D1_COD, .F.) )
				
				// Busco no SB5 o serviço e endereço de entrada padrão, se existir
				RecLock( "SD1", .F. )
					D1_SERVIC := Iif( _lAchou .And. !Empty( SB5->B5_SERVENT ), SB5->B5_SERVENT, "003"  )
					D1_ENDER  := Iif( _lAchou .And. !Empty( SB5->B5_ENDENT ) , SB5->B5_ENDENT , "DOCA" )
				SD1->( MsUnLock() )
				
				WmsCriaDCF('SD1',,,,@nPosDCF ) // Cria o DCF quando não for informado ENDERECO nem SERVICO
			
			Endif
			
			SD1->( dbSkip() )
		End

	EndIf

	RestArea(aArea)

Return()