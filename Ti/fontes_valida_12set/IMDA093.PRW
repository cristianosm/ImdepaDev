#INCLUDE "TOTVS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � IMDA093  �Autor  � Cristiano Oliveira � Data �  08/09/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Este programa tem o objetivo de executar as regras de     ���
���          �  negocio para o preenchimento dos campos de produto.       ���
�������������������������������������������������������������������������͹��
���Uso       � IMDEPA - Produto Inteligente                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*///
*********************************************************************
User Function IMDA093(_cCampo, _cFam, _cRef, _cLrg, _cCom)
*********************************************************************
Local 	aSavSBs 	:= 	SaveArea1({"SBQ", "SBP", "SBR", "SBS", "SB1", "SG1", "SGG", "SBT", "SBU", "SBX"})
Local   xRetorno   

Private	lCopia		:=	IsInCallStack("A010COPIA")	// COPIA DE PRODUTO VARIAVEL M->B1_XX NAO EXISTE
Private	lReplicaSB1 := 	IsInCallStack("U_REPLICASB1")
Private cBaseBS		:=	''
Private	lCorreia 	:=	.F.
Private lCorrOpen	:=	.F.
Private lImp  		:= 	.F.
Private cTipo 		:= 	''
Default _cCom		:=	''

//�������������������������������������������������������������������������������������������������������������������������������������Ŀ
//|	 ROTINA IMPORTA CORREIA -> IMDA100.PRW (CRIA CORREIAS PAs VIA .CSV)                                                                 |
//�  PRIMENTO CHAMADA DA ROTINA Eh VIA FUNCAO &(a093SubsId(SBY->BY_EXPRES,SBP->BP_BASE)) ->A093VldCod() ->MATA093.PRX                   |	
//|	 VARIAVEL M->B1_COD NAO EXISTE cCodProd FICARA COM O CORDIGO ERRADO (FALTA @MAT NA COMPOSICAO DO CODIGO) POREM NAO Eh CRITICO 		|
//|	 PQ NESSE MOMENTO ROTINA SOMENTE IRA ATUALIZAR B1_DESC.                                                                             |
//|	 NAS PROXIMAS CHAMADAS M->B1_COD ESTARA CORRETO  																					�
//|																																		|
//|  OBS.: NA COPIA DO PRODUTO, ROTINA A010COPIA, A VARIAVEL M->B1_XX NAO EXISTE														|
//���������������������������������������������������������������������������������������������������������������������������������������
//�����������������������������������������������������������������������������Ŀ
//�  OBS.: SBS->BS_BASE DEVERA OBRIGATORIAMENTE ESTAR POSICIONADO CORRETAMENTE	�
//�������������������������������������������������������������������������������
IIF(Select('SBP')==0.Or.Empty(Alias()), (ChkFile('SBP'),DbSelectArea("SBP")),); SBP->(DbGoTop())
lCopia		:=	IIF(!lCopia .And. lReplicaSB1, .T., lCopia)
cCodProd	:=	IIF(!lCopia, IIF(Type('M->B1_COD')!='U', M->B1_COD, PadR(AllTrim(SBS->BS_BASE)+_cFam+_cRef+_cLrg+_cCom, TamSx3('B1_COD')[01])), SB1->B1_COD)
cBaseBS		:= 	A093VldBase(cCodProd)
lCorreia 	:= !Empty(cBaseBS)
lCorrOpen	:=	IIF(AllTrim(cBaseBS) == '02', .T., .F.) // 01-FECHADAS, 02-ABERTAS

If AllTrim(SBP->BP_BASE) != AllTrim(SBS->BS_BASE)
	SBP->(DbSeek(xFilial('SBP')+PadR(cBaseBS,TamSx3('BP_BASE')[01]), .F.))
EndIf

