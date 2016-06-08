#Include 'Protheus.ch'


*******************************************************************************
User Function ImdContCe()
*******************************************************************************
Local nHandleLP := 0	//| Variável que conterá o num. (Handle) do arquivo (.LAN) criado.
Local cLoteLanP	:= "" 	//| ??? -  Verificar qual LOTE deve ser utilizado.... Código do lote do módulo (Ex.: Ativo Fixo: “8866”)
Local cNomProLP := "" 	//| Nome do Programa  (Ex.: “ATFA060”)
Local cUsuarioA := Subs(cUsuario,7,6) //| Usuário arquivo: nome do arquivo (Ex.: cArquivo := ‘ ‘) 
Local cNomeFile	:= ""   //| Arquivo 

Local cCoLanPad := ""  	//| Código do Lançamento Padrão
Local nTotalLPa	:= 0 	//| Total do Lancamento

Local lDigita 	:= .T. 	//| Se Mostra ou nao o Lancamento
Local lAglut	:= .T. 	//| Se Aglutina ou não o Lancamento
Local cOnLine 	:= "O" 	//| Determina se sera On Line ou pelo cProva. O -> OnLine , C -> Contra-Prova
Local nOpcx		:= 3	//| 
Local dData		:= dDataBase



//| HeadProva -> Este função cria o cabeçalho da contabilização. É tratada de forma diferenciada para os módulos SIGACON e SIGACTB.
nHandleLP 	:= HeadProva( cLoteLanP, cNomProLP, cUsuarioA, @cNomeFile, .T.)

//| DetProva -> Em primeiro lugar, deve-se estar posicionado no registro, que contém o valor à ser contabilizado
nTotalLPa 	+= DetProva(nHandleLP,cCoLanPad,cNomProLP,cLoteLanP)

//| Esta função irá cria a finalização da contabilização.
RodaProva(nHandleLP,nTotalLPa)

//| No Final, ou seja, após todos registros serem processados utilizar a função CA100INCL(), cujo objetivo é ler o arquivo gerado (.LAN), e gerar os lançamentos no arquivo SI2 (Lançamentos contábeis).
CA100Incl( cNomeFile, nHandleLP, nOpcx, cLoteLanP, lDigita, lAglut, cOnLine, dData)


Return()