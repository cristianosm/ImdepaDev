#Include "DbTree.ch"
#Include "Colors.ch"
#Include "Ap5Mail.ch"
#Include "TopConn.ch"
#Include "Totvs.ch"
#Include "DbInfo.ch"
//#Include "DbfCdxAx.ch"
#Include "Fileio.ch"
#Define SEG_EM_HORA 3600

#Define _ENTER chr(13) + Chr(10)

//fdhfdhgfdeeff
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFTesEspe  บAutor  ณCristiano MAchado   บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChamado: AAZSHW  Data: 08/07/2010  Solicit.: Adriana Fiscal บฑฑ                                                                                       *
ฑฑบ          ณDesc: Regras Especificas para TES                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8 Imdepa Rolamentos                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

**********************************************************************
User Function FTesEspe(lRetSubT,cFilImd,cTpCliente,cDestino,cClassif,cSegmento,cIndustrial,lAgrico)
**********************************************************************
	Local cTes     := ""
	//Local lInterna := (SM0->M0_ESTENT == U_CCToP("SA1->A1_EST") )
	Local lInterna := (SM0->M0_ESTENT == U_ConvA1toUS("SA1->A1_EST") )


//| Parametros de Entrada:
//| ----------------------
//| lRetSubT 	= Para identificar se eh ou nao Substituicao Tributaria
//| cFilImd 	= Filial que sta sendo utilizada
//| cTpCliente 	= Tipo do Cliente
//| cDestino 	= Estado destino da Venda
//| cClassif  	= Classificacao do Produto
//| cSegmento 	= Segmento do Cliente
//| cIndustrial	= Se o Produto Eh Indusrial
//| lAgrico   	= Se o Produto Eh Agricola




	If FunName() = "TMKA271" //| Somente eh Utilizado no CallCenter.

	// Tratamento Estoque 02 - Projeto: Fiscal
		cLocal := gdFieldGet("UB_LOCAL",n)


	//| Regras Empresa ---------------------------------------------------------------
		If U_FEhSufra() == "ZFM" .AND. SB1->B1_GRUPO <>'0008' //| Regra 001
			cTes := U_FBuscaTes("00R001") //| TES - 504

		ElseIf U_FEhSufra() == "AMO" .AND. SB1->B1_GRUPO <>'0008' //| Regra 002
			cTes := U_FBuscaTes("00R002") //| TES - 505

		Else //| Regras Filiais ----------------------------------------------------------

		//| Filial Cuiaba ------------------------------------------------------------
			If cFilImd == "02"

				If U_FEhSufra() == "ALC" .AND. SB1->B1_GRUPO <>'0008'//| Regra 001
					cTes := U_FBuscaTes(cFilImd+"R001") //| TES - 518

				EndIf

				If ( Empty( U_ConvA1toUS("SA1->A1_INSCR")) .OR. Alltrim(U_ConvA1toUS("SA1->A1_INSCR"))=="ISENTO")
						cTes := U_FBuscaTes(cFilImd+"R002")  //| TES - 516
                ElseIf ( !lInterna .AND. cSegmento $ ('1') )
                        cTes := U_FBuscaTes(cFilImd+"R003")  //| TES - 514
				Endif




			EndIf

		//| Filial Goias -------------------------------------------------------------
			If cFilImd == "04"

				If U_FEhSufra() == "ALC" .AND. SB1->B1_GRUPO <>'0008' //| Regra 003
					cTes := U_FBuscaTes(cFilImd+"R003") //| TES - 518


				Elseif U_ConvA1toUS("SA1->A1_CLITARE") == 'S' .OR. (!lRetSubT .AND. cDestino == "GO")  // Chamado: AAZUIM
					cTes := U_FBuscaTes(cFilImd+"R004") //| TES - 540

		 	//ElseIf !lRetSubT .AND. 	cDestino == "GO" //| Se nao for ST.
			  //   	cTes := U_FBuscaTes(cFilImd+"R004") //| TES - 540
				Elseif U_ConvA1toUS("SA1->A1_SIMPNAC") == '1' .AND. U_ConvA1toUS("SA1->A1_EST")='GO' .AND. lRetSubT
					cTes := U_FBuscaTes(cFilImd+"R005") //| TES - 723


			    ElseIf (lInterna .AND. SB1->B1_INDUSTR=='S' .AND. cSegmento $ ('1/3 '))
			    	cTes := U_FBuscaTes(cFilImd+"R004") //| TES - 540

				/*
				ElseIf cTpCliente == "F" .And. cSegmento == "2"	  //| Regra 001
				cTes := U_FBuscaTes(cFilImd+"R001") //| TES - 502

				ElseIf 	cDestino == "GO" //.AND. SA1->A1_GRPSEG $ "AU1/AG1/IN1" //| Regra 002
				cTes := U_FBuscaTes(cFilImd+"R002") //| TES - 540
				*/

				Endif

				If ( Empty( U_ConvA1toUS("SA1->A1_INSCR")) .OR. Alltrim(U_ConvA1toUS("SA1->A1_INSCR"))=="ISENTO")
						cTes := U_FBuscaTes(cFilImd+"R006")  //| TES - 516

			     ElseIf ( !lInterna .AND. cSegmento $ ('1') )
                        cTes := U_FBuscaTes(cFilImd+"R007")  //| TES - 529
				Endif




			EndIf

		//| Filial Cd Porto Alegre ---------------------------------------------------
			If cFilImd == "05"

		// Tratamento Estoque 02 - Projeto: Fiscal
				cLocal := gdFieldGet("UB_LOCAL",n)

				If Empty(cLocal)
					cLocal := SB1->B1_LOCPAD
				EndIF



				If U_FEhSufra() == "ALC"  .AND. SB1->B1_GRUPO <>'0008'//| Regra 001
					cTes := U_FBuscaTes(cFilImd+"R001") //| TES - 514
				EndIf

			//Tratamento para o Decreto RS - Desconto de 7.7 no Pre็o de Tabela atrelado a TES 721
			//If cSegmento == "3" .AND. SA1->A1_EST='RS' .AND. lRetSubT .AND. Alltrim(SB1->B1_ORIGER) =="F/NCZADO" .OR. cSegmento == "3" .AND. SA1->A1_EST =='RS' .AND. lRetSubT .AND.  Alltrim(SB1->B1_ORIGER) == "IMPORTADO"
				If (cSegmento == "3" .AND. U_ConvA1toUS("SA1->A1_EST")=='RS' .AND. lRetSubT .AND. cSegmento == "3" .AND. cLocal == "02" .AND. !SB1->B1_GRUPO $'0011/0014/0015')
					cTes := U_FBuscaTes(cFilImd+"R002")  //| TES - 721 (Decreto RS)
				Endif

				If (cSegmento $ ('1/3 ')  .AND. !lInterna .AND. U_ConvA1toUS("SA1->A1_EST") $ ('SP/PR') .AND. SB1->B1_INDUSTR=='S')
					cTes := U_FBuscaTes(cFilImd+"R003")  //| TES - 501
				Endif

		        //Desconiderado esta regra , pois ela ja esta no trecho acima Adriana/Fiscal
               /*
			    //Tratamento p Estoque 02
				If ((cSegmento == "3" .AND. SA1->A1_EST='RS' .AND. Alltrim(SB1->B1_ORIGER) =="F/NCZADO" .AND. !SB1->B1_GRUPO $'0011/0014/0015' ) .OR. (cSegmento == "3" .AND. SA1->A1_EST =='RS' .AND. Alltrim(SB1->B1_ORIGER) == "IMPORTADO") .AND. !SB1->B1_GRUPO $'0011/0014/0015')
					cTes := U_FBuscaTes(cFilImd+"R002")  //| TES - 721
				Endif
              */

				If cLocal == "02" .AND. Empty(U_FEhSufra()) // Item esta utilizando estoque 02
					If (cSegmento $ ('1/3 ')  .AND. !lInterna .AND. U_ConvA1toUS("SA1->A1_EST") $ ('SP/PR') .AND. SB1->B1_INDUSTR=='S')
						cTes := U_FBuscaTes(cFilImd+"R003")  //| TES - 501
					Endif
				Endif


	             If ( cSegmento $ ('3 ') .AND. SB1->B1_INDUSTR=='S' .AND. ( ('8482') $  ALLTRIM(SB1->B1_POSIPI) .OR. ('40103') $  ALLTRIM(SB1->B1_POSIPI)) )

				  cTes := U_FBuscaTes(cFilImd+"R003") //| TES - 501
				 Endif


				If ( Empty( U_ConvA1toUS("SA1->A1_INSCR")) .OR. Alltrim(U_ConvA1toUS("SA1->A1_INSCR"))=="ISENTO")
						cTes := U_FBuscaTes(cFilImd+"R004")  //| TES - 503
				Endif




			EndIf

		**********************************************************************

		//| Filial Sao Jose ---------------------------------------------------
			If cFilImd == "06"


				If U_FEhSufra() == "ALC"  .AND. SB1->B1_GRUPO <>'0008'//| Regra 001
					cTes := U_FBuscaTes(cFilImd+"R003") //| TES - 514
				EndIf


				If (!lInterna .AND. U_ConvA1toUS("SA1->A1_EST") $ ('MT/MG/RS') .AND. SB1->B1_INDUSTR=='S' .AND. cSegmento=='3')
					cTes := U_FBuscaTes(cFilImd+"R001")  //| TES - 750
				Endif


				If (cSegmento $ ('1/3 ')  .AND. !lInterna .AND. U_ConvA1toUS("SA1->A1_EST") $ ('SP/PR') .AND. SB1->B1_INDUSTR=='S')
					cTes := U_FBuscaTes(cFilImd+"R002")  //| TES - 501
				Endif


				If ( Empty( U_ConvA1toUS("SA1->A1_INSCR")) .OR. Alltrim(U_ConvA1toUS("SA1->A1_INSCR"))=="ISENTO")
						cTes := U_FBuscaTes(cFilImd+"R004")  //| TES - 503
				Endif


			EndIf

		*************



		//| Filial Sao Paulo ---------------------------------------------------------
			If cFilImd == "09"

			/// Tratamento Estoque 02 - Projeto: Fiscal -
				cLocal := gdFieldGet("UB_LOCAL",n)


				If !Empty(U_FEhSufra()) .And. lRetSubT .AND. SB1->B1_GRUPO <>'0008' //| Regra 001  //If !Empty(U_FEhSufra()) .And. lRetSubT .AND. cLocal <> '02' .OR. SB1->B1_GRUPO <>'0008' //| Regra 001
					cTes := U_FBuscaTes(cFilImd+"R001") //| TES - 753

				ElseIf U_FEhSufra() == "ALC"  .AND. SB1->B1_GRUPO <>'0008'  //| Regra 002
					cTes := U_FBuscaTes(cFilImd+"R002") //| TES - 753

				Endif



				If Empty(cLocal)
					cLocal := SB1->B1_LOCPAD
				EndIF

			 //Alert("Local :"+cLocal)
				If cLocal == "02" .AND. Empty(U_FEhSufra()) // Item esta utilizando estoque 02
					If cSegmento == '2' //.AND. SA1->A1_EST='SP'
						cTes := U_FBuscaTes(cFilImd+"R006") //| TES - 502
					Else
						If Empty(U_FEhSufra()) .AND. cLocal == "02" .AND. cSegmento $ ('1/3 ') .AND. U_ConvA1toUS("SA1->A1_EST") $ ('SP/PR')  ///lInterna .AND. SA1->A1_EST <> 'PR'
							cTes := U_FBuscaTes(cFilImd+"R005") //| TES - 501
						Endif
					Endif
				Endif



		     	If ( Empty( U_ConvA1toUS("SA1->A1_INSCR")) .OR. Alltrim(U_ConvA1toUS("SA1->A1_INSCR"))=="ISENTO")
						cTes := U_FBuscaTes(cFilImd+"R004")  //| TES - 503
				Endif


		/*

				If lRetSubT .AND. cLocal <> "02" // Produto eh ST

					If cSegmento == '3' // Cliente
						lAuto	:= U_FCnaeAuto()//Nova Regra Substituicao Tributaria Para Segmento 3 Definido em 01/08/08
						If SA1->A1_GRPSEG $ "AU3/AG3"
							cTes := U_FBuscaTes(cFilImd+"R003") //| TES - 722

						ElseIf lAuto .and. cProd == "N" .AND. SA1->A1_GRPSEG == "IN3"
							cTes := U_FBuscaTes(cFilImd+"R004") //| TES - 722

						ElseIf cProd == "S"
							cTes := U_FBuscaTes(cFilImd+"R005") //| TES - 501

						EndIf
					EndIf
					Else
				   If cSegmento == '2' .AND. SA1->A1_EST='SP'
				    cTes := U_FBuscaTes(cFilImd+"R006") //| TES - 502
				  Endif

				Endif


			//EndIf
			*/


			EndIf


		//| Filial Curitiba ----------------------------------------------------------
			If cFilImd == "13" //| Curitiba

            //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
        	//ณRegra das concessionแriasณ		         		            ณ
	        //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		     //Rgra das concessionarias desabilitadas conforme solicita็ใo Adriana/Ari

		     // Armaz้m C/ST
		     If (cLocal == "01" .AND. cIndustrial=='N' .AND. lAgrico )
				cTes := U_FBuscaTes(cFilImd+"R006")  //| TES - 720
		        //ElseIf (cLocal == "01" .AND. cIndustrial=='S' .AND. lAgrico )
		        //cTes := U_FBuscaTes(cFilImd+"R006")  //| TES - 720
			   //Armaz้m S/ST
			      ElseIf (cLocal == "02" .AND. cIndustrial=='N' .AND. lAgrico )
				cTes := U_FBuscaTes(cFilImd+"R004")  //| TES - 724
		       // ElseIf (cLocal == "02" .AND. cIndustrial=='S' .AND. lAgrico )
		        //cTes := U_FBuscaTes(cFilImd+"R004")  //| TES - 724
			 Endif

			   //ณ Se caiu na regra das concessionแrias nao precisa avaliar as demais regrasณ
			 If !Empty(cTes)
			    Return(cTes)
			 Endif


		   //Tratamento para o Decreto PR
			 //If cSegmento == "3" .AND. SA1->A1_EST='PR' .AND. lRetSubT .AND. Alltrim(SB1->B1_ORIGER) =="F/NCZADO" .OR. cSegmento == "3" .AND. SA1->A1_EST='PR' .AND. lRetSubT .AND.  Alltrim(SB1->B1_ORIGER) =="IMPORTADO"
			 //EDI If (cSegmento == "3" .AND. SA1->A1_EST='PR' .AND. lRetSubT .AND. cSegmento == "3" .AND. cLocal == "02")
			 //If (cSegmento == "3" .AND. SA1->A1_EST='PR' .AND. lRetSubT .AND. cSegmento == "3") //.AND. cLocal == "02")
				If ((cSegmento == "3" .AND. U_ConvA1toUS("SA1->A1_EST")='PR' .AND. lRetSubT .AND. Alltrim(SB1->B1_ORIGER) =="F/NCZADO" .AND. !SB1->B1_GRUPO $'0011/0014/0015/0008' .AND. cLocal <> "02" ) .OR. (cSegmento == "3" .AND. U_ConvA1toUS("SA1->A1_EST")='PR' .AND. lRetSubT .AND.  Alltrim(SB1->B1_ORIGER) =="IMPORTADO" .AND. !SB1->B1_GRUPO $'0011/0014/0015/0008' .AND. cLocal <> "02"  ))
					cTes := U_FBuscaTes(cFilImd+"R004")  //| TES - 723 (Decreto PR)
				Endif


				If (cSegmento == "3" .AND. U_ConvA1toUS("SA1->A1_EST")='PR' .AND. lRetSubT .AND. cSegmento == "3" .AND. cLocal == "02" .AND. !SB1->B1_GRUPO $'0011/0014/0015/0008' )
					cTes := U_FBuscaTes(cFilImd+"R004")  //| TES - 723 (Decreto PR)
				Endif



				If U_FEhSufra() == "ALC" //| Regra 003
					cTes := U_FBuscaTes(cFilImd+"R003") //| TES 515

				ElseIf !lRetSubT //| Se nao for ST.

					If cTpCliente == "F" .And. cSegmento == "2" //| Regra 001
						cTes := U_FBuscaTes(cFilImd+"R001") //| TES 502

					Endif


				Endif

				If (SB1->B1_INDUSTR=='S' .AND. lInterna .AND. cSegmento $ ('1/3 '))
					cTes := U_FBuscaTes(cFilImd+"R002") //| TES - 514
					ElseIf  SB1->B1_INDUSTR=='S' .AND. !lInterna .AND. cSegmento $ ('3 ')
				Endif



				If cLocal == "02" .AND. Empty(U_FEhSufra()) // Item esta utilizando estoque 02


					If (lInterna .AND. cSegmento == '3' .AND. SB1->B1_INDUSTR=='N' .AND. !SB1->B1_GRUPO $'0011/0014/0015/0008')
						cTes := U_FBuscaTes(cFilImd+"R004")  //| TES - 723 (Decreto PR)
					//ElseIf (lInterna .AND. cSegmento $ ('1/2') .AND. SB1->B1_INDUSTR=='S')
					ElseIf (lInterna .AND. cSegmento $ ('1') .AND. SB1->B1_INDUSTR=='S')
						cTes := U_FBuscaTes(cFilImd+"R002") //| TES - 514
					ElseIf (cSegmento $ ('1/3 ') .AND. !lInterna .AND. U_ConvA1toUS("SA1->A1_EST") $ ('SP') .AND. SB1->B1_INDUSTR=='S')
						cTes := U_FBuscaTes(cFilImd+"R005")  //| TES - 501
					Endif

					If (SB1->B1_INDUSTR=='S' .AND. lInterna .AND. cSegmento $ ('1/3 '))
						cTes := U_FBuscaTes(cFilImd+"R002") //| TES - 514
					Endif


				Endif

					If ( Empty( U_ConvA1toUS("SA1->A1_INSCR")) .OR. Alltrim(U_ConvA1toUS("SA1->A1_INSCR"))=="ISENTO")
						cTes := U_FBuscaTes(cFilImd+"R008")  //| TES - 503


			       ElseIf ( !lInterna .AND. U_ConvA1toUS("SA1->A1_GRPSEG")=='IN3')
                        cTes := U_FBuscaTes(cFilImd+"R005")  //| TES - 501

				   Endif


			Endif

		 		//| Filial Contagem ---------------------------------------------------
			If cFilImd == "14"

			//Tratamento para tes
				If  (U_ConvA1toUS("SA1->A1_EST") =='MG' .AND. U_FVerNcm() .AND. !SB1->B1_GRUPO $'0011/0014/0015/0008')  //(SB1->B1_GRTRIB='004' .OR. SB1->B1_GRTRIB='004') //.And. .f. //U_FVerNcm() //lRetSubT
					cTes := U_FBuscaTes(cFilImd+"R001")  //| TES - 720  Projeto Enquadramento de clientes s/ distin็ใo na ST /MG
				Endif


				If ( Empty( U_ConvA1toUS("SA1->A1_INSCR")) .OR. Alltrim(U_ConvA1toUS("SA1->A1_INSCR"))=="ISENTO")
						cTes := U_FBuscaTes(cFilImd+"R002")  //| TES - 503
						  ElseIf ( !lInterna .AND. cSegmento $ ('1') )
                        cTes := U_FBuscaTes(cFilImd+"R003")  //| TES - 501

				Endif


			EndIf

		Endif
	EndIf


	If FunName() = "IMDA070" //| Tes especificas p/ Transfer๊ncias
		If (SB1->B1_INDUSTR=='S' .AND. SA1->A1_LOJA=='09')
			cTes := U_FBuscaTes(SA1->A1_LOJA+"T001")  //| TES - 653  Tes de Transferecia p/ SPA
		ElseIf ((Alltrim(SB1->B1_ORIGER)== "F/NCZADO" .OR. Alltrim(SB1->B1_ORIGER)=="IMPORTADO") .AND. (SA1->A1_LOJA=='13'))
			cTes := U_FBuscaTes(SA1->A1_LOJA+"T001")  //| TES - 653  Tes de Transferecia p/ CTBA
		ElseIf (SA1->A1_EST $ ('SP/PR') .AND. SB1->B1_INDUSTR=='S' )
			cTes := U_FBuscaTes(SA1->A1_LOJA+"T001")  //| TES - 653  Tes de Transferecia p/ SP/PR
		EndIf
	Endif