//����������������������������������������Ŀ
//�   PARAMETROS UTILIZADOS NA ROTINA	   �
//������������������������������������������
IIF(!ExisteSX6('IM_I093PE'),	CriarSX6('IM_I093PE', 'C','Filiais X Prazo de Entrega. IMDA093PRW',"{{'02',14},{'04',10},{'05',07},{'06',07},{'09',07},{'13',07},{'14',10}}"), )
IIF(!ExisteSX6('IM_FILXALM'), 	CriarSX6('IM_FILXALM','C','Filiais que nao tem Almox02', '02/14'), )
IIF(!ExisteSX6('IM_AI093S2'), 	CriarSX6('IM_AI093S2', 'C','SubGrupo2 x Correias ABERTAS. IMDA093PRW',"{{'1','220401'}}"),)
IIF(!ExisteSX6('IM_FI093S2'), 	CriarSX6('IM_FI093S2', 'C','SubGrupo2 x Correias FECHADAS. IMDA093PRW',"{{'01','220301'},{'02','220302'},{'03','220303'},{'04','220304'},{'05','220305'},{'06','220306'},{'10','220310'},{'11','220311'},{'12','220312'}{'20','220320'},{'30','220330'},{'40','220340'}}"), )
IIF(!ExisteSX6('IM_FS2I093'), 	CriarSX6('IM_FS2I093', 'C','SubGrupo2 x Correias FECHADAS. IMDA093PRW',"{{'02','220302'},{'35','220335'}}"), )
IIF(!ExisteSX6('IM_I093CT'), 	CriarSX6('IM_I093CT', 'C','Conta Contabil x Correias. IMDA093PRW',"{{'PA','11501010'},{'PP','11501012'}}") , )
IIF(!ExisteSX6('IM_I093EF'), 	CriarSX6('IM_I093EF', 'C','Estoque de Seguranca x Correias. IMDA093PRW',"{{'PA','C04'},{'PP','C00'}}"), )
IIF(!ExisteSX6('IM_I093TE'), 	CriarSX6('IM_I093TE', 'C','Tempo Maximo do Estoque x Correias. IMDA093PRW',"{{'PA', 150},{'PP',60}}"), )
IIF(!ExisteSX6('IM_AI093CV'), 	CriarSX6('IM_AI093CV', 'C','Curva(IM1) x Correias ABERTAS. IMDA093PRW',"{{'1','0171'}}"), )
IIF(!ExisteSX6('IM_FI093CV'), 	CriarSX6('IM_FI093CV', 'C','Curva(IM1) x Correias FECHADAS. IMDA093PRW',"{{'01\03\04\05\06','0169'},{'02\10\11\20\30\40','0170'}}"), )


	

//����������������������������������������Ŀ
//�  CONTROLA O CODIGO DE ENTRADA E SAIDA  �
//������������������������������������������
If Type("cCod") == Nil .OR. Type("cCod") == "U"
	Public  cCod  := ""
EndIf
                 
//�����������������������������������������������������Ŀ
//� VERIFICA SE Eh IMPORTACAO (lImporta vem da IMDA100) �
//�������������������������������������������������������
If Type("lImporta") != Nil .AND. Type("lImporta") != "U"
	lImp  := .T.
EndIf              

//�������������������������������������������Ŀ
//�  IMPORTACAO � PA, C�DIGO INTELIGENTE � PP �
//���������������������������������������������
cTipo := IIF(lImp, 'PA', 'PP')



