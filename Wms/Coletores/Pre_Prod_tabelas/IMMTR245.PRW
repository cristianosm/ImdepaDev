#include 'protheus.ch'
#include 'topconn.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ IMMTR245 ºAutor ³Edivaldo Gonçalves   º Data ³  15/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Saldos a Distribuir - modo gráfico                         º±±
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
#DEFINE POS_LEGENDA   	  1  //Legenda do Endereço
#DEFINE POS_ENDERECO	  2  //Endereço do Produto
#DEFINE POS_PERCENT_OCUP  3  //Percentual de Ocupação no Endereço
#DEFINE POS_SALDO_PROD	  4  //Saldo do Produto no Endereço  

#DEFINE POS_PICK_FIXO 	  1  //Endereço Picking Fixo
#DEFINE POS_PROD_FIXO     2  //Produto Fixo

#DEFINE POS_NORMA_2       1  //2º Norma do Produto
#DEFINE POS_QTD_END       2  //Saldo do Produto no Endereco no 2º Armazem


User Function IMMTR245() 

Local   cPerg      :='IMDMTR245' 
Local   aDados     :={}
Private nLinha     := 3000 
Private nPagina    :=0  
Private aPickings  :={} 
                                 
 If cperg <> "MP8.11"
	cPerg := PADR(cperg,10)
 Endif
 
 
 //Ajusta Grupo de Perguntas
 aAdd(aDados,{ "Do Armazem ?          ","Do Armazem ?          ","Do Armazem ?          ","mv_ch1","C", 2 ,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","",""," ","","" })
 aAdd(aDados,{ "Ate Armazem ?         ","Ate Armazem ?         ","Ate Armazem ?         ","mv_ch2","C", 2 ,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","",""," ","","" })
 aAdd(aDados,{ "Do Produto  ?         ","Do Produto ?          ","Do Produto ?          ","mv_ch3","C", 15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","" }) 
 aAdd(aDados,{ "Ate Produto ?         ","Ate Produto?          ","Ate Produto?          ","mv_ch4","C", 15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","" })
 aAdd(aDados,{ "Da Data ?             ","Da Data ?             ","Da Data ?             ","mv_ch5","D", 8 ,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","",""," ","","" })
 aAdd(aDados,{ "Até a Data ?          ","Até a Data ?          ","Até a Data ?          ","mv_ch6","D", 8 ,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","",""," ","","" })
 aAdd(aDados,{ "Lista Saldos Zerados ?","Lista Saldos Zerados ?","Lista Saldos Zerados ?","mv_ch7","N", 1 ,0,0,"C","","mv_par07","Sim","Sim","Sim","","","Nao","Nao","Nao","",""," "," "," ","","","","","","","","","","","","","","" })
 aAdd(aDados,{ "Da Nota Fiscal ?      ","Da Nota Fiscal ?      ","Da Nota Fiscal ?      ","mv_ch8","C", 9 ,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","",""," ","","" })
 aAdd(aDados,{ "Ate a Nota Fiscal ?   ","Ate a Nota Fiscal ?   ","Ate a Nota Fiscal ?   ","mv_ch9","C", 9 ,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","",""," ","","" }) 
 aAdd(aDados,{ "Imprime Saldo ?       ","Imprime Saldo ?       ","Imprime Saldo ?       ","mv_cha","N", 1 ,0,0,"C","","mv_par10","Sim","Sim","Sim","","","Nao","Nao","Nao","",""," "," "," ","","","","","","","","","","","","","","" })
 
 U_ImdASX1( cPerg, aDados )


 
    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa a rotina de impressao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
	
		If  Pergunte(cPerg,.T.)
		
		  MsAguarde({ |lEnd| xPrintRel(),OemToAnsi('Processando o relatório.')}, OemToAnsi('Aguarde...'))  

		Endif
		
Return


Static Function xPrintRel()
Local  aEndereFixo  :={} 
Local  aEnderecos   :={}  
Local  cDocAtu      :=' '
Local  cUM          :=' ' 
Local  cEndereco    :=' '     
Local  cEndereSugest:=' ' // Endereço Sugerido para Endereçamento 

Private	oPrint		:= TMSPrinter():New(OemToAnsi('Saldos a Distribuir')),;
		oBrush		:= TBrush():New(,4),;
		oPen		:= TPen():New(0,5,CLR_BLUE),;
		cFileLogo	:= GetSrvProfString('Startpath','') + 'lgrl01' + '.BMP',;
		oFont07		:= TFont():New('Courier New',07,07,,.F.,,,,.T.,.F.),;
		oFont08		:= TFont():New('Courier New',08,08,,.F.,,,,.T.,.F.),;
		oFont09		:= TFont():New('Tahoma',09,09,,.F.,,,,.T.,.F.),;
		oFont10		:= TFont():New('Tahoma',10,10,,.F.,,,,.T.,.F.),;
		oFont10n	:= TFont():New('Courier New',10,10,,.T.,,,,.T.,.F.),;
		oFont11		:= TFont():New('Tahoma',11,11,,.F.,,,,.T.,.F.),;
		oFont12		:= TFont():New('Tahoma',12,12,,.T.,,,,.T.,.F.),;
		oFont12n	:= TFont():New('Tahoma',12,12,,.F.,,,,.T.,.F.),;
		oFont13		:= TFont():New('Tahoma',13,13,,.T.,,,,.T.,.F.),;
		oFont14		:= TFont():New('Tahoma',14,14,,.T.,,,,.T.,.F.),;
		oFont15		:= TFont():New('Courier New',15,15,,.T.,,,,.T.,.F.),;
		oFont18		:= TFont():New('Arial',18,18,,.T.,,,,.T.,.T.),;  
		oFont18b	:= TFont():New('Arial',18,18,,.T.,,,,.F.,.F.),;
		oFont16		:= TFont():New('Arial',16,16,,.T.,,,,.T.,.F.),;
		oFont20		:= TFont():New('Arial',20,20,,.T.,,,,.T.,.F.),;
		oFont22		:= TFont():New('Arial',22,22,,.T.,,,,.T.,.F.)

	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Define que a impressao deve ser RETRATO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:SetLandscape()//SetPortrait()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta query   ³                                                
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		
   cQuery :=" SELECT SDA.DA_PRODUTO,SDA.DA_LOCAL,SDA.DA_QTDORI,SDA.DA_SALDO,SDA.DA_DOC,SDA.DA_DATA,SDA.DA_LOTECTL,SB1.B1_DESC " 
   cQuery +=" FROM "
   cQuery += RetSqlName( "SDA" )+ " SDA, "+RetSqlName( "SB1" )+ " SB1 "  
   cQuery +=" WHERE "  
   cQuery +=" DA_FILIAL = '"+xFilial("SDA")+"'"
   cQuery +=" AND B1_FILIAL = DA_FILIAL"
   cQuery +=" AND B1_COD=DA_PRODUTO"
   cQuery +=" AND DA_LOCAL >= '"+MV_PAR01+"'" 
   cQuery +=" AND DA_LOCAL <= '"+MV_PAR02+"'" 
   cQuery +=" AND DA_PRODUTO>= '"+MV_PAR03+"'" 
   cQuery +=" AND DA_PRODUTO<= '"+MV_PAR04+"'" 
   cQuery +=" AND DA_DATA >='"+DTOS(MV_PAR05)+"'"     
   cQuery +=" AND DA_DATA <='"+DTOS(MV_PAR06)+"'" 
     
  If MV_PAR07=1
    cQuery +=" AND DA_SALDO >=0"
   Else
    cQuery +=" AND DA_SALDO >0"
  Endif   
  
  cQuery +=" AND DA_DOC>= '"+MV_PAR08+"'" 
  cQuery +=" AND DA_DOC<= '"+MV_PAR09+"'" 
  

   cQuery +=" AND SDA.D_E_L_E_T_ = ' '"
   cQuery +=" AND SB1.D_E_L_E_T_ = ' '"
   cQuery +=" ORDER BY DA_DATA DESC,DA_DOC,DA_LOCAL,DA_PRODUTO"  
 
  TCQUERY cQuery NEW ALIAS "TRB_SDA"

	If	! USED()
     MsgBox(cQuery+Chr(10)+Chr(13)+'. Erro na geração da Query','Erro!!!','STOP')
	EndIf                                         


aStru := DbStruct()
For nI := 1 To Len( aStru )
   If aStru[nI,2] != "C"
	   TCSetField( "TRB_SDA", aStru[nI,1], aStru[nI,2], aStru[nI,3], aStru[nI,4] )
   EndIf
Next  

TCSetField("TRB_SDA","DA_DATA" ,"D",8, 0) 

 ProcRegua(0)
 
 cDocAtu:=TRB_SDA->DA_DOC

 While 	TRB_SDA->( ! Eof() ) 

		      xVerPag() 	    		    
		    
		       //Unidade de medida do produto
   		 	  cUM :=TRB_SDA->(Posicione("SB1",1,xFilial("SB1")+TRB_SDA->DA_PRODUTO,"B1_UM"))
			
	   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	     	//³Ordem das sugestões para o Endereçamento   ³                                                
	     	//³ 
	     	//³ 1 ENDEREÇO FIXO DO PRODUTO
	     	//³ 2 ENDEREÇO ESTRUTURA PICKING
	     	//³ 3 ENDEREÇO ESTRUTURA PALLET     		     	
	    	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

			
			
	  // Verifica se o produto possui um Endereco FIXO para sugerir o Endereçamento do produto 
	  MsAguarde({|| aEndereFixo:=fEndFixo(TRB_SDA->DA_PRODUTO,TRB_SDA->DA_LOCAL)},OemToAnsi("Aguarde..."),OemToAnsi("Verificando se há Picking Fixo..."))
             
      // Verifica se o produto possui um Picking FIXO
      If Len(aEndereFixo)>0
         For i=1 to Len(aEndereFixo)       
			  oPrint:Say(nLinha,0030,OemToAnsi(Alltrim(TRB_SDA->DA_PRODUTO)),oFont10)   
			  oPrint:Say(nLinha,0300,OemToAnsi(Substr(TRB_SDA->B1_DESC,1,25)),oFont10)
			    		
			  oPrint:Say(nLinha,0810,OemToAnsi(TRB_SDA->DA_LOCAL),oFont10)  			 			  
			  
			  If MV_PAR10==1
		       //oPrint:Say(0400,690+95,OemToAnsi('SALDO'),oFont09)             	
		       oPrint:Say(nLinha,840,OemToAnsi(Transform (TRB_SDA->DA_SALDO, "@E 9999999")),oFont10)  			 			    
		      Endif
			  
			  oPrint:Say(nLinha,977,OemToAnsi(TRB_SDA->DA_DOC),oFont10)  //0832+65-80
			  
			  oPrint:Say(nLinha,1187   ,OemToAnsi(DTOC(TRB_SDA->DA_DATA)),oFont10)						
					
              
 		     // oPrint:Say(nLinha,0845,OemToAnsi(TRB_SDA->DA_LOCAL),oFont10)  			 
 		      oPrint:Say(nLinha,1037+285,OemToAnsi(aEndereFixo[i,POS_LEGENDA]),oFont10)
 		      oPrint:Say(nLinha,1362,OemToAnsi(aEndereFixo[i,POS_ENDERECO]),oFont12)
			 			
			//If aEndereFixo[i,POS_PERCENT_OCUP] > 0              
			  oPrint:Say(nLinha,1556,OemToAnsi(Transform(aEndereFixo[i,POS_PERCENT_OCUP], "@E 9999999.99")),oFont12) 			 
			  oPrint:Say(nLinha,1781,OemToAnsi(Alltrim(Transform(aEndereFixo[i,POS_SALDO_PROD], "@E 999999")+ ' '+Capital(cUM))),oFont10) 				 			
			//Endif
			
			  oPrint:Say(nLinha,1640+316 ,OemToAnsi('----------------------'),oFont10) 
			  oPrint:Say(nLinha,1960+316 ,OemToAnsi('----------'),oFont10)
			  			  			  
			  oPrint:Say(nLinha,2135 +316,OemToAnsi('----------------------'),oFont10) 			  
			  oPrint:Say(nLinha,2460 +316,OemToAnsi('----------'),oFont10)     			  
			  
			  oPrint:Say(nLinha,2615 +316, OemToAnsi('----------------------'),oFont10)
			  oPrint:Say(nLinha,2945 +316,OemToAnsi('----------'),oFont10) 

			
		   nLinha+=100		
		 Next i 
	  Endif
	 
	 
	 // Verifica se o produto já possui algum Endereço com este produto  para sugerir no Endereçamento 
	 MsAguarde({|| aEnderecos:=fRetEnd(TRB_SDA->DA_PRODUTO,TRB_SDA->DA_LOCAL)},OemToAnsi("Aguarde..."),OemToAnsi("Verificando se existe saldo em algum endereço ..."))	  

	 		
	If Len(aEnderecos)>0	  
		             
       For i=1 to Len(aEnderecos)
            //Verifica a página 
             xVerPag() 
                       
           //Verifica se o Endereço sugerido com saldo distribuido não é o mesmo sugerido como Picking Fixo
       	     //nPos := aScan(aPickings,{|x| Substr(x[1],3,7)=Alltrim(aEnderecos[i,POS_ENDERECO])})
       	     nPos := aScan(aPickings,{|x| x[1]+x[2]=Alltrim(aEnderecos[i,POS_PICK_FIXO]+aEnderecos[i,POS_PROD_FIXO])})
       	 
	          //Somente imprime o endereço com saldo sugerido se ele não estiver sido sugerido como Picking Fixo
	      If nPos=0 
	          oPrint:Say(nLinha,0030,OemToAnsi(Alltrim(TRB_SDA->DA_PRODUTO)),oFont10)   
			  oPrint:Say(nLinha,0300,OemToAnsi(Substr(TRB_SDA->B1_DESC,1,25)),oFont10)  		
			  oPrint:Say(nLinha,0810,OemToAnsi(TRB_SDA->DA_LOCAL),oFont10)  
			  
			  If MV_PAR10==1
		       //oPrint:Say(0400,690+95,OemToAnsi('SALDO'),oFont09)  
		       oPrint:Say(nLinha,840,OemToAnsi(Transform (TRB_SDA->DA_SALDO, "@E 9999999")),oFont10) 			 			    
		      Endif
			  
			  oPrint:Say(nLinha,977,OemToAnsi(TRB_SDA->DA_DOC),oFont10) 	//0832+65-40	
			  
			  
			  oPrint:Say(nLinha,1187,OemToAnsi(DTOC(TRB_SDA->DA_DATA)),oFont10)			

			  //Endereços com ocupação do produto	
			 // oPrint:Say(nLinha,1036+20+100,OemToAnsi(aEnderecos[i,POS_ENDERECO]),oFont12)
			 oPrint:Say(nLinha,1362,OemToAnsi(aEnderecos[i,POS_ENDERECO]),oFont12)
			  
			  
			 
			 // Percentual de Ocupação dos endereços			
		    // If aEnderecos[i,POS_PERCENT_OCUP] > 0
		      oPrint:Say(nLinha,1556,OemToAnsi(Transform(aEnderecos[i,POS_PERCENT_OCUP], "@E 9999999.99")),oFont12)
		      oPrint:Say(nLinha,1781,OemToAnsi(Alltrim(Transform(aEnderecos[i,POS_SALDO_PROD], "@E 999999")+ ' '+Capital(cUM))),oFont10) 
		     //Endif
			
			  oPrint:Say(nLinha,1640 +316,OemToAnsi('----------------------'),oFont10) 
			  oPrint:Say(nLinha,1960 +316,OemToAnsi('----------'),oFont10)			  
			  
			  oPrint:Say(nLinha,2135 +316,OemToAnsi('----------------------'),oFont10)
			  oPrint:Say(nLinha,2460 +316,OemToAnsi('----------'),oFont10) 
			  
			  oPrint:Say(nLinha,2615+316,OemToAnsi('----------------------'),oFont10)
			  oPrint:Say(nLinha,2945+316,OemToAnsi('----------'),oFont10) 
											
		      nLinha+=100
		  Endif		  
		  
	   Next i  	   
   	Else
   	  //Não existe Picking Fixo nem  saldo deste produto endereçado , imprime os dados para o primeiro endereçamento
   	 If Len(aEndereFixo)=0
   	         
   	          oPrint:Say(nLinha,0030,OemToAnsi(Alltrim(TRB_SDA->DA_PRODUTO)),oFont10)   
			  oPrint:Say(nLinha,0300,OemToAnsi(Substr(TRB_SDA->B1_DESC,1,25)),oFont10)  		
			  oPrint:Say(nLinha,0810,OemToAnsi(TRB_SDA->DA_LOCAL),oFont10)  			 
			  
			  If MV_PAR10==1
		       //oPrint:Say(0400,690+95,OemToAnsi('SALDO'),oFont09)  
		       oPrint:Say(nLinha,840,OemToAnsi(Transform (TRB_SDA->DA_SALDO, "@E 9999999")),oFont10) 			 			    
		      Endif
			  
			  oPrint:Say(nLinha,977,OemToAnsi(TRB_SDA->DA_DOC),oFont10)  
			  
			  oPrint:Say(nLinha,1187   ,OemToAnsi(DTOC(TRB_SDA->DA_DATA)),oFont10)						
			  
			  oPrint:Say(nLinha,1640+316 ,OemToAnsi('----------------------'),oFont10) 
			  oPrint:Say(nLinha,1960+316 ,OemToAnsi('----------'),oFont10)
			  			  			  
			  oPrint:Say(nLinha,2135 +316,OemToAnsi('----------------------'),oFont10) 			  
			  oPrint:Say(nLinha,2460 +316,OemToAnsi('----------'),oFont10)     			  
			  
			  oPrint:Say(nLinha,2615+316, OemToAnsi('----------------------'),oFont10)
			  oPrint:Say(nLinha,2945+316,OemToAnsi('----------'),oFont10) 
			  nLinha+=100
	 Endif		  
 
	Endif	

   IncProc() 
  TRB_SDA->(DbSkip())	
  
  //Dá um espaço na impressão dos documentos
  If cDocAtu <> TRB_SDA->DA_DOC
   nLinha+=60
   cDocAtu := TRB_SDA->DA_DOC
  Endif
  
 End

		xVerPag()
		TRB_SDA->(DbCloseArea())
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime em Video, e finaliza a impressao. !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		oPrint:Preview()

Return


Static Function xCabec()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime o cabecalho da empresa. !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 	oPrint:SayBitmap(050,070,cFileLogo,320,70)
		oPrint:Say(050,400,AllTrim(Upper(SM0->M0_NOMECOM)),oFont16)
		oPrint:Say(135,400,AllTrim(SM0->M0_ENDCOB),oFont11)
		oPrint:Say(180,400,Capital(AllTrim(SM0->M0_CIDCOB))+'/'+AllTrim(SM0->M0_ESTCOB)+ '  -  ' + AllTrim(TransForm(SM0->M0_CEPCOB,'@R 99.999-999')) + '  -  ' + AllTrim(SM0->M0_TEL),oFont11)
		oPrint:Say(225,400,AllTrim('www.imdepa.com.br'),oFont11)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Titulo do Relatorio³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        oPrint:Say(0300,0030,OemToAnsi('Saldos a Distribuir'),oFont20)     
     
        oPrint:Say(0350,0030,OemToAnsi( Replicate( '_', 253 )),oFont09 ) 
        oPrint:Say(0490,0030,OemToAnsi( Replicate( '_', 253 )),oFont09 )         
		
		oPrint:Say(0400,0050,OemToAnsi('PRODUTO'),	oFont09)   
		oPrint:Say(0400,0300,OemToAnsi('DESCRICAO'),oFont09)      
		
		oPrint:Say(0400,770,OemToAnsi('AMZ'),oFont09)       
		
		If MV_PAR10==1
		 oPrint:Say(0400,690+170,OemToAnsi('SALDO'),oFont09)       
   	     // oPrint:Say(0400+60,690+85,OemToAnsi('ENDERECAR'),oFont09)       
   	    Endif
		
		
		
		oPrint:Say(0400,857+130,OemToAnsi('DOCTO'),oFont09)
		
		oPrint:Say(0400,1037+161,OemToAnsi('DATA'),oFont09) 
	
		oPrint:Say(0400,1082+286,OemToAnsi('ENDEREÇO'),oFont09)    
		oPrint:Say(0460,1082+286,OemToAnsi('SUGERIDO'),oFont09)    
		
		oPrint:Say(0400,1606,OemToAnsi('CAPACID.'),oFont09)    
		oPrint:Say(0460,1606,OemToAnsi('NORMA'),oFont09)
				
		oPrint:Say(0460,1630+322,OemToAnsi('ENDERECO'),oFont09)
		oPrint:Say(0460,2000+280,OemToAnsi('QTD'),oFont09)
		
		oPrint:Say(0460,2140+322,OemToAnsi('ENDERECO'),oFont09)  
		oPrint:Say(0460,2480+322,OemToAnsi('QTD'),oFont09)
		
		oPrint:Say(0460,2660+270,OemToAnsi('ENDERECO'),oFont09)  
		oPrint:Say(0460,2965+322,OemToAnsi('QTD'),oFont09)
      
      nLinha:=0590
	
Return

Static Function xVerPag()

 If	( nLinha >= 2200 ) 
       nLinha := 800
    
   
	   oPrint:EndPage()
	
	 If TRB_SDA->( !Eof() )
		nPagina++		                                                    
 
        oPrint:Say(2280,0030,OemToAnsi( Replicate( '_', 253 )),oFont09 )    
    	oPrint:Say(2320,0030,Oemtoansi('Página  '+Alltrim(Str(nPagina))),oFont10) 
   		oPrint:Say(2320,0970,Oemtoansi('|'),oFont10)
    	oPrint:Say(2320,1000,Oemtoansi('o'),oFont12)
    	oPrint:Say(2320,1035,Oemtoansi('ENDEREÇO FIXO |  '),oFont10) 		
    	
    	oPrint:Say(2320,1340,Oemtoansi('o*'),oFont12)
    	oPrint:Say(2320,1405,Oemtoansi('ENDEREÇO FIXO C/ SALDO ACIMA DA NORMA |'),oFont10)
    	oPrint:Say(2320,2188,Oemtoansi('*'),oFont12)
   		oPrint:Say(2320,2250,Oemtoansi('ENDEREÇO C/ SALDO ACIMA DA NORMA |'),oFont10) 	
		
		oPrint:StartPage()
        xCabec()
     Endif  
      
 EndIf

Return

/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: fRetEnd()     || Autor: Edivaldo Gonçalves    || Data: 31/05/12 ||
||-------------------------------------------------------------------------||
|| Descrição: Verifica se o produto que esta sendo Endereçado ja existe em ||
|| algum endereço no Armazem, se existir , retorna o Endereço ,Percentual  ||
|| de ocupação e saldo                                                     ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fRetEnd(cProduto,cLocal)
Local cTpEstrDC8     :=' '
Local cEndEst        :=' ' 
Local cSql           :=' '
Local aRet           :={} 
Local aCapa2Norma    :={} //Capacidade da Norma do Produto e Saldo no Endereco no 2º Armazem
Local nSaldoSBF      :=0
Local nCapacidNorma  :=0
Local nQuantoCabe    :=0
Local cLegenda       :=Space(3)
Local cEndEstAux     :=' '
   

  //Consulta os produtos no Armazém para sugerir no Enderecamento 
  cSql :=" SELECT BF_FILIAL,BF_PRODUTO,SUM(BF_QUANT) AS SALDO_BF,BF_LOCALIZ, BF_ESTFIS,SUM((DC2_LASTRO*DC2_CAMADA)) AS CAPACIDADE"
  cSql +=" FROM "+RetSqlName("SBF")+" SBF, "
  cSql += RetSqlName("SBE")+" SBE, "
  cSql += RetSqlName("DC8")+" DC8, "
  cSql += RetSqlName("DC3")+" DC3, "  
  cSql += RetSqlName("DC2")+" DC2  "   
  
  cSql +=" WHERE BF_FILIAL='"+xFilial("SBF")+"'"
  cSql +=" AND  DC3_FILIAL=BF_FILIAL"
  cSql +=" AND  DC2_FILIAL=DC3_FILIAL"
  cSql +=" AND  DC2_CODNOR=DC3_CODNOR"
      
  cSql +=" AND BF_PRODUTO ='"+cProduto+"'"
  cSql +=" AND DC3_CODPRO=BF_PRODUTO"
 // cSql +=" AND BF_LOCAL   ='"+cLocal+"'"
  cSql +=" AND BF_LOCAL NOT IN ('10','20')"
  cSql +=" AND DC3_LOCAL =BF_LOCAL  "
  cSql +=" AND BE_FILIAL =BF_FILIAL "
  cSql +=" AND BE_LOCALIZ=BF_LOCALIZ"

// Desconsidera Endereço Bloqueado
  cSql +=" AND BE_STATUS <>'3'" 
  
  cSql +=" AND DC8_CODEST=BF_ESTFIS" 
  cSql +=" AND BE_ESTFIS=BF_ESTFIS " 
  cSql +=" AND DC3_TPESTR=BF_ESTFIS"
  

  // Desconsidera o Endereço tipo DOCA
  cSql+=" AND DC8_FILIAL = '" + xFilial("DC8") + "' "  
  cSql+=" AND DC8_TPESTR <> '5'"  
    
  cSql+=" AND SBF.D_E_L_E_T_=' '"
  cSql+=" AND SBE.D_E_L_E_T_=' '"
  cSql+=" AND DC8.D_E_L_E_T_=' '"
  cSql+=" AND DC3.D_E_L_E_T_=' '"
  cSql+=" AND DC2.D_E_L_E_T_=' '"  
  
  cSql+=" GROUP BY BF_FILIAL,BF_PRODUTO,BF_LOCALIZ,BF_ESTFIS,DC2_LASTRO,DC2_CAMADA"
  cSql+=" ORDER BY bf_LOCALIZ"  
  
  Iif( Select("TRB") <> 0, TRB->( dbCloseArea() ), ) // Verifico se a area não está em uso
  
  TCQUERY cSql NEW ALIAS "TRB"
                
If Alias() == "TRB"
	lOk := .T.
	aStru := DbStruct()
	For nI := 1 To Len( aStru )
	   If aStru[nI,2] != "C"
		   TCSetField( "TRB", aStru[nI,1], aStru[nI,2], aStru[nI,3], aStru[nI,4] )
	   EndIf
	Next  
EndIf	
  
dbSelectArea('TRB')

While TRB->( !Eof() )
  cEndEst        := TRB->BF_LOCALIZ
     
  //³ Calcula a quantidade da Norma no Armazem 1 ³
  nQtdNorma      := TRB->CAPACIDADE //DLQtdNorma(TRB->BF_PRODUTO,TRB->BF_LOCAL,TRB->BF_ESTFIS)

  //³ Calcula a quantidade no Endereco ³
  nSaldoSBF      := TRB->SALDO_BF//SaldoSBF(TRB->BF_LOCAL,TRB->BF_LOCALIZ,TRB->BF_PRODUTO) 
  
   //³ Calcula o percentual de ocupação no Endereco ³
  nQuantoCabe:= nQtdNorma //Round((nSaldoSBF/ nQtdNorma)*100 , 2 ) //Obtenho o Percentual de Ocupação do Endereço
 
  //³ Se o saldo no endereço for superior a norma , sinaliza o endereço para análise da Logística ³ 
  If TRB->SALDO_BF > nQtdNorma
    cLegenda:="*"+Space(2)
  Endif    
 
  cEndEst :=Alltrim(TRB->BF_LOCALIZ) 
 
  Aadd(aRet,{cLegenda,cEndEst,nQuantoCabe,nSaldoSBF})			              

  TRB->(DbSkip())

End
		
Return(aRet)

/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: Qtd_Norma()   || Autor: Edivaldo Gonçalves    || Data: 31/05/12 ||
||-------------------------------------------------------------------------||
|| Descrição: Retorna a capacidade da Norma para um determinado produto    ||
||            na sua respectiva Estrutura Fisica                           ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Qtd_Norma(cProduto,cLocal,cEstFis)
 nQtdNorma  :=0
 nQtdNorma  := SBE->(DLQtdNorma(cProduto,cLocal,cEstFis))
  
Return(nQtdNorma)

Static Function fEndFixo(cProduto,cLocal)
Local cEndEst       :=' ' 
Local aRet          :={} 
Local nQtdNorma     :=0
Local nSaldoSBF     :=0
Local nSaldoEnderec :=0
Local cLegenda      :=Space(3)

      aPickings     :={} //Esvazia o vetor aPickings

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Produto possui um Endereco Fixo                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SBE')
	dbSetOrder(10) //-- BE_FILIAL+BE_CODPRO+BE_LOCAL+BE_LOCALIZ	
	If MsSeek(xFilial('SBE')+cProduto+cLocal, .F.) 
	   cLegenda:='o'+Space(2) //Picking Fixo
	   cEndEst :=Alltrim(SBE->BE_LOCALIZ)
	   	 
	   	    dbSelectArea('SBF')
	        dbSetOrder(1)	//BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
	        	        
	         If SBE->BE_STATUS=='3' //Desconsidera Endereço Bloqueado
	          Return (aRet) 
	         Endif
	         
		   	 
	   	     If dbSeek(xFilial('SBF')+cLocal+SBE->BE_LOCALIZ+cProduto,.F.) 
	            nSaldoEnderec:=SBF->BF_QUANT  	   	     
	   	     Endif 	 	   	  
	       
	        //³ Calcula a quantidade da Norma ³
            nQtdNorma      := DLQtdNorma(cProduto,cLocal,SBE->BE_ESTFIS)
           //³ Calcula a quantidade no Endereco ³
            nSaldoSBF      := SaldoSBF(cLocal,SBE->BE_LOCALIZ,cProduto)
           //³ Calcula o percentual de ocupação no Endereco ³
            nQuantoCabe:= nQtdNorma  //Round((nSaldoSBF/ nQtdNorma)*100 , 2 ) 
	     
	      //Se o Saldo Enderecado for maior que a capacidade da Norma , sinaliza o Endereco para analise da Logistica 
	     If nSaldoSBF  > nQtdNorma
	       cLegenda:='o*'+Space(1)
	       cEndEst :=Alltrim(SBE->BE_LOCALIZ)
	     Endif 
	   
	   aAdd(aPickings,{cEndEst,cProduto})  
	   aAdd(aRet,{cLegenda,cEndEst,nQuantoCabe,nSaldoSBF})	   	   
	 	
	Endif

Return(aRet)