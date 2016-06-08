#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'TOTVS.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMDA840   บAutor  ณEdivaldo Gon็alves   บ Data ณ  06/04/13  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Lista o pre็o de venda por filial                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Imdepa                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function IMDA840()

	Local cperg	 := 'MDA840'
	Local aDados    := {}
	Local lOk

	Private aListBox:={}

	aAdd(aDados,{ "Saida para ?" ,"","" ,"mv_ch1","N", 1,0,0,"C",""        ,"mv_par01","Excel","Excel","Excel","","","Tela","Tela","Tela","","","","","","","","","","","","","","","","","","","" })
	aAdd(aDados,{ "Do Produto  ?","Do Produto ?","Do Produto ?","mv_ch2","C", 15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","" })
	aAdd(aDados,{ "At้ o Produto ?","At้ o Produto ?","At้ o Produto ?","mv_ch3","C", 15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","" })
	aAdd(aDados,{ "Do Grupo ?"   	,"Do Grupo ?"   ,"Do Grupo ?"   ,"mv_ch4","C", 4,0,0,"G",""		  ,"mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","" })
	aAdd(aDados,{ "At้ o Grupo ?" ,"At้ o Grupo ?"   ,"At้ o Grupo ?"   ,"mv_ch5","C", 4,0,0,"G",""		  ,"mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","" })
	aAdd(aDados,{ "Do Sub Grupo 1 ?" ,"Do Sub Grupo 1 ?"   ,"Do Sub Grupo 1 ?"   ,"mv_ch6","C", 6,0,0,"G",""		  ,"mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SZA","","" })
	aAdd(aDados,{ "At้ o Sub Grupo 1 ?" ,"At้ o Sub Grupo 1 ?" ,"At้ o Sub Grupo 1 ?"   ,"mv_ch7","C", 6,0,0,"G",""		  ,"mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SZA","","" })
	aAdd(aDados,{ "Do Sub Grupo 2 ?" ,"Do Sub Grupo 2 ?" ,"Do Sub Grupo 2 ?"   ,"mv_ch8","C", 6,0,0,"G",""		  ,"mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SZB","","" })
	aAdd(aDados,{ "At้ o Sub Grupo 2 ?" ,"At้ o Sub Grupo 2 ?" ,"At้ o Sub Grupo 2 ?"   ,"mv_ch9","C", 6,0,0,"G",""		  ,"mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","SZB","","" })
	aAdd(aDados,{ "Da Marca          ?" ,"Da Marca          ?" ,"Da Marca       ?"  ,"mv_cha","C", 20,0,0,"G",""	 ,"mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","ZZW ","","" })
	aAdd(aDados,{ "At้ a Marca       ?" ,"At้ a Marca       ?" ,"At้ a Marca    ?"  ,"mv_chb","C", 20,0,0,"G"," "   ,"mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","ZZW ","","" })
	aAdd(aDados,{ "Da curva          ?" ,"Da curva          ?" ,"Da curva       ?"  ,"mv_chc","C",  4,0,0,"G"," "   ,"mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","IM1 ","","" })
	aAdd(aDados,{ "At้ a curva       ?" ,"At้ a curva       ?" ,"At้ a curva    ?"  ,"mv_chd","C",  4,0,0,"G"," "   ,"mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","IM1 ","","" })

	AjustaSx1( cPerg, aDados )

	If Pergunte(cPerg,.T.)
        // Consulta os produtos de acordo com os parโmetros definidos
		MsAguarde({|| lOk := IMDA840IT()},OemToAnsi("Aguarde..."),OemToAnsi("Selecionando Produtos..."))

		If lOk
			If MV_PAR01 == 1   // Execu็ใo Modo Excel
				MsAguarde({|| xArqToExcel()},OemToAnsi("Arquivo Excel"),OemToAnsi("Gerando Arquivo..."))
			Else          // Execu็ใo Modo Tela
				IMDA840TELA()
			Endif
		Endif

	Endif

Return


	/*/
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
	ฑฑณFuncao    ณ IMDA840IT ณAutor ณEdivaldo Gon็alves ณ Data    ณ 23/03/13  ณฑฑ
	ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
	ฑฑณDescriao ณ Processamento para selecionar os produtos X pre็o de Venda ณฑฑ
	ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
	ฑฑณSintaxe   ณIMDA840IT()                                                  ณฑฑ
	ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
	ฑฑณParametrosณ                                                            ณฑฑ
	ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
	ฑฑณRetorno   ณ NIL                                                        ณฑฑ
	ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
	ฑฑณUso       ณ IMDEPA                                                     ณฑฑ
	ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	/*/
Static Function IMDA840IT()
	LOCAL nI
	LOCAL aStru := {}
	LOCAL cQuery
	LOCAL cClassVe


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Seleciona os Produtos                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	CriaArq()  // Cria Arquivo de Trabalho



	If MV_PAR01 == 2   // Execu็ใo Modo Tela

		@ 032,02 LISTBOX oListBox FIELDS HEADER OemToAnsi(" "),OemToAnsi("FILIAL"),OemToAnsi("PRODUTO"),OemToAnsi("DESCRIวรO"),OemToAnsi("CODITE"),OemToAnsi("CLASSVE"),OemToansi("B1_OBSTPES"),OemToAnsi("DESC ESPECIAL"),OemToAnsi("PREวO VENDA"),OemToAnsi("PREวO BASE")  SIZE 390,150;

// Preenche o array com os produtos
			DbSelectArea("_TEMP");DbGotop()
		While !Eof()


			SB1->( DbGoto(_Temp->RECNO_SB1) )
			DA1->( DbGoto(_Temp->RECNO_DA1) )
			IM1->( DbGoto(_Temp->RECNO_IM1) )
			ZA7->( DbGoto(_Temp->RECNO_ZA7) )

/*
			DbSelectArea("TRB_PRCVEND")
			Reclock("TRB_PRCVEND",.T.)
			TRB_PRCVEND->ZA7_FILIAL	:= ZA7->ZA7_FILIAL
			TRB_PRCVEND->ZA7_CODPRO	:= ZA7->ZA7_CODPRO
			TRB_PRCVEND->B1_DESC		:= SB1->B1_DESC
			TRB_PRCVEND->B1_CODITE	:= SB1->B1_CODITE
			TRB_PRCVEND->B1_CLASSVE	:= SB1->B1_CLASSVE
			TRB_PRCVEND->B1_OBSTPES	:= SB1->B1_OBSTPES
			TRB_PRCVEND->ZA7_PROMES	:= ZA7->ZA7_PROMES
			TRB_PRCVEND->DA1_PRCVEN	:= DA1->DA1_PRCVEN
			TRB_PRCVEND->PRC_VENDA	:= DA1->DA1_PRCVEN +((DA1->DA1_PRCVEN * ZA7->ZA7_PROMES)/100)
			TRB_PRCVEND->DA1_PRCMAN	:= DA1->DA1_PRCMAN
			TRB_PRCVEND->IM1_COD		:= IM1->IM1_COD
			TRB_PRCVEND->IM1_MARKUP	:= IM1->IM1_MARKUP
			TRB_PRCVEND->IM1_DESC	:= IM1->IM1_DESC
			Msunlock()

*/

  //1=Normal;2=Especial;3=Manual(Desc Filial)
/*
		Do Case
		Case TRB_PRCVEND->B1_CLASSVE=='1'
			cClassVe:=TRB_PRCVEND->B1_CLASSVE+'-Normal'
		Case TRB_PRCVEND->B1_CLASSVE=='2'
			cClassVe:=TRB_PRCVEND->B1_CLASSVE+'-Especial'
		Case TRB_PRCVEND->B1_CLASSVE=='3'
			cClassVe:=TRB_PRCVEND->B1_CLASSVE+'-Manual(Desc Filial)'
		End Case

		aAdd(aListBox,{.T.,TRB_PRCVEND->ZA7_FILIAL,TRB_PRCVEND->ZA7_CODPRO,Alltrim(TRB_PRCVEND->B1_DESC),Alltrim(TRB_PRCVEND->B1_CODITE),cClassVe,TRB_PRCVEND->B1_OBSTPES,TRB_PRCVEND->ZA7_PROMES,TRB_PRCVEND->PRC_VENDA,TRB_PRCVEND->DA1_PRCMAN,IM1_COD,IM1_MARKUP,IM1_DESC })
*/


			Do Case
			Case SB1->B1_CLASSVE =='1'
				cClassVe:=SB1->B1_CLASSVE +'-Normal'
			Case SB1->B1_CLASSVE =='2'
				cClassVe:=SB1->B1_CLASSVE +'-Especial'
			Case SB1->B1_CLASSVE =='3'
				cClassVe:=SB1->B1_CLASSVE +'-Manual(Desc Filial)'
			End Case

			nPRC_VENDA	:= DA1->DA1_PRCVEN +((DA1->DA1_PRCVEN * ZA7->ZA7_PROMES)/100)

			aAdd(aListBox,{.T.,ZA7->ZA7_FILIAL,ZA7->ZA7_CODPRO,Alltrim(SB1->B1_DESC),Alltrim(SB1->B1_CODITE),cClassVe,SB1->B1_OBSTPES,ZA7->ZA7_PROMES,nPRC_VENDA,DA1->DA1_PRCMAN,IM1->IM1_COD,IM1->IM1_MARKUP,IM1->IM1_DESC })


			DbSelectArea("_TEMP")
			dbSkip()
			IncProc()
		Enddo
//Fecha o arquivo ap๓s a carga do aRRay
		TRB_PRCVEND->( dbCloseArea() )

		If Len(aListbox) == 0
			IW_MsgBox("Nใo Hแ Registro com os parโmetros selecionados !","Aten็ใo","INFO")
		Return .F.
		Endif

	Endif

Return .T.



	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
	ฑฑบFuncao    ณIMDA840TELAบ Autor ณ Edivaldo Gon็alves   บ Data ณ 23/05/2013  บฑฑ
	ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
	ฑฑบDescricao ณ Exibe a tela com os produtos X Pre็o de Venda                บฑฑ
	ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
	ฑฑบUso       ณ IMDEPA                                                       บฑฑ
	ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
	/*/
Static Function IMDA840TELA()

	Private oDlg, oListbox

	DEFINE MSDIALOG oDlg TITLE OemToAnsi( "Pre็o de Venda por Filial" )  FROM 120,005 TO 515,950  PIXEL OF oMainWnd
                                                                                                                                                                                                                                                  //390,150;

	@ 020,02 LISTBOX oListBox FIELDS HEADER OemToAnsi(" "),OemToAnsi("FILIAL"),OemToAnsi("PRODUTO"),OemToAnsi("DESCRIวรO"),OemToAnsi("CODITE"),OemToAnsi("STATUS VENDA"),OemToAnsi("OBS TIPO EST"),OemToAnsi("DESC ESPECIAL"),OemToAnsi("PREวO VENDA"),OemToAnsi("PREวO BASE"),OemToAnsi("CURVA"),OemToAnsi("MARKUP"),OemToAnsi("DESCRIวรO")  SIZE 480,150 VSCROLL PIXEL
	 //  ON DBLCLICK (IMDA840B(oListBox:nAt,@aListBox,'2'),oListBox:nColPos := 1,oListBox:Refresh()) NOSCROLL PIXEL
	oListBox:SetArray(aListBox)
	oListBox:bLine := { || {,;
		aListBox[oListBox:nAt,2],;
		aListBox[oListBox:nAt,3],;
		aListBox[oListBox:nAt,4],;
		aListBox[oListBox:nAt,5],;
		aListBox[oListBox:nAt,6],;
		aListBox[oListBox:nAt,7],;
		aListBox[oListBox:nAt,8],;
		aListBox[oListBox:nAt,9],;
		aListBox[oListBox:nAt,10],;
		aListBox[oListBox:nAt,11],;
		aListBox[oListBox:nAt,12],;
		aListBox[oListBox:nAt,13] } }



	ACTIVATE MSDIALOG oDlg CENTERED //ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()} , {|| oDlg:End()},,aButtons )

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณxArqToExcel บAutor  ณEdivaldo          บ Data ณ  27/05/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera lista de pre็o com desconto por filial em formato Excelบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Imdepa                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xArqToExcel()
	Local cClassve     :=' '
	Local xFile        :="C:\lista_preco_por_filial.xls"
	Local _cArq        :="\workflow\lista_preco_por_filial.xls"

	Local _aStruct     := {{"FILIAL"	         , "C", 02, 0 },;
		{"PRODUTO"	         , "C", 15, 0 },;
		{"DESCRI"	         , "C", 30, 0 },;
		{"CODITE"	         , "C", 27, 0 },;
		{"STATUSVE"	         , "C", 40,  0 },;
		{"B1_OBSTPES"	     , "C", 40,  0 },;
		{"DESCESPE"	         , "N", 7,  3 },;
		{"PRCVEND"	         , "N", 12, 4 },;
		{"PRCMAN"	         , "N", 12, 4 },;
		{"CURVA  "	         , "C", 50, 0 },;
		{"MARKUP  "	         , "N", 7, 4 }}

	// Apaga o arquivo no servidor
	If( File( _cArq ) )
		fErase( _cArq )
	Endif

	//Apaga o arquivo local do usuแrio
	If( File( xFile ) )
		fErase( xFile )
	Endif

	dbCreate( _cArq, _aStruct, "DBFCDXADS" ) // Crio o arquivo

	If( Select("XLS") <> 0 ) // Se a area a ser utilizada estiver em uso, fecho a mesma
		XLS->( dbCloseArea() )
	EndIf

	Use ( _cArq ) EXCLUSIVE NEW via "DBFCDXADS" alias "XLS" // Crio a แrea


    //Seleciona a area de trabalho
	DbSelectArea("_TEMP")

	While _TEMP->(!EOF())

			SB1->( DbGoto(_Temp->RECNO_SB1) )
			DA1->( DbGoto(_Temp->RECNO_DA1) )
			IM1->( DbGoto(_Temp->RECNO_IM1) )
			ZA7->( DbGoto(_Temp->RECNO_ZA7) )


		Do Case
		Case SB1->B1_CLASSVE == '1'
			cClassVe := SB1->B1_CLASSVE+'-Normal'
		Case SB1->B1_CLASSVE == '2'
			cClassVe := SB1->B1_CLASSVE+'-Especial'
		Case SB1->B1_CLASSVE == '3'
			cClassVe := SB1->B1_CLASSVE+'-Manual(Desc Filial)'
		EndCase

		nPRC_VENDA	:= DA1->DA1_PRCVEN +((DA1->DA1_PRCVEN * ZA7->ZA7_PROMES)/100)

		RecLock( "XLS", .T. )
		XLS->FILIAL    	:= ZA7->ZA7_FILIAL
		XLS->PRODUTO    	:= ZA7->ZA7_CODPRO
		XLS->DESCRI     	:= Alltrim(SB1->B1_DESC)
		XLS->CODITE     	:= Alltrim(SB1->B1_CODITE)
		XLS->STATUSVE   	:= cClassVe
		XLS->B1_OBSTPES 	:= SB1->B1_OBSTPES
		XLS->DESCESPE   	:= ZA7->ZA7_PROMES
		XLS->PRCVEND    	:= nPRC_VENDA
		XLS->PRCMAN     	:= DA1->DA1_PRCMAN
		XLS->CURVA      	:= IM1->IM1_COD+' - '+IM1->IM1_DESC
		XLS->MARKUP     	:= IM1->IM1_MARKUP
		MsUnLock()


		IncProc()
		_TEMP->(DBSKIP() )

	End

	XLS->( dbCloseArea() )
	TRB_PRCVEND->( dbCloseArea() )


	 //Copia o arquivo para a mแquina do usuแrio
	cFile1:=_cArq
	COPY FILE &cFile1 TO &xFile

	// Apaga o arquivo no servidor
	If( File( _cArq ) )
		fErase( _cArq )
	Endif


	Aviso('Pre็o de Venda por Filial','Gerado arquivo no seguinte diret๓rio'+CHR(10)+CHR(13)+xFile  ,{'Ok'})

	SW_NORMAL:=1

	MsAguarde({ |lEnd|  ShellExecute ("open",xFile,"/play /close","",SW_NORMAL) 	,OemToAnsi('Abrindo arquivo '+xFile +' ...'  )}, OemToAnsi(' Pre็o de venda por Filial'   ))


Return


*******************************************************************************
Static Function CriaArq()
*******************************************************************************
	Local aEstrutura := {}

	cSql := "select "
	cSql += "        sb1.r_e_c_n_o_ RECNO_SB1, "
	cSql += "        da1.r_e_c_n_o_ RECNO_DA1, "
	cSql += "        im1.r_e_c_n_o_ RECNO_IM1, "
	cSql += "        za7.r_e_c_n_o_ RECNO_ZA7 "

	cSql += "from  sb1010 sb1 inner join da1010 da1 "
	cSql += "  On  sb1.b1_filial  = '05' "
	cSql += "  And sb1.b1_cod     = da1.da1_codpro "
	cSql += "  And ' '            = da1.da1_filial "

	cSql += "                inner join im1010 im1 "
	cSql += "  On  im1_filial     = '  ' "
	cSql += " And  im1_cod        = sb1.b1_curva "

	cSql += "                inner join za7010 za7 "
	cSql += "  On  za7.za7_filial > ' ' "
	cSql += " And  za7.za7_codpro = da1.da1_codpro "

	cSql += "Where "
	cSql += "  sb1.d_e_l_e_t_ = ' ' "
	if !Empty(Alltrim(MV_PAR02)) .And. !Empty(Alltrim(MV_PAR03))
		cSql += "  And sb1.b1_cod     between '" + MV_PAR02 + "' And '" + MV_PAR03 + "' "
	EndIf

	if !Empty(Alltrim(MV_PAR04)) .And. !Empty(Alltrim(MV_PAR05))
		cSql += "  And sb1.b1_grupo   between '" + MV_PAR04 + "' And '" + MV_PAR05 + "' "
	EndIf

	if !Empty(Alltrim(MV_PAR06)) .And. !Empty(Alltrim(MV_PAR07))
		cSql += "  And sb1.b1_sgrb1   between '" + MV_PAR06 + "' And '" + MV_PAR07 + "' "
	EndIf

	if !Empty(Alltrim(MV_PAR08)) .And. !Empty(Alltrim(MV_PAR09))
		cSql += "  And sb1.b1_sgrb1   between '" + MV_PAR08 + "' And '" + MV_PAR09 + "' "
	EndIf

	if !Empty(Alltrim(MV_PAR10)) .And. !Empty(Alltrim(MV_PAR11))
		cSql += "  And sb1.b1_marca   between '" + MV_PAR10 + "' And '" + MV_PAR11 + "' "
	EndIf

	if !Empty(Alltrim(MV_PAR12)) .And. !Empty(Alltrim(MV_PAR13))
		cSql += "  And sb1.b1_curva   between '" + MV_PAR12 + "' And '" + MV_PAR13 + "' "
	EndIf

	cSql += "  And da1.d_e_l_e_t_ = ' ' "
	cSql += "  And im1.d_e_l_e_t_ = ' ' "
	cSql += "  And za7.d_e_l_e_t_ = ' ' "

	U_ExecMySql(cSql, "_TEMP", "Q", .T.)



// Cria Trab Vazio

If MV_PAR01 == 1   // Execu็ใo Modo Excel

	Aadd( aEstrutura , {'ZA7_FILIAL'	,'C',02,0} )
	Aadd( aEstrutura , {'ZA7_CODPRO'	,'C',15,0} )
	Aadd( aEstrutura , {'B1_DESC'		,'C',30,0} )
	Aadd( aEstrutura , {'B1_CODITE'		,'C',27,0} )
	Aadd( aEstrutura , {'B1_CLASSVE'	,'C',01,0} )
	Aadd( aEstrutura , {'B1_OBSTPES'	,'C',20,0} )
	Aadd( aEstrutura , {'ZA7_PROMES'	,'N',07,3} )
	Aadd( aEstrutura , {'DA1_PRCVEN'	,'N',12,4} )
	Aadd( aEstrutura , {'PRC_VENDA'  	,'N',12,4} )
	Aadd( aEstrutura , {'DA1_PRCMAN'	,'N',12,4} )
	Aadd( aEstrutura , {'IM1_COD'		,'C',04,0} )
	Aadd( aEstrutura , {'IM1_MARKUP'	,'N',07,4} )
	Aadd( aEstrutura , {'IM1_DESC'		,'C',40,0} )

	cArqTrab 	:= CriaTrab(aEstrutura, .T.)
	cIndice 	:= "ZA7_CODPRO,ZA7_FILIAL"

	Use &cArqTrab Alias TRB_PRCVEND NEW
	Index on &cIndice To &cArqTrab
EndIF


Return()

/*
 cQuery :=" SELECT ZA7_FILIAL,ZA7_CODPRO,B1_DESC,B1_CODITE,B1_CLASSVE,B1_OBSTPES,ZA7_PROMES,DA1_PRCVEN +((DA1_PRCVEN*ZA7_PROMES)/100) AS PRECO_VENDA ,DA1_PRCMAN,IM1_COD,IM1_MARKUP,IM1_DESC "
 cQuery +=" FROM "+RetSqlName( "SB1" )+ " SB1, "
 cQuery +=         RetSqlName( "ZA7" )+ " ZA7, "
 cQuery +=         RetSqlName( "IM1" )+ " IM1, "
 cQuery +=         RetSqlName( "DA1" )+ " DA1 "
 cQuery +=" WHERE "
 cQuery +=" DA1_FILIAL ='"+ xFilial("DA1") + "' "
 cQuery +=" AND IM1_FILIAL ='"+ xFilial("IM1") + "' "
 cQuery +=" AND B1_FILIAL=ZA7_FILIAL "
 cQuery +=" AND ZA7_CODPRO  >= '" + MV_PAR02 + "' "
 cQuery +=" AND ZA7_CODPRO  <= '" + MV_PAR03 + "' "

 //Grupo do Produto
 cQuery +=" AND B1_GRUPO    >= '" + MV_PAR04 + "' "
 cQuery +=" AND B1_GRUPO    <= '" + MV_PAR05 + "' "

 //Sub grupo 1 do Produto
  cQuery +=" AND B1_SGRB1   >= '" + MV_PAR06 + "' "
  cQuery +=" AND B1_SGRB1   <= '" + MV_PAR07 + "' "

 //Sub grupo 2 do Produto
  cQuery +=" AND B1_SGRB1   >= '" + MV_PAR08 + "' "
  cQuery +=" AND B1_SGRB1   <= '" + MV_PAR09 + "' "

 //Marca do Produto
  cQuery +=" AND B1_MARCA   >= '" + MV_PAR10 + "' "
  cQuery +=" AND B1_MARCA   <= '" + MV_PAR11 + "' "

   //Curva do Produto
  cQuery +=" AND B1_CURVA   >= '" + MV_PAR12 + "' "
  cQuery +=" AND B1_CURVA   <= '" + MV_PAR13 + "' "

 cQuery +=" AND   B1_COD     = ZA7_CODPRO"
 cQuery +=" AND   DA1_CODPRO = ZA7_CODPRO"
 cQuery +=" AND   IM1_COD    = B1_CURVA"

 cQuery +=" ORDER BY ZA7_CODPRO,ZA7_FILIAL"

TCQUERY cQuery NEW ALIAS "TRB_PRCVEND"

aStru := DbStruct()
For nI := 1 To Len( aStru )
   If aStru[nI,2] != "C"
	   TCSetField( "TRB_PRCVEND", aStru[nI,1], aStru[nI,2], aStru[nI,3], aStru[nI,4] )
   EndIf
Next

*/