Do Case
	Case _cCampo == "B1_PE"
		xRetorno := I093PE()
	Case _cCampo == "B1_LOCPAD"
		xRetorno := I093LP()
	Case _cCampo == "B1_CODITE"
		xRetorno := I093CI(_cRef, _cLrg, _cCom)
	Case _cCampo == "B1_DESC"
		xRetorno := I093DC(_cFam, _cRef, _cLrg, _cCom)
	Case _cCampo == "B1_REFER"
		xRetorno := I093RF(_cFam, _cRef, _cLrg, _cCom)
	Case _cCampo == "B1_SGRB2"
		xRetorno := I093S2(_cFam)
	Case _cCampo == "B1_SGRB3"
		xRetorno := I093S3(_cRef)
	Case _cCampo == "B1_CONTA"
		xRetorno := I093CT()
	Case _cCampo == "B1_ESTFOR"
		xRetorno := I093EF()	
	Case _cCampo == "B1_TMAXEST"
		xRetorno := I093TE()	
	Case _cCampo == "B1_CURVA"
		xRetorno := I093CV( _cFam )
	Case _cCampo == "B1_ESPEC1"	//	B1_ESPECIF
		xRetorno := I093E1(_cFam, _cRef, _cLrg)
	Case _cCampo == "B1_POSIPI"
		xRetorno := I093PI(_cFam, _cRef, _cLrg)
	Case _cCampo == "B1_IPI"
		xRetorno := I093IP(_cFam, _cRef, _cLrg)
	Case _cCampo == "B1_PESO"
		xRetorno := I093PS(_cFam, _cRef, _cLrg)
	Case _cCampo == "B1_CUSTD"
		xRetorno := I093CS(_cFam, _cRef, _cLrg, _cCom)
	Case _cCampo == "B1_CUSTRP"
		xRetorno := I093CR( _cFam, _cRef, _cLrg )	
	Case _cCampo == "B1_MCUSTD"
		xRetorno := I093MS(_cFam, _cRef, _cLrg)
	Case _cCampo == "B1_MCUSTRP"
		xRetorno := I093MR(_cFam, _cRef, _cLrg)
	Case _cCampo == "B1_TIPO"
		xRetorno := I093TP(_cFam, _cRef, _cLrg)
	OtherWise
		xRetorno := ""
EndCase	

RestArea1(aSavSBs)
Return(xRetorno)
*********************************************************************
Static Function I093PE()
*********************************************************************
//��������������������������������������������������������������Ŀ
//� B1_PE - Prazo de Entrega                                     �
//����������������������������������������������������������������
	Local nPrazo	:=	0
	// 	{{'02',30},{'04',25},{'05',21},{'06',21},{'09',21},{'13',21},{'14',25}}
	//	{{'02',30},{'04',25},{'05',21},{'06',21},{'09',21},{'13',21},{'14',25}}
	IIF(!ExisteSX6('IM_I093PE'), CriarSX6('IM_I093PE', 'C','Filiais X Prazo de Entrega. IMDA093PRW',"{{'02',14},{'04',10},{'05',07},{'06',07},{'09',07},{'13',07},{'14',10}}"), )
	aFilPE	:=	&(GetMv('IM_I093PE'))
	nPos 	:= 	Ascan(aFilPE, {|X| X[01] == xFilial('SB1') })
	
	If cTipo == 'PA' .And. nPos > 0
		nPrazo	:=	aFilPE[nPos][02]
    Endif


