#Include 'Protheus.ch'


*******************************************************************************
User Function ImdContCe()
*******************************************************************************
Local nHandleLP := 0	//| Vari�vel que conter� o num. (Handle) do arquivo (.LAN) criado.
Local cLoteLanP	:= "" 	//| ??? -  Verificar qual LOTE deve ser utilizado.... C�digo do lote do m�dulo (Ex.: Ativo Fixo: �8866�)
Local cNomProLP := "" 	//| Nome do Programa  (Ex.: �ATFA060�)
Local cUsuarioA := Subs(cUsuario,7,6) //| Usu�rio arquivo: nome do arquivo (Ex.: cArquivo := � �) 
Local cNomeFile	:= ""   //| Arquivo 

Local cCoLanPad := ""  	//| C�digo do Lan�amento Padr�o
Local nTotalLPa	:= 0 	//| Total do Lancamento

Local lDigita 	:= .T. 	//| Se Mostra ou nao o Lancamento
Local lAglut	:= .T. 	//| Se Aglutina ou n�o o Lancamento
Local cOnLine 	:= "O" 	//| Determina se sera On Line ou pelo cProva. O -> OnLine , C -> Contra-Prova
Local nOpcx		:= 3	//| 
Local dData		:= dDataBase



//| HeadProva -> Este fun��o cria o cabe�alho da contabiliza��o. � tratada de forma diferenciada para os m�dulos SIGACON e SIGACTB.
nHandleLP 	:= HeadProva( cLoteLanP, cNomProLP, cUsuarioA, @cNomeFile, .T.)

//| DetProva -> Em primeiro lugar, deve-se estar posicionado no registro, que cont�m o valor � ser contabilizado
nTotalLPa 	+= DetProva(nHandleLP,cCoLanPad,cNomProLP,cLoteLanP)

//| Esta fun��o ir� cria a finaliza��o da contabiliza��o.
RodaProva(nHandleLP,nTotalLPa)

//| No Final, ou seja, ap�s todos registros serem processados utilizar a fun��o CA100INCL(), cujo objetivo � ler o arquivo gerado (.LAN), e gerar os lan�amentos no arquivo SI2 (Lan�amentos cont�beis).
CA100Incl( cNomeFile, nHandleLP, nOpcx, cLoteLanP, lDigita, lAglut, cOnLine, dData)


Return()