//If FunName() ="U_IMDTESTR" //| Tes especificas p/ Entradas
//    Msginfo('Rodar Tes especificas p/ Entradas')
//Endif



Return(cTes)
**********************************************************************
User Function FBuscaTes(cRegra) //| Tabela de TES Especificas confomre filial e Regra
**********************************************************************

	cTes := SX5->(Posicione("SX5",1,xFilial("SX5")+"ZN"+cRegra,"X5_DESCRI"))

Return(AllTrim(cTes))
**********************************************************************
User Function FEhSufra() //| Verifica se enquadra na regra suframa e qual delas
**********************************************************************
//| Definicoes:
//| -----------
//| AMO - Amazonia Ocidental
//| ZFM - Zona Franca de Manaus
//| ALC - Area de Livre Comerci'o

	Local cRet := ""
//| Tratamento Zona Franca de Manaus - Tratamento Empresa
	If SB1->B1_ORIGEM == "0" .OR. SB1->B1_ORIGEM == "2" //| Nacional / Mercado Interno

		If !Empty(U_ConvA1toUS("SA1->A1_SUFRAMA"))

			If U_ConvA1toUS("SA1->A1_ESTE") == "AP" //| UF = AMAPA

				Do Case
				Case U_ConvA1toUS("SA1->A1_CODMUN") == "00605" //| Macapa
					cRet := "ALC"

				Case U_ConvA1toUS("SA1->A1_CODMUN") == "00615" //| Santana
					cRet := "ALC"

				OtherWise
					cRet := ""
				EndCase

			ElseIf U_ConvA1toUS("SA1->A1_ESTE") == "AC" //| UF = ACRE

				Do Case
				Case U_ConvA1toUS("SA1->A1_CODMUN") == "00107" //| Cruzeiro do Sul
					cRet := "ALC"

				Case U_ConvA1toUS("SA1->A1_CODMUN") == "00105" //| Brasileira
					cRet := "ALC"

				Case U_ConvA1toUS("SA1->A1_CODMUN") == "99998" //| Epitacolandia
					cRet := "ALC"

				Otherwise
					cRet := "AMO"
				EndCase

			ElseIf U_ConvA1toUS("SA1->A1_ESTE") == "RR" //| UF = RORAIMA

				Do Case
				Case U_ConvA1toUS("SA1->A1_CODMUN") == "00307" //| Bonfim
					cRet := "ALC"

				Case U_ConvA1toUS("SA1->A1_CODMUN") == "99999" //| Pacaraima
					cRet := "ALC"

				OtherWise
					cRet := "AMO"
				EndCase

			ElseIf U_ConvA1toUS("SA1->A1_ESTE") == "RO" //| UF = RONDONIA

				Do Case
				Case U_ConvA1toUS("SA1->A1_CODMUN") == "00001" //| Guajara Mirin
					cRet := "ALC"

				OtherWise
					cRet := "AMO"
				EndCase

			ElseIf U_ConvA1toUS("SA1->A1_ESTE") == "AM" //| UF = AMAZONAS

				Do Case
				Case U_ConvA1toUS("SA1->A1_CODMUN") == "09847" //| Tabatinga
					cRet := "ALC"

				Case U_ConvA1toUS("SA1->A1_CODMUN") == "00255" //| Manaus
					cRet := "ZFM"

				Case U_ConvA1toUS("SA1->A1_CODMUN") == "09843" //| Rio Preto da Eva
					cRet := "ZFM"

				Case U_ConvA1toUS("SA1->A1_CODMUN") == "09841" //| Presidente Figueiredo
					cRet := "ZFM"

				OtherWise
					cRet := "AMO"

				EndCase
			EndIf
		EndIf
	Endif