Return(nPrazo)
*********************************************************************
Static Function I093LP()
*********************************************************************
//��������������������������������������������������������������Ŀ
//� B1_LOCPAD - Local Padrao                                     �
//����������������������������������������������������������������
	Local cRet := ""

	Local cOriger  := SB1->B1_ORIGER  									// 1 == C/St // 2 == S/St
	Local cIndustr := IIF(lCopia, SB1->B1_INDUSTR, M->B1_INDUSTR)   	// S == Sim  // N == Nao
	
	Local cLocCST  := "01" 		  // Armaz�m C/St
	Local cLocSST  := "02" 		  // Armaz�m S/St 

	IIF(!ExisteSX6('IM_FILXALM'), CriarSX6('IM_FILXALM','C','Filiais que nao tem Almox02', '02/14'), )
	cFilxAlm  := GetMv('IM_FILXALM')

	
	If lCorreia .And. cIndustr == 'S'
		If cFilAnt $ cFilxAlm
			cRet := cLocCST  	//	01
		Else
			cRet := cLocSST		//	02
		EndIf
	Else
		If xFilial("SB1") == "02"    
		    cRet := cLocCST
		ElseIf xFilial("SB1") == "04"
		    cRet := cLocSST                     
		ElseIf xFilial("SB1") == "06"
		    cRet := cLocSST                     
		ElseIf xFilial("SB1") == "07"
		    cRet := cLocCST
		ElseIf xFilial("SB1") == "09"
		    If cIndustr == "S"
		       cRet := cLocSST
		    Else
		       cRet := cLocCST
		    Endif
		ElseIf xFilial("SB1") == "10"
		    cRet := cLocCST
		ElseIf xFilial("SB1") == "11"
		    cRet := cLocCST
		ElseIf xFilial("SB1") == "12"
		    cRet := cLocCST
		ElseIf xFilial("SB1") == "13"    
		    If (cOriger == 'F/NCZADO' .OR. cOriger == 'IMPORTADO')
		       cRet := cLocSST
		    Else
		       cRet := cLocCST
		    Endif  
		ElseIf xFilial("SB1") == "14"
		    cRet := cLocCST
		ElseIf xFilial("SB1") == "15"
		    cRet := cLocCST
		Else
			cRet := cLocCST    
		Endif
	EndIf
	  
Return(cRet)
*********************************************************************
Static Function I093CI(_cRef, _cLrg, _cCom)
*********************************************************************	
//��������������������������������������������������������������Ŀ
//� B1_CODITE - Codigo do Item                                   �
//����������������������������������������������������������������

cCodIte := "CLA_" 	+ AllTrim(Posicione('SBS', 1, xFilial('SBS')+PadR(cBaseBS,TamSx3('BS_BASE')[01])+PadR('REF',TamSx3('BS_ID')[01])+ _cRef, 'BS_DESCR')) 
cCodIte += " " 	+ AllTrim(Posicione('SBS', 1, xFilial('SBS')+PadR(cBaseBS,TamSx3('BS_BASE')[01])+PadR('LRG',TamSx3('BS_ID')[01])+ _cLrg, 'BS_DESCR')) 
If lCorreia .And. lCorrOpen
	cCodIte += " "	+ AllTrim(Posicione('SBS', 1, xFilial('SBS')+PadR(cBaseBS,TamSx3('BS_BASE')[01])+PadR('COM',TamSx3('BS_ID')[01])+ _cCom, 'BS_DESCR'))
EndIf

Return(cCodIte)
*********************************************************************
Static Function I093DC(_cFam, _cRef, _cLrg, _cCom)
*********************************************************************	
//��������������������������������������������������������������Ŀ
//� B1_DESC - Descricao                                          �
//����������������������������������������������������������������
	Local cOriger  	:=	SB1->B1_ORIGER
	Local cDescri	:=	''
		
	cDescri :=       AllTrim(Posicione('SBS', 1, xFilial('SBS')+PadR(cBaseBS,TamSx3('BS_BASE')[01])+PadR('FAM',TamSx3('BS_ID')[01])+ _cFam, 'BS_DESCR')) 
	cDescri += " " + AllTrim(Posicione('SBS', 1, xFilial('SBS')+PadR(cBaseBS,TamSx3('BS_BASE')[01])+PadR('REF',TamSx3('BS_ID')[01])+ _cRef, 'BS_DESCR')) 
	cDescri += " " + AllTrim(Posicione('SBS', 1, xFilial('SBS')+PadR(cBaseBS,TamSx3('BS_BASE')[01])+PadR('LRG',TamSx3('BS_ID')[01])+ _cLrg, 'BS_DESCR')) 
	If lCorreia .And. lCorrOpen
		cDescri += " " + AllTrim(Posicione('SBS', 1,xFilial('SBS')+PadR(cBaseBS,TamSx3('BQ_BASE')[01])+PadR('COM',TamSx3('BS_ID')[01])+ _cCom, 'BS_DESCR')) 	
	EndIf
	cDescri += " CONTITECH"
		
	If !Empty(cOriger)
		cDescri += " " + cOriger
	Else
		cDescri += " NCZADO"
	EndIf
	
