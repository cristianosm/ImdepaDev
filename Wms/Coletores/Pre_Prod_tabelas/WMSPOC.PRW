#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH" 
 
#Define  CRLF    (chr(13)+chr(10)) 

#DEFINE DEF_ESTRUTURA     4    
#DEFINE DEF_PER_OCUP      5    
#DEFINE DEF_QTD_ITENS     6  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ WMSPOC ºAutor ³Edivaldo Gonçalves   º Data ³  15/06/08     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Percentual de ocupação nos Endereços                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ WMS - Endereçamento de Itens                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³ MOTIVO                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±                           
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
           
              
User Function WMSPOC() 

Local cperg		:= 'WMSPOC'
Local aDados	:= {}
Local lOk

Private aListBox    := {} 
Private lTransferiu :=.F.  
Private nPosEndereco //Número da linha do Endereço no vetor ListBox{}

If cperg <> "MP8.11"
	cPerg := PADR(cperg,10)
Endif

//aAdd(aDados,{ "Do Produto ?","Do Produto ?","Do Produto ?","mv_ch1","C", 8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","" }) 
aAdd(aDados,{ "Do Produto ?","Do Produto ?","Do Produto ?","mv_ch1","C", 8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","" })
aAdd(aDados,{ "Até o Produto ?","Até o Produto ?","Até o Produto ?","mv_ch2","C", 8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","" })
aAdd(aDados,{ "Da Estrutura ?","Da Estrutura ?","Da Estrutura ?","mv_ch3","C", 6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","DC8","","" })
aAdd(aDados,{ "Até a Estrutura ?","Até a Estrutura ?","Até a Estrutura ?","mv_ch4","C", 6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","DC8","","" })

aAdd(aDados,{ "Do Armazém ?","Do Armazém ?","Do Armazém ?","mv_ch5","C", 2,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","",""," ","","" })
aAdd(aDados,{ "Até o Armazém ?","Até o Armazém ?","Até o Armazém ?","mv_ch6","C", 2,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","",""," ","","" })


aAdd(aDados,{ "Do Endereço ?","Do Endereço ?","Do Endereço ?","mv_ch7","C", 15,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SBE","","" })

aAdd(aDados,{ "Até o Endereço ?","Até o Endereço ?","Até o Endereço ?","mv_ch8","C", 15,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SBE","","" })

aAdd(aDados,{ "Status","Status","Status","mv_ch9","N", 1,0,0,"C","","mv_par09","Desocupado","Desocupado","Desocupado","","","Ocupado","Ocupado","Ocupado","","","BLOQUEADO","BLOQUEADO","BLOQUEADO","","","","","","","","","","","","","","" })


aAdd(aDados,{ "% de Ocupação de ?  ","% de Ocupação de?         ","% de Ocupação de?         ","mv_chA","N", 7,2,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
aAdd(aDados,{ "% de Ocupação Até ?  ","% de Ocupação Até ?         ","% de Ocupação Até ?    ","mv_chB","N", 7,2,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","","" })


U_ImdASX1( cPerg, aDados )

     If  Pergunte(cPerg,.T.)

		Processa( {||lOk := BuscaEnderecos( )}, "Aguarde","Identificando Percentual de Ocupação nos Endereços ...")

		// Exibe a consulta
		If lOk
			SHOWTELA()
		Endif	
    Endif
    		


Return NIL


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ BuscaEnderecos ³Autor ³Edivaldo Gonçalves ³ Data ³ 08/06/08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Processamento para Listar os Endereços                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PROCREGRA   ()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Rotina Principal                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function BuscaEnderecos()

LOCAL nI
LOCAL aStru := {}
LOCAL cQuery
Local nPorCentOcupado:=0
Local nQtdItens      :=1
Local cControllaItem 
Local cEndereco      
Local cEstrutura     
Local cLocal         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona os Endereços baseado nos parâmetros definidos pelo usuário ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 aListBox := {}
 
   
Do Case
 case mv_par09 =1 //Endereços Desocupado
	
 cQuery :=" SELECT SBE.BE_LOCAL," 
 cQuery	+=" SBE.BE_LOCALIZ," 
 cQuery	+=" NVL(SUM(SBF.BF_QUANT),0) QTD,"
 cQuery	+=" DC8_DESEST,DC8_TPESTR,DC8_CODEST"
 cQuery	+="	FROM "	
 cQuery +=RetSqlName( "SBE" )+ " SBE "	 
 cQuery +=" FULL JOIN "+RetSqlName( "SBF" )+ " SBF "	 			 
 cQuery +=" ON  BE_FILIAL    = BF_FILIAL "
 cQuery +=" AND   BE_LOCAL   = BF_LOCAL  "
 cQuery +=" AND   BE_LOCALIZ = BF_LOCALIZ "
 cQuery +=" AND   BE_ESTFIS  = BF_ESTFIS "
 cQuery +=" AND   SBF.D_E_L_E_T_  = ' '"
 cQuery +=" INNER JOIN "+RetSqlName( "DC8" )+ " DC8 "
 cQuery +=" ON   DC8_CODEST  = BE_ESTFIS" 
 cQuery +=" WHERE SBE.BE_FILIAL   = '"+xFilial("SBE")+"'"   
 cQuery +=" AND BE_LOCAL >= '"+MV_PAR05+"'"  
 cQuery +=" AND BE_LOCAL <= '"+MV_PAR06+"'"  
 
 cQuery +=" AND BE_ESTFIS >= '"+MV_PAR03+"'"   
 cQuery +=" AND BE_ESTFIS <= '"+MV_PAR04+"'" 
 cQuery +=" AND BE_LOCALIZ >='" +MV_PAR07+ "'" 
 cQuery +=" AND BE_LOCALIZ <='" +MV_PAR08+ "'" 
 cQuery +=" AND   SBE.D_E_L_E_T_  = ' '"
 
 cQuery +=" AND DC8.DC8_FILIAL = '" + xFilial("DC8") + "' "  
 cQuery +=" AND DC8.D_E_L_E_T_  = ' '"
 cQuery +=" GROUP BY BE_FILIAL,BE_LOCAL,BE_LOCALIZ,DC8_DESEST,DC8_TPESTR,DC8_CODEST HAVING NVL(SUM(SBF.BF_QUANT),0) = 0"   


 case mv_par09 =2 //Endereço Ocupado

  
   cQuery :=" SELECT SBF.BF_LOCALIZ,SBF.BF_ESTFIS,SBF.BF_LOCAL,SBF.BF_PRODUTO,DC8.DC8_CODEST,DC8.DC8_TPESTR,DC8.DC8_DESEST FROM "
   cQuery += RetSqlName( "SBF" )+ " SBF, "+RetSqlName( "SBE" )+ " SBE, "+RetSqlName( "DC8" )+ " DC8 "  
   cQuery +=" WHERE "  
   cQuery +=" BF_FILIAL = '"+xFilial("SBF")+"'"
   cQuery +=" AND BE_FILIAL = BF_FILIAL"
   cQuery +=" AND BE_LOCALIZ=BF_LOCALIZ"
   cQuery +=" AND BE_LOCAL  =BF_LOCAL"
   cQuery +=" AND BF_PRODUTO >= '"+MV_PAR01+"'" 
   cQuery +=" AND BF_PRODUTO <= '"+MV_PAR02+"'" 
   cQuery +=" AND BF_ESTFIS >= '"+MV_PAR03+"'" 
   cQuery +=" AND BF_ESTFIS <= '"+MV_PAR04+"'" 
   
   cQuery +=" AND BF_LOCAL >= '"+MV_PAR05+"'"     
   cQuery +=" AND BF_LOCAL <= '"+MV_PAR06+"'"     
   
   cQuery +=" AND BF_LOCALIZ >='" +MV_PAR07+ "'" 
   cQuery +=" AND BF_LOCALIZ <='" +MV_PAR08+ "'" 
   cQuery +=" AND BE_ESTFIS=BF_ESTFIS  " 
   cQuery +=" AND DC8_CODEST=BE_ESTFIS  "
  // cQuery +="DC8_TPESTR <> '2' AND "
   cQuery +=" AND BF_QUANT <> 0 " 
   cQuery +=" AND SBF.D_E_L_E_T_ = ' '"
   cQuery +=" AND SBE.D_E_L_E_T_ = ' '"
   cQuery +=" AND DC8.DC8_FILIAL = '" + xFilial("DC8") + "' "  
   cQuery +=" AND DC8.D_E_L_E_T_ = ' '" 
   cQuery +=" ORDER BY BF_ESTFIS,BF_LOCALIZ"
                                           
// Executa a query
//MEMOWRIT( FunName(1)+".SQL", cQuery )
End Case

TCQUERY cQuery NEW ALIAS "TRB"

aStru := DbStruct()
For nI := 1 To Len( aStru )
   If aStru[nI,2] != "C"
	   TCSetField( "TRB", aStru[nI,1], aStru[nI,2], aStru[nI,3], aStru[nI,4] )
   EndIf
Next  

ProcRegua(TRB->(Reccount()))

If mv_par09 =2
   nPorCentOcupado:=0
   nQtdItens      :=1
   cControllaItem :=TRB->BF_PRODUTO      
   cEndereco      :=TRB->BF_LOCALIZ
   cEstrutura     :=TRB->DC8_CODEST +' - '+TRB->DC8_TPESTR+'/'+TRB->DC8_DESEST
   cLocal         :=TRB->BF_LOCAL
Endif   

Do While !Eof()

If mv_par09 =2 //Carrega Array AlistBox{} com os endereços e seus percentuais de ocupação
  		
	If TRB->BF_LOCALIZ <> cEndereco  //Se mudar o Endereço
	
	   If  nPorCentOcupado>=mv_par10 .AND. nPorCentOcupado <=mv_par11 
	
		aAdd(aListBox,{.T.,cEndereco,cLocal,cEstrutura,Str(nPorCentOcupado),nQtdItens})
		cEndereco       :=TRB->BF_LOCALIZ
    	cEstrutura      :=TRB->DC8_CODEST +' - '+TRB->DC8_TPESTR+'/'+TRB->DC8_DESEST
		cLocal          :=TRB->BF_LOCAL
		nPorCentOcupado :=0
		nQtdItens       :=1
		cControllaItem  :=TRB->BF_PRODUTO
		Else
	
		cEndereco       :=TRB->BF_LOCALIZ
    	cEstrutura      :=TRB->DC8_CODEST +' - '+TRB->DC8_TPESTR+'/'+TRB->DC8_DESEST
		cLocal          :=TRB->BF_LOCAL
		nPorCentOcupado :=0
		nQtdItens       :=1
		cControllaItem  :=TRB->BF_PRODUTO
	
		
	 Endif
		
	Else
		
		If  cControllaItem <> TRB->BF_PRODUTO
			nQtdItens ++
			cControllaItem :=TRB->BF_PRODUTO
		Endif
		
	Endif
	
	nQtdNorma := DLQtdNorma(TRB->BF_PRODUTO,TRB->BF_LOCAL,TRB->BF_ESTFIS)
	nSaldoSBF := SaldoSBF(TRB->BF_LOCAL,TRB->BF_LOCALIZ,TRB->BF_PRODUTO)
	nPorCentOcupado += Round((nSaldoSBF/ nQtdNorma)*100 , 2 ) //Obtenho o Percentual de Ocupação do Endereço

  	
Else
 //Carrega Array AlistBox{} com os endereços vazios
 aAdd(aListBox,{.T.,TRB->BE_LOCALIZ,TRB->BE_LOCAL,TRB->DC8_CODEST +' - '+TRB->DC8_TPESTR+'/'+TRB->DC8_DESEST,'0','0'})
 

Endif
	
	
	dbSkip()
	
	IncProc()




	
Enddo

dbCloseArea()  


If mv_par09 =2   
 
 If nPorCentOcupado>=mv_par10 .AND. nPorCentOcupado<=mv_par11 
   aAdd(aListBox,{.T.,cEndereco,cLocal,cEstrutura,Str(nPorCentOcupado),nQtdItens})
Endif
  
Endif

If Len(aListBox)=0
   aAdd(aListBox,{.T.,' ',' ',' ','0','0'})
Endif

//aSort(aListBox, , , { |x,y| x[2] < y[2] } ) // Ordeno por Ordem de Percentual	
           
                                          
Return(.T.) 



Static Function SHOWTELA()

Local nOpca := 0
Local oOk := LoadBitmap( GetResources(), "LBOK" )
Local oNo := LoadBitmap( GetResources(), "LBNO" )
Local aButtons	:= {}

Private oDlgMain, oListbox 

Aadd(aButtons, {"S4WB010N",{||  MsAguarde( {|| U_rPerocup() }," % Ocupação ","Gerando relatório em Html...")  },OemToAnsi('Imprimir Relatório')})
Aadd(aButtons,{"LOCALIZA",&("{|| PesqLista(oListBox:nAt,@aListBox  )}"),"Pesquisa Endereços"})
Aadd(aButtons,{"S4WB011N",&("{|| ListAddress(oListBox:nAt,@aListBox)}"),"Visualiza Itens no Endereço"})


DEFINE MSDIALOG oDlgMain TITLE OemToAnsi( "WMS - % de Ocupação nos Endereços" ) FROM 120,005 TO 620,810 PIXEL //515/795
DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD                

      @ 35,02 LISTBOX oListBox FIELDS HEADER OemToAnsi("Endereço"),OemToAnsi("Armazém"),OemToAnsi("Estrutura"),OemToAnsi("% De Ocupação  "),OemToAnsi(" Qtd. Itens") FONT oBold SIZE 390,175; 
	  ON DBLCLICK (ListAddress(oListBox:nAt,@aListBox),oListBox:nColPos := 1,oListBox:Refresh()) NOSCROLL PIXEL
	  oListBox:SetArray(aListBox)
      oListBox:bLine := { || {aListBox[oListBox:nAt,2],aListBox[oListBox:nAt,3],;
      aListBox[oListBox:nAt,DEF_ESTRUTURA],aListBox[oListBox:nAt,DEF_PER_OCUP],Transform(aListBox[oListBox:nAt,DEF_QTD_ITENS],'@E 999999.99' )}}  
      
ACTIVATE MSDIALOG oDlgMain CENTERED ON INIT EnchoiceBar(oDlgMain,{|| nOpca := 1, oDlgMain:End()} , {|| oDlgMain:End()},,aButtons ) 
                                                              


*********************************************************************
Static Function PesqLista(nAt,aArray)
*********************************************************************

Local 	cDesc 		:= Space(15)
Local 	nPos, nOpc 	:= 0
Local 	oCbxPesq
Local  	oDlgPesq

Define msDialog oDlgPesq Title OemToAnsi( 'Pesquisa' ) Of oDlgPesq  From 00,00 To 080,250 Pixel

@ 10,005 Say OemToAnsi('ENDERECO ') of oDlgPesq Pixel
@ 07,046 msGet cDesc F3 "SBE"  Of oDlgPesq Pixel Size 50,10

Define sButton oBut1 From 07,97 Type 01 Enable Of oDlgPesq Pixel Action ( nOpc := 1, oDlgPesq:End() )

Activate msDialog oDlgPesq Center

cDesc := Upper(cDesc)

If  !Empty( cDesc )
	
	nPos := aScan(aListBox,{|x| x[02] = ALLTRIM(cDesc)})//Identifica o Endereço
	
	If nPos <> 0
		oListBox:nAt := nPos
		Else
		
    	Aviso('Endereço não Localizado','Endereço '+cDesc+ 'não Localizado !',{'Ok'})	
	EndIf
	
	oListBox:SetFocus()
	oListBox:Refresh()
	
EndIf

Return()



Static Function ListAddress(nAt,aArray)  

Local cEndereco :=aArray[nAt,2]  
Local cEstrut   :=aArray[nAt,4]   
Local cCodEstrut:=Substr(aArray[nAt,4],1,6) 
Local aListEnd  := {}   
Local oListEnd  
Local aButtons  := {}
Local nPorCentOcupado :=0    

nPosEndereco    :=nAt  //Variável PRIVATE armazena o número da linha do ListBox com os percentuais de ocupação
 
   cQuery :=" SELECT BF_LOCAL,BF_PRODUTO,B1_DESC,B2_QACLASS,SUM(BF_QUANT) AS SALDO_BF,DC3_PERREP,DC3_PERAPM,DC2_LASTRO*DC2_CAMADA AS CAPACIDADE"  
   cQuery +=" FROM "
   cQuery += RetSqlName( "SBF" )+ " SBF, "+RetSqlName( "SB2" )+ " SB2,"+RetSqlName( "SB1" )+ " SB1, "+RetSqlName( "DC3" )+ " DC3, "+RetSqlName( "DC2" )+ " DC2 "   
   cQuery +=" WHERE "  
   cQuery +=" BF_FILIAL = '"+xFilial("SBF")+"'" 
   cQuery +=" AND  B1_FILIAL=BF_FILIAL "            
   cQuery +=" AND  B2_FILIAL=BF_FILIAL "  
   
   cQuery +=" AND  DC3_FILIAL=BF_FILIAL"  
   cQuery +=" AND  DC3_TPESTR=BF_ESTFIS"
    
   cQuery +=" AND  DC2_FILIAL = '"+xFilial("DC2")+"'" 
   cQuery +=" AND  BF_LOCALIZ='"+cEndereco+"'" 
   cQuery +=" AND  B1_COD=BF_PRODUTO"
   cQuery +=" AND  B2_COD=BF_PRODUTO"
   cQuery +=" AND  DC3_CODPRO=BF_PRODUTO "
   
   //cQuery +=" AND  DC2_ESTRUT= DC3_TPESTR "
   cQuery +=" AND  DC2_CODNOR=DC3_CODNOR "
	
	

   cQuery +=" AND  B2_LOCAL=BF_LOCAL" 
   cQuery +=" AND  DC3_LOCAL=BF_LOCAL "
   
   cQuery +=" AND DC3.D_E_L_E_T_ = ' '"
   cQuery +=" AND DC2.D_E_L_E_T_ = ' ' "
	  
   cQuery +=" AND SBF.D_E_L_E_T_ = ' '"
   cQuery +=" AND SB2.D_E_L_E_T_ = ' '"
   cQuery +=" AND SB1.D_E_L_E_T_ = ' '"  
   cQuery +=" GROUP BY BF_LOCAL,BF_PRODUTO,B1_DESC,B2_QACLASS,DC3_PERREP,DC3_PERAPM,DC2_LASTRO,DC2_CAMADA"    
   cQuery +=" ORDER BY  BF_PRODUTO"    
  
   
   TCQUERY cQuery NEW ALIAS "TRB"

aStru := DbStruct()
For nI := 1 To Len( aStru )
   If aStru[nI,2] != "C"
	   TCSetField( "TRB", aStru[nI,1], aStru[nI,2], aStru[nI,3], aStru[nI,4] )
   EndIf
Next  

 TCSetField("TRB","B1_UREV" ,"D",8, 0) 
 
Do While TRB->(!Eof())  
	nPorCentOcupado = Round((TRB->SALDO_BF/TRB->CAPACIDADE)*100 , 2 ) //Obtenho o Percentual de Ocupação do Endereço 
	
     aAdd(aListEnd,{TRB->BF_LOCAL,Alltrim(TRB->BF_PRODUTO),Alltrim(TRB->B1_DESC),TRB->SALDO_BF,TRB->B2_QACLASS,nPorCentOcupado,TRB->CAPACIDADE})   
   DbSkip() 
EndDo

TRB->(dbCloseArea())
 

/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o Endereço estiver vazio carrego a matriz aListEnd[] com conteúdo em branco,não pode ser nulo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/

 
 If Empty(aListEnd)
     Aviso('Endereço Vazio','Não há produtos no Endereço '+cEndereco,{'Ok'})
    Return
 Endif  
 
  

    DEFINE MSDIALOG oDlgListAddress TITLE OemToAnsi( "WMS - [ Produtos no Endereço] " ) FROM 120,005 TO 500,800 PIXEL 
    DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD                

      Aadd(aButtons,{"DESTINOS",&("{|| WMSTRF(oListEnd:nAt,@aListEnd,cCodEstrut,cEndereco) }"),"Transferências"})

                   
       @ 015,005 Say OemToAnsi("Endereço   : ") FONT oBold 	 Size 0120,008 of oDlgListAddress PIXEL 
       @ 015,045 MsGet cEndereco  Size 0140,010 WHEN .F. of oDlgListAddress PIXEL 
      
       
       @ 026,005 Say OemToAnsi("Estrutura    : ") FONT oBold 	 Size 0120,008 of oDlgListAddress PIXEL 
       @ 026,045 MsGet cEstrut   Size 140,010 WHEN .F. of oDlgListAddress PIXEL   
       
       

      @ 42,02 LISTBOX oListEnd FIELDS HEADER OemToAnsi("Armazém"), OemToAnsi("Produto"),OemToAnsi("Descrição"),OemToAnsi("Endereçado"),OemToAnsi("Á Endereçar "),OemToAnsi("% Ocupação "),OemToAnsi("Cap.Norma ")  SIZE 390,148; 
      ON DBLCLICK (WMSTRF(oListEnd:nAt,@aListEnd,cCodEstrut,cEndereco),oListEnd:nColPos := 1,oListEnd:Refresh()) NOSCROLL PIXEL 
      oListEnd:SetArray(aListEnd)
      oListEnd:bLine := { || {aListEnd[oListEnd:nAt,1],aListEnd[oListEnd:nAt,2],;
      aListEnd[oListEnd:nAt,3],aListEnd[oListEnd:nAt,4],aListEnd[oListEnd:nAt,5],Transform(aListEnd[oListEnd:nAt,6],'@E 99999.99' ),Transform(aListEnd[oListEnd:nAt,7],'@E 9999999.99' )}}  

    ACTIVATE MSDIALOG oDlgListAddress CENTERED ON INIT EnchoiceBar(oDlgListAddress,{|| nOpca := 1, oDlgListAddress:End()} , {|| oDlgListAddress:End()},,aButtons )    

  
Return  


Static Function nPercentOcupado(cLocal,cProduto,cEstrutura,cEndereco,nQuantSaida)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³nPercentOcupadoºAutor  ³Edivaldo Gonçalves Data ³  08/06/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para Retornar o Percentual de Ocupação dos itens que º±±
±±ºDesc.     ³estão saindo do endereço                                    º±±
±±ºParam     ³Armazém,Produto,Estrutura,Endereço,Quantidade da saída      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Atualização do % de Ocupação do Endereço no Array AlistBox º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Local cCodPro  :=PADR(cProduto   ,TamSx3('D3_COD')[1])
Local cLocaliz :=PADR(cEndereco  ,TamSx3('BF_LOCALIZ')[1])  
Local cEstfis  :=PADR(cEstrutura ,TamSx3('BF_ESTFIS')[1])  
Local cArmazem :=PADR(cLocal     ,TamSx3('BF_LOCAL')[1])  
Local nPercentOcup

nQtdNorma     := DLQtdNorma(cCodPro,cArmazem,cEstfis)
nPercentOcup  := Round((nQuantSaida/nQtdNorma)*100 , 2 ) //Obtenho o Percentual de Ocupação em função da quantidade que está saindo do endereço  

Return nPercentOcup



Static Function WMSTRF(nAt,aArray,cCodEstrut,cEndereco)      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WMSTRFº Autor  ³Edivaldo Gonçalves Data ³          08/06/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de Transferências                                    º±±
±±ºParam     ³Posição do Endereço,Array,Estrutura,Endereço                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Transferências                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


LOCAL cSaveMenuh,nOpca := 0,cNumSeq,aCM:={},aCusto:={}
LOCAL GetList:={},lDigita,lAglutina
LOCAL cCodPict,cUmPict,cLocPict,cDocPict,cUmValid,nQuantSeg,cLotePict,cPotPict
LOCAL dDataFec := GetMV("MV_ULMES")
LOCAL oDlg,oBtn
LOCAL cTela
LOCAL lDocto := .T.
Local aButton := {}
LOCAL cLoteDigiD:=""
LOCAL nCalculaSaida
LOCAL nNovoPercentual     
LOCAL nNovaQuantidade
LOCAL nQuantNoEndereco:=aArray[nAt,4]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega a variavel que identifica se o calculo do custo e' :    ³
//³               O = On-Line                                    ³
//³               M = Mensal                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCusMed  := GetMv("MV_CUSMED")
PRIVATE cCadastro:= 'Transferências'	//"Transferˆncias"
PRIVATE aRegSD3  := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o custo medio e' calculado On-Line               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCusMed == "O"
	PRIVATE nHdlPrv // Endereco do arquivo de contra prova dos lanctos cont.
	PRIVATE lCriaHeader := .T. // Para criar o header do arquivo Contra Prova
	PRIVATE cLoteEst 	// Numero do lote para lancamentos do estoque
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona numero do Lote para Lancamentos do Faturamento     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   //	dbSelectArea("SX5")
  //	dbSeek(xFilial()+"09EST")
  //	cLoteEst:=IIF(Found(),Trim(X5Descri()),"EST ")
	PRIVATE nTotal := 0 	// Total dos lancamentos contabeis
	PRIVATE cArquivo	// Nome do arquivo contra prova
EndIf


If (ExistBlock("MT260BTN"))
	aButton := ExecBlock("MT260BTN",.F.,.F.)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclusao de botao que permite selecionar lote destino da     ³
//³ transferencia diferente do lote origem.                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aButton,{'BONUS',{|| A260LDest(cCodDest,@cLoteDigiD,cLotePict,.T.)},'Sel. Lote Destino'}) //"Sel. Lote Destino"

PRIVATE cDescOrig:=cDescDest:=Criavar("B1_DESC", .F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variavel lPyme utilizada para Tratamento do Siga PyME        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lPyme:= Iif(Type("__lPyme") <> "U",__lPyme,.F.)  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificar data do ultimo fechamento em SX6.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If dDataFec >= dDataBase
	Help ( " ", 1, "FECHTO" )
	Return
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa tecla F4 para comunicacao com Saldos dos Lotes         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Key VK_F4 TO A260AvalF4()



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega as pictures do SX3 para manter o padrao                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(2)    // ordem por campo

dbSeek("D3_COD")
If EOF();Help(" ",1,"NOSX3");EndIf
PRIVATE cCodOrig :=PADR(aArray[nAt,2],TamSx3('D3_COD')[1]),cCodDest := Space(X3_TAMANHO)     
cCodPict := TRIM(X3_PICTURE)

dbSeek("D3_UM")
If EOF();Help(" ",1,"NOSX3");EndIf
PRIVATE cUmOrig := cUmDest := Space(X3_TAMANHO)
cUmPict := TRIM(X3_PICTURE)
cUmValid:= TRIM(X3_VALID)

dbSeek("D3_LOCAL")
If EOF();Help(" ",1,"NOSX3");EndIf
PRIVATE cLocOrig := cLocDest := Space(X3_TAMANHO)
cLocPict := TRIM(X3_PICTURE)

dbSeek("D3_LOCALIZ")
If EOF();Help(" ",1,"NOSX3");EndIf
PRIVATE cLoclzOrig :=cEndereco,cLoclzDest := Space(X3_TAMANHO)
cLoclzPict := TRIM(X3_PICTURE)

dbSeek("D3_QUANT")
If EOF();Help(" ",1,"NOSX3");EndIf
PRIVATE nQuant260   := Criavar("D3_QUANT")
PRIVATE cQtdPict := TRIM(X3_PICTURE)

dbSeek("D3_QTSEGUM")
If EOF();Help(" ",1,"NOSX3");EndIf
PRIVATE nQuant260D   :=  Criavar("D3_QTSEGUM")
PRIVATE cQtd2Pict := TRIM(X3_PICTURE)

dbSeek("D3_DOC")
If EOF();Help(" ",1,"NOSX3");EndIf
PRIVATE cDocto := CriaVar("D3_DOC")
cDocPict := TRIM(X3_PICTURE)

dbSeek("D3_NUMLOTE")
If EOF();Help(" ",1,"NOSX3");EndIf
PRIVATE cNumLote := Space(X3_TAMANHO)
cLotePict := TRIM(X3_PICTURE)

dbSeek("D3_NUMSERI")
If EOF();Help(" ",1,"NOSX3");EndIf
PRIVATE cNumSerie := Space(X3_TAMANHO)
cSeriePict := TRIM(X3_PICTURE)

dbSeek("D3_LOTECTL")
If EOF();Help(" ",1,"NOSX3");EndIf
PRIVATE cLoteDigi:= Space(X3_TAMANHO)
cLoteDigiD:= Space(X3_TAMANHO)
cLotCTLPic := TRIM(X3_PICTURE)

dbSeek("D3_DTVALID")
If EOF();Help(" ",1,"NOSX3");EndIf
PRIVATE dDtValid := CriaVar("D3_DTVALID")
cDtVldPic := TRIM(X3_PICTURE)

dbSeek("D3_POTENCI")
If EOF();Help(" ",1,"NOSX3");EndIf
PRIVATE nPotencia:= CriaVar("D3_POTENCI")
cPotPict := TRIM(X3_PICTURE) 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio os campos após preenchimento do campo Produto                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
A260IniCpo(1)   
A260Locali()



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve ordem original do SX3                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSetOrder(1)

PRIVATE dEmis260 := M->dDataBase
PRIVATE lControl:=.F.
While .T.
	nOpca:=0
	DEFINE MSDIALOG oDlg FROM  140,000 TO 450,680 TITLE OemToAnsi('WMS - Transferências') PIXEL	//"Transferˆncias"
	DEFINE SBUTTON oBtn FROM 800,800 TYPE 5 ENABLE OF oDlg
	@ 026,006 TO 056,320 LABEL OemToAnsi('Origem')  OF oDlg  PIXEL	//"Origem"
	@ 062,006 TO 092,320 LABEL OemToAnsi('Destino') OF oDlg  PIXEL	//"Destino"
	@ 034,039 MSGET cCodOrig F3 "SB1" WHEN .F. Picture PesqPict("SD3","D3_COD") Valid NaoVazio() .And. A260IniCpo(1) SIZE 68,09 OF oDlg PIXEL
	@ 034,153 MSGET cUmOrig  When .F. SIZE 12,09 OF oDlg PIXEL
	@ 034,216 MSGET cLocOrig WHEN .F. Picture cLocPict Valid NaoVazio() .And. A260Local() .And. VldUser("D3_LOCAL") SIZE 12,09 OF oDlg PIXEL
	If !lPyme
		@ 034,241 MSGET cLoclzOrig F3 "SBE" Picture cLoclzPict WHEN.F. Valid If(Localiza(cCodOrig),A260Locali(),Vazio()) When Localiza(cCodOrig) SIZE 60,09 OF oDlg PIXEL
	EndIf
	@ 069,039 MSGET cCodDest F3 "SB1" Picture cCodPict Valid NaoVazio() .And. A260IniCpo(2) SIZE 68,9 OF oDlg PIXEL
	@ 069,153 MSGET cUmDest  When .F. SIZE 12,09 OF oDlg PIXEL
	@ 069,216 MSGET cLocDest Picture cLocPict Valid NaoVazio() .And. A260LocDest() .And. VldUser("D3_LOCAL") SIZE 12,09 OF oDlg PIXEL
	If !lPyme
		@ 069,241 MSGET cLoclzDest F3 "SBE" Picture cLoclzPict Valid If(Localiza(cCodDest),A260Locali(),Vazio()) When Localiza(cCodDest) SIZE 60,09 OF oDlg PIXEL
		@ 106,029 MSGET cNumSerie When Localiza(cCodOrig) SIZE 85,09 OF oDlg PIXEL
		@ 106,132 MSGET cLoteDigi  Picture cLotCtlPic Valid A260Lote() When (Rastro(cCodOrig,"S") .Or. Rastro(cCodOrig,"L")) SIZE 45,09 OF oDlg PIXEL
		@ 106,204 MSGET cNumLote   Picture cLotePict  Valid A260Lote() When Rastro(cCodOrig,"S") SIZE 27,09 OF oDlg PIXEL
		@ 106,257 MSGET dDtValid   Picture cDtVldPic  Valid dDtValid > dDataBase When lControl  SIZE 36,09 OF oDlg PIXEL
		@ 106,305 MSGET nPotencia  Picture cPotPict   When lControl  SIZE 07,09 OF oDlg PIXEL		
	EndIf
	@ 128,037 MSGET nQuant260  Picture cQtdPict   Valid A260Quant(1) SIZE 63,09 OF oDlg PIXEL
	@ 128,137 MSGET nQuant260D Picture cQtd2Pict  Valid A260Quant(2) SIZE 63,09 OF oDlg PIXEL
	@ 128,220 MSGET dEmis260 Valid A260Data() .And. VldUser('D3_EMISSAO') SIZE 45,09 OF oDlg PIXEL
	@ 128,282 MSGET cDocto Picture cDocPict Valid A260Doc() SIZE 44,09 OF oDlg PIXEL WHEN lDocto
	@ 048,040 SAY cDescOrig 								SIZE 130,6 OF oDlg PIXEL
	@ 084,040 SAY cDescDest 								SIZE 130,6 OF oDlg PIXEL
	@ 036,011 SAY OemtoAnsi('Produto') SIZE 24,7  OF oDlg PIXEL //"Produto"
	@ 032,118 SAY OemToAnsi('Un.Medida') SIZE 32,13 OF oDlg PIXEL //"Unidade de Medida"
	If !lPyme
		@ 032,178 SAY OemToAnsi('Armaz./Endereço')	SIZE 35,13 	OF oDlg PIXEL //"Armazem  /  Endereco"
	Else
		@ 036,178 SAY OemToAnsi('Armazém')	SIZE 35,13 	OF oDlg PIXEL //"Armazem"
	EndIf
	@ 071,011 SAY OemToAnsi('Produto') SIZE 24,7  OF oDlg PIXEL //"Produto"
	@ 067,118 SAY OemToAnsi('UM') SIZE 32,13 OF oDlg PIXEL //"Unidade de Medida"
	If !lPyme
		@ 067,178 SAY OemToAnsi('Armaz./Endereço')	SIZE 35,13 	OF oDlg PIXEL //"Armazem  /  Endereco"
	Else
		@ 071,178 SAY OemToAnsi('Armazém')	SIZE 35,13 	OF oDlg PIXEL //"Armazem"
	EndIf
	If !lPyme
		@ 106,004 SAY OemToAnsi('Número de Série') SIZE 25,13 OF oDlg PIXEL //"N£mero de Serie"
		@ 106,118 SAY OemToAnsi('Lote') SIZE 12,13 OF oDlg PIXEL //"Lote"
		@ 106,179 SAY OemToAnsi('Sub-Lote') SIZE 22,7  OF oDlg PIXEL //"Sub-Lote"
		@ 106,234 SAY OemToAnsi('Data de Validade') SIZE 22,13 OF oDlg PIXEL //"Data de Validade"
		@ 106,294 SAY OemToAnsi('Pot') SIZE 09,13 	OF oDlg PIXEL //"Pot."	
	EndIf
	@ 128,003 SAY OemToAnsi('Quantidade Primária') SIZE 30,16 OF oDlg PIXEL //"Quantidade Prim ria"
	@ 128,104 SAY OemToAnsi('Quantidade Secundária') SIZE 30,16 OF oDlg PIXEL //"Quantidade Secund ria"
	@ 128,205 SAY OemToAnsi('Data') SIZE 12,7  OF oDlg PIXEL //"Data"
	@ 128,270 SAY OemToAnsi('Doc') SIZE 29,7  OF oDlg PIXEL //"Documento"
	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| If(A260PTE(),(nOpca:=1,oDlg:End()),"") },{||nOpca:=0,oDlg:End()},, aButton)
	IF nOpcA == 0
		Exit
	ENDIF
	If cCodOrig+cUmOrig+cLocOrig+cLocLzOrig+cLoteDigi == cCodDest+cUmDest+cLocDest+cLoclzDest+If(!Empty(cLoteDigiD),cLoteDigiD,cLoteDigi)
		Help(" ",1,"MA260IGUAL")
		Loop
	EndIf
	If Localiza(cCodOrig)
		If !MtAvlNSer(cCodOrig,cNumSerie,nQuant260,nQuant260D)
			Loop
		EndIf
		If Empty(cLocLzOrig) .And. Empty(cNumSerie)
			Help(" ",1,"LOCALIZOBR")
			Loop
		EndIf
		If (!Empty(cLocLzOrig) .Or. !Empty(cNumSerie)) .And. QtdComp(SaldoSBF(cLocOrig,cLoclzOrig,cCodOrig,cNumSerie,cLoteDigi,If(Rastro(cCodOrig, 'S'),cNumLote,''))) < QtdComp(nQuant260)
			Help(" ",1,"SALDOLOCLZ")
			Loop
		EndIf
		If !ProdLocali(cCodDest,cLocDest,cLoclzDest)
			Loop
		EndIf
	EndIf
	If Rastro(cCodOrig) .And. Empty(IF(Rastro(cCodOrig,"S"),cNumLote,cLoteDigi))
		Help(" ",1,"MA260LOTE")
		Loop
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a Qtde estiver em branco ele deve dar uma mensagem  ³
	//³ de que este registro nao sera' gravado.                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nQuant260 == 0
		Help(" ",1,"MA240NAOGR")
		Loop
	Endif
	//--> Verifica se o saldo do armz esta liberado
	If !SldBlqSB2(cCodOrig,cLocOrig)
		Loop
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste Quantidade Negativa                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If GetMV('MV_ESTNEG')=='N'
		If SB2->(dbSeek(xFilial('SB2')+cCodOrig+cLocOrig, .F.))
			//--> Verifica se o saldo do armz esta liberado
			If QtdComp((SaldoMov()-nQuant260)) < QtdComp(0)
				Help(' ',1,'MA240NEGAT')
				Loop
			EndIf
		EndIf
	EndIf	
	
 If  a260Processa(cCodOrig,cLocOrig,nQuant260,cDocto,dEmis260,nQuant260D,cNumLote,cLoteDigi,dDtValid,cNumSerie,cLoclzOrig,cCodDest,cLocDest,cLocLzDest,.F.,NIL,NIL,"MATA260")
 
   MsAguarde( {|| nCalculaSaida:=nPercentOcupado(cLocOrig,cCodOrig,cCodEstrut,cLoclzOrig,nQuant260) }, "Endereço de Origem","Atualizando Percentual de Ocupação...")
 
   nNovoPercentual:=Round(Val(aListBox[nPosEndereco,DEF_PER_OCUP])-nCalculaSaida   , 2 ) 
  
   aListBox[nPosEndereco,DEF_PER_OCUP]:=Str(nNovoPercentual)  
    
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //Atualiza a Quantidade de Itens apenas no Endereço de Origem  //
  //Quando este zerar o saldo no Endereço                        //
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  
   If nQuant260=nQuantNoEndereco //Zerou o Endereço
    nNovaQuantidade:=aListBox[nPosEndereco,DEF_QTD_ITENS]-1
    aListBox[nPosEndereco,DEF_QTD_ITENS]:=Transform(nNovaQuantidade,'@E 999999.99')
   Endif
   
     
   n :=ASCAN(aListBox,{|X|X[2] = cLocLzDest})//Verifica se o Endereço de Destino está no Array AlistBox{} 
        
     	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     	//³ Verifica se o Endereço de Destino da Transferência está no Array aListBox{} para atualizar o seu percentual de ocupação  ³
    	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

         IF n > 0 
            SubstrcCodEstrut        :=Substr(aListBox[n,DEF_ESTRUTURA],1,6 )                        //Código da estrutura de Destino
            cCodEstrut              :=PADR(SubstrcCodEstrut ,TamSx3('BF_ESTFIS')[1])                //Compatibiliza tamanho de cCodEstrut com o tamanho do X3
                                                                                                         
   
         MsAguarde( {|| nCalculaSaida:=nPercentOcupado(cLocDest,cCodDest,cCodEstrut,cLocLzDest,nQuant260) }, "Endereço de Saída","Atualizando Percentual de Ocupação...")
         
         nNovoPercentual:=Round(Val(aListBox[n,DEF_PER_OCUP])+nCalculaSaida,2) 
         aListBox[n,DEF_PER_OCUP]:=Str(nNovoPercentual)  

      
   
         Endif
         
         oDlgListAddress:End() 
           
		// Processa Gatilhos
		EvalTrigger()
		If __lSX8
			ConfirmSX8()
		Endif
	Else
		If __lSX8
			RollBackSX8()
		EndIf
		Loop
 EndIf
	Exit
EndDo  


Return


Static FUNCTION A260LDest(cProduto,cLoteDest,cPicture,lDigita)
Local oDlg,lConfirma:=.F.
Local cNovoLote:=cLoteDest
If Rastro(cProduto)
	DEFINE MSDIALOG oDlg TITLE 'Sel. Lote Destino' From 145,30 To 270,200 OF oMainWnd PIXEL //"Sel. Lote Destino"
	@ 10,07 TO 40,80 LABEL 'Informe Lote Destino' OF oDlg PIXEL //"Informe Lote Destino"	
	@ 20,12 MSGET cNovoLote WHEN lDigita Picture cPicture OF oDlg PIXEL
	DEFINE SBUTTON FROM 50,15 TYPE 1 ACTION (oDlg:End(),lConfirma:=.T.) ENABLE OF oDlg
	DEFINE SBUTTON FROM 50,43 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTER
	If lConfirma
		cLoteDest:=cNovoLote
	EndIf
EndIf
Return  


ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Static Function A260Data()
LOCAL dData
LOCAL dDataFec := GetMV("MV_ULMES")
dData:= &(ReadVar())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificar data do ultimo fechamento em SX6.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If dDataFec >= dData
	Help ( " ", 1, "FECHTO" )
	Return .F.
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A260LocDest³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 29/04/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡„o do campo cLocDest                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA260                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A260LocDest()
LOCAL cAlias:=Alias(),nOrder:=IndexOrd(),nRecno:=Recno(),lRet:=.T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o produto est  sendo inventariado.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BlqInvent(cCodDest,cLocDest)
	Help(" ",1,"BLQINVENT",,cCodDest+" Almox: "+cLocDest,1,11)
	lRet:=.F.
EndIf
If lRet .And. (GetMV("MV_VLDALMO") == "S")
	dbSelectArea("SB2")
	dbSetOrder(1)
	dbSeek(xFilial()+cCodDest+cLocDest)
	If !Found()          
		Help(" ",1,"A260LOCAL")
		lRet:=.F.
	EndIf
	dbSelectArea(cAlias)
	dbSetOrder(nOrder)
	dbGoTo(nRecno)
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A260Lote   ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 25/11/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡„o referente aos campos de Lote                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA260                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A260Lote()
Local cAlias := Alias()
Local nOrder := IndexOrd()
Local nRecno := Recno()
Local lRet   := .T.
Local cVar	 := UPPER(ReadVar())

If Empty(&(ReadVar()))
	Help(" ",1,"MA260LOTE")
	lRet:=.F.
EndIf

If lRet
	If Rastro(cCodOrig,'S') .And. If(cVar == "CNUMLOTE",!Empty(cLoteDigi),!Empty(cNumLote))
		SB8->(dbSetOrder(2))
		If SB8->(dbSeek(xFilial('SB8') + cNumLote + cLoteDigi + cCodOrig + cLocOrig, .F.))
			cLoteDigi := SB8->B8_LOTECTL
			dDtValid  := SB8->B8_DTVALID
			nPotencia := SB8->B8_POTENCI
		Else
			Help(' ', 1, 'A240LOTERR')
			lRet := .F.
		EndIf
	Else
		SB8->(dbSetOrder(3))
		If SB8->(dbSeek(xFilial()+cCodOrig+cLocOrig+cLoteDigi, .F.))
			dDtValid :=SB8->B8_DTVALID
			nPotencia:=SB8->B8_POTENCI
		Else
			Help(' ', 1, 'A240LOTERR')
			lRet := .F.
		EndIf
	EndIf
EndIf

dbSelectArea(cAlias)
dbSetOrder(nOrder)
dbGoto(nRecno)
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A260Doc  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 31/03/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o documento da transferencia.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA260                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A260Doc()
LOCAL lRet:=.T.,cAlias:=Alias(),nOrder:=IndexOrd(),nRecno:=Recno()
LOCAL cDoc:= &(ReadVar())
If !Empty(cDoc)
	dbSelectArea("SD3")
	dbSetOrder(2)
	If dbSeek(xFilial()+cDoc)
		Help(" ",1,"a24101")
		lRet:= .F.
	EndIf
	dbSelectArea(cAlias)
	dbSetOrder(nOrder)
	dbGoTo(nRecno)
EndIf
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A260Locali³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 14/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida as localizacoes da transferencia                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA260                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A260Locali()
LOCAL lRet:=.T.
LOCAL cConteudo:=&(ReadVar())    

If AllTrim(ReadVar()) == "CLOCLZORIG"
	lRet:=Vazio(cConteudo) .Or. ExistCpo("SBE",cLocOrig+&(ReadVar()))
Else
	lRet:=Vazio(cConteudo) .Or. ExistCpo("SBE",cLocDest+&(ReadVar()))
EndIf
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A260ChkCF     ³ Fernando Joly Siquini     ³ Data ³ 16/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o D3_CF correto para ser utilizado em Transferencias³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A260ChkCF()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MatA260                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A260ChkCF(cCod, cLocal, cNumSeq, cCF, cLocCQ)

Local lRet       := .F.
Local nOrdSD3    := SD3->(IndexOrd())
Local nRecSD3    := SD3->(Recno())

cLocCQ := If(cLocCQ==Nil.Or.ValType(cLocCQ)#'C',GetMV('MV_CQ'),cLocCQ)

If Subs(cCF,3,1) == '4'
	lRet := .T.
EndIf

SD3->(dbSetOrder(nOrdSD3))
SD3->(dbGoto(nRecSD3))

Return lRet

STATIC Function A260IniCpo(nOrigDest)
STATIC lA260INI := NIL
LOCAL lRet:=.T.
LOCAL cVar := IIF(nOrigDest=1,cCodOrig,cCodDest)
Local nDec2UM := TamSX3('D3_QTSEGUM')[2]

lA260INI := If(lA260INI == NIL,ExistBlock("A260INI"),lA260INI)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa PE na digitacao do campo                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lA260INI
	lRet:=Execblock("A260INI",.f.,.f.)
EndIf

If lRet
	dbSelectArea("SB1")
	If !dbSeek(xFilial()+cVar)
		Help(" ",1,"A260SB1")
		lRet:=.F.
	EndIf
	If lRet .And. nOrigDest == 1
		cUmOrig  := B1_UM
		cLocOrig := B1_LOCPAD
		cDescOrig:= B1_DESC
		cCodDest := IIF(Empty(cCodDest),cCodOrig,cCodDest)
		cUmDest  := IIF(Empty(cUmDest),B1_UM,cUmDest)
		cLocDest := IIF(Empty(cLocDest),B1_LOCPAD,cLocDest)
		cDescDest:= IIF(Empty(cDescDest),B1_DESC,cDescDest)
		nQuant260D := Round(QtdComp(ConvUm(B1_COD, nQuant260, nQuant260D, 2)), nDec2UM)
	Else
		cUmDest  := B1_UM
		cLocDest := IIF(Empty(cLocDest),B1_LOCPAD,cLocDest)
		cDescDest:= B1_DESC
	EndIf
EndIf

Return lRet  


Static Function A260Local()
Static l260Local := NIL
Local lRet := .T., cLocal
Local cAlias:=Alias(),nOrder:=IndexOrd(),nRecno:=Recno()
cLocal := &(ReadVar())
l260Local:=If(l260Local==NIL,ExistBlock("A260LOC"),l260Local)
If cLocal == GetMV("MV_CQ")
	Help(" ",1,"A260LOCCQ")
	lRet:=.F.
ElseIf cLocal == GetMV("MV_LOCPROC")
	Help(" ",1,"A260LOCPRO")
	lRet:=.F.
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o produto est  sendo inventariado.      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BlqInvent(cCodOrig,cLocal)
		Help(" ",1,"BLQINVENT",,cCodOrig+" Almox: "+cLocal,1,11)
		lRet:=.F.
	EndIf
	If lRet
		If l260Local
			ExecBlock("A260LOC",.F.,.F., {cCodOrig,cLocal})
		EndIf
		dbSelectArea("SB2")
		dbSetOrder(1)
		If !(dbSeek(xFilial()+cCodOrig+cLocal))
			Help(" ",1,"A260LOCAL")
			lRet:=.F.
		EndIf
		dbSelectArea(cAlias)
		dbSetOrder(nOrder)
		dbGoTo(nRecno)
	EndIf
EndIf
Return lRet 


Static Function A260PTE()
Local lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para a validacao dos dados digitados nos    ³
//³ Gets fixos.                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MT260TOK")
	lRet := ExecBlock("MT260TOK",.F.,.F.)
	lRet := If(ValType(lRet)#"L",.T.,lRet)
EndIf
		
Return(lRet)


 
Static Function A260Quant(nTipoUM)

Local aAreaAnt   := GetArea()
Local aAreaSB1   := SB1->(GetArea())
Local aAreaSB2   := SB2->(GetArea())
Local aAreaSB8   := SB8->(GetArea())
Local aAreaSBE   := SBE->(GetArea())
Local lEstNeg    := .F.
Local lRastro    := .F.
Local lLocaliza  := .F.
Local lRet       := .T.
Local nTam1UM    := TamSX3('D3_QUANT')[1]
Local nTam2UM    := TamSX3('D3_QTSEGUM')[1]
Local nDec1UM    := TamSX3('D3_QUANT')[2]
Local nDec2UM    := TamSX3('D3_QTSEGUM')[2]
Local nQuantVld  := 0

SB1->(dbSetOrder(1))

If nTipoUM == 1
	//-- Verifica se deve Reinicializar a 2aUM com base na 1aUM Digitada
	nQuantVld := Round(QtdComp(ConvUm(cCodOrig, nQuant260, nQuant260D,2)), nDec2UM)
	If !(StrZero(nQuant260D,nTam2UM,nDec2UM)==StrZero(nQuantVld,nTam2UM,nDec2UM))
		nQuant260D := nQuantVld
	EndIf
ElseIf nTipoUM == 2
	//-- Verirfica se deve Reinicializar a 1aUM com base na 2aUM Digitada
	nQuantVld := Round(QtdComp(ConvUm(cCodOrig, nQuant260, nQuant260D, 1)), nDec1UM)
	If !(StrZero(nQuant260,nTam1UM,nDec1UM)==StrZero(nQuantVld,nTam1UM,nDec1UM))
		nQuant260 := nQuantVld
	EndIf
EndIf

//-- Valida Movimenta‡äes c/Quantidade Negativa
If QtdComp(nQuant260) < QtdComp(0)
	Help(' ', 1, 'POSIT')
	lRet := .F.
EndIf

If lRet
	lEstNeg   := (GetMV('MV_ESTNEG')=='N')
	lRastro   := Rastro(cCodOrig)
	lLocaliza := Localiza(cCodOrig)
EndIf

If lRet .And. (lEstNeg.Or.lRastro.Or.lLocaliza)
	//-- Valida Saldo em Estoque Negativo
	If lEstNeg
		dbSelectArea('SB2')
		aAreaSB2 := GetArea()
		dbSetOrder(1)
		If !dbSeek(xFilial()+cCodOrig+cLocOrig)
			Help(' ', 1, 'REGNOIS')
			lRet := .F.
		ElseIf QtdComp(SaldoMov()) < QtdComp(nQuant260)
			Help(' ', 1, 'MA240NEGAT')
			lRet := .F.
		EndIf
		dbSetOrder(aAreaSB2[2])
		dbGoto(aAreaSB2[3])
	EndIf
	
	//-- Valida Saldo em Estoque ref. a Rastreabilidade
	If lRet .And. lRastro
		dbSelectArea('SB8')
		aAreaSB8 := GetArea()
		If	Rastro(cCodOrig, 'S')
			dbSetOrder(2)
			If dbSeek(xFilial('SB8')+cNumLote+cLoteDigi+cCodOrig+cLocOrig, .F.)
				If QtdComp(SB8Saldo(nil,.T.,nil,nil,nil,nil,nil,dEmis260)) < QtdComp(nQuant260)
					Help(' ', 1, 'A240NEGAT' )
					lRet := .F.
				EndIF
			EndIf
		ElseIf QtdComp(SaldoLote(cCodOrig,cLocOrig,cLoteDigi,NIL,NIL,.T.,NIL,dEmis260)) < QtdComp(nQuant260)
			Help(' ', 1, 'A240NEGAT')
			lRet := .F.
		EndIf
		dbSetOrder(aAreaSB8[2])
		dbGoto(aAreaSB8[3])
	EndIf
	
	//-- Valida Saldo em Estoque ref. a Localiza‡Æo
	If lRet .And. lLocaliza
		If lRet
			dbSelectArea('SBE')
			aAreaSBE := GetArea()
			dbSetOrder(1)
			If dbSeek(xFilial('SBE')+cLocDest+cLoclzDest, .F.)
				If QtdComp(BE_CAPACID)>QtdComp(0) .And. (QtdComp(BE_CAPACID)<QtdComp(nQuant260+QuantSBF(cLocDest, cLoclzDest)))
					Help(' ', 1, 'MA265CAPAC')
					lRet := .F.
				EndIf
			EndIf
			If lRet .And. QtdComp(SaldoSBF(cLocOrig,cLoclzOrig,cCodOrig,cNumSerie,cLoteDigi,If(Rastro(cCodOrig,'S'),cNumLote,'')))<QtdComp(nQuant260)
				Help(' ', 1, 'SALDOLOCLZ')
				lRet := .F.
			EndIf
			dbSetOrder(aAreaSBE[2])
			dbGoto(aAreaSBE[3])
		EndIf
	EndIf
EndIf

SB1->(dbSetOrder(aAreaSB1[2]))
SB1->(dbGoto(aAreaSB1[3]))
RestArea(aAreaAnt)

Return lRet