Return(cRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLIBRARY   บAutor  ณMicrosiga           บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
**********************************************************************
User Function FSubTrib (cpar1,cpar2,cpar3,cpar4,cpar5,cpar6,cpar7,npar8,cpar9)//Retorna a Tes conforme parametros - (cfilImd,cNota,cTipo,cTpCliFor,cDestin,Classif,cSegmento,tpRet,CProd)
**********************************************************************
	Local 	cRetorno
	Local   lAgrico

	Private ltesok 		:= .F.
	Private CtesRt 		:= space(03)
	Private CtesTf 		:= space(03)
	Private cfilImd 		:= cpar1
	Private cNota		:= cpar2
	Private cTipo		:= cpar3
	Private cTpCliFor 	:= cpar4
	Private cDestin 		:= cpar5
	Private Classif 		:= cpar6
	Private cSegmento 	:= cpar7
	Private tpRet 		:= npar8
	Private cVeST		:= Iif(cPar9 == Nil,'',cpar9)// Regra Custo ?
	Private cIndustrial	:= SB1->B1_INDUSTR

	If cfilImd == nil .or. cNota == nil .or. cTipo == nil .or. cTpCliFor == nil .or. cDestin == nil .or. Classif == nil .or.  cSegmento == nil .or. tpRet == nil

		alert("Chamada invalida da Fun็ใo!!! - FSubTrib( Falta Parametro )")
		Conout("Chamada invalida da Fun็ใo!!! - FSubTrib( Falta Parametro )")
		Return("")

	Endif

	cQuery := " "
	cQuery += " SELECT ZA4_CLASSI CLASSI, ZA4_TES TES, ZA4_TESTRF TESTRF, ZA4_REGST REGST "
	cQuery += " FROM " + RetSqlName("ZA4")
	cQuery += " WHERE ZA4_FILIAL  = '" + xFilial("ZA4")	+ "' "
	cQuery += "   AND ZA4_FORIGE  = '" + cfilImd 		+ "' "
	cQuery += "   AND ZA4_NOTA    = '" + cNota 			+ "' "
	cQuery += "   AND(ZA4_TIPO    = '" + cTipo 			+ "' OR ZA4_TIPO   = '*') "
	cQuery += "   AND(ZA4_CLIFOR  = '" + cTpCliFor 		+ "' OR ZA4_CLIFOR = '*') "
	cQuery += "   AND(ZA4_DESTIN  = '" + cDestin 		+ "' OR ZA4_DESTIN = '**') "
	cQuery += "   AND(ZA4_GRPSEG  = '" + cSegmento 		+ "' OR ZA4_GRPSEG = '*') "

	If ( cVeST == 'S' )
		cQuery += "   AND ZA4_REGST  = '" + cVeST 		+ "' "
	EndIf

	cQuery += "  AND D_E_L_E_T_  = ' '
	cQuery += " ORDER BY ZA4_TIPO,ZA4_CLIFOR,ZA4_DESTIN, ZA4_GRPSEG,ZA4_CLASSI DESC "

//MEMOWRIT("C:\SQLSIGA\Funcao_FSubTrib.TXT ", cQuery)

	IF Select( '_ST' ) <> 0
		dbSelectArea('_ST')
		DbCloseArea('_ST')
	Endif

	TCQUERY cQuery NEW ALIAS ('_ST')

	Do While _ST->(!EOF())
		cCaracter := ""

		For I:=1 to len(alltrim(_ST->CLASSI))

			If substr(Classif,i,1) == substr(_ST->CLASSI,i,1) .Or. Substr(_ST->CLASSI,i,1) == '*'
				cCaracter += substr(_ST->CLASSI,i,1)
				ltesok := .T.
				CtesRt := _ST->TES
				CtesTf := _ST->TESTRF
			ElseIf substr(_ST->CLASSI,i,1) == "%" .and. ltesok
				CtesRt := _ST->TES
				CtesTf := _ST->TESTRF
				ltesok := .T.
				exit
			Else
				ltesok := .F.
				exit
			Endif

		Next i

		If ltesok
			CtesRt := _ST->TES
			CtesTf := _ST->TESTRF
			Exit
		else
			_ST->(DbSkip())
		Endif

	EndDo

	_ST->(DBCloseArea())

	If cSegmento == "3" .and. ltesok .and. tpRet != 2 //Regra especifica P/ Cliente Segmento 3
	// Regra de Excessao solicitada pelos clientes. Para se enquadrar na ST. 20/01/08 | Ariorbeto - Fiscal
	//If SA1->A1_ATIVIDA == '47890' .And.  cfilImd $('13/05')
		lTesOk	:= .T.
		If U_ConvA1toUS("SA1->A1_CLITARE") == 'S' //| Cliente Tare ? S=Sim | N= Nao
			lTesOk	:= .F.
		ElseIf U_ConvA1toUS("SA1->A1_EXCECST") == '1' //| Cliente Entra na ST ?
			lTesOk	:= .T.
		ElseIf cfilImd == '05' .and. cDestin == 'RS' //| Chamado: AAZVNW -  Data: 28/03/2013 - Cristiano Machado //.and. (substr(Classif,1,5) = '40103' .or. substr(Classif,1,8) = '59100000' .or. substr(Classif,1,4) = '8482')
			lTesOk	:= .T.
		ElseIf ConAgri() .and. cIndustrial == "S" //Regra para Concessionarias Agricolas conforme proj. logico do chamado AAZQV1 - Agostinho 23/09/2009
			lTesOk	:= .T.
		Else
			lAuto	:= U_FCnaeAuto()//Nova Regra Substituicao Tributaria Para Segmento 3 Definido em 01/08/08
			If !lAuto .and. cIndustrial == "S" .AND. U_ConvA1toUS("SA1->A1_GRPSEG") == "IN3"  .and. !(cfilImd == '14' .and. cDestin == 'MG' )
				lTesOk	:= .F.
			Endif
		Endif
	Endif


	IF PROCNAME(1) == "U_FPARTES" .OR. PROCNAME(1) == "U_TMKVFIM" .OR. PROCNAME(1) == "U_INCPV" //.OR. PROCNAME(1) == "U_IMDTESTR" // == //PROCNAME() <> "U_IMDV240AC"  .AND. PROCNAME() <> "U_IMDV240" //DESC ICMS

	   lAgrico:=ConAgri()
	//|Chamado: AAZSHW  Data: 08/07/2010  Solicitante: Adriana Fiscal  Desc: Regras Especificas para TES
		cRetFunc := U_FTesEspe(lTesOk,cfilImd,cTpCliFor,cDestin,Classif,cSegmento,cIndustrial,lAgrico)

		If !Empty(cRetFunc)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ  FABIANO PEREIRA 12/01/2016                                    			   ณ
			//ณ  QUANDO Eh GERADO UMA TRANSFERENCIA (U_INCPV) DE SP -> PR VIA TMKA271	   |
			//|  (PRJ. CORREIAS) ESTAVA BUSCANDO A TES 501   			 				   ณ
			//ณ  VERIFICO SE Eh UMA TRANSF.DE SP->PR E MANTENHO A TES QUE ESTA 			   ณ
			//ณ  TRAZENDO DA QUERY DA TABELA ZA4 (TES 653)                     			   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			//	tpRet == 1 -> Tes Venda / Compra
			//	tpRet == 2 -> Tes Transferencia
			//	tpRet == 3 -> True / False


			lTransSpToPr :=	ProcName(1) == 'U_INCPV' .And. tpRet == 2 .And. cFilImd == '09' .And. U_ConvA1toUS("SA1->A1_EST") == 'PR'
			lTesOK 		 :=	.T.
			CtesRt 		 :=	IIF(!lTransSpToPr, cRetFunc, CtesRt)
			CtesTf 		 :=	IIF(!lTransSpToPr, cRetFunc, CtesTf) 	//	Tes de Transferencia Especifica

		EndIf
	//| Fim AAZSHW

	ENDIF

	If tpRet == 3 .and. !lTesok
		Return(.F.)
	Elseif !ltesok
		Return(Space(03))
	Endif

	Do Case
	Case tpRet == 1 //Tes Venda / Compra
		If ltesok
			cRetorno := CtesRt
		else
			cRetorno := '   '
		endif
	Case tpRet == 2 //Tes Transferencia
		If ltesok
			cRetorno := CtesTf
		else
			cRetorno := '   '
		endif
	Case tpRet == 3 //True / False
		cRetorno := ltesok
	EndCase


Return(cRetorno)
*********************************************************************
Static Function ConAgri()//Retorna se ้ Concessionแrias Agrํcolas
*********************************************************************

	If FunName() = "TMKA271"
		If lProspect
			If SUS->US_CONAGRI = "1"
				Return(.T.)
			Endif
		Else
			If SA1->A1_CONAGRI = "1"
				Return(.T.)
			Endif
		Endif
	Else
		If SA1->A1_CONAGRI = "1"
			Return(.T.)
		Endif
	Endif

Return(.F.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLIBRARY   บAutor  ณMicrosiga           บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

*****************************************************************************************************
User Function VerGer(ARQ)//Ver se o usuario ้ gerente - valida็ใo para os campos US_CONAGRI e A1_CONAGRI
*****************************************************************************************************
	LOCAL ARQ
	LOCAL nHdlLog
	LOCAL cQuery
	LOCAL aArea := GetArea()
	LOCAL _CAMPO:= ARQ+"_CONAGRI"
	LOCAL _DE   := IF(&("S"+ARQ+"->"+ARQ+"_CONAGRI")= "1","SIM","NAO")
	LOCAL _PARA := IF(&("M->"+ARQ+"_CONAGRI")= "1","SIM","NAO")

	cQuery := " "
	cQuery += " SELECT A3_CODUSR "
	cQuery += " FROM " + RetSqlName("SA3")
	cQuery += " WHERE  D_E_L_E_T_  = ' ' "
	cQuery += " AND A3_CODUSR = '" + __CUSERID	+ "' "
	cQuery += " AND A3_GERENTE = 'S'

	TCQUERY cQuery NEW ALIAS ('VERGER')

	VERGER->(dbSelectArea("VERGER"))

	IF VERGER->(EOF()) .AND. VERGER->(BOF())
		AVISO("Permissใo Negada!","Somente gerentes podem alterar este campo!",{"OK"} )
		VERGER->(dbCloseArea())
		RETURN(.F.)
	ENDIF

//GRAVA LOG
	If File("\conagri.log")
		nHdlLog := fOpen("\conagri.log",2)
		fSeek(nHdlLog,0,2)
	Else
		nHdlLog:=fCreate("\conagri.log",0)
		fWrite(nHdlLog,"DATA     HORA     CAMPO      USUARIO CLIENTE LOJA DE  PARA"+CRLF)
		fWrite(nHdlLog,"----------------------------------------------------------"+CRLF)
	Endif
	fWrite(nHdlLog,dtoc(date())+" "+time()+" "+_CAMPO+" "+__CUSERID+"  "+&("S"+ARQ+"->"+ARQ+"_COD")+"  "+&("S"+ARQ+"->"+ARQ+"_LOJA")+"   "+_DE+" "+_PARA+CRLF)
	fclose(nHdlLog)

	DBCloseArea("VERGER")
	RestArea(aArea)

RETURN(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLIBRARY   บAutor  ณMicrosiga           บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

*********************************************************************
User Function FCnaeAuto()//Retorna Conforme Regra se E Substituicao Tributaria ou Nao
*********************************************************************

	Dbselectarea("SX5")
	Dbseek(xFilial("SX5")+"Z9"+"NIND1",.F.)
	While(SX5->X5_TABELA == "Z9") //Tabela com Cnaes Automotivos (De - Ate) Eles Nao devem ter ST
	/*
	CnaeIni := SUBSTR(SX5->X5_DESCRI,1,5)
	CnaeFim := SUBSTR(SX5->X5_DESCRI,7,5)

	If SA1->A1_ATIVIDA >= CnaeIni .and. SA1->A1_ATIVIDA <= CnaeFim
	Return(.T.)
	Endif
	*/
	CnaeIni := SUBSTR(SX5->X5_DESCRI,1,9)
	CnaeFim := SUBSTR(SX5->X5_DESCRI,11,9)

	//If SA1->A1_ATIVIDA >= CnaeIni .and. SA1->A1_ATIVIDA <= CnaeFim
	If U_ConvA1toUS("SA1->A1_CNAE") >= CnaeIni .and. U_ConvA1toUS("SA1->A1_CNAE") <= CnaeFim
		Return(.T.)
	Endif

	Dbselectarea("SX5")
	Dbskip()
EndDo

Return(.F.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLIBRARY   บAutor  ณMicrosiga           บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

**********************************************************************
User Function FCusTrib(lOk) //ณ Calcula Custo de Substituicao Tributaria
**********************************************************************
	Local nCusto 		:= 0
	Local nCusB2 		:= 0
	Local nAliqICM 		:= 0
	Local nIcmSbDest 	:= 0 // ICMS de Destino (Substtiuicao)
	Local nAcrMargem	:= 0
	Local nAcrIPI		:= 0
	Local nAliqPIS 		:= 0
	Local nAliqCOF 		:= 0


	Local cImdepa  		:= GetMV('MV_IMDEPA')               // Cliente Tranfer๊ncia
	Local nAliqICMSInt  := GETMV('MV_ICMSTRF',,0)/100       //ICMS TRF - ICMS USADO NA DESONERACAO DE CUSTO TRANSFERENCIA

	Local nIcmsDesVen   := GETMV('MV_ICMVEND',,0)           //ICMS de Desonera็ใo da Venda
//Local nIcmsDesVen   := 0

	Local nAliqMVATRF   := 1 + (GETMV("MV_MVATRF",,0) /100) //% MVA padrใo para transferencia entre filiais
//Local lImportado    :=.F.

/*
 If (Alltrim(SB1->B1_ORIGER) == "F/NCZADO" .OR. Alltrim(SB1->B1_ORIGER) == "IMPORTADO")
  lImportado:=.T.
 Endif
 */

// nIcmsDesVen   :=Iif(lImportado, GETMV('MV_ICMVEDI',,0), GETMV('MV_ICMVEND',,0))

	Private nDesonera	:= .F. // Se deve ou nao Desonerar o Calculo do Custo Kardex
	Private cUFOri		:= Posicione("SM0",1,"01"+cfilant,"M0_ESTENT")   //SM0->M0_ESTENT
	Private lEstOner  	:= dDatabase >= GetMV("MV_ESTONER",,dDatabase+1)
	Private lZA4Ok 		:= lOk
	Private cEstATU		:= GETMV("MV_ESTADO") // Estado Atual (Edivaldo,inserido como variavel private para ser usado na funcao FcondOnera()

	nDesonera := FcondOnera() //Condicoes para Calculo de Desoneracao

	If !nDesonera
		Return(SB2->B2_CM1)
	Endif

	nCusB2 		:= 	SB2->B2_CM1                //Parametriz็ใo somente para Venda  - MV_ALIQOST
	nAliqICM 	:= 	GETMV("MV_ALIQOST",,0) /100//| ICM de Origem - Aliquota de Origem (Fornecedor) para Substituicao Tributaria - Desoneracao // nAliqICM := GETMV("MV_ICMPAD") /100
//  nAliqICM 	:= Iif(lImportado, GETMV("MV_ALIOSTI",,0) /100, GETMV("MV_ALIQOST",,0)/100)  //| ICM de Origem - Aliquota de Origem (Fornecedor) para Substituicao Tributaria - Desoneracao // nAliqICM := GETMV("MV_ICMPAD") /100

	if SB1->B1_ORIGEM == "1" .OR. SB1->B1_ORIGEM == "2"   .AND. ! (FunName() $('IMDA070/IMDA090/IMDA640'))      //Alterado por Rodrigo solutio em 05/06/2015 pois conforme informado pela Mแrcia, os produtos importados tem alํquota de 4% de ICMS

		nIcmSbDest := 4/100
	else

		IF SF4->F4_CREDICM <> 'S'

			nIcmSbDest := 0

		else


			If SA1->A1_EST $ GetMV('MV_NORTE') .AND. !(cEstATU$GetMV('MV_NORTE')) 	// ICM de Destino //cEstDest $ GetMV('MV_NORTE')


				nIcmSbDest := 7/100

			Else

				nIcmSbDest := 12/100
			EndIf
		endif

	endif

	nAcrMargem 	:= 1 + (GETMV("MV_MVAOST",,0) /100)// Deixo de buscar a Margem das excecoes fiscais e passo a buscar do parโmetro MV_MVAOST
// nAcrMargem 	:=Iif(lImportado, 1 + (GETMV("MV_MVAOSTI",,0) /100), 1 + (GETMV("MV_MVAOST",,0) /100))


	nAcrIPI 	:= 1 + (SB1->B1_IPI / 100 )        // Acrescimo de IPI
// PIS e COFINS
	nAliqPIS	:= iif(SB1->B1_PPIS > 0, SB1->B1_PPIS, GetMV("MV_TXPIS"))
	nAliqPIS	:= nAliqPIS /100 // 84821010 / 100 = 848210,1

	nAliqCOF 	:= iif(SB1->B1_PCOFINS	>0, SB1->B1_PCOFINS	, GetMV("MV_TXCOFIN"))
	nAliqCOF	:= nAliqCOF/100

// Aplica Reducao no  PIS e COFINS
	nAliqPIS 	:= nAliqPIS - (nAliqPIS * (SB1->B1_REDPIS / 100))
	nAliqCOF 	:= nAliqCOF - (nAliqCOF * (SB1->B1_REDCOF / 100))
	nPISCOF		:= nAliqPIS + nAliqCOF

	If cEstATU == "SP"// Desoneracao venda SP tem regra especifica ... Alicota Interna ICMS
		nFATOR:=U_FCalcIMC(cFilAnt,SUB->UB_LOCAL,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
		nCusto1 	:= nCusB2 / NFATOR  //( 1 + ( 1 / ( 1 - nPISCOF - nAliqICMSInt )) * nAcrIPI * nAcrMargem * nAliqICM)
	ElseIf cEstATU  == "MT" //| Chamado: AAZUG0

		If FunName() == 'TMKA271' //| CallCenter
			nTotItem	:= SUB->UB_VRCACRE + (( SUB->UB_VRCACRE / (SUA->UA_VALMERC + SUA->UA_DESPESA + SUA->UA_ACRESCI) ) * SUA->UA_DESPESA )

		ElseIf  FunName() == 'MATA460A' //| Faturamento
			nTotItem	:= SD2->D2_BASEICM / SD2->D2_QUANT

		Else //| Outros
			nTotItem	:= 0

		EndIF

		nCusto1 	:= nCusB2 - ( nTotItem * nIcmSbDest)
	//| Fim Chamado: AAZUG0
	Else
	//nCusto1 	:= nCusB2 /( 1 + ( 1 / ( 1 - nPISCOF - nIcmSbDest )) * nAcrIPI * nAcrMargem * nAliqICM)

	// Edivaldo Gon็alves Cordeiro | Alterado a variแvel nIcmSbDest pela nova variแvel de Desonera็ใo na Venda (nIcmsDesVen)
		nFATOR:=U_FCalcIMC(cFilAnt,SUB->UB_LOCAL,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
		nCusto1 	:= nCusB2 / NFATOR   //nCusB2 /( 1 + ( 1 / ( 1 - nPISCOF - nIcmsDesVen )) * nAcrIPI * nAcrMargem * nAliqICM)

	Endif//		 	=  C66    /( 1 + ( 1 / ( 1 -    N66   -      G66    )) *   K66   *     I66           *E66      )


	If cEstATU == "MT"	//| Chamado: AAZUG0
		nVlrProd 	:= 100 //| Valor Produto
		nVlrIpi 	:= nVlrProd * (SB1->B1_IPI / 100 ) //| nVlrIpi 	= nVlrProd * Aliq IPI
		nVlrRetST 	:= ( nVlrIpi + nVlrProd ) * 0.13 	//| nVlrRetST 	= ( nVlrIpi + nVlrProd ) * Imcs Carga Media
		nBaseSt		:= ( nVlrRetST + 7 ) / 0.17 		//| nBaseSt		= ( nVlrRetST + VlrIcms ) / Icms Interno
		nMVACalc	:= nBaseSt / ( nVlrIpi + nVlrProd )//| nMVACalc		= nBaseSt / nVlrIpi + nVlrProd

		nFATOR:=U_FCalcIMC(cFilAnt,SUB->UB_LOCAL,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
		nCustTRF 	:= nCusB2 /  NFATOR  //( 1 + ( 1 / ( 1 - nPISCOF - nAliqICMSInt )) * nAcrIPI * nMVACalc * nAliqICMSInt)
	//| Fim Chamado: AAZUG0

	Else
	//Inserido por Edivaldo Gon็alves Cordeiro em 25/11/2008
	//Custo para Transferencia entre filiais
	    nFATOR:=U_FCalcIMC(cFilAnt,SUB->UB_LOCAL,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
		nCustTRF 	:= nCusB2 /  NFATOR  //( 1 + ( 1 / ( 1 - nPISCOF - nAliqICMSInt )) * nAcrIPI * nAliqMVATRF  * nAliqICMSInt)
	//		 	=  C66    /( 1 + ( 1 / ( 1 -    N66   -      G66    )) *   K66   *     I66           *E66      )
	EndIf

//Inserido por Cristiano Machado Data: 13/01/2009
	If FunName() == 'TMKA271'//Call Center
		If !Empty(SUB->UB_FILTRAN) // Item de Transferencia
			nCusto 	:=  nCustTRF
		Else
			nCusto 	:=  nCusto1
		Endif
	// Jorge Oliveira 16/08/2010 - Incluida a funcao IMDA090 e IMDA640
	//Transferencia entre filiais, Manutencao da Planilha, Transferencia de vendas das Planilhas
	ElseIf FunName() $('IMDA070/IMDA090/IMDA640')
		nCusto 	:=  nCustTRF
	ElseIf FunName() == 'MATA410' .AND. SA1->A1_COD == 'N00000' //Alteracao no Pedido Transferencia SC6
		nCusto 	:=  nCustTRF
	ElseIf FunName() == 'MATA410' .AND. SA1->A1_COD != 'N00000' //Alteracao Pedido de Venda SC6
		nCusto 	:=  nCusto1
	ElseIf FunName() == 'MATA460A'//Geracao da NF
		If SD2->D2_CLIENTE =='N00000' //Cliente Transferencia
			nCusto 	:=  nCustTRF
		Else
			nCusto 	:=  nCusto1
		Endif
	Endif

Return nCusto
**********************************************************************
Static Function FcondOnera()//Condic๕es Para Onerar Custos (.T.)
**********************************************************************
	Local  Desonera 	:= .T.
	Local  NaoDesonera 	:= .F.
	Local lEhST         := .F.
	Local cImdepa       := GetMV('MV_IMDEPA')

	Private lEstOner    := dDatabase >= GetMV("MV_ESTONER",,dDatabase+1)

//-----------Projeto Armaz้m s/ST - Nao Desonera o Custo
//If cFilAnt=="09" .AND. SB2->B2_LOCAL=="02"
	If SB2->B2_LOCAL=="02"
		Return(NaoDesonera)
	Endif



	If !Empty(U_FEhSufra())//| Chamado: AAZUQO - Cliente Suframa Desonera   data: 28/03/2012
		Return(Desonera)
	EndIF

	IF lEstOner // Verifica se filial tem estoque onerado

		If  cUFOri == "MT" //Regras para MT
			If FunName() $('IMDA070/IMDA090/IMDA640')
				Return(Desonera)
			ElseIf cUFOri <> SA1->A1_EST

				IF SF4->F4_CREDICM <> 'S' .and. SF4->F4_ICM <> 'S' .and.  cfilant == '02'  //alterado em 05/06/2015 por Rodrigo Solutio para nใo desonerar produtos quando a TES nใo calcula nem credita ICMS na filial 02

					Return(NaoDesonera)
				else

					Return(Desonera)

				endif


			Else
				Return(NaoDesonera)
			Endif
		Endif

		lEhST := U_FVerNcm()

	//Inserido por Edivaldo Goncalves Cordeiro
		If lEhST .AND. SA1->A1_COD == cImdepa  // eh uma transferencia entre filiais e o produto eh ST
			Return(Desonera)
		Endif


		If lEhST//Verifica Se Ncm do Produto eh ST
	   //Tratamento para RS
			If (cUFOri == "RS" .OR. cUFOri == "PR") .AND. (Alltrim(SB1->B1_ORIGER) == "F/NCZADO" .OR.Alltrim(SB1->B1_ORIGER) == "IMPORTADO")  //.AND. (Substr(SA1->A1_GRPSEG,3,1) == "1" .OR. Substr(SA1->A1_GRPSEG,3,1) == "2")

				IF  (Substr(SA1->A1_GRPSEG,3,1) == "1" .OR. Substr(SA1->A1_GRPSEG,3,1) == "2")
					Return(Desonera)
				//ELSE
				 //	Return(NaoDesonera)
				ENDIF
			Endif

		     //Ajuste para desonerar custo conforme Decreto RS 52.846/2015 (Exclusใo de Rolamentos e Correias Industriais da ST)
			If (cUFOri == "RS" .and. cUFOri == SA1->A1_EST .AND. SB2->B2_LOCAL=='01' .AND.  SB1->B1_INDUSTR == "S")

			    If (substr(SB1->B1_POSIPI,1,5) = '40103' .OR. substr(SB1->B1_POSIPI,1,8) = '59100000' .OR. substr(SB1->B1_POSIPI,1,4) = '8482')

			      Return(Desonera)
			    Endif
			Endif




	     //If cUFOri == "PR" .AND. (Alltrim(SB1->B1_ORIGER) == "F/NCZADO" .OR.Alltrim(SB1->B1_ORIGER) == "IMPORTADO") // .AND. (Substr(SA1->A1_GRPSEG,3,1) == "1" .OR. Substr(SA1->A1_GRPSEG,3,1) == "2")
	     // Return(NaoDesonera)
	     //Endif


			If cUFOri <> SA1->A1_EST //Verifica se eh Venda Para Fora do Estado
				Return(Desonera)
			ElseIf cUFOri <> 'MG' .AND. cUFOri == SA1->A1_EST .AND. (Substr(SA1->A1_GRPSEG,3,1) == "1" .OR. Substr(SA1->A1_GRPSEG,3,1) == "2")
				Return(Desonera)
			ElseIf cUFOri == SA1->A1_EST .AND. Substr(SA1->A1_GRPSEG,3,1) == "3"
			// Regra de Excessao solicitada pelos clientes. Para se enquadrar na ST. 20/01/08 | Ariorbeto - Fiscal
			//	If SA1->A1_ATIVIDA == '47890' .And.  cUFOri $("RS/PR")
			//	lTesOk	:= .T.
				If SA1->A1_CLITARE == 'S' //| Cliente tare ? S=Sim | N=Nao
					Return(Desonera)
				ElseIf SA1->A1_EXCECST == '1'  //| Cliente Entra na ST ? 1 = SIM | 2 = NAO
					Return(Desonera)
				ElseIf (cUFOri == "RS" .and. cUFOri == SA1->A1_EST .AND. Alltrim(SB1->B1_ORIGER) == "F/NCZADO" .OR. cUFOri == "RS" .and. cUFOri == SA1->A1_EST .AND.  Alltrim(SB1->B1_ORIGER) == "IMPORTADO")  //| Chamado: AAZVNW -  Data: 28/03/2013 - Cristiano Machado // .and. (substr(SB1->B1_POSIPI,1,5) = '40103' .or. substr(SB1->B1_POSIPI,1,8) = '59100000' .or. substr(SB1->B1_POSIPI,1,4) = '8482')
					Return(NaoDesonera) ////| Chamado: AAZVNW -  Data: 28/03/2013 - Cristiano Machado


				//ElseIf cUFOri == "RS" .and. cUFOri == SA1->A1_EST .AND. Alltrim(SB1->B1_ORIGER) <> "F/NCZADO" .OR. cUFOri == "RS" .and. cUFOri == SA1->A1_EST .AND. Alltrim(SB1->B1_ORIGER) <> "IMPORTADO"  //| Chamado: AAZVNW -  Data: 28/03/2013 - Cristiano Machado // .and. (substr(SB1->B1_POSIPI,1,5) = '40103' .or. substr(SB1->B1_POSIPI,1,8) = '59100000' .or. substr(SB1->B1_POSIPI,1,4) = '8482')
				  //	Return(NaoDesonera)
				ElseIf cUFOri == "MG" .and. cUFOri == SA1->A1_EST //.AND. Alltrim(SB1->B1_ORIGER) <> "F/NCZADO" .OR. cUFOri == "RS" .and. cUFOri == SA1->A1_EST .AND. Alltrim(SB1->B1_ORIGER) <> "IMPORTADO"  //| Chamado: AAZVNW -  Data: 28/03/2013 - Cristiano Machado // .and. (substr(SB1->B1_POSIPI,1,5) = '40103' .or. substr(SB1->B1_POSIPI,1,8) = '59100000' .or. substr(SB1->B1_POSIPI,1,4) = '8482')
					Return(NaoDesonera)
				ElseIf ConAgri() .and. SB1->B1_INDUSTR == "S" //Regra para Concessionarias Agricolas conforme proj. logico do chamado AAZQV1 - Agostinho 23/09/2009
					Return(NaoDesonera)
				ElseIf !U_FCnaeAuto() //Cnae Industria
					If SB1->B1_INDUSTR == "S"
						Return(Desonera)
					Endif
				Endif
			Endif
		Endif
	Endif

Return(NaoDesonera)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLIBRARY   บAutor  ณMicrosiga           บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

**********************************************************************
User Function FVerNcm()
**********************************************************************
	Local lTesOk := .F.
	Private Classif := SB1->B1_POSIPI

	cQuery := " "
	cQuery += " SELECT ZA4_CLASSI "
	cQuery += " FROM " + RetSqlName("ZA4")
	cQuery += " WHERE ZA4_FILIAL  = '" + xFilial("ZA4")	+ "' "
	cQuery += " AND ZA4_FORIGE    = '" + cfilant 		+ "' "
	cQuery += " AND ZA4_NOTA      = 'S' "
	cQuery += " AND(ZA4_TIPO      = 'N' OR ZA4_TIPO   = '*') "
	cQuery += " AND ZA4_REGST     = 'S' "
	cQuery += " AND ZA4_CLASSI   != '*%' "
	cQuery += " AND D_E_L_E_T_    = ' ' "
	cQuery += " GROUP BY ZA4_CLASSI  "

	MEMOWRIT("C:\SQLSIGA\FVerNcm.TXT ", cQuery)

	IF Select( '_ST' ) <> 0
		dbSelectArea('_ST')
		DbCloseArea('_ST')
	Endif

	TCQUERY cQuery NEW ALIAS ('_ST')

	Do While _ST->(!EOF())
		cCaracter := ""
		For i:=1 to len(alltrim(_ST->ZA4_CLASSI))

			If substr(Classif,i,1) == substr(_ST->ZA4_CLASSI,i,1)
				cCaracter += substr(_ST->ZA4_CLASSI,i,1)
				ltesok := .T.
			ElseIf substr(_ST->ZA4_CLASSI,i,1) == "%" .and. ltesok
				ltesok := .T.
				exit
			Else
				ltesok := .F.
				exit
			Endif

		Next i

		If ltesok
			Exit
		else
			_ST->(DbSkip())
		Endif

	EndDo

	_ST->(DBCloseArea())

Return(lTesOk)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLIBRARY   บAutor  ณMicrosiga           บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

**********************************************************************
User Function F_Sim_SUBTRIB(cpar1,cpar2,cpar3)//|Valida as Regras do Cliente Ref. Subst. Trib -> SX5 TAB IE
**********************************************************************
	Local lReturn := .F.
	Local cRegra  := cpar1 + "," + cpar2 + "," + cpar3
	Local cQuery := " "

	cQuery += "SELECT '1' ST "
	cQuery += "  FROM " + RetSqlName("SX5")
	cQuery += " WHERE x5_filial = '  '"
	cQuery += "   AND x5_tabela = 'IE'"
	cQuery += "   AND x5_descri LIKE '" + cpar1 + "," + cpar2 + "%'" //'IMP,RS%'"
	cQuery += "   AND (SUBSTR (x5_descri, 8, 1) = '" + cpar3 + "' OR SUBSTR (x5_descri, 8, 1) = '*')"
	cQuery += "   AND d_e_l_e_t_ = ' ' AND rownum = 1"

//MEMOWRIT("C:\SQLSIGA\Funcao_F_Sim_SUBTRIB.TXT ", cQuery)

	IF SELECT( '_ST' ) <> 0
		dbSelectArea('_ST')
		DbCloseArea('_ST')
	Endif

	TCQUERY cQuery NEW ALIAS ('_ST')

	IF !EMPTY(_ST->ST)
		lReturn   := .T.
	ENDIF

	_ST->(DBCloseArea())

Return lReturn
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณClearAcentosบAutor  ณCristiano Machadoบ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetira acentos das strings enviadas a funcap               บฑฑ
ฑฑบ          ณ                                                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
**********************************************************************
User Function ClearAcentos(xTxt)
**********************************************************************
	Local cAcentos  	:= "็ว€แ้ํ๓๚มษอำฺโ๊๎๔๛ยสฮิÛเ้ํ๓๚มษอำฺไ๋๏๖üฤหฯึÜใ๕รี"+chr(65533)+"ภล… ฆๅ"+chr(65533)+"ศ่ฬก"+chr(65533)+"าึ“”•ขง๐ูฃ"+chr(65533)+"๙ั๑%$þ๗Ýฐบชฌ&"
	Local cAcSubst  	:= "cCCcaeiouAEIOUaeiouAEIOUaeiouAEIOUaeiouAEIOUaoAOAAAAaaaaaaEEeeeIiiOOooooooUuuuNnPScoiooaqaE"
	Local nI       	:= 0
	Local nPos     	:= 0

	cCpoLmp			:=	cTxt

//ณTroca Acentos
	For nI := 1 To Len( cCpoLmp )
		If ( nPos := At( SubStr( cCpoLmp, nI, 1 ), cAcentos ) ) > 0
			cCpoLmp := SubStr( cCpoLmp, 1, nI - 1 ) + SubStr( cAcSubst, nPos, 1 ) +  SubStr( cCpoLmp, nI + 1 )
		EndIf
	Next nI

	cTxt  := cCpoLmp

Return(cTxt)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLIBRARY   บAutor  ณMicrosiga           บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
**********************************************************************
User Function FValIcmsRet()
**********************************************************************

	nMVA        := 0

	nValIcmSt 	:= 0

	nIcmRetido	:= 0

	nValDesp 	:= NoRound(SUB->UB_VLRITEM / SUA->UA_VALMERC * SUA->UA_DESPESA,2) // Despesa DOC

	nAcreCon 	:= NoRound(((SUB->UB_VLRITEM + (SUB->UB_VLRITEM / SUA->UA_VALMERC) * SUA->UA_DESPESA) * SE4->E4_ACRSFIN)/100,2) //Acrescimo Condicao

	nValFret 	:= NoRound(SUB->UB_VLRITEM / SUA->UA_VALMERC * SUA->UA_FRETE,2) //Valor Frete

	nCalcIcm 	:= NoRound((SUB->UB_VLRITEM  + nValDesp + nAcreCon + nValFret),2)

	nAlicIpi 	:= SB1->B1_IPI

	cTpCliFor  	:= SA1->A1_TIPO

	cSegmento  	:= substr(SA1->A1_GRPSEG,3,1)

// Jorge Oliveira - 22/12/10 - Alteracao da regra de calculo de IMCS ST
// Regra antiga: SF4->F4_CREDST == '3'
// Regra nova..: ( SF4->F4_CREDST == '3' .Or. ( SF4->F4_CODIGO $ '720_750' .And. SF4->F4_CREDST $ '2_4' ) )
	If U_Fsubtrib(xFilial("SUA"),"S","N",cTpCliFor,SA1->A1_EST,SB1->B1_POSIPI,cSegmento,3) .AND.;
			( SF4->F4_CREDST $ '2/4') //'3' .Or. ( SF4->F4_CODIGO $ '720/721/750/723' .And. SF4->F4_CREDST $ '2/4' ) )

		DbSelectarea("SF7")
		If DbSeek(xFilial("SF7")+SB1->B1_GRTRIB,.F.)
			While !eof() .AND. SB1->B1_GRTRIB == SF7->F7_GRTRIB .AND. SF7->F7_GRPCLI == SPACE(03)
				If SA1->A1_EST == SF7->F7_EST
					nMVA := SF7->F7_MARGEM
					Exit
				Endif
				DbSkip()

			EndDo

			nBaseRet 	:= ( nCalcIcm * (1 + nAlicIpi / 100)) * ( 1 +  (nMVA/100) )
			cEstxIcm 	:= GetMv("MV_ESTICM")
			nPosUf		:= At(SA1->A1_EST,cEstxIcm) + 2
			nValIcmSt 	:= (nBaseRet * ((Val(Substr(cEstxIcm,nPosUf,2))/100)))


		Endif

	Endif

	lInterna := (SM0->M0_ESTENT == SA1->A1_EST)

	If SF4->F4_MKPCMP = '2'  //SF4->F4_ICM = 'S'     //

		If lInterna
			nAlicIcm := GetMv('MV_ICMPAD')
		ElseIf SA1->A1_EST $ GetMv('MV_NORTE') .AND. !(SM0->M0_ESTENT $ GetMv('MV_NORTE'))
			nAlicIcm := 7
		Else
			nAlicIcm := 12
		EndIf

		If nValIcmSt != 0
			nIcmRetido := NoRound(( nValIcmSt - ( nCalcIcm * ( nAlicIcm / 100) )),3)
		Endif

	///JULIO COMENTOU
	///em 30/04/2012
		If SF4->F4_BASEICM<>0 .AND. SF4->f4_bsicmst==0 .AND. lInterna .AND. NVALICMST!=0
			nAliqRed:= nAlicIcm * (SF4->F4_BASEICM/100)
			nAliqNova:= nAliqRED
			nIcmRetido := NoRound(( nValIcmSt - ( nCalcIcm * ( nAliqNova / 100) )),3)
		ELSEIF 	SF4->F4_BASEICM<>0 .AND. SF4->f4_bsicmst<>0 .AND. lInterna .AND. NVALICMST!=0
		//pega aliquota de reducao
			nAliqRed   := nAlicIcm * (SF4->F4_BSICMST/100)
			nAliqNova  := nAliqRED
		//aplico no valor base
			nValor     := (nBaseRet * (nAliqNova/100))
		//neste valor temos de reduzir novamente
			nIcmRetido:= NoRound(( nValor - ( nCalcIcm * ( nAliqNova / 100) )),3)
		Endif


	EndIf


Return(nIcmRetido)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExecMySql บAutor  ณCristiano Machado   บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPar: 	cSql    = Texto Sql,                                  บฑฑ
ฑฑบ          ณ	  	cAlias  = Alias a ser usado no caso de Query          บฑฑ
ฑฑบ          ณ      lModo   = "E"-Execucao ou "Q"-Query)                  บฑฑ
ฑฑบ          ณ      lMostra = Se deve Apresentar a Query para captura     บฑฑ
ฑฑบ          ณ      lChange = Se deve executar o ChangeQuery              บฑฑ
ฑฑบ          ณObs.: Execucao(Drop, Update, Delete e etc..                 บฑฑ
ฑฑบ          ณRetorno: No modo Execucao retorna o Status caracter, em     บฑฑ
ฑฑบ          ณmodo Query nใo tem retorno.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
User Function ExecMySql( cSql , cCursor , lModo, lMostra, lChange )
*********************************************************************
	Local nRet := 0
	Local cRet := "Executado Com Sucesso"

	Default lModo   := "Q"
	Default lMostra := .F.
	Default lChange := .T.

	If lMostra
		cSql := U_CaixaTexto(cSql)
	EndIf

	If lModo == "Q" //| Query

		If lChange
			cSql := ChangeQuery(cSql)
		Else
			cSql := Upper(cSql)
		EndIf

		If( Select(cCursor) <> 0 )
			DbSelectArea(cCursor)
			DbCloseArea()
		EndIf

		TCQUERY cSql NEW ALIAS &cCursor.

	ElseIf lModo == "E" //| Comandos

		cSql := Upper(cSql)

		nRet := TCSQLExec(cSql)

		If nRet <> 0
			cRet := TCSQLError()
			If lmostra
				Iw_MsgBox(cRet)
			Endif
		Endif
		Return(cRet)

	ElseIf lModo == "P" //Procedure

		cSql := Upper(cSql)

		TCSQLExec("BEGIN")

		nRet := TCSPExec(cSql)

		If Empty(nRet)
			cRet := TCSQLError()

			If lmostra
				Iw_MsgBox(cRet)
			Endif
		Endif

		TCSQLExec("END")

		Return(cRet)

	Endif


Return()
*********************************************************************
User Function CaixaTexto( cTexto , cMail)
*********************************************************************

	Default cMail := ""

	__cFileLog := MemoWrite(Criatrab(,.F.)+".log",cTexto)

	Define FONT oFont NAME "Tahoma" Size 6,12
	Define MsDialog oDlgMemo Title "Leitura Concluida." From 3,0 to 340,550 Pixel

	@ 5,5 Get oMemo  Var cTexto MEMO Size 265,145 Of oDlgMemo Pixel
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont

	Define SButton  From 153,205 Type 6 Action Send(cTexto)   Enable Of oDlgMemo Pixel
	Define SButton  From 153,245 Type 1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel

	Activate MsDialog oDlgMemo Center

Return(cTexto)
*********************************************************************
Static Function Send(cTexto)
*********************************************************************

	U_EnvMyMail("","","","",cTexto,"",.T.)

Return()


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEnvMyMail บAutor  ณCristiano MAchado   บ Data ณ  07/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Envia Email conform parametros                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
User Function EnvMyMail(_cFrom,_cTo,_cBcc,_cSubject,_cBody,_cAttach,lTela)//| U_EnvMyMail(De, Para, Copia, Assunto, Corpo, Anexo )
*********************************************************************
	Local cServer 		:= SX6->(U_GetSx6("MV_RELSERV"	,""	,"mail.imdepa.com.br"			))
	Local cAccount 	:= SX6->(U_GetSx6("MV_RELACNT"	,""	,"protheus@imdepa.com.br"	))
	Local cPassword 	:= SX6->(U_GetSx6("MV_RELPSW"		,""	,"mp8"										))
	Local lAuth 			:= SX6->(U_GetSx6("MV_RELAUTH"	,""	,.F.											))
	Local lResult  	:= .T.
	Local cError	    	:= ''
	Local lContinua	:= .T.
	Local lPula			:= .F.
   //        Alert(_cSubject)
	Private cFrom				:= Iif(empty(Alltrim(_cFrom)), cAccount, Alltrim(_cFrom))
	Private cTo					:= PadR( Alltrim(_cTo)		, 200 ," " )
	Private cBcc				:= PadR( Alltrim(_cBcc)		, 200 ," " )
	Private cSubject			:= PadR( Alltrim(_cSubject)	, 200 ," " )
	Private cBody				:= Alltrim(_cBody) + Space(10000)
	Private cAttach				:= Alltrim(_cAttach)

	Private cPathInServer	 	:= "\system\anexos\"
	Private cAttachL				:= cAttach
	Private cDrive					:= ""
	Private cDiretorio			:= ""
	Private cNome					:= ""
	Private cExtensao			:= ""

	Private lAnexoCli			:= .F. /// identifica como verdadeiro quando o anexo esta no cliente..
	Default lTela := .F.


	//| Valida Anexo e Copiar para o Server caso necessario... |
	If !Empty( Alltrim( cAttach ) ) // Divide ecaminho e nome do arquivo....anexo

		SplitPath( cAttach, @cDrive, @cDiretorio, @cNome, @cExtensao )

			//|  Valida se o Endere็o do anexo eh Cliente...
		If At(":",cAttach) > 0
			lAnexoCli := .T.
			If File(cPathInServer+cNome+cExtensao)
				If fErase(cPathInServer+cNome+cExtensao) == -1
					Iw_MsGbox("Nใo pode copiar o arquivo "+ cAttach+" para o servidor "+ cPathInServer+cNome+cExtensao+", jแ existe um arquivo no destino com o mesmo nome e nเo pode ser deletado!!! " )
					lPula := .T.
				EndIf
			EndIf

			If !lPula
				If _CopyFile( cAttach , cPathInServer+cNome+cExtensao )
					cAttach := cPathInServer+cNome+cExtensao
				Else
					Iw_MsGbox("Nใo pode copiar o arquivo "+ cAttach+" para o servidor "+ cPathInServer+cNome+cExtensao+"!!! " )
					lContinua := lTela := .F.
				EndIf
			EndIf
		EndIf
	EndIf


	If lTela
		lContinua := TelaMail()
	EndIf

	If lContinua

		CONNECT SMTP SERVER Alltrim(cServer) ACCOUNT Alltrim(cAccount) PASSWORD Alltrim(cPassword) RESULT lResult

	 //lResult := MailAuth(cAccount,cPassword)

		If lResult
			SEND MAIL FROM cFrom TO cTo CC cBcc SUBJECT cSubject BODY cBody ATTACHMENT cAttach RESULT lResult

			If !lResult
				GET MAIL ERROR cError
				IW_MsgBox("Email Nใo Enviado !!! cServer:"+cServer+" Conta:"+cAccount +" Pass: "+ cPassword+ " lResult: "+cValToChar(lResult) +" Erro: "+cError,"Aten็ใo","ALERT")
			Else
				IW_MsgBox("Email "+Alltrim(cSubject)+" . Enviado com Sucesso. Destinatarios:"+Alltrim(cTo+cBcc),"Aten็ใo","INFO")
			EndIf
		Endif

		DISCONNECT SMTP SERVER
	EndIf


Return(cError)
*********************************************************************
Static Function TelaMail() //| Prepara Para Gera็ใo por PDF
*********************************************************************

	Static oButtonV
	Static oButtonE
	Static oButtonS
	Static oGet
	Static oGroup
	Static oMultiGe1
	Static oSay
	Static oTHButton

	Local  cMailUser 	:= ""

	Private oWinMail
	Private lReturn := .F.
	Private lCheck
	Private lCheck2


	PswOrder(2);PswSeek(CUSERNAME,.T.)
	cMailUser		:= SA3->(PswRet()[1][14]) + Space(100)
	cAttach			:= Alltrim(cAttach)

	If Empty(cTo)
		cTo := cMailUser
	EndIf

 /*
	DEFINE MSDIALOG oWinMail TITLE "Envio de e-mail" FROM 000, 000  TO 450, 505 COLORS 0, 16777215 PIXEL
	@ 010, 010 GROUP oGroup TO 063, 245 PROMPT "Emails" 		OF oWinMail COLOR 0, 16777215 PIXEL
	@ 065, 010 GROUP oGroup TO 092, 192 PROMPT "Assunto" 		OF oWinMail COLOR 0, 16777215 PIXEL
	@ 065, 195 GROUP oGroup TO 092, 245 PROMPT "Anexo" 		OF oWinMail COLOR 0, 16777215 PIXEL
	@ 095, 010 GROUP oGroup TO 195, 245 PROMPT "Mensagem"		OF oWinMail COLOR 0, 16777215 PIXEL
	@ 197, 045 GROUP oGroup TO 220, 223 PROMPT "" 					OF oWinMail COLOR 0, 16777215 PIXEL

	@ 020, 020 SAY oSay PROMPT "De:" 		SIZE 015, 008 OF oWinMail COLORS 0, 16777215 PIXEL
	@ 035, 020 SAY oSay PROMPT "Para:" 	SIZE 015, 008 OF oWinMail COLORS 0, 16777215 PIXEL
	@ 048, 020 SAY oSay PROMPT "C๓pia:" 	SIZE 015, 008 OF oWinMail COLORS 0, 16777215 PIXEL

	@ 020, 040 MSGET oGet VAR cFrom 		SIZE 195, 010 OF oWinMail COLORS 0, 16777215 PIXEL
	@ 033, 040 MSGET oGet VAR cTo 			SIZE 195, 010 OF oWinMail COLORS 0, 16777215 PIXEL
	@ 046, 040 MSGET oGet VAR cBcc 			SIZE 195, 010 OF oWinMail COLORS 0, 16777215 PIXEL
	@ 075, 015 MSGET oGet VAR cSubject 	SIZE 167, 010 OF oWinMail COLORS 0, 16777215 PIXEL

	@ 105, 020 GET oMultiGe1 VAR cBody OF oWinMail MULTILINE SIZE 215, 080 COLORS 0, 16777215 HSCROLL PIXEL

	If lAnexoCli
		oTHButton := THButton():New(071,195,cNome+cExtensao,oDlg,{||FAction(1)},40,20,,"")
	EndIf
	//@ 074, 200 BUTTON oButtonV PROMPT cNome+cExtensao	 		Action(FAction(1))		SIZE 040, 015 OF oWinMail PIXEL
	@ 201, 050 BUTTON oButtonE PROMPT "Enviar" 		Action(FAction(2))		SIZE 050, 015 OF oWinMail PIXEL
	@ 201, 170 BUTTON oButtonS PROMPT "Sair"    	 	Action(FAction(3))		SIZE 050, 015 OF oWinMail PIXEL


	oButtonE:SetFocus()

	ACTIVATE MSDIALOG oWinMail CENTERED
	*/
	DEFINE DIALOG oWinMail TITLE "Envio de e-mail" FROM 000, 000  TO 450, 505 COLORS 0, 16777215  STYLE nOr( DS_MODALFRAME, WS_DLGFRAME )  PIXEL


	@ 011, 010 GROUP oGroup TO 063, 245 PROMPT "Emails" 		              OF oWinMail COLOR 0, 16777215 PIXEL

	@ 065, 010 GROUP oGroup TO 092, 192 PROMPT "Assunto"                      OF oWinMail COLOR 0, 16777215 PIXEL
	@ 065, 195 GROUP oGroup TO 092, 245 PROMPT "Anexo" 	                      OF oWinMail COLOR 0, 16777215 PIXEL

	@ 095, 010 GROUP oGroup TO 188, 245 PROMPT "Mensagem"		              OF oWinMail COLOR 0, 16777215 PIXEL


	@ 020, 020 SAY oSay PROMPT PadC("De   :",6," ")	            SIZE 015, 008 OF oWinMail COLORS 0, 16777215 PIXEL
	@ 035, 020 SAY oSay PROMPT PadC("Para :",6," ")             SIZE 015, 008 OF oWinMail COLORS 0, 16777215 PIXEL
	@ 048, 020 SAY oSay PROMPT PadC("Cc   :",6," ")             SIZE 015, 008 OF oWinMail COLORS 0, 16777215 PIXEL

	@ 020, 040 MSGET oGet VAR cFrom 	WHEN.F.                 SIZE 195, 010 OF oWinMail COLORS 0, 16777215 PIXEL
	@ 033, 040 MSGET oGet VAR cTo 			                    SIZE 195, 010 OF oWinMail COLORS 0, 16777215 PIXEL
	@ 046, 040 MSGET oGet VAR cBcc 			                    SIZE 195, 010 OF oWinMail COLORS 0, 16777215 PIXEL

	@ 074, 020 MSGET oGet VAR cSubject 	                        SIZE 165, 010 OF oWinMail COLORS 0, 16777215 PIXEL

	@ 105, 020 GET oMultiGe1 VAR cBody        OF oWinMail MULTILINE SIZE 215, 077 COLORS 0, 16777215 HSCROLL PIXEL

	Opcional(oWinMail) // Para Inclusao de opcoes especificas a cada local em que o email esta sendo utilizado...

	//TBtnBmp2():New(0,420,030,030,'OK_MDI.PNG',,,,{|| FAction(2) },oWinMail,"Enviar e-mail",{||},,.T. )
    //TBtnBmp2():New(0,460,030,030,'CANCEL.PNG',,,,{|| FAction(3) },oWinMail,"Sair",{||},,.T. )
    /*
    TBtnBmp2():New(0,420,030,030,'IC_EMAILRECEBIDO.GIF',,,,{|| FAction(2) },oWinMail,"Enviar e-mail",{||},,.T. )
    TBtnBmp2():New(0,460,030,030,'IC_EMAILEXCLUIDO.GIF',,,,{|| FAction(3) },oWinMail,"Sair",{||},,.T. )
    */


	TBtnBmp2():New(0,410,030,030,'NGBIOALERTA_02.PNG',,,,{|| FAction(2) },oWinMail,"Enviar e-mail",{||},,.T. )
	TBtnBmp2():New(0,460,030,030,'NGBIOALERTA_03.PNG',,,,{|| FAction(3) },oWinMail,"Sair",{||},,.T. )













	If lAnexoCli
		TBtnBmp2():New(148,422,40,23,'CLIPS_MDI.PNG',,,,{|| FAction(1) },oWinMail,"Abrir arquivo anexo "+cNome+cExtensao,{||},,.T. )
	EndIf


	ACTIVATE DIALOG oWinMail CENTERED



Return(lReturn)
********************************************************************
Static Function Opcional(oWinMail)
********************************************************************
	Local lCallCenter 	:=  Iif(FUNNAME()=='TMKA271',.T.,.F.)


	If lCallCenter

		lCheck	:=	IIf(SU7->U7_OPENREL == '1' ,.T. ,.F. ) //Verifica a configura็ใo atual da Op็ใo de impressao dos relatorios para o Operador
		lCheck2	:=	IIf(SU7->U7_RCOPORC == '1' ,.T. ,.F. ) //Verifica a configura็ใo atual da Op็ใo de Receber uma C๓pia do e-mail do Or็amento para o operador


		//Faz a abertura do Or็amento Automaticamente
		If lCheck
			MsAguarde({|| FAction(1)},OemToAnsi("Abertura Automatica do Or็amento"),OemToAnsi("Abrindo Arquivo " +Alltrim(cAttach)))
		Endif

		@ 197, 010 GROUP oGroup TO 220, 245 PROMPT "Configura็๕es" 	              OF oWinMail COLOR 0, 16777215 PIXEL

		@ 206,20  CHECKBOX oCheck  VAR lCheck  PROMPT OemToAnsi("Abrir Or็amento Automaticamente") SIZE 120, 10 OF oWinMail PIXEL ON CLICK fConfigOper('1')
		@ 206,152 CHECKBOX oCheck2 VAR lCheck2 PROMPT OemToAnsi("Receber C๓pia do Or็amento     ") SIZE 120, 10 OF oWinMail PIXEL ON CLICK fConfigOper('2')

	EndIF


Return
********************************************************************
Static Function fConfigOper(cObj)
********************************************************************

	RecLock("SU7",.F.)

	If cObj=='1' //Objeto 1 : Configura o operador para abrir o Or็amento Automaticamente
		If lCheck
			SU7->U7_OPENREL:="1"
		Else
			SU7->U7_OPENREL:="2"
		Endif
	Else

		If lCheck2 //Objeto 2 : Configura o operador para receber uma c๓pia do Or็amento Automaticamente
			SU7->U7_RCOPORC:="1"
		Else
			SU7->U7_RCOPORC:="2"
		Endif

	Endif

	SU7->( MsUnlock() )
Return

********************************************************************
Static Function FAction(nOpc)
********************************************************************

	Do Case
	Case nOpc == 1 //| Abrir Anexo
		ShellExecute( "Open", cAttachL, "", "", 1 )

	Case nOpc == 2 //| Enviar

		If Empty(cTo) .And. Empty(cBcc)
			IW_MsgBox("Para enviar o email Preencha o Destinatแrio.","Aten็ใo","INFO")
			Return()
		EndIf

		oWinMail:End()
		//IW_MsgBox("Email Enviado com Sucesso. Destinatarios:"+Alltrim(cTo+cBcc),"Aten็ใo","INFO")
		lReturn := .T.

	Case nOpc == 3  //| Sair
		oWinMail:End()

	End Case


Return()


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVERSEDEV  บAutor  ณAgostinho Lima      บ Data ณ  21/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o cliente estแ com titulos em atraso. Conforme บฑฑ
ฑฑบ          ณ os dias de atraso informado no parametro MV_DIAATR         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
**********************************************************************
User Function VERSEDEV(CLIE)
**********************************************************************
	Local oFont3    		:= 	TFont():New("Arial",0,17,,.T.,0,,700,.F.,.F.,,,,,, )
	LOCAL cQuery 			:= 	""
	LOCAL cTexto 			:= 	"       TITULO         TIPO   VENCIMENTO    DIAS ATRASO     VALOR"+CHR(13)+CHR(10)
	LOCAL aArea  			:= 	GetArea()
	LOCAL nTotcli			:= 	0
	Local aBrowse			:=	  {}
	Local cOldReadVar 	:= ReadVar()


	//Conout('VERSEDEV') // Conout's foram usados para mapear os pontos lentos da rotina...

	//Conout('VERSEDEV -> P01 -> ' + Time())

	If FUNNAME() == "IMDB2BPV" .OR. FUNNAME()=="RPC"
		Return(CLIE)
	EndIf

	//Conout('VERSEDEV -> P02 -> ' + Time())

	//IIF(Select('TDEV')!=0, TDEV->(DbCloseArea()), )	// FABIANO PEREIRA
	cQuery := "SELECT E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_VENCREA,E1_SALDO,TRUNC(SYSDATE) - TO_DATE(E1_VENCREA,'YYYYMMDD') ATRASO "
	cQuery += " FROM SE1010 "
	cQuery += " WHERE  D_E_L_E_T_  = ' ' AND E1_FILIAL = ' ' "
	cQuery += " AND E1_CLIENTE  = '"+CLIE+"' "
	cQuery += " AND E1_SALDO > 0 "
	cQuery += " AND E1_TIPO IN  "+GETMV("MV_TIPOATR")
	cQuery += " AND TO_DATE(E1_VENCREA,'YYYYMMDD')  > SYSDATE - "+GETMV("MV_DIAPVAL")
	cQuery += " AND ( '"+DTOS(DDATABASE)+"' - E1_VENCREA ) > '"+GETMV("MV_DIATATR")+"' "

	// FABIANO PEREIRA - SOLUTIO
	// RETIRADO PARA MELHORAR PERFORMACE... ORDENA NO aSort NO ARRAY aBrowse
	// cQuery += " ORDER BY E1_VENCREA,E1_PREFIXO,E1_NUM,E1_PARCELA "

	U_ExecMySql(cQuery,'TDEV','Q',.F.) //   TCQUERY cQuery NEW ALIAS ("TDEV")
	//Conout('VERSEDEV -> P03 -> ' + Time())

	DbSelectarea('TDEV')

	//Conout('VERSEDEV -> P04 -> ' + Time())

	If TDEV->(!Eof()) //nCount >= 1

		//Conout('VERSEDEV -> P05 -> ' + Time())

		nTitulos := 0
		DbSelectArea('TDEV')
		Do While !Eof()

					//									1									     2                                                       3                                                       4                               5                                      6
			Aadd(aBrowse, {TDEV->E1_PREFIXO + " - " + TDEV->E1_NUM + " - " +TDEV->E1_PARCELA, TDEV->E1_TIPO, RIGHT(TDEV->E1_VENCREA,2)+"/"+SUBSTR(TDEV->E1_VENCREA,5,2)+"/"+LEFT(TDEV->E1_VENCREA,4), AllTrim(Str(DateDiffDay(Date(),StoD(TDEV->E1_VENCREA)))), Transform(TDEV->E1_SALDO,'@E 999,999.99'), StoD(TDEV->E1_VENCREA) })
			nTotCli += TDEV->E1_SALDO
			nTitulos++
			DbSkip()
		EndDo
		//Conout('VERSEDEV -> P06 -> ' + Time())
		aSort(aBrowse,,,{|X,Y| X[6] > Y[6]})
		//Conout('VERSEDEV -> P07 -> ' + Time())
		oDlgAtr  := MSDialog():New(050, 050, 300, 580,'CLIENTE DEVEDOR!!!',,,.F.,,,,,,.T.,,/*oFont*/,.T. )

		oBrowse := TCBrowse():New(001, 003, 260, 110,,{'Tํtulo','Tipo','Vencimento','Dias Atraso','Valor'},{},oDlgAtr,,,,,{||},,/*oFont*/,,,,,.F.,,.T.,,.F.,,.T.,.F.)
		oBrowse:SetArray(aBrowse)

		oBrowse:AddColumn( TCColumn():New('Tํtulo',			{|| aBrowse[oBrowse:NAT,01] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
		oBrowse:AddColumn( TCColumn():New('Tipo',	   		{|| aBrowse[oBrowse:NAT,02] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
		oBrowse:AddColumn( TCColumn():New('Vencimento',		{|| aBrowse[oBrowse:NAT,03] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
		oBrowse:AddColumn( TCColumn():New('Dias Atraso',	{|| aBrowse[oBrowse:NAT,04] },,,,"CENTER",,.F.,.T.,,,,.F.,) )
		oBrowse:AddColumn( TCColumn():New('Valor',			{|| aBrowse[oBrowse:NAT,05] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
		//Conout('VERSEDEV -> P08 -> ' + Time())
		oBtnSair := TButton():New(113, 005, "Sair", oDlgAtr,{|| oDlgAtr:End() },30,010,,,.F.,.T.,.F.,,.F.,,,.F. )
		oSayTit	 :=	TSay():New( 115, 070,{|| AllTrim(Str(nTitulos))+' TITULO(s) EM ATRASO' },oDlgAtr,,/*oFont3*/,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,088,008)
		oSayTotal:=	TSay():New( 115, 160,{||"TOTAL:   R$ "+ AllTrim(Transform(nTotCli,'@E 999,999.99')) },oDlgAtr,,oFont3,.F.,.F.,.F.,.T.,CLR_HRED,CLR_WHITE,088,008)

		oBtnSair:SetFocus()
		oDlgAtr:Activate(,,,.T.)
		//Conout('VERSEDEV -> P09 -> ' + Time())
	EndIf


// __ReadVar ESTA EM BRANCO AO SAIR DO MSDialog
	If Empty(__ReadVar)
		__ReadVar := cOldReadVar
	EndIf
	Conout('VERSEDEV -> P10 -> ' + Time())
	DbSelectarea('TDEV')
	DbCloseArea()


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ  VERIFICA VIGENCIA DA TABELA DE PRECO									ณ
	//|  SE FORA DA VIGENCIA BUSCA TABELA DE PRECO PELO SEGMENTEO DO CLIENTE	|
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aValidDA0 := ExecBlock('ChkValidDA0',.F.,.F.,{M->UA_TABELA})
	If aValidDA0[01]
		M->UA_TABELA := aValidDA0[02]
	EndIf


	//Conout('VERSEDEV -> P11 -> ' + Time())
	RestArea(aArea)
	//Conout('VERSEDEV -> P12 -> ' + Time())

RETURN(CLIE)
*********************************************************************
USer Function IGeraFile( cFileTxt, cTitulo )
*********************************************************************
//Local cTrab   := Criatrab(,.F.)
//Local cArq   := "\system\arqtrab.txt"
//Local __cFileTxt  := MemoWrit(cArq,cFileTxt)
//Local nOrder   := 2 // Pesquisa pelo nome do usuario
	Static oFontNor  := TFont():New("Courier New",,16,.T.)  //| Campos

	Static oEnvMail,oSairArq,oCampMail,oEnvMail,oSayMail

//PswOrder(nOrder)
//PswSeek(Substr(cusuario,7,15), .T.)
//cEamilCC := PswRet()[1][14]  //| Retorna Codigo do Usuario

	Define FONT oFont NAME "Tahoma" Size 6,12
	Define MsDialog oDlgMemo Title cTitulo From 3,0 to 340,550 Pixel

	@ 005,005 Get oMemo  Var cFileTxt MEMO Size 265,145 Of oDlgMemo Pixel

	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont  := oFont

//@ 155, 006 SAY oSayMail PROMPT "Enviar Para:" FONT oFontNor SIZE 060, 007 OF oDlgMemo COLORS 0, 16777215 PIXEL
//@ 153, 050 MSGET oCampMail VAR cEmailTo SIZE 140, 010 OF oDlgMemo COLORS 0, 16777215 PIXEL

//@ 153,200 Button oEnvMail PROMPT "Enviar"  Action ({ oDlgMemo:End(), EnvMail(cArq)})  Size 30,12 Of oDlgMemo Pixel
	@ 153,235 Button oSairArq PROMPT "Sair"   Action   oDlgMemo:End()       Size 30,12 Of oDlgMemo Pixel

	Activate MsDialog oDlgMemo Center

Return()
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExecFunc  บAutor  ณCristiano Machado   บ Data ณ  10/05/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Executa Qualquer Funcao e mantem as ultimas 10 executados บฑฑ
ฑฑบ          ณordenadas.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
User Function ExecMyFunc()//| Executa Qualquer Fun็ใo   Autor: Cristiano Machado   Data: 10/05/2011
*********************************************************************
	Private lContinua 	:= .T.
	Private cLastRun 	:= GetProfString( Lower("ExecMy_"+ GetComputerName()), "LastRun"		, "undefined", .T.)

	If cLastRun == "undefined"
		cLastRun := ""
	EndIf

	While lContinua
		MontaTela()

		WriteProfString( Lower("ExecMy_"+ GetComputerName()), "LastRun"		,cLastRun	,.T.)

	EndDo

Return()
*********************************************************************
Static Function MontaTela()
*********************************************************************
	Static oJanela
	Static oButton
	Static oGet
	Static oGroup
	Static oRadOpc
	Static oSay

	Private cAuxRun 	:= cLastRun
	Private lTrue 		:= .T.

	Private  nRadOpc := 1
	Private  cFunc 	:= Space(20)


	DEFINE MSDIALOG oJanela TITLE "New Dialog" FROM 000, 000  TO 150, 500 COLORS 0, 16777215 PIXEL

	@ 004, 003 GROUP oGroup TO 050, 147 PROMPT "Executa Fun็๕es " 		   									OF oJanela COLOR  0, 16777215 	PIXEL
	@ 023, 047 MSGET oGet VAR cFunc SIZE 094, 016 	PICTURE "@E"							   				OF oJanela COLORS 0, 16777215 	PIXEL
	@ 023, 007 RADIO oRadOpc VAR nRadOpc ITEMS "Usuario","Sistema" SIZE 031, 019 							OF oJanela COLOR  0, 16777215 	PIXEL
	@ 013, 003 SAY oSay PROMPT "Tipo Fun็ใo" 	SIZE 034, 007 												OF oJanela COLORS 0, 16777215 	PIXEL
	@ 013, 046 SAY oSay PROMPT "Fun็ใo" 		SIZE 021, 007 												OF oJanela COLORS 0, 16777215 	PIXEL

	fDBTree()

	@ 055, 004 BUTTON oButton PROMPT "Executa" 	ACTION (oJanela:End() , Executa()       ) SIZE 046,012	OF oJanela 				   		PIXEL
	@ 055, 099 BUTTON oButton PROMPT "Sair" 	ACTION (oJanela:End() , lContinua := .F.) SIZE 046,012	OF oJanela 				   		PIXEL

	ACTIVATE MSDIALOG oJanela CENTERED


Return()
*********************************************************************
Static Function fDBTree()
*********************************************************************
	Static oRunTree
	True 	:= .T.
	nCount 	:= 1

	oRunTree := DbTree():New(004,155,068,245,oJanela,,,.T.)//fDBTree()
	oRunTree:AddItem(PadR("Ultimas Exec",15," "),"001", "FOLDER5" ,,,,1)

	While lTrue

		nPos := At(',',cAuxRun)
		nCount	+= 1
		If nPos <= 0
			lTrue := .F.
			Loop
		Endif

		cAuxFunc	:= 	PadR(Substr(cAuxRun,1,nPos - 1),15," ")
		cAuxCont	:= 	StrZero(nCount,3)

		oRunTree:AddItem(cAuxFunc ,cAuxCont, "FOLDER6",,,,2)

		cAuxRun	:= Substr(cAuxRun,nPos + 1)

	EndDo

	oRunTree:EndTree()

Return()
*********************************************************************
Static Function Executa()
*********************************************************************
	cFunc :=  Alltrim(cFunc)

	If Empty(cFunc)
		cFunc := Alltrim(oRunTree:GetPrompt(.T.))
	EndIf

	If nRadOpc == 1
		cFunc :=  "U_" + cFunc
	EndIf

	If At("(",cFunc) <= 0
		cFunc := cFunc + "()"
	EndIF

	&cFunc.

	Alert( " Fim da Execu็ใo da Rotina "+ cFunc )

	AtuUltFun() //| Atualiza Ultimas Funcoes Executadas

Return()
*********************************************************************
Static Function AtuUltFun()
*********************************************************************
	nVir := 0
	nPos := At("U_", cFunc )
	If nPos > 0
		cFunc :=  Substr(cFunc,3)
	EndIf

	nPos := At("(",	cFunc )
	If nPos > 0
		cFunc := Substr(cFunc,1,nPos-1)
	EndIF

	nPos := At(cFunc, cLastRun )


	If nPos <= 0
		cLastRun := cFunc + "," + cLastRun
	Else
		cLastRun := cFunc+ "," + Substr(cLastRun,1,nPos - 1) + Substr(cLastRun,nPos + Len(cFunc) + 1)
	EndIf

	nPos := 0
	For N := 1 To Len(cLastRun)

		If Substr(cLastRun,N,1) == ","
			nVir += 1
		Endif

		If nVir == 11
			nPos := N
			Exit
		EndIf

	Next

	If nPos <> 0
		cLastRun := Substr(cLastRun,1,nPos - 1)
	EndIf

	cFunc := ""

Return()
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValTelCad บAutor  ณCristiano Machado   บ Data ณ  10/05/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Valida o Telefone do Cliente/Prospect                     บฑฑ
ฑฑบ          ณ  Nao pode conter apostrofo por causa da Nf-e.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
User Function ValTelCad()
*********************************************************************
	lVal := .F.

	If Alltrim(__ReadVar) $ ("M->A1_TEL/M->US_TEL")
		If AT("-",&__ReadVar.) > 0
			Iw_MsgBox("Por Favor, Nใo Utilizar Hifen (-) no Telefone .")
		Else
			lVal := .T.
		EndIf
	Else
		lVal := .T.
	EndIf

Return(lVal)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Mensagem บAutor  ณCristiano Machado   บ Data ณ  28/05/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta Janala com botoes e/ou get.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cCaption   	:Titulo da Janela                             บฑฑ
ฑฑบ          ณ cSubTit  	:Sub Titulo da Janela                         บฑฑ
ฑฑบ          ณ cMensagem  	:Texto da Janela (400 caracteres)             บฑฑ
ฑฑบ          ณ aBotoes    	:Array com titulo dos botoes  ( Max.5 )       บฑฑ
ฑฑบ          ณ xGet			:Valor Padaro do Get                          บฑฑ
ฑฑบ          ณ cValida		:Validacao para o Get                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*********************************************************************
User Function Men(cCaption, cSubTit, cMensagem, aBotoes, xGet, lAut)
*********************************************************************
	Local ny        := 0//                   W - COMPRIMENTO | H - ALTURA
	Local nx        := 0// Lf  Cf            W  H    LB    g
	Local aSize  := {  	{144,304, 35,155, 35,113, 61  , 37},;  	// Tamanho 1
	{144,450, 35,155, 35,185, 61  , 47},; 		// Tamanho 2
	{237,450, 35,210, 65,185, 100 , 67} } 		// Tamanho 3

	Local nLinha    := 0
	Local cMsgButton:= ""
	Local oGet

	Private oGet
	Private mGet
	Private bGet
	Private lGet := .F.

	Private oTButton1
	Private oTButton2
	Private oTButton3
	Private oTButton4
	Private oTButton5

	Private cBotao := ""
	Private oDlgAviso
	Private nOpc := 0

	If lAut == Nil
		lAut := .F.
	EndIf

	If xGet <> Nil
		Do Case
		Case ValType(xGet) == "C"
			mGet := "@!"
		Case ValType(xGet) == "N"
			mGet := "@E 999,999,999.99"
		Case ValType(xGet) == "D"
			mGet := "@"
		EndCase

		lGet := .T.
	EndIf


//ณ Verifica o numero de botoes Max. 5 e o tamanho da Msg.       ณ
	If aBotoes <> Nil
		If  Len(aBotoes) > 3
			If Len(cMensagem) > 286
				nSize := 3
			Else
				nSize := 2
			EndIf
		Else
			Do Case
			Case Len(cMensagem) > 170 .And. Len(cMensagem) < 250
				nSize := 2
			Case Len(cMensagem) >= 250
				nSize := 3
			OtherWise
				nSize := 1
			EndCase
		EndIf
	Else
		nSize := 1
	EndIf


	If nSize <= 3
		nLinha := nSize
	Else
		nLinha := 3
	EndIf

//| Monta Janela

	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

	DEFINE MSDIALOG oDlgAviso FROM 0,0 TO aSize[nLinha][1],aSize[nLinha][2] TITLE cCaption STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) Of oMainWnd PIXEL

	@ 0, 0 BITMAP RESNAME "LOGIN" oF oDlgAviso SIZE aSize[nSize][3],aSize[nSize][4] NOBORDER WHEN .F. PIXEL ADJUST .T.
	@ 3  ,37  SAY cSubTit Of oDlgAviso PIXEL SIZE 130 ,9 FONT oBold
	@ 11 ,35  TO 13 ,400 LABEL '' OF oDlgAviso PIXEL

	If nSize <= 3
		@ 16 ,38  SAY cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5]
	Else
		@ 16 ,38  SAY cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5]
	//	@ 16 ,38  GET oGet VAR cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5] READONLY MEMO
	EndIf


	If lGet
		If nSize <= 2
			nCol := 65
		else
			nCol := 95
		Endif

		@ aSize[nLinha][8], nCol MSGET xGet PICTURE mGet SIZE 040, 	010 OF oDlgAviso COLORS 0, 16777215 PIXEL Valid( .T. )

	EndIf


//If aBotoes <> Nil

//	If Len(aBotoes) > 1
//		TButton():New(1000,1000," ",oDlgAviso,{||Nil},32,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
//	EndIf

//EndIf

	ny := (aSize[nLinha][2]/2)-36

	If aBotoes <> Nil

//	 For nx := Len(aBotoes) To 1 Step -1
		For nx := 1 TO Len(aBotoes)
			cMsgButton	:= OemToAnsi(AllTrim(aBotoes[nx]))
			cMsgButton	:= IF( ( "&" $ SubStr( cMsgButton , 1 , 1 ) ) , cMsgButton , ( "&"+cMsgButton ) )

			Do Case
			Case nx == 1
				@ aSize[nLinha][7], ny BUTTON oTButton1 PROMPT cMsgButton SIZE 32, 10 OF oDlgAviso Action {|| nOpc:=1 , oDlgAviso:end()} PIXEL

			Case nx == 2
				@ aSize[nLinha][7], ny BUTTON oTButton2 PROMPT cMsgButton SIZE 32, 10 OF oDlgAviso Action {|| nOpc:=2 , oDlgAviso:end()} PIXEL

			Case nx == 3
				@ aSize[nLinha][7], ny BUTTON oTButton3 PROMPT cMsgButton SIZE 32, 10 OF oDlgAviso Action {|| nOpc:=3 , oDlgAviso:end()} PIXEL

			Case nx == 4
				@ aSize[nLinha][7], ny BUTTON oTButton4 PROMPT cMsgButton SIZE 32, 10 OF oDlgAviso Action {|| nOpc:=4 , oDlgAviso:end()} PIXEL

			Case nx == 5
				@ aSize[nLinha][7], ny BUTTON oTButton5 PROMPT cMsgButton SIZE 32, 10 OF oDlgAviso Action {|| nOpc:=5 , oDlgAviso:end()} PIXEL
			EndCase
			ny -= 35
		Next

	EndIf

	Activate MsDialog oDlgAviso Centered

Return ( { nOpc , If(lGet,xGet,Nil) } )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLIBRARY   บAutor  ณEdivaldo Gonsalves  บ Data ณ  06/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna as filiais que operam com estoque.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ|Q|- Se quiser Utilizar na Clausula IN da Query             บฑฑ
ฑฑบParametro ณ|A|- Se quiser receber Array                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*********************************************************************
User Function cRetFils(cTipo,cMV_Nome,lExcOrInc) //|Parametro:( |Q|-Se quiser Utilizar na Clausula IN da Query, |A|- se quiser receber Arrey )
*********************************************************************

	Local cFilNoEst	:= "" //GetMV('MV_FILSEST')
	Local cFiliais 	:= ""
	Local aFiliais 	:= {}
	Local nRecSM0

	DeFault cTipo 		:= "Q"
	Default cMV_Nome		:= "MV_FILSEST"
	Default lExcOrInc	:= .F. /// .T. -> Inclui apenas Filiais contidas no Parametro ou .F. -> Exclui Filiais contidas no Parametro

	cFilNoEst				:= GetMV(cMV_Nome)

	DbSelectArea("SM0")
	nRecSM0 := Recno()

	DbSeek(cEmpAnt,.F.)


	Do While SM0->M0_CODIGO == cEmpAnt

		If lExcOrInc
			If !SM0->M0_CODFIL $ cFilNoEst
				dbSkip()
				Loop
			Endif
		Else
			If SM0->M0_CODFIL $ cFilNoEst
				dbSkip()
				Loop
			Endif
		EndIF

		If cTipo == "Q"
			cFiliais += "'" + SM0->M0_CODFIL + "',"
		ElseIf cTipo == "A"
			Aadd(aFiliais,{M0_CODFIL,Tabela("Z3",M0_CODFIL,.F.)})
		EndIf

		DbSkip()
	EndDo

	If  cTipo == "Q"
		xRetorno := Left(cFiliais,Len(cFiliais)-1)
	ElseIf cTipo == "A"
		xRetorno := aFiliais
	Else
		xRetorno := ""
	EndIf

	DbGoto(nRecSM0)

Return (xRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFileCopy  บAutor  ณCristiano Machado   บ Data ณ  06/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Efetua a Copia de arquivos do Server para a pasta Temp do  บฑฑ
ฑฑบ          ณ Windows.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ|cArquivo|- Informar o nome do Arquivo.                [Obr]บฑฑ
ฑฑบ          ณ|cDirServ|- Especificar o diretorio no Server.              บฑฑ
ฑฑบ          ณ            Padrao: \arquivos\                         [Opc]บฑฑ
ฑฑบ          ณ|lOpen|	- [.T.,.F.] Se deve abrir arquivo apos copia.[Opc]บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ|Caracter|- Caminho completo do arquivo ap๓s c๓pia ou "Erro"บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*********************************************************************
User Function FileCopy(cArquivo,cDirServ,lOpen)
*********************************************************************
	Local 	cDirTem		:= GetTempPath()
	Local 	lCopied		:= .F.
	Local 	cDrive 		:= "" //| Resultado: "c:"
	Local 	cDir   		:= "" //| Resultado: "\path\"
	Local 	cNome  		:= "" //| Resultado: "arquivo"
	Local 	cExt		:= ""
	Local 	cLArqServer	:= ""
	Local 	cLArqClient	:= ""

	Default cDirServ 	:= "\arquivos\"
	Default	lOpen		:= .F.

	cLArqServer	:= cDirServ + cArquivo //| Local + nome arquivo no Servidor
	cLArqClient	:= cDirTem  + cArquivo //| Local + Nome Arquivo na Maquina Cliente pasta Temp do Windows

	If Empty(cArquivo)
		IW_MsgBox("Aten็ใo","Parametro obrigat๓rio nใo Informado [cArquivo] Fun็ใo: U_FileCopy(cArquivo) !","ALERT")
		Return("Erro")
	EndIf

	lCopied := CpyS2T( cLArqServer, cDirTem, .T. )

	If !lCopied
		IW_MsgBox(" O Arquivo nใo foi copiado ! "+_ENTER+"Origem: "+cLArqServer+_ENTER+" Destino : "+cDirTem+_ENTER,"Aten็ใo","ALERT")
		Return("Erro")
	EndIF

	If lOpen

		SplitPath(cLArqClient, @cDrive, @cDir, @cNome ,@cExt)

		cDir := StrTran(cDir,"/","\")

		nRet := ShellExecute("Open",cArquivo,"",cDrive+cDir, 1 )

	Endif


Return(cLArqClient)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFTIMETO   บAutor  ณCRISTIANO MACHADO   บ Data ณ  04/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna Diferen็a entre 2 Tempos em formato Hora ou        บฑฑ
ฑฑบ          ณ Segundos e Converte Hora para Segundo ou Segundo para Hora บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso.   1- ณ Se vc quiser Retorno em SN - Segundos Numero passar o TimeIบฑฑ
ฑฑบ          ณ e TimeF em formato Time() - Caracter                       บฑฑ
ฑฑบ       2- ณ Se vc quiser Retorno em HC - Horas Caracter passar o TimeI บฑฑ
ฑฑบ          ณ e TimeF em formato segundos numericos                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*********************************************************************
User Function FTimeTo(TimeI,TimeF,cTipo)// Retorno = SN - Segundos formato Numerico ou HC - Hora Formato Caracter
*********************************************************************
	Local Hora
	Local Min
	Local Seg
	Local TimeAux
	Local Retorno

	Default cTipo := "SN"
	Default TimeI := 0
	Default TimeF := 0

	If cTipo == "SN"  // Segundos Formato Numero

		If !Empty(TimeI) .And. !Empty(TimeF)
			TimeAux := ElapTime(TimeI,TimeF)
		ElseIf !Empty(TimeI)
			TimeAux := TimeI
		Else
			TimeAux := "00:00:00"
		EndIf

		Hora := Val(Substr(TimeAux,1,2)) * 3600
		Min  := Val(Substr(TimeAux,4,2)) * 60
		Seg  := Val(Substr(TimeAux,7,2))

		Retorno := Hora + Min + Seg

	ElseIf cTipo == "HC" // Hora Formato Caracter

		If TimeI <> 0 .And. TimeF <> 0
			TimeAux := TimeF - TimeI
		ElseIf TimeI <> 0
			TimeAux := TimeI
		Else
			TimeAux := 0
		EndIf

		Hora := Int(   TimeAux / 3600)
		Min  := Int((  TimeAux - Hora * 3600 ) / 60 )
		Seg  := Int((  TimeAux - Hora * 3600 - Min * 60) )

		Retorno := StrZero(Hora,2) + ":" + StrZero(Min,2) + ":" + StrZero(Seg,2)

	EndIf

Return(Retorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoadBmp   บAutor  ณCristiano Machado   บ Data ณ  08/22/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para visualizar as imagens do RPO                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

********************************************************************
User Function LoadBMP()
********************************************************************

	Local oGet
	Local 	oGroup

	Private cGet 		:= "Imagem"
	Private lExiste 		:= .F.
	Private aFontes 		:= {}
	Private nListBox 	:= 0
	Private aItens 		:= {}

	Static 	oImagem
	Static 	oDlg

	Carrega_itens()

	DEFINE MSDIALOG oDlg TITLE "New Dialog" FROM 000, 000  TO 350, 400 COLORS 0, 16777215 PIXEL

	oListBox := TListBox():New(017,010,{|u| if(Pcount()>0,nListBox := u, nListBox )},aItens,100,150,{||Ver()},oDlg,,,,.T.)

	oImagem := TBitmap():New(34,122,50,50,,/*aItens[nListBox]*/,.T.,oDlg,,,.F.,.F.,,,.F.,,.T.,,.F.)

	@ 017, 110 GROUP oGroup TO 200, 100 PROMPT "Imagem RPO" OF oDlg COLOR 0, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return ""
********************************************************************
Static Function Carrega_itens()
********************************************************************
	Local nFile := 0
	Local cLine := ""

	nFile := FT_FUse("\system\imagens.txt")

	If nFile == -1
		Return
	Endif

	FT_FGoTop()
	While !FT_FEOF()

		cLine  := FT_FReadLn()

		aAdd(aItens,cLine)

		FT_FSkip()

	EndDo


Return
********************************************************************
Static Function Ver()
********************************************************************
	oImagem:SetFocus()
	oImagem:SetEmpty()
	oImagem:Load ( aItens[nListBox], aItens[nListBox] )

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoadBmp   บAutor  ณCristiano Machado   บ Data ณ  08/22/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que cria tabela local..                            	บฑฑ
ฑฑบ          ณ                                                           	บฑฑ
ฑฑบ          ณ aStruFile		-> 	Extrutura Padrao para Campos da tabela 		บฑฑ
ฑฑบ          ณ Ex.: = {	{ "FILIAL" , "C",  2, 0	},{	"TOTAL" , "N", 12, 0	}}บฑฑ
ฑฑบ          ณ                                                           	บฑฑ
ฑฑบ          ณ [aStruIndex]	-> 	Extrutura contendo os indices desejados.. 	บฑฑ
ฑฑบ          ณ                  caso nao informado nao cria indices...   	บฑฑ
ฑฑบ          ณ                  Ex.: = { "FILIAL+PERIODO","FILIAL+TOTAL" }บฑฑ
ฑฑบ          ณ                                                           	บฑฑ
ฑฑบ          ณ [cPath] 		-> 	NIl  system ou informar outro caminho   	  บฑฑ
ฑฑบ          ณ                  apartir do rootpath                      	บฑฑ
ฑฑบ          ณ                                                           	บฑฑ
ฑฑบ          ณ [cNameFile] 	-> 	Informar o Nome do arquivo   	             บฑฑ
ฑฑบ          ณ                                                           	บฑฑ
ฑฑบ          ณ [cAliasFile] -> 	Informar o Apelido que deve ser utilizado 	บฑฑ
ฑฑบ          ณ                  ou caso nao informar sera utilizado TAUX 	บฑฑ
ฑฑบ          ณ                                                           	บฑฑ
ฑฑบ          ณ [cDriver]		-> 	.T. Substitui o Arquivo caso j exista....	บฑฑ
ฑฑบ          ณ              		.F. Abre o arquivo caso exista...        	บฑฑ
ฑฑบ          ณ                                                           	บฑฑ
ฑฑบ          ณ [lReplace]		-> 	.T. Substitui o Arquivo caso j exista....	บฑฑ
ฑฑบ          ณ              		.F. Abre o arquivo caso exista...        	บฑฑ
ฑฑบ          ณ                                                           	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ cRetorno 		-> 	ALIAS do arquivo caso tenha sucesso na    	บฑฑ
ฑฑบ          ณ									criacao ou vazio em caso de erro...        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ Exemplos 		-> 	Nome do arquivo caso tenha sucesso na    	บฑฑ
ฑฑบ          ณ                                                 						บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
********************************************************************
User Function MyFile( aStruFile, aStruIndex, cPath, cNameFile, cAliasFile, cDriver, lReplace )
********************************************************************
	Local cFileFull		:= ""
	Local cFileExt			:= GetDbExtension()
	Local cRetorno			:= ""
	Local cIndexExt		:= ""
	Local cIndexFull		:= ""

	Default aStruFile	:= {}
	Default aStruIndex	:= {}
	Default cNameFile 	:= CriaTrab(,.f.)
	Default cPath 			:= "\system\"
	Default cAliasFile := "TAUX"
	Default cDriver		:= RealRDD()
	Default lReplace		:= .F.


	//| Preenche as Variaveis Vazias...
	If Len(aStruFile) < 1
		Return(cRetorno)
	EndIf
	If Empty(cNameFile)
		cNameFile 	:= CriaTrab(,.f.)
	EndIf
	If Empty(cPath)
		cPath 			:= "\system\"
	EndIf
	If Empty(cAliasFile)
		cAliasFile := "TAUX"
	EndIf
	If Empty(cDriver)
		cDriver		:= RealRDD()
	EndIf

	// Monta Caminho e nome do Arquivo Completo...
	cFileFull := Lower(cPath + cNameFile)

	// Monta Extensao do indice da Tabela...
	cIndexExt	:= IIf( At("CTREE",cDriver) > 0,".cdx",".idx")

	// Monta Caminho e nome do Arquivo Indice Completo...
	cIndexFull := Lower(cPath + cNameFile)

	// Varifica se alias alias esta aberto...
	If ( Select(cAliasFile) > 0 ) .And. lReplace

		DbSelectArea(cAliasFile)
		DbCloseArea(cAliasFile) //| Fecha Alias

	EndIf

	// Verifica se Arquivo existe...
	//If ( File( cFileFull ) )
	lExistFile := File( cFileFull + cFileExt)


	If lExistFile
		If lReplace
			If FErase(cFileFull + cFileExt)
				DbCreate( cFileFull, aStruFile, cDriver )


			Else
				Return()
			EndIf
		EndIf
	Else
		DbCreate( cFileFull, aStruFile, cDriver )
		lReplace := .T.

	EndIf

	//| Apaga o arquivo index...
	lExistIndex := File( cIndexFull + cIndexExt)

	If lReplace .And. lExistIndex



		FErase(cIndexFull + cIndexExt)
	EndIf


	// Cria o Alias de Trabalho...
	If ( Select(cAliasFile) <= 0 )
		DbUseArea( lReplace, cDriver	, cFileFull		, cAliasFile	, .T. 	,	.F.	)
	EndIf

	// Cria indices...
	If lReplace .Or. !lExistIndex


		For i := 1 To Len(aStruIndex)
			OrdCreate( cIndexFull , cValToChar(i), aStruIndex[i], { || aStruIndex[i] }, )
			lExistIndex := .T.
		Next

	EndIf

	//| Define o indice que deve ser usado... //| DBOI_ORDERCOUNT
	DbSelectArea(cAliasFile)

	IF lExistIndex

		DbSetIndex(cIndexFull)
	EndIf

	If ( Select(cAliasFile) > 0 )
		cRetorno := cAliasFile
		DbSelectArea(cAliasFile)
		DbGotop()

		lReplace := .F.

	EndIf

Return(cRetorno)
*******************************************************************************
User Function GetSx6(CPar,cFil,xConteudo)// Obtem Conteudo do Parametro SX6
*******************************************************************************
	Local cTipo 		:= ""
	Local aAreaSx6	:= SX6->(GetArea())
	Local lAchou 	:= .F.


	Default cFil 			:= cFilAnt
	Default cPar 			:= ''
	Default xConteudo 	:= ''

// Abre SX6... caso esteja fechado e ordena...
	If SELECT("SX6") == 0

		U_MyFile( {}, {}, '', 'SX6010', 'SX6', '', .F. )

		DbSelectarea("SX6")
		DbSetOrder(1)
	Else
		DbSelectarea("SX6")
		DbSetOrder(1)
	EndIf

// Pesquisa o Parametro e obtem o conteudo e tipo...
	If SX6->(DbSeek(Space(02) + cPar,.F.))
		xConteudo 	:= if(!Empty(Alltrim(X6_CONTEUD)),Alltrim(X6_CONTEUD),xConteudo)
		cTipo			:= Alltrim(X6_TIPO)
		lAchou			:= .T.
	ElseIf SX6->(DbSeek(cFil + cPar,.F.))
		xConteudo 	:= if(!Empty(Alltrim(X6_CONTEUD)),Alltrim(X6_CONTEUD),xConteudo)
		cTipo			:= Alltrim(X6_TIPO)
		lAchou			:= .T.
	ElseIf !Empty(cValToChar(xConteudo))
		Return(xConteudo)
	Else
		Return("X")
	EndIf

	//Converte o Conteudo para o Tipo....
	If ( lAchou )
		If cTipo == "C"
			Return(xConteudo)
		ElseIf cTipo == "N"
			Return(Val(xConteudo))
		ElseIf cTipo == "D"
			Return(SToD(xConteudo))
		ElseIf cTipo == "L"
			If At('T',xConteudo) > 0
				Return(.T.)
			Else
				Return(.F.)
			EndIf
		Else
			Return(xConteudo)
		EndIf
	EndIf


	RestArea(aAreaSx6)

Return('ERRO')
*******************************************************************************
User Function TabToArray(_cAlias, _lHeader )// Joga o conteudo da tabela em array...
*******************************************************************************

	Local aStru 			:= {}
	Local aAux				:= {}
	Local aVaz				:= {}
	Local aRet				:= {}
	Local aLine			:= {}
	Static CAMPO			:= 1

	Default _cAlias 	:= ""
	Default _lHeader := .F.

	_cAlias := Alltrim( _cAlias )

// Obtem Estrutura da Tabela...
	DbSelectArea(_cAlias)
	aStru := DbStruct()

// Cria Array s— com nome dos campos que compoe a tabela
	For i:= 1 To Len(aStru)

		Aadd( aAux, aStru[i][CAMPO] )

	Next

	If _lHeader
		aadd( aRet , aAux )
	EndIf

	lPri := .T.
	DbSelectArea(_cAlias);DbGotop()
	While !Eof()

		aLine := {}
		aEval( aAux, { |aCampo| cCampo := _cAlias+"->"+Alltrim(aCampo) , Aadd( aLine, cValToChar(&cCampo.) ) } )

		aadd( aRet ,  aLine  )

		DbSelectArea(_cAlias)
		DbSkip()

	EndDo


	// Caso a tabela esteja vazia... cria uma linha vazia no array
	If ( Len(aRet) == 0 )

		aLine := {}
		For i := 1 To Len(aStru)

			If ( aStru[i][2] == "N" )
				cConteudo := 0
			ElseIf ( aStru[i][2] == "B" )
				cConteudo := .F.
			ElseIf ( aStru[i][2] == "D" )
				cConteudo := CToD("  /  /  ")
			Else
				cConteudo := Space(aStru[i][3])
			EndIf

			Aadd( aLine, cConteudo )

		Next

		aadd( aRet ,  aLine  )

	EndIf


Return ( aRet )
*******************************************************************************
User Function XToC(xVar) // Converte Qualquer Tipo de Variavel para Caracter
*******************************************************************************

Return(Alltrim(cValToChar(xVar)))


//|Funcao	: ArrayToCsv -> Converte um Array em Arquivo texto tipo .CSV
//|Autor		: Cristiano Machado												Data: 02/12/2104
//|
//|Parametros:
//|		aArray				: Array contendo os dados (Obrigatorio)
//|		cNameFile 		: Nome do Arquivo [Opcional] Padrao: Aleat—rio
//|		cDelimitador	: Operador que ser utilizado como delimitador de campos [Opcional].. Padrao: ";"
//|
//|Retorno: Nome do Arquivo Criado... com caminho completo...e extensao...

*******************************************************************************
User Function ArrayToCsv( aArray , cNameFile, cDelimitador )
*******************************************************************************
	Local aHeader				:= {}
	Local nHandle				:= {}
	Local cExt						:= ".csv"
	Local cLin						:= ""
	Local aArrLin				:= {}

	Static  POSCAB				:= 1

	Default	aArray				:=	 {}
	Default 	cNameFile 		:= LOWER(CriaTrab(,.f.))
	Default	cDelimitador	:= ";"

	If Len( aArray ) == 0
		Return("")
	EndIf

	nHandle	:= FCreate ( "\"+cNameFile+cExt, FC_NORMAL , Nil , .T. )

	For nLin := 1 To Len(aArray)

		aArrLin := aArray[nLin]

		For nCol := 1 To Len(aArrLin)

			cLin += U_xToC(aArrLin[nCol]) + cDelimitador

		Next
		cLin += _ENTER

		FWrite ( nHandle, cLin, Len(cLin) )

		cLin := ""

	Next

	FClose( nHandle )


Return(cNameFile + cExt)
*********************************************************************
User Function ObjTela(oTela, cTipo, oObj, aMonta )
*********************************************************************
	Local nIndex := 1
	Local nDados := 2

	if cTipo == "GET"

		oGet_Banco	:= TGet():Create(oTela)

		For n := 1 To Len(aMonta)
			Do Case
			Case aMonta[i][nIndex] == GET_VALOR
				oGet_Banco:bSetGet			:= aMonta[GET_VALOR][nDados]	//| {|u| if(Pcount()>0,cGet_Banco:=u,cGet_Banco)}
			Case aMonta[i][nIndex] == GET_LIN
				oGet_Banco:nTop				:= aMonta[GET_LIN]					//| 18
			Case aMonta[i][nIndex] == GET_COL
				oGet_Banco:nLeft				:= aMonta[GET_COL]					//| 35
			Case aMonta[i][nIndex] == GET_COMPRIMENTO
				oGet_Banco:nWidth			:= aMonta[GET_LARGURA]		//| 60
			Case aMonta[i][nIndex] == GET_ALTURA
				oGet_Banco:nHeight			:= aMonta[GET_ALTURA]				//| 20
			Case aMonta[i][nIndex] == GET_MASCARA
				oGet_Banco:Picture			:= aMonta[GET_MASCARA]				//| "@!"
			Case aMonta[i][nIndex] == GET_VALIDACAO
				oGet_Banco:bValid			:= aMonta[GET_VALIDACAO]			//| {||}
			Case aMonta[i][nIndex] == GET_F3
				oGet_Banco:cf3					:= aMonta[GET_F3]						//| "SA6"
			Case aMonta[i][nIndex] == GET_ONDE
				oGet_Banco:bWhen 			:= aMonta[GET_ONDE]					//| {||}
			Case aMonta[i][nIndex] == GET_ALTERACAO
				oGet_Banco:bChange			:= aMonta[GET_ALTERACAO]			//| {||}
			Case aMonta[i][nIndex] == GET_LEITURA
				oGet_Banco:lReadOnly 		:= aMonta[GET_LEITURA]				//| .F.
			Case aMonta[i][nIndex] == GET_SENHA
				oGet_Banco:lPassword 		:= aMonta[GET_SENHA]				//| .F.
			Case aMonta[i][nIndex] == GET_VAR
				oGet_Banco:cReadVar 		:= aMonta[GET_VAR]					//| cGet_Banco
			Case aMonta[i][nIndex] == GET_ATIVO
				oGet_Banco:lActive 			:= aMonta[GET_ATIVO]				//| .T.
			Case aMonta[i][nIndex] == GET_TITULO
				oGet_Banco:cTitle			:= aMonta[GET_TITULO]				//| ""

			EndCase

		Next

	EndIf

Return(oObj)


*********************************************************************
User Function Date_Time_UTC(_UF) // Retorna Data e Hora no Formato UTC ( AAAA-MM-DDTHH-MM-SSTZD NFE 3.0)
*********************************************************************
	Local cZonaHServer 	:= ""
	Local cZonaHFilial 	:= ""
	Local cTimeHLocal		:= ""
	Local dData			:= dDatabase

	Private cTimeZero		:= "00:00:00"
	Private nTimeZero		:= 0

	//| Hora Zona do Servidor Oracle
	cZonaHServer := Server_Obtem_Zona()

	//| Hora Zona da Filial Aplicacao Protheus
	cZonaHFilial := AllTrim(Filial_Obtem_Zona(_UF))

	// Retorna a Data e Hora no Local na UF ... Corrigindo a Diferenca entre Servidores e de acordo com Horario na UF...
	cTimeHLocal := AllTrim(GMT_Obtem_Hora(cZonaHServer, cZonaHFilial, @dData))






Return( ALLTRIM(Left(dToS(dData),4)+"-"+Substr(dToS(dData),5,2)+"-"+Right(dToS(dData),2)+"T"+ cTimeHLocal + cZonaHFilial) )
*********************************************************************
Static Function GMT_Obtem_Hora(cZonaHServer, cZonaHFilial, dData)// Retorna a Data e Hora no Local na UF ... Corrigindo a Diferenca entre Servidores e de acordo com Horario na UF...
*********************************************************************

	Local nSegundos 		:= 0
	Local nZServXSeg 		:= cHtoN(cZonaHServer) 	* SEG_EM_HORA
	Local nZFiliXSeg		:= cHtoN(cZonaHFilial) 	* SEG_EM_HORA
	Local nZLocXSeg		:= nZServXSeg - nZFiliXSeg

//alert('nZLocXSeg:'+cvaltochar(nZLocXSeg))
	nSegundos := U_FTimeTO(cTimeZero,TIME(),'SN')

	If (nZLocXSeg == 0 )

		nSegundos	:= U_FTimeTO(cTimeZero,TIME(),'SN')

	elseIf (nSegundos - nZLocXSeg) < 0
		dData := dData - 1
		nSegundos := ( 23 * SEG_EM_HORA ) - (nSegundos - nZLocXSeg)

	Else
		nSegundos := ( nSegundos - nZLocXSeg )

	EndIf

//alert('nSegundos:'+cvaltochar(nSegundos))

Return( U_FTimeTo(nSegundos,nTimeZero,"HC") )
*********************************************************************
Static Function Filial_Obtem_Zona(_UF)//| Hora Zona da Filial Aplicacao Protheus
*********************************************************************

	Local cUF := _UF
	Local cZona := ""

	Default cUf := SM0->M0_ESTENT

	If cUf $ ('DF/ES/GO/MG/PR/RJ/RS/SC/SP/TO') // BRASILIA COM VERAO = -3:00 OU -2:00 TZ_OFFSET('America/Sao_Paulo')
		cZona := "'America/Sao_Paulo'"

	ElseIf cUf $ ('AL/AP/BA/CE/MA/PA/PB/PE/PI/RN/RO/SE') // BRASILIA SEM VERAO = -3:00 TZ_OFFSET('America/Recife')
		cZona := "'America/Recife'"

	ElseIf cUf $ ('MT/MS') // AMAZONIA COM VERAO = -3:00 TZ_OFFSET('America/Araguaina'))
		cZona := "'America/Araguaina'"

	ElseIf cUf $ ('AC/AM/RR') // AMAZONIA SEM VERAO = -4:00 TZ_OFFSET('Brazil/West')
		cZona := "'Brazil/West'"

	EndIf

Return( Server_Obtem_Zona(cZona) )
*********************************************************************
Static Function Server_Obtem_Zona(_TMZ)//| Hora Zona do Servidor Oracle
*********************************************************************
	Local cTimeZona := _TMZ

	Default cTimeZona := "SESSIONTIMEZONE"

	If Select("_TZS") <> 0
		DbCloseArea("_TZS")
	EndIf

	U_ExecMySql("SELECT TZ_OFFSET("+cTimeZona+") TIME FROM DUAL","_TZS","Q",.F.)

Return(_TZS->TIME)
*********************************************************************
Static Function cHtoN(cHZona) /// Converte Hora em Numero exemplo:  '-02:00' em -2
*********************************************************************
	Local cSinal := Substr(cHZona,1,1)
	Local nHora	:= Val(Substr(cHZona,2,2))

	If cSinal == '-'
		nHora := nHora * -1
	EndIf

Return(nHora)

*********************************************************************
User Function CCToP(cCampo)
*********************************************************************
Local cCampoSUS := ''

If ValType(lProspect) <> 'U'
	If lProspect .And. Substr(cCampo,1,3) == "SA1"

	cCampoSUS := 'SUS->US_' + Substr(cCampo , 9 , Len(Alltrim(cCampo))-8)

	Return(&cCampoSUS.)

	EndIf
Endif

Return(&cCampo.)

/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Fun็ใo: ConvA1toUS    || Autor: Edivaldo Gon็alves     || Data: 24/06/16||
||-------------------------------------------------------------------------||
|| Descri็ใo: Tratamento de Prospect para rotina que atribui a TES         ||
||            Troca o Alias de SA1 para SUS        					       ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ*/

User Function ConvA1toUS(cTabCamp)
Local _cCampo      :=  "US_"+ Substr(cTabCamp ,9 , Len(Alltrim(cTabCamp)))
local cNewTabCamp  :=  "SUS->"+_cCampo

If FunName()=='TMKA271' //Valido somente para o Televendas (Defini็ใo de TES na Venda)
  If (lProspect .AND. Substr(cTabCamp,1,3) == "SA1")
    dbSelectArea('SX3')
    SX3->( dbSetOrder(2) )

      ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //Inserido por Edivaldo Goncalves | Se existir o campo no ALIAS do SUS , retorna o Novo Alias e Campo para tratamento correto da TES //
      ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    If SX3->( dbSeek( _cCampo) )
       //Se o campo Existir retorno a Novo Alias e Campo
       cTabCamp:=cNewTabCamp
    Endif

  Endif
Endif

Return(&cTabCamp.)
/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNฬO   : MostraTxt    | AUTOR : Cristiano Machado  | DATA : 07/10/2015   **
**---------------------------------------------------------------------------**
** DESCRIฬO:  Apresenta Memo editavel com Texto recebido via Parametro      **
**          :                                                                **
**---------------------------------------------------------------------------**
** USO      : Funcao de Propriedade CSM                                      **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
**                 |          |                                              **
**                 |          |                                              **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function ArrayToFCsv( aArray , cPath, cNameFile, cDelimitador )
*******************************************************************************
	Local aHeader				:= {}
	Local nHandle				:= {}
	Local cExt					:= ".csv"
	Local cLin					:= ""
	Local aArrLin				:= {}
	Static  POSCAB				:= 1
	
	Default	aArray				:=	 {}
	Default cNameFile 			:= LOWER(CriaTrab(,.f.))
	Default	cDelimitador		:= ";"
	Default	cPath				:= "\"
	
	If Len( aArray ) == 0
		Return("")
	EndIf
	
	nHandle	:= FCreate ( cPath+cNameFile+cExt, FC_NORMAL , Nil , .T. )
	For nLin := 1 To Len(aArray)
		aArrLin := aArray[nLin]
		For nCol := 1 To Len(aArrLin)
			cLin += U_xToC(aArrLin[nCol]) + cDelimitador
		Next
		cLin += _ENTER
		FWrite ( nHandle, cLin, Len(cLin) )
		cLin := ""
	Next
	
	FClose( nHandle )
	
Return(cPath+cNameFile+cExt)