Return(cDescri)
*********************************************************************
Static Function I093RF(_cFam, _cRef, _cLrg, _cCom)
*********************************************************************	
//��������������������������������������������������������������Ŀ
//� B1_REFER - Referencia                                        �
//����������������������������������������������������������������
		
	cReferencia :=       AllTrim(Posicione('SBS', 1, xFilial('SBS')+PadR(cBaseBS,TamSx3('BS_BASE')[01])+PadR('FAM',TamSx3('BS_ID')[01])+ _cFam, 'BS_DESCR')) 
	cReferencia += " " + AllTrim(Posicione('SBS', 1, xFilial('SBS')+PadR(cBaseBS,TamSx3('BS_BASE')[01])+PadR('REF',TamSx3('BS_ID')[01])+ _cRef, 'BS_DESCR')) 
	cReferencia += " " + AllTrim(Posicione('SBS', 1, xFilial('SBS')+PadR(cBaseBS,TamSx3('BS_BASE')[01])+PadR('LRG',TamSx3('BS_ID')[01])+ _cLrg, 'BS_DESCR')) 
	If lCorreia .And. lCorrOpen
		cReferencia += " " + AllTrim(Posicione('SBS', 1,xFilial('SBS')+PadR(cBaseBS,TamSx3('BQ_BASE')[01])+PadR('COM',TamSx3('BS_ID')[01])+ _cCom, 'BS_DESCR')) 	
	EndIf
	
Return(cReferencia)
*********************************************************************
Static Function I093S2(_cFam)
*********************************************************************
//��������������������������������������������������������������Ŀ
//� B1_SGRB2 - Sub Grupo 2                                       �
//����������������������������������������������������������������
	Local cSubGrp2 := ''
/*	
	IIF(!ExisteSX6('IM_AI093S2'), CriarSX6('IM_AI093S2', 'C','SubGrupo2 x Correias ABERTAS. IMDA093PRW',"{{'01','220301'},{'02','220302'},{'03','220303'},{'05','220305'},{'06','220306'},{'10','220310'},{'20','220320'},{'30','220330'},{'40','220340'}}"),)
	aASubGrp := &(GetMv('IM_AI093S2'))

	IIF(!ExisteSX6('IM_FI093S2'), CriarSX6('IM_FI093S2', 'C','SubGrupo2 x Correias FECHADAS. IMDA093PRW',"{{'1','220401'}}"), )
	aFSubGrp := &(GetMv('IM_FI093S2'))
	
	If lCorreia
		If !lCorrOpen
			nPos 	 := Ascan(aASubGrp, {|X| AllTrim(X[01]) == AllTrim(_cFam)})
			cSubGrp2 :=	IIF(nPos > 0, aASubGrp[nPos][02], '')
	
		ElseIf lCorrOpen
			nPos 	 :=	Ascan(aFSubGrp, {|X| AllTrim(X[01]) == AllTrim(_cFam)})
			cSubGrp2 :=	IIF(nPos > 0, aFSubGrp[nPos][02], '')
		EndIf
	EndIf
*/




	IIF(!ExisteSX6('IM_AI093S2'), CriarSX6('IM_AI093S2', 'C','SubGrupo2 x Correias ABERTAS. IMDA093PRW',"{{'1','220401'}}"),)
	aASubGrp := &(GetMv('IM_AI093S2'))

	IIF(!ExisteSX6('IM_FI093S2'), CriarSX6('IM_FI093S2', 'C','SubGrupo2 x Correias FECHADAS. IMDA093PRW',"{{'01','220301'},{'03','220303'},{'04','220304'},{'05','220305'},{'06','220306'},{'10','220310'},{'11','220311'},{'22','220322'},{'20','220320'},{'21','220321'},{'30','220330'},{'40','220340'},{'07','220307'},{'08','220308'}}"), )
	aFSubGrp := &(GetMv('IM_FI093S2'))	
	IIF(!ExisteSX6('IM_FS2I093'), CriarSX6('IM_FS2I093', 'C','SubGrupo2 x Correias FECHADAS. IMDA093PRW',"{{'02','220302'},{'35','220335'}}"), )
	aP2FSubGrp := &(GetMv('IM_FS2I093'))	
		
	If lCorreia
		If !lCorrOpen
			nPos 	 := Ascan(aFSubGrp, {|X| AllTrim(X[01]) == AllTrim(_cFam)})
			cSubGrp2 :=	IIF(nPos > 0, aFSubGrp[nPos][02], '')
			
			If Empty(cSubGrp2)
				//�����������������������������������������������������������������Ŀ
				//�  PESQUISA NO SEGUNDO PARAMETRO CASO NAO ENCONTRE NO PRIMEIRO 	�
				//�������������������������������������������������������������������
				nPos 	 := Ascan(aP2FSubGrp, {|X| AllTrim(X[01]) == AllTrim(_cFam)})
				cSubGrp2 :=	IIF(nPos > 0, aP2FSubGrp[nPos][02], '')
			EndIf
			
		ElseIf lCorrOpen
			nPos 	 :=	Ascan(aASubGrp, {|X| AllTrim(X[01]) == AllTrim(_cFam)})
			cSubGrp2 :=	IIF(nPos > 0, aASubGrp[nPos][02], '')
		EndIf
	EndIf


			
Return(cSubGrp2)
*********************************************************************
Static Function I093S3(_cRef)
*********************************************************************	
//��������������������������������������������������������������Ŀ
//� B1_SGRB3 - Sub Grupo 3                                       �
//����������������������������������������������������������������

Local cSubGrp3 	:=	AllTrim(Posicione('SBS', 1, xFilial('SBS')+PadR(cBaseBS,TamSx3('BS_BASE')[01])+PadR('REF',TamSx3('BS_ID')[01])+ _cRef, 'BS_DESCR')) 
		
Return(cSubGrp3)
*********************************************************************
Static Function I093CT()
*********************************************************************	
//��������������������������������������������������������������Ŀ
//� B1_CONTA - CONTA CONTABIL                                    �
//����������������������������������������������������������������
	IIF(!ExisteSX6('IM_I093CT'), CriarSX6('IM_I093CT', 'C','Conta Contabil x Correias. IMDA093PRW',"{{'PA','11501010'},{'PP','11501012'}}") , )
	aContas := &(GetMv('IM_I093CT'))
	    
	nPos 	:= 	Ascan(aContas, {|X| AllTrim(X[01]) == AllTrim(cTipo)} )
	cConta 	:= 	IIF(nPos > 0, aContas[nPos][02], '')

Return(cConta)
*********************************************************************
Static Function I093EF()
*********************************************************************	
//��������������������������������������������������������������Ŀ
//� B1_ESTFOR - Formula do Estoque de Seguranca                  �
//����������������������������������������������������������������
	IIF(!ExisteSX6('IM_I093EF'), CriarSX6('IM_I093EF', 'C','Estoque de Seguranca x Correias. IMDA093PRW',"{{'PA','C04'},{'PP','C00'}}"), )
	aEstSeg := &(GetMv('IM_I093EF'))
	    
	nPos 	:= 	Ascan(aEstSeg, {|X| AllTrim(X[01]) == AllTrim(cTipo)} )
	cEstSeg	:= 	IIF(nPos > 0, aEstSeg[nPos][02], '')                                                                                                                                                                                                                             
		
Return(cEstSeg)
*********************************************************************
Static Function I093TE()
*********************************************************************
//��������������������������������������������������������������Ŀ
//� B1_TMAXEST - Tempo Maximo do Estoque                         �
//����������������������������������������������������������������
	IIF(!ExisteSX6('IM_I093TE'), CriarSX6('IM_I093TE', 'C','Tempo Maximo do Estoque x Correias. IMDA093PRW',"{{'PA', 150},{'PP',60}}"), )
	aTempMax  := &(GetMv('IM_I093TE'))

	nPos 	  := Ascan(aTempMax, {|X| AllTrim(X[01]) == AllTrim(cTipo)} )
	nTempMax  := IIF(nPos > 0, aTempMax[nPos][02], 0)   

Return(nTempMax)
*********************************************************************
Static Function I093CV(_cFam)
*********************************************************************	
//��������������������������������������������������������������Ŀ
//� B1_CURVA - CURVA                                             �
//����������������������������������������������������������������
	Local cCurva := '' 
/*
	IIF(!ExisteSX6('IM_AI093CV'), CriarSX6('IM_AI093CV', 'C','Curva(IM1) x Correias ABERTAS. IMDA093PRW',"{{'01\03\05\06','0169'},{'02\10\20\30\40','0170'}}"), )
	aACurva	:= &(GetMv('IM_AI093CV'))

	IIF(!ExisteSX6('IM_FI093CV'), CriarSX6('IM_FI093CV', 'C','Curva(IM1) x Correias FECHADAS. IMDA093PRW',"{{'1','0171'}}"), )
	aFCurva	:= &(GetMv('IM_FI093CV'))
	
	If lCorreia
		If !lCorrOpen
			nPos 	:=	Ascan(aACurva, {|X| AllTrim(_cFam) $ AllTrim(X[01]) })
			cCurva	:=	IIF(nPos > 0, aACurva[nPos][02], '')
	
		ElseIf lCorrOpen
			nPos 	:=	Ascan(aFCurva, {|X| AllTrim(X[01]) == AllTrim(_cFam)})
			cCurva	:=	IIF(nPos > 0, aFCurva[nPos][02], '')
		EndIf
	EndIf
*/

	IIF(!ExisteSX6('IM_AI093CV'), CriarSX6('IM_AI093CV', 'C','Curva(IM1) x Correias ABERTAS. IMDA093PRW',"{{'1','0171'}}"), )
	aACurva	:= &(GetMv('IM_AI093CV'))

	IIF(!ExisteSX6('IM_FI093CV'), CriarSX6('IM_FI093CV', 'C','Curva(IM1) x Correias FECHADAS. IMDA093PRW',"{{'01\03\04\05\06','0169'},{'02\10\11\20\30\40','0170'}}"), )
	aFCurva	:= &(GetMv('IM_FI093CV'))
	
	If lCorreia
		If !lCorrOpen
			nPos 	:=	Ascan(aFCurva, {|X| AllTrim(_cFam) $ AllTrim(X[01]) })
			cCurva	:=	IIF(nPos > 0, aFCurva[nPos][02], '')
	
		ElseIf lCorrOpen
			nPos 	:=	Ascan(aACurva, {|X| AllTrim(X[01]) == AllTrim(_cFam)})
			cCurva	:=	IIF(nPos > 0, aACurva[nPos][02], '')
		EndIf
	EndIf
	
Return(cCurva)
*********************************************************************
Static Function I093E1(_cFam, _cRef, _cLrg)
*********************************************************************	
//��������������������������������������������������������������Ŀ
//� B1_ESPEC1 - Especifica��o / SAP: C�digo do Fornecedor        �
//����������������������������������������������������������������
	If lImp
		cRet := cSAP
	Else
		cRet := U_QDADOPAI(_cFam , cCodProd, "B1_ESPEC1")
	EndIf
	
Return(cRet)
*********************************************************************
Static Function I093PI(_cFam, _cRef, _cLrg)
*********************************************************************	
//��������������������������������������������������������������Ŀ
//� B1_POSIPI - NCM                                              �
//����������������������������������������������������������������
	If lImp
		cRet := cNCM
	Else
		cRet := U_QDADOPAI( _cFam , cCodProd, "B1_POSIPI")
	EndIf
	
Return(cRet)
*********************************************************************
Static Function I093IP(_cFam, _cRef, _cLrg)
*********************************************************************
//��������������������������������������������������������������Ŀ
//� B1_IPI - IPI (%)                                             �
//����������������������������������������������������������������

	If lImp
		nRet := Posicione('SYD',1, xFilial('SYD')+ cNCM, "YD_PER_IPI")
	Else
		nRet := Posicione('SYD',1, xFilial('SYD')+ U_QDADOPAI( _cFam , cCodProd, "B1_POSIPI"), "YD_PER_IPI")
	EndIf
	
Return(nRet)
*********************************************************************
Static Function I093PS(_cFam, _cRef, _cLrg)
*********************************************************************	
//��������������������������������������������������������������Ŀ
//� B1_PESO - PESO                                               �
//����������������������������������������������������������������

	If lImp
		nRet := nPeso
		
		If lCorrOpen 
			aVarSBS	:= 	A093SBSVars(cCodProd)			
			nPosCom	:= 	Ascan(aVarSBS, {|X|  AllTrim(X[01]) == 'COM'} )
			cIDBS	:= 	IIF(nPosCom > 0, aVarSBS[nPosCom][01], '')
			cCodBS	:= 	IIF(nPosCom > 0, aVarSBS[nPosCom][02], '')
			nTamCom	:=	Val(IIF(nPosCom > 0, aVarSBS[nPosCom][03], '1'))
			nRet 	:= 	nPeso * nTamCom
		EndIf
		
	Else
		nRet := U_QCSTRPAI( _cFam , cCodProd, "B1_PESO")
	EndIf
	
Return(nRet)
*********************************************************************
Static Function I093CS( _cFam, _cRef, _cLrg, _cCom )
*********************************************************************	
//��������������������������������������������������������������Ŀ
//� B1_CUSTD - CUSTO STANDART                                    �
//| IMPORTA .CSV CUSTO CORREIA ABERTA EM METROS					 |
//����������������������������������������������������������������
	If lImp 
		nRet := nCstd
	Else
		cCod := cCodProd
		nRet := U_QCSTRPAI(_cFam , cCodProd, "B1_CUSTD")
	EndIf  

	
Return(nRet)
*********************************************************************
Static Function I093CR( _cFam, _cRef, _cLrg )
*********************************************************************	
//��������������������������������������������������������������Ŀ
//� B1_CUSTRP - CUSTO DE REPOSICAO                               �
//����������������������������������������������������������������
	If lImp 
		nRet := nCrps
	Else
		nRet := U_QCSTRPAI( _cFam , cCod, "B1_CUSTRP" )
	EndIf                                                    
	
Return(nRet)
*********************************************************************
Static Function I093MS(_cFam, _cRef, _cLrg)
*********************************************************************  
//��������������������������������������������������������������Ŀ
//� B1_MCUSTD - MOEDA DO CUSTO STANDART                          �
//����������������������������������������������������������������
_cMoeda := '1'

Return(_cMoeda)
*********************************************************************
Static Function I093MR(_cFam, _cRef, _cLrg)
*********************************************************************       
//��������������������������������������������������������������Ŀ
//� B1_MCUSTRP - MOEDA DO CUSTO DE REPOSICAO                     �
//����������������������������������������������������������������
cMoedaRep := '1'

Return(cMoedaRep)
*********************************************************************
Static Function I093TP(_cFam, _cRef, _cLrg)
*********************************************************************                
//��������������������������������������������������������������Ŀ
//� B1_TIPO - PP ou PA                                           �
//����������������������������������������������������������������
Return(cTipo)