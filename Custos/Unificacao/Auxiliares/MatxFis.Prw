#INCLUDE "MATXFIS.CH"
#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ MATXFIS  ³ Autor ³ Eduardo / Edson       ³ Data ³08.12.1999	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Calculo de Impostos Fiscais e Financeiros      	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Thiago H.    ³06/06/06³100256³ Correcao dos calculos de descontos       ³±±
±±³              ³        ³      ³ quando a item escolhido na venda contem  ³±±
±±³              ³        ³      ³ Deducao de ICMS cadastrado no TES.       ³±±
±±³              ³        ³      ³ Estava sendo retirado a Deducao de ICMS  ³±±
±±³              ³        ³      ³ duas vezes.                              ³±±
±±³              ³        ³      ³ Alterada a funcao MaFisBSICM()           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#DEFINE NF_TIPONF		01    //Tipo : N , I , C , P
#DEFINE NF_OPERNF		02    //E-Entrada | S - Saida
#DEFINE NF_CLIFOR		03    //C-Cliente | F - Fornecedor
#DEFINE NF_TPCLIFOR 	04    //Tipo do destinatario R,F,S,X
#DEFINE NF_LINSCR		05    //Indica se o destino possui inscricao estadual
#DEFINE NF_GRPCLI		06    //Grupo de Tributacao
#DEFINE NF_UFDEST		07    //UF do Destinatario
#DEFINE NF_UFORIGEM	    08    //UF de Origem
#DEFINE NF_DESCONTO	    10    //Valor Total do Deconto
#DEFINE NF_FRETE		11    //Valor Total do Frete
#DEFINE NF_DESPESA	    12    //Valor Total das Despesas Acessorias
#DEFINE NF_SEGURO		13    //Valor Total do Seguro
#DEFINE NF_AUTONOMO 	14    //Valor Total do Frete Autonomo
#DEFINE NF_ICMS		    15    //Array contendo os valores de ICMS
#DEFINE NF_BASEICM	    15,01 //Valor da Base de ICMS
#DEFINE NF_VALICM		15,02 //Valor do ICMS Normal
#DEFINE NF_BASESOL	    15,03 //Base do ICMS Solidario
#DEFINE NF_VALSOL		15,04 //Valor do ICMS Solidario
#DEFINE NF_BICMORI	    15,05 //Base do ICMS Original
#DEFINE NF_VALCMP		15,06 //Valor do Icms Complementar
#DEFINE NF_BASEICA	    15,07 //Base do ICMS sobre o Frete Autonomo
#DEFINE NF_VALICA 	    15,08 //Valor do ICMS sobre o Frete Autonomo
#DEFINE NF_RECFAUT	    15,09 //1-Emitente, 2-Transportador
#DEFINE NF_IPI  		16    //Array contendo os valores de IPI
#DEFINE NF_BASEIPI	    16,01 //Valor da Base do IPI
#DEFINE NF_VALIPI		16,02 //Valor do IPI
#DEFINE NF_BIPIORI	    16,03 //Valor da Base Original do IPI
#DEFINE NF_TOTAL		17    //Valor Total da NF
#DEFINE NF_VALMERC	    18    //Total de Mercadorias
#DEFINE NF_FUNRURAL 	19	   //Valor Total do FunRural
#DEFINE NF_CODCLIFOR	20    //Codigo do Cliente/Fornecedor
#DEFINE NF_LOJA		    21	  //Loja do Cliente/Fornecedor
#DEFINE NF_LIVRO		22    //Array contendo o Demonstrativo Fiscal
#DEFINE NF_ISS			23	  //Array contendo os Valores de ISS
#DEFINE NF_BASEISS	    23,01 //Base de Calculo do ISS
#DEFINE NF_VALISS		23,02 //Valor do ISS
#DEFINE NF_IR			24    //Array contendo os valores do Imposto de renda
#DEFINE NF_BASEIRR	    24,01 //Base do Imposto de Renda do item
#DEFINE NF_VALIRR		24,02 //Valor do IR do item
#DEFINE NF_INSS		    25    //Array contendo os valores de INSS
#DEFINE NF_BASEINS	    25,01 //Base de calculo do INSS
#DEFINE NF_VALINS		25,02 //Valor do INSS do item
#DEFINE NF_NATUREZA		26	   //Codigo da natureza a ser gravado nos titulos do Financeiro.
#DEFINE NF_VALEMB		27	   //Valor da Embalagem
#DEFINE NF_RESERV1	    28	   //Array contendo as Bases de Impostos ( Argentina,Chile,Etc.)
#DEFINE NF_RESERV2	    29	   //Array contendo os valores de Impostos ( Argentina,Chile,Etc. )
#DEFINE NF_IMPOSTOS		30	   //Array contendo todos os impostos calculados na funcao Fiscal com quebra por impostos+aliquotas
#DEFINE NF_BASEDUP		31	  	//Base de calculo das duplicatas geradas no financeiro
#DEFINE NF_RELIMP		32	  	//Array contendo a relacao de impostos que podem ser alterados
#DEFINE NF_IMPOSTOS2	33	  //Array contendo todos os impostos calculados na funcao Fiscal com quebras por impostos
#DEFINE NF_DESCZF		34	  //Valor Total do desconto da Zona Franca
#DEFINE NF_SUFRAMA	    35	  // Indica se o Cliente pertence a SUFRAMA
#DEFINE NF_BASEIMP	    36	  //Array contendo as Bases de Impostos Variaveis
#DEFINE NF_BASEIV1	    36,01 //Base de Impostos Variaveis 1
#DEFINE NF_BASEIV2	    36,02 //Base de Impostos Variaveis 2
#DEFINE NF_BASEIV3	    36,03 //Base de Impostos Variaveis 3
#DEFINE NF_BASEIV4	    36,04 //Base de Impostos Variaveis 4
#DEFINE NF_BASEIV5	    36,05 //Base de Impostos Variaveis 5
#DEFINE NF_BASEIV6	    36,06 //Base de Impostos Variaveis 6
#DEFINE NF_BASEIV7	    36,07 //Base de Impostos Variaveis 7
#DEFINE NF_BASEIV8	    36,08 //Base de Impostos Variaveis 8
#DEFINE NF_BASEIV9	    36,09 //Base de Impostos Variaveis 9
#DEFINE NF_VALIMP		37 	  //Array contendo os valores de Impostos Agentina/Chile/Etc.
#DEFINE NF_VALIV1		37,01 //Valor do Imposto Variavel 1
#DEFINE NF_VALIV2		37,02 //Valor do Imposto Variavel 2
#DEFINE NF_VALIV3		37,03 //Valor do Imposto Variavel 3
#DEFINE NF_VALIV4		37,04 //Valor do Imposto Variavel 4
#DEFINE NF_VALIV5		37,05 //Valor do Imposto Variavel 5
#DEFINE NF_VALIV6		37,06 //Valor do Imposto Variavel 6
#DEFINE NF_VALIV7		37,07 //Valor do Imposto Variavel 7
#DEFINE NF_VALIV8		37,08 //Valor do Imposto Variavel 8
#DEFINE NF_VALIV9		37,09 //Valor do Imposto Variavel 96
#DEFINE NF_TPCOMP		38    //Tipo de complemento  - F Frete , D Despesa Imp.
#DEFINE NF_INSIMP		39	  //Flag de Controle : Indica se podera inserir Impostos no Rodape.
#DEFINE NF_PESO  		40	  //Peso Total das mercadorias da NF
#DEFINE NF_ICMFRETE 	41	  //Valor do ICMS relativo ao frete
#DEFINE NF_BSFRETE 		42	  //Base do ICMS relativo ao frete
#DEFINE NF_BASECOF 		43	  //Base de calculo do COFINS
#DEFINE NF_VALCOF  		44	  //Valor do COFINS
#DEFINE NF_BASECSL 		45	  //Base de calculo do CSLL
#DEFINE NF_VALCSL 		46	  //Valor do CSLL
#DEFINE NF_BASEPIS 		47	  //Base de calculo do PIS
#DEFINE NF_VALPIS 		48	  //Valor do PIS
#DEFINE NF_ROTINA 		49	  //Nome da rotina que esta utilizando a funcao
#DEFINE NF_AUXACUM 		50	  //Campo auxiliar para acumulacao no calculo de impostos
#DEFINE NF_ALIQIR      51    //Aliquota de IRF do Cliente
#DEFINE NF_VNAGREG     52	  //Valor da Mercadoria nao agregada.
#DEFINE NF_RECPIS      53    //Recolhe PIS
#DEFINE NF_RECCOFI     54    //Recolhe CONFINS
#DEFINE NF_RECCSLL     55    //Recolhe CSLL
#DEFINE NF_RECISS      56    //Recolhe ISS
#DEFINE NF_RECINSS     57    //Recolhe INSS
#DEFINE NF_MOEDA       58    //Moeda da nota
#DEFINE NF_TXMOEDA     59    //Taxa da moeda
#DEFINE NF_SERIENF     60    //Serie da nota fiscal
#DEFINE NF_TIPODOC     61    //Tipo do documento (localizacoes)
#DEFINE NF_MINIMP      62    //Minimo para calcular Impostos Variaveis
#DEFINE NF_MINIV1      62,01 //Minimo para calcular Imposto Variavel 1
#DEFINE NF_MINIV2      62,02 //Minimo para calcular Imposto Variavel 2
#DEFINE NF_MINIV3      62,03 //Minimo para calcular Imposto Variavel 3
#DEFINE NF_MINIV4      62,04 //Minimo para calcular Imposto Variavel 4
#DEFINE NF_MINIV5      62,05 //Minimo para calcular Imposto Variavel 5
#DEFINE NF_MINIV6      62,06 //Minimo para calcular Imposto Variavel 6
#DEFINE NF_MINIV7      62,07 //Minimo para calcular Imposto Variavel 7
#DEFINE NF_MINIV8      62,08 //Minimo para calcular Imposto Variavel 8
#DEFINE NF_MINIV9      62,09 //Minimo para calcular Imposto Variavel 9
#DEFINE NF_BASEPS2     63	  //Base de calculo do PIS 2
#DEFINE NF_VALPS2      64	  //Valor do PIS 2
#DEFINE NF_ESPECIE     65	  //Especie do Documento
#DEFINE NF_CNPJ        66    //CNPJ/CPF
#DEFINE NF_BASECF2     67	  //Base de calculo do COFINS 2
#DEFINE NF_VALCF2      68	  //Valor do COFINS 2
#DEFINE NF_ICMSDIF     69    //Valor do ICMS diferido
#DEFINE NF_MODIRF      70    //Calculo do IRPF
#DEFINE NF_PNF_COD     71,01 //Codigo do pagador do documento fiscal
#DEFINE NF_PNF_LOJ     71,02 //Loja   do pagador do documento fiscal
#DEFINE NF_PNF_UF      71,03 //UF do pagador do documento fiscal
#DEFINE NF_PNF_TPCLIFOR 71,04//Tipo do pagador do documento fiscal
#DEFINE NF_CALCSUF	    72	  // Indica se cliente possui calculo suframa
#DEFINE NF_BASEAFRMM   73	  //Base de calculo do AFRMM ( Cabecalho )
#DEFINE NF_VALAFRMM    74	  //Valor do AFRMM ( Cabecalho )
#DEFINE NF_PIS252      75    // Decreto 252 de 15/06/2005 - Valor do PIS para retencao aquisicao a aquisicao - sem considerar R# 5.000,00 da Lei 10925
#DEFINE NF_COF252      76    // Decreto 252 de 15/06/2005 - Valor da COFINS para retencao aquisicao a aquisicao - sem considerar R# 5.000,00 da Lei 10925
#DEFINE NF_OPIRRF		77    // Indicacao de Orgao Publico para recolhimento de IRRF
#DEFINE NF_SEST        78	  //Array contendo os valores do SEST (Servico Social do Transporte)
#DEFINE NF_BASESES     78,01 //Base de calculo do SEST
#DEFINE NF_VALSES      78,02 //Valor do SEST
#DEFINE NF_RECSEST     79    //Recolhe SEST
#DEFINE NF_BASEPS3     80	  //Base de calculo do PIS Subst. Tributaria
#DEFINE NF_VALPS3      81	  //Valor do PIS Subst. Tributaria
#DEFINE NF_BASECF3     82	  //Base de calculo da COFINS Subst. Tributaria
#DEFINE NF_VALCF3      83	  //Valor da COFINS Subst. Tributaria
#DEFINE NF_VLR_FRT     84    //Valor Total do Frete de Pauta
#DEFINE NF_VALFET		85	  //Valor do FETHAB
#DEFINE NF_RECFET      86    //FETHAB
#DEFINE NF_CLIENT      87    //Codigo do cliente de entrega na nota fiscal de saida
#DEFINE NF_LOJENT      88    //Loja do cliente de entrega na nota fiscal de saida
#DEFINE NF_VALFDS      89    //Valor do Fundersul - Mato Grosso do Sul
#DEFINE IT_GRPTRIB  	01    //Grupo de Tributacao
#DEFINE IT_EXCECAO  	02    //Array da EXCECAO Fiscal
#DEFINE IT_ALIQICM	    03    //Aliquota de ICMS
#DEFINE IT_ICMS 		04    //Array contendo os valores de ICMS
#DEFINE IT_BASEICM  	04,01 //Valor da Base de ICMS
#DEFINE IT_VALICM		04,02 //Valor do ICMS Normal
#DEFINE IT_BASESOL	    04,03 //Base do ICMS Solidario
#DEFINE IT_ALIQSOL	    04,04 //Aliquota do ICMS Solidario
#DEFINE IT_VALSOL		04,05 //Valor do ICMS Solidario
#DEFINE IT_MARGEM		04,06 //Margem de lucro para calculo da Base do ICMS Sol.
#DEFINE IT_BICMORI	    04,07 //Valor original da Base de ICMS
#DEFINE IT_ALIQCMP	    04,08 //Aliquota para calculo do ICMS Complementar
#DEFINE IT_VALCMP		04,09 //Valor do ICMS Complementar do item
#DEFINE IT_BASEICA 	    04,10 //Base do ICMS sobre o frete autonomo
#DEFINE IT_VALICA  	    04,11 //Valor do ICMS sobre o frete autonomo
#DEFINE IT_DEDICM      04,12 //Valor do ICMS a ser deduzido
#DEFINE IT_VLCSOL		04,13 //Valor do ICMS Solidario calculado sem o credito aplicado
#DEFINE IT_PAUTIC       04,14 //Valor da Pauta do ICMS Proprio
#DEFINE IT_PAUTST       04,15 //Valor da Pauta do ICMS-ST
#DEFINE IT_PREDIC       04,16 //%Redução da Base do ICMS
#DEFINE IT_PREDST       04,17 //%Redução da Base do ICMS-ST
#DEFINE IT_MVACMP       04,18 //Margem do complementar
#DEFINE IT_PREDCMP      04,19 //%Redução da Base do ICMS-CMP
#DEFINE IT_ALIQIPI  	 05    //Aliquota de IPI
#DEFINE IT_IPI  		 06    //Array contendo os valores de IPI
#DEFINE IT_BASEIPI  	 06,01 //Valor da Base do IPI
#DEFINE IT_VALIPI		 06,02 //Valor do IPI
#DEFINE IT_BIPIORI      06,03 //Valor da Base Original do IPI
#DEFINE IT_PREDIPI      06,04 //%Redução da Base do IPI
#DEFINE IT_PAUTIPI      06,05 //Valor da Pauta do IPI
#DEFINE IT_NFORI		 07    //Numero da NF Original
#DEFINE IT_SERORI		 08    //Serie da NF Original
#DEFINE IT_RECORI		 09    //RecNo da NF Original (SD1/SD2)
#DEFINE IT_DESCONTO	 10    //Valor do Desconto
#DEFINE IT_FRETE		 11    //Valor do Frete
#DEFINE IT_DESPESA	 12    //Valor das Despesas Acessorias
#DEFINE IT_SEGURO		 13    //Valor do Seguro
#DEFINE IT_AUTONOMO 	 14    //Valor do Frete Autonomo
#DEFINE IT_VALMERC	 15    //Valor da mercadoria
#DEFINE IT_PRODUTO	 16    //Codigo do Produto
#DEFINE IT_TES			 17    //Codigo da TES
#DEFINE IT_TOTAL		 18    //Valor Total do Item
#DEFINE IT_CF			 19    //Codigo Fiscal de Operacao
#DEFINE IT_FUNRURAL	 20    //Aliquota para calculo do Funrural
#DEFINE IT_PERFUN		 21    //Valor do Funrural do item
#DEFINE IT_DELETED	 22    //Flag de controle para itens deletados
#DEFINE IT_LIVRO		 23    //Array contendo o Demonstrativo Fiscal do Item
#DEFINE IT_ISS			 24    //Array contendo os valores de ISS
#DEFINE IT_ALIQISS	     24,01 //Aliquota de ISS do item
#DEFINE IT_BASEISS  	 24,02 //Base de Calculo do ISS
#DEFINE IT_VALISS		 24,03 //Valor do ISS do item
#DEFINE IT_CODISS		 24,04 //Codigo do ISS
#DEFINE IT_CALCISS	     24,05 //Flag de controle para calculo do ISS
#DEFINE IT_RATEIOISS	 24,06 //Flag de controle para calculo do ISS
#DEFINE IT_CFPS     	 24,07 //Codigo Fiscal de Prestacao de Servico
#DEFINE IT_PREDISS  	 24,08 //Redução da base de calculo do ISS
#DEFINE IT_IR			 25    //Array contendo os valores do Imposto de renda
#DEFINE IT_BASEIRR	 25,01 //Base do Imposto de Renda do item
#DEFINE IT_REDIR		 25,02 //Percentual de Reducao da Base de calculo do IR
#DEFINE IT_ALIQIRR	 25,03 //Aliquota de Calculo do IR do Item
#DEFINE IT_VALIRR		 25,04 //Valor do IR do Item
#DEFINE IT_INSS		 26    //Array contendo os valores de INSS
#DEFINE IT_BASEINS	 26,01 //Base de calculo do INSS
#DEFINE IT_REDINSS	 26,02 //Percentual de Reducao da Base de Calculo do INSS
#DEFINE IT_ALIQINS	 26,03 //Aliquota de Calculo do INSS
#DEFINE IT_VALINS		 26,04 //Valor do INSS
#DEFINE IT_VALEMB		 27	 //Valor da embalagem
#DEFINE IT_BASEIMP	 28	 //Array contendo as Bases de Impostos Variaveis
#DEFINE IT_BASEIV1	 28,01 //Base de Impostos Variaveis 1
#DEFINE IT_BASEIV2	 28,02 //Base de Impostos Variaveis 2
#DEFINE IT_BASEIV3	 28,03 //Base de Impostos Variaveis 3
#DEFINE IT_BASEIV4	 28,04 //Base de Impostos Variaveis 4
#DEFINE IT_BASEIV5	 28,05 //Base de Impostos Variaveis 5
#DEFINE IT_BASEIV6	 28,06 //Base de Impostos Variaveis 6
#DEFINE IT_BASEIV7	 28,07 //Base de Impostos Variaveis 7
#DEFINE IT_BASEIV8	 28,08 //Base de Impostos Variaveis 8
#DEFINE IT_BASEIV9	 28,09 //Base de Impostos Variaveis 9
#DEFINE IT_ALIQIMP	 29	 //Array contendo as Aliquotas de Impostos Variaveis
#DEFINE IT_ALIQIV1	 29,01 //Aliquota de Impostos Variaveis 1
#DEFINE IT_ALIQIV2	 29,02 //Aliquota de Impostos Variaveis 2
#DEFINE IT_ALIQIV3	 29,03 //Aliquota de Impostos Variaveis 3
#DEFINE IT_ALIQIV4	 29,04 //Aliquota de Impostos Variaveis 4
#DEFINE IT_ALIQIV5	 29,05 //Aliquota de Impostos Variaveis 5
#DEFINE IT_ALIQIV6	 29,06 //Aliquota de Impostos Variaveis 6
#DEFINE IT_ALIQIV7	 29,07 //Aliquota de Impostos Variaveis 7
#DEFINE IT_ALIQIV8	 29,08 //Aliquota de Impostos Variaveis 8
#DEFINE IT_ALIQIV9	 29,09 //Aliquota de Impostos Variaveis 9
#DEFINE IT_VALIMP		 30    //Array contendo os valores de Impostos Agentina/Chile/Etc.
#DEFINE IT_VALIV1		 30,01 //Valor do Imposto Variavel 1
#DEFINE IT_VALIV2		 30,02 //Valor do Imposto Variavel 2
#DEFINE IT_VALIV3		 30,03 //Valor do Imposto Variavel 3
#DEFINE IT_VALIV4		 30,04 //Valor do Imposto Variavel 4
#DEFINE IT_VALIV5		 30,05 //Valor do Imposto Variavel 5
#DEFINE IT_VALIV6		 30,06 //Valor do Imposto Variavel 6
#DEFINE IT_VALIV7		 30,07 //Valor do Imposto Variavel 7
#DEFINE IT_VALIV8		 30,08 //Valor do Imposto Variavel 8
#DEFINE IT_VALIV9		 30,09 //Valor do Imposto Variavel 9
#DEFINE IT_BASEDUP	 31	   //Base das duplicatas geradas no financeiro
#DEFINE IT_DESCZF		 32	   //Valor do desconto da Zona Franca do item
#DEFINE IT_DESCIV		 33	   //Array contendo a descricao dos Impostos Variaveis
#DEFINE IT_DESCIV1	 33,1  //Array contendo a Descricao dos IV 1
#DEFINE IT_DESCIV2	 33,2  //Array contendo a Descricao dos IV 2
#DEFINE IT_DESCIV3	 33,3  //Array contendo a Descricao dos IV 3
#DEFINE IT_DESCIV4	 33,4  //Array contendo a Descricao dos IV 4
#DEFINE IT_DESCIV5	 33,5  //Array contendo a Descricao dos IV 5
#DEFINE IT_DESCIV6	 33,6  //Array contendo a Descricao dos IV 6
#DEFINE IT_DESCIV7	 33,7  //Array contendo a Descricao dos IV 7
#DEFINE IT_DESCIV8	 33,8  //Array contendo a Descricao dos IV 8
#DEFINE IT_DESCIV9	 33,9  //Array contendo a Descricao dos IV 9
#DEFINE IT_QUANT		 34	 //Quantidade do Item
#DEFINE IT_PRCUNI		 35	 //Preco Unitario do Item
#DEFINE IT_VIPIBICM 	 36	 //Valor do IPI Incidente na Base de ICMS
#DEFINE IT_PESO     	 37	 //Peso da mercadoria do item
#DEFINE IT_ICMFRETE 	 38	 //Valor do ICMS Relativo ao Frete
#DEFINE IT_BSFRETE  	 39	 //Base do ICMS Relativo ao Frete
#DEFINE IT_BASECOF  	 40	 //Base de calculo do COFINS
#DEFINE IT_ALIQCOF  	 41	 //Aliquota de calculo do COFINS
#DEFINE IT_VALCOF   	 42	 //Valor do COFINS
#DEFINE IT_BASECSL  	 43    //Base de calculo do CSLL
#DEFINE IT_ALIQCSL  	 44    //Aliquota de calculo do CSLL
#DEFINE IT_VALCSL   	 45	 //Valor do CSLL
#DEFINE IT_BASEPIS  	 46	 //Base de calculo do PIS
#DEFINE IT_ALIQPIS  	 47	 //Aliquota de calculo do PIS
#DEFINE IT_VALPIS   	 48	 //Valor do PIS
#DEFINE IT_RECNOSB1 	 49	 //RecNo do SB1
#DEFINE IT_RECNOSF4 	 50	 //RecNo do SF4
#DEFINE IT_VNAGREG   51	    //Valor da Mercadoria nao agregada.
#DEFINE IT_TIPONF    52    //Tipo da nota fiscal
#DEFINE IT_REMITO    53    //Remito
#DEFINE IT_BASEPS2   54	    //Base de calculo do PIS 2
#DEFINE IT_ALIQPS2   55	    //Aliquota de calculo do PIS 2
#DEFINE IT_VALPS2    56	    //Valor do PIS 2
#DEFINE IT_BASECF2   57	    //Base de calculo do COFINS 2
#DEFINE IT_ALIQCF2   58	    //Aliquota de calculo do COFINS 2
#DEFINE IT_VALCF2    59	    //Valor do COFINS 2
#DEFINE IT_ABVLINSS  60    //Abatimento da base do INSS em valor
#DEFINE IT_ABVLISS   61    //Abatimento da base do ISS em valor
#DEFINE IT_REDISS    62    //Percentual de reducao de base do ISS ( opcional, utilizar normalmente TS_BASEISS )
#DEFINE IT_ICMSDIF   63    //Valor do ICMS diferido
#DEFINE IT_DESCZFPIS 64    //Desconto do PIS
#DEFINE IT_DESCZFCOF 65    //Desconto do Cofins
#DEFINE IT_BASEAFRMM 66	    //Base de calculo do AFRMM ( Item )
#DEFINE IT_ALIQAFRMM 67	    //Aliquota de calculo do AFRMM ( Item )
#DEFINE IT_VALAFRMM  68	    //Valor do AFRMM ( Item )
#DEFINE IT_PIS252    69    //Decreto 252 de 15/06/2005 - PIS no item para retencao aquisicao a aquisicao - sem considerar R# 5.000,00 da Lei 10925
#DEFINE IT_COF252    70    //Decreto 252 de 15/06/2005 - COFINS no item para retencao aquisicao a aquisicao - sem considerar R# 5.000,00 da Lei 10925
#DEFINE IT_CRDZFM    71    //Credito Presumido - Zona Franca de Manaus
#DEFINE IT_CNAE      72    //Codigo da Atividade Economica da Prestacao de Servicos
#DEFINE IT_ITEM      73    //Numero Item
#DEFINE IT_SEST	    74	 //Array contendo os valores do SEST
#DEFINE IT_BASESES   74,01 //Base de calculo do SEST
#DEFINE IT_ALIQSES   74,02 //Aliquota de calculo do SEST
#DEFINE IT_VALSES    74,03 //Valor do INSS
#DEFINE IT_BASEPS3   75	    //Base de calculo do PIS Subst. Tributaria
#DEFINE IT_ALIQPS3   76	    //Aliquota de calculo do PIS Subst. Tributaria
#DEFINE IT_VALPS3    77	    //Valor do PIS Subst. Tributaria
#DEFINE IT_BASECF3   78	    //Base de calculo da COFINS Subst. Tributaria
#DEFINE IT_ALIQCF3   79	    //Aliquota de calculo da COFINS Subst. Tributaria
#DEFINE IT_VALCF3    80	    //Valor da COFINS Subst. Tributaria
#DEFINE IT_VLR_FRT   81    //Valor do Frete de Pauta
#DEFINE IT_BASEFET   82	    //Base do Fethab
#DEFINE IT_ALIQFET   83	    //Aliquota do Fethab
#DEFINE IT_VALFET    84	    //Valor do Fethab
#DEFINE IT_ABSCINS   85	    //Abatimento do Valor do INSS em Valor - SubContratada
#DEFINE IT_SPED      86    //SPED
#DEFINE IT_ABMATISS  87    //Abatimento da base do ISS em valor referente a material utilizado
#DEFINE IT_RGESPST   88    //Indica se a operacao, mesmo sem calculo de ICMS ST, faz parte do Regime Especial de Substituicao Tributaria
#DEFINE IT_PRFDSUL   89    //Percentual de UFERMS para o calculo do Fundersul - Mato Grosso do Sul
#DEFINE IT_UFERMS    90    //Valor da UFERMS para o calculo do Fundersul - Mato Grosso do Sul
#DEFINE IT_VALFDS    91     //Valor do Fundersul - Mato Grosso do Sul

#DEFINE LF_CFO			01	  // Codigo Fiscal
#DEFINE LF_ALIQICMS 	02	  // Aliquota de ICMS
#DEFINE LF_VALCONT		03	  // Valor Contabil
#DEFINE LF_BASEICM		04	  // Base de ICMS
#DEFINE LF_VALICM		05	  // Valor do ICMS
#DEFINE LF_ISENICM		06	  // ICMS Isento
#DEFINE LF_OUTRICM		07	  // ICMS Outros
#DEFINE LF_BASEIPI		08	  // Base de IPI
#DEFINE LF_VALIPI		09	  // IPI Tributado
#DEFINE LF_ISENIPI		10	  // IPI Isento
#DEFINE LF_OUTRIPI		11	  // IPI Outros
#DEFINE LF_OBSERV		12	  // Observacao
#DEFINE LF_VALOBSE		13 	  // Valor na Observacao
#DEFINE LF_ICMSRET		14	  // Valor ICMS Retido
#DEFINE LF_LANCAM		15	  // Numero do Lancamento
#DEFINE LF_TIPO		    16	  // Tipo de Lancamento
#DEFINE LF_ICMSCOMP 	17 	  // ICMS Complementar
#DEFINE LF_CODISS		18	  // Cod.Serv. ISS
#DEFINE LF_IPIOBS		19	  // IPI na Observacao
#DEFINE LF_NFLIVRO		20	  // Numero do Livro
#DEFINE LF_ICMAUTO		21	  // ICMS Frete Autonomo
#DEFINE LF_BASERET		22	  // Base do ICMS Retido
#DEFINE LF_FORMUL		23	  // Flag de Fom. Proprio
#DEFINE LF_FORMULA		24	  // Formula
#DEFINE LF_DESPESA		25	  // Despesas Acessorias
#DEFINE LF_ICMSDIF		26	  // Icms Diferido
#DEFINE LF_TRFICM	    27	  // Transferencia de Debito e Credito
#DEFINE LF_OBSICM	    28	  // Icms na coluna de observacoes
#DEFINE LF_OBSSOL	    29	  // Solidario na coluna de observacoes
#DEFINE LF_SOLTRIB	    30	  // Valor do ICMS Solidario que possui tributacao com credito de imposto
#DEFINE LF_CFOEXT		31	  // Codigo Fiscal Extendido
#DEFINE LF_ISSST		32	  // Codigo Fiscal Extendido
#DEFINE LF_RECISS		33	  // Codigo Fiscal Extendido
#DEFINE LF_ISSSUB       34    // ISS de Sub-empreitada.
#DEFINE LF_ISS_ALIQICMS 35,01 // Aliquota de ICMS
#DEFINE LF_ISS_ISENICM	 35,02 // ICMS Isento
#DEFINE LF_ISS_OUTRICM	 35,03 // ICMS Outros
#DEFINE LF_ISS_ISENIPI	 35,04 // IPI Isento
#DEFINE LF_ISS_OUTRIPI	 35,05 // IPI Outros
#DEFINE LF_CREDST       36    // Credito / Debito Substituição tributária.
#DEFINE LF_CRDEST       37    // Credito Estimulo de Manaus
#DEFINE LF_CRDPRES      38    // Credito Presumido - RJ/PR
#DEFINE LF_SIMPLES      39    // Valor do ICMS para clientes optantes pelo Simples - SC
#DEFINE LF_CRDTRAN      40    // Credito Presumido - RJ - Prestacoes de Servicos de Transporte
#DEFINE LF_CRDZFM       41    // Credito Presumido - Zona Franca de Manaus
#DEFINE LF_CNAE         42    // Codigo da Atividade Economica da Prestacao de Servicos
#DEFINE LF_IDENT        43    // Identificador de gravacao
#DEFINE LF_CLASFIS      44    //Classificacao fiscal de acordo com o F4_SITTRIB + B1_ORIGEM
#DEFINE LF_CTIPI        45    //Codigo de Situacao tributaria do IPI
#DEFINE LF_ESTOQUE      46    //Movimentacao fisica do estoque
#DEFINE LF_DESPIPI      47    //IPI sobre despesas acessorias
#DEFINE LF_POSIPI       48    //NCM Produto
#DEFINE LF_OUTRRET      49    //ICMS Retido escriturado coluna Outros
#DEFINE LF_ISENRET      50    //ICMS Retido escriturado coluna Isento
#DEFINE LF_ITEMORI      51   //Numero Item da NF Ori
#DEFINE LF_CFPS         52    //Codigo Fiscal de Prestacao de Servicos
#DEFINE LF_ALIQIPI      53    //Aliquota de IPI
#DEFINE LF_CRPRST       54    //valor Credito Presumido Substituicao Tributaria retido pelo contratante do servico de transporte - Decreto 44.147/2005 (MG)
							   //	- Decreto 44.147/2005 (MG)
							   // 	- Decreto 20.686, Art 111, $6 em diante. (AM)
#DEFINE LF_TRIBRET      55    //ICMS Retido escriturado coluna Tributado
#DEFINE LF_DESCZFR      56    //Desconto Zona Franca de Manaus
#DEFINE LF_BASEPS3      57    //Base PIS Subst. Tributaria
#DEFINE LF_ALIQPS3      58    //Aliquota do PIS Subst. Tributaria
#DEFINE LF_VALPS3       59    //Valor do PIS Subst. Tributaria
#DEFINE LF_BASECF3      60    //Base da Cofins Subst. Tributaria
#DEFINE LF_ALIQCF3      61    //Aliquota da da Cofins Subst. Tributaria
#DEFINE LF_VALCF3       62    //Valor da da Cofins Subst. Tributaria
#DEFINE LF_CRPRELE      63    //Valor Crédito Presumido nas operações de Saída com o ICMS destacado sobre os produtos resultantes da industrialização com componentes, partes e pecas recebidos do exterior, destinados a fabricacao de produtos de informatica, eletronicos e telecomunicacoes, por estabelecimento industrial desses setores. Tratamento conforme Art. 1º do DECRETO 4.316 de 19 de Junho de 1995.(BA)
#DEFINE LF_ISSMAT       64    //Valor da deducao da base de calculo do ISS referente ao material aplicado
#DEFINE LF_VALFDS       65    //Valor do Fundersul - Mato Grosso do Sul
#DEFINE SP_ITEM         01
#DEFINE SP_CODPRO       02
#DEFINE SP_IMP          03
#DEFINE SP_ORIGEM       04
#DEFINE SP_CST          05
#DEFINE SP_MODBC        06
#DEFINE SP_MVA          07
#DEFINE SP_PREDBC       08
#DEFINE SP_BC           09
#DEFINE SP_ALIQ         10
#DEFINE SP_VLTRIB       11
#DEFINE SP_QTRIB        12
#DEFINE SP_PAUTA        13
#DEFINE SP_COD_MN       14

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle do Tipo de Entrada e Saida                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE TS_CODIGO      01    //Codigo da TES
#DEFINE TS_TIPO        02    //Tipo da TES - S Saida , E Entrada
#DEFINE TS_ICM         03    //Calcula ICMS , S-Sim,N-Nao
#DEFINE TS_IPI         04    //Calcula IPI , S-Sim,N-Nao,R-Comerciante nao Atac.
#DEFINE TS_CREDICM     05    //Credito de ICMS , S-Sim,N-Nao
#DEFINE TS_CREDIPI     06    //Credito de IPI  , S-Sim,N-Nao
#DEFINE TS_DUPLIC      07    //Gera Duplicata , S-Sim,N-Nao
#DEFINE TS_ESTOQUE     08    //Movimenta Estoque , S-Sim,N-Nao
#DEFINE TS_CF          09    //Codigo Fiscal de Operacao
#DEFINE TS_TEXTO       10    //Descricao do TES
#DEFINE TS_BASEICM     11    //Reducao da Base de ICMS
#DEFINE TS_BASEIPI     12    //Reducao da Base de IPI
#DEFINE TS_PODER3      13    //Controla Poder de 3os R-Remessa,D-Devolucao,N-Nao Controla
#DEFINE TS_LFICM       14    //Coluna Livros Fiscais ICM - T-Tributado,I-Isentas,O-Outras,N-Nao,Z-ICMS Zerado
#DEFINE TS_LFIPI       15    //Coluna Livros Fiscais IPI - T-Tributado,I-Isentas,O-Outras,N-Nao,Z-IPI Zerado
#DEFINE TS_DESTACA     16    //Destaca IPI S-Sim,N-Nao
#DEFINE TS_INCIDE      17    //Incide IPI na Base de ICMS , S-Sim,N-Nao
#DEFINE TS_COMPL       18    //Calcula ICMS Complementar , S-Sim,N-NAo
#DEFINE TS_IPIFRET     19    //Calcula IPI sobre Frete S-Sim,N-Nao
#DEFINE TS_ISS         20    //Calcula ISS S-Sim,N-Nao
#DEFINE TS_LFISS       21    //Coluna Livros Fiscais ISS - T=Tributado;I=Isento;O=Outros;N=Nao calcula
#DEFINE TS_NRLIVRO     22    //Numero do Livro
#DEFINE TS_UPRC        23    //Atualiza Ultimo Preco de Compra S-Sim,N-Nao
#DEFINE TS_CONSUMO     24    //Material de Consumo S-Sim,N-Nao
#DEFINE TS_FORMULA     25    //Formula para uso na impressao dos Livros Fiscais
#DEFINE TS_AGREG       26    //Agrega Valor a Mercadoria S-Sim N-Nao
#DEFINE TS_INCSOL      27    //Agrega Valor do ICMS Sol. S-Sim,N-Nao
#DEFINE TS_CIAP        28    //Livro Fiscal CIAP S-Sim,N-Nao
#DEFINE TS_DESPIPI     29    //Calcula IPI sobre Despesas S-Sim,N-Nao
#DEFINE TS_LIVRO       30    //Formula para livro Fiscal
#DEFINE TS_ATUTEC      31    //Atualiza SigaTec S-Sim,N-Nao
#DEFINE TS_ATUATF      32    //Atualiza Ativo Fixo S-Sim,N-Nao
#DEFINE TS_TPIPI       33    //Base do IPI B - Valor Bruto , L - Valor Liquido
#DEFINE TS_SFC         34    //Array contendo os Itens do SFC
#DEFINE TS_LIVRO       35    //Nome do Rdmake de complemento/geracao dos livors Fiscais
#DEFINE TS_STDESC      36    //Define se considera o Desconto no calculo do ICMS Retido.
#DEFINE TS_DESPICM     37    //Define se as Despesas entram na base de Calculo de ICMS
#DEFINE TS_BSICMST     38    //% de Reduco da Base de Calculo do ICMS Solidario
#DEFINE TS_BASEISS     39    //% de Reduco da Base de Calculo do ISS.
#DEFINE TS_IPILICM     40    //O ipi deve ser lancado nas colunas nao tributadas do ICMS
#DEFINE TS_ICMSDIF     41    //ICMS Diferido
#DEFINE TS_QTDZERO     42    //Tes permite digitar quantidade zero.
#DEFINE TS_TRFICM      43    //Tes permite digitar quantidade zero.
#DEFINE TS_OBSICM      44    //Icms na coluna de observacao
#DEFINE TS_OBSSOL      45    //Icms Solidario na coluna de observacao
#DEFINE TS_PICMDIF     46    //Percentual do ICMS Diferido
#DEFINE TS_PISCRED     47    //Credita/Debita PIS/COFIS
#DEFINE TS_PISCOF      48    //Calcula PIS/COFIS
#DEFINE TS_CREDST      49    //Credita Solidario
#DEFINE TS_BASEPIS     50    //Percentual de Reducao do PIS
#DEFINE TS_ICMSST      51    //Indica se o ICMS deve ser somado ao ICMS ST.
#DEFINE TS_FRETAUT     52    //Indica se o Frete Automo deve ser calculo sobre o ICMS ou ICMS-ST
#DEFINE TS_MKPCMP      53    //Indica se o ICMS complementar deve considerar a Margem de Lucro do solidario
#DEFINE TS_CFEXT       54    //Codigo Fiscal de Operacao extendido
#DEFINE TS_BASECOF     55    //Percentual de Reducao do PIS
#DEFINE TS_ISSST       56
#DEFINE TS_MKPSOL      57    //Informa a condição da Margem de Lucro no calculo do ICMS Solidario
#DEFINE TS_AGRPIS      58    //Informa se agrega o valor do PIS ao total da nota
#DEFINE TS_AGRCOF      59    //Informa se agrega o valor do COFINS ao total da nota
#DEFINE TS_AGRRETC     60    //Informa se agrega o valor do ICMS Retido na Coluna Outras/Isenta
#DEFINE TS_PISBRUT     61    //Informa a condição da Margem de Lucro no calculo do ICMS Solidario
#DEFINE TS_COFBRUT     62    //Informa se agrega o valor do PIS ao total da nota
#DEFINE TS_COFDSZF     63    //Informa se agrega o valor do COFINS ao total da nota
#DEFINE TS_PISDSZF     64    //Informa se agrega o valor do ICMS Retido na Coluna Outras/Isenta
#DEFINE TS_LFICMST     65    //Informa como será a escrituração do ICMS-ST.
#DEFINE TS_DESPRDIC    66    //Informa se as despesas acessórias devem ser reduzidas juntamente com a base de calculo do ICMS.
#DEFINE TS_CRDEST      67    //Informa se efetua o calculo do Credito Estimulo de Manaus (1 = Nao Calcula, 2 = Produtos Eletronicos, 3 = Contrucao Civil)
#DEFINE TS_CRDPRES     68    //Percentual do Credito Presumido - RJ/PR
#DEFINE TS_AFRMM       69    //Calcula AFRMM: S-Sim,N-Nao
#DEFINE TS_CRDTRAN     70    //Percentual para calculo do Credito Presumido - RJ - Prestacoes de Serv.de Transporte
#DEFINE TS_CTIPI       71
#DEFINE TS_SITTRIB     72
#DEFINE TS_CFPS        73    //Codigo Fiscal de Prestacao de Servicos
#DEFINE TS_CRPRST      74    //valor Credito Presumido Substituicao Tributaria retido pelo contratante do servico de transporte - Decreto 44.147/2005 (MG)
#DEFINE TS_IPIOBS      75    //valor Credito Presumido Substituicao Tributaria retido pelo contratante do servico de transporte - Decreto 44.147/2005 (MG)
#DEFINE TS_IPIPC       76    //Indica se o valor do IPI deve compor a base de calculo do PIS e da COFINS. 1=Sim (Compoe) e 2=Nao(Nao Compoe)
#DEFINE TS_PSCFST		77    //Indica se o PIS/COFINS devera ser calculado como Subst. Tributaria.
#DEFINE TS_CRPRELE     78    //% Crédito Presumido nas operações de Saída com o ICMS destacado sobre os produtos resultantes da industrialização com componentes, partes e pecas recebidos do exterior, destinados a fabricacao de produtos de informatica, eletronicos e telecomunicacoes, por estabelecimento industrial desses setores. Tratamento conforme Art. 1º do DECRETO 4.316 de 19 de Junho de 1995.(BA)
#DEFINE TS_CALCFET     79    //Informa se calcula o imposto FETHAB
#DEFINE TS_CONTSOC     80    //Informa se calcula o imposto FUNRURAL
#DEFINE TS_COMPRED     81    //Indica se o ICMS interestadual devera ser calculado de acordo com a reducao informada na NF ou desprezando a reducao
#DEFINE TS_CSTPIS      82    //CST PIS
#DEFINE TS_CSTCOF      83    //CST COF
#DEFINE TS_RGESPST     84    //Indica se a operacao, mesmo sem calculo de ICMS ST, faz parte do Regime Especial de Substituicao Tributaria
#DEFINE TS_CLFDSUL     85    //Indica se existira o calculo do Fundersul - Mato Grosso do Sul

#DEFINE MAX_TS         85    //Tamanho do array de TES

#DEFINE SFC_SEQ        01    //Sequencia de calculo do Imposto
#DEFINE SFC_IMPOSTO    02    //Codigo do imposto
#DEFINE SFC_INCDUPL    03    //Indica se incide nas Duplicatas
#DEFINE SFC_INCNOTA    04    //Indica se incide no total da NF
#DEFINE SFC_CREDITA    05    //Indica de Credita o Imposto
#DEFINE SFC_INCIMP     06    //Indica se incide na Base de Calculo de Outro imposto
#DEFINE SFC_BASE       07    // %Reducao da base de calculo
#DEFINE SFB_DESCR      08    //Descricao do Imposto
#DEFINE SFB_CPOVREI    09    //Campo do Valor de Entrada Item
#DEFINE SFB_CPOBAEI    10    //Campo da Base de Entrada do Item
#DEFINE SFB_CPOVREC    11    //Campo do Valor de Entrada Cabecalho
#DEFINE SFB_CPOBAEC    12    //Campo da Base de Entrada Cabecalho
#DEFINE SFB_CPOVRSI    13    //Campo do Valor de Saida Item
#DEFINE SFB_CPOBASI    14    //Campo da Base de Saida Item
#DEFINE SFB_CPOVRSC    15    //Campo do Valor de Saida Cabecalho
#DEFINE SFB_CPOBASC    16    //Campo da Base de Saida Cabecalho
#DEFINE SFB_FORMENT    17    //Rotina para calculo do imposto na Entrada
#DEFINE SFB_FORMSAI    18    //Rotina para calculo do imposto na Saida
#DEFINE SFC_CALCULO    19    //Tipo de calculo

#DEFINE IMP_COD		    01    //Codigo do imposto no Array NF_IMPOSTOS
#DEFINE IMP_DESC		02    //Descricao do imposto no Array NF_IMPOSTOS
#DEFINE IMP_BASE		03    //Base de Calculo do Imposto no Array NF_IMPOSTOS
#DEFINE IMP_ALIQ		04    //Aliquota de calculo do imposto
#DEFINE IMP_VAL		    05    //Valor do Imposto no Array NF_IMPOSTOS
#DEFINE IMP_NOME		06    //Nome de referencia aos Impostos do cabecalho

#DEFINE NMAXIV	        36    // Numero maximo de Impostos Variaveis

STATIC aMaster
STATIC aNFCab
STATIC aNFItem
STATIC aItemDec
STATIC bFisRefresh
STATIC bLivroRefresh
STATIC aBrwLF
STATIC aStack
STATIC aRefSX3
STATIC aSaveDec
STATIC aAuxOri
STATIC cAliasPROD := "SB1"

STATIC aTES[MAX_TS]
STATIC aItemRef
STATIC aCabRef
STATIC aResRef
STATIC aLFIS

STATIC MV_ALIQISS
STATIC MV_ESTADO
STATIC MV_ICMPAD
STATIC MV_NORTE
STATIC MV_ESTICM
STATIC MV_IPIBRUT
STATIC MV_SOLBRUT
STATIC MV_DSZFSOL
STATIC MV_BASERET
STATIC MV_GERIMPV
STATIC MV_FRETEST
STATIC MV_CONTSOC
STATIC MV_RATDESP
STATIC aUltPesq

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisIni  ³ Autor ³Eduardo/Edson          ³ Data ³08.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializa o Calculo das operacoes Fiscais                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Codigo do Cliente / Fornecedor                     ³±±
±±³          ³ ExpC2 : Loja do Cliente / Fornecedor                       ³±±
±±³          ³ ExpC3 : "C" / Cliente , "F" / Fornecedor                   ³±±
±±³          ³ ExpC4 : Tipo da NF ( "N","D","B","C","P","I" )             ³±±
±±³          ³ ExpC5 : Tipo do Cliente / Fornecedor                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³31/03/05  ³Andrea Farias  ³BOPS 77373 -Inicializar a funcao fiscal para³±±
±±³          ³               ³a entidade Prospect.                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisIni(cCodCliFor,;	// 1-Codigo Cliente/Fornecedor
	cLoja,;		// 2-Loja do Cliente/Fornecedor
	cCliFor,;	// 3-C:Cliente , F:Fornecedor
	cTipoNF,;	// 4-Tipo da NF
	cTpCliFor,;	// 5-Tipo do Cliente/Fornecedor
	aRelImp,;	// 6-Relacao de Impostos que suportados no arquivo
	cTpComp,;	// 7-Tipo de complemento
	lInsere,;	// 8-Permite Incluir Impostos no Rodape .T./.F.
	cAliasP,;	// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
	cRotina,;	// 10-Nome da rotina que esta utilizando a funcao
	cTipoDoc,;	// 11-Tipo de documento
	cEspecie,;  // 12-Especie do documento
    cCodProsp,; // 13-Codigo e Loja do Prospect
    cGrpCliFor,;// 14-Grupo Cliente
    cRecolheISS,;// 15-Recolhe ISS
    cCliEnt,;   // 16-Codigo do cliente de entrega na nota fiscal de saida
    cLojEnt)    // 17-Loja do cliente de entrega na nota fiscal de saida

Local aArea    := GetArea()
Local aAreaSA1 := SA1->(GetArea())
Local aAreaSA2 := SA2->(GetArea())
Local cOperNf  := ""
Local cUfDest  := ""
Local cUfOrig  := ""
Local cNatureza:= ""
Local cRecPIS  := "N"
Local cRecCOFI := "N"
Local cRecCSLL := "N"
Local cRecISS  := "2"
Local cRecINSS := "N"
Local cRecSEST := "2"
Local cCNPJ    := ""
Local lInclui  := .T.
Local lInscrito:= .F.
Local lSuframa := .F.
Local cCalcSuf := ""
Local nAliqIRF := 0
Local cSerie   := ''
Local nMoeda   := 1
Local nTxMoeda := 0
Local cModIRF  := ""
Local cOPIrrf  := ""
Local cRecFet  := "2"

DEFAULT aRelImp := {}
DEFAULT cTpComp := ""
DEFAULT lInsere := .F.
DEFAULT cAliasP := "SB1"
DEFAULT cTipoDoc:= ""
DEFAULT cEspecie:= ""
DEFAULT	cCodProsp:= ""	//Codigo e Loja do Prospect
DEFAULT cGrpCliFor:= CriaVar("A1_GRPTRIB",.F.)
DEFAULT cRecolheISS	:=	""
DEFAULT cCliEnt  := Space(TamSx3("F3_CLIEFOR")[1])
DEFAULT cLojEnt  := Space(TamSx3("F2_LOJA")[1])

cTpCliFor		 := IIf(cTpCliFor==Nil," ",cTpCliFor)
aUltPesq         := {ctod(""),"","",0,0}

If MaFisFound("NF")
	lInclui 	:= .F.
	cCodCliFor	:= aNfCab[NF_CODCLIFOR]
	cLoja		:= aNfCab[NF_LOJA]
	cCliFor		:= aNfCab[NF_CLIFOR]
	cTipoNF		:= aNfCab[NF_TIPONF]
	cTpCliFor	:= aNfCab[NF_TPCLIFOR]
	aRelImp		:= aNfCab[NF_RELIMP]
	cNatureza	:= aNfCab[NF_NATUREZA]
	cTpComp		:= aNfCab[NF_TPCOMP]
	lInsere		:= aNfCab[NF_INSIMP]
	cRotina		:= aNfCab[NF_ROTINA]
	nAliqIRF    := aNfCab[NF_ALIQIR]
	cSerie		:= aNfCab[NF_SERIENF]
	cTipoDoc	:= aNfCab[NF_TIPODOC]
	nMoeda 		:= aNfCab[NF_MOEDA]
	nTxMoeda	:= aNfCab[NF_TXMOEDA]
	cEspecie	:= aNfCab[NF_ESPECIE]
	cCNPJ       := aNfCab[NF_CNPJ]
	cCliEnt		:= aNfCab[NF_CLIENT]
	cLojEnt		:= aNfCab[NF_LOJENT]
EndIf

If lInclui
	aNFCab	:= {}
	aNFItem	:= {}
	aItemDec:= {}
	MV_ALIQISS := SuperGetMV("MV_ALIQISS")
	MV_ESTADO  := SuperGetMV("MV_ESTADO")
	MV_ICMPAD  := SuperGetMV("MV_ICMPAD")
	MV_NORTE   := SuperGetMV("MV_NORTE")
	MV_ESTICM  := SuperGetMV("MV_ESTICM")
	MV_IPIBRUT := SuperGetMV("MV_IPIBRUT")
	MV_SOLBRUT := SuperGetMV("MV_SOLBRUT")
	MV_DSZFSOL := SuperGetMV("MV_DSZFSOL")
	MV_BASERET := SuperGetMV("MV_BASERET")
	MV_GERIMPV := SuperGetMV("MV_GERIMPV")
	MV_FRETEST := SuperGetMV("MV_FRETEST")
	MV_CONTSOC := SuperGetMV("MV_CONTSOC")
	MV_RATDESP := SuperGetMV("MV_RATDESP")
	cAliasPROD := cAliasP
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona os registros necessarios                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( cCliFor == "C" )

	If Empty(cCodProsp)
		dbSelectArea("SA1")
		dbSetOrder(1)
		MsSeek(xFilial("SA1")+cCodCliFor+cLoja)
		cOperNf   := IIf(cTipoNf$"DB","E","S")
		lInscrito := IIf(Empty(SA1->A1_INSCR).OR."ISENT"$SA1->A1_INSCR.OR."RG"$SA1->A1_INSCR,.T.,.F.)
		lSuframa  := !Empty(SA1->A1_SUFRAMA).AND.SA1->A1_CALCSUF<>'N'
		cCalcSuf  := SA1->A1_CALCSUF
		If Empty(cGrpCliFor)
			cGrpCliFor:= SA1->A1_GRPTRIB
		EndIf
		cUfDest   := IIf(cTipoNf$"DB",MV_ESTADO,SA1->A1_EST)
		cUfOrig   := IIf(cTipoNf$"DB",SA1->A1_EST,MV_ESTADO)
		cCNPJ     := SA1->A1_CGC

		If lInclui
			cNatureza := SA1->A1_NATUREZ
			cTpCliFor := IIf(Empty(cTpCliFor),SA1->A1_TIPO,cTpCliFor)
		Else
			cTpCliFor := SA1->A1_TIPO
		EndIf
		nAliqIRF    := SA1->A1_ALIQIR
		cRecPIS  := SA1->A1_RECPIS
		cRecCOFI := SA1->A1_RECCOFI
		cRecCSLL := SA1->A1_RECCSLL
		cRecISS  := SA1->A1_RECISS
		If !Empty(cRecolheISS)
			cRecISS  := cRecolheISS
		Endif
		cRecINSS := SA1->A1_RECINSS
		If MaCalcFet()
			cRecFet  := IIf(Empty(SA1->A1_RECFET),"2",SA1->A1_RECFET)
		Endif
		cModIRF  := IIf(SA1->(FieldPos("A1_CALCIRF")<>0),SA1->A1_CALCIRF,IIf(GetNewPar("MV_IRMP232","2")=="2","1","2"))
		cOPIrrf  := If(SA1->(FieldPos("A1_TPESSOA")) > 0,SA1->A1_TPESSOA,"")
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa as variaveis para a entidade prospect³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SUS")
		DbSetOrder(1)
		MsSeek(xFilial("SUS")+cCodProsp)
		cOperNf   := IIf(cTipoNf$"DB","E","S")

		If SUS->(FieldPos("US_INSCR")) > 0
			lInscrito := IIf(Empty(SUS->US_INSCR) .OR. "ISENT" $ SUS->US_INSCR .OR. "RG" $ SUS->US_INSCR,.T.,.F.)
		Endif

		If SUS->(FieldPos("US_SUFRAMA")) > 0 .AND. SUS->(FieldPos("US_CALCSUF")) > 0
			lSuframa  := !Empty(SUS->US_SUFRAMA) .AND. SUS->US_CALCSUF<>'N'
			cCalcSuf  := SUS->US_CALCSUF
		Endif

		If SUS->(FieldPos("US_GRPTRIB")) > 0 .AND. Empty(cGrpCliFor)
			cGrpCliFor:= SUS->US_GRPTRIB
	    Endif

		cUfDest   := IIf(cTipoNf$"DB",MV_ESTADO,SUS->US_EST)
		cUfOrig   := IIf(cTipoNf$"DB",SUS->US_EST,MV_ESTADO)
		cCNPJ     := SUS->US_CGC

		If lInclui
			If SUS->(FieldPos("US_NATUREZ")) > 0
				cNatureza := SUS->US_NATUREZ
			Endif
			cTpCliFor := IIf(Empty(cTpCliFor),SUS->US_TIPO,cTpCliFor)
		Else
			cTpCliFor := SUS->US_TIPO
		EndIf

		nAliqIRF := IIf(SUS->(FieldPos("US_ALIQIR"))	> 0,SUS->US_ALIQIR	,0)
		cRecPIS  := IIf(SUS->(FieldPos("US_RECPIS"))	> 0,SUS->US_RECPIS	,"N")
		cRecCOFI := IIf(SUS->(FieldPos("US_RECCOFI")) 	> 0,SUS->US_RECCOFI	,"N")
		cRecCSLL := IIf(SUS->(FieldPos("US_RECCSLL")) 	> 0,SUS->US_RECCSLL	,"N")
		cRecISS  := IIf(SUS->(FieldPos("US_RECISS")) 	> 0,SUS->US_RECISS	,"2")
		cRecINSS := IIf(SUS->(FieldPos("US_RECINSS"))	> 0,SUS->US_RECINSS	,"N")
		cModIRF  := IIf(SA1->(FieldPos("A1_CALCIRF")<>0),SA1->A1_CALCIRF,IIf(GetNewPar("MV_IRMP232","2")=="2","1","2"))
		cOPIrrf  := IIf(SUS->(FieldPos("US_TPESSOA"))	> 0,SUS->US_TPESSOA	,"")
	EndIf

Else
	dbSelectArea("SA2")
	dbSetOrder(1)
	MsSeek(xFilial("SA2")+cCodCliFor+cLoja)
	cOperNf   := IIf(cTipoNf$"DB","S","E")
	If Empty(cGrpCliFor)
		cGrpCliFor:= SA2->A2_GRPTRIB
	EndIf
	lInscrito := IIf(Empty(SM0->M0_INSC).OR."ISENT"$SM0->M0_INSC,.T.,.F.)
	cUfDest   := IIf(cTipoNf$"DB",SA2->A2_EST,MV_ESTADO)
	cUfOrig   := IIf(cTipoNf$"DB",MV_ESTADO,SA2->A2_EST)
	cCNPJ     := SA2->A2_CGC

	If lInclui
		cNatureza := &(SuperGetMV("MV_2DUPNAT"))
		If Empty( cTpCliFor )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Converte os tipos do fornecedor para os tipos validos       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cTpCliFor := MaFisTpCon( SA2->A2_TIPO )
		EndIf
	Else
		cTpCliFor := MaFisTpCon( SA2->A2_TIPO )
	EndIf
	If cPaisLoc== "BRA"
		cRecISS  := IIf(SA2->A2_RECISS<>"S","2","1")
		cRecINSS := SA2->A2_RECINSS
		cRecSEST := IIf(SA2->(FieldPos("A2_RECSEST"))>0,SA2->A2_RECSEST,"2")
		cRecPIS  := IIf(SA2->A2_RECPIS<>"2","N","S")
		cRecCOFI := IIf(SA2->A2_RECCOFI<>"2","N","S")
		cRecCSLL := IIf(SA2->A2_RECCSLL<>"2","N","S")
		If MaCalcFet()
			cRecFet  := IIf(Empty(SA2->A2_RECFET),"2",SA2->A2_RECFET)
		Endif
		cModIRF  := IIf(SA2->(FieldPos("A2_CALCIRF")<>0),SA2->A2_CALCIRF,"1")
		cOPIrrf  := Iif(SA2->(FieldPos("A2_TPESSOA")) > 0,SA2->A2_TPESSOA,"")
	EndIf
EndIf

If lInclui
	aNfCab := {	cTipoNF,;		//1
		cOperNF,;		//2
		cCliFor,;		//3
		cTpCliFor,;		//4
		lInscrito,;		//5
		cGrpCliFor,;	//6
		cUFdest,;       //7
		cUfOrig,;		//8
		0,;				//9
		0,;				//10
		0,;				//11
		0,;				//12
		0,;				//13
		0,;				//14
		{0,0,0,0,0,0,0,0,"1"},;	//15
		{0,0,0},;		//16
		0,;				//17
		0,;				//18
		0,;				//19
		cCodCliFor,;	//20
		cLoja,;			//21
		{},;			//22
		{0,0},;		    //23
		{0,0},;		    //24
		{0,0},;		    //25
		cNatureza,;		//26
		0,;				//27
		{},;			//28
		{},;			//29
		{{'...','  ',0,0,0,'NEW'}},;	//30
		0,;				//31
		aRelImp,;		//32
		{{'...','  ',0,0,'NEW'}},;//33
		0,;				//34
		lSuframa,;		//35
		Array(NMAXIV),;	//36
		Array(NMAXIV),;	//37
		cTpComp,;		//38
		lInsere,;		//39
		0,;				//40
		0,;				//41
		0,;				//42
		0,;				//43
		0,;				//44
		0,;				//45
		0,;				//46
		0,;				//47
		0,;				//48
		cRotina,;       //49
		0,;				//50
		nAliqIRF,;		//51
		0,;   			//52
		cRecPIS,;		//53
		cRecCOFI,;		//54
		cRecCSLL,;		//55
		cRecISS,;		//56
		cRecINSS,;		//57
		nMoeda,;		//58
		nTxMoeda,;		//59
		cSerie,;		//60
		cTipoDoc,;		//61
		Array(NMAXIV),;	//62
		0,;				//63
		0,;				//64
		cEspecie,;      //65
		cCNPJ,;         //66
		0,;             //67
		0,;             //68
		0,;             //69
		cModIRF,;       //70
		{"","","",""},;//71
		cCalcSuf,;	    //72
		0,;				//73 - Base de Calculo do AFRMM - NF
		0,;				//74 - Valor do AFRMM - NF
		0,;             //75
		0,;             //76
		cOPIrrf,;		//77
		{0,0},;		    //78 - Array dos valores do SEST
		cRecSEST,;		//79 - Recolhe SEST
		0,;				//80 - Base de calculo do PIS Subst. Tributaria
		0,;				//81 - Valor do PIS Subst. Tributaria
		0,;				//82 - Base de calculo da COFINS Subst. Tributaria
		0,;				//83 - Valor da COFINS Subst. Tributaria
		0,;				//84 - Valor Total do Frete de Pauta
		0,;				//85 - Valor FETHAB
		cRecFet,;		//86 - Recolhe FETHAB
		cCliEnt,;   	//87 - Codigo do cliente de entrega
		cLojEnt,;		//88 - Loja do cliente de entrega
		0}				//89 - Valor do Fundersul - Mato Grosso do Sul
Else
	aNfCab	:= {	cTipoNF,;		//1
		cOperNF,;		//2
		cCliFor,;		//3
		cTpCliFor,;		//4
		lInscrito,;		//5
		cGrpCliFor,;	//6
		cUFdest,;	    //7
		cUfOrig,;		//8
		0,;				//9
		0,;				//10
		0,;				//11
		0,;				//12
		0,;				//13
		0,;				//14
		{0,0,0,0,0,0,0,0,"1"},;	//15
		{0,0,0},;		//16
		0,;	 			//17
		0,;				//18
		0,;				//19
		cCodCliFor,;	//20
		cLoja,;			//21
		{},;			//22
		{0,0},;			//23
		{0,0},;			//24
		{0,0},;	  		//25
		cNatureza,;		//26
		0,;				//27
		{},;			//28
		{},;			//29
		{{"","",0,0,0,""}},;	//30
		0,;				//31
		aRelImp,;		//32
		{{"","",0,0,""}},;	 //33
		0,;				//34
		lSuframa,;		//35
		Array(NMAXIV),;//36
		Array(NMAXIV),; //37
		cTpComp,;		//38
		lInsere,;		//39
		0,;				//40
		0,;				//41
		0,;				//42
		0,;				//43
		0,;				//44
		0,;				//45
		0,;				//46
		0,;				//47
		0,;				//48
		cRotina,;       //49
		0,;				//50
		nAliqIRF,;    	//51
		0,;   			//52
		cRecPIS,;		//53
		cRecCOFI,;		//54
		cRecCSLL,;		//55
		cRecISS,;		//56
		cRecINSS,;		//57
		nMoeda,;		//58
		nTxMoeda,;		//59
		cSerie,;		//60
		cTipoDoc,;		//61
		Array(NMAXIV),;	//62
		0,;				//63
		0,;				//64
		cEspecie,;      //65
		cCNPJ,;         //66
		0,;             //67
		0,;             //68
		0,;             //69
		cModIRF,;       //70
		{"","","",""},;//71
		cCalcSuf,;	    //72
		0,;				//73
		0,;				//74
		0,;             //75
		0,;             //76
		cOPIrrf,;       //77
		{0,0},;		    //78 - Array dos valores do SEST
		cRecSEST,;		//79 - Recolhe SEST
		0,;				//80 - Base de calculo do PIS Subst. Tributaria
		0,;				//81 - Valor do PIS Subst. Tributaria
		0,;				//82 - Base de calculo da COFINS Subst. Tributaria
		0,;				//83 - Valor da COFINS Subst. Tributaria
		0,;				//84 - Valor Total do Frete de Pauta
		0,;				//85 - Valor FETHAB
		cRecFet,;		//86 - Recolhe FETHAB
		cCliEnt,;   	//87 - Codigo do cliente de entrega
		cLojEnt,;		//88 - Loja do cliente de entrega
		0}				//89 - Valor do Fundersul - Mato Grosso do Sul
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa arrays de impostos variaveis                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aNfCab[NF_BASEIMP]:=Afill(aNfCab[NF_BASEIMP],0)
aNfCab[NF_VALIMP]:=Afill(aNfCab[NF_VALIMP],0)
aNfCab[NF_MINIMP]:=Afill(aNfCab[NF_MINIMP],0)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o array de Referencias                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aItemRef == Nil
	MaIniRef()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o array de arredondamentos do item                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aSaveDec == Nil
	aSaveDec := Array(Len(aItemRef))
	aFill(aSaveDec,0)
EndIf
If aAuxOri == Nil
	aAuxOri := {}
EndIf

RestArea(aAreaSA1)
RestArea(aAreaSA2)
RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisAdd  ³ Autor ³ Edson Maricate        ³ Data ³09.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializa o Calculo das operacoes Fiscais por item         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array contendo o calculo de impostos do item                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisAdd(cProduto,;   	// 1-Codigo do Produto ( Obrigatorio )
	cTes,;	   	// 2-Codigo do TES ( Opcional )
	nQtd,;	   	// 3-Quantidade ( Obrigatorio )
	nPrcUnit,;   	// 4-Preco Unitario ( Obrigatorio )
	nDesconto,;  	// 5-Valor do Desconto ( Opcional )
	cNFOri,;	   	// 6-Numero da NF Original ( Devolucao/Benef )
	cSEROri,;		// 7-Serie da NF Original ( Devolucao/Benef )
	nRecOri,;		// 8-RecNo da NF Original no arq SD1/SD2
	nFrete,;		// 9-Valor do Frete do Item ( Opcional )
	nDespesa,;	// 10-Valor da Despesa do item ( Opcional )
	nSeguro,;		// 11-Valor do Seguro do item ( Opcional )
	nFretAut,;	// 12-Valor do Frete Autonomo ( Opcional )
	nValMerc,;	// 13-Valor da Mercadoria ( Obrigatorio )
	nValEmb,;		// 14-Valor da Embalagem ( Opiconal )
	nRecSB1,;		// 15-RecNo do SB1
	nRecSF4)		// 16-RecNo do SF4

Local aArea    := GetArea()
Local nItem

DEFAULT nRecSB1 := 0
DEFAULT nRecSF4 := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona os registros necessarios                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasPROD)
If nRecSB1 <> 0 .AND. cAliasPROD=="SB1"
	MsGoto(nRecSB1)
Else
	dbSetOrder(1)
	MsSeek(xFilial(cAliasPROD)+cProduto)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a TES utilizada no calculo de impostos      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaFisTes(@cTes,nRecSF4)

aadd(aNfItem,{MaSBCampo("GRTRIB"),;			//1 - Grupo de Tributacao
	{},;										//2 - Array contendo as excessoes Fiscais
	0,;											//3 - Aliquota de ICMS
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},;//4 - Valores de ICMS
	0,;											//5 - Aliquota de IPI
	{0,0,0,0,0},;  							//6 - Valores de IPI
	cNFOri,;          							//7 - Numero da NF Original
	cSEROri,;									//8 - Serie da NF Original
	nRecOri,;									//9 - RecNo da NF original
	nDesconto,;									//10 - Valor do desconto do item
	nFrete,;									//11 - Valor do Frete
	nDespesa,;									//12 - Valor da despesa
	nSeguro,;									//13 - Valor do seguro
	nFretAut,;									//14 - Valor do frete autonomo
	nValMerc,; 									//15 - Valor da Mercadoria
	cProduto ,;									//16 - Codigo do produto
	cTes	,;									//17 - Codigo da TES
	0 ,;										//18 - Valor Total do item
	"",;										//19 - Codigo FIscal de Operacao
	0 ,;										//20 - Valor do Funrural
	0 ,;                     					//21 - Aliquota para calculo do FunRural
	.F.,;										//22 - Flag de controle para itens deletados
	MaFisRetLF() ,;	         					//23 - Array Contendo o demonstrativo fiscal
	{0,0,0,"","","","",0},;	           		//24 - Array contendo os valores de ISS
	{0,0,0,0},;							     	//25 - Array contendo os valores de IR
	{0,0,0,0},;								    //26 - Array contendo os valores de INSS
	0,; 										//27 - Valor da Embalagem
	Array(NMAXIV),;								//28
	Array(NMAXIV),;								//29
	Array(NMAXIV),;								//30
	0,;											//31
	0,;											//32
	Array(NMAXIV),;								//33
	nQtd ,;										//34
	nPrcUnit,;									//35
	0,;											//36
	0,;											//37
	0,;											//38
	0,;											//39
	0,;											//40
	0,;											//41
	0,;											//42
	0,;			  			  					//43
	0,;			  								//44
	0,;			  								//45
	0,;											//46
	0,;											//47
	0,;											//48
	nRecSB1,;									//49
	nRecSF4,;									//50
	0,; 										//51
	aNfCab[NF_TIPONF],;						    //52
	"",;										//53
	0,;											//54
	0,;											//55
	0,;											//56
	0,;											//57
	0,;											//58
    0,;                                         //59
	0,;     		                            //60
    0,;             		                    //61
    0,;                     		            //62
    0,;                             		    //63
    0,;      		                            //64
    0,;             		                    //65
    0,;											//66 - Base AFRMM - Item
    0,;											//67 - Aliquota AFRMM - Item
    0,;											//68 - Valor AFRMM - Item
    0,;											//69
    0,;											//70
    0,;											//71
	"",;										//72
    Iif (aNfCab[NF_OPERNF]=='S', "01", "0001"),;	//73
	{0,0,0},;										//74 - Array dos valores do SEST
	0,;				//75 - Base de calculo do PIS Subst. Tributaria
	0,;				//76 - Aliquota do PIS Subst. Tributaria
	0,;				//77 - Valor do PIS Subst. Tributaria
	0,;				//78 - Bae da COFINS Subst. Tributaria
	0,;				//79 - Aliquota da COFINS Subst. Tributaria
	0,;				//80 - Valor da COFINS Subst. Tributaria
	0,;				//81 - Valor do Frete de Pauta
	0,;				//82 - Base FETHAB
	0,;				//83 - Aliquota FETHAB
	0,;				//84 - Valor FETHAB
	0,;             //85 - Abatimento do Valor do INSS em Valor - Subcontratada
	{"","","","","","",0,0,0,0,0,0,0,""},;
	0,;             //87 - Abatimento do Valor do ISS referente ao material utilizado})
	"",;            //88 - Indica se a operacao, mesmo sem calculo de ICMS ST, faz parte do Regime Especial de Substituicao Tributaria
	0,;				//89 - Percentual de UFERMS para o calculo do Fundersul - Mato Grosso do Sul
	0,;				//90 - Valor da UFERMS para o calculo do Fundersul - Mato Grosso do Sul
	0})				//91 - Valor do Fundersul - Mato Grosso do Sul

If Len(aNfitem) > 1
	aNfitem[Len(aNfitem)][IT_ITEM] := Soma1(aNfitem[Len(aNfitem)-1][IT_ITEM])
EndIf

aadd(aItemDec,{Nil,Nil})
aItemDec[Len(aItemDec)][1] := Array(Len(aItemRef))
aItemDec[Len(aItemDec)][2] := Array(Len(aItemRef))
aFill(aItemDec[Len(aItemDec)][1],0)
aFill(aItemDec[Len(aItemDec)][2],0)

nItem 	:= Len(aNfItem)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa arrays de impostos variaveis                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aNfItem[nItem][IT_BASEIMP]:=Afill(aNfItem[nItem][IT_BASEIMP],0)
aNfItem[nItem][IT_ALIQIMP]:=Afill(aNfItem[nItem][IT_ALIQIMP],0)
aNfItem[nItem][IT_VALIMP]:=Afill(aNfItem[nItem][IT_VALIMP],0)
aNfItem[nItem][IT_DESCIV]:=Afill(aNfItem[nItem][IT_DESCIV],{"","",""})

MaFisRecal("",nItem)
MaIt2Cab()

RestArea(aArea)
Return(nItem)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisAlt  ³ Autor ³ Edson Maricate        ³ Data ³09.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Altera os valores de impostos e bases do item.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisAlt(cCampo,nValor,nItem,lNoCabec,nItemNao,lDupl)

Local aArea    := GetArea()
Local aRef     := {}
Local cPosCpo  := ""
Local nPos     := 0
Local nValAnt  := 0
Local nPosItDec:= 0

DEFAULT lNoCabec := .F.
DEFAULT nItemNao := 0
DEFAULT lDupl    := .F.

If nValor <> Nil
	Do Case
	Case Substr(cCampo,1,2) == "IT"
		If MaFisFound("IT",nItem)
			If MaFisRet(nItem,cCampo) <> nValor
				If !lNocabec
					MaFisSomaIt(nItem,.F.,cCampo)
				EndIf
				cPosCpo	:= MaFisScan(cCampo)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Tratamento para os itens.                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ValType(cPosCpo) == "A"
					aNfItem[nItem][cPosCpo[1]][cPosCpo[2]] := nValor
				Else
					aNfItem[nItem][Val(cPosCpo)] := nValor
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Tratamento especifico e diferenciado para cada campo.       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MaFisRecal(cCampo,nItem)
				If !lNoCabec
					MaFisSomaIt(nItem)
					If bFisRefresh <> Nil
						Eval(bFisRefresh)
					EndIf
					If bLivroRefresh <> Nil
						Eval(bLivroRefresh)
					EndIf
				EndIf
			EndIf
		EndIf
	Case Substr(cCampo,1,2) == "NF"
		If MaFisFound("NF")
			If MaFisRet(,cCampo) <> nValor .Or. lDupl
				cPosCpo	:= MaFisScan(cCampo)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Tratamento para o cabecalho.                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ValType(cPosCpo) == "A"
					nValAnt	:= aNfCab[cPosCpo[1]][cPosCpo[2]]
					aNfCab[cPosCpo[1]][cPosCpo[2]] := nValor
				Else
					nValAnt	:= aNfCab[Val(cPosCpo)]
					aNfCab[Val(cPosCpo)] := nValor
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Tratamento especifico e diferenciado para cada campo.       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Do Case
				Case AllTrim(cCampo)$"NF_CODCLIFOR/NF_LOJA/NF_TIPONF/NF_OPERNF/NF_CLIFOR/NF_NATUREZA"

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Reinicia os valores de arredondamento dos impostos contidos no aSaveDec.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If AllTrim(cCampo)$"NF_NATUREZA"
						aRef := {"IT_VALISS","IT_VALIRR","IT_VALINS","IT_VALCOF","IT_VALCSL","IT_VALPIS","IT_VALPS2","IT_VALCF2","IT_VALPS3","IT_VALCF3"}
						For nPos := 1 to Len(aItemRef)
							If !Empty(aScan(aRef,aItemRef[nPos,1]))
								aSaveDec[nPos] := 0
							EndIF
						Next nPos
					Else
						aSaveDec := Nil
					EndIf

					MaFisIni()
					For nItem := 1 To Len(aNfItem)
						If AllTrim(cCampo)$"NF_CODCLIFOR"
							aNfItem[nItem, IT_EXCECAO]	:=	{}
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Como zero o array aSaveDec acima, preciso zerar o aItemDec tambem, para nao dar diferenca na funcao MaItArred³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						ElseIf AllTrim(cCampo)$"NF_NATUREZA"
							For nPos := 1 to Len(aRef)
								nPosItDec	:=	aScan(aItemRef,{|aX| aX[1]==aRef[nPos]})
								If !Empty(nPosItDec)
									If Len(aItemDec[nItem][1])>=nPosItDec
										aItemDec[nItem][1][nPosItDec]	:=	0
									EndIf
									If Len(aItemDec[nItem][2])>=nPosItDec
										aItemDec[nItem][2][nPosItDec]	:=	0
									EndIf
								EndIf
							Next nPos
						EndIf
						MaFisRecal(cCampo,nItem)
					Next nItem
					If !lNoCabec
						MaIt2Cab()
					EndIf
				Case AllTrim(cCampo)$"NF_UFDEST/NF_UFORIGEM/NF_SUFRAMA/NF_AUXACUM/NF_RECISS"+Iif(cPaisLoc <> "BRA","/NF_SERIENF","")+"/NF_PNF_COD/NF_PNF_LOJ/NF_PNF_UF/NF_PNF_TPCLIFOR"
					For nItem := 1 To Len(aNfItem)
						MaFisRecal(cCampo,nItem)
						If !lNoCabec .AND. cPaisLoc <> "BRA"
							MaFisSomaIt(nItem)
							If bFisRefresh <> Nil
								Eval(bFisRefresh)
							EndIf
							If bLivroRefresh <> Nil
								Eval(bLivroRefresh)
							EndIf
						EndIf
					Next nItem

					If !lNoCabec
						MaIt2Cab()
					EndIf
				OtherWise
					If ((nValAnt <> nValor .Or. lDupl) .AND. ValType(nValor) == "N" ) .AND. !(AllTrim(cCampo)$"NF_MOEDA/NF_TXMOEDA/") .AND. !'NF_MINIV'$AllTrim(cCampo) .AND.!'NF_MINIMP'$AllTrim(cCampo)
						If AllTrim(cCampo)$"NF_FRETE/NF_SEGURO/NF_DESPESA/NF_DESCONTO/NF_VLR_FRT"
							For nItem := 1 To Len(aNfItem)
								aFill(aItemDec[nItem][1],0)
								aFill(aItemDec[nItem][2],0)
							Next nItem
							aFill(aSaveDec,0)
						EndIf
						MaRateio("IT"+Substr(cCampo,3,Len(cCampo)-2),nValAnt,nValor,lDupl)
						For nItem := 1 To Len(aNfItem)
							MaFisRecal("IT"+Substr(cCampo,3,Len(cCampo)-2),nItem)
						Next nItem
						If !lNoCabec
							MaIt2Cab()
						EndIf
					EndIf
				EndCase
			EndIf
		EndIf
	Case Substr(cCampo,1,3) == "IMP"
		If cCampo == "IMP_VALRUR"
			cCampo := "IMP_FUNRURAL"
			MaFisRatRes("IT_FUNRURAL",nValor,aNfCab[NF_IMPOSTOS][nItem][IMP_ALIQ],"IT_PERFUN","",nItemNao)
		Else
			MaFisRatRes("IT"+Substr(cCampo,4,Len(cCampo)-3),nValor,aNfCab[NF_IMPOSTOS][nItem][IMP_ALIQ],'IT_ALIQ'+aNfCab[NF_IMPOSTOS][nItem][IMP_NOME],'IT_BASE'+aNfCab[NF_IMPOSTOS][nItem][IMP_NOME],nItemNao)
		EndIf
		For nItem := 1 to Len(aNfItem)
			If nItem <> nItemNao
				MaFisRecal("IT"+Substr(cCampo,4,Len(cCampo)-3),nItem)
			Endif
		Next nItem
		If !lNoCabec
			MaIt2Cab(nItemNao)
		EndIf
	EndCase
EndIF
RestArea(aArea)
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisLoad ³ Autor ³ Edson Maricate        ³ Data ³09.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega os valores de impostos de bases e item.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo da referencia                                 ³±±
±±³          ³ExpN2: Valor a ser atualizado na referencia                 ³±±
±±³          ³ExpN3: Item a ser considerado                          (OPC)³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisLoad(cCampo,nValor,nItem)

Local aArea    := GetArea()
Local cPosCpo  := MaFisScan(cCampo)

If nValor <> Nil
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Altera o valor do campo no Array aNfCab ou aNfItem          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Substr(cCampo,1,2) == "IT"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento para os itens.                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType(cPosCpo) == "A"
			aNfItem[nItem][cPosCpo[1]][cPosCpo[2]] := nValor
		Else
			aNfItem[nItem][Val(cPosCpo)] := nValor
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento para o cabecalho.                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType(cPosCpo) == "A"
			aNfCab[cPosCpo[1]][cPosCpo[2]] := nValor
		Else
			aNfCab[Val(cPosCpo)] := nValor
		EndIf
	EndIf
EndIf
RestArea(aArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisWrite³ Autor ³ Edson Maricate        ³ Data ³10.01.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica arredondamentos para iniciar a gravacao.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisWrite(nOpc,cArea,nItem,lImpostos)


Local aAcDif 	:= Array(Len(aItemRef))
Local aNotasOri := {}
Local nX       	:= 0	// controle de loop
Local nY       	:= 0	// controle de loop
Local nLf      	:= 0	// controle de loop

DEFAULT lImpostos := .F.

aFill(aAcDif,0)
Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua a gravacao dos campos de impostos.                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case nOpc == 2
	For nX := 1 to Len(aNfCab[NF_RELIMP])
		If aNfCab[NF_RELIMP][nX][1] == cArea
			If !lImpostos .OR.	Substr(aNfCab[NF_RELIMP][nX][1],4,6) == "BASIMP" .OR.;
					Substr(aNfCab[NF_RELIMP][nX][1],4,6) == "ALQIMP" .OR.;
					Substr(aNfCab[NF_RELIMP][nX][1],4,6) == "VALIMP"
				dbSelectArea(cArea)
				FieldPut(FieldPos(aNfCab[NF_RELIMP][nX][2]),MaFisRet(nItem,aNfCab[NF_RELIMP][nX][3]))
			Endif
		EndIf
	Next nX
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia a gravacao e fetua a correcao dos arredondamentos.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OtherWise
	aNfCab[NF_LIVRO]	:= {}
	For nX := 1 to Len(aNfItem)
		If !aNfItem[nX][IT_DELETED]
			For nY := 1 to Len(aItemRef)
				If aItemRef[nY][4]
					If ValType(aItemRef[nY][2]) == "A"
						nAcDif := aAcDif[nY]
						nValor := aNfItem[nX][aItemRef[nY][2][1]][aItemRef[nY][2][2]]
						If nValor > 0
							aNfItem[nX][aItemRef[nY][2][1]][aItemRef[nY][2][2]] := NoRound(nValor,2,@nAcDif,10)
							aAcDif[nY] := nAcDif
							If NoRound(aAcDif[nY],2) >= 0.01
								aNfItem[nX][aItemRef[nY][2][1]][aItemRef[nY][2][2]] += 0.01
								aAcDif[nY] -= 0.01
							EndIf
						EndIf
					Else
						nAcDif := aAcDif[nY]
						nValor := aNfItem[nX][Val(aItemRef[nY][2])]
						If nValor > 0
							aNfItem[nX][Val(aItemRef[nY][2])] := NoRound(nValor,2,@nAcDif,10)
							aAcDif[nY] := nAcDif
							If NoRound(aAcDif[nY],2) >= 0.01
								aNfItem[nX][Val(aItemRef[nY][2])] += 0.01
								aAcDif[nY] -= 0.01
							EndIf
						EndIf
					EndIf
				EndIf
			Next nY
			MaFisLFToLivro(nX,@aNotasOri)
		EndIf
	Next nX
	For nX := 1 To Len(aCabRef)
		If ValType(aCabRef[nX,2]) <> "A"
			nY := Val(aCabRef[nX,2])
			If ValType(aNfCab[nY]) == "N" .AND. aCabRef[nX][3]
				aNfCab[nY] := NoRound(aNfCab[nY]+0.000000001,2,,10)
			EndIf
		EndIf
	Next nX
	If cPaisLoc=="BRA"
		For nLf := 1 to Len(aNfCab[NF_LIVRO])
			For nY	:= 1 to Len(aNfCab[NF_LIVRO][nLf])
				If !AllTrim(StrZero(nY,2))$"01#02#12#15#16#18#20#23#24#31#32#33#35#36#42#43#44#45#46#47#48#51#52#53#58#61"
					aNfCab[NF_LIVRO][nLF][nY] := aNfCab[NF_LIVRO][nLF][nY]
				EndIf
			Next nY
		Next nLf
	Endif
EndCase

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaExcecao ³ Autor ³Eduardo/Edson          ³ Data ³09.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calculo das Excecoes fiscais                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array da EXCECAO Fiscal                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaExcecao(nItem)

Local aArea	   := GetArea()
Local aAreaSF7 := SF7->(GetArea())
Local aExcecao := {}
Local cGRTrib  := ""
Local nScan    := 0

// Estrutura do Array aExcecao
// [01] - Aliq. de ICMS Interna
// [02] - Aliq. de ICMS Externa
// [03] - Margem de Lucro Presumida
// [04] - Grupo de Tributacao
// [05] - "S"
// [06] - Aliq. de ICMS Destino
// [07] - Refere-se ao ISS "S/N"
// [08] - Valor do Solidario de Pauta
// [09] - Valor do IPI de Pauta
// [10] - Valor do PIS
// [11] - Valor Cofins
// [12] - Aliquota do PIS
// [13] - Aliquota do Cofins
// [14] - Reducao da base de calculo do ICMS
// [15] - Reducao da base de calculo do IPI
// [16] - Icms Pauta
// [17] - Aliquota de IPI
// [18] - Reducao da base de calculo do PIS
// [19] - Reducao da base de calculo da COFINS
// [20] - Pauta Produto "S/N"

If Empty( cGrTrib := MaFisRet( nItem, "IT_GRPTRIB" ) )
	cGrTrib := PadR(MaSBCampo("GRTRIB"),Len(SF7->F7_GRTRIB))
EndIf

If ( !Empty(cGRTrib) )
	nScan := aScan(aNfItem,{|x| !Empty(x[IT_EXCECAO]) .AND. x[IT_EXCECAO,4]==cGRTrib })
	If ( nScan == 0 )
		dbSelectArea("SF7")
		dbSetOrder(1)
		MsSeek(xFilial()+cGRTrib+aNFCab[NF_GRPCLI])

		While ( !Eof() .AND.SF7->F7_FILIAL == xFilial("SF7") .AND.;
				SF7->F7_GRTRIB == cGRTrib .AND. ;
				SF7->F7_GRPCLI == aNFCab[NF_GRPCLI] )

			If aNFCab[NF_TIPONF] == "D" .AND.;
					( aNFCab[NF_UFORIGEM] == SF7->F7_EST .OR. SF7->F7_EST == "**") .AND. ;
					(aNfCab[NF_TPCLIFOR] == SF7->F7_TIPOCLI .OR. SF7->F7_TIPOCLI == "*")
				aadd(aExcecao,SF7->F7_ALIQINT)
				aadd(aExcecao,SF7->F7_ALIQEXT)
				aadd(aExcecao,SF7->F7_MARGEM)
				aadd(aExcecao,SF7->F7_GRTRIB)
				aadd(aExcecao,"S")
				aadd(aExcecao,SF7->F7_ALIQDST)
				aadd(aExcecao,SF7->F7_ISS)
				If cPaisLoc == "BRA"
					aadd(aExcecao,SF7->F7_VLR_ICM)
					aadd(aExcecao,SF7->F7_VLR_IPI)
					aadd(aExcecao,SF7->F7_VLR_PIS)
					aadd(aExcecao,SF7->F7_VLR_COF)
					aadd(aExcecao,SF7->F7_ALIQPIS)
					aadd(aExcecao,SF7->F7_ALIQCOF)
					aadd(aExcecao,SF7->F7_BASEICM)
					aadd(aExcecao,SF7->F7_BASEIPI)
					aadd(aExcecao,SF7->F7_VLRICMP)
					aadd(aExcecao,SF7->F7_ALIQIPI)
					aadd(aExcecao,SF7->F7_REDPIS)
					aadd(aExcecao,SF7->F7_REDCOF)
					aadd(aExcecao,SF7->F7_ICMPAUT)
				Else
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
				EndIf
			Else
				If aNFCab[NF_TIPONF] != "D" .And.;
						( aNFCab[NF_UFDEST] == SF7->F7_EST .OR. SF7->F7_EST == "**") .AND. ;
						(aNfCab[NF_TPCLIFOR] == SF7->F7_TIPOCLI .OR. SF7->F7_TIPOCLI == "*")
					aadd(aExcecao,SF7->F7_ALIQINT)
					aadd(aExcecao,SF7->F7_ALIQEXT)
					aadd(aExcecao,SF7->F7_MARGEM)
					aadd(aExcecao,SF7->F7_GRTRIB)
					aadd(aExcecao,"S")
					aadd(aExcecao,SF7->F7_ALIQDST)
					aadd(aExcecao,SF7->F7_ISS)
					If cPaisLoc == "BRA"
						aadd(aExcecao,SF7->F7_VLR_ICM)
						aadd(aExcecao,SF7->F7_VLR_IPI)
						aadd(aExcecao,SF7->F7_VLR_PIS)
						aadd(aExcecao,SF7->F7_VLR_COF)
						aadd(aExcecao,SF7->F7_ALIQPIS)
						aadd(aExcecao,SF7->F7_ALIQCOF)
						aadd(aExcecao,SF7->F7_BASEICM)
						aadd(aExcecao,SF7->F7_BASEIPI)
						aadd(aExcecao,SF7->F7_VLRICMP)
						aadd(aExcecao,SF7->F7_ALIQIPI)
						aadd(aExcecao,SF7->F7_REDPIS)
						aadd(aExcecao,SF7->F7_REDCOF)
						aadd(aExcecao,SF7->F7_ICMPAUT)
					Else
						aadd(aExcecao,0)
						aadd(aExcecao,0)
						aadd(aExcecao,0)
						aadd(aExcecao,0)
						aadd(aExcecao,0)
						aadd(aExcecao,0)
						aadd(aExcecao,0)
						aadd(aExcecao,0)
						aadd(aExcecao,0)
						aadd(aExcecao,0)
						aadd(aExcecao,0)
						aadd(aExcecao,0)
						aadd(aExcecao,0)
					EndIf
					Exit
				EndIf
			EndIf
			dbSelectArea("SF7")
			dbSkip()
		End
	Else
		aExcecao := aNfItem[nScan][IT_EXCECAO]
	EndIf
EndIf
aNfItem[nItem][IT_EXCECAO] := aExcecao

RestArea(aAreaSF7)
RestArea(aArea)
Return(aExcecao)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MaFisTes ³ Autor ³  Edson Maricate       ³ Data ³03.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicializa o codigo da TES utilizada no item.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Codigo do TES                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisTes(cTes,nRecSF4,nItemTes)

Local aArea		:= {}
Local aAreaSFC	:= {}
Local nSeq		:= 0
Local cConverte
Local aTmp	:=	{}
Local nX 	:=	0
Local cDummy	:=	'z'
Local lTotal	:=	.F.
Local lImport	:=	(Type("lFacImport")=="L" .AND. lFacImport)
DEFAULT cTes 	:= ""
DEFAULT nRecSF4 := 0

If cTes <> aTes[TS_CODIGO]
	aArea		:= GetArea()
	aAreaSFC	:= SFC->(GetArea())

	aTes[TS_SFC]		:= {}
	dbSelectArea("SF4")
	If nRecSF4 == 0
		dbSetOrder(1)
		MsSeek(xFilial("SF4")+cTes)
	Else
		MsGoto(nRecSF4)
	EndIf
	If Empty(cTes)
		aTes[TS_CODIGO] 	:= CriaVar("F4_CODIGO",.F.)
		aTes[TS_TIPO]		:= aNfCab[NF_OPERNF]
		aTes[TS_ICM]		:= IIf( cPaisLoc=="BRA","S","N")
		aTes[TS_IPI]		:= IIf( cPaisLoc=="BRA","S","N")
		aTes[TS_CREDICM]	:= "S"
		aTes[TS_CREDIPI]	:= "N"
		aTes[TS_DUPLIC]	    := "S"
		aTes[TS_ESTOQUE]	:= "S"
		aTes[TS_TEXTO]		:= CriaVar("F4_TEXTO",.F.)
		aTes[TS_BASEICM]	:= 0
		aTes[TS_BASEIPI]	:= 0
		aTes[TS_PODER3]	    := "N"
		aTes[TS_LFICM]		:= "T"
		aTes[TS_LFIPI]		:= "T"
		aTes[TS_DESTACA]	:= "N"
		aTes[TS_INCIDE]	    := "N"
		aTes[TS_COMPL]		:= "N"
		aTes[TS_IPIFRET]	:= "N"
		aTes[TS_ISS]		:= " "
		aTes[TS_LFISS]		:= " "
		aTes[TS_NRLIVRO]	:= " "
		aTes[TS_UPRC]		:= " "
		aTes[TS_CONSUMO]	:= " "
		aTes[TS_FORMULA]	:= " "
		aTes[TS_AGREG]		:= " "
		aTes[TS_INCSOL]	    := " "
		aTes[TS_CIAP]		:= " "
		aTes[TS_DESPIPI]	:= " "
		aTes[TS_LIVRO]		:= " "
		aTes[TS_ATUTEC]	    := " "
		aTes[TS_ATUATF]	    := " "
		aTes[TS_TPIPI]		:= "B"
		aTes[TS_STDESC]	    := " "
		If aNfCab[NF_OPERNF] == "E"
			aTes[TS_CF]		:= "111"
		Else
			aTes[TS_CF]		:= "511"
		EndIf
		aTes[TS_LIVRO]		:= ""
		aTes[TS_DESPICM]	:= "1"
		aTes[TS_BSICMST]	:= 0
		aTes[TS_BASEISS]	:= 0
		aTes[TS_IPILICM]  	:= "2"
		aTes[TS_ICMSDIF]  	:= "2"
		aTes[TS_QTDZERO]  	:= "2"
		aTes[TS_TRFICM]  	:= "2"
		aTes[TS_OBSICM]     := "2"
		aTes[TS_OBSSOL]     := "2"
		aTES[TS_PICMDIF]    := 0
		aTES[TS_PISCRED]    := "3"
		aTES[TS_PISCOF]     := "4"
		aTes[TS_CREDST]     := "2"
		aTes[TS_BASEPIS]    := 0
		aTes[TS_BASECOF]    := 0
		aTes[TS_ICMSST]     := "1"
		aTes[TS_FRETAUT]    := "1"
		aTes[TS_MKPCMP]     := "2"
		aTes[TS_CFEXT]      := ""
		aTes[TS_ISSST]      := "1"
		aTes[TS_MKPSOL]     := "2"
		aTes[TS_AGRPIS]     := "2"
		aTes[TS_AGRCOF]     := "2"
		aTes[TS_AGRRETC]    := "2"
		aTes[TS_PISBRUT]    := "2"
		aTes[TS_COFBRUT]    := "2"
		aTes[TS_PISDSZF]    := "2"
		aTes[TS_COFDSZF]    := "2"
		aTES[TS_LFICMST]    := "N"
		aTES[TS_DESPRDIC]   := "1"
		aTes[TS_CRDEST]     := "1"
		aTes[TS_CRDPRES]    := 0
		aTes[TS_AFRMM]		:= "N"
		aTes[TS_CRDTRAN]    := 0
		aTes[TS_CTIPI]      := ""
		aTes[TS_SITTRIB]    := ""
		aTes[TS_CFPS]       := ""
		aTes[TS_CRPRST]     := 0
		aTes[TS_IPIOBS]		:= "1"
		aTes[TS_IPIPC]		:= "1"
		aTes[TS_PSCFST]		:= "2"
		aTes[TS_CRPRELE]	:=	0
		aTes[TS_CALCFET]    := "2"
		aTes[TS_CONTSOC]    := "1"
		aTes[TS_COMPRED]    := "1"
		aTES[TS_CSTPIS]     := ""
		aTES[TS_CSTCOF]     := ""
		aTes[TS_RGESPST]    := "2"
		aTes[TS_CLFDSUL]    := "2"
	Else
		aTes[TS_CODIGO] 	:= SF4->F4_CODIGO
		aTes[TS_TIPO]		:= SF4->F4_TIPO
		aTes[TS_ICM]		:= IIf( cPaisLoc=="BRA",SF4->F4_ICM,"N")
		aTes[TS_IPI]		:= IIf( cPaisLoc=="BRA",SF4->F4_IPI,"N")
		aTes[TS_CREDICM]	:= SF4->F4_CREDICM
		aTes[TS_CREDIPI]	:= SF4->F4_CREDIPI
		aTes[TS_DUPLIC]	:= SF4->F4_DUPLIC
		aTes[TS_ESTOQUE]	:= SF4->F4_ESTOQUE
		aTes[TS_CF]			:= SF4->F4_CF
		aTes[TS_TEXTO]		:= SF4->F4_TEXTO
		aTes[TS_BASEICM]	:= SF4->F4_BASEICM
		aTes[TS_BASEIPI]	:= SF4->F4_BASEIPI
		aTes[TS_PODER3]	:= SF4->F4_PODER3
		aTes[TS_LFICM]		:= SF4->F4_LFICM
		aTes[TS_LFIPI]		:= SF4->F4_LFIPI
		aTes[TS_DESTACA]	:= SF4->F4_DESTACA
		aTes[TS_INCIDE]	:= SF4->F4_INCIDE
		aTes[TS_COMPL]		:= SF4->F4_COMPL
		aTes[TS_IPIFRET]	:= SF4->F4_IPIFRET
		aTes[TS_ISS]		:= SF4->F4_ISS
		aTes[TS_LFISS]		:= IIF(SF4->(FieldPos("F4_LFISS"))>0,SF4->F4_LFISS," ")
		aTes[TS_NRLIVRO]	:= SF4->F4_NRLIVRO
		aTes[TS_UPRC]		:= SF4->F4_UPRC
		aTes[TS_CONSUMO]	:= SF4->F4_CONSUMO
		aTes[TS_FORMULA]	:= SF4->F4_FORMULA
		aTes[TS_AGREG]		:= SF4->F4_AGREG
		aTes[TS_INCSOL]	    := IIF(SF4->(FieldPos("F4_INCSOL"))>0,SF4->F4_INCSOL," ")
		aTes[TS_CIAP]		:= SF4->F4_CIAP
		aTes[TS_DESPIPI]	:= SF4->F4_DESPIPI
		aTes[TS_LIVRO]		:= SF4->F4_LIVRO
		aTes[TS_ATUTEC]	:= SF4->F4_ATUTEC
		aTes[TS_ATUATF]	:= SF4->F4_ATUATF
		aTes[TS_TPIPI]		:= SF4->F4_TPIPI
		aTes[TS_LIVRO]		:= SF4->F4_LIVRO
		aTes[TS_STDESC]	:= SF4->F4_STDESC
		aTes[TS_DESPICM]	:= SF4->F4_DESPICM
		aTes[TS_BSICMST]	:= SF4->F4_BSICMST
		aTes[TS_BASEISS] 	:= SF4->F4_BASEISS
		aTes[TS_IPILICM] 	:= SF4->F4_IPILICM
		aTes[TS_ICMSDIF] 	:= SF4->F4_ICMSDIF
		aTes[TS_QTDZERO] 	:= SF4->F4_QTDZERO
		aTes[TS_TRFICM]  	:= IIF(SF4->(FieldPos("F4_TRFICM"))>0,SF4->F4_TRFICM,"2")
		aTes[TS_OBSICM]   := SF4->F4_OBSICM
		aTes[TS_OBSSOL]   := SF4->F4_OBSSOL
		aTES[TS_PICMDIF]  := SF4->F4_PICMDIF
		aTES[TS_PISCRED]  := SF4->F4_PISCRED
		aTES[TS_PISCOF]   := SF4->F4_PISCOF
		aTes[TS_CREDST]   := SF4->F4_CREDST
		aTes[TS_BASEPIS]  := SF4->F4_BASEPIS
		aTes[TS_BASECOF]  := SF4->F4_BASECOF
		aTes[TS_ICMSST]   := SF4->F4_ICMSST
		aTes[TS_ISSST]    := SF4->F4_ISSST
		aTes[TS_AGRPIS]   := IIF(SF4->(FieldPos("F4_AGRPIS"))>0,SF4->F4_AGRPIS,"2")
		aTes[TS_AGRCOF]   := IIF(SF4->(FieldPos("F4_AGRCOF"))>0,SF4->F4_AGRCOF,"2")
		aTes[TS_AGRRETC]  := IIF(SF4->(FieldPos("F4_AGRRETC"))>0,SF4->F4_AGRRETC,"2")

		aTes[TS_PISBRUT]    := IIF(SF4->(FieldPos("F4_PISBRUT"))>0,SF4->F4_PISBRUT,"2")
		aTes[TS_COFBRUT]    := IIF(SF4->(FieldPos("F4_COFBRUT"))>0,SF4->F4_COFBRUT,"2")
		aTes[TS_PISDSZF]    := IIF(SF4->(FieldPos("F4_PISDSZF"))>0,SF4->F4_PISDSZF,"2")
		aTes[TS_COFDSZF]    := IIF(SF4->(FieldPos("F4_COFDSZF"))>0,SF4->F4_COFDSZF,"2")
		aTes[TS_CRDEST]     := IIF(SF4->(FieldPos("F4_CRDEST"))>0,SF4->F4_CRDEST,"1")
		aTes[TS_CRDPRES]    := IIF(SF4->(FieldPos("F4_CRDPRES"))>0,SF4->F4_CRDPRES,0)
		aTes[TS_AFRMM]		:= IIF(SF4->(FieldPos("F4_AFRMM"))>0,SF4->F4_AFRMM,"N")
		aTes[TS_CRDTRAN]    := IIF(SF4->(FieldPos("F4_CRDTRAN"))>0,SF4->F4_CRDTRAN,0)
		aTes[TS_CALCFET]	:= IIF(SF4->(FieldPos("F4_CALCFET"))>0,SF4->F4_CALCFET,"2")

		If cPaisLoc == "BRA"
			aTes[TS_FRETAUT]    := SF4->F4_FRETAUT
			aTes[TS_MKPCMP]     := SF4->F4_MKPCMP
			aTes[TS_CFEXT]      := SF4->F4_CFEXT
			aTes[TS_CFPS]       := IIF(SF4->(FieldPos ("F4_CFPS"))>0, SF4->F4_CFPS, "")
			aTes[TS_MKPSOL]     := IIF(SF4->(FieldPos("F4_MKPSOL"))>0,SF4->F4_MKPSOL,"2")
			aTES[TS_LFICMST]    := IIF(SF4->(FieldPos("F4_LFICMST"))>0,SF4->F4_LFICMST,"N")
			aTES[TS_DESPRDIC]   := IIF(SF4->(FieldPos("F4_DSPRDIC"))>0,SF4->F4_DSPRDIC,"1")
			aTes[TS_CTIPI]      	:= IIF (SF4->(FieldPos ("F4_CTIPI"))>0, SF4->F4_CTIPI, "  ")
			aTes[TS_SITTRIB]        := IIF (SF4->(FieldPos ("F4_SITTRIB"))>0, SF4->F4_SITTRIB, "  ")
			aTes[TS_CFPS]       	:= IIF (SF4->(FieldPos ("F4_CFPS"))>0, SF4->F4_CFPS, "")
			aTes[TS_CRPRST]     	:= IIF (SF4->(FieldPos ("F4_CRPRST"))>0, SF4->F4_CRPRST, 0)
			aTes[TS_IPIOBS]     	:= IIF (SF4->(FieldPos ("F4_IPIOBS"))>0, SF4->F4_IPIOBS, " ")
			aTes[TS_IPIPC]     		:= IIF (SF4->(FieldPos ("F4_IPIPC"))>0, SF4->F4_IPIPC, " ")
			aTes[TS_PSCFST]			:= IIF (SF4->(FieldPos ("F4_PSCFST"))>0,SF4->F4_PSCFST,"2")
			aTes[TS_CRPRELE]		:= IIF (SF4->(FieldPos ("F4_CRPRELE"))>0, SF4->F4_CRPRELE, 0)
			aTes[TS_CONTSOC]    	:= IIF (SF4->(FieldPos ("F4_CONTSOC"))>0, SF4->F4_CONTSOC,"1")
			aTes[TS_COMPRED]    	:= IIF (SF4->(FieldPos ("F4_COMPRED"))>0, SF4->F4_COMPRED,"1")
			aTES[TS_CSTPIS]         := IIF (SF4->(FieldPos ("F4_CSTPIS"))>0, SF4->F4_CSTPIS,"")
			aTES[TS_CSTCOF]         := IIF (SF4->(FieldPos ("F4_CSTCOF"))>0, SF4->F4_CSTCOF,"")
			aTes[TS_RGESPST]   		:= IIF (SF4->(FieldPos ("F4_RGESPST"))>0, SF4->F4_RGESPST,"2")
			aTes[TS_CLFDSUL]		:= IIF (SF4->(FieldPos ("F4_CLFDSUL"))>0, SF4->F4_CLFDSUL,"2")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa os impostos variaveis                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SFC")
		dbSetOrder(1)
		If MV_GERIMPV == "S" .AND. !(IsRemito(1,"'"+MaFisRet(,'NF_TIPODOC')+"'"))
			cTesImp:=SF4->F4_CODIGO
			If cPaisLoc<>"BRA"
				If lImport .AND. nItemTes <> Nil
					If (SD1->(MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+aNfItem[nItemTes][IT_PRODUTO]+StrZero(nItemTes,TamSX3("D1_ITEM")[1]))))
						If SD1->D1_TIPO_NF $ "5678"
							If (SYD->(MsSeek(xFilial("SYD")+SD1->D1_TEC)))
								cTesImp:=SYD->YD_TES
							Endif
						Else
							If SuperGetMV("MV_DESPSD1",,"N")=="S"
								cTesImp:=SD1->D1_TESDES
							Else
								SYD->(MsSeek(xFilial("SYD")+SD1->D1_TEC))
								cTesImp:=SYD->YD_TES
								SFC->(MsSeek(xFilial("SFC")+SYD->YD_TES+aTes[TS_SFC][nY][SFC_IMPOSTO]))
							Endif
						Endif
					Endif
				Endif
			Endif
			If MsSeek(xFilial()+cTesImp)
				While !Eof() .AND. xFilial()+cTesImp == SFC->FC_FILIAL+SFC->FC_TES
					SFB->(dbSetOrder(1))
					SFB->(MsSeek(xFilial()+SFC->FC_IMPOSTO))
					If Ascan(aTes[TS_SFC],{|x| x[SFC_IMPOSTO]==SFC->FC_IMPOSTO})==0
						Aadd(aTes[TS_SFC],Array(19))
						nSeq := Len(aTes[TS_SFC])
						aTes[TS_SFC][nSeq][SFC_SEQ]			:= SFC->FC_SEQ
						aTes[TS_SFC][nSeq][SFC_IMPOSTO]		:= SFC->FC_IMPOSTO
						aTes[TS_SFC][nSeq][SFC_CALCULO]		:= SFC->FC_CALCULO
						If IsAlpha(SFC->FC_INCDUPL)
							cConverte := SFC->FC_INCDUPL + SFC->FC_INCNOTA + SFC->FC_CREDITA
							aTes[TS_SFC][nSeq][SFC_INCDUPL]	 :=	IIf(Subs(cConverte,1,2)=="SN".OR.Subs(cConverte,1,2)=="NS","3",;
								IIf(Subs(cConverte,1,2)=="SS","1","2"))
							aTes[TS_SFC][nSeq][SFC_INCNOTA]	 :=	IIf(Subs(cConverte,2,1)=="S" ,"1",IIf(Subs(cConverte,2,1)=="R" ,"2","3"))
							aTes[TS_SFC][nSeq][SFC_CREDITA]	 :=	IIf(Subs(cConverte,2,2)=="SN","1",IIf(Subs(cConverte,2,2)=="NS","2","3"))
						Else
							aTes[TS_SFC][nSeq][SFC_INCDUPL]		:= SFC->FC_INCDUPL
							aTes[TS_SFC][nSeq][SFC_INCNOTA]		:= SFC->FC_INCNOTA
							aTes[TS_SFC][nSeq][SFC_CREDITA]		:= SFC->FC_CREDITA
						EndIf
						aTes[TS_SFC][nSeq][SFC_INCIMP]		:= SFC->FC_INCIMP
						aTes[TS_SFC][nSeq][SFC_BASE]		:= SFC->FC_BASE
						aTes[TS_SFC][nSeq][SFB_DESCR]		:= SFB->FB_DESCR
						aTes[TS_SFC][nSeq][SFB_CPOVREI]		:= "D1_VALIMP"+SFB->FB_CPOLVRO
						aTes[TS_SFC][nSeq][SFB_CPOBAEI]		:= "D1_BASIMP"+SFB->FB_CPOLVRO
						aTes[TS_SFC][nSeq][SFB_CPOVREC]		:= "F1_VALIMP"+SFB->FB_CPOLVRO
						aTes[TS_SFC][nSeq][SFB_CPOBAEC]		:= "F1_BASIMP"+SFB->FB_CPOLVRO
						aTes[TS_SFC][nSeq][SFB_CPOVRSI]		:= "D2_VALIMP"+SFB->FB_CPOLVRO
						aTes[TS_SFC][nSeq][SFB_CPOBASI]		:= "D2_BASIMP"+SFB->FB_CPOLVRO
						aTes[TS_SFC][nSeq][SFB_CPOVRSC]		:= "F2_VALIMP"+SFB->FB_CPOLVRO
						aTes[TS_SFC][nSeq][SFB_CPOBASC]		:= "F2_BASIMP"+SFB->FB_CPOLVRO
						aTes[TS_SFC][nSeq][SFB_FORMENT]		:= SFB->FB_FORMENT
						aTes[TS_SFC][nSeq][SFB_FORMSAI]		:= SFB->FB_FORMSAI
						Aadd(aTmp,Val(SFB->FB_CPOLVRO))
						If aTes[TS_SFC][nSeq][SFC_CALCULO]=="T"
							lTotal	:=	.T.
						Endif
					Endif
					dbSkip()
				End
				If cPaisLoc == "ARG" .AND. lTotal
					aSort(aTmp)
					For nX := 1 To Len(aTmp)
						If aTmp[nX] <> nX
							cDummy	:=	Str(nX,1)
							Exit
						Endif
					Next nX
					If cDummy <> 'z'
						aSize(aTes[TS_SFC],Len(aTes[TS_SFC])+1)
						aIns(aTes[TS_SFC],1)
						aTes[TS_SFC][1]	:=	aClone(aTes[TS_SFC][2])
						aTes[TS_SFC][1][SFC_SEQ]			:= '00'
						aTes[TS_SFC][1][SFC_IMPOSTO]		:= 'DUM'
						aTes[TS_SFC][1][SFC_CALCULO]		:= 'T'
						aTes[TS_SFC][1][SFB_DESCR]			:= "Dummy"
						aTes[TS_SFC][1][SFB_CPOVREI]		:= "D1_VALIMP"+cDummy
						aTes[TS_SFC][1][SFB_CPOBAEI]		:= "D1_BASIMP"+cDummy
						aTes[TS_SFC][1][SFB_CPOVREC]		:= "F1_VALIMP"+cDummy
						aTes[TS_SFC][1][SFB_CPOBAEC]		:= "F1_BASIMP"+cDummy
						aTes[TS_SFC][1][SFB_CPOVRSI]		:= "D2_VALIMP"+cDummy
						aTes[TS_SFC][1][SFB_CPOBASI]		:= "D2_BASIMP"+cDummy
						aTes[TS_SFC][1][SFB_CPOVRSC]		:= "F2_VALIMP"+cDummy
						aTes[TS_SFC][1][SFB_CPOBASC]		:= "F2_BASIMP"+cDummy
						aTes[TS_SFC][1][SFB_FORMENT]		:= "MaFisZero"
						aTes[TS_SFC][1][SFB_FORMSAI]		:= "MaFisZero"
						MaFisZero() //PAra evitar erro de compilacao
					Endif
				Endif
			Endif
		Else
			aTes[TS_SFC] := {}
		EndIf
	EndIf
	RestArea(aAreaSFC)
	RestArea(aArea)
EndIf

cTes := aTes[TS_CODIGO]

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaAliqICM ³ Autor ³Eduardo/Edson          ³ Data ³08.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calculo da Aliquota para operacoes de ICMS                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Aliquota de ICMS                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item do documento                                    ³±±
±±³          ³ExpL2: Calcula a aliquota interna para o calculo do Solid.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaAliqIcms(nItem,lSolidario)

Local cMV_NORTE	:= SuperGetMV("MV_NORTE")
Local nAliquota := If ( MaSBCampo("PICM") == 0 , MV_ICMPAD ,  MaSBCampo("PICM") )
Local cTipoNF   := aNfCab[NF_TIPONF]

DEFAULT lSolidario := .F.
If aTes[TS_ICM] <> "N" .OR. lSolidario
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a nota fiscal eh de Conhecimento de Frete       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ("CTR"$AllTrim(aNFCab[NF_ESPECIE]).OR."NFST"$AllTrim(aNFCab[NF_ESPECIE]))
		nAliquota := Val(Substr(MV_FRETEST,(AT(aNfCab[NF_UFORIGEM],MV_FRETEST)+2),2))
		nAliquota := IIf(nAliquota>0,NoRound(nAliquota,2),12)
	EndIf
	Do Case
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a nota fiscal eh de Conhecimento de Frete       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case aNfCab[NF_TPCOMP] == "F"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o Parametro MV_FRETEST que contem as Aliq. de ICMS/Frete ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(MV_FRETEST)
			If aNfCab[NF_UFDEST]$MV_NORTE.AND.!(aNfCab[NF_UFORIGEM]$MV_NORTE)
				nAliquota := 7
			Else
				nALiquota := 12 // Aliquota de Frete Fixa em 12%
			EndIf
		Else
			nAliquota := Val(Substr(MV_FRETEST,(AT(aNfCab[NF_UFORIGEM],MV_FRETEST)+2),2))
			nAliquota := IIf(nAliquota>0,NoRound(nAliquota,2),12)
		EndIf
	Case AllTrim(aNFCab[NF_ESPECIE])$"CA"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o Parametro MV_FRETEST que contem as Aliq. de ICMS/Frete ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aNFCab[NF_LINSCR]
			If aNfCab[NF_UFDEST]$MV_NORTE.AND.!(aNfCab[NF_UFORIGEM]$MV_NORTE)
				nAliquota := 7
			Else
				nAliquota := 12 // Aliquota de Frete Fixa em 12%
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a nota fiscal eh de Servicos                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case ( aTes[TS_ISS] =="S" )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula a aliquota do ISS                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nAliquota := If ( MaSBCampo("ALIQISS") == 0 , MV_ALIQISS , MaSBCampo("ALIQISS") )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica as Excecoes fiscais                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( !Empty(aNFitem[nItem][IT_EXCECAO]) )
			If ( aNFCab[NF_UFORIGEM]==aNFCab[NF_UFDEST])
				If (aNfItem[nItem][IT_EXCECAO][1] > 0)
					nAliquota := aNfItem[nItem][IT_EXCECAO][1] //Aliquota Interna
				EndIf
			Else
				If aNfItem[nItem][IT_EXCECAO][2] > 0
					nAliquota := aNfItem[nItem][IT_EXCECAO][2] //Aliquota Externa
				EndIf
			EndIf
		EndIf
	Case ( aTes[TS_PODER3] =="D" )  //Devolucao de Poder de Terceiros
		If !Empty(aNFItem[nItem][IT_RECORI])
			If aNFCab[NF_OPERNF] == "E"
				dbSelectArea("SD2")
				MsGoto( aNFItem[nItem][IT_RECORI] )
				nAliquota  := SD2->D2_PICM
				cTipoNF    := IIf(SD2->D2_TIPO$"IP",SD2->D2_TIPO,cTipoNF)
			Else
				dbSelectArea("SD1")
				MsGoto( aNFItem[nItem][IT_RECORI] )
				nAliquota  := SD1->D1_PICM
				cTipoNF    := IIf(SD1->D1_TIPO$"IP",SD1->D1_TIPO,cTipoNF)
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nas devolucoes sempre pega a aliquota da NF original.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case ( aNFCab[NF_TIPONF] == "D" .AND. !Empty(aNFItem[nItem][IT_RECORI]) )
		If aNFCab[NF_TIPONF] == "D"
			If ( aNFCab[NF_CLIFOR] == "C" )
				dbSelectArea("SD2")
				MsGoto( aNFItem[nItem][IT_RECORI] )
				nAliquota  := SD2->D2_PICM
				cTipoNF    := IIf(SD2->D2_TIPO$"IP",SD2->D2_TIPO,cTipoNF)
				If SD2->D2_DESCZFR > 0
					nAliquota := 0
				EndIf
			Else
				dbSelectArea("SD1")
				MsGoto( aNFItem[nItem][IT_RECORI] )
				nAliquota  := SD1->D1_PICM
				cTipoNF    := IIf(SD1->D1_TIPO$"IP",SD1->D1_TIPO,cTipoNF)
			EndIf
		Else
			If ( aNFCab[NF_CLIFOR] == "C" )
				dbSelectArea("SD1")
				MsGoto( aNFItem[nItem][IT_RECORI] )
				nAliquota  := SD1->D1_PICM
				cTipoNF    := IIf(SD1->D1_TIPO$"IP",SD1->D1_TIPO,cTipoNF)
			Else
				dbSelectArea("SD2")
				MsGoto( aNFItem[nItem][IT_RECORI] )
				nAliquota  := SD2->D2_PICM
				cTipoNF    := IIf(SD2->D2_TIPO$"IP",SD2->D2_TIPO,cTipoNF)
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a nota fiscal eh de ICMS                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento para Exportacao                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case ( aNFCab[NF_TPCLIFOR] == "X" )
		If ( aNFCab[NF_CLIFOR]=="C" )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calculo da Aliquota de ICMS para Exportacao                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nAliquota := 13
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica as Excecoes fiscais                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( !Empty(aNFitem[nItem][IT_EXCECAO]) .AND. aNFItem[nItem][IT_EXCECAO][1]>0)
			nAliquota := aNFItem[nItem][IT_EXCECAO][1] //Aliquota Interna
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento para Nao Inscritos e Consumidores Finais         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case ( aNFCab[NF_LINSCR] )
		If ( aNFCab[NF_CLIFOR]=="F" )
			nAliquota := IIf(!Empty(MaSBCampo("PICM")),MaSBCampo("PICM"),MaAliqOrig(nItem))
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica as Excecoes fiscais                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( !Empty(aNFItem[nItem][IT_EXCECAO]) )
			If ( aNFCab[NF_UFORIGEM] == aNFCab[NF_UFDEST] )
				If ( aNFItem[nItem][IT_EXCECAO][1] ) <> 0
					nAliquota := aNFItem[nItem][IT_EXCECAO][1]  //Aliq. de ICMS Interna
				EndIf
			Else
				If ( !aNFCab[NF_LINSCR] )
					If (aNFItem[nItem][IT_EXCECAO][2] > 0)
						nAliquota :=  aNFItem[nItem][IT_EXCECAO][2]   //Aliq. de ICMS Externa
					EndIf
				Else
					If (aNFItem[nItem][IT_EXCECAO][1] > 0)
						nAliquota :=  aNFItem[nItem][IT_EXCECAO][1]   //Aliq. de ICMS Interna
					EndIf
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento para Operacoes internas com ICMS                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case ( aNFCab[NF_UFORIGEM] == aNFCab[NF_UFDEST] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica as Excecoes fiscais                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( !Empty(aNFItem[nItem][IT_EXCECAO]) )
			If ( aNFItem[nItem][IT_EXCECAO][1] ) <> 0
				nAliquota :=  aNFItem[nItem][IT_EXCECAO][1]   //Aliq. de ICMS Interna
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento para Operacaoes InterEstaduais com ICMS          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case ( aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] )
		If ( aNFCab[NF_TIPONF] <> "D" )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calculo da Aliquota de ICMS                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( aNFCab[NF_UFORIGEM] $ MV_NORTE )
				nAliquota := 12 //MV_ICMTRF
			Else
				nAliquota := IIf( aNFCab[NF_UFDEST] $ MV_NORTE , 7 , 12 ) //MV_ICMTRF
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calculo da Aliquota de ICMS                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( aNFCab[NF_UFORIGEM] $ cMV_NORTE )
				nAliquota := IIf( aNFCab[NF_UFORIGEM] $ cMV_NORTE , 12 , 7 ) //MV_ICMTRF
			Else
				nAliquota := 12 //MV_ICMTRF
			Endif
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica as Excecoes fiscais                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( !Empty(aNFItem[nItem][IT_EXCECAO]) )
			If ( aNFItem[nItem][IT_EXCECAO][2] ) <> 0
				nAliquota :=  aNFItem[nItem][IT_EXCECAO][2]   //Aliq. de ICMS Externa
			EndIf
		EndIf
	EndCase
Else
	nAliquota := 0
EndIf
If aTes[TS_ICM] <> "N"
	aNFitem[nItem][IT_ALIQICM] := nAliquota
	aNFitem[nItem][IT_TIPONF ] := cTipoNF
Else
	aNFitem[nItem][IT_ALIQICM] := 0
	aNFitem[nItem][IT_TIPONF ] := cTipoNF
EndIf

Return(nAliquota)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaAliqDest³ Autor ³Eduardo/Edson          ³ Data ³13.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calculo da Aliquota para operacoes de ICMS                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Aliquota de ICMS                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaAliqDest(nItem)

Local nPerIcm
Local cDestino := aNFCab[NF_UFDEST]

nPerIcm := Val(Subs(MV_ESTICM,AT(cDestino,MV_ESTICM)+2,2))
If !Empty(MV_FRETEST) .AND. aNfCab[NF_TPCOMP] == "F"
	nPerICM := Val(Substr(MV_FRETEST,(AT(aNfCab[NF_UFDEST],MV_FRETEST)+2),2))
	nPerICM := IIf(nPerICM>0,NoRound(nPerICM,2),12)
EndIf
If ( !Empty(aNFItem[nItem][IT_EXCECAO]) )
	If ( aNFItem[nItem][IT_EXCECAO][6] ) <> 0
		nPerIcm := aNfItem[nItem][IT_EXCECAO][6]
	EndIf
EndIf
Return(nPerIcm)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaAliqIPI ³ Autor ³ Edson Maricate        ³ Data ³08.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calculo da Aliquota de IPI.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Aliquota de IPI.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaAliqIPI(nItem)

Local nAliquota	:= 0
Local cTipoNF   := aNfCab[NF_TIPONF]

If aTes[TS_IPI] <> "N"
	nAliquota := MaSBCampo("IPI")
	Do Case
	Case ( aNFCab[NF_TIPONF] $"DB" ) .OR. aTes[TS_PODER3] =="D"

		If aNFCab[NF_TIPONF] $ "DB"
			If !Empty(aNFItem[nItem][IT_RECORI])
				If ( aNFCab[NF_CLIFOR] == "C" )
					dbSelectArea("SD2")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					nAliquota  := SD2->D2_IPI
					cTipoNF    := IIf(SD2->D2_TIPO$"IP",SD2->D2_TIPO,cTipoNF)
				Else
					dbSelectArea("SD1")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					nAliquota  := SD1->D1_IPI
					cTipoNF    := IIf(SD1->D1_TIPO$"IP",SD1->D1_TIPO,cTipoNF)
				EndIf
			EndIf
		Else
			If !Empty(aNFItem[nItem][IT_RECORI])
				If ( aNFCab[NF_CLIFOR] == "C" )
					dbSelectArea("SD1")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					nAliquota  := SD1->D1_IPI
					cTipoNF    := IIf(SD1->D1_TIPO$"IP",SD1->D1_TIPO,cTipoNF)
				Else
					dbSelectArea("SD2")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					nAliquota  := SD2->D2_IPI
					cTipoNF    := IIf(SD2->D2_TIPO$"IP",SD2->D2_TIPO,cTipoNF)
				EndIf
			EndIf
		EndIf
	EndCase
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as Excecoes fiscais                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(Empty(aNFitem[nItem,IT_EXCECAO]))
	If aNFItem[nItem,IT_EXCECAO,17] <> 0
		nAliquota := aNFItem[nItem,IT_EXCECAO,17]
	Endif
Endif

If aTes[TS_IPI] <> "N"
	aNFitem[nItem][IT_ALIQIPI] := nAliquota
	aNFitem[nItem][IT_TIPONF ] := cTipoNF
Else
	aNFitem[nItem][IT_ALIQIPI] := 0
	aNFitem[nItem][IT_TIPONF ] := cTipoNF
EndIf

Return nAliquota

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MaFisRet ³ Autor ³ Edson Maricate        ³ Data ³08.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os impostos calculados pela MATXFIS.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Valor do imposto.                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisRet(nItem,cCampo)
Local nRetorno
Local cPosCpo := MaFisScan(cCampo)

Do Case
Case Substr(cCampo,1,2) == "IT"
	If ValType(cPosCpo) == "A"
		nRetorno:=aNfItem[nItem][cPosCpo[1]][cPosCpo[2]]
	Else
		nRetorno:=aNfItem[nItem][Val(cPosCpo)]
	EndIf
Case Substr(cCampo,1,2) == "LF"
	If nItem == Nil
		nRetorno:=aNfItem[nItem][NF_LIVRO][cPosCpo]
	Else
		nRetorno:=aNfItem[nItem][IT_LIVRO][cPosCpo]
	EndIf
OtherWise
	If ValType(cPosCpo) == "A"
		nRetorno:=aNfCab[cPosCpo[1]][cPosCpo[2]]
	Else
		nRetorno:=aNfCab[Val(cPosCpo)]
	EndIf
EndCase

Return nRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisFound³ Autor ³ Edson Maricate        ³ Data ³08.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se o item ja existe na relacao de itens incluidos. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Valor do imposto.                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisFound(cCampo,nItem)
Local lRetorno := .T.

If aNfItem <> Nil
	If cCampo == "IT"
		If nItem > Len(aNfItem)
			lRetorno := .F.
		EndIf
	Else
		If Empty(aNfCab)
			lRetorno := .F.
		EndIf
	EndIf
Else
	lRetorno := .F.
EndIf

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisScan ³ Autor ³Eduardo/Edson          ³ Data ³02.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de procura da posicao da referencia nos arrays inter ³±±
±±³          ³nos                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpX1: Posicao da referencia                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Codigo da Referencia                               ³±±
±±³          ³ ExpL2 : Flag de indicacao de tratamento de erro            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisScan(cCampo,lErro)

Local cPosCpo := 0
Local nScan   := 0

DEFAULT lErro := .T.

If aItemRef == Nil
	MaIniRef()
EndIf

If Substr(cCampo,1,2) == "IT"
	nScan	:= aScan(aItemRef,{|x|x[1]==cCampo})
	If nScan > 0
		cPosCpo	:= aItemRef[nScan][2]
	Else
		If lErro
			MsgAlert(STR0001 + cCampo ) //"ERRO MATXFIS - Referencia de imposto invalida : "
			Final(STR0002) //"ERRO MATXFIS - Referencia de imposto invalida "
		EndIf
	EndIf
ElseIf Substr(cCampo,1,2) == "NF"
	nScan	:= aScan(aCabRef,{|x|x[1]==cCampo})
	If nScan > 0
		cPosCpo	:= aCabRef[nScan][2]
	Else
		If lErro
			MsgAlert(STR0001 + cCampo ) //"ERRO MATXFIS - Referencia de imposto invalida : "
			Final(STR0002) //"ERRO MATXFIS - Referencia de imposto invalida "
		EndIf
	EndIf
ElseIf Substr(cCampo,1,2) == "LF"
	nScan	:= aScan(aLFis,{|x|x[1]==cCampo})
	If nScan > 0
		cPosCpo	:= aLFis[nScan][2]
	Else
		If lErro
			MsgAlert(STR0001 + cCampo ) //"ERRO MATXFIS - Referencia de imposto invalida : "
			Final(STR0002) //"ERRO MATXFIS - Referencia de imposto invalida "
		EndIf
	EndIf
ElseIf Substr(cCampo,1,3) == "IMP"
	nScan 	:= aScan(aResRef,{|x|x[1]==cCampo})
	If nScan > 0
		cPosCpo	:= aResRef[nScan][2]
	Else
		If lErro
			MsgAlert(STR0001 + cCampo ) //"ERRO MATXFIS - Referencia de imposto invalida : "
			Final(STR0002) //"ERRO MATXFIS - Referencia de imposto invalida "
		EndIf
	EndIf
EndIf
Return(cPosCpo)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisBSICA³ Autor ³ Edson Maricate        ³ Data ³08.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa o calculo da Base do ICMS do frete Autonomo.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisBSICA(nX)

If aTes[TS_FRETAUT] <> "2"
	aNfItem[nX][IT_BASEICA] := aNfItem[nX][IT_AUTONOMO]
Else
	aNfItem[nX][IT_BASEICA] := 0
EndIf

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisVlICA³ Autor ³ Edson Maricate        ³ Data ³08.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa o calculo do Valor do ICMS do Frete Autonomo.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisVLICA(nX)

If aTes[TS_ICM] <> "N"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo do valor do ICMS do frete autonomo do item.         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aNfItem[nX][IT_VALICA]	:= aNfItem[nX][IT_BASEICA]*aNfItem[nX][IT_ALIQICM]/100
Else
	aNfItem[nX][IT_VALICA]	:= 0
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisBSICM³ Autor ³ Edson Maricate        ³ Data ³08.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa o calculo da Base do ICMS do Item.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisBSICM(nX,lReproc,lZF)

Local nSalvaBase := 0
Local lIncide    := .F.
Local nReduzICMS := 0
Local nDespOri   := 0
Local nBsFrete   := 0
Local lRet       := .F.
Local lVlr_Frt   := .F.

DEFAULT lZF := .F.

//-- Na devolucao integral a base do ICMS devera ser a mesma da nota original.
If ( aNFCab[NF_TIPONF] $ "DB" .OR. aTes[TS_PODER3] =="D" ) .AND. !Empty(aNFItem[nX][IT_RECORI])
	If aNFCab[NF_TIPONF] $ "DB"
		If ( aNFCab[NF_CLIFOR] == "C")
			dbSelectArea("SD2")
			MsGoto(aNFItem[nX][IT_RECORI])
			If aNfItem[nX][IT_QUANT] == SD2->D2_QUANT .AND. SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0
				aNfItem[nX][IT_BASEICM] := SD2->D2_BASEICM
				lRet := .T.
			EndIf
		Else
			dbSelectArea("SD1")
			MsGoto(aNFItem[nX][IT_RECORI])
			If aNfItem[nX][IT_QUANT] == SD1->D1_QUANT .AND. SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0
				aNfItem[nX][IT_BASEICM] := SD1->D1_BASEICM
				lRet := .T.
			EndIf
		EndIf
	Else
		If ( aNFCab[NF_CLIFOR] == "C")
			dbSelectArea("SD1")
			MsGoto(aNFItem[nX][IT_RECORI])
			If aNfItem[nX][IT_QUANT] == SD1->D1_QUANT .AND. SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0
				aNfItem[nX][IT_BASEICM] := SD1->D1_BASEICM
				lRet := .T.
			EndIf
		Else
			dbSelectArea("SD2")
			MsGoto(aNFItem[nX][IT_RECORI])
			If aNfItem[nX][IT_QUANT] == SD2->D2_QUANT .AND. SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0
				aNfItem[nX][IT_BASEICM] := SD2->D2_BASEICM
				lRet := .T.
			EndIf
		EndIf
	EndIf
EndIf

If !lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega a reducao da base do ICMS                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aNFitem[nX,IT_EXCECAO]) .AND. aNfItem[nX,IT_EXCECAO,14] > 0
		nReduzICMS := aNfItem[nX,IT_EXCECAO,14]
	Else
		nReduzICMS := aTes[TS_BASEICM]
	EndIf
	aNfItem[nX,IT_PREDIC] := nReduzICMS

	lReproc := IIf(lReproc==Nil,.F.,lReproc)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva  a base do ICMS no reprocessamento.                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nSalvaBase	:= aNfItem[nX][IT_BASEICM]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo da base de ICMS - Valor da Mercadoria               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aTes[TS_AGREG]<>"F"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Alteracao realizada caso o produto tenha o TES configurado³
		//³para aplicacao de Deducao ICM                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FunName() == "FRTA010" .AND. aTes[TS_AGREG] == "D"
			aNfItem[nX][IT_BICMORI]	:= aNfItem[nX][IT_VALMERC] + IIf(!lZF,aNfItem[nX][IT_DESCZF],0)
		Else
			aNfItem[nX][IT_BICMORI]	:= aNfItem[nX][IT_VALMERC] - aNfItem[nX][IT_DESCONTO] + IIf(!lZF,aNfItem[nX][IT_DESCZF],0)
		Endif
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo da base de ICMS - Pauta fiscal                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( MaSbCampo("INT_ICM")<>Nil .AND.  MaSbCampo("INT_ICM")<>0 ) .OR. (!Empty(aNFitem[nX][IT_EXCECAO]) .AND. aNfItem[nX][IT_EXCECAO][16]<>0)
		If Len (aNfItem[nX][IT_EXCECAO])>0 .AND. aNfItem[nX][IT_EXCECAO][16]<>0
			If Max(aNfItem[nX][IT_QUANT]*aNfItem[nX][IT_EXCECAO][16],aNfItem[nX][IT_BICMORI]) <> aNfItem[nX][IT_BICMORI]
				aNfItem[nX][IT_BICMORI] := aNfItem[nX][IT_QUANT]*aNfItem[nX][IT_EXCECAO][16]
				aNfItem[nX][IT_PAUTIC]  := aNfItem[nX][IT_EXCECAO][16]
			EndIf
		Else
			If !Empty(aNFItem[nX][IT_VLR_FRT])
				If (aNfItem[nX][IT_BICMORI]+aNfItem[nX][IT_FRETE]) < (aNfItem[nX][IT_QUANT]*MaSbCampo("INT_ICM")+aNfItem[nX][IT_VLR_FRT])
					aNfItem[nX][IT_BICMORI] := aNfItem[nX][IT_QUANT]*MaSbCampo("INT_ICM")
					aNfItem[nX][IT_PAUTIC]  := MaSbCampo("INT_ICM")
					lVlr_Frt := .T.
				EndIf
			Else
				If Max(aNfItem[nX][IT_QUANT]*MaSbCampo("INT_ICM"),aNfItem[nX][IT_BICMORI]) <> aNfItem[nX][IT_BICMORI]
					aNfItem[nX][IT_BICMORI] := aNfItem[nX][IT_QUANT]*MaSbCampo("INT_ICM")
					aNfItem[nX][IT_PAUTIC]  := MaSbCampo("INT_ICM")
				EndIf
			EndIf
		EndIf
		If !Empty(GetNewPar("MV_ICMPFAT",""))
			aNfItem[nX][IT_BICMORI] *= MaSBCampo(SubStr(GetNewPar("MV_ICMPFAT",""),4))
		EndIf
		If GetNewPar("MV_ICPAUTA","1")=="2"
			If aTES[TS_DESPRDIC] $ " 1"
				If lVlr_Frt
					aNfItem[nX][IT_BICMORI]	+= aNfItem[nX][IT_VLR_FRT]
				Else
					aNfItem[nX][IT_BICMORI]	+= aNfItem[nX][IT_FRETE]
				EndIf
				aNfItem[nX][IT_BSFRETE]	:= aNfItem[nX][IT_FRETE]
				If aTes[TS_DESPICM] <> "2"
					aNfItem[nX][IT_BICMORI]	+= aNfItem[nX][IT_DESPESA]
					aNfItem[nX][IT_BICMORI]	+= aNfItem[nX][IT_SEGURO]
				EndIf
			Else
				If lVlr_Frt
					nDespOri += aNfItem[nX][IT_VLR_FRT]
				Else
					nDespOri += aNfItem[nX][IT_FRETE]
				EndIf
				nBsFrete += aNfItem[nX][IT_FRETE]
				If aTes[TS_DESPICM] <> "2"
					nDespOri += aNfItem[nX][IT_DESPESA]
					nDespOri += aNfItem[nX][IT_SEGURO]
				EndIf
			EndIf
		EndIf
	Else
		If aTES[TS_DESPRDIC] $ "1 "
			aNfItem[nX][IT_BICMORI]	+= aNfItem[nX][IT_FRETE]
			aNfItem[nX][IT_BSFRETE]	:= aNfItem[nX][IT_FRETE]
			If aTes[TS_DESPICM] <> "2"
				aNfItem[nX][IT_BICMORI]	+= aNfItem[nX][IT_DESPESA]
				aNfItem[nX][IT_BICMORI]	+= aNfItem[nX][IT_SEGURO]
			EndIf
		Else
			nDespOri += aNfItem[nX][IT_FRETE]
			nBsFrete += aNfItem[nX][IT_FRETE]
			If aTes[TS_DESPICM] <> "2"
				nDespOri += aNfItem[nX][IT_DESPESA]
				nDespOri += aNfItem[nX][IT_SEGURO]
			EndIf
		EndIf
	EndIf
	If aTes[TS_INCIDE] == "S" .OR. (aTes[TS_INCIDE] == "F" .AND. aNFCab[NF_TPCLIFOR] =="F" .AND. aNFCab[NF_CLIFOR] =="C")
		lIncide := .T.
		If aNFitem[nX][IT_TIPONF ] <> "P"
			aNfItem[nX][IT_BICMORI]	+= aNfItem[nX][IT_VALIPI]
		Else
			aNfItem[nX][IT_BICMORI]	:= aNfItem[nX][IT_VALIPI]
		EndIf
		If aNfItem[nX][IT_BSFRETE] <> 0
			aNfItem[nX][IT_BSFRETE]	+= aNfItem[nX][IT_VALIPI]
		EndIf
		If aTes[TS_IPILICM] <> "1"
			aNfItem[nX][IT_VIPIBICM]:= (aNfItem[nX][IT_VALIPI])
		Else
			aNfItem[nX][IT_VIPIBICM]:= 0
		EndIf
	EndIf
	If (aTes[TS_ICM] <> "N" .AND. !aNFitem[nX][IT_TIPONF ]$"IP") .OR. (aNFitem[nX][IT_TIPONF ]=="P".AND.lIncide)
		If aTes[TS_AGREG]=="I" .OR. aTes[TS_AGREG]=="A"
			aNfItem[nX][IT_BICMORI]	:= Round(aNfItem[nX][IT_BICMORI]/( 1 - (aNfItem[nX][IT_ALIQICM]/100*IIF(nReduzICMS==0,1,nReduzICMS/100))),2)
			aNfItem[nX][IT_BSFRETE]	:= Round(aNfItem[nX][IT_BSFRETE]/( 1 - (aNfItem[nX][IT_ALIQICM]/100*IIF(nReduzICMS==0,1,nReduzICMS/100))),2)
			nDespOri := nDespOri/( 1 - (aNfItem[nX][IT_ALIQICM]/100))
			nBsFrete := nBsFrete/( 1 - (aNfItem[nX][IT_ALIQICM]/100))
		EndIf
		If ( aTes[TS_AGREG]=="D" )
			If ( nReduzICMS > 0)
				aNfItem[nX][IT_DEDICM]	:= Round(aNfItem[nX][IT_BICMORI]*aNfItem[nX][IT_ALIQICM]/100*(1-(nReduzICMS/100)),2)
			Else
				aNfItem[nX][IT_DEDICM]	:= aNfItem[nX][IT_BICMORI]-Round(aNfItem[nX][IT_BICMORI]*( 1 - (aNfItem[nX][IT_ALIQICM]/100*IIF(nReduzICMS==0,1,nReduzICMS/100))),2)
			EndIf
		EndIf
		If (aTes[TS_AGREG]=="E" )
			aNfItem[nX][IT_DEDICM]	:= aNfItem[nX][IT_BICMORI]-Round(aNfItem[nX][IT_BICMORI]*( 1 - (aNfItem[nX][IT_ALIQICM]/100*IIF(nReduzICMS==0,1,nReduzICMS/100))),2)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Salva a base de ICMS original e aplica a reducao.           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNfItem[nX][IT_BASEICM]	:= aNfItem[nX][IT_BICMORI]
		If nReduzICMS > 0
			aNfItem[nX][IT_BASEICM]	:= aNfItem[nX][IT_BASEICM] * nReduzICMS /100
			MaItArred(nX,{"IT_BASEICM"})
			aNfItem[nX][IT_BSFRETE]	:= aNfItem[nX][IT_BSFRETE] * nReduzICMS /100
			MaItArred(nX,{"IT_BSFRETE"})
			If aTes[TS_INCIDE] == "S"  .OR. (aTes[TS_INCIDE] == "F" .AND. aNFCab[NF_TPCLIFOR] =="F" .AND. aNFCab[NF_CLIFOR] =="C")
				aNfItem[nX][IT_VIPIBICM]	:= NoRound(aNfItem[nX][IT_VIPIBICM]* nReduzICMS /100,2)
			Else
				aNfItem[nX][IT_VIPIBICM]	:= 0
			EndIf
		EndIf
		If aTES[TS_DESPRDIC] == "2"
			aNfItem[nX][IT_BASEICM] += nDespOri
			aNfItem[nX][IT_BICMORI] += nDespOri
			aNfItem[nX][IT_BSFRETE] += nBsFrete
		EndIf
	Else
		aNfItem[nX][IT_BASEICM]	:= 0
		aNfItem[nX][IT_BSFRETE]	:= 0
	EndIf
	If lReproc
		aNfItem[nX][IT_BASEICM]	:= nSalvaBase
	EndIf
Else
	If !(aTes[TS_ICM] <> "N" .AND. !aNFitem[nX][IT_TIPONF ]$"IP") .OR. (aNFitem[nX][IT_TIPONF ]=="P".AND.lIncide)
		aNfItem[nX][IT_BASEICM]	:= 0
		aNfItem[nX][IT_BSFRETE]	:= 0
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisVICMS³ Autor ³ Edson Maricate        ³ Data ³08.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa o calculo do Valor do ICMS  do Item.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisVICMS(nX,lReproc)

Local nSavValICM := 0
Local nSValICMFR := 0

DEFAULT lReproc  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva o valor do ICMS no reprocessamento.                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nSavValICM := aNfItem[nX][IT_VALICM]
nSValICMFR := aNfItem[nX][IT_ICMFRETE]

If aTes[TS_ICM] <> "N"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo do valor do ICMS do item.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aNFitem[nX][IT_TIPONF ] == "I"
		If aTes[TS_AGREG]<>"F"
			aNfItem[nX][IT_VALICM]	:= aNfItem[nX][IT_VALMERC]
		EndIf
		aNfItem[nX][IT_ICMFRETE]	:= 0
	Else
		aNfItem[nX][IT_VALICM]	   := aNfItem[nX][IT_BASEICM]*aNfItem[nX][IT_ALIQICM]/100
		aNfItem[nX][IT_ICMFRETE]	:= aNfItem[nX][IT_BSFRETE]*aNfItem[nX][IT_ALIQICM]/100
		If aNFCab[NF_TIPONF] $ "DB" .OR. aTes[TS_PODER3] =="D"
			If !Empty(aNFItem[nX][IT_RECORI])
				If aNFCab[NF_TIPONF] $ "DB"
					If ( aNFCab[NF_CLIFOR] == "C")
						dbSelectArea("SD2")
						MsGoto(aNFItem[nX][IT_RECORI])
						If ((SD2->D2_VALICM > 0 .AND. aNfItem[nX][IT_VALICM] = 0) .OR. Abs(aNfItem[nX][IT_VALICM]-SD2->D2_VALICM)<=1) .AND. aNfItem[nX][IT_QUANT] == SD2->D2_QUANT .AND. SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0
							aNfItem[nX][IT_VALICM] := SD2->D2_VALICM
						EndIf
					Else
						dbSelectArea("SD1")
						MsGoto(aNFItem[nX][IT_RECORI])
						If ((SD1->D1_VALICM > 0 .AND. aNfItem[nX][IT_VALICM] = 0) .OR. Abs(aNfItem[nX][IT_VALICM]-SD1->D1_VALICM)<=1) .AND. aNfItem[nX][IT_QUANT] == SD1->D1_QUANT .AND. SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0
							aNfItem[nX][IT_VALICM] := SD1->D1_VALICM
						EndIf
					EndIf
				Else
					If ( aNFCab[NF_CLIFOR] == "C")
						dbSelectArea("SD1")
						MsGoto(aNFItem[nX][IT_RECORI])
						If ((SD1->D1_VALICM > 0 .AND. aNfItem[nX][IT_VALICM] = 0) .OR. Abs(aNfItem[nX][IT_VALICM]-SD1->D1_VALICM)<=1) .AND. aNfItem[nX][IT_QUANT] == SD1->D1_QUANT .AND. SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0
							aNfItem[nX][IT_VALICM] := SD1->D1_VALICM
						EndIf
					Else
						dbSelectArea("SD2")
						MsGoto(aNFItem[nX][IT_RECORI])
						If ((SD2->D2_VALICM > 0 .AND. aNfItem[nX][IT_VALICM] = 0) .OR. Abs(aNfItem[nX][IT_VALICM]-SD2->D2_VALICM)<=1) .AND. aNfItem[nX][IT_QUANT] == SD2->D2_QUANT .AND. SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0
							aNfItem[nX][IT_VALICM] := SD2->D2_VALICM
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Else
	aNfItem[nX][IT_VALICM]	 := 0
	aNfItem[nX][IT_ICMFRETE] := 0
EndIf
If aTes[TS_AGREG]=="I" .OR. aTes[TS_AGREG]=="A"
	aNfItem[nX][IT_VALICM]   := Round(aNfItem[nX][IT_VALICM],2)
	aNfItem[nX][IT_ICMFRETE] := Round(aNfItem[nX][IT_ICMFRETE],2)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna o valor do ICMS no reprocessamento para calcular ICMS Diferido.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lReproc
	aNfItem[nX][IT_VALICM]   := nSavValICM
EndIf

aNfItem[nX][IT_ICMSDIF] := 0

If aTes[TS_ICMSDIF]=="1"
	aNfItem[nX][IT_ICMSDIF] := aNfItem[nX][IT_VALICM]
EndIf
If  aTES[TS_PICMDIF]<>0 .AND. aTES[TS_PICMDIF]<>100
	aNfItem[nX][IT_ICMSDIF] := aNfItem[nX][IT_VALICM]*aTes[TS_PICMDIF]/100
	MaItArred(nX,{"IT_ICMSDIF"})
EndIf
If aTes[TS_ICMSDIF]=="3" .Or. aTes[TS_ICMSDIF]=="4"
	aNfItem[nX][IT_VALICM] -= aNfItem[nX][IT_ICMSDIF]
EndIf

MaItArred(nX,{"IT_VALICM"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna o valor do ICMS no reprocessamento.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lReproc
	aNfItem[nX][IT_VALICM]   := nSavValICM
	aNfItem[nX][IT_ICMFRETE] := nSValICMFR
EndIf

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaFisBSIPI³ Autor ³Edson Maricate         ³ Data ³08.12.1999 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de calculo da base do imposto sobre produtos industri-³±±
±±³          ³alizacos ( IPI ).                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item do Array ANFItem que deve ser calculado          ³±±
±±³          ³ExpL2: Indica se o calculo nao deve ser efetuado, assim somen³±±
±±³          ³       te as variaveis devem ser inicializadas               ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo calcular a base de IPI conforme³±±
±±³          ³definido no Regulamento do IPI. A base eh calculada para o   ³±±
±±³          ³IPI de pauta e para o IPI Normal.                            ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisBSIPI(nX,lBsOri)

Local nSalvaBase := aNfItem[nX][IT_BASEIPI]
Local nReduzIPI  := 0
DEFAULT lBsOri := .F.

If !Empty(aNFitem[nX,IT_EXCECAO]) .AND. aNfItem[nX,IT_EXCECAO,15] > 0
	nReduzIPI := aNfItem[nX,IT_EXCECAO,15]
Else
	nReduzIPI := aTes[TS_BASEIPI]
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona os registros necessarios                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasPROD)
If aNfItem[nX][IT_RECNOSB1] <> 0 .AND. cAliasPROD=="SB1"
	MsGoto(aNfItem[nX][IT_RECNOSB1])
Else
	dbSetOrder(1)
	MsSeek(xFilial(cAliasPROD)+aNfItem[nX][IT_PRODUTO])
EndIf
MaFisTes(aNfItem[nX][IT_TES],aNfItem[nX][IT_RECNOSF4],nX)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o IPI deve ser calculado                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( aTes[TS_IPI] <> "N" .AND. !aNFitem[nX][IT_TIPONF ] $ "PI" )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo da base de IPI.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aTes[TS_AGREG]<>"F"
		aNfItem[nX][IT_BASEIPI]	:= aNfItem[nX][IT_VALMERC]-aNfItem[nX][IT_DESCONTO]-IIf(aTes[TS_AGREG]$"D",aNfItem[nX][IT_DEDICM],0)
	EndIf
	If aTes[TS_DESPIPI] <> "N"
		aNfItem[nX][IT_BASEIPI] += aNfItem[nX][IT_DESPESA]
		aNfItem[nX][IT_BASEIPI] += aNfItem[nX][IT_SEGURO]
	EndIf
	If aTes[TS_IPIFRET] <> "N"
		aNfItem[nX][IT_BASEIPI] += aNfItem[nX][IT_FRETE]
	EndIf
	If aTes[TS_AGREG]<>"F"
		If ( aTes[TS_TPIPI]=="B" .OR. (MV_IPIBRUTO=="S" .AND. aTes[TS_TPIPI] ==" ") )
			aNfItem[nX][IT_BASEIPI] += aNfItem[nX][IT_DESCONTO]
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva a base de IPI original e aplica a reducao.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aNfItem[nX][IT_BIPIORI]	:= NoRound(aNfItem[nX][IT_BASEIPI],2)

	If ( nReduzIPI <> 0 )
		aNfItem[nX][IT_BASEIPI] := NoRound(aNfItem[nX][IT_BASEIPI] * nReduzIPI /100,2)
		aNfItem[nX][IT_PREDIPI] := nReduzIPI
	Else
		aNfItem[nX][IT_BASEIPI] := NoRound(aNfItem[nX][IT_BASEIPI],2)
	EndIf
Else
	aNfItem[nX][IT_BASEIPI]	:= 0
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a base de calculo anterior                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lBsOri
	aNfItem[nX][IT_BASEIPI] := nSalvaBase
EndIf
Return(Nil)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaFisBSIPI³ Autor ³Edson Maricate         ³ Data ³08.12.1999 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de calculo do valor do imposto sobre produtos industri³±±
±±³          ³alizacos ( IPI ).                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item do Array ANFItem que deve ser calculado          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo calcular o valor do IPI confor-³±±
±±³          ³me definido no Regulamento do IPI. O valor eh calculada para ³±±
±±³          ³o IPI de pauta e para o IPI Normal.                          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisVIPI(nX)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona os registros necessarios                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasPROD)
If aNfItem[nX][IT_RECNOSB1] <> 0 .AND. cAliasPROD=="SB1"
	MsGoto(aNfItem[nX][IT_RECNOSB1])
Else
	dbSetOrder(1)
	MsSeek(xFilial(cAliasPROD)+aNfItem[nX][IT_PRODUTO])
EndIf
MaFisTes(aNfItem[nX][IT_TES],aNfItem[nX][IT_RECNOSF4],nX)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o valor do IPI                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( aTes[TS_IPI] <> "N" .AND. aNFitem[nX][IT_TIPONF ]<>"I" )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo do IPI Normal                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aNFitem[nX][IT_TIPONF ] == "P" .OR. (MaSbCampo("VLR_IPI")==0 .AND. (Empty(aNFitem[nX][IT_EXCECAO]) .OR. aNfItem[nX][IT_EXCECAO][9]==0)) .Or. (aNFCab[NF_TIPONF] $ "DB" .OR. aTes[TS_PODER3] =="D")
		If aNFitem[nX][IT_TIPONF ] == "P"
			If aTes[TS_AGREG]<>"F"
				aNfItem[nX][IT_VALIPI]  := aNfItem[nX][IT_VALMERC]
			EndIf
		Else
			If !GetNewPar("MV_RNDIPI",.F.)
				aNfItem[nX][IT_VALIPI]  := NoRound(aNfItem[nX][IT_BASEIPI]*aNfItem[nX][IT_ALIQIPI]/100,2)
			Else
				aNfItem[nX][IT_VALIPI]  := Round(aNfItem[nX][IT_BASEIPI]*aNfItem[nX][IT_ALIQIPI]/100,2)
			EndIf
			If aNFCab[NF_TIPONF] $ "DB" .OR. aTes[TS_PODER3] =="D"
				If !Empty(aNFItem[nX][IT_RECORI])
					If aNFCab[NF_TIPONF] $ "DB"
						If ( aNFCab[NF_CLIFOR] == "C")
							dbSelectArea("SD2")
							MsGoto(aNFItem[nX][IT_RECORI])
							If ((SD2->D2_VALIPI > 0 .AND. aNfItem[nX][IT_VALIPI] = 0) .OR. Abs(aNfItem[nX][IT_VALIPI]-SD2->D2_VALIPI)<=1) .AND. aNfItem[nX][IT_QUANT] == SD2->D2_QUANT .AND. SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0
								aNfItem[nX][IT_VALIPI] := SD2->D2_VALIPI
							EndIf
						Else
							dbSelectArea("SD1")
							MsGoto(aNFItem[nX][IT_RECORI])
							If ((SD1->D1_VALIPI > 0 .AND. aNfItem[nX][IT_VALIPI] = 0) .OR. Abs(aNfItem[nX][IT_VALIPI]-SD1->D1_VALIPI)<=1) .AND. aNfItem[nX][IT_QUANT] == SD1->D1_QUANT .AND. SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0
								aNfItem[nX][IT_VALIPI] := SD1->D1_VALIPI
							EndIf
						EndIf
					Else
						If ( aNFCab[NF_CLIFOR] == "C")
							dbSelectArea("SD1")
							MsGoto(aNFItem[nX][IT_RECORI])
							If ((SD1->D1_VALIPI > 0 .AND. aNfItem[nX][IT_VALIPI] = 0) .OR. Abs(aNfItem[nX][IT_VALIPI]-SD1->D1_VALIPI)<=1) .AND. aNfItem[nX][IT_QUANT] == SD1->D1_QUANT .AND. SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0
								aNfItem[nX][IT_VALIPI] := SD1->D1_VALIPI
							EndIf
						Else
							dbSelectArea("SD2")
							MsGoto(aNFItem[nX][IT_RECORI])
							If ((SD2->D2_VALIPI > 0 .AND. aNfItem[nX][IT_VALIPI] = 0) .OR. Abs(aNfItem[nX][IT_VALIPI]-SD2->D2_VALIPI)<=1) .AND. aNfItem[nX][IT_QUANT] == SD2->D2_QUANT .AND. SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0
								aNfItem[nX][IT_VALIPI] := SD2->D2_VALIPI
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calculo do IPI de Pauta                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aNFitem[nX][IT_EXCECAO]) .AND. aNfItem[nX][IT_EXCECAO][9]<>0
			If !GetNewPar("MV_RNDIPI",.F.)
				aNfItem[nX][IT_VALIPI]  := NoRound(aNfItem[nX][IT_QUANT]*aNfItem[nX][IT_EXCECAO][9],2)
			Else
				aNfItem[nX][IT_VALIPI]  := Round(aNfItem[nX][IT_QUANT]*aNfItem[nX][IT_EXCECAO][9],2)
			EndIf
			aNfItem[nX][IT_PAUTIPI] := aNfItem[nX][IT_EXCECAO][9]
		Else
			If !GetNewPar("MV_RNDIPI",.F.)
				aNfItem[nX][IT_VALIPI]  := NoRound(aNfItem[nX][IT_QUANT]*MaSbCampo("VLR_IPI"),2)
			Else
				aNfItem[nX][IT_VALIPI]  := Round(aNfItem[nX][IT_QUANT]*MaSbCampo("VLR_IPI"),2)
			EndIf
			aNfItem[nX][IT_PAUTIPI] := MaSbCampo("VLR_IPI")
		EndIf
		If !Empty(SuperGetMV("MV_IPIPFAT"))
			aNfItem[nX][IT_VALIPI] *= MaSBCampo(SubStr(SuperGetMV("MV_IPIPFAT"),4))
		EndIf
	EndIf
Else
	aNfItem[nX][IT_VALIPI]  :=	0
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao haja valor do IPI nao se deve ter base de calculo  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aNfItem[nX][IT_VALIPI] == 0
	aNfItem[nX][IT_BASEIPI]	:= 0
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisPRC³ Autor ³ Edson Maricate          ³ Data ³08.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica o preco unitario do item                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisPRC(nItem)

If aNFitem[nItem][IT_TIPONF ]$"PIC" .AND. (cPaisLoc == "BRA" .OR. aTES[TS_QTDZERO] == "1")
	aNfItem[nItem][IT_PRCUNI]  := aNfItem[nItem][IT_VALMERC]
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaAliqSol ³ Autor ³ Edson Maricate        ³ Data ³08.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calculo da Aliquota para operacoes de ICMS Solidario.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Aliquota de ICMS Solidario                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Item                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function MaAliqSoli(nItem)

Local nAliquota := If ( MaSBCampo("PICM") == 0 , IIf(aTES[TS_ICM]<>"N",aNfItem[nItem][IT_ALIQICM],MaAliqIcms(nItem,.T.)) ,  MaSBCampo("PICM") )

If !Empty(MaFisRet(,"NF_PNF_UF")) .AND. ("CTR"$AllTrim(aNFCab[NF_ESPECIE]).OR."NFST"$AllTrim(aNFCab[NF_ESPECIE])) .AND. aNFCab[NF_OPERNF] == "S"
	nAliquota := MaAliqIcms(nItem,.T.)
Else
	If ( aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] )
		If aNFCab[NF_TIPONF] == "D"
			nAliquota := MaAliqOrig(nItem)
		Else
			nAliquota := MaAliqDest(nItem)
		EndIf
	EndIf
EndIf
If ( !Empty(aNFItem[nItem][IT_EXCECAO]) )
	If ( aNFItem[nItem][IT_EXCECAO][6] ) <> 0
		nAliquota := aNfItem[nItem][IT_EXCECAO][6]
	EndIf
EndIf
aNFitem[nItem][IT_ALIQSOL] := nAliquota
Return(nAliquota)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MaMargem ³ Autor ³ Edson Maricate        ³ Data ³08.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calculo da Margem de lucro para calculo do ICMS Solidario.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Margem de lucro.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Item                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function MaMargem(nItem)

Local nMargem  := If ( aNfCab[NF_CLIFOR] =='F'  , MaSBCampo("PICMENT"), MaSBCampo("PICMRET") )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as Excecoes fiscais                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( !Empty(aNFItem[nItem][IT_EXCECAO]) )
	If ( aNFItem[nItem][IT_EXCECAO][3] ) <> 0
		nMargem :=  aNFItem[nItem][IT_EXCECAO][3]   //Margem de Lucro Presumida
	EndIf
EndIf

aNFitem[nItem][IT_MARGEM] := nMargem

Return(nMargem)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaFisBSSol³ Autor ³Edson Maricate         ³ Data ³08.12.1999 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de calculo da base do imposto retido/solidario        ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item do Array ANFItem que deve ser calculado          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo calcular a base do solidario   ³±±
±±³          ³conforme definido no regulamento de ICMS.                    ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATXFIS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisBSSOL(nX)

Local nBsICMSt    := 0
Local nMargem     := 0
Local lValido     := .T.
Local nReduzICMS  := 0
Local lTipoCliFor := .F.
Local cTipoCliFor := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega o tipo do cliente pagador ou destinario             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aNfCab[NF_PNF_TPCLIFOR])
	lTipoCliFor := aNfCab[NF_PNF_TPCLIFOR]$SuperGetMV("MV_TPSOLCF")
	cTipoCliFor := aNfCab[NF_PNF_TPCLIFOR]
Else
	lTipoCliFor := aNfCab[NF_TPCLIFOR]$SuperGetMV("MV_TPSOLCF")
	cTipoCliFor := aNfCab[NF_TPCLIFOR]
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega a reducao da base do ICMS                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aNFitem[nX,IT_EXCECAO]) .AND. aNfItem[nX,IT_EXCECAO,14] > 0
	nReduzICMS := aNfItem[nX,IT_EXCECAO,14]
Else
	nReduzICMS := aTes[TS_BASEICM]
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona os registros necessarios                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasPROD)
If aNfItem[nX][IT_RECNOSB1] <> 0 .AND. cAliasPROD=="SB1"
	MsGoto(aNfItem[nX][IT_RECNOSB1])
Else
	dbSetOrder(1)
	MsSeek(xFilial(cAliasPROD)+aNfItem[nX][IT_PRODUTO])
EndIf
MaFisTes(aNfItem[nX][IT_TES],aNfItem[nX][IT_RECNOSF4],nX)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se deve-se calcular o ICMS solidario               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aTES[TS_MKPCMP]<>"1" .AND. !(aNFitem[nX][IT_TIPONF ]$'IP') .AND. IIf(aNfCab[NF_OPERNF]=="S".AND.aNFCab[NF_CLIFOR] == "C",lTipoCliFor,.T.)

	If aNFCab[NF_TIPONF]$"DB"
		If !Empty(aNFItem[nX][IT_RECORI])
			If ( aNFCab[NF_CLIFOR] == "C" )
				dbSelectArea("SD2")
				MsGoto( aNFItem[nX][IT_RECORI] )
				dbSelectArea("SF2")
				dbSetOrder(1)
				If MsSeek(xFilial("SF2")+(SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA))
					If SF2->F2_TIPOCLI$SuperGetMV("MV_TPSOLCF")
						lValido := .T.
					Else
						lValido := .F.
					EndIf
				Endif
			Else
				dbSelectArea("SD1")
				MsGoto( aNFItem[nX][IT_RECORI] )
				dbSelectArea("SF1")
				dbSetOrder(1)
				If MsSeek(xFilial("SF1")+(SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
					If SF1->F1_BRICMS > 0
						lValido := .T.
					Else
						lValido := .F.
					EndIf
				Endif
			Endif
		Endif
	EndIf

	If lValido
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calculo do Solidario pela Margem de lucro                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If MaSbCampo("VLR_ICM")==0 .AND. (Empty(aNFitem[nX][IT_EXCECAO]) .OR. aNfItem[nX][IT_EXCECAO][8]==0) .Or.;
			(!Empty(aNFitem[nX][IT_EXCECAO]) .And. aNfItem[nX][IT_EXCECAO][20] == "2" .And. aNfItem[nX][IT_EXCECAO][8] == 0)
			If aNfItem[nX][IT_MARGEM] > 0
				nMargem := aNfItem[nX][IT_MARGEM]
				aNfItem[nX][IT_BASESOL] := IIf(aTes[TS_AGREG]<>"F",aNfItem[nX][IT_VALMERC]-IIf(aTes[TS_AGREG]$"D",aNfItem[nX][IT_DEDICM],0),0)+aNfItem[nX][IT_VALIPI]+aNfItem[nX][IT_FRETE]
				If aTes[TS_DESPICM] <> "2" .OR. GetNewPar("MV_DESPICM",.T.)
					aNfItem[nX][IT_BASESOL] += 	aNfItem[nX][IT_SEGURO]+aNfItem[nX][IT_DESPESA]
				EndIf
				If aTes[TS_FRETAUT] == "2"
					aNfItem[nX][IT_BASESOL] += aNfItem[nX][IT_AUTONOMO]
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se nao calcular o ICMS Normal soma-lo na base de ICMS ST    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aNfItem[nX][IT_VALICM] == 0 .AND. aTES[TS_ICMSST] <> "2" .AND. aNfItem[nX][IT_DESCZF] == 0
					aNfItem[nX][IT_BASESOL] /= (1 - (MaAliqIcms(nX,.T.)/100))
				EndIf
				If aTes[TS_AGREG]<>"F"
					If !MV_SOLBRUT .OR. aTes[TS_STDESC] == "1"
						aNfItem[nX][IT_BASESOL] -= aNfItem[nX][IT_DESCONTO]
					EndIf
				EndIf

				If !MV_DSZFSOL
					aNfItem[nX][IT_BASESOL] += aNfItem[nX][IT_DESCZF]
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Operacoes de venda para consumidor final nao podem ter      ³
				//³ margem de lucro se o destino for para uso e consumo.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (( aTes[TS_CONSUMO]=="S" .AND.;
						(	( cTipoCliFor=="F" .AND. aNfCab[NF_CLIFOR]=="C" ) .OR. ( aNfCab[NF_CLIFOR]=="F" ) ) .AND.;
						aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] ) .OR. aTes[TS_MKPSOL]=="1") .AND. aTES[TS_MKPSOL]<>"3"
					nMargem := 0
				EndIf
				If aTes[TS_INCSOL] <> "A"
					aNfItem[nX][IT_BASESOL] := aNfItem[nX][IT_BASESOL]*(1+(nMargem/100))
				EndIf
				If nReduzICMS > 0 .AND. MV_BASERET =="S"
					aNfItem[nX][IT_BASESOL] := (aNfItem[nX][IT_BASESOL]*nReduzICMS)/100
					aNfItem[nX][IT_PREDST]  := nReduzICMS
				EndIf
				If aTes[TS_BSICMST] > 0 .AND. aTes[TS_INCSOL]<>'A'
					If aTes[TS_BSICMST] == 100
						aNfItem[nX][IT_BASESOL] := 0
					Else
						aNfItem[nX][IT_BASESOL] := (aNfItem[nX][IT_BASESOL]*aTes[TS_BSICMST])/100
					EndIf
				EndIf
			Else
				aNfItem[nX][IT_BASESOL]	:= 0
			EndIf
		Else
			If !Empty(aNFitem[nX][IT_EXCECAO]) .And. (aNfItem[nX][IT_EXCECAO][8]<>0 .Or. aNfItem[nX][IT_EXCECAO][20]=="2")
				aNfItem[nX][IT_BASESOL] := aNfItem[nX][IT_QUANT]*aNfItem[nX][IT_EXCECAO][8]
				aNfItem[nX][IT_PAUTST]  := aNfItem[nX][IT_EXCECAO][8]
			Else
				aNfItem[nX][IT_BASESOL] := aNfItem[nX][IT_QUANT]*MaSbCampo("VLR_ICM")
				aNfItem[nX][IT_PAUTST]  := MaSbCampo("VLR_ICM")
			EndIf
			If !Empty(SuperGetMV("MV_ICMPFAT"))
				aNfItem[nX][IT_BASESOL] *= MaSBCampo(SubStr(SuperGetMV("MV_ICMPFAT"),4))
			EndIf
			If GetNewPar("MV_ICPAUTA","1")=="2" //1=Sem Frete/Despesa/Seguro - 2=Com Frete/Despesa/Seguro
				If !Empty(aNFItem[nX][IT_VLR_FRT])
					aNfItem[nX][IT_BASESOL] += aNfItem[nX][IT_VLR_FRT]+aNfItem[nX][IT_SEGURO]+aNfItem[nX][IT_DESPESA]
				Else
					aNfItem[nX][IT_BASESOL] += aNfItem[nX][IT_FRETE]+aNfItem[nX][IT_SEGURO]+aNfItem[nX][IT_DESPESA]
				EndIf
			EndIf
			nBsICMSt := IIf(aTes[TS_AGREG]<>"F",aNfItem[nX][IT_VALMERC]-IIf(aTes[TS_AGREG]$"D",aNfItem[nX][IT_DEDICM],0),0)+aNfItem[nX][IT_VALIPI]+aNfItem[nX][IT_FRETE]+aNfItem[nX][IT_SEGURO]+aNfItem[nX][IT_DESPESA]
			If aTes[TS_FRETAUT] == "2"
				nBSICMSt += aNfItem[nX][IT_AUTONOMO]
			EndIf
			If !MV_SOLBRUT .OR. aTes[TS_STDESC] == "1"
				nBsICMSt -= aNfItem[nX][IT_DESCONTO]
			EndIf
			If !MV_DSZFSOL
				nBsICMSt += aNfItem[nX][IT_DESCZF]
				aNfItem[nX][IT_BASESOL] += aNfItem[nX][IT_DESCZF]
			EndIf
			If nReduzICMS > 0 .AND. MV_BASERET =="S"
				nBsICMSt := (aNfItem[nX][IT_BASESOL]*nReduzICMS)/100
				aNfItem[nX][IT_BASESOL] := (aNfItem[nX][IT_BASESOL]*nReduzICMS)/100
				aNfItem[nX][IT_PREDST]  := nReduzICMS
			EndIf
			If aTes[TS_BSICMST] > 0
				If aTes[TS_BSICMST] == 100
					nBSICMSt := 0
					aNfItem[nX][IT_BASESOL] := 0
				Else
					nBsICMSt := (aNfItem[nX][IT_BASESOL]*aTes[TS_BSICMST])/100
					aNfItem[nX][IT_BASESOL] := (aNfItem[nX][IT_BASESOL]*aTes[TS_BSICMST])/100
				EndIf
			EndIf
			If aNfItem[nX][IT_MARGEM] > 0 .AND. GetNewPar("MV_MKPICPT","1")=="2"
				nMargem := aNfItem[nX][IT_MARGEM]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Operacoes de venda para consumidor final nao podem ter      ³
				//³ margem de lucro se o destino for para uso e consumo.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (( aTes[TS_CONSUMO]=="S" .AND.;
						(	( cTipoCliFor=="F" .AND. aNfCab[NF_CLIFOR]=="C" ) .OR. ( aNfCab[NF_CLIFOR]=="F" ) ) .AND.;
						aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] ) .OR. aTes[TS_MKPSOL]=="1") .AND. aTes[TS_MKPSOL]<>"3"
					nMargem := 0
				EndIf
				If aTes[TS_INCSOL] <> "A"
					aNfItem[nX][IT_BASESOL] := aNfItem[nX][IT_BASESOL]*(1+(nMargem/100))
					nBsICMSt                 := nBsICMSt*(1+(nMargem/100))
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calculo do valor total para acertar o ICMS de Pauta         ³
			//³ A pauta nao pode ser menor que o valor comercializado       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !SuperGetMV("MV_ICMPAUT")
				If ( nBsICMSt > aNfItem[nX][IT_BASESOL] )
					aNfItem[nX][IT_BASESOL] := nBsICMSt
					aNfItem[nX][IT_PAUTST]  := 0
				EndIf
			EndIf
		EndIf
	Else
		aNfItem[nX][IT_BASESOL]	:= 0
	EndIf
Else
	aNfItem[nX][IT_BASESOL]	:= 0
EndIf
MaItArred(nX,{"IT_BASESOL"})
Return(Nil)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaFisVSol ³ Autor ³Edson Maricate         ³ Data ³08.12.1999 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de calculo do ICMS retido/solidario                   ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item do Array ANFItem que deve ser calculado          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo calcular o valor do ICMS retido³±±
±±³          ³/solidario conforme definido do regulamento de ICMS.         ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATXFIS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisVSOL(nItem)

If !(aNFitem[nItem][IT_TIPONF ]$'IP')
	If aNfItem[nItem][IT_BASESOL] <> 0
		MaFisTes(aNfItem[nItem][IT_TES],aNfItem[nItem][IT_RECNOSF4],nItem)
		If aTES[TS_INCSOL]=="A"
			aNfItem[nItem][IT_VALSOL] := ( aNfItem[nItem][IT_BASESOL]*(aNfItem[nItem][IT_MARGEM]/100) )
			aNfItem[nItem][IT_VALSOL] := ( aNfItem[nItem][IT_VALSOL] * aNfItem[nItem][IT_ALIQSOL]/100 )
			If aTes[TS_BSICMST] > 0
				aNfItem[nItem][IT_VALSOL] := (aNfItem[nItem][IT_VALSOL]*aTes[TS_BSICMST])/100
			EndIf
			MaItArred(nItem,{"IT_VALSOL"})
			aNfItem[nItem][IT_VALICM] -= Max(0,NoRound(aNfItem[nItem][IT_VALSOL]*aNfItem[nItem][IT_ALIQICM]/100,2))
			MaItArred(nItem,{"IT_VALICM"})
		Else
			aNfItem[nItem][IT_VALSOL] := ( aNfItem[nItem][IT_BASESOL] * aNfItem[nItem][IT_ALIQSOL]/100 )
			MaItArred(nItem,{"IT_VALSOL"})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento implementado para os estados de MG e AM referente ao credito presumido do contratante do servico de transporte.  ³
			//³    Este tratamento deve refletir o calculo do ICMS Normal de direito do contratante e o ICMS Retido como debito na apuracao³
			//³    jah deduzindo o Credito presumido.                                                                                      ³
			//³    Ex: Em uma operacao interna, a entrada do CTR no valor de R$1.000,00 deverah ficar da seguinte forma:                   ³
			//³                                                                                                                            ³
			//³    ICMS Normal                                                                                                             ³
			//³    BC = 1000, Aliq = 18, VL ICMS = 180                                                                                     ³
			//³                                                                                                                            ³
			//³    ICMS Retido                                                                                                             ³
			//³    BC = 1000, Aliq = 18, VL ICMS Ret = 144, CRED PRES = 36                                                                 ³
			//³                                                                                                                            ³
			//³    OBS: Este valor retido de 144 eh lancado automaticamente na Apuracao de ICMS/ST em outros debitos devido a configuracao ³
			//³         da TES(F4_CREDST=3)                                                                                                |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If	!(SuperGetMv("MV_ESTADO")$"MG/AM" .And.;
				aTes[TS_CRPRST]<>0 .And.;
				("CTR"$AllTrim(aNFCab[NF_ESPECIE]) .Or. "NFST"$AllTrim(aNFCab[NF_ESPECIE])))

				aNfItem[nItem][IT_VALSOL] -= (aNfItem[nItem][IT_VALICM] + aNfItem[nItem][IT_DESCZF]  - aNfItem[nItem][IT_DESCZFPIS] - aNfItem[nItem][IT_DESCZFCOF])
			EndIf

		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Credito Presumido(20%) sobre prestacao servico de transporte com ICMS/ST devido ao alienante/remetente|
		//|  da operacao - Decreto 44.147/2005 (MG)                                                              ³
		//³- Esta sendo considerado a entrada deste credito como 100% do valor, sem a deducao (20%).Portanto devo|
		//|  subtrair do ICMS/ST Retido o valor de credito (20%), gravar na referencia LF_CRPRST que devera ser  |
		//|  tratado na apresentacao das informacoes complementares da apuracao.                                 |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aTes[TS_CRPRST]<>0
			aNfItem[nItem][IT_VLCSOL]	:=	aNfItem[nItem][IT_VALSOL]
			aNfItem[nItem][IT_VALSOL]	-=	(aNfItem[nItem][IT_VALSOL]/100)*aTes[TS_CRPRST]
			MaItArred(nItem,{"IT_VALSOL"})
		EndIf
		If aNFCab[NF_TIPONF] $ "DB" .OR. aTes[TS_PODER3] =="D"
			If !Empty(aNFItem[nItem][IT_RECORI])
				If aNFCab[NF_TIPONF] $ "DB"
					If ( aNFCab[NF_CLIFOR] == "C")
						dbSelectArea("SD2")
						MsGoto(aNFItem[nItem][IT_RECORI])
						If ((SD2->D2_ICMSRET > 0 .AND. aNfItem[nItem][IT_VALSOL] = 0) .OR. Abs(aNfItem[nItem][IT_VALSOL]-SD2->D2_ICMSRET)<=1) .AND. aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT .AND. SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0
							aNfItem[nItem][IT_VALSOL] := SD2->D2_ICMSRET
						EndIf
					Else
						dbSelectArea("SD1")
						MsGoto(aNFItem[nItem][IT_RECORI])
						If ((SD1->D1_ICMSRET > 0 .AND. aNfItem[nItem][IT_VALSOL] = 0) .OR. Abs(aNfItem[nItem][IT_VALSOL]-SD1->D1_ICMSRET)<=1) .AND. aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT .AND. SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0
							aNfItem[nItem][IT_VALSOL] := SD1->D1_ICMSRET
						EndIf
					EndIf
				Else
					If ( aNFCab[NF_CLIFOR] == "C")
						dbSelectArea("SD1")
						MsGoto(aNFItem[nItem][IT_RECORI])
						If ((SD1->D1_ICMSRET > 0 .AND. aNfItem[nItem][IT_VALSOL] = 0) .OR. Abs(aNfItem[nItem][IT_VALSOL]-SD1->D1_ICMSRET)<=1) .AND. aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT .AND. SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0
							aNfItem[nItem][IT_VALSOL] := SD1->D1_ICMSRET
						EndIf
					Else
						dbSelectArea("SD2")
						MsGoto(aNFItem[nItem][IT_RECORI])
						If ((SD2->D2_ICMSRET > 0 .AND. aNfItem[nItem][IT_VALSOL] = 0) .OR. Abs(aNfItem[nItem][IT_VALSOL]-SD2->D2_ICMSRET)<=1) .AND. aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT .AND. SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0
							aNfItem[nItem][IT_VALSOL] := SD2->D2_ICMSRET
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		If aNfItem[nItem][IT_VALSOL]<0 .AND. aNfItem[nItem][IT_BASESOL]>0
			aNfItem[nItem][IT_VALSOL]	:= 	0
		EndIf
	Else
		aNfItem[nItem][IT_VALSOL]	:= 	0
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao haja valor de ICMS solidario deve-se zerar a base  ³
//³ de calculo do ICMS-ST                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aNfItem[nItem][IT_VALSOL] == 0
	aNfItem[nItem][IT_BASESOL]	:= 0
EndIf

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaALIQCMP ³ Autor ³ Edson Maricate        ³ Data ³08.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa o calculo da aliquota do ICMS complementar.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaALIQCMP(nItem)

Local nAliquota	:= aNfItem[nItem][IT_ALIQICM]

If ( aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] )
	If ( aNFCab[NF_TIPONF] == "D" ) // devolucao
		nAliquota := Iif (MaSBCampo("PICM") <> 0,MaSBCampo("PICM"),MaAliqOrig(nItem))
	Else
		nAliquota := Iif (MaSBCampo("PICM") <> 0,MaSBCampo("PICM"),MaAliqDest(nItem))
	EndIf
EndIf

aNfItem[nItem][IT_ALIQCMP]	:= nAliquota

Return nAliquota

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisVComp³ Autor ³ Edson Maricate        ³ Data ³08.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa o calculo do ICMS Complementar.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisVComp(nItem)

Local nMargem 		:= 0
Local nBase   		:= 0
Local nReduzICMS 	:= 0
Local nVlIcmOri		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valor do ICMS original, sem a reducao na base de calculo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlIcmOri := aNfItem[nItem][IT_BICMORI] * (aNfItem[nItem][IT_ALIQICM]/100)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega a reducao da base do ICMS                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !Empty(aNFitem[nItem,IT_EXCECAO]) .AND. aNfItem[nItem,IT_EXCECAO,14] > 0
	nReduzICMS := aNfItem[nItem,IT_EXCECAO,14]
Else
	nReduzICMS := aTes[TS_BASEICM]
EndIf

aNfItem[nItem][IT_VALCMP] := 0

If aTes[TS_COMPL] == "S"
	If aTes[TS_MKPCMP]=="1"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calculo do ICMS Complementar por margem de lucro            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aNfItem[nItem][IT_MARGEM] > 0
			nMargem := aNfItem[nItem][IT_MARGEM]
			nBase   := IIf(aTes[TS_AGREG]<>"F",aNfItem[nItem][IT_VALMERC]-IIf(aTes[TS_AGREG]$"D",aNfItem[nX][IT_DEDICM],0),0)+aNfItem[nItem][IT_VALIPI]+aNfItem[nItem][IT_FRETE]+aNfItem[nItem][IT_SEGURO]+aNfItem[nItem][IT_DESPESA]
			If aTes[TS_AGREG]<>"F"
				nBase   -= aNfItem[nItem][IT_DESCONTO]
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Operacoes de venda para consumidor final nao podem ter      ³
			//³ margem de lucro se o destino for para uso e consumo.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aTes[TS_CONSUMO]=="S" .AND.;
					(	( aNfCab[NF_TPCLIFOR]=="F" .AND. aNfCab[NF_CLIFOR]=="C" ) .OR.;
					( aNfCab[NF_CLIFOR]=="F" ) ) .AND.;
					aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST]
				nMargem := 0
			EndIf
			If nReduzICMS > 0 .AND. SuperGetMv("MV_BICMCMP")
				nBase := (nBase*nReduzICMS)/100
				aNfItem[nItem][IT_PREDCMP]	:= nReduzICMS
			EndIf
			If nMargem > 0
				nBase := nBase*(1+(nMargem/100))
				aNfItem[nItem][IT_MVACMP]	:= nMargem
			EndIf
			If aTes[TS_COMPRED] == "1"
				aNfItem[nItem][IT_VALCMP] := (nBase*(aNfItem[nItem][IT_ALIQCMP]/100)) - aNfItem[nItem][IT_VALICM]
			Else
				aNfItem[nItem][IT_VALCMP] := (nBase*(aNfItem[nItem][IT_ALIQCMP]/100)) - nVlIcmOri
			Endif
		Else
			aNfItem[nItem][IT_VALCMP]	:= 0
		EndIf
	Else
		If ( aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] ) .AND. aNFCab[NF_TPCLIFOR] <> "X"
			If SuperGetMv("MV_BICMCMP")
				If aTes[TS_COMPRED] $ " 1"
					aNfItem[nItem][IT_VALCMP] := (aNfItem[nItem][IT_BASEICM]*(aNfItem[nItem][IT_ALIQCMP]/100)) - aNfItem[nItem][IT_VALICM]
				Else
					aNfItem[nItem][IT_VALCMP] := (aNfItem[nItem][IT_BASEICM]*(aNfItem[nItem][IT_ALIQCMP]/100)) - nVlIcmOri
				Endif
				aNfItem[nItem][IT_PREDCMP]	:= nReduzICMS
			Else
				If aTes[TS_COMPRED] $ " 1"
					aNfItem[nItem][IT_VALCMP] := (aNfItem[nItem][IT_BICMORI]*(aNfItem[nItem][IT_ALIQCMP]/100)) - aNfItem[nItem][IT_VALICM]
				Else
					aNfItem[nItem][IT_VALCMP] := (aNfItem[nItem][IT_BICMORI]*(aNfItem[nItem][IT_ALIQCMP]/100)) - nVlIcmOri
				Endif
				aNfItem[nItem][IT_PREDCMP]	:= 0
			EndIf
		EndIf
	EndIf
EndIf
aNfItem[nItem][IT_VALCMP] := Max(0,aNfItem[nItem][IT_VALCMP])
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaAliqOrig³ Autor ³ Edson Maricate        ³ Data ³13.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calculo da Aliquota para operacoes de ICMS                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Aliquota de ICMS                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Item                                                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaAliqOrig(nItem)

Local nPerIcm
Local cOrig := aNFCab[NF_UFORIGEM]

nPerIcm := Val(Subs(MV_ESTICM,AT(cOrig,MV_ESTICM)+2,2))

Return(nPerIcm)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisVDescZF³ Autor ³ Edson Maricate      ³ Data ³08.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa o calculo do Valor do Desconto da ZF.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisVDescZF(nItem)

Local nOldVlr := aNfItem[nItem][IT_DESCZF]
If aNfCab[NF_CLIFOR]=='C'.AND.aNfCab[NF_SUFRAMA].AND.!aNFitem[nItem][IT_TIPONF ]$'BD'.AND.;
		!aNfCab[NF_LINSCR].AND.MaSBCampo("IMPZFRC")$" N" .AND. aTes[TS_ISS]<>"S" .AND. ;
		aTes[TS_ICM]=="S" .AND. !MaFisConsumo(nItem) .AND. GetNewPar("MV_DESCZF",.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento para SUFRAMA apenas para NF de Saida MATA461    ³
	//³ Este tratamento nao deve ser utilizado nas NF que serao    ³
	//³ digitadas pelo usuario ( MATA103/MATA910/MATA920/etc.)     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aNfItem[nItem][IT_DESCZF]  := NoRound(aNfItem[nItem][IT_VALICM],2)
	aNfItem[nItem][IT_DESCZFPIS] := 0
	aNfItem[nItem][IT_DESCZFCOF] := 0
	If aNfCab[NF_ROTINA] == 'MATA461'
		aNfItem[nItem][IT_VALMERC] -= aNfItem[nItem][IT_DESCZF] -  nOldVlr
		aNfItem[nItem][IT_PRCUNI]  := (aNfItem[nItem][IT_VALMERC]-aNfItem[nItem][IT_DESCONTO])/aNfItem[nItem][IT_QUANT]
	EndIf
	aNfItem[nItem][IT_VALICM]  := 0
	aNfItem[nItem][IT_BASEICM] := 0
Else
	aNfItem[nItem][IT_DESCZF] := 0
	aNfItem[nItem][IT_DESCZFPIS]:= 0
	aNfItem[nItem][IT_DESCZFCOF]:= 0
	If aNfCab[NF_ROTINA] == 'MATA461'
		aNfItem[nItem][IT_VALMERC] -= aNfItem[nItem][IT_DESCZF] -  nOldVlr
		aNfItem[nItem][IT_PRCUNI]  := (aNfItem[nItem][IT_VALMERC]-aNfItem[nItem][IT_DESCONTO])/aNfItem[nItem][IT_QUANT]
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MaFisCFO ³ Autor ³ Edson Maricate        ³ Data ³13.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa o Codigo Fiscal do item especificado               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpC1 := MaFisCFO(ExpN1,ExpC2,[ExpA1])                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item                                                 ³±±
±±³          ³ExpC2: Codigo Fiscal Original ( Opcional )                  ³±±
±±³          ³ExpA1: Array de parametros opcional a ser enviado quando    ³±±
±±³          ³a funcao e chamada de fora da matxfis. Estrutura:           ³±±
±±³          ³  1 - Identificador do parametro ( mnemonico )              ³±±
±±³          ³  2 - Conteudo                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Codigo Fiscal de Operacao                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisCFO(nItem,cAuxCF,aDados)
Local cCfo	:= IIf(cAuxCF==Nil,aTes[TS_CF],cAuxCF)
Local cRetCF:= ""

Local cOperNf   := ""
Local cTpCliFor := ""
Local cUfOrigem := ""
Local cUfDest   := ""
Local cTpComp   := ""
Local cInscri   := ""
Local cRestoCfo := ""

Local lInscrito := .T.

Local nLoop     := 0	// controle de loop
Local lUsaCfps	:= GetNewPar("MV_USACFPS",.F.)

If ValType( aDados ) == "A"
	cUfOrigem   := SuperGetMv("MV_ESTADO")
	cUfDest     := SuperGetMv("MV_ESTADO")
	For nLoop := 1 To Len( aDados )
		Do Case
		Case aDados[ nLoop, 1 ] == "OPERNF"
			cOperNF   := aDados[ nLoop, 2 ]
		Case aDados[ nLoop, 1 ] == "TPCLIFOR"
			cTpCliFor := aDados[ nLoop, 2 ]
		Case aDados[ nLoop, 1 ] == "UFORIGEM"
			cUfOrigem := aDados[ nLoop, 2 ]
		Case aDados[ nLoop, 1 ] == "UFDEST"
			cUfDest   := aDados[ nLoop, 2 ]
		Case aDados[ nLoop, 1 ] == "TPCOMP"
			cTpComp   := aDados[ nLoop, 2 ]
		Case aDados[ nLoop, 1 ] == "INSCR"
 			cInscri   := aDados[ nLoop, 2 ]
 			lInscrito := !(Empty(cInscri).OR."ISENT" $ cInscri)
		EndCase
	Next nLoop

Else
	cOperNf     := aNfCab[NF_OPERNF]
	cTpCliFor   := aNfCab[NF_TPCLIFOR]
	cUfOrigem   := aNfCab[NF_UFORIGEM]
	cUfDest     := aNfCab[NF_UFDEST]
	cTpComp     := aNfCab[NF_TPCOMP]
	lInscrito   := !( aNfCab[NF_LINSCR] )
EndIf

cRestoCfo := SubStr(cCfo,2,Len(cCfo)-1)

If cPaisLoc=="BRA"
	If SubStr(cCfo,1,3) == "999" .OR. SubStr(cCfo,1,3) == "000" .OR. SubStr(cCfo,1,4) $ "1601#1602#5601#5602"
		cRetCF := cCfo
	Else
		If cOperNf == "E"
			If cUfOrigem == "EX" .OR. cTpCliFor == "X"
				cRetCF := "3"
			Else
				If cUfOrigem == SuperGetMv("MV_ESTADO")
					cRetCF := "1"
				Else
					cRetCF := "2"
				EndIf
			EndIf
		Else
			If cUfDest == cUfOrigem .AND. cTpCliFor <> "X"
				cRetCF := "5"
				If GetNewPar( "MV_CONVCFO", "1" ) == "1"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso seja operacao com consumidor final troca a terminacao ³
				//³ do CFOP                                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cTpCliFor == "F" .OR. !lInscrito) .AND. AllTrim( cRestoCfo ) == "655"
						cRestoCfo := "656" + Space( Len( cRestoCfo ) - 3 )
					EndIf
				EndIf
			ElseIf cTpCliFor <> "X"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Conversao do CFO interestadual                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cRetCF := "6"
				If GetNewPar( "MV_CONVCFO", "1" ) == "1"
					If !lInscrito
						If AllTrim( cRestoCfo ) == "102"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Caso seja operacao interestadual para nao inscritos        ³
							//³ altera o final do CFO de 102 para 108                      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cRestoCfo := "108" + Space( Len( cRestoCfo ) - 3 )
						ElseIf AllTrim( cRestoCfo ) == "101"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Caso seja operacao interestadual para nao inscritos        ³
							//³ altera o final do CFO de 101 para 107                      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cRestoCfo := "107" + Space( Len( cRestoCfo ) - 3 )
						ElseIf AllTrim( cRestoCfo ) == "106"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Caso seja operacao interestadual para nao inscritos        ³
							//³ altera o final do CFO de 106 para 108                      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cRestoCfo := "108" + Space( Len( cRestoCfo ) - 3 )
						EndIf
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso seja operacao com consumidor final troca a terminacao ³
					//³ do CFOP                                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (cTpCliFor == "F" .OR. !lInscrito) .AND. AllTrim( cRestoCfo ) == "655"
						cRestoCfo := "656" + Space( Len( cRestoCfo ) - 3 )
					EndIf
				EndIf
			Else
				cRetCF := "7"
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento para Complemento de Frete                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTpComp == "F" .AND. GetNewPar( "MV_CONVCFO", "1" ) == "1"
			cRetCF += IIf(SubStr(cCfo,2,3)$"931/932/933/351/352/353/354/355/356",SubStr(cCfo,2,3),"352")
		Else
			cRetCF += cRestoCfo
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajuste do CFO para fora do estado quando for 4 digitos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Left(cRetCf,4) == "6405" .AND. GetNewPar( "MV_CONVCFO", "1" ) == "1"
		cRetCf := "6404"+SubStr(cRetCf,5)
	EndIf
	If lUsaCfps .AND. Left(LTrim(cCfo),1)=="9"
		cRetCf := "9"+cRestoCfo
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica os CFOPS de Importacao e Exportacao.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SubStr(cRetCF,1,2) == "79"
		SX5->(dbSetOrder(1))
		If !SX5->(MsSeek(xFilial("SX5")+"13"+cRetCF))
			cRetCf := "7949"
		EndIf
	EndIf

Else
	cRetCF:=Alltrim(cCfo)
EndIf

If ValType( aDados ) <> "A"
	aNfItem[nItem][IT_CF]	:= PadR(cRetCF,Len(SF4->F4_CF))
Endif

Return ( cRetCF )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaFisIniLo³ Autor ³Edson Maricate         ³ Data ³13.12.1999 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina atualizacao dos dados do Cabecalho da funcao fiscal   ³±±
±±³          ³aNfCab com base em um item da funcao fiscal aNfItem          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item do Array ANFItem que deve ser inicializado       ³±±
±±³          ³ExpL2: Indica se eh inclusao (.T.)ou estorno(.F.)       (OPC)³±±
±±³          ³ExpC3: Campo a ser atualizado                           (OPC)³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo atualizar a variavel aNfCab com³±±
±±³          ³base nos itens da funcao fiscal                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisSomaIt(nX,lSoma,cCampo)

Local nY := 0
Local nG := 0
DEFAULT lSoma := .T.

If !aNfItem[nX][IT_DELETED]
	If lSoma
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os campos totalizadores.                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNfCab[NF_DESCONTO]	+= aNfItem[nX][IT_DESCONTO]
		aNfCab[NF_FRETE]	+= aNfItem[nX][IT_FRETE]
		aNfCab[NF_DESPESA]	+= aNfItem[nX][IT_DESPESA]
		aNfCab[NF_SEGURO]	+= aNfItem[nX][IT_SEGURO]
		aNfCab[NF_AUTONOMO]	+= aNfItem[nX][IT_AUTONOMO]
		aNfCab[NF_BASEICM]	+= aNfItem[nX][IT_BASEICM]
		aNfCab[NF_VALICM]	+= aNfItem[nX][IT_VALICM]
		aNfCab[NF_BASESOL]	+= aNfItem[nX][IT_BASESOL]
		aNfCab[NF_VALSOL]	+= aNfItem[nX][IT_VALSOL]
		aNfCab[NF_BICMORI]	+= aNfItem[nX][IT_BICMORI]
		aNfCab[NF_VALCMP]	+= aNfItem[nX][IT_VALCMP]
		aNfCab[NF_BASEIPI]	+= aNfItem[nX][IT_BASEIPI]
		aNfCab[NF_BIPIORI]	+= aNfitem[nX][IT_BIPIORI]
		aNfCab[NF_VALIPI]	+= aNfItem[nX][IT_VALIPI]
		aNfCab[NF_TOTAL]	+= aNfItem[nX][IT_TOTAL]
		aNfCab[NF_VALMERC]	+= aNfItem[nX][IT_VALMERC]-aNfItem[nX][IT_VNAGREG]
		aNfCab[NF_VNAGREG]  += aNfItem[nX][IT_VNAGREG]
		aNfCab[NF_FUNRURAL]	+= aNfItem[nX][IT_FUNRURAL]
		aNfCab[NF_BASEIRR]	+= aNfItem[nX][IT_BASEIRR]
		aNfCab[NF_VALIRR]	+= aNfItem[nX][IT_VALIRR]
		aNfCab[NF_BASEINS]	+= aNfItem[nX][IT_BASEINS]
		aNfCab[NF_VALINS]	+= aNfItem[nX][IT_VALINS]
		aNfCab[NF_BASEISS]	+= aNfItem[nX][IT_BASEISS]
		aNfCab[NF_VALISS]	+= aNfItem[nX][IT_VALISS]
		aNfCab[NF_BASEDUP]	+= aNfItem[nX][IT_BASEDUP]
		aNfCab[NF_DESCZF]	+= aNfItem[nX][IT_DESCZF]
		aNfCab[NF_PESO]		+= aNfItem[nX][IT_PESO]
		aNfCab[NF_ICMFRETE]	+= aNfItem[nX][IT_ICMFRETE]
		aNfCab[NF_BSFRETE]	+= aNfItem[nX][IT_BSFRETE]
		aNfCab[NF_BASEICA]	+= aNfItem[nX][IT_BASEICA]
		aNfCab[NF_VALICA]	+= aNfItem[nX][IT_VALICA]
		aNfCab[NF_BASECOF]	+= aNfItem[nX][IT_BASECOF]
		aNfCab[NF_VALCOF]	+= aNfItem[nX][IT_VALCOF]
		aNfCab[NF_BASEPIS]	+= aNfItem[nX][IT_BASEPIS]
		aNfCab[NF_VALPIS]	+= aNfItem[nX][IT_VALPIS]
		aNfCab[NF_BASEPS2] += aNfItem[nX][IT_BASEPS2]
		aNfCab[NF_VALPS2]  += aNfItem[nX][IT_VALPS2]
		aNfCab[NF_BASECF2] += aNfItem[nX][IT_BASECF2]
		aNfCab[NF_VALCF2]  += aNfItem[nX][IT_VALCF2]
		aNfCab[NF_BASECSL]	+= aNfItem[nX][IT_BASECSL]
		aNfCab[NF_VALCSL]	+= aNfItem[nX][IT_VALCSL]
		For nG := 1 To NMAXIV
			aNfCab[NF_BASEIMP][nG] += aNfItem[nX][IT_BASEIMP][nG]
			aNfCab[NF_VALIMP][nG]  += aNfItem[nX][IT_VALIMP][nG]
		Next nG
		aNfCab[NF_ICMSDIF]		+= aNfItem[nX][IT_ICMSDIF]
		aNfCab[NF_BASEAFRMM]	+= aNfItem[nX][IT_BASEAFRMM]
		aNfCab[NF_VALAFRMM] 	+= aNfItem[nX][IT_VALAFRMM]
		// PIS/COFINS - Decreto 252 de 15/06/2005 - para retencao aquisicao a aquisicao - sem considerar R# 5.000,00 da Lei 10925
		aNfCab[NF_PIS252]		+= aNfItem[nX][IT_PIS252]
		aNfCab[NF_COF252]		+= aNfItem[nX][IT_COF252]
		aNfCab[NF_BASESES]		+= aNfItem[nX][IT_BASESES]		//Base de calculo SEST
		aNfCab[NF_VALSES]		+= aNfItem[nX][IT_VALSES]		//Valor do SEST
		aNfCab[NF_BASEPS3]		+= aNfItem[nX][IT_BASEPS3]		//Valor da base do PIS de Subst. Tributaria
		aNfCab[NF_VALPS3]		+= aNfItem[nX][IT_VALPS3]		//Valor do PIS de Subst. Tributaria
		aNfCab[NF_BASECF3]		+= aNfItem[nX][IT_BASECF3]		//Valor da base da COFINS de Subst. Tributaria
		aNfCab[NF_VALCF3]		+= aNfItem[nX][IT_VALCF3]		//Valor da COFINS de Subst. Tributaria
		aNfCab[NF_VLR_FRT]	    += aNfItem[nX][IT_VLR_FRT]     //Valor do Frete de Pauta
		aNfCab[NF_VALFET]		+= aNfItem[nX][IT_VALFET]		//Valor do FETHAB
		aNfCab[NF_VALFDS]		+= aNfItem[nX][IT_VALFDS]		//Valor do FUNDERSUL
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os campos totalizadores.                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNfCab[NF_DESCONTO]	-= aNfItem[nX][IT_DESCONTO]
		aNfCab[NF_FRETE]	-= aNfItem[nX][IT_FRETE]
		aNfCab[NF_DESPESA]	-= aNfItem[nX][IT_DESPESA]
		aNfCab[NF_SEGURO]	-= aNfItem[nX][IT_SEGURO]
		aNfCab[NF_AUTONOMO]	-= aNfItem[nX][IT_AUTONOMO]
		aNfCab[NF_BASEICM]	-= aNfItem[nX][IT_BASEICM]
		aNfCab[NF_VALICM]	-= aNfItem[nX][IT_VALICM]
		aNfCab[NF_BASESOL]	-= aNfItem[nX][IT_BASESOL]
		aNfCab[NF_VALSOL]	-= aNfItem[nX][IT_VALSOL]
		aNfCab[NF_BICMORI]	-= aNfItem[nX][IT_BICMORI]
		aNfCab[NF_VALCMP]	-= aNfItem[nX][IT_VALCMP]
		aNfCab[NF_BASEIPI]	-= aNfItem[nX][IT_BASEIPI]
		aNfCab[NF_BIPIORI]	-= aNfitem[nX][IT_BIPIORI]
		aNfCab[NF_VALIPI]	-= aNfItem[nX][IT_VALIPI]
		aNfCab[NF_TOTAL]	-= aNfItem[nX][IT_TOTAL]
		aNfCab[NF_VALMERC]	-= aNfItem[nX][IT_VALMERC]-aNfItem[nX][IT_VNAGREG]
		aNfCab[NF_VNAGREG] -= aNfItem[nX][IT_VNAGREG]
		aNfCab[NF_FUNRURAL]	-= aNfItem[nX][IT_FUNRURAL]
		aNfCab[NF_BASEIRR]	-= aNfItem[nX][IT_BASEIRR]
		aNfCab[NF_VALIRR]	-= aNfItem[nX][IT_VALIRR]
		aNfCab[NF_BASEINS]	-= aNfItem[nX][IT_BASEINS]
		aNfCab[NF_VALINS]	-= aNfItem[nX][IT_VALINS]
		aNfCab[NF_BASEISS]	-= aNfItem[nX][IT_BASEISS]
		aNfCab[NF_VALISS]	-= aNfItem[nX][IT_VALISS]
		aNfCab[NF_BASEDUP]	-= aNfItem[nX][IT_BASEDUP]
		aNfCab[NF_DESCZF]	-= aNfItem[nX][IT_DESCZF]
		aNfCab[NF_PESO]		-= aNfItem[nX][IT_PESO]
		aNfCab[NF_ICMFRETE]	-= aNfItem[nX][IT_ICMFRETE]
		aNfCab[NF_BSFRETE]	-= aNfItem[nX][IT_BSFRETE]
		aNfCab[NF_BASEICA]	-= aNfItem[nX][IT_BASEICA]
		aNfCab[NF_VALICA]	-= aNfItem[nX][IT_VALICA]
		aNfCab[NF_BASECOF]	-= aNfItem[nX][IT_BASECOF]
		aNfCab[NF_VALCOF]	-= aNfItem[nX][IT_VALCOF]
		aNfCab[NF_BASEPIS]	-= aNfItem[nX][IT_BASEPIS]
		aNfCab[NF_VALPIS]	-= aNfItem[nX][IT_VALPIS]
		aNfCab[NF_BASEPS2] -= aNfItem[nX][IT_BASEPS2]
		aNfCab[NF_VALPS2]  -= aNfItem[nX][IT_VALPS2]
		aNfCab[NF_BASECF2] -= aNfItem[nX][IT_BASECF2]
		aNfCab[NF_VALCF2]  -= aNfItem[nX][IT_VALCF2]
		aNfCab[NF_BASECSL]	-= aNfItem[nX][IT_BASECSL]
		aNfCab[NF_VALCSL]	-= aNfItem[nX][IT_VALCSL]
		For nG := 1 To NMAXIV
			aNfCab[NF_BASEIMP][nG] -= aNfItem[nX][IT_BASEIMP][nG]
			aNfCab[NF_VALIMP][nG]  -= aNfItem[nX][IT_VALIMP][nG]
		Next nG
		If cPaisLoc <> "BRA" .AND. cCampo=="IT_DESCONTO" .AND. aNfCab[NF_OPERNF] =='S' .AND. SuperGetMV('MV_DESCSAI') =='1'
			aNFitem[nX][IT_VALMERC] +=	aNFitem[nX][IT_DESCONTO]
			aNFitem[nX][IT_PRCUNI]  :=	aNFitem[nX][IT_VALMERC]/Max(aNFitem[nX][IT_QUANT],1)
		EndIf
		aNfCab[NF_ICMSDIF]		-= aNfItem[nX][IT_ICMSDIF]
		aNfCab[NF_BASEAFRMM]	-= aNfItem[nX][IT_BASEAFRMM]
		aNfCab[NF_VALAFRMM] 	-= aNfItem[nX][IT_VALAFRMM]
		//  PIS/COFINS - Decreto 252 de 15/06/2005 - para retencao aquisicao a aquisicao - sem considerar R# 5.000,00 da Lei 10925
		aNfCab[NF_PIS252]		-= aNfItem[nX][IT_PIS252]
		aNfCab[NF_COF252]		-= aNfItem[nX][IT_COF252]
		aNfCab[NF_BASESES]		-= aNfItem[nX][IT_BASESES]		//Base de calculo SEST
		aNfCab[NF_VALSES]		-= aNfItem[nX][IT_VALSES]		//Valor do SEST
		aNfCab[NF_BASEPS3]		-= aNfItem[nX][IT_BASEPS3]		//Valor da base do PIS de Subst. Tributaria
		aNfCab[NF_VALPS3]		-= aNfItem[nX][IT_VALPS3]		//Valor do PIS de Subst. Tributaria
		aNfCab[NF_BASECF3]		-= aNfItem[nX][IT_BASECF3]		//Valor da base da COFINS de Subst. Tributaria
		aNfCab[NF_VALCF3]		-= aNfItem[nX][IT_VALCF3]		//Valor da COFINS de Subst. Tributaria
		aNfCab[NF_VLR_FRT]		-= aNfItem[nX][IT_VLR_FRT]		//Valor do Frete de Pauta
		aNfCab[NF_VALFET]		-= aNfItem[nX][IT_VALFET]		//Valor do FETHAB
		aNfCab[NF_VALFDS]		-= aNfItem[nX][IT_VALFDS]		//Valor do FUNDERSUL
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclui a linha para inclusao de Impostos.                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aNfCab[NF_INSIMP]
		If aScan(aNfCab[NF_IMPOSTOS],{|x| x[6] == "NEW"  }) == 0
			aadd(aNfCab[NF_IMPOSTOS],{'...','  ',0,0,0,'NEW'})
		EndIf
		If aScan(aNfCab[NF_IMPOSTOS2],{|x| x[5] == "NEW"  }) == 0
			aadd(aNfCab[NF_IMPOSTOS2],{'...','  ',0,0,'NEW'})
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do array NF_IMPOSTOS contando o rodape e todos os impostos calculados³
	//³ ICMS,IPI,INSS,ICMS RETIDO,ICMS COMP,ISS,IR    Impostos Argentina,Chile,Etc    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "BRA"
		If (aNfItem[nX][IT_BASEICM]<>0 .OR. aNfItem[nX][IT_VALICM]<>0) .AND. aNfItem[nX][IT_VALISS] == 0
			MaFisResumo(aNfItem[nX][IT_BASEICM],aNfItem[nX][IT_ALIQICM],aNfItem[nX][IT_VALICM],;
				'ICM','ICMS','ICM',,,lSoma)
		EndIf
		If aNfItem[nX][IT_BASEIPI]<>0 .OR. aNfItem[nX][IT_VALIPI]<>0
			MaFisResumo(aNfItem[nX][IT_BASEIPI],aNfItem[nX][IT_ALIQIPI],aNfItem[nX][IT_VALIPI],;
				'IPI','IPI ','IPI',,,lSoma)
		EndIf
		If aNfItem[nX][IT_BASEICA]<>0 .OR. aNfItem[nX][IT_VALICA]<>0
			MaFisResumo(aNfItem[nX][IT_BASEICA],aNfItem[nX][IT_ALIQICM],aNfItem[nX][IT_VALICA],;
				'ICA','ICMS ref. Frete Autonomo','ICA',,,lSoma)
		EndIf
		If aNfItem[nX][IT_BASESOL]<>0 .OR. aNfItem[nX][IT_VALSOL]<>0
			MaFisResumo(aNfItem[nX][IT_BASESOL],aNfItem[nX][IT_ALIQSOL],aNfItem[nX][IT_VALSOL],;
				'ICR','ICMS Retido ','SOL',,,lSoma)
		EndIf
		If aNfItem[nX][IT_VALCMP]<>0
			MaFisResumo(aNfItem[nX][IT_BASEICM],aNfItem[nX][IT_ALIQCMP],aNfItem[nX][IT_VALCMP],;
				'ICC','ICMS Complementar ','CMP',,,lSoma)
		EndIf
		If aNfItem[nX][IT_BASEISS]<>0 .OR. aNfItem[nX][IT_VALISS]<>0
			MaFisResumo(aNfItem[nX][IT_BASEISS],aNfItem[nX][IT_ALIQISS],aNfItem[nX][IT_VALISS],;
				'ISS','ISS Imposto sobre servico ','ISS',,,lSoma)
		EndIf
		If aNfItem[nX][IT_BASEIRR]<>0 .OR. aNfItem[nX][IT_VALIRR]<>0
			MaFisResumo(aNfItem[nX][IT_BASEIRR],aNfItem[nX][IT_ALIQIRR],aNfItem[nX][IT_VALIRR],;
				'IRR','IRRF Imposto de renda ','IRR',,,lSoma)
		EndIf
		If aNfItem[nX][IT_BASEINS]<>0 .OR. aNfItem[nX][IT_VALINS]<>0
			MaFisResumo(aNfItem[nX][IT_BASEINS],aNfItem[nX][IT_ALIQINS],aNfItem[nX][IT_VALINS],;
				'INS','INSS ','INS',,,lSoma)
		EndIf
		If aNfItem[nX][IT_BASECOF]<>0 .OR. aNfItem[nX][IT_VALCOF]<>0
			MaFisResumo(aNfItem[nX][IT_BASECOF],aNfItem[nX][IT_ALIQCOF],aNfItem[nX][IT_VALCOF],;
				'COF','COFINS - Via Retenção','COF',.T.,.T.,lSoma)
		EndIf
		If aNfItem[nX][IT_BASECSL]<>0 .OR. aNfItem[nX][IT_VALCSL]<>0
			MaFisResumo(aNfItem[nX][IT_BASECSL],aNfItem[nX][IT_ALIQCSL],aNfItem[nX][IT_VALCSL],;
				'CSL','CSLL - Via Retenção','CSL',.T.,.T.,lSoma)
		EndIf
		If aNfItem[nX][IT_BASEPIS]<>0 .OR. aNfItem[nX][IT_VALPIS]<>0
			MaFisResumo(aNfItem[nX][IT_BASEPIS],aNfItem[nX][IT_ALIQPIS],aNfItem[nX][IT_VALPIS],;
				'PIS','PIS - Via Retençao','PIS',.T.,.T.,lSoma)
		EndIf
		If aNfItem[nX][IT_FUNRURAL]<>0
			MaFisResumo(0,aNfItem[nX][IT_PERFUN],aNfItem[nX][IT_FUNRURAL],;
				'FRU','FUNRURAL ','RUR',.T.,,lSoma)
		EndIf
		If aNfItem[nx][IT_BASEPS2]<>0 .OR. aNfItem[nx][IT_VALPS2]<>0
			MaFisResumo(aNfItem[nx][IT_BASEPS2],aNfItem[nx][IT_ALIQPS2],aNfItem[nx][IT_VALPS2],;
				'PS2','PIS/Pasep - Via apuracao','PS2',,,lSoma)
		EndIf
		If aNfItem[nx][IT_BASECF2]<>0 .OR. aNfItem[nx][IT_VALCF2]<>0
			MaFisResumo(aNfItem[nx][IT_BASECF2],aNfItem[nx][IT_ALIQCF2],aNfItem[nx][IT_VALCF2],;
				'CF2','COFINS - Via apuracao','CF2',,,lSoma)
		EndIf
		If aNfItem[nx][IT_BASEAFRMM]<>0 .OR. aNfItem[nx][IT_VALAFRMM]<>0
			MaFisResumo(aNfItem[nx][IT_BASEAFRMM],aNfItem[nx][IT_ALIQAFRMM],aNfItem[nx][IT_VALAFRMM],;
				'AFRMM','AFRMM','AFRMM',,,lSoma)
		EndIf
		If aNfItem[nX][IT_BASESES]<>0 .OR. aNfItem[nX][IT_VALSES]<>0
			MaFisResumo(aNfItem[nX][IT_BASESES],aNfItem[nX][IT_ALIQSES],aNfItem[nX][IT_VALSES],;
				'SES','SEST/SENAT','SES',,,lSoma)
		EndIf
		If aNfItem[nx][IT_BASEPS3]<>0 .OR. aNfItem[nx][IT_VALPS3]<>0
			MaFisResumo(aNfItem[nx][IT_BASEPS3],aNfItem[nx][IT_ALIQPS3],aNfItem[nx][IT_VALPS3],;
				'PS3','PIS/Pasep - Subst. Tributaria','PS3',,,lSoma)
		EndIf
		If aNfItem[nx][IT_BASECF3]<>0 .OR. aNfItem[nx][IT_VALCF3]<>0
			MaFisResumo(aNfItem[nx][IT_BASECF3],aNfItem[nx][IT_ALIQCF3],aNfItem[nx][IT_VALCF3],;
				'CF3','COFINS - Subst. Tributaria','CF3',,,lSoma)
		EndIf
		If MaCalcFet()	//Calculo do Imposto FETHAB
			If aNfItem[nx][IT_BASEFET]<>0 .Or. aNfItem[nx][IT_VALFET]<>0
				MaFisResumo(aNfItem[nx][IT_BASEFET],aNfItem[nx][IT_ALIQFET],aNfItem[nx][IT_VALFET],;
				'FET','FETHAB','FET',.T.,.T.,lSoma)
			Endif
		EndIf
		If aNfItem[nX][IT_VALFDS] > 0
			MaFisResumo(0,0,aNfItem[nX][IT_VALFDS],;
				'FDS','FUNDERSUL','FDS',.T.,.T.,lSoma)
		EndIf
	Endif
	For nG := 1 To NMAXIV
		If aNfItem[nX][IT_BASEIMP][nG]<>0 .OR. aNfItem[nX][IT_VALIMP][nG]<>0
			MaFisResumo(aNfItem[nX][IT_BASEIMP][nG],aNfItem[nX][IT_ALIQIMP][nG],aNfItem[nX][IT_VALIMP][nG],;
				aNfItem[nX][IT_DESCIV][nG][1],aNfItem[nX][IT_DESCIV][nG][2],"IV"+NumCpoImpVar(nG),,,lSoma)
		EndIf
	Next nG

	MaFisLFToLivro(nX,@aAuxOri,lSoma)
	If !lSoma
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa a correcao nos arredondamentos.                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nY := 1 to Len(aItemRef)
			If aItemRef[nY][4]
				If ValType(aItemRef[nY][2]) == "A"
					If !aItemRef[nY][5]
						aNfItem[nX][aItemRef[nY][2][1]][aItemRef[nY][2][2]] += aItemDec[nX][1][nY]
						aSaveDec[nY] += aItemDec[nX][1][nY]
						aSaveDec[nY] -= aItemDec[nX][2][nY]
					Else
						aNfItem[nX][aItemRef[nY][2][1]][aItemRef[nY][2][2]] -= aItemDec[nX][1][nY]
						If !(!Empty(cCampo) .AND. cCampo == aItemRef[nY][1])
							aSaveDec[nY] += aItemDec[nX][1][nY]
							aSaveDec[nY] -= aItemDec[nX][2][nY]
						EndIf

					EndIf
					aItemDec[nX][1][nY]:= 0
					aItemDec[nX][2][nY]:= 0
				Else
					If !aItemRef[nY][5]
						aNfItem[nX][Val(aItemRef[nY][2])] += aItemDec[nX][1][nY]
						aSaveDec[nY] += aItemDec[nX][1][nY]
						aSaveDec[nY] -= aItemDec[nX][2][nY]
					Else
						aNfItem[nX][Val(aItemRef[nY][2])] -= aItemDec[nX][1][nY]
						If !(!Empty(cCampo) .AND. cCampo == aItemRef[nY][1])
							aSaveDec[nY] += aItemDec[nX][1][nY]
							aSaveDec[nY] -= aItemDec[nX][2][nY]
						EndIf
					EndIf
					aItemDec[nX][1][nY]:= 0
					aItemDec[nX][2][nY]:= 0
				EndIf
			EndIf
		Next nY
	EndIf
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MaIt2Cab ³ Autor ³ Edson Maricate        ³ Data ³13.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza os valores totais do cabecalho da NF              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaIt2Cab(nItemNao)
Local nX    := 0
Local nY    := 0
Local nLF	:= 0

DEFAULT nItemNao	:=	0

aAuxOri				:= {}
aNfCab[NF_DESCONTO]	:= 0
aNfCab[NF_FRETE]	:= 0
aNfCab[NF_DESPESA]	:= 0
aNfCab[NF_SEGURO]	:= 0
aNfCab[NF_AUTONOMO]	:= 0
aNfCab[NF_ICMS]		:= {0,0,0,0,0,0,0,0,"1"}
aNfCab[NF_IPI]		:= {0,0,0}
aNfCab[NF_TOTAL]	:= 0
aNfCab[NF_VALMERC]	:= 0
aNfCab[NF_VNAGREG]  :=0
aNfCab[NF_FUNRURAL]	:= 0
aNfCab[NF_LIVRO]	:= {}
aNfCab[NF_BASEIRR]	:= 0
aNfCab[NF_VALIRR]	:= 0
aNfCab[NF_BASEINS]  := 0
aNfCab[NF_VALINS]	:= 0
aNfCab[NF_BASEISS] 	:= 0
aNfCab[NF_VALISS]	:= 0
aNfCab[NF_IMPOSTOS]	:= {}
aNfCab[NF_IMPOSTOS2]:= {}
aNfCab[NF_BASEDUP]	:= 0
aNfCab[NF_DESCZF]	:= 0
aNfCab[NF_BASEIMP]	:= Array(NMAXIV)
aNfCab[NF_BASEIMP]	:= Afill(aNfCab[NF_BASEIMP],0)
aNfCab[NF_VALIMP]	:= Array(NMAXIV)
aNfCab[NF_VALIMP]	:= Afill(aNfCab[NF_VALIMP],0)
aNfCab[NF_PESO]		:= 0
aNfCab[NF_ICMFRETE]	:= 0
aNfCab[NF_BSFRETE]	:= 0
aNfCab[NF_BASEICA]	:= 0
aNfCab[NF_VALICA]	:= 0
aNfCab[NF_BASECOF]	:= 0
aNfCab[NF_VALCOF]	:= 0
aNfCab[NF_BASECSL]	:= 0
aNfCab[NF_VALCSL]	:= 0
aNfCab[NF_BASEPIS]	:= 0
aNfCab[NF_VALPIS]	:= 0
aNfCab[NF_BASEPS2]	:= 0
aNfCab[NF_VALPS2]	:= 0
aNfCab[NF_BASECF2]	:= 0
aNfCab[NF_VALCF2]	:= 0
aNfCab[NF_MINIMP]	:=Array(NMAXIV)
aNfCab[NF_MINIMP]	:=Afill(aNfCab[NF_MINIMP],0)
aNfCab[NF_BASEAFRMM]:= 0
aNfCab[NF_PIS252]    := 0
aNfCab[NF_COF252]    := 0
aNfCab[NF_BASESES]   := 0
aNfCab[NF_VALSES]	 := 0
aNfCab[NF_BASEPS3]   := 0
aNfCab[NF_VALPS3]    := 0
aNfCab[NF_BASECF3]   := 0
aNfCab[NF_VALCF3]    := 0
aNfCab[NF_VLR_FRT]   := 0
aNfCab[NF_VALFET]    := 0
aNfCab[NF_VALFDS]    := 0

For nX := 1 to Len(aNfItem)
	If nItemNao <> nX
		MaFisSomaIt(nX)
	Endif
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a correcao nos arredondamentos no Cabecalho e Livros Fiscais   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc=="BRA"
	For nX := 1 To Len(aCabRef)
		If ValType(aCabRef[nX,2]) <> "A"
			nY := Val(aCabRef[nX,2])
			If ValType(aNfCab[nY]) == "N" .AND. aCabRef[nX][3]
				aNfCab[nY] := NoRound(aNfCab[nY],2,,10)
			EndIf
		EndIf
	Next nX
	For nLf := 1 to Len(aNfCab[NF_LIVRO])
		For nY	:= 1 to Len(aNfCab[NF_LIVRO][nLf])
			If !AllTrim(StrZero(nY,2))$"01#02#12#15#16#18#20#23#24#31#32#33#35#36#42#43#44#45#46#47#48#51#52#53#58#61"
				aNfCab[NF_LIVRO][nLF][nY] := aNfCab[NF_LIVRO][nLF][nY]
			EndIf
		Next nY
	Next nLf
Endif

If bFisRefresh <> Nil
	Eval(bFisRefresh)
EndIf

If bLivroRefresh <> Nil
	Eval(bLivroRefresh)
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MaFisVTot³ Autor ³ Edson Maricate        ³ Data ³13.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza os valores totais do item                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisVTot(nItem)
Local nImp := 0,nValImp:=0
Local lDescInc   :=	(cPaisLoc<>"BRA".AND.aNfCab[NF_OPERNF]=="S".AND.SuperGetMV('MV_DESCSAI')=='1')
Local nImposto   := 0
Local nAgrPisPas :=	If( aTes[TS_AGRPIS]=="1" .AND. aTes[TS_PSCFST] <> "1",aNfItem[nItem,IT_VALPS2],0) + If( aTes[TS_AGRCOF]=="1" .AND. aTes[TS_PSCFST] <> "1",aNfItem[nItem,IT_VALCF2],0)
Local nFretAut   := aNfItem[nItem][IT_VALICA]
Local nPisCofST  :=	0

If !GetNewPar("MV_FRETAUT",.T.)
	nFretAut := 0
EndIf

// Pis/Cofins Substituicao Tributaria - sera somado ao total do documento
If aTes[TS_PSCFST] == "1"
	nPisCofST := aNfItem[nItem,IT_VALPS3] + aNfItem[nItem,IT_VALCF3]
Endif

Do Case
Case aNFitem[nItem][IT_TIPONF ] == "P"
	aNfItem[nItem][IT_TOTAL]	:= aNfItem[nItem][IT_FRETE] + aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO]+;
		aNfItem[nItem][IT_VALIPI]+IIf(aTes[TS_INCSOL]$"A,N,D",0,aNfItem[nItem][IT_VALSOL])+;
		aNfItem[nItem][IT_VALEMB]+nFretAut+nAgrPisPas+nPisCofST
OtherWise
	Do Case
	Case aTes[TS_AGREG] == "N"
		aNfItem[nItem][IT_TOTAL]	:= aNfItem[nItem][IT_FRETE] + aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO]+;
			IIf(aTes[TS_IPI] == 'R',0,aNfItem[nItem][IT_VALIPI]) + IIf(aTes[TS_INCSOL]$"A,N,D",0,aNfItem[nItem][IT_VALSOL])+;
			aNfItem[nItem][IT_VALEMB]+nAgrPisPas+nPisCofST
		aNfItem[nItem][IT_VNAGREG] := aNfItem[nItem][IT_VALMERC]-aNfItem[nItem][IT_DESCONTO]
	Case aTes[TS_AGREG] == "I" .OR. aTes[TS_AGREG] == "B"
		aNfItem[nItem][IT_TOTAL]	:= aNfItem[nItem][IT_VALMERC] + aNfItem[nItem][IT_FRETE] + aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO]+;
			IIf(aTes[TS_IPI] == 'R',0,aNfItem[nItem][IT_VALIPI])+ IIf(aTes[TS_INCSOL]$"A,N,D".AND.aTes[TS_ICM]<>"N",0,aNfItem[nItem][IT_VALSOL]) - IIf(lDescInc,0,aNfItem[nItem][IT_DESCONTO])+;
			If(aNFitem[nItem][IT_TIPONF ]<>"I",aNfItem[nItem][IT_VALICM],0) + aNfItem[nItem][IT_VALEMB]+nFretAut+nAgrPisPas+nPisCofST
			aNfItem[nItem][IT_VNAGREG] := 0
			If	(("CTR"$AllTrim(aNFCab[NF_ESPECIE]) .Or. "NFST"$AllTrim(aNFCab[NF_ESPECIE])))
				If aTes[TS_CRPRST] <> 0  .And. !(aTes[TS_INCSOL] $ "A,N,D" .And. aTes[TS_ICM] <> "N")
					aNfItem[nItem][IT_TOTAL] += 	(aNfItem[nItem][IT_VLCSOL] - aNfItem[nItem][IT_VALSOL])
				EndIf
			EndIf

	OtherWise
		aNfItem[nItem][IT_TOTAL]	:= aNfItem[nItem][IT_VALMERC] + aNfItem[nItem][IT_FRETE] + aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO]+;
			IIf(aTes[TS_IPI] == 'R',0,aNfItem[nItem][IT_VALIPI])+ IIf(aTes[TS_INCSOL]$"A,N,D",0,aNfItem[nItem][IT_VALSOL]) - IIf(lDescInc,0,aNfItem[nItem][IT_DESCONTO])+;
			aNfItem[nItem][IT_VALEMB]+nFretAut + nAgrPisPas + nPisCofST - IIf(aTes[TS_AGREG]$"D",aNfItem[nItem][IT_DEDICM],0)
			aNfItem[nItem][IT_VNAGREG] := 0
	EndCase
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ICMS Diferido Incentivo abate de gado - o valor diferido sera somado ao total da NF e a duplicata³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aTES[TS_PICMDIF]<>0 .AND. aTes[TS_ICMSDIF]=="4"
	aNfItem[nItem][IT_TOTAL] += aNfItem[nItem][IT_ICMSDIF]
EndIf

aNfItem[nItem][IT_BASEDUP] := 0

If aTes[TS_DUPLIC] <>"N"
	aNfItem[nItem][IT_BASEDUP] := aNfItem[nItem][IT_TOTAL]
	If SuperGetMV("MV_DPAGREG") .AND. aTes[TS_AGREG] == "N"
		aNfItem[nItem][IT_BASEDUP] += aNfItem[nItem][IT_VALMERC]
	EndIf
	If aTes[TS_AGREG]=="F"
		aNfItem[nItem][IT_BASEDUP] -= aNfItem[nItem][IT_VALMERC]
	EndIf
	If aNFitem[nItem][IT_TIPONF ]=='I'
		aNfItem[nItem][IT_BASEDUP]	-= aNfItem[nItem][IT_VALICM]
	EndIf
	If aTES[TS_PICMDIF]<>0 .AND. aTes[TS_ICMSDIF]$" ,1,2"
		MaItArred(nItem, { "IT_ICMSDIF" } )
		aNfItem[nItem][IT_BASEDUP]	-= aNfItem[nItem][IT_ICMSDIF]
	EndIf
	If (aNfCab[NF_RECISS]=="1".AND.SuperGetMV("MV_DESCISS").AND.aNfCab[NF_OPERNF]=="S".AND.GetNewPar("MV_TPABISS","1")=="1")
		aNfItem[nItem][IT_BASEDUP]	-= aNfItem[nItem][IT_VALISS]
	EndIf
	If aTes[TS_INCSOL]=="D"
		If	aTes[TS_CRPRST] <> 0 .And. ("CTR"$AllTrim(aNFCab[NF_ESPECIE]) .Or. "NFST"$AllTrim(aNFCab[NF_ESPECIE])) .And. aNFCab[NF_OPERNF]=="S"
			aNfItem[nItem][IT_BASEDUP]	-= (aNfItem[nItem][IT_VLCSOL] - aNfItem[nItem][IT_VALSOL])
		Else
			aNfItem[nItem][IT_BASEDUP]	-= aNfItem[nItem][IT_VALSOL]
		EndIf
	EndIf
	If aTes[TS_AGREG]=="E"
		aNfItem[nItem][IT_BASEDUP]	-= aNfItem[nItem][IT_DEDICM]
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fundersul - sera reduzido do total da duplicata³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aTes[TS_CLFDSUL] == "1"
		aNfItem[nItem][IT_BASEDUP]	-= aNfItem[nItem][IT_VALFDS]
	Endif
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a TES possui tratamento para Impostos Variaveis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aTes[TS_SFC])
	For nImposto := 1 to Len(aTes[TS_SFC])
		nImp := NumCpoImpVar(RIGHT(Alltrim(aTes[TS_SFC][nImposto][SFB_CPOVREI]),1))
		If  aTes[TS_DUPLIC] <> "N" .AND. aNFitem[nItem][IT_TIPONF ]<>'B'
			Do Case
			Case aTes[TS_SFC][nImposto][SFC_INCDUPL]=="1"
				nValImp:=aNfItem[nItem][IT_VALIMP][nImp]
			Case aTes[TS_SFC][nImposto][SFC_INCDUPL]=="2"
				nValImp:=-aNfItem[nItem][IT_VALIMP][nImp]
			Case aTes[TS_SFC][nImposto][SFC_INCDUPL]=="3"
				nValImp:=0
			EndCase
			aNfItem[nItem][IT_BASEDUP] += nValImp
		Endif

		Do Case
		Case aTes[TS_SFC][nImposto][SFC_INCNOTA]=="1"
			nValImp:=aNfItem[nItem][IT_VALIMP][nImp]
		Case aTes[TS_SFC][nImposto][SFC_INCNOTA]=="2"
			nValImp:=-aNfItem[nItem][IT_VALIMP][nImp]
		Case aTes[TS_SFC][nImposto][SFC_INCNOTA]=="3"
			nValImp:=0
		EndCase
		aNfItem[nItem][IT_TOTAL] += nValImp
	Next nImposto
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaAliqRur ³ Autor ³ Edson Maricate        ³ Data ³20.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula a aliquota para calculo do Funrural do item.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaAliqRur(nItem)
Local cTipoRur  := ""
Local nAliquota	:= 0
Local nPosPer   := 0
Local aPFunRur  := {}

If MaSBCampo("CONTSOC") == "S" .AND. aTes[TS_DUPLIC] == "S" .AND. aNfCab[NF_TPCLIFOR] <> "X" .And. (aTes[TS_CONTSOC]$" 1")
	If aNfCab[NF_CLIFOR] == "F"
		cTipoRur := SA2->A2_TIPORUR
	Else
		cTipoRur := SM0->M0_PRODRUR
	EndIf
	aPFunRur := FunRur()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³aPFunRur[1]  == "F"³
	//³aPFunRur[2]  == "L"³
	//³aPFunRur[3]  == "J"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPosPer := At(cTipoRur,"FLJ")
	If nPosPer > 0
		nAliquota := Val(aPFunRur[nPosPer])
	Endif
EndIf
aNfItem[nItem][IT_PERFUN] := nAliquota

Return nAliquota

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaALIQIRR ³ Autor ³ Edson Maricate        ³ Data ³04.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a aliquota para calculo do Imposto de Renda.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaALIQIRR(nItem)

Local aArea		:= GetArea()
Local nAliquota	:= 0
Local nSomaIRF  := 0
aEval(aNfItem,{|x| nSomaIRF += x[IT_BASEIRR]})

If !Empty(aNfCab[NF_NATUREZA]) .AND. aNfCab[NF_MODIRF] <> "3"
	dbSelectArea("SED")
	dbSetOrder(1)
	If MsSeek(xFilial("SED")+aNfCab[NF_NATUREZA])
		If aNfCab[NF_CLIFOR] == "C"
			Do Case
				Case aNfCab[NF_ALIQIR] > 0
					nAliquota := aNfCab[NF_ALIQIR]
				Case SED->ED_CALCIRF = "S" .AND. (Len(AllTrim(aNFCAB[NF_CNPJ]))==14 .OR. aNfCab[NF_MODIRF]=="2")
					nAliquota := IIf(SED->ED_PERCIRF>0,SED->ED_PERCIRF,SuperGetMV("MV_ALIQIRF"))
				Case SED->ED_CALCIRF = "S" .AND. Len(AllTrim(aNFCAB[NF_CNPJ]))<>14
					If aNfCab[NF_MODIRF] == "4" //--Empresa Individual
						nAliquota := IIf(SED->ED_PERCIRF>0,SED->ED_PERCIRF,SuperGetMV("MV_ALIQIRF"))
					Else
						nAliquota := MaTbIrfPF(aNfItem[nItem][IT_BASEIRR],nSomaIRF-aNfItem[nItem][IT_BASEIRR],.T.,aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA])[2]
					EndIf
			EndCase
		Else
			If SED->ED_CALCIRF = "S"
				If aNfCab[NF_TPCLIFOR] == "F" .AND. aNfCab[NF_MODIRF]<>"2"
					If aNfCab[NF_MODIRF] == "4" //--Empresa Individual
						nAliquota := IIf(SED->ED_PERCIRF>0,SED->ED_PERCIRF,SuperGetMV("MV_ALIQIRF"))
					Else
						nAliquota := MaTbIrfPF(aNfItem[nItem][IT_BASEIRR],nSomaIRF-aNfItem[nItem][IT_BASEIRR],.T.,aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA])[2]
					EndIf
				Else
					nAliquota := IIf(SED->ED_PERCIRF>0,SED->ED_PERCIRF,SuperGetMV("MV_ALIQIRF"))
				EndIf
			EndIf
		EndIf
	EndIf
Else
	nAliquota := aNfCab[NF_ALIQIR]
EndIf
aNfItem[nItem][IT_ALIQIRR]	:= nAliquota
RestArea(aArea)
Return(nAliquota)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaALIQINS ³ Autor ³ Edson Maricate        ³ Data ³04.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a aliquota para calculo do INSS                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaALIQINS(nItem)

Local aArea		:= GetArea()
Local nAliquota	:= 0

If !Empty(aNfCab[NF_NATUREZA])
	dbSelectArea("SED")
	dbSetOrder(1)
	If MsSeek(xFilial("SED")+aNfCab[NF_NATUREZA])
		nAliquota := SED->ED_PERCINSS
	EndIf
EndIf
aNfItem[nItem][IT_ALIQINS]	:= nAliquota

RestArea(aArea)
Return(nAliquota)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisRdIR ³ Autor ³ Edson Maricate        ³ Data ³04.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o Percentual de reducao do IRRF do item.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisRdIR(nItem)

aNfItem[nItem][IT_REDIR] := MaSBCampo("REDIRRF")

Return(aNfItem[nItem][IT_REDIR])

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisRdINS³ Autor ³ Edson Maricate        ³ Data ³04.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o Percentual de reducao do INSS do item.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisRdINSS(nItem)

aNfItem[nItem][IT_REDINSS] := MaSBCampo("REDINSS")

Return(aNfItem[nItem][IT_REDINSS])

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisBsIR ³ Autor ³ Edson Maricate        ³ Data ³04.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o base de Caluculo do IIRF do item                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisBSIR(nItem)

Local lRetBlock := .T.

If ExistBlock( "MAFISBIR" )
	lRetBlock := ExecBlock( "MAFISBIR",.F.,.F.,;
		{aNfItem[nItem,IT_TES],aNfItem[nItem,IT_PRODUTO],aNfCab[NF_CLIFOR],aNfCab[NF_OPERNF],aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA]})
EndIf

// aNFCab[NF_OPIRRF] == "EP" -> Empresa Publica, devera efetuar a retencao sempre
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O INSS devera ser deduzido da base do IR e nao do valor dos       ³
//³servicos. Portanto, quando ha reducao na base de calculo, primeiro³
//³efetua-se a reducao e depois a deducao do INSS.                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (MaSBCampo("IRRF") == "S" .AND. aTES[TS_DUPLIC]=="S" .AND. lRetBlock) .OR. (aNFCab[NF_OPIRRF] == "EP" .AND. aTES[TS_DUPLIC]=="S" .AND. lRetBlock)
	aNfItem[nItem][IT_BASEIRR] := aNfItem[nItem][IT_TOTAL]
	aNfItem[nItem][IT_BASEIRR] := aNfItem[nItem][IT_BASEIRR]*IIf(aNfItem[nItem][IT_REDIR]>0,aNfItem[nItem][IT_REDIR]/100,1)
	If !Len(AllTrim(aNFCAB[NF_CNPJ]))==14
		aNfItem[nItem][IT_BASEIRR] := aNfItem[nItem][IT_BASEIRR]-aNfItem[nItem][IT_VALINS]
	Endif
Else
	aNfItem[nItem][IT_BASEIRR] := 0
EndIf

Return(aNfItem[nItem][IT_BASEIRR])

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisVLIR ³ Autor ³ Edson Maricate        ³ Data ³04.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o valor do Imposto de Renda do Item.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisVLIR(nItem)

Local nSomaIRF  := 0
Local lTbProgressiva := .F.
Local aBIR      := {}
Local nX        := 0	// controle de loop
Local cNatureza := ""
aEval(aNfItem,{|x| nSomaIRF += IIf(!x[IT_DELETED],x[IT_BASEIRR],0)})

If aNfItem[nItem][IT_ALIQIRR] <> 0
	If Len(AllTrim(aNFCAB[NF_CNPJ])) < 14
		If aNfCab[NF_CLIFOR] == "F" .OR. (aNfCab[NF_CLIFOR] == "C" .AND. aNfCab[NF_ALIQIR]==0)
			lTbProgressiva := .T.
    	EndIf
  	EndIf
EndIf
If !lTbProgressiva
	aNfItem[nItem][IT_VALIRR] := aNfItem[nItem][IT_BASEIRR] * aNfItem[nItem][IT_ALIQIRR] /100
Else
	If aNfCab[NF_MODIRF]<>"2"


		aBIR := MaTbIrfPF(aNfItem[nItem][IT_BASEIRR],nSomaIRF-aNfItem[nItem][IT_BASEIRR],.T.,aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA])
		For nX := 1 To Len(aNFItem)
			aNFItem[nX][IT_ALIQIRR] := aBIR[2]
		Next nX
		MaFisRatRes("IT_VALIRR",aBIR[1],aBIR[2],"IT_ALIQIRR","IT_BASEIRR",nItem)
		MaIt2Cab(nItem)

	Else
		If aNfItem[nItem][IT_BASEIRR]-MaTbIrfPF(aNfItem[nItem][IT_BASEIRR],nSomaIRF-aNfItem[nItem][IT_BASEIRR],.T.,aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA])[4] > 0
			aNfItem[nItem][IT_VALIRR] := aNfItem[nItem][IT_BASEIRR] * aNfItem[nItem][IT_ALIQIRR] /100
		Else
			aNfItem[nItem][IT_VALIRR] := 0
		EndIf
	EndIf

EndIf

Return(aNfItem[nItem][IT_VALIRR])

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisBsINS³ Autor ³ Edson Maricate        ³ Data ³04.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o base de Caluculo do INSS do item                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisBSINSS(nItem)

If MaSBCampo("INSS") == "S" .AND. aNfCab[NF_RECINSS]=="S" .AND. aTES[TS_DUPLIC]=="S"
	aNfItem[nItem][IT_BASEINS] := (aNfItem[nItem][IT_TOTAL]+If(SuperGetMV("MV_INSSDES")=="1",aNfItem[nItem,IT_DESCONTO],0) )*;
		IIf(aNfItem[nItem][IT_REDINSS]>0,aNfItem[nItem][IT_REDINSS]/100,1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  	//³ Abatimento da base de calculo do INSS                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aNfItem[nItem][IT_BASEINS] -= aNfItem[nItem,IT_ABVLINSS]

Else
	aNfItem[nItem][IT_BASEINS] := 0
EndIf

Return(aNfItem[nItem][IT_BASEINS])


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisVLINS³ Autor ³ Edson Maricate        ³ Data ³04.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o valor do INSS do item.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisVLINSS(nItem)

Local aArea     := GetArea()
Local aAreaSA2  := SA2->(GetArea())
Local nLimINSS  := GetNewPar("MV_LIMINSS",0)
Local nInssAcum := 0
Local nValMaxIns:= 0

aNfItem[nItem][IT_VALINS] := aNfItem[nItem][IT_BASEINS] * aNfItem[nItem][IT_ALIQINS] /100
If aNFCab[NF_OPERNF]=="E" .AND. aNFCab[NF_CLIFOR]=="F" .AND. Len(AllTrim(aNFCab[NF_CNPJ]))<14 .AND. Len(AllTrim(aNFCab[NF_CNPJ]))>1 .AND. nLimInss > 0
	dbSelectArea("SA2")
	dbSetOrder(1)
	MsSeek(xFilial("SA2")+aNfCab[NF_CODCLIFOR]+aNfCab[NF_LOJA])
	nInssAcum  := VerInssAcm(SA2->A2_COD,SA2->A2_LOJA,SA2->A2_NREDUZ,dDataBase)
	nValMaxIns := ( nLimInss - nInssAcum )
	Do Case
		Case nValMaxIns <= 0
			aNfItem[nItem][IT_VALINS] := 0
		Case nValMaxIns < aNfItem[nItem][IT_VALINS]
			aNfItem[nItem][IT_VALINS] :=  nValMaxIns
	EndCase
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abatimento da valor do INSS em valor - Subcontratada         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aNfItem[nItem][IT_VALINS] >= aNfItem[nItem][IT_ABSCINS] .And. aNfItem[nItem][IT_ABSCINS] > 0
	aNfItem[nItem][IT_VALINS] -= aNfItem[nItem][IT_ABSCINS]
Endif

RestArea(aAreaSA2)
RestArea(aArea)
Return(aNfItem[nItem][IT_VALINS])

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisVRur ³ Autor ³ Edson Maricate        ³ Data ³20.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa o calculo do Valor do funrural no item especificado.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisVRur(nItem)

Local nItemIni := IIf(nItem==Nil,1,nItem)
Local nItemFim := IIf(nItem==Nil,Len(aNfItem),nItem)
Local nX       := 0		// controle de loop

For nX := nItemIni to nItemFim
	aNfItem[nX][IT_FUNRURAL]	:= aNfItem[nX][IT_VALMERC] * aNfItem[nX][IT_PERFUN] / 100
Next nX
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisDel  ³ Autor ³ Edson Maricate        ³ Data ³21.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Marca/Desmarca o item especificado como deletado.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1	: Numero do Item.                                     ³±±
±±³          ³ExpL2 : .T. - Deleta o item , .F. - Ativa o item            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisDel(nItem,lDelete)

If MaFisFound("IT",nItem)
	If lDelete
		If !aNfItem[nItem][IT_DELETED]
			aNfItem[nItem][IT_DELETED]	:= .T.
			MaIt2Cab()
		EndIf
	Else
		If aNfItem[nItem][IT_DELETED]
			aNfItem[nItem][IT_DELETED]	:= .F.
			If cPaisLoc<>"BRA"
				MaFisRecal("IT_VALMERC",nItem)
			Endif
			MaIt2Cab()
		EndIf
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisRecal³ Autor ³  Edson Maricate       ³ Data ³20.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Recalcula os valores de impostos do item.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Campo que sofreu alteracao.                          ³±±
±±³          ³ExpN2: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisRecal(cCampo,nItem)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona os registros necessarios                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT cCampo	:=	''
dbSelectArea(cAliasPROD)
If aNfItem[nItem][IT_RECNOSB1] <> 0 .AND. cAliasPROD=="SB1"
	MsGoto(aNfItem[nItem][IT_RECNOSB1])
Else
	dbSetOrder(1)
	MsSeek(xFilial(cAliasPROD)+aNfItem[nItem][IT_PRODUTO])
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a TES utilizada no calculo de impostos      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaFisTes(aNfItem[nItem][IT_TES],aNfItem[nItem][IT_RECNOSF4],nItem)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa a natureza antes de recalcular                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( aNfCab[NF_NATUREZA] )
	SED->( dbSetOrder(1) )
	SED->( MsSeek(xFilial("SED")+aNfCab[NF_NATUREZA] ) )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento especifico e diferenciado para cada campo.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
Case AllTrim(cCampo) == "IT_CF"
	MaItArred(nItem)	// Ajusta os arredondamentos
	MaFisLF(nItem)
	MaFisLF2(nItem)		// Verifica se a TES possui RdMake para complemento/geracao dos Livros
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_VALMERC"
	aNfItem[nItem][IT_DESCZF] := 0
	If cPaisLoc == "BRA"
		MaAliqSoli(nItem)
		MaExcecao(nItem)	// Verifica se o produto possui excecao fiscal
		MaMargem(nItem)
	Endif
	MaFisPRC(nItem)		// Verifica o preco unitario do item
	If cPaisLoc == "BRA"
		MaFisBSIPI(nItem)
		MaFisVIPI(nItem)
		MaFisBSICM(nItem)
		MaFisVICMS(nItem)
		If !( aTes[TS_TPIPI]=="B" .OR. (MV_IPIBRUTO=="S" .AND. aTes[TS_TPIPI] ==" ") ) .And. ( aTes[TS_AGREG]=="D" )
			MaFisBSIPI(nItem)
			MaFisVIPI(nItem)
		EndIf
		MaItArred(nItem, { "IT_BASEICM","IT_VALICM" } )   // Ajusta os arredondamentos do item
		MaFisVComp(nItem)
		MaFisVDescZF(nItem)
		MaFisBSSol(nItem)
		MaFisVSol(nItem)
		If cPaisLoc == "BRA" .AND. !( aTes[TS_AGREG] $ "B|C"	)
			MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
			MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
			MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
			MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
			If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
				MaFisBSIPI(nItem)
				MaFisVIPI(nItem)
				If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
					MaFisBSICM(nItem,,.T.)
					MaFisVICMS(nItem)
				EndIf
				MaFisBSSol(nItem)
				MaFisVSol(nItem)
			EndIf
		EndIf
		MaFisVRur(nItem)	// Calcula o valor do funrural do item.
		MaFisVSul(nItem)	// Calcula o valor do Fundersul do item
		MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
		MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
		MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
		MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
		MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
		MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
   Endif
	If cPaisLoc=="BRA"
		MaFisAliqIV(,nItem)	// Executa o calculo da Aliquota dos IVs
		MaFisBSIV(,nItem)	// Executa o calculo da Base dos IVs
		MaFisVLIV(,nItem)	// Executa o calculo do Valor dos IVs
	Else
		MaFisImpIV(nItem)
	Endif
	MaFisNameIV(,nItem)	// Verifica o Nome dos Impostos Variaveis
	If cPaisLoc == "BRA" .AND. !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
		If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
			MaFisBSIPI(nItem)
			MaFisVIPI(nItem)
			If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
				MaFisBSICM(nItem,,.T.)
				MaFisVICMS(nItem)
			EndIf
			MaFisBSSol(nItem)
			MaFisVSol(nItem)
		EndIf
	EndIf
	MaFisVTot(nItem)
	If cPaisLoc == "BRA"
		MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
		MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
		MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
		MaALIQIRR(nItem)	// Calcula a Aliquota do IRRF do item
		MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
		MaFisBsISS(nItem)	// Calcula a Base do ISS do item
		MaFisVLISS(nItem)	// Calcula o valor do ISS do item

		If !( aTes[TS_AGREG] $ "B|C"	)
			MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
			MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
			MaFisBsPIS(nItem,"2")	// Calcula a Base do PIS do item
			MaFisVlPIS(nItem,"2")	// Calcula o Valor do PIS do item.
		EndIF

		MaFisBsCSL(nItem)	// Calcula a Base do CSLL do item
		MaFisVlCSL(nItem)	// Calcula o Valor do CSLL do item.
		MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
		MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
		MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
	Endif
	MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
	MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
	MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
	MaFisBsAFRMM(nItem)	// Calcula a Base do AFRMM do item
	MaAliqAFRMM(nItem)	// Calcula a Aliquota do AFRMM do item
	MaFisVlAFRMM(nItem)	// Calcula o Valor do AFRMM do item
	If MaCalcFet()			// Calcula o Imposto FETHAB
		MaFisBSFet(nItem)	// Calcula a base do imposto Fethab
		MaFisAlqFet(nItem)	// Calcula a aliquota do imposto Fethab
		MaFisValFet(nItem)	// Calcula a valor do imposto Fethab
	Endif
Case AllTrim(cCampo) == "IT_BASEICM"
	MaAliqSoli(nItem)
	MaExcecao(nItem)	// Verifica se o produto possui excecao fiscal
	MaMargem(nItem)
	MaFisVICMS(nItem)
	If !( aTes[TS_TPIPI]=="B" .OR. (MV_IPIBRUTO=="S" .AND. aTes[TS_TPIPI] ==" ") )	.And. ( aTes[TS_AGREG]=="D" )
		MaFisBSIPI(nItem)
		MaFisVIPI(nItem)
	EndIf
	MaItArred(nItem, { "IT_BASEICM","IT_VALICM" } )   // Ajusta os arredondamentos do item
	MaFisVComp(nItem)
	MaFisBSSol(nItem)
	MaFisVSol(nItem)
	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
		If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
			MaFisBSIPI(nItem)
			MaFisVIPI(nItem)
			If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
				MaFisBSICM(nItem,,.T.)
				MaFisVICMS(nItem)
			EndIf
			MaFisBSSol(nItem)
			MaFisVSol(nItem)
		EndIf
	EndIf
	MaFisVTot(nItem)
	MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.

	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"2")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"2")	// Calcula o Valor do PIS do item.
	EndIf

	MaFisBsCSL(nItem)	// Calcula a Base do CSLL do item
	MaFisVlCSL(nItem)	// Calcula o Valor do CSLL do item.
	MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
	MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
	MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
	MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
	MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
	MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
Case AllTrim(cCampo) == "IT_ALIQICM"
	If aTes[TS_AGREG] $ "I,A,D"
		MaFisBsICM(nItem)
	Endif
	MaAliqSoli(nItem)
	MaFisVICMS(nItem)
	If !( aTes[TS_TPIPI]=="B" .OR. (MV_IPIBRUTO=="S" .AND. aTes[TS_TPIPI] ==" ") )	.And. ( aTes[TS_AGREG]=="D" )
		MaFisBSIPI(nItem)
		MaFisVIPI(nItem)
	EndIf
	MaItArred(nItem, { "IT_BASEICM","IT_VALICM" } )   // Ajusta os arredondamentos do item

	MaFisVComp(nItem)
	MaFisVSol(nItem)

	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
		If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
			MaFisBSIPI(nItem)
			MaFisVIPI(nItem)
			If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
				MaFisBSICM(nItem,,.T.)
				MaFisVICMS(nItem)
			EndIf
			MaFisBSSol(nItem)
			MaFisVSol(nItem)
		EndIf
	EndIf
	MaFisVTot(nItem)
	MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.

	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"2")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"2")	// Calcula o Valor do PIS do item.
	EndIf

	MaFisBsCSL(nItem)	// Calcula a Base do CSLL do item
	MaFisVlCSL(nItem)	// Calcula o Valor do CSLL do item.
	MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
	MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
	MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
	MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
	MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
	MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
Case AllTrim(cCampo) == "IT_ALIQIPI"
	MaAliqSoli(nItem)
	MaExcecao(nItem)	// Verifica se o produto possui excecao fiscal
	MaMargem(nItem)
	If MaFisRet(nItem,"IT_BASEIPI") == 0
		MaFisBSIPI(nItem)	// Calcula a Base de IPI
	Endif
	MaFisVIPI(nItem)
	If aTes[TS_INCIDE]	== "S"  .OR. (aTes[TS_INCIDE] == "F" .AND. aNFCab[NF_TPCLIFOR] =="F" .AND. aNFCab[NF_CLIFOR] =="C")
		MaFisBsICM(nItem)
		MaFisVICMS(nItem)

		MaItArred(nItem, { "IT_BASEICM","IT_VALICM" } )   // Ajusta os arredondamentos do item

		MaFisVComp(nItem)
	EndIf
	MaFisBSSol(nItem)
	MaFisVSol(nItem)
	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
		If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
			MaFisBSIPI(nItem)
			MaFisVIPI(nItem)
			If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
				MaFisBSICM(nItem,,.T.)
				MaFisVICMS(nItem)
			EndIf
			MaFisBSSol(nItem)
			MaFisVSol(nItem)
		EndIf
	EndIf
	MaFisVTot(nItem)
	MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.

	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"2")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"2")	// Calcula o Valor do PIS do item.
	EndIf

	MaFisBsCSL(nItem)	// Calcula a Base do CSLL do item
	MaFisVlCSL(nItem)	// Calcula o Valor do CSLL do item.
	MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
	MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
	MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
	MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
	MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
	MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
Case AllTrim(cCampo) == "IT_BASEIPI"
	MaAliqSoli(nItem)
	MaExcecao(nItem)	// Verifica se o produto possui excecao fiscal
	MaMargem(nItem)
	MaFisVIPI(nItem)
	If aTes[TS_INCIDE]	== "S" .OR. (aTes[TS_INCIDE] == "F" .AND. aNFCab[NF_TPCLIFOR] =="F" .AND. aNFCab[NF_CLIFOR] =="C")
		MaFisBsIcm(nItem)
		MaFisVICMS(nItem)
		MaItArred(nItem, { "IT_BASEICM","IT_VALICM" } )   // Ajusta os arredondamentos do item
		MaFisVComp(nItem)
		MaFisBSSol(nItem)
		MaFisVSol(nitem)
	EndIf
	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
		If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
			MaFisBSIPI(nItem)
			MaFisVIPI(nItem)
			If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
				MaFisBSICM(nItem,,.T.)
				MaFisVICMS(nItem)
			EndIf
			MaFisBSSol(nItem)
			MaFisVSol(nItem)
		EndIf
	EndIf
	MaFisVTot(nItem)
	MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"2")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"2")	// Calcula o Valor do PIS do item.
	EndIf

	MaFisBsCSL(nItem)	// Calcula a Base do CSLL do item
	MaFisVlCSL(nItem)	// Calcula o Valor do CSLL do item.
	MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
	MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
	MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
	MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
	MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
	MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
Case AllTrim(cCampo) == "IT_VALIPI"
	MaAliqSoli(nItem)
	MaExcecao(nItem)	// Verifica se o produto possui excecao fiscal
	MaMargem(nItem)
	If aTes[TS_INCIDE]	== "S"  .OR. (aTes[TS_INCIDE] == "F" .AND. aNFCab[NF_TPCLIFOR] =="F" .AND. aNFCab[NF_CLIFOR] =="C")
		MaFisBsIcm(nItem)
		MaFisVICMS(nItem)
		MaItArred(nItem, { "IT_BASEICM","IT_VALICM" } )   // Ajusta os arredondamentos do item
		MaFisVComp(nItem)
		MaFisBSSol(nItem)
		MaFisVSol(nItem)
	EndIf
	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
		If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
			MaFisBSIPI(nItem)
			MaFisVIPI(nItem)
			If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
				MaFisBSICM(nItem,,.T.)
				MaFisVICMS(nItem)
			EndIf
			MaFisBSSol(nItem)
			MaFisVSol(nItem)
		EndIf
	EndIf
	MaFisVTot(nItem)
	MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.

	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"2")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"2")	// Calcula o Valor do PIS do item.
	EndIf

	MaFisBsCSL(nItem)	// Calcula a Base do CSLL do item
	MaFisVlCSL(nItem)	// Calcula o Valor do CSLL do item.
	MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
	MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
	MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
	MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
	MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
	MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
Case Alltrim(cCampo) == "IT_BASESOL"
	MaFisVSol(nItem)
	MaFisVTot(nItem)
	MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
	MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
	MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
	MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
Case AllTrim(cCampo) == "IT_ALIQSOL"
	MaFisVSol(nItem)
	MaFisVTot(nItem)
	MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
	MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
	MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
	MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
Case AllTrim(cCampo) == "IT_VALSOL"
	MaFisVTot(nItem)
	MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
	MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
	MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
	MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
	MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
	MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
	MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
Case AllTrim(cCampo) == "IT_MARGEM"
	MaFisBsSol(nItem)
	MaFisVSol(nItem)
	MaFisVTot(nItem)
	MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
	MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
	MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
	MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
Case AllTrim(cCampo) == "IT_ALIQCMP"
	MaFisVComp(nItem)
	MaFisVTot(nItem)
	MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
	MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
	MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
	MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
Case AllTrim(cCampo) == "IT_VALCMP"
	MaFisVTot(nItem)
	MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
	MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
	MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
	MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
Case Alltrim(cCampo) == "IT_VALICM"
	MaFisVComp(nItem)   // Calcula o Valor do ICMS Complementar
	MaFisVTot(nItem)
	MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.

	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"2")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"2")	// Calcula o Valor do PIS do item.
	EndIf

	MaFisBsCSL(nItem)	// Calcula a Base do CSLL do item
	MaFisVlCSL(nItem)	// Calcula o Valor do CSLL do item.
	MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
	MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
	MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
	MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
	MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
	MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
Case AllTrim(cCampo) == "IT_PERFUN"
	MaFisVRur(nItem)	// Calcula o valor do funrural do item.
	MaFisVTot(nItem)
	MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
	MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
	MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
	MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
Case AllTrim(cCampo) == "IT_FUNRURAL"
	MaAliqRur(nItem)
	MaFisVTot(nItem)
	MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
	MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
	MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
	MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
Case AllTrim(cCampo) == "IT_VALFDS"
	MaFisVSul(nItem)	// Calcula o valor do funrural do item.
	MaFisVTot(nItem)
	MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
	MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
	MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
	MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
Case AllTrim(cCampo) == "IT_FRETE" .Or. AllTrim(cCampo) == "IT_VLR_FRT"
	If cPaisLoc == "BRA"
		If !( aTes[TS_AGREG] $ "B|C"	)
			MaAliqSoli(nItem)
		Endif
		MaExcecao(nItem)	// Verifica se o produto possui excecao fiscal
		If !( aTes[TS_AGREG] $ "B|C"	)
			MaMargem(nItem)
			MaFisBSIPI(nItem)	// Calcula a Base de IPI
			MaFisVIPI(nItem)	// Calcula o Valor do IPI
			MaFisBSICM(nItem)	// Calcula a Base de ICMS
			MaFisVICMS(nItem)	// Calcula o Valor do ICMS
			MaItArred(nItem, { "IT_BASEICM","IT_VALICM" } )   // Ajusta os arredondamentos do item
			MaFisVDescZF(nItem)
			MaFisVComp(nItem)	// Calcula o Valor do ICMS Complementar
			MaFisBSSOL(nItem)	// Calcula o Valor da Base do ICMS Solidario
			MaFisVSOL(nItem)	// Calcula o Valor do ICMS Solidario
			If cPaisLoc == "BRA" .AND. !( aTes[TS_AGREG] $ "B|C"	)
				MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
				MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
				MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
				MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
				If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
					MaFisBSIPI(nItem)
					MaFisVIPI(nItem)
					If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
						MaFisBSICM(nItem,,.T.)
						MaFisVICMS(nItem)
					EndIf
					MaFisBSSol(nItem)
					MaFisVSol(nItem)
				EndIf
			EndIf
		EndIf
		MaFisAliqIV(,nItem)	// Executa o calculo da Aliquota dos IVs
		MaFisBSIV(,nItem)	// Executa o calculo da Base dos IVs
		MaFisVLIV(,nItem)	// Executa o calculo do Valor dos IVs
	Else
		MaFisImpIV(nItem)
	Endif

	If cPaisLoc == "BRA" .AND. !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
		If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
			MaFisBSIPI(nItem)
			MaFisVIPI(nItem)
			If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
				MaFisBSICM(nItem,,.T.)
				MaFisVICMS(nItem)
			EndIf
			MaFisBSSol(nItem)
			MaFisVSol(nItem)
		EndIf
	EndIf
	MaFisVTot(nItem)
	If cPaisLoc == "BRA"
		MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
		MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
		MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
		MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
		MaFisBsISS(nItem)	// Calcula a Base do ISS do item
		MaFisVLISS(nItem)	// Calcula o valor do ISS do item

		If !( aTes[TS_AGREG] $ "B|C"	)
			MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
			MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
			MaFisBsPIS(nItem,"2")	// Calcula a Base do PIS do item
			MaFisVlPIS(nItem,"2")	// Calcula o Valor do PIS do item.
		EndIf

		MaFisBsCSL(nItem)	// Calcula a Base do CSLL do item
		MaFisVlCSL(nItem)	// Calcula o Valor do CSLL do item.
		MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
		MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
		MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
	Endif
	MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
	MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
	MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_DESPESA"
	If cPaisLoc == "BRA"
		If !( aTes[TS_AGREG] $ "B|C"	)
			MaAliqSoli(nItem)
		Endif
		MaExcecao(nItem)	// Verifica se o produto possui excecao fiscal
		If !( aTes[TS_AGREG] $ "B|C"	)
			MaMargem(nItem)
			MaFisBSIPI(nItem)	// Calcula a Base de IPI
			MaFisVIPI(nItem)	// Calcula o Valor do IPI
			MaFisBSICM(nItem)	// Calcula a Base de ICMS
			MaFisVICMS(nItem)	// Calcula o Valor do ICMS

			MaItArred(nItem, { "IT_BASEICM","IT_VALICM" } )   // Ajusta os arredondamentos do item
			MaFisVDescZF(nItem)
			MaFisVComp(nItem)	// Calcula o Valor do ICMS Complementar
			MaFisBSSOL(nItem)	// Calcula o Valor da Base do ICMS Solidario
			MaFisVSOL(nItem)	// Calcula o Valor do ICMS Solidario
			If cPaisLoc == "BRA" .AND. !( aTes[TS_AGREG] $ "B|C"	)
				MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
				MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
				MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
				MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
				If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
					MaFisBSIPI(nItem)
					MaFisVIPI(nItem)
					If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
						MaFisBSICM(nItem,,.T.)
						MaFisVICMS(nItem)
					EndIf
					MaFisBSSol(nItem)
					MaFisVSol(nItem)
				EndIf
			EndIf
		EndIf
		MaFisAliqIV(,nItem)	// Executa o calculo da Aliquota dos IVs
		MaFisBSIV(,nItem)	// Executa o calculo da Base dos IVs
		MaFisVLIV(,nItem)	// Executa o calculo do Valor dos IVs

		If !( aTes[TS_AGREG] $ "B|C"	)
			MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
			MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
			MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
			MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
			If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
				MaFisBSIPI(nItem)
				MaFisVIPI(nItem)
				If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
					MaFisBSICM(nItem,,.T.)
					MaFisVICMS(nItem)
				EndIf
				MaFisBSSol(nItem)
				MaFisVSol(nItem)
			EndIf
		EndIf
	Else
		MaFisImpIV(nItem)
	Endif

	MaFisVTot(nItem)
	If cPaisLoc == "BRA"
		MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
		MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
		MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
		MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
		MaFisBsISS(nItem)	// Calcula a Base do ISS do item
		MaFisVLISS(nItem)	// Calcula o valor do ISS do item
		If !( aTes[TS_AGREG] $ "B|C"	)
			MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
			MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
			MaFisBsPIS(nItem,"2")	// Calcula a Base do PIS do item
			MaFisVlPIS(nItem,"2")	// Calcula o Valor do PIS do item.
		EndIf

		MaFisBsCSL(nItem)	// Calcula a Base do CSLL do item
		MaFisVlCSL(nItem)	// Calcula o Valor do CSLL do item.
		MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
		MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
		MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
		MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
		MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
		MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
		MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
		MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
		MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	Endif
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_SEGURO"
	If cPaisLoc == "BRA"
		If !( aTes[TS_AGREG] $ "B|C"	)
			MaAliqSoli(nItem)
		Endif
		MaExcecao(nItem)	// Verifica se o produto possui excecao fiscal
		If !( aTes[TS_AGREG] $ "B|C"	)
			MaMargem(nItem)
			MaFisBSIPI(nItem)	// Calcula a Base de IPI
			MaFisVIPI(nItem)	// Calcula o Valor do IPI
			MaFisBSICM(nItem)	// Calcula a Base de ICMS
			MaFisVICMS(nItem)	// Calcula o Valor do ICMS
			MaItArred(nItem, { "IT_BASEICM","IT_VALICM" } )   // Ajusta os arredondamentos do item
			MaFisVDescZF(nItem)
			MaFisVComp(nItem)	// Calcula o Valor do ICMS Complementar
			MaFisBSSOL(nItem)	// Calcula o Valor da Base do ICMS Solidario
			MaFisVSOL(nItem)	// Calcula o Valor do ICMS Solidario
			If cPaisLoc == "BRA" .AND. !( aTes[TS_AGREG] $ "B|C"	)
				MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
				MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
				MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
				MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
				If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
					MaFisBSIPI(nItem)
					MaFisVIPI(nItem)
					If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
						MaFisBSICM(nItem,,.T.)
						MaFisVICMS(nItem)
					EndIf
					MaFisBSSol(nItem)
					MaFisVSol(nItem)
				EndIf
			EndIf
		Endif
		If !( aTes[TS_AGREG] $ "B|C"	)
			MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
			MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
			MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
			MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
			If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
				MaFisBSIPI(nItem)
				MaFisVIPI(nItem)
				If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
					MaFisBSICM(nItem,,.T.)
					MaFisVICMS(nItem)
				EndIf
				MaFisBSSol(nItem)
				MaFisVSol(nItem)
			EndIf
		EndIf
	Else
		MaFisImpIV(nItem)
	Endif

	MaFisVTot(nItem)
	If cPaisLoc == "BRA"
		MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
		MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
		MaFisAliqIV(,nItem)	// Executa o calculo da Aliquota dos IVs
		MaFisBSIV(,nItem)	// Executa o calculo da Base dos IVs
		MaFisVLIV(,nItem)	// Executa o calculo do Valor dos IVs
		MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
		MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
		MaFisBsISS(nItem)	// Calcula a Base do ISS do item
		MaFisVLISS(nItem)	// Calcula o valor do ISS do item
		If !( aTes[TS_AGREG] $ "B|C"	)
			MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
			MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
			MaFisBsPIS(nItem,"2")	// Calcula a Base do PIS do item
			MaFisVlPIS(nItem,"2")	// Calcula o Valor do PIS do item.
		EndIf

		MaFisBsCSL(nItem)	// Calcula a Base do CSLL do item
		MaFisVlCSL(nItem)	// Calcula o Valor do CSLL do item.
		MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
		MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
		MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
	Endif
	MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
	MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
	MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_REDIR"
	MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_BASEIRR"
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_VALIRR"
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_ALIQIRR"
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_BASESES"
	MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_VALSES"
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_ALIQSES"
	MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_REDINSS"
	MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
	MaFisVlINSS(nItem)	// Calcula o Valor do IRRF do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_BASEINS"
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_ABVLINSS"
	MaFisBsINSS(nItem) // Calcula a base do INSS do item
	MaFisVlINSS(nItem) // Calcula o Valor do INSS do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_ABSCINS"
	MaFisBsINSS(nItem) // Calcula a base do INSS do item
	MaFisVlINSS(nItem) // Calcula o Valor do INSS do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_ABVLISS"
	MaFisBsISS(nItem) // Calcula a base do ISS do item
	MaFisVlISS(nItem)
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_ABMATISS"
	MaFisBsISS(nItem) // Calcula a base do ISS do item
	MaFisVlISS(nItem)
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_VALINS"
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_ALIQINS"
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_VALISS"
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_REDISS"
	MaFisBsISS(nItem)
	MaFisVlISS(nItem)
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_BASEISS"
	MaFisVlISS(nItem)
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_ALIQISS"
	MaFisVlISS(nItem)
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_CODISS"
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_CFPS"
	MaFisLF(nItem)
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_RGESPST"
	MaFisLF(nItem)
Case Alltrim(cCampo) == "IT_BASECOF"
	MaFisVlCOF(nItem)	// Calcula o Valor do COFINS do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
Case Alltrim(cCampo) == "IT_ALIQCOF"
	MaFisVlCOF(nItem)	// Calcula o Valor do COFINS do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
Case Alltrim(cCampo) == "IT_BASEPIS"
	MaFisVlPIS(nItem)	// Calcula o Valor do PIS do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
Case Alltrim(cCampo) == "IT_ALIQPIS"
	MaFisVlPIS(nItem)	// Calcula o Valor do PIS do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)			// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_BASEPS2"
	MaFisVlPIS(nItem)	// Calcula o Valor do PIS do item.
	MaFisVTot(nItem)

	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlPIS(nItem,"2")	// Calcula o Valor do COFINS do item.
	EndIf

	MaFisBsCSL(nItem)
	MaFisVlCSL(nItem)
	MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
	MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
	MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_BASECF2"
	MaFisVlCOF(nItem)	// Calcula o Valor do COFINS do item.
	MaFisVTot(nItem)

	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlPIS(nItem,"2")	// Calcula o Valor do COFINS do item.
	EndIf

	MaFisBsCSL(nItem)
	MaFisVlCSL(nItem)
	MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
	MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
	MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_ALIQPS2"
	MaFisVlPIS(nItem)	// Calcula o Valor do PIS do item.

	MaFisVTot(nItem)

	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlPIS(nItem,"2")	// Calcula o Valor do COFINS do item.
	EndIf

	MaFisBsCSL(nItem)
	MaFisVlCSL(nItem)
	MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
	MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
	MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)			// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_ALIQCF2"
	MaFisVlCOF(nItem)	// Calcula o Valor do COFINS do item.
	MaFisVTot(nItem)

	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlPIS(nItem,"2")	// Calcula o Valor do COFINS do item.
	EndIf

	MaFisBsCSL(nItem)
	MaFisVlCSL(nItem)
	MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
	MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
	MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)			// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_VALPS2"
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisVTot(nItem)

	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlPIS(nItem,"2")	// Calcula o Valor do COFINS do item.
	EndIf

	MaFisBsCSL(nItem)
	MaFisVlCSL(nItem)
	MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
	MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
	MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)			// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_VALCF2"
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisVTot(nItem)

	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlPIS(nItem,"2")	// Calcula o Valor do COFINS do item.
	EndIf

	MaFisBsCSL(nItem)
	MaFisVlCSL(nItem)
	MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
	MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
	MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)			// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_BASECSL"
	MaFisVlCSL(nItem)	// Calcula o Valor do CSLL do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)			// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_ALIQCSL"
	MaFisVlCSL(nItem)	// Calcula o Valor do CSLL do item.
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)			// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_VALCSL"
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)			// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_VALCOF"
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)			// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_VALPIS"
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)			// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_DESCONTO"
	If cPaisLoc <> "BRA"
		MaPrcVen(nItem)
		MaFisImpIV(nItem)
	Else
		MaAliqSoli(nItem)
		MaExcecao(nItem)	// Verifica se o produto possui excecao fiscal
		MaMargem(nItem)
		MaFisBSIPI(nItem)	// Calcula a Base de IPI
		MaFisVIPI(nItem)	// Calcula o Valor do IPI
		MaFisBSICM(nItem)	// Calcula a Base de ICMS
		MaFisVICMS(nItem)	// Calcula o Valor do ICMS
		If !( aTes[TS_TPIPI]=="B" .OR. (MV_IPIBRUTO=="S" .AND. aTes[TS_TPIPI] ==" ") ) .And. ( aTes[TS_AGREG]=="D" )
			MaFisBSIPI(nItem)
			MaFisVIPI(nItem)
		EndIf
		MaItArred(nItem, { "IT_BASEICM","IT_VALICM" } )   // Ajusta os arredondamentos do item
		MaFisVComp(nItem)	// Calcula o Valor do ICMS Complementar
		MaFisBSSOL(nItem)	// Calcula o Valor da Base do ICMS Solidario
		MaFisVSOL(nItem)	// Calcula o Valor do ICMS Solidario
		MaFisAliqIV(,nItem)	// Executa o calculo da Aliquota dos IVs
		MaFisBSIV(,nItem)	// Executa o calculo da Base dos IVs
		MaFisVLIV(,nItem)	// Executa o calculo do Valor dos IVs
	Endif
	MaFisNameIV(,nItem)	// Verifica o Nome dos Impostos Variaveis
	If cPaisLoc == "BRA"
		If !( aTes[TS_AGREG] $ "B|C"	)
			MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
			MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
			MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
			MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
			If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
				MaFisBSIPI(nItem)
				MaFisVIPI(nItem)
				If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
					MaFisBSICM(nItem,,.T.)
					MaFisVICMS(nItem)
				EndIf
				MaFisBSSol(nItem)
				MaFisVSol(nItem)
			EndIf
		EndIf
	Endif

	MaFisVTot(nItem)
	If cPaisLoc == "BRA"
		MaFisRdINSS(nItem)	// Calcula o Percentual de reducao do INSS do item
		MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
		MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
		MaFisRdIR(nItem)	// Calcula o Percentual de reducao do IRFF do item
		MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
		MaALIQIRR(nItem)	// Calcula a aliquota do IRRF do item
		MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
		MaFisBsISS(nItem)	// Calcula a Base do ISS do item
		MaFisVLISS(nItem)	// Calcula o valor do ISS do item
		If !( aTes[TS_AGREG] $ "B|C"	)
			MaFisBsPIS(nItem,"2")	// Calcula a Base do PIS do item
			MaFisVlPIS(nItem,"2")	// Calcula o Valor do PIS do item.
			MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
			MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
		EndIf
		MaFisBsCSL(nItem)	// Calcula a Base do CSLL do item
		MaFisVlCSL(nItem)	// Calcula o Valor do CSLL do item.
		MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
		MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
		MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
		MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
		MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
		MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	Endif
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case Substr(cCampo,1,9) == "IT_BASEIV"
	MaFisVLIV(Ascan(aTes[TS_SFC],{|x| Substr(x[10],10,1) == Substr(cCampo,10,1)}),nItem)	// Executa o calculo do Valor dos IVs
	MaFisVTot(nItem)	// Calcula o valor total do item
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF2(nItem)	// Verifica se a TES possui RdMake para complemento/geracao dos Livros
	MaFisLF3(nItem)
Case Substr(cCampo,1,8) == "IT_VALIV"
	MaFisVTot(nItem)	// Calcula o valor total do item
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF2(nItem)	// Verifica se a TES possui RdMake para complemento/geracao dos Livros
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_AUTONOMO"
	MaFisBSSOL(nItem)
	MaFisVSol(nItem)
	MaFisBsICA(nItem)		// Calcula o valor da Base do ICMS Autonomo
	MaFisVlICA(nItem)		// Calcula o valor do ICMS Autonomo
	MaFisVTot(nItem)
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)			// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_BASEICA"
	MaFisVlICA(nItem)		// Calcula o valor do ICMS Autonomo
	MaFisVTot(nItem)
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)			// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_VALICA"
	MaFisVTot(nItem)
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)			// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_FUNRURAL"
	MaFisVTot(nItem)
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "NF_NATUREZA"
	If cPaisLoc == "BRA"
	MaALIQINS(nItem)	// CalCula a Aliquota do INSS
	MaAliqISS(nItem)	// CalCula a Aliquota do ISS
	If !( aTes[TS_AGREG] $ "B|C"	)
		MaAliqCOF(nItem)	// CalCula a Aliquota do COFINS
		MaAliqCSL(nItem)	// CalCula a Aliquota do CSLL
		MaAliqPIS(nItem)	// CalCula a Aliquota do PIS
		MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
		MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
		If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
			MaFisBSIPI(nItem)
			MaFisVIPI(nItem)
			If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
				MaFisBSICM(nItem,,.T.)
				MaFisVICMS(nItem)
			EndIf
			MaFisBSSol(nItem)
			MaFisVSol(nItem)
		EndIf
	EndIf
	MaFisVTot(nItem)	// Calcula o valor total do item
	MaFisRdINSS(nItem)	// Calcula o Percentual de reducao do INSS do item
	MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaFisRdIR(nItem)	// Calcula o Percentual de reducao do IRFF do item
	MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
	MaALIQIRR(nItem)	// Calcula a Aliquota do IRRF do item
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
	MaFisBsISS(nItem)	// Calcula a Base do ISS do item
	MaFisVLISS(nItem)	// Calcula o valor do ISS do item

	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"2")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"2")	// Calcula o Valor do PIS do item.
	EndIf

	MaFisBsCSL(nItem)	// Calcula a Base do CSLL do item
	MaFisVlCSL(nItem)	// Calcula o Valor do CSLL do item.
		MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
		MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
		MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
		MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
		MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
		MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	Endif
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_TES"
	If cPaisLoc == "BRA"
		MaExcecao(nItem)	// Verifica se o produto possui excecao fiscal
	Endif
	MaFisPRC(nItem)		// Verifica o preco unitario do item
	MaFisCFO(nItem)		// Verifica o Codigo Fiscal de Operacao
	If cPaisLoc == "BRA"
		MaAliqRur(nItem)	// Calcula a Aliquota de calculo do Funrural
		MaFisVSul(nItem)	// Calcula o valor do Fundersul do item
		If (Empty( MaFisRet(nItem,"IT_ALIQICM") ) .OR. aTes[TS_ICM]=="N") .AND. !( aTes[TS_AGREG] $ "B|C" )
			MaAliqIcms(nItem)	// Calcula a Aliquota de ICMS
		EndIf
		If (Empty( MaFisRet(nItem,"IT_ALIQIPI") ) .OR. aTes[TS_IPI]=="N") .AND. !( aTes[TS_AGREG] $ "B|C" )
			MaAliqIPI(nItem)	// Calcula a Aloquota de IPI
		EndIf

		If !( aTes[TS_AGREG] $ "B|C" )
			MaALIQCMP(nItem)	// Calcula a Aliquota do ICMS Complementar
			MaAliqSoli(nItem)	// Calcula a Aliquota do ICMS Solidario
		Endif

		MaALIQINS(nItem)	// CalCula a Aliquota do INSS
		MaAliqISS(nItem)	// CalCula a Aliquota do ISS
		If !( aTes[TS_AGREG] $ "B|C"	)
			MaAliqCOF(nItem)	// CalCula a Aliquota do COFINS
			MaAliqCSL(nItem)	// CalCula a Aliquota do CSLL
			MaAliqPIS(nItem)	// CalCula a Aliquota do PIS
			MaMargem(nItem)		// Calcula o Valor da Margem de lucro
			MaFisBSIPI(nItem)	// Calcula a Base de IPI
			MaFisVIPI(nItem)	// Calcula o Valor do IPI
			MaFisBSICM(nItem)	// Calcula a Base de ICMS
			MaFisVICMS(nItem)	// Calcula o Valor do ICMS

			MaItArred(nItem, { "IT_BASEICM","IT_VALICM" } )   // Ajusta os arredondamentos do item

			MaFisVComp(nItem)	// Calcula o Valor do ICMS Complementar
		Endif
		MaFisVDescZF(nItem)
		If !( aTes[TS_AGREG] $ "B|C" )
			MaFisBSSOL(nItem)	// Calcula o Valor da Base do ICMS Solidario
			MaFisVSOL(nItem)	// Calcula o Valor do ICMS Solidario
			MaFisBsICA(nItem)	// Calcula o valor da Base do ICMS Autonomo
			MaFisVlICA(nItem)	// Calcula o valor do ICMS Autonomo
		EndIf
		If cPaisLoc == "BRA" .AND. !( aTes[TS_AGREG] $ "B|C"	)
			MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
			MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
			MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
			MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
			If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
				MaFisBSIPI(nItem)
				MaFisVIPI(nItem)
				If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
					MaFisBSICM(nItem,,.T.)
					MaFisVICMS(nItem)
				EndIf
				MaFisBSSol(nItem)
				MaFisVSol(nItem)
			EndIf
		EndIf
		MaFisVRur(nItem)	// Calcula o valor do funrural do item.
		MaFisVSul(nItem)	// Calcula o valor do Fundersul do item
		MaFisAliqIV(,nItem)	// Executa o calculo da Aliquota dos IVs
		MaFisBSIV(,nItem)	// Executa o calculo da Base dos IVs
		MaFisVLIV(,nItem)	// Executa o calculo do Valor dos IVs
	Else
		MaFisImpIV(nItem)
	Endif
	MaFisNameIV(,nItem)	// Verifica o Nome dos Impostos Variaveis

	If cPaisLoc == "BRA" .AND. !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
		If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
			MaFisBSIPI(nItem)
			MaFisVIPI(nItem)
			If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
				MaFisBSICM(nItem,,.T.)
				MaFisVICMS(nItem)
			EndIf
			MaFisBSSol(nItem)
			MaFisVSol(nItem)
		EndIf
	EndIf
	MaFisVTot(nItem)	// Calcula o valor total do item
	If cPaisLoc == "BRA"
		MaFisRdINSS(nItem)	// Calcula o Percentual de reducao do INSS do item
		MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
		MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
		MaFisRdIR(nItem)	// Calcula o Percentual de reducao do IRFF do item
		MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
		MaALIQIRR(nItem)	// Calcula a Aliquota do IRRF do item
		MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
		MaFisBsISS(nItem)	// Calcula a Base do ISS do item
		MaFisVLISS(nItem)	// Calcula o valor do ISS do item

		If !( aTes[TS_AGREG] $ "B|C"	)
			MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
			MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
			MaFisBsPIS(nItem,"2")	// Calcula a Base do PIS do item
			MaFisVlPIS(nItem,"2")	// Calcula o Valor do PIS do item.
		EndIf

		MaFisBsCSL(nItem)	// Calcula a Base do CSLL do item
		MaFisVlCSL(nItem)	// Calcula o Valor do CSLL do item.
		MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
		MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
		MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
		MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
		MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
		MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
		MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
		MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
		MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	Endif
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF2(nItem)		// Verifica se a TES possui RdMake para complemento/geracao dos Livros
	MaFisLF3(nItem)
	MaFisBsAFRMM(nItem)	// Calcula a Base do AFRMM do item
	MaAliqAFRMM(nItem)	// Calcula a Aliquota do AFRMM do item
	MaFisVlAFRMM(nItem)	// Calcula o Valor do AFRMM do item
	If MaCalcFet()			// Calcula o Imposto FETHAB
		MaFisBSFet(nItem)	// Calcula a base do imposto Fethab
		MaFisAlqFet(nItem)	// Calcula a aliquota do imposto Fethab
		MaFisValFet(nItem)	// Calcula a valor do imposto Fethab
	Endif
Case AllTrim(cCampo) == "IT_VALEMB"
	MaExcecao(nItem)	// Verifica se o produto possui excecao fiscal
	MaFisPRC(nItem)		// Verifica o preco unitario do item
	MaFisCFO(nItem)		// Verifica o Codigo Fiscal de Operacao
	MaAliqRur(nItem)	// Calcula a Aliquota de calculo do Funrural
	MaFisVSul(nItem)	// Calcula o valor do Fundersul do item
	If Empty( MaFisRet(nItem,"IT_ALIQICM") ) .OR. aTes[TS_ICM]=="N"
		MaAliqIcms(nItem)	// Calcula a Aliquota de ICMS
	EndIf
	If Empty( MaFisRet(nItem,"IT_ALIQIPI") ) .OR. aTes[TS_IPI]=="N"
		MaAliqIPI(nItem)	// Calcula a Aloquota de IPI
	EndIf
	MaALIQCMP(nItem)	// Calcula a Aliquota do ICMS Complementar
	MaAliqSoli(nItem)	// Calcula a Aliquota do ICMS Solidario
	MaALIQINS(nItem)	// CalCula a Aliquota do INSS
	MaAliqISS(nItem)	// CalCula a Aliquota do ISS
	MaAliqCOF(nItem)	// CalCula a Aliquota do COFINS
	MaAliqCSL(nItem)	// CalCula a Aliquota do CSLL
	MaAliqPIS(nItem)	// CalCula a Aliquota do PIS
	MaMargem(nItem)		// Calcula o Valor da Margem de lucro
	MaFisBSIPI(nItem)	// Calcula a Base de IPI
	MaFisVIPI(nItem)	// Calcula o Valor do IPI
	MaFisBSICM(nItem)	// Calcula a Base de ICMS
	MaFisVICMS(nItem)	// Calcula o Valor do ICMS
	If !( aTes[TS_TPIPI]=="B" .OR. (MV_IPIBRUTO=="S" .AND. aTes[TS_TPIPI] ==" ") ) .And. ( aTes[TS_AGREG]=="D" )
		MaFisBSIPI(nItem)
		MaFisVIPI(nItem)
	EndIf
	MaItArred(nItem, { "IT_BASEICM","IT_VALICM" } )   // Ajusta os arredondamentos do item
	MaFisVComp(nItem)	// Calcula o Valor do ICMS Complementar
	MaFisVDescZF(nItem)
	MaFisBSSOL(nItem)	// Calcula o Valor da Base do ICMS Solidario
	MaFisVSOL(nItem)	// Calcula o Valor do ICMS Solidario
	If cPaisLoc == "BRA" .AND. !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
		If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
			MaFisBSIPI(nItem)
			MaFisVIPI(nItem)
			If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
				MaFisBSICM(nItem,,.T.)
				MaFisVICMS(nItem)
			EndIf
			MaFisBSSol(nItem)
			MaFisVSol(nItem)
		EndIf
	EndIf
	MaFisBsICA(nItem)	// Calcula o valor da Base do ICMS Autonomo
	MaFisVlICA(nItem)	// Calcula o valor do ICMS Autonomo
	MaFisVRur(nItem)	// Calcula o valor do funrural do item.
	MaFisVSul(nItem)	// Calcula o valor do Fundersul do item
	If cPaisLoc=="BRA"
		MaFisAliqIV(,nItem)	// Executa o calculo da Aliquota dos IVs
		MaFisBSIV(,nItem)	// Executa o calculo da Base dos IVs
		MaFisVLIV(,nItem)	// Executa o calculo do Valor dos IVs
	Else
		MaFisImpIV(nItem)
	Endif
	MaFisNameIV(,nItem)	// Verifica o Nome dos Impostos Variaveis
	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
		If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
			MaFisBSIPI(nItem)
			MaFisVIPI(nItem)
			If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
				MaFisBSICM(nItem,,.T.)
				MaFisVICMS(nItem)
			EndIf
			MaFisBSSol(nItem)
			MaFisVSol(nItem)
		EndIf
	EndIf
	MaFisVTot(nItem)	// Calcula o valor total do item
	MaFisRdINSS(nItem)	// Calcula o Percentual de reducao do INSS do item
	MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaFisRdIR(nItem)	// Calcula o Percentual de reducao do IRFF do item
	MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
	MaALIQIRR(nItem)	// Calcula a Aliquota do IRRF do item
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
	MaFisBsISS(nItem)	// Calcula a Base do ISS do item
	MaFisVLISS(nItem)	// Calcula o valor do ISS do item
	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"2")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"2")	// Calcula o Valor do PIS do item.
	EndIf
	MaFisBsCSL(nItem)	// Calcula a Base do CSLL do item
	MaFisVlCSL(nItem)	// Calcula o Valor do CSLL do item.
	MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
	MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
	MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF2(nItem)		// Verifica se a TES possui RdMake para complemento/geracao dos Livros
	MaFisLF3(nItem)
Case Alltrim(cCampo) == "IT_DESCZF"
	MaFisBSSOL(nItem)	// Calcula o Valor da Base do ICMS Solidario
	MaFisVSOL(nItem)	// Calcula o Valor do ICMS Solidario
	MaFisBsICA(nItem)	// Calcula o valor da Base do ICMS Autonomo
	MaFisVlICA(nItem)	// Calcula o valor do ICMS Autonomo
	MaFisVRur(nItem)	// Calcula o valor do funrural do item.
	MaFisVSul(nItem)	// Calcula o valor do Fundersul do item
	If cPaisLoc=="BRA"
		MaFisAliqIV(,nItem)	// Executa o calculo da Aliquota dos IVs
		MaFisBSIV(,nItem)	// Executa o calculo da Base dos IVs
		MaFisVLIV(,nItem)	// Executa o calculo do Valor dos IVs
	Else
		MaFisImpIV(nItem)
	Endif
	MaFisNameIV(,nItem)	// Verifica o Nome dos Impostos Variaveis
	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
		MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
		If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
			MaFisBSIPI(nItem)
			MaFisVIPI(nItem)
			If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
				MaFisBSICM(nItem,,.T.)
				MaFisVICMS(nItem)
			EndIf
			MaFisBSSol(nItem)
			MaFisVSol(nItem)
		EndIf
	EndIf
	MaFisVTot(nItem)	// Calcula o valor total do item
	MaFisRdINSS(nItem)	// Calcula o Percentual de reducao do INSS do item
	MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
	MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
	MaFisRdIR(nItem)	// Calcula o Percentual de reducao do IRFF do item
	MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
	MaALIQIRR(nItem)	// Calcula a Aliquota do IRRF do item
	MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
	MaFisBsISS(nItem)	// Calcula a Base do ISS do item
	MaFisVLISS(nItem)	// Calcula o valor do ISS do item

	If !( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsPIS(nItem,"2")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"2")	// Calcula o Valor do PIS do item.
		MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
	EndIf

	MaFisBsCSL(nItem)	// Calcula a Base do CSLL do item
	MaFisVlCSL(nItem)	// Calcula o Valor do CSLL do item.
	MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
	MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
	MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
	MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF2(nItem)		// Verifica se a TES possui RdMake para complemento/geracao dos Livros
	MaFisLF3(nItem)
Case AllTrim(cCampo) == "IT_BASEDUP"
	MaItArred(nItem)	// Ajusta os arredondamentos do item
OtherWise
	If cPaisLoc == "BRA"
		MaExcecao(nItem)	// Verifica se o produto possui excecao fiscal
	Endif
	MaFisPRC(nItem)		// Verifica o preco unitario do item
	MaFisCFO(nItem)		// Verifica o Codigo Fiscal de Operacao
	If cPaisLoc == "BRA"
		MaAliqRur(nItem)	// Calcula a Aliquota de calculo do Funrural
		MaFisVSul(nItem)	// Calcula o valor do Fundersul do item
		If Empty( MaFisRet(nItem,"IT_ALIQICM") ) .OR. aNfCab[NF_TIPONF] $ "DB" .OR. ;
			"NF_" $ Alltrim(cCampo) .OR. "IT_RECORI" $ Alltrim(cCampo) .OR.;
			"IT_PRODUTO" $ Alltrim(cCampo) .OR. "IT_GRPTRIB" $ Alltrim(cCampo)

			MaAliqIcms(nItem)	// Calcula a Aliquota de ICMS
		Endif
		If Empty( MaFisRet(nItem,"IT_ALIQIPI") ) .OR. aNfCab[NF_TIPONF] $ "DB" .OR. ;
			"NF_" $ Alltrim(cCampo) .OR. "IT_RECORI" $ Alltrim(cCampo) .OR. ;
			"IT_PRODUTO" $ Alltrim(cCampo) .OR. "IT_GRPTRIB" $ Alltrim(cCampo)
			MaAliqIPI(nItem)	// Calcula a Aloquota de IPI
		Endif
		MaALIQCMP(nItem)	// Calcula a Aliquota do ICMS Complementar
		MaAliqSoli(nItem)	// Calcula a Aliquota do ICMS Solidario

		MaALIQINS(nItem)	// CalCula a Aliquota do INSS
		MaAliqISS(nItem)	// CalCula a Aliquota do ISS
		If !( aTes[TS_AGREG] $ "B|C"	)
			MaAliqCOF(nItem)	// CalCula a Aliquota do COFINS
			MaAliqCSL(nItem)	// CalCula a Aliquota do CSLL
			MaAliqPIS(nItem)	// CalCula a Aliquota do PIS
		EndIf
		MaMargem(nItem)		// Calcula o Valor da Margem de lucro
		MaFisBSIPI(nItem)	// Calcula a Base de IPI
		MaFisVIPI(nItem)	// Calcula o Valor do IPI
		MaFisBSICM(nItem)	// Calcula a Base de ICMS
		MaFisVICMS(nItem)	// Calcula o Valor do ICMS
		If !( aTes[TS_TPIPI]=="B" .OR. (MV_IPIBRUTO=="S" .AND. aTes[TS_TPIPI] ==" ") ) .And. ( aTes[TS_AGREG]=="D" )
			MaFisBSIPI(nItem)
			MaFisVIPI(nItem)
		EndIf
		MaItArred(nItem, { "IT_BASEICM","IT_VALICM" } )   // Ajusta os arredondamentos do item
		MaFisVComp(nItem)	// Calcula o Valor do ICMS Complementar
		MaFisVDescZF(nItem)
		MaFisBSSOL(nItem)	// Calcula o Valor da Base do ICMS Solidario
		MaFisVSOL(nItem)	// Calcula o Valor do ICMS Solidario
		If cPaisLoc == "BRA" .AND. !( aTes[TS_AGREG] $ "B|C"	)
			MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
			MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
			MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
			MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
			If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
				MaFisBSIPI(nItem)
				MaFisVIPI(nItem)
				If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
					MaFisBSICM(nItem,,.T.)
					MaFisVICMS(nItem)
				EndIf
				MaFisBSSol(nItem)
				MaFisVSol(nItem)
			EndIf
		EndIf
		MaFisBsICA(nItem)	// Calcula o valor da Base do ICMS Autonomo
		MaFisVlICA(nItem)	// Calcula o valor do ICMS Autonomo
		MaFisVRur(nItem)	// Calcula o valor do funrural do item.
		MaFisVSul(nItem)	// Calcula o valor do Fundersul do item
		MaFisAliqIV(,nItem)	// Executa o calculo da Aliquota dos IVs
		MaFisBSIV(,nItem)	// Executa o calculo da Base dos IVs
		MaFisVLIV(,nItem)	// Executa o calculo do Valor dos IVs
	Else
		MaFisImpIV(nItem)
	Endif

	MaFisNameIV(,nItem)	// Verifica o Nome dos Impostos Variaveis

	If cPaisLoc == "BRA" .AND.!( aTes[TS_AGREG] $ "B|C"	)
		MaFisBsCOF(nItem,"1")	// Calcula a Base do COFINS do item
		MaFisVlCOF(nItem,"1")	// Calcula o Valor do COFINS do item.
		MaFisBsPIS(nItem,"1")	// Calcula a Base do PIS do item
		MaFisVlPIS(nItem,"1")	// Calcula o Valor do PIS do item.
		If aNfItem[nItem][IT_DESCZFPIS] <> 0 .OR. aNfItem[nItem][IT_DESCZFCOF] <> 0
			MaFisBSIPI(nItem)
			MaFisVIPI(nItem)
			If aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS]+aNfItem[nItem][IT_DESCZFCOF]) == 0
				MaFisBSICM(nItem,,.T.)
				MaFisVICMS(nItem)
			EndIf
			MaFisBSSol(nItem)
			MaFisVSol(nItem)
		EndIf
	EndIf
	MaFisVTot(nItem)	// Calcula o valor total do item
	If cPaisLoc == "BRA"
		MaFisRdINSS(nItem)	// Calcula o Percentual de reducao do INSS do item
		MaFisBsINSS(nItem)	// Calcula a Base do INSS do item
		MaFisVlINSS(nItem)	// Calcula o Valor do INSS do item.
		MaFisRdIR(nItem)	// Calcula o Percentual de reducao do IRFF do item
		MaFisBsIR(nItem)	// Calcula a Base do IRRF do item
		MaALIQIRR(nItem)	// Calcula a Aliquota do IRRF do item
		MaFisVlIR(nItem)	// Calcula o Valor do IRRF do item.
		MaFisBsISS(nItem)	// Calcula a Base do ISS do item
		MaFisVLISS(nItem)	// Calcula o valor do ISS do item

		If !( aTes[TS_AGREG] $ "B|C"	)
			MaFisBsCOF(nItem,"2")	// Calcula a Base do COFINS do item
			MaFisVlCOF(nItem,"2")	// Calcula o Valor do COFINS do item.
			MaFisBsPIS(nItem,"2")	// Calcula a Base do PIS do item
			MaFisVlPIS(nItem,"2")	// Calcula o Valor do PIS do item.
		EndIf

		MaFisBsCSL(nItem)	// Calcula a Base do CSLL do item
		MaFisVlCSL(nItem)	// Calcula o Valor do CSLL do item.
		MaFisBsSEST(nItem)	// Calcula a Base do SEST do item
		MaALIQSEST(nItem)	// Calcula a Aliquota do SEST do item
		MaFisVlSEST(nItem)	// Calcula o Valor do SEST do item.
		MaFisBSCF3(nItem)	// Calcula a base de calculo da COFINS Subst. Tributaria do item
		MaFisVLCF3(nItem)	// Calcula o valor da COFINS Subst. Tributaria do item
		MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
		MaFisBSPS3(nItem)	// Calcula a base de calculo do PIS Subst. Tributaria do item
		MaFisVLPS3(nItem)	// Calcula o valor do PIS Subst. Tributaria do item
		MaFisVTot(nItem)	// Calcula o valor total do item para agregar o valor do PIS/COFINS ST
	Endif
	MaItArred(nItem)	// Ajusta os arredondamentos do item
	MaFisLF(nItem)		// Atualiza os valores do Livro Fiscal
	MaFisLF2(nItem)		// Verifica se a TES possui RdMake para complemento/geracao dos Livros
	MaFisLF3(nItem)
	MaFisBsAFRMM(nItem)	// Calcula a Base do AFRMM do item
	MaAliqAFRMM(nItem)	// Calcula a Aliquota do AFRMM do item
	MaFisVlAFRMM(nItem)	// Calcula o Valor do AFRMM do item
	If MaCalcFet()			// Calcula o Imposto FETHAB
		MaFisBSFet(nItem)	// Calcula a base do imposto Fethab
		MaFisAlqFet(nItem)	// Calcula a aliquota do imposto Fethab
		MaFisValFet(nItem)	// Calcula a valor do imposto Fethab
	Endif
EndCase
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MaFisLF  ³ Autor ³  Edson Maricate       ³ Data ³20.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza os livros fiscais para o item.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisLF(nItem)

Local lConsumo		:= MaFisConsumo(nItem)
Local lConsFinal	:= MaFisConsFin()
Local nRetVCtb		:= IIF(!aTes[TS_INCSOL]$"A,N,D",aNfItem[nItem][IT_VALSOL],0)
Local nDescIpi		:= IIf(aTes[TS_TPIPI]=="B" .OR. (MV_IPIBRUTO=="S" .AND. aTes[TS_TPIPI] ==" "),aNfItem[nItem][IT_DESCONTO]+IIf(aNfCab[NF_OPERNF] == "S",aNfItem[nItem][IT_DESCZF],-1*aNfItem[nItem][IT_DESCZF]),0)
Local cIPINaOBS     := SuperGetMV("MV_IPINOBS")  	//Primeiro S - IPI nao tributado
//Segundo  S - IPI na Base do ICMS
Local lLFAgreg      := SuperGetMV("MV_LFAGREG",.F.) .AND. aTes[TS_AGREG]=="N" .AND. aTes[TS_TRFICM]=="2" //Indica se deve ser feita escrituracao, mesmo nao agregando valor ao total da nota.
Local nBICMOri      := aNfItem[nItem][IT_TOTAL]+IIf(aTes[TS_AGREG]=="N" .AND. aTes[TS_TRFICM]=="2",aNfItem[nItem][IT_VALMERC],0)-IIf(aTes[TS_IPILICM] <> "1".AND.aTes[TS_IPI]<>"R",aNfItem[nItem][IT_VALIPI],0)-IIF(aTes[TS_AGRRETC]=="1",0,nRetVCtb)
Local nBIPIOri      := aNfItem[nItem][IT_TOTAL]+IIf(aTes[TS_AGREG]=="N" .AND. aTes[TS_TRFICM]=="2",aNfItem[nItem][IT_VALMERC],0)-;
		IIf(aTes[TS_IPI]<>"R",aNfItem[nItem][IT_VALIPI],0) - nRetVCtb + nDescIPI - Iif(aTes[TS_AGREG]$"I|B" .AND. aTes[TS_INCIDE] == "S",aNfItem[nItem][IT_VALICM],0)-If(aTes[TS_AGRPIS]=="1" .AND. aTes[TS_PSCFST]<>"1",aNfItem[nItem,IT_VALPS2],0)-If(aTes[TS_AGRCOF]=="1" .AND. aTes[TS_PSCFST]<>"1",aNfItem[nItem,IT_VALCF2],0)-;
		IIf(aTES[TS_DESPIPI]=="N",aNfItem[nItem][IT_DESPESA],0)-;
		IIf(aTES[TS_PSCFST]=="1",aNfItem[nItem][IT_VALPS3] + aNfItem[nItem][IT_VALCF3],0)

Local nReduzICMS := aTes[TS_BASEICM]
Local nReduzIPI  := aTes[TS_BASEIPI]
Local cMvEstado  := SuperGetMV("MV_ESTADO")

If !Empty(aNFitem[nItem][IT_EXCECAO] )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega a reducao da base do ICMS                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aNfItem[nItem,IT_EXCECAO,14] > 0
		nReduzICMS := aNfItem[nItem,IT_EXCECAO,14]
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega a reducao da base do IPI                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aNfItem[nItem,IT_EXCECAO,15] > 0
		nReduzIPI := aNfItem[nItem,IT_EXCECAO,15]
	EndIf

EndIf

aNfItem[nItem][IT_LIVRO]	:= aClone(MaFisRetLF())

If aTes[TS_LFICM] <> "N" .OR. aTes[TS_LFIPI] <> "N" .OR. aTes[TS_LFISS] $"TIO"
	If cPaisLoc == "BRA"
		aNfItem[nItem][IT_LIVRO][LF_RECISS]   	:= aNfCab[NF_RECISS]
		aNfItem[nItem][IT_LIVRO][LF_ISSST]   	:= aTes[TS_ISSST]
		aNfItem[nItem][IT_LIVRO][LF_CFO] 		:= aNfItem[nItem][IT_CF]
		aNfItem[nItem][IT_LIVRO][LF_CFOEXT]    := aTes[TS_CFEXT]
		aNfItem[nItem][IT_LIVRO][LF_NFLIVRO]	:= aTes[TS_NRLIVRO]
		aNfItem[nItem][IT_LIVRO][LF_FORMULA]	:= aTes[TS_FORMULA]
		//
		aNfItem[nItem][IT_LIVRO][LF_CLASFIS]	:=	MaSBCampo("ORIGEM")+aTes[TS_SITTRIB]
		aNfItem[nItem][IT_LIVRO][LF_POSIPI]		:= 	MaSBCampo("POSIPI")
		aNfItem[nItem][IT_LIVRO][LF_CTIPI]		:= 	aTes[TS_CTIPI]
		aNfItem[nItem][IT_LIVRO][LF_ESTOQUE]	:=	aTes[TS_ESTOQUE]
		aNfItem[nItem][IT_LIVRO][LF_DESPIPI]	:=	aTes[TS_DESPIPI]
		aNfItem[nItem][IT_LIVRO][LF_CFPS]	    :=	aNfItem[nItem][IT_CFPS]
		aNfItem[nItem][IT_RGESPST]				:=	aTes[TS_RGESPST]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pegando o item da NF Original³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aNFCab[NF_TIPONF] $ "DB"
			If !Empty(aNFItem[nItem][IT_RECORI])
				If ( aNFCab[NF_CLIFOR] == "C" )
					dbSelectArea("SD2")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					aNfItem[nItem][IT_LIVRO][LF_ITEMORI] 	:= SD2->D2_ITEM
				Else
					dbSelectArea("SD1")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					aNfItem[nItem][IT_LIVRO][LF_ITEMORI] 	:= SD1->D1_ITEM
				EndIf
			EndIf
		Else
			If !Empty(aNFItem[nItem][IT_RECORI])
				If ( aNFCab[NF_CLIFOR] == "C" )
					dbSelectArea("SD1")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					aNfItem[nItem][IT_LIVRO][LF_ITEMORI] 	:= SD1->D1_ITEM
				Else
					dbSelectArea("SD2")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					aNfItem[nItem][IT_LIVRO][LF_ITEMORI] 	:= SD2->D2_ITEM
				EndIf
			EndIf
		EndIf
		//
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Abatimento na base de calculo do ISS referente a subempreitada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNfItem[nItem][IT_LIVRO][LF_ISSSUB]	:= aNfItem[nItem][IT_ABVLISS]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Abatimento na base de calculo do ISS referente ao material aplicado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNfItem[nItem][IT_LIVRO][LF_ISSMAT]	:= aNfItem[nItem][IT_ABMATISS]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o Valor dos Descontos na Observacao.                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNfItem[nItem][IT_LIVRO][LF_VALOBSE]	:= aNfItem[nItem][IT_DESCONTO]+IIf(aNfCab[NF_OPERNF] == "S",aNfItem[nItem][IT_DESCZF],0)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o Valor dos Descontos - Zona Franca de Manaus        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNfItem[nItem][IT_LIVRO][LF_DESCZFR] := aNfItem[nItem][IT_DESCZF]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ ICMS Diferido                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aTes[TS_ICMSDIF] $ "1"
			aNfItem[nItem][IT_LIVRO][LF_ICMSDIF]	:= aNfItem[nItem][IT_ICMSDIF]
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Credito Estimulo Manaus                                   ³
		//| 1 = Nao Calcula                                           |
		//| 2 = Produtos Eletronicos                                  |
		//| 3 = Contrucao Civil
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aTes[TS_CRDEST]$"23"
			If (cAliasPROD)->(FieldPos(Right(cAliasPROD,2)+"_CRDEST")) > 0 .AND. SF3->(FieldPos("F3_CRDEST")) > 0
				aNfItem[nItem][IT_LIVRO][LF_CRDEST]	:= NoRound(aNfItem[nItem][IT_VALICM]*MaSBCampo("CRDEST")/100,2)
			Endif
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava o valor do credito presumido referente a Zona Franca de Manaus                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNfItem[nItem][IT_LIVRO][LF_CRDZFM] := aNfItem[nItem][IT_CRDZFM]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o Valor de PIS/COFINS Subst. Tributaria              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNfItem[nItem][IT_LIVRO][LF_BASEPS3] 	:= aNfItem[nItem][IT_BASEPS3]
		aNfItem[nItem][IT_LIVRO][LF_ALIQPS3] 	:= aNfItem[nItem][IT_ALIQPS3]
		aNfItem[nItem][IT_LIVRO][LF_VALPS3]		:= aNfItem[nItem][IT_VALPS3]
		aNfItem[nItem][IT_LIVRO][LF_BASECF3]	:= aNfItem[nItem][IT_BASECF3]
		aNfItem[nItem][IT_LIVRO][LF_ALIQCF3] 	:= aNfItem[nItem][IT_ALIQCF3]
		aNfItem[nItem][IT_LIVRO][LF_VALCF3] 	:= aNfItem[nItem][IT_VALCF3]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava o valor do Fundersul - Mato Grosso do Sul³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNfItem[nItem][IT_LIVRO][LF_VALFDS] 	:= aNfItem[nItem][IT_VALFDS]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o Valor Contabil.                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aNFitem[nItem][IT_TIPONF] <> "I" .OR. aNfItem[nItem][IT_VALSOL] <> 0
			aNfItem[nItem][IT_LIVRO][LF_VALCONT]	:= aNfItem[nItem][IT_TOTAL]+IIf(lLfAgreg,aNfItem[nItem][IT_VALMERC],0)-aNfItem[nItem][IT_LIVRO][LF_ICMSDIF]-If(aTes[TS_LFIPI]=="N".AND.aTes[TS_AGREG]=="N",aNfItem[nItem][IT_VALIPI],0)
			If aTes[TS_LFICM]=="B"
			   aNfItem[nItem][IT_LIVRO][LF_VALOBSE]	:= 	aNfItem[nItem][IT_LIVRO][LF_VALCONT]
			   aNfItem[nItem][IT_LIVRO][LF_VALCONT]	:=0
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³                         CREDITO PRESUMIDO                        ³
			//³------------------------------------------------------------------³
			//³ Estados que utilizam a mesma implementacao do Credito Presumido: ³
			//³ - RJ - Rio de Janeiro                                            ³
			//³ - PR - Parana                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cMvEstado == "RJ" .And. aTes[TS_CRDPRES] > 0
				aNfItem[nItem][IT_LIVRO][LF_CRDPRES]	:= NoRound((aNfItem[nItem][IT_LIVRO][LF_VALCONT] * aTes[TS_CRDPRES]) / 100,2)
			Endif
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Credito Presumido - PR                                   ³
		//³----------------------------------------------------------³
		//³ Conforme a Lei 14.985, de 06.01.2006, e regulamentada    ³
		//³ pelo Decreto 6.144, de 22.02.2006 - DOE PR de 22.02.2006 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cMvEstado == "PR" .And. aTes[TS_CRDPRES] > 0
			If aTes[TS_AGREG]$"BC"
				aNfItem[nItem][IT_LIVRO][LF_CRDPRES]	:= NoRound((IIF(aNfItem[nItem][IT_BASEICM]==0,aNfItem[nItem][IT_LIVRO][LF_VALCONT]/(1-(aNfItem[nItem][IT_ALIQICM]/100)),aNfItem[nItem][IT_BASEICM])*(aTes[TS_CRDPRES]/100)),2)
			Else
				aNfItem[nItem][IT_LIVRO][LF_CRDPRES]	:= NoRound((IIF(aNfItem[nItem][IT_BASEICM]==0,nBICMOri,aNfItem[nItem][IT_BASEICM])*(aTes[TS_CRDPRES]/100)),2)
			EndIf
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o valor do ICMS do Frete Autonomo no Livro Fiscal    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNfItem[nItem][IT_LIVRO][LF_ICMAUTO] := IIF(aNfCab[NF_RECFAUT]<>"2",aNfItem[nItem][IT_VALICA],0)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tipo de Nota Fiscal.                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aNfCab[NF_TIPONF] $ "DB"
			aNfItem[nItem][IT_LIVRO][LF_TIPO]	:= aNfCab[NF_TIPONF]
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Livro de ICMS                                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF !(aTes[TS_LFICM]$'NZ') .AND. aTes[TS_ISS]<>"S"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Base do ICMS                                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aNfItem[nItem][IT_TIPONF] <> "I"
				If nReduzICMS > 0
					If !lConsumo
						aNfItem[nItem][IT_LIVRO][LF_BASEICM] := aNfItem[nItem][IT_BASEICM]
					Else
						If aTes[TS_LFICM] == "I"
							aNfItem[nItem][IT_LIVRO][LF_ISENICM] := aNfItem[nItem][IT_BASEICM] - aNfItem[nItem][IT_VIPIBICM]
							aNfItem[nItem][IT_LIVRO][LF_OUTRICM] := nBICMOri-aNfItem[nItem][IT_BASEICM]+aNfItem[nItem][IT_VIPIBICM]
						Else
							aNfItem[nItem][IT_LIVRO][LF_ISENICM] := Max( nBICMOri-aNfItem[nItem][IT_BASEICM]+aNfItem[nItem][IT_VIPIBICM], 0 )
							aNfItem[nItem][IT_LIVRO][LF_OUTRICM] := aNfItem[nItem][IT_BASEICM]-aNfItem[nItem][IT_VIPIBICM]
						EndIf
					EndIf
				Else
					If aTes[TS_LFICM] == "T"
						aNfItem[nItem][IT_LIVRO][LF_BASEICM] := aNfItem[nItem][IT_BASEICM]
					EndIf
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valor do ICMS Tributado                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aTes[TS_LFICM] =="T" .OR. (nReduzICMS<>0.AND.!lConsumo)
				aNfItem[nItem][IT_LIVRO][LF_VALICM] := aNfItem[nItem][IT_VALICM]
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|Tratamento para os casos do Art. 1. DECRETO 4.316 de 19 de Junho de 1995, onde determina:  ³
			//|                                                                                           |
			//³Que deverah haver um percentual(conf. art. 7.) de crédito Presumido nas operações de Saída |
			//| com o ICMS destacado sobre os produtos resultantes da industrialização com componentes,   |
			//| partes e pecas recebidos do exterior, destinados a fabricacao de produtos de informatica, |
			//| eletronicos e telecomunicacoes, por estabelecimento industrial desses setores.            ³
			//|                                                                                           |
			//|O percentual informado no cadastro de TES deverah estar de acordo com o Art. 7. deste      |
			//|   decreto.                                                                                |
			//|Art. 7. Nas operações de saídas internas de produtos acabados, recebidos do exterior com o |
			//| diferimento regulado nos incisos II e III do "caput" do art. 1º, o estabelecimento que os |
			//| importar lançará a crédito o valor correspondente ao indicado nos incisos abaixo, de forma|
			//| que a carga tributária incidente corresponda a um percentual efetivo de 3,5% (tres inteiros|
			//| e cinco décimos por cento), observada a disposição do § 1. do art. 1.:                    |
			//| I  - 50% (cinqüenta por cento) do imposto destacado, sem prejuízo do disposto no inciso V |
			//|   do art. 87 do RICMS/BA, quando relativas a produtos de informática;                     |
		    //| II - 79,41118% (setenta e nove inteiros e quatro mil cento e dezoito décimos de milésimos |
		    //|   por cento), quando relativas a produtos de telecomunicações, elétricos, eletrônicos e   |
		    //|   eletro-eletrônicos, efetuadas por estabelecimento industrial.		                      |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (aTes[TS_CRPRELE]<>0)
				aNfItem[nItem][IT_LIVRO][LF_CRPRELE] := Round( aNfItem[nItem][IT_VALICM]*(aTes[TS_CRPRELE]/100), 2)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava o Valor do Credito Presumido - RJ - Prestacoes de Servicos de Transporte  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aTes[TS_CRDTRAN]<>0
				aNfItem[nItem][IT_LIVRO][LF_CRDTRAN] := (aNfItem[nItem][IT_LIVRO][LF_VALICM] * aTes[TS_CRDTRAN]) / 100
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valor da Coluna Isentas e Nao Tributadas                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aTes[TS_LFICM] =="I"
				If nReduzICMS > 0
					If !lConsumo
						aNfItem[nItem][IT_LIVRO][LF_ISENICM] := nBICMOri-aNfItem[nItem][IT_BASEICM]+aNfItem[nItem][IT_VIPIBICM]
					EndIf
				Else
					aNfItem[nItem][IT_LIVRO][LF_ISENICM] := nBICMOri
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valor da Coluna Outras                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aTes[TS_LFICM]=="O"
				If nReduzICMS > 0
					If !lConsumo
						aNfItem[nItem][IT_LIVRO][LF_OUTRICM] := nBICMOri-aNfItem[nItem][IT_BASEICM]+aNfItem[nItem][IT_VIPIBICM]
					EndIf
				Else
					aNfItem[nItem][IT_LIVRO][LF_OUTRICM] := nBICMOri
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ ICMS Complementar                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNfItem[nItem][IT_LIVRO][LF_ICMSCOMP]	:= aNfItem[nItem][IT_VALCMP]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Transferencia de Debito e Credito                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aTes[TS_TRFICM]=="1"
			aNfItem[nItem][IT_LIVRO][LF_TRFICM]		:= aNfItem[nItem][IT_VALMERC]
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ ICMS Solidario.                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNfItem[nItem][IT_LIVRO][LF_ICMSRET]	:= aNfItem[nItem][IT_VALSOL]
		aNfItem[nItem][IT_LIVRO][LF_BASERET]	:= aNfItem[nItem][IT_BASESOL]
		If aTes[TS_OBSICM] == "1"
			aNfItem[nItem][IT_LIVRO][LF_OBSICM] := aNfItem[nItem][IT_VALICM]
		Endif
		If aTes[TS_OBSSOL] == "1"
			aNfItem[nItem][IT_LIVRO][LF_OBSSOL] := aNfItem[nItem][IT_VALSOL]
		EndIf

		If aTes[TS_CREDST] $ "1#3#4"
			If aTes[TS_CREDST] <> "4"
				aNfItem[nItem][IT_LIVRO][LF_SOLTRIB] := aNfItem[nItem][IT_VALSOL]
			Endif
			aNfItem[nItem][IT_LIVRO][LF_CREDST ] := aTes[TS_CREDST]
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|Grava valor Credito Presumido Substituicao Tributaria retido pelo contratante do servico de transporte - Decreto 44.147/2005 (MG)|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aTes[TS_CRPRST]<>0
			aNfItem[nItem][IT_LIVRO][LF_CRPRST]		:=	NoRound(aNfItem[nItem][IT_VLCSOL] - aNfItem[nItem][IT_VALSOL],2)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ ICMS Aliquota                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aNfItem[nItem][IT_LIVRO][LF_BASEICM]==0
			aNfItem[nItem][IT_LIVRO][LF_ALIQICMS] := 0
		Else
			aNfItem[nItem][IT_LIVRO][LF_ALIQICMS] := aNfItem[nItem][IT_ALIQICM]
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando o IPI estiver na base do ICMS preencher o valor do IPI na Observ.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aNfItem[nItem][IT_VIPIBICM]>0 .AND. SubStr(cIPInaObs,2,1)=="S" .AND. aTes[TS_IPIOBS] $ " 1"
			aNfItem[nItem][IT_LIVRO][LF_IPIOBS]   := aNfItem[nItem][IT_VIPIBICM]
		Else
			aNfItem[nItem][IT_LIVRO][LF_IPIOBS]   := 0
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Livro de ICMS-ST                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF (aTes[TS_LFICMST]$'IOT')
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valor da Coluna Isentas e Nao Tributadas                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aTes[TS_LFICMST] =="I"
				aNfItem[nItem][IT_LIVRO][LF_ISENICM] += aNfItem[nItem][IT_VALSOL]
				aNfItem[nItem][IT_LIVRO][LF_ISENRET] += aNfItem[nItem][IT_VALSOL]
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valor da Coluna Outras                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aTes[TS_LFICMST]=="O"
				aNfItem[nItem][IT_LIVRO][LF_OUTRICM] += aNfItem[nItem][IT_VALSOL]
				aNfItem[nItem][IT_LIVRO][LF_OUTRRET] += aNfItem[nItem][IT_VALSOL]
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valor da Coluna Tributadas                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aTes[TS_LFICMST]=="T"
				aNfItem[nItem][IT_LIVRO][LF_BASEICM] += aNfItem[nItem][IT_BASESOL]
				//O credito deverah ser o valor integral, ou seja, o ICMS/ST + CRED PRES ST, pois quando houver valor neste campo vai se referir a 20% do valor retido que foi subtraido
				aNfItem[nItem][IT_LIVRO][LF_VALICM]  += aNfItem[nItem][IT_VALSOL]+aNfItem[nItem][IT_LIVRO][LF_CRPRST]
				aNfItem[nItem][IT_LIVRO][LF_ALIQICMS]:= aNfItem[nItem][IT_ALIQSOL]
				//O credito deverah ser o valor integral, ou seja, o ICMS/ST + CRED PRES ST, pois quando houver valor neste campo vai se referir a 20% do valor retido que foi subtraido
				aNfItem[nItem][IT_LIVRO][LF_TRIBRET] += aNfItem[nItem][IT_VALSOL]+aNfItem[nItem][IT_LIVRO][LF_CRPRST]
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Livro de IPI                                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !aTes[TS_LFIPI]$"NZ" .AND. aTes[TS_ISS]<>"S" .AND. aNfItem[nItem][IT_TIPONF] <> "I"
			If nReduzIPI == 0
				Do Case
				Case aTes[TS_LFIPI] == "T"
					aNfItem[nItem][IT_LIVRO][LF_BASEIPI] := aNfItem[nItem][IT_BASEIPI]
					aNfItem[nItem][IT_LIVRO][LF_VALIPI]  := aNfItem[nItem][IT_VALIPI]
				Case aTes[TS_LFIPI] == "I"
					aNfItem[nItem][IT_LIVRO][LF_ISENIPI] := nBIPIOri
				Case aTes[TS_LFIPI] == "O"
					aNfItem[nItem][IT_LIVRO][LF_OUTRIPI] := nBIPIOri
				EndCase
			Else
				If lConsumo
					If aTes[TS_LFIPI]=="I"
						aNfItem[nItem][IT_LIVRO][LF_ISENIPI] := aNfItem[nItem][IT_BASEIPI]
						aNfItem[nItem][IT_LIVRO][LF_OUTRIPI] := nBIPIOri-aNfItem[nItem][IT_BASEIPI]
					Else
						aNfItem[nItem][IT_LIVRO][LF_ISENIPI] := nBIPIOri-aNfItem[nItem][IT_BASEIPI]
						aNfItem[nItem][IT_LIVRO][LF_OUTRIPI] := aNfItem[nItem][IT_BASEIPI]
					EndIf
				Else
					aNfItem[nItem][IT_LIVRO][LF_BASEIPI] := aNfItem[nItem][IT_BASEIPI]
					aNfItem[nItem][IT_LIVRO][LF_VALIPI]  := aNfItem[nItem][IT_VALIPI]
					aNfItem[nItem][IT_LIVRO][IIf(aTes[TS_LFIPI]=="I",LF_ISENIPI,LF_OUTRIPI)] := nBIPIOri-aNfItem[nItem][IT_BASEIPI]
				EndIf
			EndIf
		ElseIf aTes[TS_LFIPI] == "N" .AND. aTes[TS_ISS] <> "S" .AND. SubStr(cIPInaObs,1,1)=="S" .AND. aTes[TS_IPI] <> 'R' .AND. aTes[TS_IPIOBS] $ " 1"
			aNfItem[nItem][IT_LIVRO][LF_IPIOBS]	:= aNfItem[nItem][IT_VALIPI]
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ IPI Aliquota                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aNfItem[nItem][IT_LIVRO][LF_BASEIPI]==0
			aNfItem[nItem][IT_LIVRO][LF_ALIQIPI] := 0
		Else
			aNfItem[nItem][IT_LIVRO][LF_ALIQIPI] := aNfItem[nItem][IT_ALIQIPI]
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando o IPI possuir uma parte nao tributada, preencher o IPI na Observ.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lConsFinal
			If nBIPIOri<>aNfItem[nItem][IT_LIVRO][LF_BASEIPI] .AND. aNfItem[nItem][IT_LIVRO][LF_VALIPI]<>0
				If SubStr(cIPInaObs,1,1)=="S" .AND. aTes[TS_IPI] <> 'R' .AND. aTes[TS_IPIOBS] $ " 1"
					aNfItem[nItem][IT_LIVRO][LF_IPIOBS]   += NoRound((nBIPIOri-aNfItem[nItem][IT_LIVRO][LF_BASEIPI])*aNfItem[nItem][IT_LIVRO][LF_VALIPI]/aNfItem[nItem][IT_LIVRO][LF_BASEIPI],2)
				Endif
			Else
				If aTes[TS_LFIPI]$"IO" .AND. aNfItem[nItem][IT_LIVRO][LF_VALIPI]==0
					If SubStr(cIPInaObs,1,1)=="S" .AND. aTes[TS_IPI] <> 'R' .AND. aTes[TS_IPIOBS] $ " 1"
						aNfItem[nItem][IT_LIVRO][LF_IPIOBS]   := aNfItem[nItem][IT_VALIPI]
					Endif
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Livro de ISS                                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aTes[TS_ISS] == "S"
			Do Case
			Case aTes[TS_LFISS] == "T"
				aNfItem[nItem][IT_LIVRO][LF_BASEICM] := IIF(aNfCab[NF_TIPONF]=="I",0,aNfItem[nItem][IT_BASEISS])
				aNfItem[nItem][IT_LIVRO][LF_VALICM]  := IIF(aNfCab[NF_TIPONF]=="I",aNfItem[nItem][IT_BASEISS],aNfItem[nItem][IT_VALISS])
			Case aTes[TS_LFISS] == "I"
				aNfItem[nItem][IT_LIVRO][LF_ISENICM] := aNfItem[nItem][IT_BASEISS]
			Case aTes[TS_LFISS] == "O"
				aNfItem[nItem][IT_LIVRO][LF_OUTRICM] := aNfItem[nItem][IT_BASEISS]
			EndCase
			aNfItem[nItem][IT_LIVRO][LF_TIPO] := "S"
			aNfItem[nItem][IT_LIVRO][LF_CODISS] := aNfItem[nItem][IT_CODISS]
			aNfItem[nItem][IT_LIVRO][LF_CNAE]   := aNfItem[nItem][IT_CNAE]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ ISS Aliquota                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aNfItem[nItem][IT_LIVRO][LF_BASEICM]==0
				aNfItem[nItem][IT_LIVRO][LF_ALIQICMS] := 0
			Else
				aNfItem[nItem][IT_LIVRO][LF_ALIQICMS] := aNfItem[nItem][IT_ALIQISS]
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Livro de ICMS - Ajuste SINEF 03/04 - DOU 08.04.04         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aNfItem[nItem][IT_LIVRO][LF_ISS_ALIQICMS] := 0
			Do Case
				Case aTes[TS_LFICM] == "I"
					aNfItem[nItem][IT_LIVRO][LF_ISS_ISENICM] := aNfItem[nItem][IT_LIVRO][LF_VALCONT]
				Case aTes[TS_LFICM] == "O"
					aNfItem[nItem][IT_LIVRO][LF_ISS_OUTRICM] := aNfItem[nItem][IT_LIVRO][LF_VALCONT]
			EndCase
			Do Case
				Case aTes[TS_LFIPI] == "I"
					aNfItem[nItem][IT_LIVRO][LF_ISS_ISENIPI] := aNfItem[nItem][IT_LIVRO][LF_VALCONT]
				Case aTes[TS_LFIPI] == "O"
					aNfItem[nItem][IT_LIVRO][LF_ISS_OUTRIPI] := aNfItem[nItem][IT_LIVRO][LF_VALCONT]
			EndCase
		EndIf
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava os Valores de Despesas                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aNfItem[nItem][IT_LIVRO][LF_DESPESA] := aNfItem[nItem][IT_DESPESA]+aNfItem[nItem][IT_FRETE]+aNfItem[nItem][IT_SEGURO]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³SIMPLES SC                                                                              ³
	//³Sera gravado o valor do ICMS calculado na nota fiscal.                                  ³
	//³Contribuintes do SIMPLES/SC devem destacar o ICMS nos documentos fiscais com            ³
	//³destino a optantes do SIMPLES, mas o valor do ICMS nao deve ser apresentado na apuracao.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SubStr(aNfItem[nItem][IT_LIVRO][LF_CFO],1,1) $ "56" .AND. aNfItem[nItem][IT_LIVRO][LF_TIPO] <> "S"
		If SA1->(FieldPos("A1_SIMPLES")) > 0 .AND. SF3->(FieldPos("F3_SIMPLES")) > 0
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+aNfCab[NF_CODCLIFOR]+aNfCab[NF_LOJA]))
			If SA1->A1_SIMPLES <> "1" .AND. cMvEstado=="SC" .AND. GetNewPar("MV_SIMPLSC",.T.)
				aNfItem[nItem][IT_LIVRO][LF_SIMPLES] := aNfItem[nItem][IT_LIVRO][LF_VALICM]
			Endif
		Endif
	Endif
EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MaFisLF3 ³ Autor ³Eduardo Riera          ³ Data ³23.03.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza os livros fiscais para o item.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisLF3(nItem)

Local aImp := {"","","","","","",0,0,0,0,0,0,0,""}
Local nImp := 0

aNfItem[nItem][IT_SPED]	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o ICMS                                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aNfItem[nItem][IT_VALICM] > 0
	aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
	nImp++
	aNfItem[nItem][IT_SPED][nImp][SP_ITEM]   := aNfItem[nItem][IT_ITEM]
	aNfItem[nItem][IT_SPED][nImp][SP_CODPRO] := aNfItem[nItem][IT_PRODUTO]
	aNfItem[nItem][IT_SPED][nImp][SP_IMP]    := "ICM"
	aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM] := MaSBCampo("ORIGEM")
	aNfItem[nItem][IT_SPED][nImp][SP_CST]    := aTes[TS_SITTRIB]
	aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] := aNfItem[nItem][IT_PREDIC]
	aNfItem[nItem][IT_SPED][nImp][SP_BC]     := aNfItem[nItem][IT_BASEICM]
	aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]   := aNfItem[nItem][IT_ALIQICM]
	aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] := aNfItem[nItem][IT_VALICM]
	If aNfItem[nItem][IT_PAUTIC] > 0

		aNfItem[nItem][IT_SPED][nImp][SP_QTRIB]  := aNfItem[nItem][IT_QUANT]*IIF(!Empty(SuperGetMV("MV_ICMPFAT")),MaSBCampo(SubStr(SuperGetMV("MV_ICMPFAT"),4)),1)
		aNfItem[nItem][IT_SPED][nImp][SP_PAUTA]  := aNfItem[nItem][IT_PAUTIC]
		If aNfItem[nItem][IT_SPED][nImp][SP_PAUTA] >= aNfItem[nItem][IT_PRCUNI]
			aNfItem[nItem][IT_SPED][nImp][SP_MODBC]  := "2"
		Else
			aNfItem[nItem][IT_SPED][nImp][SP_MODBC]  := "1"
		EndIf
	Else
		aNfItem[nItem][IT_SPED][nImp][SP_MODBC]  := 	"3"
	EndIf
	aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := ""
EndIf

If aNfItem[nItem][IT_VALSOL] > 0
	aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
	nImp++
	aNfItem[nItem][IT_SPED][nImp][SP_ITEM]   := aNfItem[nItem][IT_ITEM]
	aNfItem[nItem][IT_SPED][nImp][SP_CODPRO] := aNfItem[nItem][IT_PRODUTO]
	aNfItem[nItem][IT_SPED][nImp][SP_IMP]    := "SOL"
	aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM] := MaSBCampo("ORIGEM")
	aNfItem[nItem][IT_SPED][nImp][SP_CST]    := aTes[TS_SITTRIB]
	aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] := aNfItem[nItem][IT_PREDST]
	aNfItem[nItem][IT_SPED][nImp][SP_BC]     := aNfItem[nItem][IT_BASESOL]
	aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]   := aNfItem[nItem][IT_ALIQSOL]
	aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] := aNfItem[nItem][IT_VALSOL]
	If aNfItem[nItem][IT_PAUTIC] > 0
		aNfItem[nItem][IT_SPED][nImp][SP_QTRIB]  := aNfItem[nItem][IT_QUANT]*IIF(!Empty(SuperGetMV("MV_ICMPFAT")),MaSBCampo(SubStr(SuperGetMV("MV_ICMPFAT"),4)),1)
		aNfItem[nItem][IT_SPED][nImp][SP_PAUTA]  := aNfItem[nItem][IT_PAUTST]
		If aNfItem[nItem][IT_SPED][nImp][SP_PAUTA] >= aNfItem[nItem][IT_PRCUNI]
			aNfItem[nItem][IT_SPED][nImp][SP_MODBC]  := "2"
		Else
			aNfItem[nItem][IT_SPED][nImp][SP_MODBC]  := "1"
		EndIf
	Else
		aNfItem[nItem][IT_SPED][nImp][SP_MVA]    := aNfItem[nItem][IT_MARGEM]
		aNfItem[nItem][IT_SPED][nImp][SP_MODBC]  := "0"
	EndIf
	aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := ""
EndIf

If aNfItem[nItem][IT_VALCMP] > 0
	aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
	nImp++
	aNfItem[nItem][IT_SPED][nImp][SP_ITEM]   := aNfItem[nItem][IT_ITEM]
	aNfItem[nItem][IT_SPED][nImp][SP_CODPRO] := aNfItem[nItem][IT_PRODUTO]
	aNfItem[nItem][IT_SPED][nImp][SP_IMP]    := "CMP"
	aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM] := MaSBCampo("ORIGEM")
	aNfItem[nItem][IT_SPED][nImp][SP_MVA]    := aNfItem[nItem][IT_MVACMP]
	aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] := aNfItem[nItem][IT_PREDCMP]
	aNfItem[nItem][IT_SPED][nImp][SP_BC]     := IIF(aNfItem[nItem][IT_PREDCMP]==0,aNfItem[nItem][IT_BASEICM],aNfItem[nItem][IT_BICMORI])
	aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]   := aNfItem[nItem][IT_ALIQCMP]
	aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] := aNfItem[nItem][IT_VALCMP]
	aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := ""
EndIf

If aNfItem[nItem][IT_VALIPI] > 0
	aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
	nImp++
	aNfItem[nItem][IT_SPED][nImp][SP_ITEM]   := aNfItem[nItem][IT_ITEM]
	aNfItem[nItem][IT_SPED][nImp][SP_CODPRO] := aNfItem[nItem][IT_PRODUTO]
	aNfItem[nItem][IT_SPED][nImp][SP_IMP]    := "IPI"
	aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM] := MaSBCampo("ORIGEM")
	aNfItem[nItem][IT_SPED][nImp][SP_CST]    := aTes[TS_CTIPI]
	aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] := aNfItem[nItem][IT_PREDIPI]
	aNfItem[nItem][IT_SPED][nImp][SP_BC]     := aNfItem[nItem][IT_BASEIPI]
	aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]   := aNfItem[nItem][IT_ALIQIPI]
	aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] := aNfItem[nItem][IT_VALIPI]
	aNfItem[nItem][IT_SPED][nImp][SP_QTRIB]  := aNfItem[nItem][IT_QUANT]*IIF(!Empty(SuperGetMV("MV_IPIPFAT")),MaSBCampo(SubStr(SuperGetMV("MV_IPIPFAT"),4)),1)
	aNfItem[nItem][IT_SPED][nImp][SP_PAUTA]  := aNfItem[nItem][IT_PAUTIPI]
	aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := ""
EndIf

If aTes[TS_ISS] == "S" .And. aNfItem[nItem][IT_VALISS] > 0
	aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
	nImp++
	aNfItem[nItem][IT_SPED][nImp][SP_ITEM]   := aNfItem[nItem][IT_ITEM]
	aNfItem[nItem][IT_SPED][nImp][SP_CODPRO] := aNfItem[nItem][IT_PRODUTO]
	aNfItem[nItem][IT_SPED][nImp][SP_IMP]    := "ISS"
	aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM] := MaSBCampo("ORIGEM")
	aNfItem[nItem][IT_SPED][nImp][SP_CST]    := ""
	aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] := aNfItem[nItem][IT_PREDISS]
	aNfItem[nItem][IT_SPED][nImp][SP_BC]     := aNfItem[nItem][IT_BASEISS]
	aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]   := aNfItem[nItem][IT_ALIQISS]
	aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] := aNfItem[nItem][IT_VALISS]
	aNfItem[nItem][IT_SPED][nImp][SP_QTRIB]  := 0
	aNfItem[nItem][IT_SPED][nImp][SP_PAUTA]  := 0
	aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := SM0->M0_CODMUN
EndIf
If aNfItem[nItem][IT_VALPS2] > 0
	aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
	nImp++
	aNfItem[nItem][IT_SPED][nImp][SP_ITEM]   := aNfItem[nItem][IT_ITEM]
	aNfItem[nItem][IT_SPED][nImp][SP_CODPRO] := aNfItem[nItem][IT_PRODUTO]
	aNfItem[nItem][IT_SPED][nImp][SP_IMP]    := "PS2"
	aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM] := MaSBCampo("ORIGEM")
	aNfItem[nItem][IT_SPED][nImp][SP_CST]    := aTES[TS_CSTPIS]
	aNfItem[nItem][IT_SPED][nImp][SP_MODBC]  := ""
	aNfItem[nItem][IT_SPED][nImp][SP_MVA]    := 0
	aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] := 0
	aNfItem[nItem][IT_SPED][nImp][SP_BC]     := aNfItem[nItem][IT_BASEPS2]
	aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]   := aNfItem[nItem][IT_ALIQPS2]
	aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] := aNfItem[nItem][IT_VALPS2]
	aNfItem[nItem][IT_SPED][nImp][SP_QTRIB]  := aNfItem[nItem,IT_QUANT]
	aNfItem[nItem][IT_SPED][nImp][SP_PAUTA]  := IIF((Empty(aNFitem[nItem,IT_EXCECAO]).OR.Empty(aNFItem[nItem,IT_EXCECAO,10]).OR.aNfItem[nItem,IT_QUANT]==0.OR.GetNewPar("MV_PISPAUT",.T.)),MaSBCampo( "VLR_PIS" ),aNFItem[nItem,IT_EXCECAO,10])
	aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := ""
EndIf

If aNfItem[nItem][IT_VALCF2] > 0
	aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
	nImp++
	aNfItem[nItem][IT_SPED][nImp][SP_ITEM]   := aNfItem[nItem][IT_ITEM]
	aNfItem[nItem][IT_SPED][nImp][SP_CODPRO] := aNfItem[nItem][IT_PRODUTO]
	aNfItem[nItem][IT_SPED][nImp][SP_IMP]    := "CF2"
	aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM] := MaSBCampo("ORIGEM")
	aNfItem[nItem][IT_SPED][nImp][SP_CST]    := aTES[TS_CSTCOF]
	aNfItem[nItem][IT_SPED][nImp][SP_MODBC]  := ""
	aNfItem[nItem][IT_SPED][nImp][SP_MVA]    := 0
	aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] := 0
	aNfItem[nItem][IT_SPED][nImp][SP_BC]     := aNfItem[nItem][IT_BASECF2]
	aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]   := aNfItem[nItem][IT_ALIQCF2]
	aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] := aNfItem[nItem][IT_VALCF2]
	aNfItem[nItem][IT_SPED][nImp][SP_QTRIB]  := aNfItem[nItem,IT_QUANT]
	aNfItem[nItem][IT_SPED][nImp][SP_PAUTA]  := IIF((Empty(aNFitem[nItem,IT_EXCECAO]).OR.Empty(aNFItem[nItem,IT_EXCECAO,11]).OR.aNfItem[nItem,IT_QUANT]==0.OR.GetNewPar("MV_COFPAUT",.T.)),MaSBCampo( "VLR_COF" ),aNFItem[nItem,IT_EXCECAO,11])
	aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := ""
EndIf

If aNfItem[nItem][IT_VALPS3] > 0
	aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
	nImp++
	aNfItem[nItem][IT_SPED][nImp][SP_ITEM]   := aNfItem[nItem][IT_ITEM]
	aNfItem[nItem][IT_SPED][nImp][SP_CODPRO] := aNfItem[nItem][IT_PRODUTO]
	aNfItem[nItem][IT_SPED][nImp][SP_IMP]    := "PS3"
	aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM] := MaSBCampo("ORIGEM")
	aNfItem[nItem][IT_SPED][nImp][SP_CST]    := aTES[TS_CSTPIS]
	aNfItem[nItem][IT_SPED][nImp][SP_MODBC]  := ""
	aNfItem[nItem][IT_SPED][nImp][SP_MVA]    := 0
	aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] := 0
	aNfItem[nItem][IT_SPED][nImp][SP_BC]     := aNfItem[nItem][IT_BASEPS3]
	aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]   := aNfItem[nItem][IT_ALIQPS3]
	aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] := aNfItem[nItem][IT_VALPS3]
	aNfItem[nItem][IT_SPED][nImp][SP_QTRIB]  := 0
	aNfItem[nItem][IT_SPED][nImp][SP_PAUTA]  := 0
	aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := ""
EndIf

If aNfItem[nItem][IT_VALCF3] > 0
	aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
	nImp++
	aNfItem[nItem][IT_SPED][nImp][SP_ITEM]   := aNfItem[nItem][IT_ITEM]
	aNfItem[nItem][IT_SPED][nImp][SP_CODPRO] := aNfItem[nItem][IT_PRODUTO]
	aNfItem[nItem][IT_SPED][nImp][SP_IMP]    := "CF3"
	aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM] := MaSBCampo("ORIGEM")
	aNfItem[nItem][IT_SPED][nImp][SP_CST]    := aTES[TS_CSTCOF]
	aNfItem[nItem][IT_SPED][nImp][SP_MODBC]  := ""
	aNfItem[nItem][IT_SPED][nImp][SP_MVA]    := 0
	aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] := 0
	aNfItem[nItem][IT_SPED][nImp][SP_BC]     := aNfItem[nItem][IT_BASECF3]
	aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]   := aNfItem[nItem][IT_ALIQCF3]
	aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] := aNfItem[nItem][IT_VALCF3]
	aNfItem[nItem][IT_SPED][nImp][SP_QTRIB]  := 0
	aNfItem[nItem][IT_SPED][nImp][SP_PAUTA]  := 0
	aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := ""
EndIf

Return .T.



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisRetLF³ Autor ³ Edson Maricate        ³ Data ³03.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna um array com a estrutura inicial do aLivro.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisRetLF()
//        1  2  3  4   5  6  7  8  9 10 11  12 13 14  15  16 17   18 19  20 21 22  23  24  25 26 27 28 29 30 31  32  33  34 35          36 37 38 39 40 41  42 43   44  45  46  47   48 49 50  51 52   53 54  55 56 57 58 59 60 61 62 63 64 65
Return {"", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,"", 0, 0, "", "", 0, "", 0, "", 0, 0, "", "", 0, 0, 0, 0, 0, 0, "", "", "", 0,{0,0,0,0,0},"",0, 0, 0, 0, 0, "","", "", "", "", "", "", 0, 0, "", "", 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaAliqISS ³ Autor ³  Edson Maricate       ³ Data ³03.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a aliquota para calculo do ISS.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaAliqISS(nItem)

Local nAliquota := 0
Local cCalcISS  := " "

If !Empty(aNfCab[NF_NATUREZA])
	dbSelectArea("SED")
	dbSetOrder(1)
	MsSeek(xFilial("SED")+aNfCab[NF_NATUREZA])
	cCalcISS := SED->ED_CALCISS
EndIf

If (aTes[TS_ISS] == "S" .AND. aNfCab[NF_OPERNF] == "E" .AND. MaSBCampo("CODISS")<>aNfItem[nItem][IT_CODISS])
	aNfItem[nItem][IT_CODISS]	:= MaSBCampo("CODISS")
EndIf

If (aTes[TS_ISS] == "S" .AND. aNfCab[NF_OPERNF] == "S") .OR.;
		(aTes[TS_ISS] == "S" .AND. aNfCab[NF_OPERNF] == "E" .AND. !Empty(aNfItem[nItem][IT_CODISS])) .OR.;
		(cCalcISS=="S" .AND. aTes[TS_ICM] == "N" .AND. aNfCab[NF_OPERNF]$SuperGetMV("MV_TPNFISS") )

	aNfItem[nItem][IT_CALCISS] := "S"
	nAliquota := If ( MaSBCampo("ALIQISS") == 0 , MV_ALIQISS , MaSBCampo("ALIQISS") )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as Excecoes fiscais                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( !Empty(aNFitem[nItem][IT_EXCECAO]) ) .AND. aNfItem[nItem][IT_EXCECAO][7] == "S"
		If ( aNFCab[NF_UFORIGEM]==aNFCab[NF_UFDEST] )
			If aNFItem[nItem][IT_EXCECAO][1] > 0
				nAliquota := aNfItem[nItem][IT_EXCECAO][1] //Aliquota Interna
			EndIf
		Else
			If (aNFItem[nItem][IT_EXCECAO][2] > 0)
				nAliquota := aNfItem[nItem][IT_EXCECAO][2] //Aliquota Externa
			EndIf
		EndIf
	EndIf
Else
	aNfItem[nItem][IT_CALCISS] := "N"
EndIf

aNfItem[nItem][IT_RATEIOISS]	:= aTes[TS_ISS]
aNfItem[nItem][IT_ALIQISS] 		:= nAliquota
aNfItem[nItem][IT_CNAE]			:= MaSBCampo("CNAE")
aNfItem[nItem][IT_CFPS]			:= aTes[TS_CFPS]

Return(nAliquota)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisBsISS³ Autor ³  Edson Maricate       ³ Data ³03.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a base de calculo do ISS                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisBsISS(nItem)
Local nBase := 0

If aNfItem[nItem][IT_CALCISS] == "S" .AND.;
		(aNfCab[NF_OPERNF]=="E".OR.;
		((aNfCab[NF_RECISS]=="1".AND.aNfCab[NF_OPERNF]=="S".AND.SuperGetMV("MV_DESCISS")).OR.(aNfCab[NF_RECISS]<>"1".AND.aNfCab[NF_OPERNF]=="S")))

	nBase := aNfItem[nItem][IT_VALMERC]-aNfItem[nItem][IT_DESCONTO]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reducao padrao da base do ISS ( TES )                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aTes[TS_BASEISS] > 0
		nBase := (nBase*aTes[TS_BASEISS])/100
		aNfItem[nItem][IT_PREDISS] := aTes[TS_BASEISS]
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reducao opcional da base do ISS ( TES )                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aNfItem[nItem,IT_REDISS] > 0
		nBase := (nBase*aNfItem[nItem,IT_REDISS])/100
		aNfItem[nItem][IT_PREDISS] := aNfItem[nItem,IT_REDISS]
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abatimento da base do ISS                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nBase -= aNfItem[nItem,IT_ABVLISS]
	//Abatimento referente ao material aplicado na obra
	nBase -= aNfItem[nItem,IT_ABMATISS]

Else
	nBase := 0
EndIf

aNfItem[nItem][IT_BASEISS] := nBase

Return(nBase)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisVLISS³ Autor ³  Edson Maricate       ³ Data ³03.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor do ISS do item.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisVLISS(nItem)

If aNfItem[nItem][IT_CALCISS] == "S"

	aNfItem[nItem][IT_VALISS] := aNfItem[nItem][IT_BASEISS]*aNfItem[nItem][IT_ALIQISS]/100

	If aNFCab[NF_TIPONF] $ "DB"
		If !Empty(aNFItem[nItem][IT_RECORI])
			If ( aNFCab[NF_CLIFOR] == "C")
				dbSelectArea("SD2")
				MsGoto(aNFItem[nItem][IT_RECORI])
				If ((SD2->D2_VALISS > 0 .AND. aNfItem[nItem][IT_VALISS] = 0) .OR. Abs(aNfItem[nItem][IT_VALISS]-SD2->D2_VALISS)<=1) .AND. aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT .AND. SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0
					aNfItem[nItem][IT_VALISS] := SD2->D2_VALISS
				EndIf
			Else
				dbSelectArea("SD1")
				MsGoto(aNFItem[nItem][IT_RECORI])
				If ((SD1->D1_VALISS > 0 .AND. aNfItem[nItem][IT_VALISS] = 0) .OR. Abs(aNfItem[nItem][IT_VALISS]-SD1->D1_VALISS)<=1) .AND. aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT .AND. SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0
					aNfItem[nItem][IT_VALISS] := SD1->D1_VALISS
				EndIf
			EndIf
		EndIf
	Else
		If !GetNewPar("MV_RNDRNE",.F.)
			MaItArred(nItem,{"IT_VALISS"})
		Else
			aNfItem[nItem][IT_VALISS] := RoundRNE(aNfItem[nItem][IT_VALISS],2)
		Endif
	EndIf
Else
	aNfItem[nItem][IT_VALISS] := 0
EndIf

Return(aNfItem[nItem][IT_VALISS])
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaFisIniLo³ Autor ³Edson Maricate         ³ Data ³09.12.1999 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina inicializacao do item da funcao Fiscal                ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item do Array ANFItem que deve ser inicializado       ³±±
±±³          ³ExpA2: Array de otimizacao de Inicializacao             (OPC)³±±
±±³          ³ExpL3: Indica se o item deve ser estornado caso exista       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo inicializar a variavel aNFItem ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisIniLoad(nItem,aItemLoad,lEstorno)

DEFAULT lEstorno := .F.

If !MaFisFound("IT",nItem)
	If aItemLoad <> Nil
		aadd(aNfItem,{"",;								//1 - Grupo de Tributacao
			{},;										//2 - Array contendo as excessoes Fiscais
			0,;											//3 - Aliquota de ICMS
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},;//4 - Valores de ICMS
			0,;											//5 - Aliquota de IPI
			{0,0,0,0,0},;								//6 - Valores de IPI
			aItemLoad[5],;								//7 - Numero da NF Original
			aItemLoad[6],;   							//8 - Serie da NF Original
			aItemLoad[9],;								//9 - RecNo da NF original
			0,;											//10 - Valor do desconto do item
			0,;											//11 - Valor do Frete
			0,;											//12 - Valor da despesa
			0,;											//13 - Valor do seguro
			0,;											//14 - Valor do frete autonomo
			0,; 										//15 - Valor da Mercadoria
			aItemLoad[1],;								//16 - Codigo do produto
			aItemLoad[2],;								//17 - Codigo da TES
			0,;											//18 - Valor Total do item
			"    ",;									//19 - Codigo FIscal de Operacao
			0,;											//20 - Valor do Funrural
			0,;              							//21 - Aliquota para calculo do FunRural
			.F.,;										//22 - Flag de controle para itens deletados
			MaFisRetLF() ,;								//23 - Array Contendo o demonstrativo fiscal
			{0,0,0,aItemLoad[3],"","","",0},;			//24 - Array contendo os valores de ISS
			{0,0,0,0},;								//25 - Array contendo os valores de IR
			{0,0,0,0},;								//26 - Array contendo os valores de INSS
			0 ,;										//27 - Valor da Embalagem
			Array(NMAXIV),;								//28
			Array(NMAXIV),;								//29
			Array(NMAXIV),;								//30
			0,;											//31
			0,;											//32
			Array(NMAXIV),;								//33
			aItemLoad[4],;								//34
			0,;											//35
			0,;											//36
			0,;											//37
			0,;											//38
			0,;											//39
			0,;											//40
			0,;											//41
			0,;											//42
			0,;			  			  					//43
			0,;			  								//44
			0,;			  								//45
			0,;											//46
			0,;											//47
			0,;											//48
			aItemLoad[7],;								//49
			aItemLoad[8],;								//50
			0,;											//51
			aNFCAB[NF_TIPONF],;						    //52
			"",;										//53
			0,;											//54
			0,;											//55
			0,;											//56
			0,;											//57
			0,;											//58
			0,;											//59
			0,;											//60
			0,;											//61
			0,;											//62
		    0,;                                 		//63
			0,;                                 		//64
			0,;                                 		//65
			0,;											//66 - AFRMM
			0,;											//67
			0,;											//68
			0,;											//69
			0,;											//70
			0,;											//71
			"",;										//72
            Iif (aNfCab[NF_OPERNF]=='S', "01", "0001"),;//73
            {0,0,0},;									//74 - Array contendo os valores do SEST
			0,;											//75 - Base de calculo do PIS Subst. Tributaria
			0,;			   								//76 - Aliquota do PIS Subst. Tributaria
			0,;											//77 - Valor do PIS Subst. Tributaria
			0,;											//78 - Bae da COFINS Subst. Tributaria
			0,;			   								//79 - Aliquota da COFINS Subst. Tributaria
			0,;			   								//80 - Valor da COFINS Subst. Tributaria
			0,;			   								//81 - Valor do Frete de Pauta
			0,;			   								//82 - Base FETHAB
			0,;			   								//83 - Aliquota FETHAB
			0,;			   								//84 - Valor FETHAB
			0,;											//85 - Abatimento do Valor do INSS em Valor - Subcontratada
			{"","","","","","",0,0,0,0,0,0,0,""},;    //86 - SPED
			0,;											//87 - Abatimento da base de calculo do ISS referente ao material utilizado
			"",;            							//88 - Indica se a operacao, mesmo sem calculo de ICMS ST, faz parte do Regime Especial de Substituicao Tributaria
			0,;											//89 - Percentual de UFERMS para o calculo do Fundersul - Mato Grosso do Sul
			0,;			   								//90 - Valor da UFERMS para o calculo do Fundersul - Mato Grosso do Sul
			0})											//91 - Valor do Fundersul - Mato Grosso do Sul
	Else
		aadd(aNfItem,{"",;								//1 - Grupo de Tributacao
			{},;										//2 - Array contendo as excessoes Fiscais
			0,;											//3 - Aliquota de ICMS
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},;	//4 - Valores de ICMS
			0,;											//5 - Aliquota de IPI
			{0,0,0,0,0},;								//6 - Valores de IPI
			SPACE(LEN(SD1->D1_NFORI)),;				//7 - Numero da NF Original
			SPACE(LEN(SD1->D1_SERIORI)),;				//8 - Serie da NF Original
			,;											//9 - RecNo da NF original
			0,;											//10 - Valor do desconto do item
			0,;											//11 - Valor do Frete
			0,;											//12 - Valor da despesa
			0,;											//13 - Valor do seguro
			0,;											//14 - Valor do frete autonomo
			0,; 										//15 - Valor da Mercadoria
			If( aNfCab[NF_OPERNF] == 'S', Space(Len(SD2->D2_COD)), Space(Len(SD1->D1_COD))),;	//16 - Codigo do produto
			"   ",;										//17 - Codigo da TES
			0 ,;										//18 - Valor Total do item
			"    ",;									//19 - Codigo FIscal de Operacao
			0,;											//20 - Valor do Funrural
			0 ,;            				  			//21 - Aliquota para calculo do FunRural
			.F.,;										//22 - Flag de controle para itens deletados
			MaFisRetLF() ,;								//23 - Array Contendo o demonstrativo fiscal
			{0,0,0,"","","","",0},;					//24 - Array contendo os valores de ISS
			{0,0,0,0},;								    //25 - Array contendo os valores de IR
			{0,0,0,0},;								    //26 - Array contendo os valores de INSS
			0 ,;										//27 - Valor da Embalagem
			Array(NMAXIV),;								//28
			Array(NMAXIV),;								//29
			Array(NMAXIV),;								//30
			0,;											//31
			0,;											//32
			Array(NMAXIV),;								//33
			0,;											//34
			0,;											//35
			0,;											//36
			0,;											//37
			0,;											//38
			0,;											//39
			0,;											//40
			0,;											//41
			0,;											//42
			0,;			  			  					//43
			0,;			  								//44
			0,;			  								//45
			0,;											//46
			0,;											//47
			0,;											//48
			0,;											//49
			0,;											//50
			0,;											//51
			aNFCAB[NF_TIPONF],;    						//52
			"",;										//53
			0,;											//54
			0,;											//55
			0,;											//56
			0,;											//57
			0,;											//58
			0,;											//59
			0,;											//60
			0,;											//61
			0,;											//62
		    0,;                                 		//63
			0,;                                 		//64
			0,;                                 		//65
			0,;											//66 - AFRMM
			0,;											//67
			0,;											//68
			0,;											//69
			0,;											//70
			0,;											//71
			"",;										//72
            Iif (aNfCab[NF_OPERNF]=='S', "01", "0001"),;//73
            {0,0,0},;									//74 - Array contendo os valores do SEST
			0,;											//75 - Base de calculo do PIS Subst. Tributaria
			0,;			   								//76 - Aliquota do PIS Subst. Tributaria
			0,;											//77 - Valor do PIS Subst. Tributaria
			0,;											//78 - Bae da COFINS Subst. Tributaria
			0,;			   								//79 - Aliquota da COFINS Subst. Tributaria
			0,;			   								//80 - Valor da COFINS Subst. Tributaria
			0,;			   								//81 - Valor do Frete de Pauta
			0,;			   								//82 - Base FETHAB
			0,;			   								//83 - Aliquota FETHAB
			0,;			   								//84 - Valor FETHAB
			0,;											//85 - Abatimento do Valor do INSS em Valor - Subcontratada
			{"","","","","","",0,0,0,0,0,0,0,""},;    //86 - SPED
			0,;											//87 - Abatimento da base de calculo do ISS referente ao material utilizado
			"",;            							//88 - Indica se a operacao, mesmo sem calculo de ICMS ST, faz parte do Regime Especial de Substituicao Tributaria
			0,;											//89 - Percentual de UFERMS para o calculo do Fundersul - Mato Grosso do Sul
			0,;			   								//90 - Valor da UFERMS para o calculo do Fundersul - Mato Grosso do Sul
			0})											//91 - Valor do Fundersul - Mato Grosso do Sul
	EndIf
	If Len(aNfitem) > 1
		aNfitem[Len(aNfitem)][IT_ITEM] := Soma1(aNfitem[Len(aNfitem)-1][IT_ITEM])
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa arrays de impostos variaveis                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aNfItem[nItem][IT_BASEIMP]:=Afill(aNfItem[nItem][IT_BASEIMP],0)
	aNfItem[nItem][IT_ALIQIMP]:=Afill(aNfItem[nItem][IT_ALIQIMP],0)
	aNfItem[nItem][IT_VALIMP]:=Afill(aNfItem[nItem][IT_VALIMP],0)
	aNfItem[nItem][IT_DESCIV]:=Afill(aNfItem[nItem][IT_DESCIV],{"","",""})
	aadd(aItemDec,{Nil,Nil})
	aItemDec[Len(aItemDec)][1] := Array(Len(aItemRef))
	aItemDec[Len(aItemDec)][2] := Array(Len(aItemRef))
	aFill(aItemDec[Len(aItemDec)][1],0)
	aFill(aItemDec[Len(aItemDec)][2],0)
Else
	If lEstorno
		MaFisSomaIt(nItem,.F.)
	Endif
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisEndLoad³ Autor ³ Edson Maricate      ³ Data ³09.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Finaliza a carga dos itens Fiscais                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Item                                                ³±±
±±³          ³ExpN2 : Tipo de atualizacao do Item :                       ³±±
±±³          ³        1-(default) Executa o recalculo de todos os itens   ³±±
±±³          ³                    para efetuar a atualizacao do cabecalho ³±±
±±³          ³        2-Executa a soma do item para atualizacao do cabeca ³±±
±±³          ³                    lho.                                    ³±±
±±³          ³        3-Nao executa a atualizacao do cabecalho.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisEndLoad(nItem,nTipo)

Local aArea    := GetArea()
DEFAULT nTipo  := 1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona os registros necessarios                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasPROD)
If aNfItem[nItem][IT_RECNOSB1] <> 0 .AND. cAliasPROD=="SB1"
	MsGoto(aNfItem[nItem][IT_RECNOSB1])
Else
	dbSetOrder(1)
	MsSeek(xFilial(cAliasPROD)+aNfItem[nItem][IT_PRODUTO])
EndIf
MaFisTes(aNfItem[nItem][IT_TES],aNfItem[nItem][IT_RECNOSF4],nItem)
MaFisNameIV(,nItem)	// Verifica o Nome dos Impostos Variaveis
MaFisVTot(nItem)
MaItArred(nItem)	// Ajusta os arredondamentos
MaFisLF(nItem)
MaFisLF2(nItem)
MaFisLF3(nItem)

Do Case
Case nTipo == 1
	MaIt2cab()
Case nTipo == 2
	MaFisSomaIt(nItem)
EndCase

If bFisRefresh <> Nil
	Eval(bFisRefresh)
EndIf
If bLivroRefresh <> Nil
	Eval(bLivroRefresh)
EndIf
RestArea(aArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisClear³ Autor ³ Edson Maricate        ³ Data ³09.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Limpa os itens da NF e zera as variaveis do cabecalho.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisClear()

If MaFisFound('NF')
	aNfItem := {}
	aItemDec:= {}
	If aSaveDec<>Nil
		aFill(aSaveDec,0)
	EndIf
	aAuxOri	:= {}
	MaIt2Cab()
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisResum³ Autor ³ Edson Maricate        ³ Data ³13.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza o Array de Resumos da NF.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisResumo(nValBase,nAliquota,nValor,cCodImp,cDescImp,cNomeRef,lForceVlr,lForceBs,lSoma)
Local nRS		:= 0
Local nRS2		:= 0
DEFAULT lForceVlr	:= .F.
DEFAULT lForceBs	:= .F.
DEFAULT lSoma		:= .T.
If Empty(cCodImp)
	Return	.F.
Endif
If !Empty(aNfCab[NF_IMPOSTOS]).AND.aNfCab[NF_IMPOSTOS][1][1]==""
	aNfCab[NF_IMPOSTOS] := {}
	aNfCab[NF_IMPOSTOS2] := {}
Else
	nRS	:= aScan(aNfCab[NF_IMPOSTOS],{|x| x[IMP_COD] ==cCodImp .AND.;
		x[IMP_ALIQ]==nAliquota })
	nRS2:= aScan(aNfCab[NF_IMPOSTOS2],{|x| x[IMP_COD] ==cCodImp   })
EndIf

If aNfCab[NF_RELIMP] <> Nil .AND. !Empty(aNfCab[NF_RELIMP])
	nValBase 	:= IIf(aScan(aNfCab[NF_RELIMP],{|x|"BASE"+cNomeRef$x[3]})>0.OR.lForceBs,nValBase,0)
	nValor		:= IIf(aScan(aNfCab[NF_RELIMP],{|x|"VAL"+cNomeRef$x[3]})>0.OR.lForceVlr,nValor,0)
EndIf

If lSoma
	If nRS > 0
		aNfCab[NF_IMPOSTOS][nRS][IMP_BASE] 	+= nValBase
		aNfCab[NF_IMPOSTOS][nRS][IMP_VAL]  	+= nValor
	Else
		aadd(aNfCab[NF_IMPOSTOS],{cCodImp,cDescImp,nValBase,nAliquota,nValor,cNomeRef})
	EndIf

	If nRS2 > 0
		aNfCab[NF_IMPOSTOS2][nRS2][3] 	+= nValBase
		aNfCab[NF_IMPOSTOS2][nRS2][4] 	+= nValor
	Else
		aadd(aNfCab[NF_IMPOSTOS2],{cCodImp,cDescImp,nValBase,nValor,cNomeRef})
	EndIf
Else
	If nRS > 0
		aNfCab[NF_IMPOSTOS][nRS][IMP_BASE] 	-= nValBase
		aNfCab[NF_IMPOSTOS][nRS][IMP_VAL]  	-= nValor
		If  aNfCab[NF_IMPOSTOS][nRS][IMP_BASE] <= 0 .AND.;
				aNfCab[NF_IMPOSTOS][nRS][IMP_VAL]  <= 0
			aDel(aNfCab[NF_IMPOSTOS],nRS)
			aSize(aNfCab[NF_IMPOSTOS],Len(aNfCab[NF_IMPOSTOS])-1)
		EndIf
	EndIf

	If nRS2 > 0
		aNfCab[NF_IMPOSTOS2][nRS2][3] 	-= nValBase
		aNfCab[NF_IMPOSTOS2][nRS2][4] 	-= nValor
		If  aNfCab[NF_IMPOSTOS2][nRS2][3] <= 0 .AND.;
				aNfCab[NF_IMPOSTOS2][nRS2][4]  <= 0
			aDel(aNfCab[NF_IMPOSTOS2],nRS2)
			aSize(aNfCab[NF_IMPOSTOS2],Len(aNfCab[NF_IMPOSTOS2])-1)
		EndIf
	EndIf
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisRodape³ Autor ³ Edson Maricate       ³ Data ³13.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza o Array de Resumos da NF.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisRodape(nTipo,;		// Quebra : 1 Imposto+Aliquota,  2-Imposto
	oJanela,;		// Janela onde sera montado
	aImpostos,;	// Relacao de Impostos que deverao aparecer ( Codigo )
	aPos,;			// Array contendo Posicao e Tamanho
	bValidPrg,;	// Validacao executada na Edicao dop Campo
	lVisual,; // So para visualizacao
	cFornIss,; //Fornecedor do ISS
	cLojaIss,; //Loja do Fornecedor do ISS
	aRecSE2,;
	cDirf,;
	cCodRet,;
	oCodRet,;
	nCombo,;
	oCombo,;
	dVencIss,; 	//Vencimento ISS
	aCodR,;
	cRecIss,;	//Informa se recolhe o ISS ou nao
	oRecIss)

Local oList
Local aTemp
Local aOpcoes := {"Sim","Nao"}
Local oFornIss
Local oLojaIss
Local oVencIss
Local oDescri

Local cDescri  := ""
Local aAreaSE2 := {}
Local aAreaSA2 := {}
Local lFornIss     := .F.
Local nPosDum	:=	0
Local aAUTOISS	:= &(GetNewPar("MV_AUTOISS",'{"","","",""}'))
Local aMaPCCI  := {}
Local nI        := 0
Local nPosCodR  := 0
Local aOpcIss	:=	{"1="+STR0024,"2="+STR0025}

DEFAULT oCodRet := Nil
DEFAULT oCombo  := Nil
DEFAULT nCombo  := 2
DEFAULT dVencIss := CtoD("")
DEFAULT aCodR	:=	{}
DEFAULT oRecIss := Nil
DEFAULT cRecIss := "1"

If nTipo == 1
	If Empty(aNfCab) .OR. Empty(aNfCab[NF_IMPOSTOS])
		aTemp	:= {{"","",0,0,0}}
	Else
		aTemp	:= aNFCab[NF_IMPOSTOS]
	EndIf
Else
	If Empty(aNfCab) .OR. Empty(aNfCab[NF_IMPOSTOS2])
		aTemp	:= {{"","",0,0}}

	Else
		aTemp	:= aNFCab[NF_IMPOSTOS2]
	EndIf
EndIf

bFisRefresh	:= {|| MaFisRRefresh(oList,nTipo)}

If SE2->(FieldPos("E2_FORNISS")) > 0 .AND. SE2->(FieldPos("E2_LOJAISS")) > 0
	If cFornIss <> NIL .AND. cLojaIss <> NIL

		lFornIss := .T.

		aPos[2] := 85
		aPos[3] -= 80
		@ 03,2 TO 58,84 LABEL '' OF oJanela PIXEL
		@ 06,10 SAY STR0023 Of oJanela PIXEL SIZE 80,09 //"Dados de Cobrança do ISS"
		@ 19,04 SAY RetTitle("E2_FORNISS") Of oJanela PIXEL SIZE 30,09

		If SE2->(FieldPos("E2_VENCISS")) > 0
			@ 46,04 SAY RetTitle("E2_VENCISS")Of oJanela PIXEL SIZE 30,09
		EndIf

		If lVisual

		    If Len(aRecSE2) > 0
		    	aAreaSE2 := SE2->(GetArea())
			    aAreaSA2 := SA2->(GetArea())

			    SE2->(dbGoTo(aRecSE2[1]))
			    cFornIss := SE2->E2_FORNISS
		    	cLojaIss := SE2->E2_LOJAISS
			    If SA2->(MsSeek(xFilial("SA2")+cFornIss+cLojaIss))
					cDescri := SA2->A2_NREDUZ
				Endif
				If SE2->(FieldPos("E2_VENCISS")) > 0
			    	dVencIss := SE2->E2_VENCISS
			 	EndIf

			 	aMaPCCI	:=	MaPCCI()
			 	For nI := 1 To Len( aTemp )
				 	If (nTipo==1)
						If (nPosCodR := aScan(aMaPCCI, {|aX|aX[1]==aTemp[nI][6]}))>0
							aAdd( aCodR, {nI, aMaPCCI[nPosCodR][2], 1, aTemp[nI][6]} )
						EndIf
					Else
						If (nPosCodR := aScan(aMaPCCI, {|aX|aX[1]==aTemp[nI][5]}))>0
							aAdd( aCodR, {nI, aMaPCCI[nPosCodR][2], 1, aTemp[nI][5]} )
						EndIf
					EndIf
				Next

				RestArea(aAreaSE2)
				RestArea(aAreaSA2)
		    Endif

			@ 18,31 MSGET oFornIss VAR cFornIss ;
			PICTURE PesqPict('SE2','E2_FORNISS')  ;
			OF oJanela PIXEL SIZE 35,09 ;
			READONLY

			@ 18,67 MSGET oLojaIss VAR cLojaIss ;
			PICTURE PesqPict("SE2","E2_LOJAISS") ;
			OF oJanela PIXEL SIZE 15,09 ;
			READONLY

			If SE2->(FieldPos("E2_VENCISS")) > 0
				@ 44,38 MSGET oVencIss VAR dVencIss ;
				OF oJanela PIXEL READONLY
			EndIf

		Else

			// Para montar a descricao quando o fornecedor+loja vem preenchido pelo parametro MV_AUTOISS (Mata103)
			If !Empty(cFornISS) .AND. !Empty(cLojaISS)
			    If SA2->(MsSeek(xFilial("SA2")+cFornIss+cLojaIss))
					cDescri := SA2->A2_NREDUZ
				Endif
			Endif

			@ 18,31 MSGET oFornIss VAR cFornIss ;
			PICTURE PesqPict('SE2','E2_FORNISS')  ;
			OF oJanela PIXEL SIZE 35,09 ;
			F3 CpoRetF3('E2_FORNISS') ;
			VALID MaVldForn(@cFornIss,@cLojaIss,@oDescri,@cDescri,@oLojaISS,@oFornIss,1)

			@ 18,67 MSGET oLojaIss VAR cLojaIss ;
			PICTURE PesqPict("SE2","E2_LOJAISS") ;
			OF oJanela PIXEL SIZE 15,09 ;
			F3 CpoRetF3("E2_LOJAISS") ;
			VALID MaVldForn(@cFornIss,@cLojaIss,@oDescri,@cDescri,@oLojaISS,@oFornIss,2)

			If SE2->(FieldPos("E2_VENCISS")) > 0
				@ 44,38 MSGET oVencIss VAR dVencIss ;
				OF oJanela PIXEL
			EndIf

		EndIf

		@ 31,04 MSGET oDescri VAR cDescri OF oJanela PIXEL SIZE 78,09 WHEN .F.

	Endif
Endif

If SuperGetMv("MV_VISDIRF",.F.,"1") == "1"

	If cDirf <> NIL .AND. cCodRet <> NIL

	   If lVisual
		   cCodRet 	:= 	Space(TamSx3("E2_CODRET")[1])
	       cDirf   	:= 	"2"
	   Else
			cDirf 	:= 	CriaVar("E2_DIRF",.T.)
			cCodRet := 	CriaVar("E2_CODRET")
			// Verifica se ha a configuracao para preenchimento automatico dos dados de cobranca do ISS
			If aAutoISS<>Nil .And. Len(aAutoISS)==4 .And. !Empty(aAutoISS[03])
				cDirf 	:= 	aAutoISS[03]
				cCodRet	:=	aAutoISS[04]
			EndIf
		Endif
	    nCombo	:= aOpcoes[VAL(cDirf)]

		If lFornIss
			aPos[2] := 170
			aPos[3] -= 80
			@ 03,85 TO 42,169 LABEL '' OF oJanela PIXEL
			@ 06,93 SAY "DIRF" Of oJanela PIXEL SIZE 80,09 //"Dados de Cobrança do ISS"

			@ 16,89 SAY RetTitle("E2_DIRF") Of oJanela PIXEL SIZE 30,09
			@ 16,125 MSCOMBOBOX oCombo VAR nCombo ITEMS aOpcoes ;
					ON CHANGE (cDirf := StrZero(oCombo:nAt,1)) ;
					VALID MaGrvCdR(@cCodRet,oCombo,oList,@aCodR,@oCodRet,.F.);
					WHEN !lVisual ;
			        SIZE 40,50 OF oJanela PIXEL
			@ 27,89 SAY RetTitle("E2_CODRET") Of oJanela PIXEL SIZE 50,09
			@ 27,125 MSGET oCodRet VAR cCodRet F3 "37" ;
					VALID MaGrvCdR(@cCodRet,oCombo,oList,@aCodR,@oCodRet,.T.) ;
					WHEN !lVisual ;
					OF oJanela PIXEL SIZE 40,09
			@ 42,85 TO 58,169 LABEL '' OF oJanela PIXEL
			@ 47,89 SAY RetTitle("A2_RECISS") Of oJanela PIXEL SIZE 50,09
			@ 46,125 MSCOMBOBOX oRecIss VAR cRecIss ITEMS aOpcIss  ;
					VALID MaFisAlt( "NF_RECISS", cRecIss) ;
					WHEN !lVisual SIZE 40,50 OF oJanela PIXEL
		Else

			aPos[2] := 85
			aPos[3] -= 80
			@ 03,02 TO 42,84 LABEL '' OF oJanela PIXEL
			@ 06,10 SAY "DIRF" Of oJanela PIXEL SIZE 80,09 //"Dados de Cobrança do ISS"

			@ 16,04 SAY RetTitle("E2_DIRF") Of oJanela PIXEL SIZE 30,09
			@ 16,40  MSCOMBOBOX oCombo VAR nCombo ITEMS aOpcoes ;
					ON CHANGE (cDirf := StrZero(oCombo:nAt,1)) ;
					VALID MaGrvCdR(@cCodRet,oCombo,oList,@aCodR,@oCodRet,.F.) ;
					WHEN !lVisual ;
					SIZE 40,50 OF oJanela PIXEL
			@ 27,04 SAY RetTitle("E2_CODRET") Of oJanela PIXEL SIZE 50,09
			@ 27,40 MSGET oCodRet VAR cCodRet F3 "37" ;
						VALID MaGrvCdR(@cCodRet,oCombo,oList,@aCodR,@oCodRet,.T.) ;
					WHEN !lVisual ;
					OF oJanela PIXEL SIZE 40,09
			@ 42,02 TO 58,84 LABEL '' OF oJanela PIXEL
			@ 47,04 SAY RetTitle("A2_RECISS") Of oJanela PIXEL SIZE 50,09
			@ 46,40 MSCOMBOBOX oRecIss VAR cRecIss ITEMS aOpcIss ;
					VALID MaFisAlt( "NF_RECISS", cRecIss) ;
					WHEN !lVisual SIZE 40,50 OF oJanela PIXEL
		Endif
	Endif
Endif

If nTipo == 1
	oList := TWBrowse():New( aPos[1],aPos[2],aPos[3],aPos[4],,{STR0003,STR0004,STR0005,STR0006,STR0007},{30,90,50,30,50},oJanela,,,,,,,,,,,,.F.,,.T.,,.F.,,, ) //"Cod."###"Descricao"###"Base Imposto"###"Aliquota"###"Vlr. Imposto"
Else
	oList := TWBrowse():New( aPos[1],aPos[2],aPos[3],aPos[4],,{STR0003,STR0004,STR0005,STR0007},{30,90,50,50},oJanela,,,,,,,,,,,,.F.,,.T.,,.F.,,, ) //"Cod."###"Descricao"###"Base Imposto"###"Vlr. Imposto"
EndIf
If cPaisLoc == "ARG"
	nPosDum	:=	Ascan(aTemp,{|x| x[1] == "DUM"})
	If nPosDum > 0
		aDel(aTemp,nPosDum)
		aSize(aTemp,Len(aTemp)-1)
	Endif
Endif
oList:SetArray(aTemp)
If !lVisual
	oList:bLDblClick 	:= {|| MaFisVRodape(oList,bValidPrg,nTipo,oList:nColPos) .AND. MaFisInsereImp(oList,bValidPrg,nTipo)}
EndIf
oList:bChange 		:= {|| MaAtuCdR(@cCodRet,aCodR,oList,oCodRet,oCombo,@nCombo,aOpcoes)}
oList:bLine 		:= {|| MaFisLine(oList,aTemp,nTipo) }
oList:lAutoEdit	:= !lVisual

Return oList
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaGrvCdR  ³ Autor ³Gustavo G. Rueda       ³ Data ³15.12.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de amarracao do Codigo de receita a devida retencao   º±±
±±º          ³ da aba impostos. Somente para PIS/COF/CSL/IRR.              º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Variavel cCodRet que recebe o codigo atualizado.      ³±±
±±³          ³ExpO2: Objeto oCombo para refresh.                           ³±±
±±³          ³ExpO3: Objeto oList para refresh.                            ³±±
±±³          ³ExpA4: Variavel aCodR que contem todos os codigos de retencoes³±±
±±³          ³ relacionados na nota.                                       ³±±
±±³          ³ExpO5: Objeto oCodRet para refresh.                          ³±±
±±³          ³ExpL6: Flag para identificar se a chamada estah sendo do valid³±±
±±³          ³ do campo E2_CODRET                                          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> Flag de retorno para o VALID                         ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaGrvCdR(cCodRet,oCombo,oList,aCodR,oCodRet,lCodRet)
Local	lRet		:=	.T.
Local	nPosCodR	:=	aScan(aCodR, {|x|x[4]==oList:AARRAY[oList:nAt][1]})

Default	lCodRet	:=	.F.

If oList:nAt!=1 .And. oList:AARRAY[oList:nAt][1]$"PIS/COF/CSL/IRR"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando o combo for 2(Nao) nao deve ter o codigo de receita, por isso atribuo 2 e branco.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oCombo:nAt==2
		cCodRet := Iif(cPaisLoc=="BRA", Space(TamSx3("E2_CODRET")[1]), Space(4))
		oCodRet:Refresh()

		If nPosCodR!=0
			aCodR[nPosCodR][2]	:=	cCodRet
			aCodR[nPosCodR][3]	:=	oCombo:nAt
		Else
			aAdd( aCodR, {oList:nAt, cCodRet, oCombo:nAt, oList:AARRAY[oList:nAt][1]} )
		EndIf
	Else
		oCodRet:Refresh()
		If lCodRet .And. !CheckSx3("E2_CODRET", cCodRet)
			lRet	:=	.F.
		Else
			If nPosCodR!=0
				aCodR[nPosCodR][2]	:=	cCodRet
				aCodR[nPosCodR][3]	:=	oCombo:nAt
			Else
				aAdd( aCodR, {oList:nAt, cCodRet, oCombo:nAt, oList:AARRAY[oList:nAt][1]} )
			EndIf
		EndIf
	EndIf
EndIf
Return lRet
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaAtuCdR  ³ Autor ³Gustavo G. Rueda       ³ Data ³15.12.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de atualizacao do codigo de receita exibido na aba    ³±±
±±³          ³ impostos a medida que seleciono a retencao no browse ao lado³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Variavel cCodRet que recebe o codigo atualizado.      ³±±
±±³          ³ExpA2: Variavel aCodR que contem todos os codigos de retencoes³±±
±±³          ³ relacionados na nota.                                       ³±±
±±³          ³ExpO3: Objeto oList para refresh.                            ³±±
±±³          ³ExpO4: Objeto oCodRet para refresh.                          ³±±
±±³          ³ExpO5: Objeto oCombo para refresh.                           ³±±
±±³          ³ExpO6: Variavel nCombo que recebe a opcao selecionada.       ³±±
±±³          ³ExpO7: Variavel aOpcoes que contem as opcoes para selecao.   ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaAtuCdR(cCodRet,aCodR,oList,oCodRet,oCombo,nCombo,aOpcoes)
Local	nPosCodR	:=	0
Local	nI

If oList<>Nil
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Este tratamento se deve para o codigo de receita do IR caso venha preenchido atraves do ³
	//³   MV_AUTOISS ou do PE MT103DRF.                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len( aCodR )==1 .And. aCodR[1][1]==99
		For nI := 1 To Len( oList:aArray )
			If oList:aArray[nI][1]=="IRR"
				aCodR[1][1]	:=	nI
			EndIf
		Next nI
	EndIf

	If (nPosCodR := aScan(aCodR, {|x|x[4]==oList:aArray[oList:nAt][1]}))>0
		cCodRet	:=	aCodR[nPosCodR,2]
		nCombo	:=	aOpcoes[aCodR[nPosCodR,3]]
	Else
		cCodRet	:=	Iif(cPaisLoc=="BRA", Space(TamSx3("E2_CODRET")[1]), Space(4))
		nCombo	:=	aOpcoes[2]
	EndIf
EndIf
If oCodRet<>Nil
	oCodRet:Refresh()
EndIf
If oCombo<>Nil
	oCombo:Refresh()
EndIf
Return .t.
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaPCCI    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.12.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescri‡„o ³Funcao de restauracao dos codigos de receita para serem      º±±
±±º          ³ exibidos na visualizacao da nota fiscal.                    º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet -> Array contendo os codigos de retencao gravados nos   ³±±
±±³          ³ titulos.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaPCCI
Local aRet       := {}

If cPaisLoc=="BRA"
	If !Empty( SE2->E2_CODRPIS )
		aAdd( aRet, {"PIS",SE2->E2_CODRPIS} )
	EndIf
	If !Empty( SE2->E2_CODRCOF )
		aAdd( aRet, {"COF",SE2->E2_CODRCOF} )
	EndIf
	If !Empty( SE2->E2_CODRCSL )
		aAdd( aRet, {"CSL",SE2->E2_CODRCSL} )
	EndIf
	If !Empty( SE2->E2_CODRET )
		aAdd( aRet, {"IRR",SE2->E2_CODRET} )
	EndIf
Endif
Return( aRet )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisLine³ Autor ³ Edson Maricate         ³ Data ³13.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a linha de exibicao do ListBox atualizado.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisLine(oList,aTemp,nTipo)
Local aRet,nDec
Local cPictAliq	:= If( cPaisLoc="BRA","@E 999.99",PesqPict("SFB","FB_ALIQ"))
Local cPictVal	:=	""
If cPaisLoc<>"BRA"
	If FunName()=="MATA121" .AND. Type("nMoedaPed")=="N"
		nDec:=MsDecimais(nMoedaPed)
	ElseIf FunName()=="MATA150" .AND. Type("nMoedaCot")=="N"
		nDec:=MsDecimais(nMoedaCot)
	Else
		nDec:=MsDecimais(If(Type("nMoedaNF")=="N",nMoedaNF,If(Type("nMoedaCor")=="N",nMoedaCor,1)))
	Endif
Else
	nDec:=2
Endif
cPictVal	:= "@E 999,999,999"+IIf(nDec>0,"."+Replicate("9",nDec),"")
If Len(aTemp)>0
	If nTipo == 1
		aRet:= {aTemp[oList:nAt][1],;
			aTemp[oList:nAt][2],;
			IIf(ValType(aTemp[oList:nAt][3])=="N",TransForm(aTemp[oList:nAt][3],cPictVal),aTemp[oList:nAt][3]),;
			TransForm(aTemp[oList:nAt][4],cPictAliq),;
			IIf(valType(aTemp[oList:nAt][5])=="N",TransForm(aTemp[oList:nAt][5],cPictVal),aTemp[oList:nAt][5]) }
	Else
		aRet:= {aTemp[oList:nAt][1],;
			aTemp[oList:nAt][2],;
			IIf(ValType(aTemp[oList:nAt][3])=="N",TransForm(aTemp[oList:nAt][3],cPictVal),aTemp[oList:nAt][3]),;
			IIf(ValType(aTemp[oList:nAt][4])=="N",TransForm(aTemp[oList:nAt][4],cPictVal),aTemp[oList:nAt][4]) }
	EndIf
Else
	aRet:={}
Endif

Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisVRoda³ Autor ³ Edson Maricate        ³ Data ³13.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza o Array de Resumos da NF.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisVRodape(oList,bValidPrg,nTipo,nCol)

Local nPos        := oList:nAT
Local nBaseAnt    := 0
Local nBase       := 0
Local nVal        := 0
Local cIniCpo     := ""
Local lEditaVal	:= .F.
Local lEditaBas	:= .F.
Local lNfCab      := MaFisFound( "NF" )
Local nDec		  := MsDecimais(Max(MaFisRet(,'NF_MOEDA'),1))
Local cPictGet	  := '@E 999,999,999'+IIf(nDec>0,"."+Replicate("9",nDec),"")

Private nValAnt   := 0


DEFAULT nCol := 0

If Len(MaFisRet(,'NF_IMPOSTOS'))>0
	If lNfCab .AND. IIf(nTipo==1,MaFisVldAlt(MaFisRet(,'NF_IMPOSTOS')[nPos][6]),MaFisVldAlt(MaFisRet(,'NF_IMPOSTOS')[nPos][5]))

		nBaseAnt := IIf(nTipo==1,aNFCab[NF_IMPOSTOS][nPos][3],aNFCab[NF_IMPOSTOS2][nPos][3])
		nBase    := nBaseAnt

		lEditaVal	:= IIf(aScan(aNfCab[NF_RELIMP],{|x|x[3]==AllTrim('IT_VAL'+IIf(nTipo==1,MaFisRet(,'NF_IMPOSTOS')[nPos][6],MaFisRet(,'NF_IMPOSTOS2')[nPos][5]))})>0 ;
		.OR.  aScan(aNfCab[NF_RELIMP],{|x|x[3]==AllTrim('NF_VAL'+IIf(nTipo==1,MaFisRet(,'NF_IMPOSTOS')[nPos][6],MaFisRet(,'NF_IMPOSTOS2')[nPos][5]))})>0 ,.T.,.F.) ;
		.OR. MaFisRet(,'NF_IMPOSTOS')[nPos][6]=="RUR"
		If cPaisLoc <> "BRA"
			lEditaBas := .F.
		Else
			lEditaBas	:= IIf(aScan(aNfCab[NF_RELIMP],{|x|x[3]==AllTrim('IT_BASE'+IIf(nTipo=1,MaFisRet(,'NF_IMPOSTOS')[nPos][6],MaFisRet(,'NF_IMPOSTOS2')[nPos][5]))})>0 ;
			.OR.  aScan(aNfCab[NF_RELIMP],{|x|x[3]==AllTrim('NF_BASE'+IIf(nTipo=1,MaFisRet(,'NF_IMPOSTOS')[nPos][6],MaFisRet(,'NF_IMPOSTOS2')[nPos][5]))})>0 ,.T.,.F.)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a Edicao da Base do imposto                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEditaBas .AND. ( nCol == 0 .OR. nCol == 3)
			MaFisEditCell(@nBase,oList,cPictGet,3,'Positivo()')
			If nBaseAnt<>nBase
				If nTipo == 1
					cIniCpo	:= 'IMP_BASE'
					MaFisAlt('IMP_BASE'+MaFisRet(,'NF_IMPOSTOS')[nPos][6],nBase,nPos)
					If Len(aNFCab[NF_IMPOSTOS]) >= nPos
						aNFCab[NF_IMPOSTOS][nPos][3] := nBase
					Else
						lEditaVal := .F.
					EndIf
				Else
					cIniCpo	:= 'NF_BASE'
					MaFisAlt('NF_BASE'+MaFisRet(,'NF_IMPOSTOS2')[nPos][5],nBase,nPos)
					If Len(aNFCab[NF_IMPOSTOS2]) >= nPos
						aNFCab[NF_IMPOSTOS2][nPos][3] := nBase
					Else
						lEditaVal := .F.
					EndIf
				EndIf
				Eval(bValidPrg)
				MaFisRRefresh(oList,nTipo)
			EndIf
		EndIf

		If lEditaVal

			nValAnt	:= IIf(nTipo==1,aNFCab[NF_IMPOSTOS][nPos][5],aNFCab[NF_IMPOSTOS2][nPos][4])
			nVal	:= nValAnt

			If cPaisLoc=="BRA"
				MaFisEditCell(@nVal,oList,cPictGet,IIf(nTipo==1,5,4),'Positivo()')
			Else
				MaFisEditCell(@nVal,oList,cPictGet,IIf(nTipo==1,5,4),'LocxValImp(ReadVar(),nValAnt)')
			Endif
			If nValAnt<>nVal
				If nTipo == 1
					MaFisAlt('IMP_VAL'+MaFisRet(,'NF_IMPOSTOS')[nPos][6],nVal,nPos)
					If Len(aNFCab[NF_IMPOSTOS]) >= nPos
						aNFCab[NF_IMPOSTOS][nPos][5] := nVal
					Endif
				Else
					MaFisAlt('NF_VAL'+MaFisRet(,'NF_IMPOSTOS2')[nPos][5],nVal,nPos)
					If Len(aNFCab[NF_IMPOSTOS2]) >= nPos
						aNFCab[NF_IMPOSTOS2][nPos][4] := nVal
					Endif
				EndIf
				Eval(bValidPrg)
				MaFisRRefresh(oList,nTipo)
			EndIf
		EndIf
	EndIf
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisInser³ Autor ³ Edson Maricate        ³ Data ³13.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Insere um novo Imposto na NF.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisInsereImp(oList,bValidPrg,nTipo)

Local oDlg
Local oCombo
Local lOk		:= .F.
Local nPos		:= oList:nAT
Local lInsere	:= .F.
Local aImpostos	:= { 'IRRF Imposto de Renda','ISS Imp. Serviço','I.C.M.S','IPI','ICMS Retido','INSS','PIS - Via Apuração','COFINS - Via Apuração','PIS - Via Retençao','COFINS - Via Retençao','CSLL - Via Retençao','ICMS Complementar','PIS - Subst. Tributaria','COFINS - Subst. Tributaria','SEST/SENAT'}
Local aImpCod	:= { 'IRR','ISS','ICM','IPI','SOL','INS','PS2','CF2','PIS','COF','CSL','CMP','PS3','CF3','SES' }
Local nBase		:= 0
Local nValor	:= 0
Local cImposto	:= aImpostos[1]

lInsere := If( MaFisFound("NF"), AllTrim(IIf(nTipo==1,Len(MaFisRet(,'NF_IMPOSTOS'))>0 .AND. MaFisRet(,'NF_IMPOSTOS')[nPos][6],Len(MaFisRet(,'NF_IMPOSTOS2'))>0 .AND. MaFisRet(,'NF_IMPOSTOS2')[nPos][5]))=="NEW", .F. )

If lInsere .AND. cPaisLoc=="BRA"

	DEFINE MSDIALOG oDlg FROM 119,147 TO 270,480 TITLE 'Impostos' Of oMainWnd PIXEL

	@ 22 ,9   SAY 'Imposto' Of oDlg PIXEL SIZE 41 ,9
	@ 21 ,34  MSCOMBOBOX oCombo VAR cImposto ITEMS aImpostos SIZE 106,50 OF oDlg PIXEL
	@ 43 ,9   SAY 'Base' Of oDlg PIXEL SIZE 28 ,9
	@ 59 ,9   SAY 'Valor' Of oDlg PIXEL SIZE 42 ,9
	@ 42 ,34  MSGET nBase  Picture "@E 999,999,999,999.99" Valid Positivo(nBase) OF oDlg PIXEL SIZE 75 ,9

	@ 60 ,34  MSGET nValor Picture "@E 999,999,999,999.99" Valid Positivo(nValor) OF oDlg PIXEL SIZE 75 ,9

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk:=.T.,oDlg:End()},{||oDlg:End()}) CENTERED

EndIf

If lOk
	If !Empty(MaFisScan("NF_BASE"+aImpCod[aScan(aImpostos,cImposto)],.F.)) .And. (nBase > 0 .OR. aImpCod[aScan(aImpostos,cImposto)] $ "PIS,COF,CSL,IRR")
		MaFisAlt("NF_BASE"+aImpCod[aScan(aImpostos,cImposto)],nBase,)
	EndIf
	If !Empty(MaFisScan("NF_VAL"+aImpCod[aScan(aImpostos,cImposto)],.F.)) .And. (nValor > 0 .OR. aImpCod[aScan(aImpostos,cImposto)] $ "PIS,COF,CSL,IRR")
		MaFisAlt("NF_VAL"+aImpCod[aScan(aImpostos,cImposto)],nValor,)
	EndIf
	If nBase+nValor>0
		MaFisRRefresh(oList,nTipo)
		Eval(bValidPrg)
	EndIf
EndIf

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisEditCellLine³ Autor ³ Edson Maricate ³ Data ³13.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria um Get para edicao do Imposta no ListBox.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisEditCell(nValor,oBrowse,cPict,nCol,cValidCpo)
Local oDlg
Local oRect
Local oGet1
Local oBtn
Local cMacro := ''
Local nRow   := oBrowse:nAt
Local oOwner := oBrowse:oWnd
Local cValid := IIf(cValidCpo==Nil,'.T.',cValidCpo)+'.AND.Eval(bChange)'


bChange := { ||  nValor := &cMacro,oBrowse:aArray[nRow,nCol] := &cMacro }
oRect := tRect():New(0,0,0,0)            // obtem as coordenadas da celula (lugar onde
oBrowse:GetCellRect(nCol,,oRect)   // a janela de edicao deve ficar)
aDim  := {oRect:nTop,oRect:nLeft,oRect:nBottom,oRect:nRight}

DEFINE MSDIALOG oDlg OF oOwner  FROM 0, 0 TO 0, 0 STYLE nOR( WS_VISIBLE, WS_POPUP ) PIXEL

cMacro := "M->CELL"
&cMacro:= nValor
cPict  := cPict

@ 0,0 MSGET oGet1 VAR &(cMacro) SIZE 0,0 OF oDlg FONT oOwner:oFont PICTURE cPict PIXEL HASBUTTON VALID &cValid
oGet1:Move(-2,-2, (aDim[ 4 ] - aDim[ 2 ]) + 4, aDim[ 3 ] - aDim[ 1 ] + 4 )

@ 0,0 BUTTON oBtn PROMPT "ze" SIZE 0,0 OF oDlg
oBtn:bGotFocus := {|| oDlg:nLastKey := VK_RETURN, oDlg:End(0)}

oGet1:cReadVar  := cMacro

ACTIVATE MSDIALOG oDlg ON INIT oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])

oBrowse:nAt := nRow
SetFocus(oBrowse:hWnd)
oBrowse:Refresh()

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisRRefresh³ Autor ³ Edson Maricate     ³ Data ³13.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa o Refresh no ListBox.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function MaFisRRefresh(oList,nTipo)

Local aTemp
Local nPosDum := 0

If nTipo == 1
	aTemp := IIf(!Empty(aNfCab),aNfCab[NF_IMPOSTOS],{{"","",0,0,0}})
Else
	aTemp := IIf(!Empty(aNfCab),aNfCab[NF_IMPOSTOS2],{{"","",0,0}})
EndIf

If cPaisLoc == "ARG"
	nPosDum	:=	Ascan(aTemp,{|x| x[1] == "DUM"})
	If nPosDum > 0
		aDel(aTemp,nPosDum)
		aSize(aTemp,Len(aTemp)-1)
	Endif
Endif

If ValType(oList)<>"U"
	oList:SetArray(aTemp)
	oList:bLine := {|| MaFisLine(oList,aTemp,nTipo) }
	oList:Refresh()
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MaFisRef ³ Autor ³ Edson Maricate        ³ Data ³ 10.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa o calculo dos valores do item da NF.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Referencia                                         ³±±
±±³          ³ ExpC2 = Identificador do arquivo                           ³±±
±±³          ³ ExpC1 = Valor da Referencia                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA100 / MATA910                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisRef(cReferencia,cProg,xValor)
Local aArea	   := GetArea()
Local lRet 	   := .T.
Local nX       := 0	//controle de loop
Local nY       := 0	//controle de loop
Local cValid   := ""
Local cRefCols := ""
Local cCampo   := ""

If Type('l100') == 'U'
	l100 := .F.
EndIf
If Type('l500') == 'U'
	l500 := .F.
EndIf

Do Case
Case MaFisFound('NF')
	If SubStr(cReferencia,1,2)=="NF"
		If lRet := MaFisVldAlt(cReferencia)
			MaFisAlt(cReferencia,xValor)
			For nY := 1 to Len(aCols)
				If MaFisFound("IT",nY)
					For nX	:= 1 to Len(aHeader)
						cValid	:= AllTrim(UPPER(aHeader[nX][6]))
						If "MAFISREF"$cValid
							nPosRef := AT('MAFISREF("',cValid) + 10
							cRefCols:=Substr(cValid,nPosRef,AT('","'+cProg+'",',cValid)-nPosRef )
							aCols[nY][nX]:= MaFisRet(nY,cRefCols)
						EndIf
					Next nX
				EndIf
			Next nY
		EndIf
		Eval(bRefresh)
	Else
		If MaFisFound("IT",N)
			If aNfItem[N][IT_DELETED] .AND. IIf(Len(aCols[1])==Len(aHeader)+1,!aCols[N][Len(aHeader)+1],.F.)
				MaFisDel(N,.F.)
			EndIf
			If GdFieldPos("D1_ITEM")>0
				aNfItem[N][IT_ITEM] := aCols[N][GdFieldPos("D1_ITEM")]
			EndIf
		EndIf
		MaFisIniLoad(n)
		If lRet := MaFisVldAlt(cReferencia,n)
			MaFisAlt(cReferencia,xValor,n)
			For nX	:= 1 to Len(aHeader)
				cValid	:= AllTrim(UPPER(aHeader[nX][6]))
				If "MAFISREF"$cValid
					nPosRef := AT('MAFISREF("',cValid) + 10
					cRefCols:=Substr(cValid,nPosRef,AT('","'+cProg+'",',cValid)-nPosRef )
					aCols[n][nX]:= MaFisRet(n,cRefCols)
				EndIf
			Next nX
		EndIf
		Eval(bRefresh)
	EndIf
Case l100
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Compatibiliz0acao com o MATA100 p/ v.5.08                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCampo	:= AllTrim(ReadVar())
	Do Case
	Case cCampo ==	'M->D1_COD'
		lRet := A100IniCpo()
	Case cCampo == 'M->D1_VUNIT'
		lRet := IIf(cTipo="D",A100Zera(),.T.) .AND. A100Valor()
	Case cCampo == 'M->D1_TOTAL'
		lRet := A100_Multt()
	Case cCampo == 'M->D1_VALIPI'
		lRet := A100Impos()
	Case cCampo == 'M->D1_TES'
		lRet := A100_IniCF()
	Case cCampo == 'M->D1_DESC'
		lRet := A100Impos()
	Case cCampo == 'M->D1_IPI'
		lRet := A100Impos()
	Case cCampo == 'M->D1_PICM'
		lRet := A100Impos()
	Case cCampo == 'M->D1_NFORI'
		lRet := A100Dev()
	Case cCampo == 'M->D1_SERIORI'
		lRet := A100Dev()
	Case cCampo == 'M->D1_ITEMORI'
		lRet := A100ItDev()
	Case cCampo == 'M->D1_BASEICM'
		lRet := A100Impos()
	Case cCampo == 'M->D1_VALDESC'
		lRet := A100VlrDes()
	Case cCampo == 'M->D1_BASEIPI'
		lRet := A100Impos()
	EndCase
Case l500
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Compatibiliz0acao com o MATA920 p/ v.5.08                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCampo	:= AllTrim(ReadVar())
	Do Case
	Case cCampo ==	'M->D2_COD'
		lRet := A100IniCpo()
	Case cCampo == 'M->D2_TOTAL'
		lRet := A100_Multt()
	Case cCampo == 'M->D2_VALIPI'
		lRet := A100Impos()
	Case cCampo == 'M->D2_TES'
		lRet := A100_IniCF()
	Case cCampo == 'M->D2_DESC'
		lRet := A100Impos()
	Case cCampo == 'M->D2_DESCON'
		lRet := A100Impos()
	Case cCampo == 'M->D2_IPI'
		lRet := A100Impos()
	Case cCampo == 'M->D2_PICM'
		lRet := A100Impos()
	Case cCampo == 'M->D2_BASEICM'
		lRet := A100Impos()
	EndCase
EndCase

RestArea(aArea)
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaIniRef³ Autor ³ Edson Maricate          ³ Data ³ 10.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicializa as variaveis utilizadas no Retorno Fiscal       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATXFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaIniRef()
Local nG
Local lArredBra	:=	(cPaisLoc == "BRA")
Local lCritArr	:=	(cPaisLoc <> "BRA")

aItemRef	:= {}
aCabRef		:= {}
aLFIs		:= {}
aResRef		:= {}

aadd(aItemRef,{"IT_GRPTRIB","1",15,.F.,.F.})      				//Grupo de Tributacao
aadd(aItemRef,{"IT_EXCECAO","2",,.F.,.F.})  					//Array da EXCECAO Fiscal
aadd(aItemRef,{"IT_ALIQICM","3",40,.F.,.F.}) 					//Aliquota de ICMS
aadd(aItemRef,{"IT_ICMS","4",,.F.,.F.})  						//Array contendo os valores de ICMS
aadd(aItemRef,{"IT_BASEICM",{4,1},70,lArredBra,lCritArr})		//Valor da Base de ICMS
aadd(aItemRef,{"IT_VALICM",{4,2},80,lArredBra,GetNewPar("MV_RNDICM",.F.)})		//Valor do ICMS Normal
aadd(aItemRef,{"IT_BASESOL",{4,3},100,lArredBra,lCritArr})		//Base do ICMS Solidario
aadd(aItemRef,{"IT_ALIQSOL",{4,4},40,.F.,.F.})				//Aliquota do ICMS Solidario
aadd(aItemRef,{"IT_VALSOL",{4,5},110,lArredBra,GetNewPar("MV_RNDICM",.F.)})		//Valor do ICMS Solidario
aadd(aItemRef,{"IT_MARGEM",{4,6},90,.F.,.F.})					//Margem de lucro para calculo da Base do ICMS Sol.
aadd(aItemRef,{"IT_BICMORI",{4,7},,lArredBra,lCritArr})		//Valor original da Base de ICMS
aadd(aItemRef,{"IT_ALIQCMP",{4,8},40,.F.,.F.})				//Aliquota para calculo do ICMS Complementar
aadd(aItemRef,{"IT_VALCMP",{4,9},80,lArredBra,GetNewPar("MV_RNDICM",.F.)})		//Valor do ICMS Complementar
aadd(aItemRef,{"IT_BASEICA",{4,10},71,lArredBra,lCritArr}) 	//Base do ICMS sobre o frete autonomo
aadd(aItemRef,{"IT_VALICA",{4,11},81,lArredBra,lCritArr})  	//Valor do ICMS sobre o frete autonomo
aadd(aItemRef,{"IT_DEDICM",{4,12},80,lArredBra,lCritArr})  	//Valor da deducao do ICMS
aadd(aItemRef,{"IT_ALIQIPI","5",40,.F.,.F.})			  		//Aliquota de IPI
aadd(aItemRef,{"IT_IPI","6",,.F.,lCritArr}) 					//Array contendo os valores de IPI
aadd(aItemRef,{"IT_BASEIPI",{6,1},50,lArredBra,lCritArr})		//Valor da Base do IPI
aadd(aItemRef,{"IT_VALIPI",{6,2},60,lArredBra,GetNewPar("MV_RNDIPI",.F.)})		//Valor do IPI
aadd(aItemRef,{"IT_BIPIORI",{6,3},,lArredBra,lCritArr})		//Valor da Base Original do IPI
aadd(aItemRef,{"IT_NFORI","7",20,.F.,.F.}) 	 				//Numero da NF Original
aadd(aItemRef,{"IT_SERORI","8",20,.F.,.F.})	  				//Serie da NF Original
aadd(aItemRef,{"IT_RECORI","9",20,.F.,.F.})  					//RecNo da NF Original (SD1/SD2)
aadd(aItemRef,{"IT_DESCONTO","10",20,.T.,lCritArr})			//Valor do Desconto
aadd(aItemRef,{"IT_FRETE","11",20,.T.,lCritArr}) 				//Valor do Frete
aadd(aItemRef,{"IT_DESPESA","12",20,.T.,lCritArr})		 		//Valor das Despesas Acessorias
aadd(aItemRef,{"IT_SEGURO","13",20,.T.,lCritArr})		 		//Valor do Seguro
aadd(aItemRef,{"IT_AUTONOMO","14",20,.T.,lCritArr})			//Valor do Frete Autonomo
aadd(aItemRef,{"IT_VALMERC","15",,.F.,lCritArr}) 				//Valor da mercadoria
aadd(aItemRef,{"IT_PRODUTO","16",10,.F.,.F.})			 		//Valor da mercadoria
aadd(aItemRef,{"IT_TES","17",20,.F.,.F.})			 			//Codigo da TES
aadd(aItemRef,{"IT_TOTAL","18",,.T.,lCritArr})		 			//Valor Total do Item
aadd(aItemRef,{"IT_CF","19",30,.F.,.F.}) 						//Codigo Fiscal de operacao
aadd(aItemRef,{"IT_FUNRURAL","20",,lArredBra,GetNewPar("MV_RNDFUN",.F.)})		//Valor do FunRural do Item
aadd(aItemRef,{"IT_PERFUN","21",,.F.,.F.}) 					//Aliquota para calculo do Funrural
aadd(aItemRef,{"IT_DELETED","22",,.F.,.F.})					//Flag de controle para itens deletados
aadd(aItemRef,{"IT_LIVRO","23",,.F.,.F.})						//Array contendo o demonstrativo fiscal
aadd(aItemRef,{"IT_ISS","24",,.F.,.F.})						//Array contendo os valores de ISS
aadd(aItemRef,{"IT_ALIQISS",{24,1},40,.F.,.F.})				//Aliquota de ISS do item
aadd(aItemRef,{"IT_BASEISS",{24,2},,lArredBra,lCritArr})		//Base de Calculo do ISS
aadd(aItemRef,{"IT_VALISS",{24,3},,.T.,SuperGetMV("MV_RNDISS")}) 		//Valor do ISS do item
aadd(aItemRef,{"IT_CODISS",{24,4},,.F.,.F.}) 					//Codigo Servico do item
aadd(aItemRef,{"IT_CFPS",{24,7},,.F.,.F.}) 					//Codigo Fiscal de Prestacao de Servico
aadd(aItemRef,{"IT_IR","25",,.F.,.F.})							//Array contendo os valores do Imposto de renda
aadd(aItemRef,{"IT_BASEIRR",{25,1},,.T.,lCritArr})			//Base do Imposto de Renda do item
aadd(aItemRef,{"IT_REDIR",{25,2},,.F.,.F.}) 					//Percentual de Reducao da Base de calculo do IR
aadd(aItemRef,{"IT_ALIQIRR",{25,3},40,.F.,.F.}) 				//Percentual de calculo do Imposto de Renda
aadd(aItemRef,{"IT_VALIRR",{25,4},,lArredBra,GetNewPar("MV_RNDIRF",.F.)}) 		//Valor do Imposto de Renda do item
aadd(aItemRef,{"IT_INSS","26",,.F.,.F.})						//Array contendo os valores de INSS
aadd(aItemRef,{"IT_BASEINS",{26,1},,lArredBra,lCritArr}) 		//Base de calculo do INSS
aadd(aItemRef,{"IT_REDINSS",{26,2},,.F.,.F.})  				//Percentual de Reducao da Base de Calculo do INSS
aadd(aItemRef,{"IT_ALIQINS",{26,3},,.F.,.F.}) 				//Aliquota de calculo do INSS
aadd(aItemRef,{"IT_VALINS",{26,4},,lArredBra,GetNewPar("MV_RNDINS",.F.)})  		//Valor do INSS do item
aadd(aItemRef,{"IT_VALEMB","27",,.T.,lCritArr})				//Valor da embalagem do item
aadd(aItemRef,{"IT_BASEIMP","28",,.F.,lCritArr})			 	//Bases dos Impostos Variaveis
For nG := 1 To NMAXIV
	aadd(aItemRef,{"IT_BASEIV"+NumCpoImpVar(nG),{28,nG},,lArredBra,lCritArr})
Next nG
aadd(aItemRef,{"IT_ALIQIMP","29",,.F.,.F.})  	 				//Aliquotas dos Impostos Variaveis
For nG := 1 To NMAXIV
	aadd(aItemRef,{"IT_ALIQIV"+NumCpoImpVar(nG),{29,nG},,.F.,.F.})
Next nG
aadd(aItemRef,{"IT_VALIMP","30",,.F.,.F.})  	 				//Valores dos Impostos Variaveis
For nG := 1 To NMAXIV
	aadd(aItemRef,{"IT_VALIV"+NumCpoImpVar(nG),{30,nG},,lArredBra,lCritArr})
Next nG
aadd(aItemRef,{"IT_BASEDUP","31",,.T.,lCritArr}) 	  			//Valor da embalagem do item
aadd(aItemRef,{"IT_DESCZF","32",,lArredBra,lCritArr})			//Valor do desconto na ZOna Franca do Item
aadd(aItemRef,{"IT_DESCIV","33",,.F.,.F.})  					//Descricao dos Impostos Variaveis
aadd(aItemRef,{"IT_QUANT","34",,.F.,.F.})						//Quantidade do Item
aadd(aItemRef,{"IT_PRCUNI","35",,.F.,lCritArr})				//Preco Unitario do Item
aadd(aItemRef,{"IT_VIPIBICM","36",,lArredBra,lCritArr})		//Valor do IPI Incidente na Base de ICMS
aadd(aItemRef,{"IT_PESO","37",,.F.,.F.})						// Peso do Item
aadd(aItemRef,{"IT_ICMFRETE","38",82,lArredBra,lCritArr})  	//Valor do ICMS Relativo ao Frete
aadd(aItemRef,{"IT_BSFRETE","39",72,lArredBra,lCritArr})		//Base do ICMS Relativo ao Frete
aadd(aItemRef,{"IT_BASECOF","40",,lArredBra,lCritArr})			//Base de calculo do COFINS
aadd(aItemRef,{"IT_ALIQCOF","41",40,lArredBra,.F.})			//Aliquota de calculo do COFINS
aadd(aItemRef,{"IT_VALCOF","42",,lArredBra,GetNewPar("MV_RNDCOF",.F.)})			//Valor do COFINS
aadd(aItemRef,{"IT_BASECSL","43",,lArredBra,lCritArr})		 	//Base de calculo do CSLL
aadd(aItemRef,{"IT_ALIQCSL","44",40,lArredBra,.F.})			//Aliquota de calculo do CSLL
aadd(aItemRef,{"IT_VALCSL","45",,lArredBra,GetNewPar("MV_RNDCSL",.F.)})			//Valor do CSLL
aadd(aItemRef,{"IT_BASEPIS","46",,lArredBra,lCritArr})			//Base de calculo do PIS
aadd(aItemRef,{"IT_ALIQPIS","47",40,lArredBra,.F.})			//Aliquota de calculo do PIS
aadd(aItemRef,{"IT_VALPIS","48",,lArredBra,GetNewPar("MV_RNDPIS",.F.)})			//Valor do PIS
aadd(aItemRef,{"IT_RECNOSB1","49",,.T.,.F.})					//RecNo SB1
aadd(aItemRef,{"IT_RECNOSF4","50",,.T.,.F.})					//RecNo SF4
aadd(aItemRef,{"IT_VNAGREG","51",,.T.,lCritArr})				//Valor da mercadoria nao agregado ao NF_VALMERC
aadd(aItemRef,{"IT_REMITO","53",,.F.,.F.})		  				//Numetro do remito
aadd(aItemRef,{"IT_BASEPS2","54",,lArredBra,lCritArr})			//Base de calculo do PIS 2
aadd(aItemRef,{"IT_ALIQPS2","55",40,lArredBra,.F.})			//Aliquota de calculo do PIS 2
aadd(aItemRef,{"IT_VALPS2","56",,.T.,GetNewPar("MV_RNDPS2",lCritArr)})			//Valor do PIS 2
aadd(aItemRef,{"IT_BASECF2","57",,lArredBra,lCritArr})			//Base de calculo do COFINS 2
aadd(aItemRef,{"IT_ALIQCF2","58",40,lArredBra,.F.})			//Aliquota de calculo do COFINS 2
aadd(aItemRef,{"IT_VALCF2","59",,.T.,GetNewPar("MV_RNDCF2",.F.)})			//Valor do COFINS 2
aadd(aItemRef,{"IT_ABVLINSS","60",,.F.,lCritArr})				//Abatimento da base do INSS em valor
aadd(aItemRef,{"IT_ABVLISS","61",,.F.,lCritArr})				//Abatimento da base do INSS em valor
aadd(aItemRef,{"IT_REDISS","62",,.F.,.F.})	 					//Reducao opcional de base do ISS
aadd(aItemRef,{"IT_ICMSDIF","63",,lArredBra,GetNewPar("MV_RNDICM",.F.)}) //Valor do ICMS diferido
aadd(aItemRef,{"IT_DESCZFPIS","64",,.T.,GetNewPar("MV_RNDPS2",.F.)})	 //Valor do PIS descontado - ZF
aadd(aItemRef,{"IT_DESCZFCOF","65",,.T.,GetNewPar("MV_RNDCF2",.F.)})	 //Valor do COFINS descontado - ZF
aadd(aItemRef,{"IT_BASEAFRMM","66",,lArredBra,lCritArr})		//Base de calculo do AFRMM
aadd(aItemRef,{"IT_ALIQAFRMM","67",,lArredBra,.F.})   			//Aliquota de calculo do AFRMM
aadd(aItemRef,{"IT_VALAFRMM","68",,lArredBra,lCritArr})		//Valor do AFRMM
aadd(aItemRef,{"IT_PIS252","69",,.F.,lCritArr})			 	//Valor do PIS Medida Provisoria 252
aadd(aItemRef,{"IT_COF252","70",,.F.,lCritArr})	 			//Valor da COFINS Medida Provisoria 252
aadd(aItemRef,{"IT_CRDZFM","71",,.F.,lCritArr})			 	//Credito Fiscal Presumido Zona Franca de Manaus
aadd(aItemRef,{"IT_CNAE","72",,.F.,.F.})	 					//Codigo da Atividade Economica da Prestacao de Servicos
aadd(aItemRef,{"IT_ITEM","73",,.F.,.F.})	 					//Numero do Item
aadd(aItemRef,{"IT_SEST","74",,.F.,.F.})			   			//Array contendo os valores do SEST
aadd(aItemRef,{"IT_BASESES",{74,1},,lArredBra,lCritArr})  		//Base de calculo do SEST
aadd(aItemRef,{"IT_ALIQSES",{74,2},,.F.,.F.}) 				//Aliquota de calculo do SEST
aadd(aItemRef,{"IT_VALSES",{74,3},,lArredBra,lCritArr})		//Valor do SEST do item
aadd(aItemRef,{"IT_BASEPS3","75",,lArredBra,lCritArr})			//Base de calculo do PIS Subst. Tributaria
aadd(aItemRef,{"IT_ALIQPS3","76",40,lArredBra,.F.})  			//Aliquota de calculo do PIS Subst. Tributaria
aadd(aItemRef,{"IT_VALPS3","77",,.T.,GetNewPar("MV_RNDPS3",.F.)}) 		//Valor do PIS Subst. Tributaria
aadd(aItemRef,{"IT_BASECF3","78",,lArredBra,lCritArr}) 		//Base de calculo da COFINS Subst. Tributaria
aadd(aItemRef,{"IT_ALIQCF3","79",40,lArredBra,.F.}) 			//Aliquota de calculo da COFINS Subst. Tributaria
aadd(aItemRef,{"IT_VALCF3","80",,.T.,GetNewPar("MV_RNDCF3",.F.)})		//Valor da COFINS Subst. Tributaria
aadd(aItemRef,{"IT_VLR_FRT","81",,.T.,lCritArr})				//Valor do Frete de Pauta
aadd(aItemRef,{"IT_BASEFET","82",,.T.,lCritArr})			 	//Base do FETHAB
aadd(aItemRef,{"IT_ALIQFET","83",,.T.,.F.})					//Aliquota do FETHAB
aadd(aItemRef,{"IT_VALFET","84",,.T.,lCritArr})	 			//Valor do FETHAB
aadd(aItemRef,{"IT_ABSCINS","85",,.F.,lCritArr}) 				//Abatimento do Valor do INSS em Valor - Subcontratada
aadd(aItemRef,{"IT_ABMATISS","87",,.F.,lCritArr}) 				//Abatimento da base do ISS referente ao material aplicado
aadd(aItemRef,{"IT_RGESPST","88",,.F.,.F.})	 				//Indica se a operacao, mesmo sem calculo de ICMS ST, faz parte do Regime Especial de Substituicao Tributaria
aadd(aItemRef,{"IT_PRFDSUL","89",,.F.,lCritArr}) 				//Percentual de UFERMS para o calculo do Fundersul - Mato Grosso do Sul
aadd(aItemRef,{"IT_UFERMS","90",,.F.,lCritArr}) 				//Valor da UFERMS para o calculo do Fundersul - Mato Grosso do Sul
aadd(aItemRef,{"IT_VALFDS","91",,.F.,lCritArr}) 				//91 - Valor do Fundersul - Mato Grosso do Sul

aadd(aCabRef,{"NF_TIPONF","1",.F.})
aadd(aCabRef,{"NF_OPERNF","2",.F.}) 			//E-Entrada | S - Saida
aadd(aCabRef,{"NF_CLIFOR","3",.F.})  			//C-Cliente | F - Fornecedor
aadd(aCabRef,{"NF_TPCLIFOR","4",.F.})  		//Tipo do destinatario R,F,S,X
aadd(aCabRef,{"NF_LINSCR","5",.F.})  			//Indica se o destino possui inscricao estadual
aadd(aCabRef,{"NF_GRPCLI","6",.F.})  			//Grupo de Tributacao
aadd(aCabRef,{"NF_UFDEST","7",.F.})  			//UF do Destinatario
aadd(aCabRef,{"NF_UFORIGEM","8",.F.})	 		//UF de Origem
aadd(aCabRef,{"NF_DESCONTO","10",.T.})			//Valor Total do Deconto
aadd(aCabRef,{"NF_FRETE","11",.T.}) 			//Valor Total do Frete
aadd(aCabRef,{"NF_DESPESA","12",.T.})			//Valor Total das Despesas Acessorias
aadd(aCabRef,{"NF_SEGURO","13",.T.}) 			//Valor Total do Seguro
aadd(aCabRef,{"NF_AUTONOMO","14",.T.})			//Valor Total do Frete Autonomo
aadd(aCabRef,{"NF_ICMS","15",.F.}) 			//Array contendo os valores de ICMS
aadd(aCabRef,{"NF_BASEICM",{15,1},.T.}) 		//Valor da Base de ICMS
aadd(aCabRef,{"NF_VALICM",{15,2},.T.})			//Valor do ICMS Normal
aadd(aCabRef,{"NF_BASESOL",{15,3},.T.})		//Base do ICMS Solidario
aadd(aCabRef,{"NF_VALSOL",{15,4},.T.})			//Valor do ICMS Solidario
aadd(aCabRef,{"NF_BICMORI",{15,5},.T.})		//Valor do ICMS Complementar
aadd(aCabRef,{"NF_VALCMP",{15,6},.T.})			//Valor do ICMS Complementar
aadd(aCabRef,{"NF_BASEICA",{15,7},.T.})   	  	//Base do ICMS sobre o Frete Autonomo
aadd(aCabRef,{"NF_VALICA",{15,8},.T.})    		//Valor do ICMS sobre o Frete Autonomo
aadd(aCabRef,{"NF_RECFAUT",{15,9},.T.})    	//Recolhimento do ICMS Autonomo - 1 - Emitente , 2 - Transportador
aadd(aCabRef,{"NF_IPI","16",.F.})  			//Array contendo os valores de IPI
aadd(aCabRef,{"NF_BASEIPI",{16,1},.T.})		//Valor da Base do IPI
aadd(aCabRef,{"NF_VALIPI",{16,2},.T.})			//Valor do IPI
aadd(aCabRef,{"NF_BIPIORI",{16,3},.T.})		//Valor da Base Original do IPI
aadd(aCabRef,{"NF_TOTAL","17",.T.})			//Valor Total da NF
aadd(aCabRef,{"NF_VALMERC","18",.T.})			//Valor Total das mercadorias
aadd(aCabRef,{"NF_FUNRURAL","19",.T.})   		//Valor Total do Funrural
aadd(aCabRef,{"NF_CODCLIFOR","20",.F.})		//Codigo do Cliente/Fornecedor
aadd(aCabRef,{"NF_LOJA","21",.F.})	      		//Loja do Cliente/Fornecedor
aadd(aCabRef,{"NF_LIVRO","22",.F.})   			//Array contendo os demonstrativos fiscais
aadd(aCabRef,{"NF_ISS","23",.F.}) 				//Array contendo os Valores de ISS
aadd(aCabRef,{"NF_BASEISS",{23,1},.T.})		//Base de Calculo do ISS
aadd(aCabRef,{"NF_VALISS",{23,2},.T.})			//Valor do ISS
aadd(aCabRef,{"NF_IR","24",.F.})		 		//Array contendo os valores do Imposto de renda
aadd(aCabRef,{"NF_BASEIRR",{24,1},.T.})		//Base do Imposto de Renda do item
aadd(aCabRef,{"NF_VALIRR",{24,2},.T.})			//Valor do IR do item
aadd(aCabRef,{"NF_INSS","25",.F.})				//Array contendo os valores de INSS
aadd(aCabRef,{"NF_BASEINS",{25,1},.T.})		//Base de calculo do INSS
aadd(aCabRef,{"NF_VALINS",{25,2},.T.})			//Valor do INSS do item
aadd(aCabRef,{"NF_NATUREZA","26",.F.})			//Natureza utilizada na geracao dos titulos no financeiro.
aadd(aCabRef,{"NF_VALEMB","27",.T.})			//Valor da Embalagem
aadd(aCabRef,{"NF_IMPOSTOS","30",.T.})			//Array contendo o resumo de Impostos
aadd(aCabRef,{"NF_BASEDUP","31",.T.})			//Array contendo o resumo de Impostos
aadd(aCabRef,{"NF_RELIMP","32",.F.})			//Array contendo o resumo de Impostos
aadd(aCabRef,{"NF_IMPOSTOS2","33",.T.})		//Array contendo o resumo de Impostos
aadd(aCabRef,{"NF_DESCZF","34",.T.})			//Valor total do Desconto da Zona Franca
aadd(aCabRef,{"NF_SUFRAMA","35",.T.})			//Valor total do Desconto da Zona Franca
aadd(aCabRef,{"NF_BASEIMP","36",.F.})			//Array contendo as Bases de Impostos Variaveis
For nG := 1 To NMAXIV
	aadd(aCabRef,{"NF_BASEIV"+NumCpoImpVar(nG),{36,nG},.T.})
Next nG
aadd(aCabRef,{"NF_VALIMP","37",.F.})   		//Array contendo os valores de Impostos Agentina/Chile/Etc.
For nG := 1 To NMAXIV
	aadd(aCabRef,{"NF_VALIV"+NumCpoImpVar(nG),{37,nG},.T.})
Next nG
aadd(aCabRef,{"NF_TPCOMP","38",.F.})    		//Tipo de complemento  - F Frete , D Despesa Imp.
aadd(aCabRef,{"NF_INSIMP","39",.F.})	  		//Flag de Controle : Indica se podera inserir Impostos no Rodape.
aadd(aCabRef,{"NF_PESO","40",.T.})  		    //Peso Total das mercadorias da NF
aadd(aCabRef,{"NF_ICMFRETE","41",.T.}) 		//Valor do ICMS relativo ao frete
aadd(aCabRef,{"NF_BSFRETE","42",.T.})   		//Base do ICMS relativo ao frete
aadd(aCabRef,{"NF_BASECOF","43",.T.})   		//Base de calculo do COFINS
aadd(aCabRef,{"NF_VALCOF","44",.T.})	  		//Valor do COFINS
aadd(aCabRef,{"NF_BASECSL","45",.T.})	  		//Base de calculo do CSLL
aadd(aCabRef,{"NF_VALCSL","46",.T.})	  		//Valor do CSLL
aadd(aCabRef,{"NF_BASEPIS","47",.T.})	  		//Base de calculo do PIS
aadd(aCabRef,{"NF_VALPIS","48",.T.})	  		//Valor do PIS
aadd(aCabRef,{"NF_AUXACUM","50",.T.})	  		//Acumulador para calculo de impostos
aadd(aCabRef,{"NF_ALIQIR","51",.T.})	  		//Aliquota de IRF do Cliente
aadd(aCabRef,{"NF_VNAGREG","52",.T.}) 		    //Valor da mercadoria nao agregado ao NF_VALMERC
aadd(aCabRef,{"NF_RECISS","56"})	             //Recolhe ISS
aadd(aCabRef,{"NF_MOEDA","58",.T.})	  	    //Moeda da nota fiscal
aadd(aCabRef,{"NF_TXMOEDA","59",.F.}) 		    //Taxa da moeda para a nota atual
aadd(aCabRef,{"NF_SERIENF","60",.F.}) 		    //Serie da nota fiscal
aadd(aCabRef,{"NF_TIPODOC","61",.F.}) 			//Tipo de documento (localizacoes)
aadd(aCabRef,{"NF_MINIMP","62",.F.}) 			//Minimo PARA CALCULAR IMPOSTOS VARIAVEIS
For nG := 1 To NMAXIV
	aadd(aCabRef,{"NF_MINIV"+NumCpoImpVar(nG),{62,nG},.T.})
Next
aadd(aCabRef,{"NF_BASEPS2","63",.T.})	        //Base de calculo do PIS 2
aadd(aCabRef,{"NF_VALPS2","64",.T.})	        //Valor do PIS 2
aadd(aCabRef,{"NF_ESPECIE","65",.F.})	        //Especie do Documento
aadd(aCabRef,{"NF_CNPJ","66",.F.})	        //CNPJ
aadd(aCabRef,{"NF_BASECF2","67",.T.})	        //Base de calculo do COFINS 2
aadd(aCabRef,{"NF_VALCF2","68",.T.})	        //Valor do COFINS 2
aadd(aCabRef,{"NF_ICMSDIF","69",.T.})	        //Valor do ICMS diferido
aadd(aCabRef,{"NF_MODIRF","70",.T.})	        //Modelo de calculo do IRPF
aadd(aCabRef,{"NF_PNF_COD",{71,01},.T.})	    //Codigo do tomador do Frete
aadd(aCabRef,{"NF_PNF_LOJ",{71,02},.T.})	    //Loja   do tomador do Frete
aadd(aCabRef,{"NF_PNF_UF" ,{71,03},.T.})	    //UF do tomador do Frete
aadd(aCabRef,{"NF_PNF_TPCLIFOR",{71,04},.T.})//Tipo do tomador do Frete
aadd(aCabRef,{"NF_BASEAFRMM","73",.T.})		//Base de calculo do AFRMM
aadd(aCabRef,{"NF_VALAFRMM","74",.T.})			//Valor do AFRMM
aadd(aCabRef,{"NF_PIS252","75",.T.})	        //Valor do PIS Medida Provisoria 252
aadd(aCabRef,{"NF_COF252","76",.T.})	        //Valor da COFINS Medida Provisoria 252
aadd(aCabRef,{"NF_BASESES",{78,1},.T.})		//Base de calculo do SEST
aadd(aCabRef,{"NF_VALSES",{78,2},.T.})			//Valor do SEST do item
aadd(aCabRef,{"NF_RECSEST","79",.T.})			//Recolhe SEST
aadd(aCabRef,{"NF_BASEPS3","80",.T.})	        //Base de calculo do PIS Subst. Tributaria
aadd(aCabRef,{"NF_VALPS3","81",.T.})	        //Valor do PIS Subst. Tributaria
aadd(aCabRef,{"NF_BASECF3","82",.T.})	        //Base de calculo da COFINS Subst. Tributaria
aadd(aCabRef,{"NF_VALCF3","83",.T.})	        //Valor da COFINS Subst. Tributaria
aadd(aCabRef,{"NF_VLR_FRT","84",.T.}) 			//Valor Total do Frete de Pauta
aadd(aCabRef,{"NF_VALFET","85",.T.}) 			//Valor do FETHAB
aadd(aCabRef,{"NF_RECFET","86",.T.}) 			//Recolhe FETHAB
aadd(aCabRef,{"NF_CLIENT","87",.F.}) 			//Recolhe FETHAB
aadd(aCabRef,{"NF_LOJENT","88",.F.}) 			//Recolhe FETHAB
aadd(aCabRef,{"NF_VALFDS","89",.T.}) 			//Valor do Fundersul - Mato Grosso do Sul

aadd(aResRef,{"IMP_COD",1})						// Codigo
aadd(aResRef,{"IMP_DESC",2})					// Descricao
aadd(aResRef,{"IMP_BASE",3})					// Base
aadd(aResRef,{"IMP_ALIQ",4})					// Aliquota
aadd(aResRef,{"IMP_VAL",5})						// Valor
aadd(aResRef,{"IMP_NOME",6})					// Nome

aadd(aLFis,{"LF_CFO",1})						// Codigo Fiscal
aadd(aLFis,{"LF_ALIQICMS",2})					// Aliquota de ICMS
aadd(aLFis,{"LF_VALCONT",3})					// Valor Contabil
aadd(aLFis,{"LF_BASEICM",4})					// Base de ICMS
aadd(aLFis,{"LF_VALICM",5})						// Valor do ICMS
aadd(aLFis,{"LF_ISENICM",6})					// ICMS Isento
aadd(aLFis,{"LF_OUTRICM",7})					// ICMS Outros
aadd(aLFis,{"LF_BASEIPI",8})					// Base de IPI
aadd(aLFis,{"LF_VALIPI",9})						// IPI Tributado
aadd(aLFis,{"LF_ISENIPI",10})					// IPI Isento
aadd(aLFis,{"LF_OUTRIPI",11})					// IPI Outros
aadd(aLFis,{"LF_OBSERV",12})					// Observacao
aadd(aLFis,{"LF_VALOBSE",13}) 					// Valor na Observacao
aadd(aLFis,{"LF_ICMSRET",14})					// Valor ICMS Retido
aadd(aLFis,{"LF_LANCAM",15})					// Numero do Lancamento
aadd(aLFis,{"LF_TIPO",16})						// Tipo de Lancamento
aadd(aLFis,{"LF_ICMSCOMP",17})					// ICMS Complementar
aadd(aLFis,{"LF_CODISS",18})					// Cod.Serv. ISS
aadd(aLFis,{"LF_IPIOBS",19})					// IPI na Observacao
aadd(aLFis,{"LF_NFLIVRO",20})					// Numero do Livro
aadd(aLFis,{"LF_ICMAUTO",21})					// ICMS Frete Autonomo
aadd(aLFis,{"LF_BASERET",22})					// Base do ICMS Retido
aadd(aLFis,{"LF_FORMUL",23})					// Flag de Fom. Proprio
aadd(aLFis,{"LF_FORMULA",24})					// Formula
aadd(aLFis,{"LF_DESPESA",25})					// Despesas Acessorias
aadd(aLFis,{"LF_ICMSDIF",26})					// Icms Diferido
aadd(aLFis,{"LF_TRFICM",27})					// Icms Transferido
aadd(aLFis,{"LF_OBSICM",28})	  // Icms na coluna de observacoes
aadd(aLFis,{"LF_OBSSOL",29})	  // Solidario na coluna de observacoes
aadd(aLFis,{"LF_SOLTRIB",30})	  // Valor do ICMS Solidario que possui tributacao com credito de imposto
aadd(aLFis,{"LF_CFOEXT",31})	  // Codigo Fiscal Extendido
aadd(aLFis,{"LF_ISSST",32})	  // Codigo Fiscal Extendido
aadd(aLFis,{"LF_RECISS",33})	  // Codigo Fiscal Extendido
aadd(aLFis,{"LF_ISSSUB",34})    // ISS de Sub-empreitada.
aadd(aLFis,{"LF_CREDST",36})    // Credito / Debito Substituição tributária.
aadd(aLFis,{"LF_CRDEST",37}) 					// Valor do Credito Estimulo Manaus
aadd(aLFis,{"LF_CRDPRES",38})   				// Valor do Credito Presumido
aadd(aLFis,{"LF_SIMPLES",39})  				    // Valor do ICMS para clientes optantes pelo Simples - SC
aadd(aLFis,{"LF_CRDTRAN",40})  					// Valor do Credito Presumido - RJ - Prestacao de Servico de Transporte
aadd(aLFis,{"LF_CFOEXT",31})  					// CFOP EXTENDIDO
aadd(aLFis,{"LF_CRDZFM",41})   					// Valor do Credito Presumido - Zona Franca de Manaus - Entradas Interestaduais
aadd(aLFis,{"LF_CNAE",42})   					// Codigo da Atividade Economica da Prestacao de Servicos
aadd(aLFis,{"LF_IDENT",43})   					// Codigo da Atividade Economica da Prestacao de Servicos
aadd(aLFis,{"LF_CLASFIS",44})                  //Classificacao fiscal (F4_SITTRIB+B1_ORIGEM)
aadd(aLFis,{"LF_CTIPI",45})	                    //Codigo Tributacao IPI
aadd(aLFis,{"LF_ESTOQUE",46})                  //Movimentacao fisica de estoque
aadd(aLFis,{"LF_DESPIPI",47})                  //IPI sobre despesas acessorias
aadd(aLFis,{"LF_POSIPI",48})                   //NCM Produto
aadd(aLFis,{"LF_OUTRRET",49})   //ICMS Retido escriturado coluna Outros
aadd(aLFis,{"LF_ISENRET",50})    //ICMS Retido escriturado coluna Isento
aadd(aLFis,{"LF_ITEMORI",51})    //Item da NF Origem
aadd(aLFis,{"LF_CFPS",52})    ////Codigo Fiscal de Prestacao de Servico
aadd(aLFis,{"LF_ALIQIPI",53})    ////Aliquota de IPI
aadd(aLFis,{"LF_CRPRST",54})    //valor Credito Presumido Substituicao Tributaria retido pelo contratante do servico de transporte - Decreto 44.147/2005 (MG)
aadd(aLFis,{"LF_TRIBRET",55})   //ICMS Retido escriturado coluna Tributado
aadd(aLFis,{"LF_DESCZFR",56})   //Desconto Zona Franca de Manaus
aadd(aLFis,{"LF_BASEPS3",57})   //Base PIS Subst. Tributaria
aadd(aLFis,{"LF_ALIQPS3",58})   //Aliquota do PIS Subst. Tributaria
aadd(aLFis,{"LF_VALPS3",59})    //Valor do PIS Subst. Tributaria
aadd(aLFis,{"LF_BASECF3",60})   //Base da Cofins Subst. Tributaria
aadd(aLFis,{"LF_ALIQCF3",61})   //Aliquota da da Cofins Subst. Tributaria
aadd(aLFis,{"LF_VALCF3",62})    //Valor da da Cofins Subst. Tributaria
aadd(aLFis,{"LF_CRPRELE",63})    ////Valor Credito Presumido sobre Saidas de Produtos Industrializados nos termos do Art. 2o, 2o-A e 7o do Decreto 4.316/1995 (BA)
aadd(aLFis,{"LF_ISSMAT",64})    //Valor do abatimento na base de calculo do ISS referente ao material aplicado
aadd(aLFis,{"LF_VALFDS",65}) 	//Valor do Fundersul - Mato Grosso do Sul

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaFisSave³ Autor ³ Edson Maricate         ³ Data ³ 10.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Salva a NF atual em uma area temporaria.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATXFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function MaFisSave()

If aMaster == Nil
	aMaster := {}
EndIf

aadd(aMaster,{aClone(aNfCab),;
	aClone(aSaveDec),;
	aClone(aNfItem),;
	aClone(aItemDec),;
	bFisRefresh,;
	bLivroRefresh,;
	aClone(aBrwLF),;
	aClone(aStack),;
	aClone(aSaveDec),;
	aClone(aAuxOri),;
	cAliasProd})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaFisRestore³ Autor ³ Edson Maricate      ³ Data ³ 10.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega a NF salva em uma area temporaia.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATXFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisRestore()

Local nUltimo := Len(aMaster)

aNfCab		 := aClone(aMaster[nUltimo][01])
aSaveDec	 := aClone(aMaster[nUltimo][02])
aNfItem		 := aClone(aMaster[nUltimo][03])
aItemDec	 := aClone(aMaster[nUltimo][04])
bFisRefresh  := aMaster[nUltimo][05]
bLivroRefresh:= aMaster[nUltimo][06]
aBrwLF	     := aClone(aMaster[nUltimo][07])
aStack		 := aClone(aMaster[nUltimo][08])
aSaveDev	 := aClone(aMaster[nUltimo][09])
aAuxOri		 := aClone(aMaster[nUltimo][10])
cAliasProd	 := aMaster[nUltimo][11]

aMaster      := aSize(aMaster,nUltimo-1)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaFisIniPC³ Autor ³ Edson Maricate        ³ Data ³20.05.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicializa as funcoes Fiscais com o Pedido de Compras      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MaFisIniPC(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Numero do Pedido                                  ³±±
±±³          ³ ExpC2 := Item do Pedido                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR110,MATR120,Fluxo de Caixa                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function MaFisIniPC(cPedido,cItem,cSequen,cFiltro)

Local aArea		:= GetArea()
Local aAreaSC7	:= SC7->(GetArea())
Local cValid	:= ""
Local nPosRef	:= 0
Local nItem		:= 0
Local cItemDe	:= IIf(cItem==Nil,'',cItem)
Local cItemAte	:= IIf(cItem==Nil,Repl('Z',Len(SC7->C7_ITEM)),cItem)
Local cRefCols	:= ''
DEFAULT cSequen:= ""
DEFAULT cFiltro:= ""

dbSelectArea("SC7")
dbSetOrder(1)
If	MsSeek(xFilial()+cPedido+cItemDe+Alltrim(cSequen))
	MaFisEnd()
	MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",{})
	While !Eof() .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial()+cPedido .AND. ;
			SC7->C7_ITEM <= cItemAte .AND. (Empty(cSequen) .OR. cSequen == SC7->C7_SEQUEN)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nao processar os Impostos se o item possuir residuo eliminado  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If &cFiltro
			dbSelectArea('SC7')
			dbSkip()
            Loop
        EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicia a Carga do item nas funcoes MATXFIS  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nItem++
		MaFisIniLoad(nItem)
		dbSelectArea("SX3")
		dbSetOrder(1)
		MsSeek('SC7')
		While !EOF() .AND. (X3_ARQUIVO == 'SC7')
			cValid	:= StrTran(UPPER(SX3->X3_VALID)," ","")
			cValid	:= StrTran(cValid,"'",'"')
			If "MAFISREF"$cValid
				nPosRef := AT('MAFISREF("',cValid) + 10
				cRefCols:=Substr(cValid,nPosRef,AT('","MT120",',cValid)-nPosRef )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega os valores direto do SC7.           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MaFisLoad(cRefCols,&("SC7->"+ SX3->X3_CAMPO),nItem)
			EndIf
			dbSkip()
		End
		MaFisEndLoad(nItem,2)
		dbSelectArea('SC7')
		dbSkip()
	End
EndIf

RestArea(aAreaSC7)
RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaFisRelImp³ Autor ³ Edson Maricate       ³ Data ³21.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array contendo todos os impostos suportados pelos³±±
±±³          ³arquivos passados para a funcao.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Codigo de referencia ao programa                    ³±±
±±³          ³ExpA2 : Array contendo o Alias dos arquivos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA103,MATA116,MATA119,MATA150,MATA120,MATA930             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisRelImp(cProg,aAlias)

Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())
Local aRet		:= {}
Local nAlias    := 0
Local nX        := 0	// controle de loop
Local nY        := 0

DEFAULT aRefSX3 := {}

For nX 	:= 1 to Len(aAlias)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o alias solicitado esta no cache de memoria  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nAlias := aScan(aRefSX3,{|x| x[1] == aAlias[nX]})
	If nAlias == 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona as referencia ao cache de memoria               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX3")
		dbSetOrder(1)
		MsSeek(aAlias[nX])
		While !EOF() .AND. (X3_ARQUIVO == aAlias[nX])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ajuste na referencia de impostos - SF2  v.508     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aAlias[nX]=="SF2"
				Do Case
				Case AllTrim(X3_CAMPO) == "F2_VALCSLL" .AND. !("MAFISREF"$UPPER(X3_VALID))
					RecLock("SX3",.F.)
					X3_VALID	:= 'MAFISREF("NF_VALCSL","MT100",M->F2_VALCSLL)'
					MsUnlock()
				Case AllTrim(X3_CAMPO) == "F2_VALCOFI" .AND. !("MAFISREF"$UPPER(X3_VALID))
					RecLock("SX3",.F.)
					X3_VALID	:= 'MAFISREF("NF_VALCOF","MT100",M->F2_VALCOFI)'
					MsUnlock()
				Case AllTrim(X3_CAMPO) == "F2_VALPIS" .AND. !("MAFISREF"$UPPER(X3_VALID))
					RecLock("SX3",.F.)
					X3_VALID	:= 'MAFISREF("NF_VALPIS","MT100",M->F2_VALPIS)'
					MsUnlock()
				Case cPaisLoc <> "BRA" .AND. AllTrim(X3_CAMPO) == "F2_TIPODOC" .AND. !("MAFISREF"$UPPER(X3_VALID))
					RecLock("SX3",.F.)
					X3_VALID	:= 'MAFISREF("NF_TIPODOC","MT100",M->F2_TIPODOC)'
					MsUnlock()
				Case cPaisLoc <> "BRA" .AND. AllTrim(X3_CAMPO) == "F2_SERIE" .AND. !("MAFISREF"$UPPER(X3_VALID))
					RecLock("SX3",.F.)
					X3_VALID	:= 'MAFISREF("NF_SERIENF","MT100",M->F2_SERIE)'
					MsUnlock()
				EndCase
			ElseIf aAlias[nX]=="SF1"
      		Do case
					Case AllTrim(X3_CAMPO) == "F1_VALCSLL" .AND. !("MAFISREF"$UPPER(X3_VALID))
						RecLock("SX3",.F.)
						X3_VALID	:= 'MAFISREF("NF_VALCSL","MT100",M->F1_VALCSLL)'
						MsUnlock()
					Case AllTrim(X3_CAMPO) == "F1_VALCOFI" .AND. !("MAFISREF"$UPPER(X3_VALID))
						RecLock("SX3",.F.)
						X3_VALID	:= 'MAFISREF("NF_VALCOF","MT100",M->F1_VALCOFI)'
						MsUnlock()
					Case AllTrim(X3_CAMPO) == "F1_VALPIS" .AND. !("MAFISREF"$UPPER(X3_VALID))
						RecLock("SX3",.F.)
						X3_VALID	:= 'MAFISREF("NF_VALPIS","MT100",M->F1_VALPIS)'
						MsUnlock()
					Case  cPaisLoc <> "BRA" .AND. AllTrim(X3_CAMPO) == "F1_SERIE" .AND. !("MAFISREF"$UPPER(X3_VALID))
						RecLock("SX3",.F.)
						X3_VALID	:= 'MAFISREF("NF_SERIENF","MT100",M->F1_SERIE)'
						MsUnlock()
					Case cPaisLoc <> "BRA" .AND. AllTrim(X3_CAMPO) == "F1_TIPODOC" .AND. !("MAFISREF"$UPPER(X3_VALID))
						RecLock("SX3",.F.)
						X3_VALID	:= 'MAFISREF("NF_TIPODOC","MT100",M->F1_TIPODOC)'
						MsUnlock()
				EndCase
			EndIf
			If "MAFISREF"$AllTrim(UPPER(SX3->X3_VALID))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cria o Array contendo a relacao Campo x Referencia ³
				//³ [RELIMP] : [1] - Alias                             ³
				//³            [2] - Campo                             ³
				//³            [3] - Referencia                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aadd(aRefSX3,{aAlias[nX],AllTrim(X3_CAMPO),MaFisGetRF(SX3->X3_VALID)[1]})
			EndIf
			dbSelectArea("SX3")
			dbSkip()
		End
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem as referencias do cache de memoria                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nY := 1 To Len(aRefSX3)
		If aRefSx3[nY][1] == aAlias[nX]
			aadd(aRet,{aAlias[nX],aRefSx3[nY][2],aRefSx3[nY][3]})
		EndIf
	Next nY
Next nX
RestArea(aAreaSX3)
RestArea(aArea)

Return aRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaColsToFi³ Autor ³Edson Maricate         ³ Data ³01.02.1999 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina carregamento da funcao fiscal com base no acols e     ³±±
±±³          ³aheader                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Variavel com a estrutura do aHeader                   ³±±
±±³          ³ExpA2: Variavel com a estrutura do aCols                     ³±±
±±³          ³ExpN3: Item a ser carregado                             (OPC)³±±
±±³          ³ExpC4: Nome do programa                                 (OPC)³±±
±±³          ³ExpL5: Indica se o recalculo dos impostos deve ser feito(OPC)³±±
±±³          ³ExpL6: Indica se o recalculo dos impostos deve ser feito(OPC)³±±
±±³          ³ExpL7: Indica se o recalculo vai considerar as linhs apagadas³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo inicializar a variavel aNFItem ³±±
±±³          ³com base no aCols                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaColsToFis(aHeader,aCols,nItem,cProg,lRecalc,lVisual,lDel,lSoItem)

Local nX       := 0	//conrole de loop
Local nY       := 0	//conrole de loop
Local cValid   := ""
Local nItemIni := IIf(nItem==Nil,1,nItem)
Local nItemAte := IIf(nItem==Nil,Len(aCols),nItem)

DEFAULT lRecalc 	:= .F.
DEFAULT lVisual	:= .F.
DEFAULT lDel		:= .F.	//Indica que a linha deletada do acols nao sera considerada
DEFAULT lSoItem	:=	.F.

If nItem == Nil
	MaFisClear()
EndIf

For nY := nItemIni to nItemAte
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia a Carga do item nas funcoes MATXFIS  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisIniLoad(nY,,.T.)
	For nX	:= 1 To Len(aHeader)
		cValid	:= AllTrim(UPPER(aHeader[nX][6]))
		cRefCols := MaFisGetRf(cValid)[1]
		If !Empty(cRefCols) .AND. MaFisFound("IT",nY)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega os valores direto do SD1.           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaFisLoad(cRefCols,aCols[nY][nX],nY)
		EndIf
	Next nX
	If lRecalc
		MaFisRecal("IT_",nY)
		For nX	:= 1 To Len(aHeader)
			cValid	:= AllTrim(UPPER(aHeader[nX][6]))
			cRefCols := MaFisGetRf(cValid)[1]
			If !Empty(cRefCols) .AND. MaFisFound("IT",nY)
				aCols[nY][nX]:= MaFisRet(nY,cRefCols)
			EndIf
		Next nX
	EndIf
	MaFisEndLoad(nY,Iif(lVisual,3,If(lSoItem,2,Nil)))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a execucao da rotina considerar os itens deletados, executa a MAFISDEL³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lDel .AND. aCols[nY][Len(aHeader)+1]
		MaFisDel(nY,.T.)
	Endif

Next nY

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaFisToCols³ Autor ³ Edson Maricate       ³ Data ³ 01.02.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza os valores do aCols com os valores da Funcao Fiscal³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisToCols(aHeader,aCols,nItem,cProg)

Local nX        := 0	//controle de loop
Local nY        := 0	//controle de loop

Local nItemIni	:= IIf(nItem==Nil,1,nItem)
Local nItemAte	:= IIf(nItem==Nil,Len(aCols),nItem)

For nY := nItemIni to nItemAte
	For nX	:= 1 to Len(aHeader)
		cValid	:= AllTrim(UPPER(aHeader[nX][6]))
		cRefCols := MaFisGetRF(cValid)[1]
		If !Empty(cRefCols) .AND. MaFisFound("IT",nY)
			aCols[nY][nX]:= MaFisRet(nY,cRefCols)
		EndIf
	Next nX
Next nY
Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaFisGet³ Autor ³ Edson Maricate          ³ Data ³ 01.02.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao utilizada no Pedido de Vendas ( Exclusivamente ) para³±±
±±³          ³criar a referencia do campo no tratamento fiscal.           ³±±
±±³          ³Obs.: nao executa o calculo do imposto, apenas utiliza o    ³±±
±±³          ³      valor informado na preparacao da Nota Fiscal.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA410,MATA461                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisGet(cReferencia)

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaFisOrdem³ Autor ³ Edson Maricate        ³ Data ³ 01.02.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a ordem utilizada pela rotina de calculo de impostos³±±
±±³          ³da referencia solicitada.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA461, Esta ordem e utilizada na rotina de Geracao de NF  ³±±
±±³          ³         de Saida permitindo que os impostos informados no  ³±±
±±³          ³         SC6 atraves da Funcao MaFisGet() nao sejam recal-  ³±±
±±³          ³         culados pela Funcao Fiscal.                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisOrdem(cReferencia)
Local nPos
Local nOrdem := 10000

If aItemRef == Nil
	MaIniRef()
EndIf

If Substr(cReferencia,1,2) == "IT"
	nPos	:= aScan(aItemRef,{|x|x[1]==cReferencia})
	If nPos > 0 .AND. aItemRef[nPos][3]<>Nil
		nOrdem	:= aItemRef[nPos][3]
	EndIf
EndIf

Return nOrdem


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisBSIV³ Autor ³ Edson Maricate         ³ Data ³02.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa o calculo da Base dos Impostos Variaveis            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Numero do Imposto ( 1 a X )                          ³±±
±±³          ³ExpN2: Item a ser calculado                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisBSIV(nImposto,nItem)
Local nBaseRet
Local nImp     := Len(aTes[TS_SFC])
Local nImpde   := IIF(nImposto==Nil,1,nImposto)
Local nImpAte  := IIF(nImposto==Nil,nImp,nImposto)

Private aInfo   //Definida como private pois é usada numa macro    := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a TES possui tratamento para Impostos Variaveis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aTes[TS_SFC])
	If nImpde>0 .AND. nImpAte>0
		For nImposto := nImpDe to nImpAte
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa o calculo atraves da Funcao cadastrada no SFB        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aInfo := {aTes[TS_SFC][nImposto][SFC_IMPOSTO],RIGHT(Alltrim(aTes[TS_SFC][nImposto][SFB_CPOVREI]),1)}
			nImp:=NumCpoImpVar(aInfo[2])
			If aNfCab[NF_OPERNF] == "E"
				If !Empty(aTes[TS_SFC][nImposto][SFB_FORMENT])
					If cPaisLoc <> "BRA"
						nBaseRet := &(aTes[TS_SFC][nImposto][SFB_FORMENT]+'("B",'+Str(nItem)+',aInfo)')
						If ValType(nBaseRet) == "N"
							aNfItem[nItem][IT_BASEIMP][nImp]:= nBaseRet
						EndIf
					Else
						aNfItem[nItem][IT_BASEIMP][nImp]:= ExecBlock(aTes[TS_SFC][nImposto][SFB_FORMENT],.F.,.F.,{"B",nItem,aInfo},(Left(aTes[TS_SFC][nImposto][SFB_FORMENT],2)=="U_"))
					EndIf
					aNfItem[nItem][IT_DESCIV][nImp] := {aTes[TS_SFC][nImposto][SFC_IMPOSTO],aTes[TS_SFC][nImposto][SFB_DESCR],aTes[TS_SFC][nImposto][SFC_CALCULO]}
				EndIf
			Else
				If !Empty(aTes[TS_SFC][nImposto][SFB_FORMSAI])
					If cPaisLoc <> "BRA"
						nBaseRet :=  &(aTes[TS_SFC][nImposto][SFB_FORMSAI]+'("B",'+Str(nItem)+',aInfo)')
						If ValType(nBaseRet) == "N"
							aNfItem[nItem][IT_BASEIMP][nImp]:= nBaseRet
						EndIf
					Else
						aNfItem[nItem][IT_BASEIMP][nImp]:= ExecBlock(aTes[TS_SFC][nImposto][SFB_FORMSAI],.F.,.F.,{"B",nItem,aInfo},(Left(aTes[TS_SFC][nImposto][SFB_FORMENT],2)=="U_"))
					EndIf
					aNfItem[nItem][IT_DESCIV][nImp] := {aTes[TS_SFC][nImposto][SFC_IMPOSTO],aTes[TS_SFC][nImposto][SFB_DESCR],aTes[TS_SFC][nImposto][SFC_CALCULO]}
				EndIf
			EndIf
		Next nImposto
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Zera todas as aliquotas.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nImposto := 1 to NMAXIV
		aNFItem[nItem][IT_BASEIMP][nImposto]:= 0
		aNfItem[nItem][IT_DESCIV][nImposto] := {"","",""}
	Next nImposto
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisVLIV³ Autor ³ Edson Maricate         ³ Data ³02.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa o calculo do Valor dos Impostos Variaveis           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Numero do Imposto ( 1 a X )                          ³±±
±±³          ³ExpN2: Item a ser calculado                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisVLIV(nImposto,nItem)

Local nValImp  := 0
Local nImp		:=Len(aTes[TS_SFC])
Local nImpde 	:=IIF(nImposto==Nil,1,nImposto)
Local nImpAte	:=IIF(nImposto==Nil,nImp,nImposto)

Private aInfo   									//Definida como private pois é usada numa macro
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a TES possui tratamento para Impostos Variaveis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aTes[TS_SFC])
	If nImpde>0 .AND. nImpAte>0
		For nImposto := nImpDe to nImpAte
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa o calculo atraves da Funcao cadastrada no SFB        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aInfo := {aTes[TS_SFC][nImposto][SFC_IMPOSTO],RIGHT(Alltrim(aTes[TS_SFC][nImposto][SFB_CPOVREI]),1)}
			nImp:=NumCpoImpVar(aInfo[2])
			If aNfCab[NF_OPERNF] == "E"
				If !Empty(aTes[TS_SFC][nImposto][SFB_FORMENT])
					If cPaisLoc <> "BRA"
						nValImp :=  &(aTes[TS_SFC][nImposto][SFB_FORMENT]+'("V",'+Str(nItem)+',aInfo)')
						If ValType(nValImp) == "N"
							aNfItem[nItem][IT_VALIMP][nImp]:= nValImp
						EndIf
					Else
						aNfItem[nItem][IT_VALIMP][nImp]:= ExecBlock(aTes[TS_SFC][nImposto][SFB_FORMENT],.F.,.F.,{"V",nItem,aInfo},(Left(aTes[TS_SFC][nImposto][SFB_FORMENT],2)=="U_"))
					EndIf
				EndIf
			Else
				If !Empty(aTes[TS_SFC][nImposto][SFB_FORMSAI])
					If cPaisLoc <>"BRA"
						nValImp :=  &(aTes[TS_SFC][nImposto][SFB_FORMSAI]+'("V",'+Str(nItem)+',aInfo)')
						If ValType(nValImp) == "N"
							aNfItem[nItem][IT_VALIMP][nImp]:= nValImp
						EndIf
					Else
						aNfItem[nItem][IT_VALIMP][nImp]:= ExecBlock(aTes[TS_SFC][nImposto][SFB_FORMSAI],.F.,.F.,{"V",nItem,aInfo},(Left(aTes[TS_SFC][nImposto][SFB_FORMENT],2)=="U_"))
					EndIf
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica as Propriedades do Imposto                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Do Case
			Case aTes[TS_SFC][nImposto][SFC_INCDUPL]=="1"
				nValImp:=aNfItem[nItem][IT_VALIMP][nImp]
			Case aTes[TS_SFC][nImposto][SFC_INCDUPL]=="2"
				nValImp:=-aNfItem[nItem][IT_VALIMP][nImp]
			Case aTes[TS_SFC][nImposto][SFC_INCDUPL]=="3"
				nValImp:=0
			EndCase
			aNfItem[nItem][IT_BASEDUP] += nValImp
			Do Case
			Case aTes[TS_SFC][nImposto][SFC_INCNOTA]=="1"
				nValImp:=aNfItem[nItem][IT_VALIMP][nImp]
			Case aTes[TS_SFC][nImposto][SFC_INCNOTA]=="2"
				nValImp:=-aNfItem[nItem][IT_VALIMP][nImp]
			Case aTes[TS_SFC][nImposto][SFC_INCNOTA]=="3"
				nValImp:=0
			EndCase
			aNfItem[nItem][IT_TOTAL] += nValImp
		Next nImposto
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Zera todas as aliquotas.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nImposto := 1 to NMAXIV
		aNFItem[nItem][IT_VALIMP][nImposto]:= 0
	Next nImposto
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisAliqIV³ Autor ³ Edson Maricate       ³ Data ³02.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa o calculo da Aliquota dos Impostos Variaveis        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Numero do Imposto ( 1 a 6 )                          ³±±
±±³          ³ExpN2: Item a ser calculado                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisAliqIV(nImposto,nItem)

Local nAliqImp
Local nImp	  :=Len(aTes[TS_SFC])
Local nImpde  :=IIF(nImposto==Nil,1,nImposto)
Local nImpAte :=IIF(nImposto==Nil,nImp,nImposto)

Private aInfo 									  //Definida como private pois é usada numa macro
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a TES possui tratamento para Impostos Variaveis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aTes[TS_SFC])
	If nImpde>0 .AND. nImpAte>0
		For nImposto := nImpDe to nImpAte
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa o calculo atraves da Funcao cadastrada no SFB        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aInfo := {aTes[TS_SFC][nImposto][SFC_IMPOSTO],RIGHT(Alltrim(aTes[TS_SFC][nImposto][SFB_CPOVREI]),1)}
			nImp:=NumCpoImpVar(aInfo[2])
			If aNfCab[NF_OPERNF] == "E"
				If !Empty(aTes[TS_SFC][nImposto][SFB_FORMENT])
					If cPaisLoc <> "BRA"
						nAliqImp :=  &(aTes[TS_SFC][nImposto][SFB_FORMENT]+'("A",'+Str(nItem)+',aInfo)')
						If ValType(nAliqImp) == "N"
							aNfItem[nItem][IT_ALIQIMP][nImp]:= nAliqImp
						EndIf
					Else
						aNfItem[nItem][IT_ALIQIMP][nImp]:= ExecBlock(aTes[TS_SFC][nImposto][SFB_FORMENT],.F.,.F.,{"A",nItem,aInfo},(Left(aTes[TS_SFC][nImposto][SFB_FORMENT],2)=="U_"))
					EndIf
				EndIf
			Else
				If !Empty(aTes[TS_SFC][nImposto][SFB_FORMSAI])
					If cPaisLoc <>"BRA"
						nAliqImp :=  &(aTes[TS_SFC][nImposto][SFB_FORMSAI]+'("A",'+Str(nItem)+',aInfo)')
						If ValType(nAliqImp) == "N"
							aNfItem[nItem][IT_ALIQIMP][nImp]:= nAliqImp
						EndIf
					Else
						aNfItem[nItem][IT_ALIQIMP][nImp]:= ExecBlock(aTes[TS_SFC][nImposto][SFB_FORMSAI],.F.,.F.,{"A",nItem,aInfo},(Left(aTes[TS_SFC][nImposto][SFB_FORMENT],2)=="U_"))
					EndIf
				EndIf
			EndIf
		Next nImposto
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Zera todas as aliquotas.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nImposto := 1 to NMAXIV
		aNFItem[nItem][IT_ALIQIMP][nImposto]:= 0
	Next nImposto
EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisNameIV³ Autor ³ Edson Maricate       ³ Data ³02.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preeche o nome dos impostos Variaveis                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Numero do Imposto ( 1 a 6 )                          ³±±
±±³          ³ExpN2: Item a ser calculado                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisNameIV(nImposto,nItem)

Local nImpde  := IIf(nImposto==Nil,1,nImposto)
Local nImpAte := IIF(nImposto==Nil,Len(aTes[TS_SFC]),nImposto)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a TES possui tratamento para Impostos Variaveis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aTes[TS_SFC])
	If nImpde>0 .AND. nImpAte>0
		For nImposto := nImpDe to nImpAte
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa o calculo atraves da Funcao cadastrada no SFB        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If	aNfCab[NF_OPERNF] == "E"
				If !Empty(aTes[TS_SFC][nImposto][SFB_FORMENT])
					nImp:=NumCpoImpVar(RIGHT(Alltrim(aTes[TS_SFC][nImposto][SFB_CPOVREI]),1))
					aNfItem[nItem][IT_DESCIV][nImp] := {aTes[TS_SFC][nImposto][SFC_IMPOSTO],aTes[TS_SFC][nImposto][SFB_DESCR],aTes[TS_SFC][nImposto][SFC_CALCULO]}
				EndIf
			Else
				If !Empty(aTes[TS_SFC][nImposto][SFB_FORMSAI])
					nImp:=NumCpoImpVar(RIGHT(Alltrim(aTes[TS_SFC][nImposto][SFB_CPOVRSI]),1))
					aNfItem[nItem][IT_DESCIV][nImp] := {aTes[TS_SFC][nImposto][SFC_IMPOSTO],aTes[TS_SFC][nImposto][SFB_DESCR],aTes[TS_SFC][nImposto][SFC_CALCULO]}
				EndIf
			EndIf
		Next nImposto
	Endif
Else
	For nImposto := 1 to NMAXIV
		aNfItem[nItem][IT_DESCIV][nImposto] := {"","",""}
	Next nImposto
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisLF2³ Autor ³ Edson Maricate          ³ Data ³02.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se o TES possui RdMake para geracao/complemento    ³±±
±±³          ³dos Livros Fiscais                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Numero do Item                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisLF2(nItem)

If !Empty(aTes[TS_LIVRO]) .AND. cPaisLoc == "BRA"
	aNfItem[nItem][IT_LIVRO] := ExecBlock(aTes[TS_LIVRO],.F.,.F.,{aNfItem[nItem][IT_LIVRO],nItem})
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaAvalTes³ Autor ³ Edson Maricate         ³ Data ³02.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se o TES pode ser utilizada na operacao.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Tipo de movimentacao - E Entrada ou Saida            ³±±
±±³          ³ExpC2: Codigo da TES                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaAvalTes(cOperacao,cTes)
Local lRet := .T.

Do Case
Case cOperacao == "E"
	If SubStr(cTes,1,1) >= "5" .AND. cTES <> "500"
		HELP("   ",1,"INV_TE")
		lRet := .F.
	EndIf
Case cOperacao == "S"
	If !SubStr(cTes,1,1) >= "5" .OR. cTES == "500"
		HELP("   ",1,"INV_TS")
		lRet := .F.
	EndIf
EndCase

Return lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaRecImp³ Autor ³ Edson Maricate          ³ Data ³02.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna array com todos os impostos recuperaveis do Item    ³±±
±±³          ³da NF.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Numero do Item                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: [1] -                                                ³±±
±±³          ³       [2] -                                                ³±±
±±³          ³       [3] -                                                ³±±
±±³          ³       [4] -                                                ³±±
±±³          ³       [5] -                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaRecImp()

Local aArea		:= GetArea()

dbSelectArea("SF4")
dbSetOrder(1)
MsSeek(xFilial()+SD1->D1_TES)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os impostos padroes da NF                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SD1->D1_VALICM <> 0

EndIf
RestArea(aArea)
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisVldAlt³ Autor ³ Edson Maricate       ³ Data ³02.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica a referencia e se a mesma pode ser alterada.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Referencia                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisVldAlt(cReferencia,nItem)
Local lRet := .T.

If cPaisLoc == "BRA"
	Do Case
	Case aNfCab[NF_TIPONF] == "I" .AND. ;
			Alltrim(cReferencia)$"IT_BASEICM#NF_BASEICM#IT_VALICM#NF_VALICM#IT_QUANT#IT_PRCUNI"
		HELP("   ",1,"COMPICM")
		lRet := .F.
	Case aNfCab[NF_TIPONF] == "P" .AND. ;
			AllTrim(cReferencia)$"IT_BASEIPI#NF_BASEIPI#IT_VALIPI#NF_VALIPI#IT_QUANT#IT_PRCUNI"
		HELP("   ",1,"COMPIPI")
		lRet := .F.
	Case aNfCab[NF_TIPONF] == "C" .AND. ;
			AllTrim(cReferencia)$"IT_QUANT#IT_PRCUNI"
		HELP("   ",1,"COMPPRC")
		lRet := .F.
	EndCase
Else
	If nItem <> NIL .AND. !Empty(aNfItem[nItem][IT_REMITO]) .AND. Alltrim(cReferencia)$"IT_PRODUTO"
		HELP("   ",1,"LOCXNF0003")
		lRet := .F.
	Endif
Endif

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaFisLFToLivro³ Autor ³ Edson Maricate    ³ Data ³07.03.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Adiciona o item nos livros fiscais                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATXFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static FUNCTION MaFisLFToLivro(nItem,aNotasOri,lSoma)

Local aGetBook := {}
Local aSFB     := {}
Local aSFC     := {}
Local aSF4     := {}
Local nLF      := 0
Local nY       := 0
Local nX       := 0
Local nS	   := 0
Local dDataEmi	:=	dDataBase
Local cAux     := ""
Local	lImport	:=	(Type("lFacImport")=="L" .AND.lFacImport)
DEFAULT lSoma := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o array aTes para o correta definicao das observacoes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaFisTes(aNfItem[nItem,IT_TES],aNfItem[nItem,IT_RECNOSF4],nItem)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem dos Livros Fiscals ( aLivro )                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc=="BRA"
	If 	aNfItem[nItem][IT_LIVRO][3] +;
			aNfItem[nItem][IT_LIVRO][4] +;
			aNfItem[nItem][IT_LIVRO][5] +;
			aNfItem[nItem][IT_LIVRO][6] +;
			aNfItem[nItem][IT_LIVRO][7] +;
			aNfItem[nItem][IT_LIVRO][9] +;
			aNfItem[nItem][IT_LIVRO][10]+;
			aNfItem[nItem][IT_LIVRO][11] <>0 .OR. !Empty(aNfItem[nItem][IT_LIVRO][24])

		If aNfItem[nItem][IT_CALCISS] == "S"
			nLF	:= aScan(aNfCab[NF_LIVRO],{|x|x[LF_CFO]==aNfItem[nItem][IT_LIVRO][LF_CFO] .AND.;
												x[LF_CODISS]==aNfItem[nItem][IT_LIVRO][LF_CODISS] .AND.;
												x[LF_ALIQICMS]==aNfItem[nItem][IT_LIVRO][LF_ALIQICMS] .AND.;
												x[LF_NFLIVRO]==aNfItem[nItem][IT_LIVRO][LF_NFLIVRO] .AND.;
												x[LF_FORMULA]==aNfItem[nItem][IT_LIVRO][LF_FORMULA] .AND.;
												x[LF_CFPS]==aNfItem[nItem][IT_LIVRO][LF_CFPS]})

		Else
			nLF	:= aScan(aNfCab[NF_LIVRO],{|x|x[LF_CFO]==aNfItem[nItem][IT_LIVRO][LF_CFO] .AND. ;
				x[LF_CFOEXT]==aNfItem[nItem][IT_LIVRO][LF_CFOEXT] .AND. x[LF_ALIQICMS]==aNfItem[nItem][IT_LIVRO][LF_ALIQICMS] ;
				.AND. x[LF_NFLIVRO]==aNfItem[nItem][IT_LIVRO][LF_NFLIVRO] .AND. x[LF_FORMULA]==aNfItem[nItem][IT_LIVRO][LF_FORMULA] ;
				.AND. x[LF_CODISS]==aNfItem[nItem][IT_LIVRO][LF_CODISS];
				.AND. x[LF_CFPS]==aNfItem[nItem][IT_LIVRO][LF_CFPS]})
		EndIf
		If nLF == 0
			aNotasOri:= {}
			aadd(aNfCab[NF_LIVRO],MaFisRetLF())
			nLF	:= Len(aNfCab[NF_LIVRO])
			aNfCab[NF_LIVRO][nLF][LF_CFO] 		:= aNfItem[nItem][IT_LIVRO][LF_CFO]
			aNfCab[NF_LIVRO][nLF][LF_CFOEXT]   := aNfItem[nItem][IT_LIVRO][LF_CFOEXT]
			aNfCab[NF_LIVRO][nLF][LF_ALIQICMS] := aNfItem[nItem][IT_LIVRO][LF_ALIQICMS]
			aNfCab[NF_LIVRO][nLF][LF_NFLIVRO] 	:= aNfItem[nItem][IT_LIVRO][LF_NFLIVRO]
			aNfCab[NF_LIVRO][nLF][LF_FORMULA] 	:= aNfItem[nItem][IT_LIVRO][LF_FORMULA]
			aNfCab[NF_LIVRO][nLF][LF_TIPO]		:= aNfItem[nItem][IT_LIVRO][LF_TIPO]
			aNfCab[NF_LIVRO][nLF][LF_CODISS]	:= aNfItem[nItem][IT_LIVRO][LF_CODISS]
			aNfCab[NF_LIVRO][nLF][LF_FORMUL]	:= aNfItem[nItem][IT_LIVRO][LF_FORMUL]
			aNfCab[NF_LIVRO][nLF][LF_ISSST]		:= aNfItem[nItem][IT_LIVRO][LF_ISSST]
			aNfCab[NF_LIVRO][nLF][LF_RECISS]	:= aNfItem[nItem][IT_LIVRO][LF_RECISS]
			aNfcab[NF_LIVRO][nLF][LF_CREDST]   := aNfItem[nItem][IT_LIVRO][LF_CREDST]
			aNfcab[NF_LIVRO][nLF][LF_CNAE]     := aNfItem[nItem][IT_LIVRO][LF_CNAE]
			aNfcab[NF_LIVRO][nLF][LF_IDENT]    := StrZero(nLF,6)
			aNfCab[NF_LIVRO][nLF][LF_CFPS]     := aNfItem[nItem][IT_LIVRO][LF_CFPS]
			aNfCab[NF_LIVRO][nLF][LF_ALIQIPI]  := aNfItem[nItem][IT_LIVRO][LF_ALIQIPI]
			aNfCab[NF_LIVRO][nLF][LF_ALIQCF3]  := aNfItem[nItem][IT_LIVRO][LF_ALIQCF3]
			aNfCab[NF_LIVRO][nLF][LF_ALIQPS3]  := aNfItem[nItem][IT_LIVRO][LF_ALIQPS3]
		EndIf
		For nY	:= 1 to Len(aNfCab[NF_LIVRO][nLf])
			If !AllTrim(StrZero(nY,2))$"01#02#12#15#16#18#20#23#24#31#32#33#36#42#43#44#45#46#47#48#51#52#53#58#61"
				If lSoma
					If Valtype(aNfItem[nItem][IT_LIVRO][nY])<>"A"
						aNfCab[NF_LIVRO][nLF][nY] += aNfItem[nItem][IT_LIVRO][nY]
					Else
						For nS := 1 To Len(aNfCab[NF_LIVRO][nLF][nY])
							aNfCab[NF_LIVRO][nLF][nY][nS] += aNfItem[nItem][IT_LIVRO][nY][nS]
						Next nS
					EndIf
				Else
					If Valtype(aNfItem[nItem][IT_LIVRO][nY])<>"A"
						aNfCab[NF_LIVRO][nLF][nY] -= aNfItem[nItem][IT_LIVRO][nY]
					Else
						For nS := 1 To Len(aNfCab[NF_LIVRO][nLF][nY])
							aNfCab[NF_LIVRO][nLF][nY][nS] += aNfItem[nItem][IT_LIVRO][nY][nS]
						Next nS
					EndIf
				EndIf
			EndIf
		Next nY
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Preenche a Observacao dos livros Fiscais                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNfCab[NF_LIVRO][nLF][LF_OBSERV]   		:= MaFisObserv(aNfCab[NF_LIVRO][nLF][LF_OBSERV],nItem,@aNotasOri)
		aNfItem[nItem][IT_LIVRO][LF_OBSERV]   	:= MaFisObserv(aNfCab[NF_LIVRO][nLF][LF_OBSERV],nItem,@aNotasOri)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Zera a coluna outras caso esteja menor que zero            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNfCab[NF_LIVRO,nLF,LF_OUTRICM] := Max(aNfCab[NF_LIVRO,nLF,LF_OUTRICM],0)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Vinculo do item do livro com o cabecalho                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNfcab[NF_LIVRO][nLF][LF_IDENT]       := StrZero(nLF,6)
		aNfItem[nItem][IT_LIVRO][LF_IDENT]    := StrZero(nLF,6)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclusao dos itens sem valor                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If 	aNfCab[NF_LIVRO][nLF][3] +;
				aNfCab[NF_LIVRO][nLF][4]+;
				aNfCab[NF_LIVRO][nLF][5]+;
				aNfCab[NF_LIVRO][nLF][6]+;
				aNfCab[NF_LIVRO][nLF][7]+;
				aNfCab[NF_LIVRO][nLF][9]+;
				aNfCab[NF_LIVRO][nLF][10]+;
				aNfCab[NF_LIVRO][nLF][11] == 0 .AND. Empty(aNfCab[NF_LIVRO][nLF][LF_FORMULA])
			aDel(aNfCab[NF_LIVRO],nLF)
			aSize(aNfCab[NF_LIVRO],Len(aNfCab[NF_LIVRO])-1)
		EndIf
	EndIf
Else
	aSF4:=SF4->(GetArea())
	aSFB:=SFB->(GetArea())
	aSFC:=SFC->(GetArea())
	SFC->(DbSetOrder(2))
	SFB->(DbSetOrder(1))
	SF4->(DbSetOrder(1))
	SF4->(MsSeek(xFilial("SF4")+aNfItem[nItem][IT_TES]))
	aImpVar:=Array(7)
	aImpVar[1] := aNfItem[nItem][IT_QUANT]
	If MaFisRet(,'NF_OPERNF') == 'E' .OR. SuperGetMV('MV_DESCSAI')='2'
		aImpVar[2] := (aNfItem[nItem][IT_VALMERC]-aNfItem[nItem][IT_DESCONTO])/Max(aNfItem[nItem][IT_QUANT],1)
		aImpVar[3] := aNfItem[nItem][IT_VALMERC]-aNfItem[nItem][IT_DESCONTO]
	Else
		aImpVar[2] := aNfItem[nItem][IT_PRCUNI]
		aImpVar[3] := aNfItem[nItem][IT_VALMERC]
	Endif
	aImpVar[4] := aNfItem[nItem][IT_FRETE]
	aImpVar[5] := aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO]
	aImpVar[6] := {}
	aImpVar[7] := ""
	MaFisTes(aNfItem[nItem][IT_TES],aNfItem[nItem][IT_RECNOSF4],nItem)
	For nY := 1 to Len(aTes[TS_SFC])
		If (cPaisLoc <> "ARG".OR. aTes[TS_SFC][nY][SFC_IMPOSTO]<> "DUM") //Ignmorar o DUMMY
			nImp:=NumCpoImpVar(RIGHT(Alltrim(aTes[TS_SFC][nY][SFB_CPOVREI]),1))
			aadd(aImpVar[6],Array(17))
			nX:=Len(aImpVar[6])
			aImpVar[6][nX][1] :=aNfItem[nItem][IT_PRODUTO]
			aImpVar[6][nX][2] :=aNfItem[nItem][IT_ALIQIMP][nImp]
			aImpVar[6][nX][3] :=aNfItem[nItem][IT_BASEIMP][nImp]
			aImpVar[6][nX][4] :=aNfItem[nItem][IT_VALIMP][nImp]
			If (lImport)
				SD1->(MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+aNfItem[nItem][IT_PRODUTO]))
				If SF1->F1_TIPO_NF$"5678"
					SYD->(MsSeek(xFilial("SYD")+SD1->D1_TEC))
					SFC->(MsSeek(xFilial("SFC")+SYD->YD_TES+aTes[TS_SFC][nY][SFC_IMPOSTO]))
				Else
					If SuperGetMV("MV_DESPSD1",,"N")=="S"
						SFC->(MsSeek(xFilial("SFC")+SD1->D1_TESDES+aTes[TS_SFC][nY][SFC_IMPOSTO]))
					Else
						SYD->(MsSeek(xFilial("SYD")+SD1->D1_TEC))
						SFC->(MsSeek(xFilial("SFC")+SYD->YD_TES+aTes[TS_SFC][nY][SFC_IMPOSTO]))
					Endif
				Endif
				SFB->(MsSeek(xFilial("SFB")+aTes[TS_SFC][nY][SFC_IMPOSTO]))
				cAux:=SFC->FC_INCDUPL+SFC->FC_INCNOTA+SFC->FC_CREDITA
				If IsAlpha(SFC->FC_INCDUPL)
					aImpVar[6][nX][5]:=IIf(Subs(cAux,1,2)=="SN".OR.Subs(cAux,1,2)=="NS","3",;
						IIf(Subs(cAux,1,2)=="SS","1","2"))
					aImpVar[6][nX][5]+=IIf(Subs(cAux,2,1)=="S" ,"1",IIf(Subs(cAux,2,1)=="R" ,"2","3"))
					aImpVar[6][nX][5]+=IIf(Subs(cAux,2,2)=="SN","1",IIf(Subs(cAux,2,2)=="NS","2","3"))
				Else
					aImpVar[6][nX][5]:=cAux
				EndIf
				aImpVar[6][nX][17]:=SFB->FB_CPOLVRO
			Else
				aImpVar[6][nX][5]:=	aTes[TS_SFC][nY][SFC_INCDUPL]+	aTes[TS_SFC][nY][SFC_INCNOTA]+	aTes[TS_SFC][nY][SFC_CREDITA]
				aImpVar[6][nX][17]:=Right(aTes[TS_SFC][nY][SFB_CPOVREI],1)
			Endif
		Endif
	Next nY
	If Type('dDEmissao') == "D" .AND. !Empty(dDEmissao)
		dDataEmi	:=	dDEmissao
	Endif
	aNfCab[NF_LIVRO]	:=	GetBook(@aGetBook,aImpVar,If(aNfCab[NF_CLIFOR]=="C","V","C"),If(Type("nTaxa")=="N",nTaxa,If(Type("nTXMoeda")=="N",nTXMoeda,1)),aNfCab[NF_LIVRO],aNfCab[NF_OPERNF],lSoma,,,,,,dDataEmi)
	RestArea(aSF4)
	RestArea(aSFB)
	RestArea(aSFC)
EndIf
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaFisConsFin()³ Autor ³ Edson Maricate    ³ Data ³07.03.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o e o destino e um Consumidor Final            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATXFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MaFisConsFin()
Local lRet := .F.

If aNfCab[NF_OPERNF] == "S"
	lRet := aNfCab[NF_TPCLIFOR] == "F"
Else
	lRet := SM0->M0_PRODRUR == "F"
EndIf

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaFisConsumo()³ Autor ³ Edson Maricate    ³ Data ³07.03.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o e material de consumo.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATXFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MaFisConsumo(nItem)
Local lRet := .F.

IF aTes[TS_CONSUMO] == " "
	If (aTes[TS_INCIDE] == "S"  .OR. (aTes[TS_INCIDE] == "F" .AND. aNFCab[NF_TPCLIFOR] =="F" .AND. aNFCab[NF_CLIFOR] =="C")) .AND.;
			( Substr(aNfItem[nItem][IT_CF],2,3)$"91 /92 /97 " .OR. (Substr(aNfItem[nItem][IT_CF],2,2) $ "55" .AND. Substr(aNfItem[nItem][IT_CF],4,1)<>" "))
		lRet := .T.
	Endif
Else
	lRet := aTes[TS_CONSUMO] == "S"
Endif

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaFisObserv   ³ Autor ³ Edson Maricate    ³ Data ³07.03.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define mensagem de observacao a ser gravada no F3_OBSERV   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATXFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static FUNCTION MaFisObserv(cObservAnt,nItem,aNotasOri)

Local  cNFOri := IIf(!empty(aNfItem[nItem][IT_NFORI]),aNfItem[nItem][IT_NFORI]+"/"+aNfItem[nItem][IT_SERORI],"")
Local  cMsg   := ""
Local  cMVCSS := GetNewPar("MV_IMPCSS","S") // Parametro de Impressao da Contr.Seg.Social

If !Empty(cNFOri) .AND. aScan(aNotasOri,cNFOri)==0
	aadd(aNotasOri,cNFOri)
EndIf

cNFOri := IIf(Len(aNotasOri)>1,STR0009,cNFOri) //"DIVERSAS"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para alteracao da mensagem quanto a devolucao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( aNotasOri )
	If ExistBlock( "MAFISOBS" )
		cNFOri := ExecBlock( "MAFISOBS", .F., .F., { cNfOri, AClone( aNotasOri ) } )
	EndIf
EndIf

Do Case
Case aNfCab[NF_TIPONF]=="D"
	cMsg:=IIf(!empty(cNFOri),STR0011+cNFOri,"") //"DEVOLUCAO N.F.:"
Case aNfCab[NF_TIPONF]=="C" .AND. aNfCab[NF_TPCOMP] == "F"
	cMsg:= STR0012 //"CONHEC. FRETE"
Case aNfCab[NF_TIPONF]=="C" .AND. aNfCab[NF_TPCOMP] == "D"
	cMsg:= STR0013 //"NF DESPESA"
Case aNfCab[NF_TIPONF]=="C"
	If !Empty(aNfCab[NF_ESPECIE])
		cMsg:=STR0014+"("+aNfCab[NF_ESPECIE]+")"+cNFOri //"COMPL.N.F.: "
	Else
		cMsg:=STR0014+cNFOri //"COMPL.N.F.: "
	EndIf
Case aNfCab[NF_TIPONF]=="B".AND.aTes[TS_PODER3]<>"R"
	cMsg:=IIf(!empty(cNFOri),STR0015+cNFOri,"") //"N.F.ORIG.: "
Case aNfCab[NF_TIPONF]=="P"
	cMsg:=STR0016+cNFOri //"COMPL.IPI N.F.: "
Case aNfCab[NF_TIPONF]=="I"
	If "CIAP" $ Upper(cNFORi)
		cMsg := ""
	Else
		cMsg:=IIF(aTes[TS_ISS]<>"N",STR0022,STR0017)+cNFOri //"COMPL.ICMS N.F.: " OU "COMPL.ISS N.F.: "
	EndIf
Case aNfCab[NF_TPCLIFOR]=="X" .AND. aNfCab[NF_OPERNF]=="S"
	cMsg:=""
	If !Empty(cNFOri)
	   cMsg:=STR0018+cNFOri //"EXPORTACAO-GE No.: "
	Endif
Case aTes[TS_IPI]=="R"
	cMsg:=STR0019 //"AQUIS.COMERC.NAO-CONTRIB.IPI"
Case aNfCab[NF_TIPONF]=="N".AND.aTes[TS_PODER3] == "D"
	cMsg:=Iif(!Empty(cNfOri),(STR0020+cNFOri),"") //"Dev. Benef. N.F.ORIG.: "
Case aNfCab[NF_FUNRURAL]>0
	If cMVCSS == "S" // Imprime Contribuicao Seguridade Social
		cMsg:=STR0021+Alltrim(Transform(aNfCab[NF_FUNRURAL],"@E 999,999,999.99")) //"CONT.SEG.SOCIAL: "
	Endif
EndCase

Return (cMsg)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MaSBCampo()  ³ Autor ³ Cesar Valadao     ³ Data ³11/09/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o Conteudo do Campo Dependendo do Alias Informado. ³±±
±±³          ³ O Front Loja Utiliza o Arquivo SBI Como Arq. de Produtos.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATXFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MaSBCampo(cNome)
Local cCampo    := Right(cAliasPROD,2)+"_"+cNome
Local cAlias    := cAliasPROD
Local nPosCampo := 0
Local xValor    := Nil
Local aArea     := GetArea()
Local cDadosProd:=SuperGetMV("MV_ARQPROD",.F.,"SB1")

If cAlias == "SB1" .And. cDadosProd == "SBZ" .And. cNome $ ("PICM/IPI")
	// Se existir registro no SBZ (Indicadores de Produtos) busca aliquotas de ICMS e IPI desta tabela
	dbSelectArea("SBZ")
	SBZ->(dbSetOrder(1)) 	//BZ_FILIAL+BZ_PRODUTO
	If (SBZ->(dbSeek(xFilial("SBZ")+SB1->B1_COD))) .And. ( SBZ->(FieldPos("BZ_"+cNome )) > 0 ) .And. SBZ->(FieldGet(FieldPos("BZ_"+cNome))) > 0
		xValor := SBZ->(FieldGet(FieldPos("BZ_"+cNome)))
    Else
		xValor := (cAlias)->(FieldGet(FieldPos(cCampo)))
	EndIf
Else
	If (cAlias)->(FieldPos(cCampo))>0
		xValor := (cAlias)->(FieldGet(FieldPos(cCampo)))
	Else
		If !Empty( nPosCampo := SB1->(FieldPos("B1_"+cNome ) ) )
			xValor := SB1->( FieldGet( nPosCampo ) )
		EndIf
	EndIf
EndIf


Restarea(aArea)
Return(xValor)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaALIQCOF³ Autor ³ Edson Maricate         ³ Data ³04.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a aliquota para calculo do COFINS.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaALIQCOF(nItem)

Local aArea		 := GetArea()
Local aRelImp	 := {}
Local aRelImp2	 := {}

Local nAliquota  := 0
Local nAliqProd  := 0
Local nPsAlCOFSa := 0
Local nPsAlCOFEt := 0
Local nScanCOF   := 0

Local cCpAlCOFSa := ""
Local cCpAlCOFEt := ""

Local lMaCalcCOF := ExistBlock("MaCalcCOF")
Local aMaCalcCOF := {}

If lMaCalcCOF
	aMaCalcCOF := ExecBlock("MaCalcCOF")
EndIf

nAliqProd := MaSBCampo("PCOFINS")
nAliquota := IIf(Empty(nAliqProd),SuperGetMv("MV_TXCOFIN"),nAliqProd)

If ( aNFCab[NF_TIPONF] $"DB" ) .OR. aTes[TS_PODER3] == "D"

	aRelImp  := MaFisRelImp("MT100",{ "SD1" })
	aRelImp2 := MaFisRelImp("MT100",{ "SD2" })

	If !Empty( nScanCOF := aScan(aRelImp2,{|x| x[1]=="SD2" .AND. x[3]=="IT_ALIQCF2"} ) )
		cCpAlCOFSa := aRelImp2[nScanCOF,2]
		nPsAlCOFSa := SD2->( FieldPos( cCpAlCOFSa ) )
	EndIf

	If !Empty( nScanCOF := aScan(aRelImp ,{|x| x[1]=="SD1" .AND. x[3]=="IT_ALIQCF2"} ) )
		cCpAlCOFEt := aRelImp[nScanCOF,2]
		nPsAlCOFEt := SD1->( FieldPos( cCpAlCOFEt ) )
	EndIf

	If aNFCab[NF_TIPONF] $ "DB"
		If !Empty(aNFItem[nItem][IT_RECORI])
			If ( aNFCab[NF_CLIFOR] == "C" )
				dbSelectArea("SD2")
				MsGoto( aNFItem[nItem][IT_RECORI] )
				If nPsAlCOFSa > 0
					nAliquota  := SD2->( FieldGet( nPsAlCOFSa ) )
				EndIf
			Else
				dbSelectArea("SD1")
				MsGoto( aNFItem[nItem][IT_RECORI] )
				If nPsAlCOFEt > 0
					If !Empty( SD1->( FieldGet( nPsAlCOFEt ) ) ) .OR. SD1->D1_EMISSAO >= CTOD( "01/02/2004" )
						nAliquota  := SD1->( FieldGet( nPsAlCOFEt ) )
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		If !Empty(aNFItem[nItem][IT_RECORI])
			If ( aNFCab[NF_CLIFOR] == "C" )
				dbSelectArea("SD1")
				MsGoto( aNFItem[nItem][IT_RECORI] )
				If nPsAlCOFEt > 0
					nAliquota  := SD1->( FieldGet( nPsAlCOFEt ) )
				Endif
			Else
				dbSelectArea("SD2")
				MsGoto( aNFItem[nItem][IT_RECORI] )
				If nPsAlCOFSa > 0
					nAliquota  := SD2->( FieldGet( nPsAlCOFSa ) )
				Endif
			EndIf
		EndIf
	EndIf
EndIf

If !( Empty(aNFitem[nItem,IT_EXCECAO]))
	If aNFItem[nItem,IT_EXCECAO,13] <> 0
		nAliquota := aNFItem[nItem,IT_EXCECAO,13]
	Endif
Endif

aNfItem[nItem][IT_ALIQCF2]	:= nAliquota

If (lMaCalcCof .AND. aMaCalcCOF[1]=="S") .OR. (!Empty(aNfCab[NF_NATUREZA]) .AND. SED->ED_CALCCOF=="S")
	If ( Empty(nAliqProd) .AND. !Empty(If(lMaCalcCOF,aMaCalcCOF[2],SED->ED_PERCCOF) ) ) .OR. GetNewPar( "MV_TPALCOF", "2" ) == "1"
		nAliquota := If(lMaCalcCOF,aMaCalcCOF[2],SED->ED_PERCCOF)
	EndIf
	aNfItem[nItem][IT_ALIQCOF]	:= nAliquota
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo da COFINS de Subst. Tributaria³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aTES[TS_PSCFST] == "1"
	aNfItem[nItem][IT_ALIQCF3] := nAliquota
Else
	aNfItem[nItem][IT_ALIQCF3] := 0
Endif

RestArea(aArea)
Return(nAliquota)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaALIQCSL³ Autor ³ Edson Maricate         ³ Data ³04.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a aliquota para calculo do CSLL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaALIQCSL(nItem)

Local aArea		 := GetArea()
Local nAliquota := 0

Local lMaCalcCSL := ExistBlock("MaCalcCSL")
Local aMaCalcCSL := {}

If lMaCalcCSL
	aMaCAlcCSL := ExecBlock("MaCalcCSL")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega aliquota do cadastro de produtos                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nAliquota := MaSBCampo("PCSLL")

If (lMaCalcCSL .AND. aMaCalcCSL[1]=="S") .OR. (!Empty(aNfCab[NF_NATUREZA]) .AND. SED->ED_CALCCSL=="S")
	If (Empty( nAliquota ) .AND. !Empty(If(lMaCalcCSL,aMaCalcCSL[2],SED->ED_PERCCSL))) .OR. GetNewPar( "MV_TPALCSL", "2" ) == "1"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso exista da natureza, carrega da natureza               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nAliquota := If(lMaCalcCSL,aMaCalcCSL[2],SED->ED_PERCCSL)
	EndIf
EndIf

If aNfItem[nItem][IT_TIPONF]=="D"
	nAliquota := 0
EndIf

aNfItem[nItem][IT_ALIQCSL]	:= nAliquota

RestArea(aArea)

Return(nAliquota)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaALIQPIS³ Autor ³ Edson Maricate         ³ Data ³04.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a aliquota para calculo do PIS.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MaALIQPIS(nItem)

Local aArea		 := GetArea()
Local aRelImp	 := {}
Local aRelImp2	 := {}

Local nAliquota  := 0
Local nAliqProd  := 0
Local nPsAlPisSa := 0
Local nPsAlPisEt := 0
Local nScanPis   := 0

Local cCpAlPisSa := ""
Local cCpAlPisEt := ""

Local lMaCalcPIS := ExistBlock("MaCalcPIS")
Local aMaCalcPIS := {}

If lMaCalcPIS
	aMaCalcPIS := ExecBlock("MaCalcPIS")
EndIf

nAliqProd := MaSBCampo("PPIS")
nAliquota := IIf(Empty(nAliqProd),SuperGetMv("MV_TXPIS"),nAliqProd)

If ( aNFCab[NF_TIPONF] $"DB" ) .OR. aTes[TS_PODER3] == "D"

	aRelImp  := MaFisRelImp("MT100",{ "SD1" })
	aRelImp2 := MaFisRelImp("MT100",{ "SD2" })

	If !Empty( nScanPis := aScan(aRelImp2,{|x| x[1]=="SD2" .AND. x[3]=="IT_ALIQPS2"} ) )
		cCpAlPisSa := aRelImp2[nScanPis,2]
		nPsAlPisSa := SD2->( FieldPos( cCpAlPisSa ) )
	EndIf

	If !Empty( nScanPis := aScan(aRelImp ,{|x| x[1]=="SD1" .AND. x[3]=="IT_ALIQPS2"} ) )
		cCpAlPisEt := aRelImp[nScanPis,2]
		nPsAlPisEt := SD1->( FieldPos( cCpAlPisEt ) )
	EndIf

	If aNFCab[NF_TIPONF] $ "DB"
		If !Empty(aNFItem[nItem][IT_RECORI])
			If ( aNFCab[NF_CLIFOR] == "C" )
				dbSelectArea("SD2")
				MsGoto( aNFItem[nItem][IT_RECORI] )
				If nPsAlPisSa > 0
					nAliquota  := SD2->( FieldGet( nPsAlPisSa ) )
				Endif
			Else
				dbSelectArea("SD1")
				MsGoto( aNFItem[nItem][IT_RECORI] )
				If nPsAlPisEt > 0
					nAliquota  := SD1->( FieldGet( nPsAlPisEt ) )
				Endif
			EndIf
		EndIf
	Else
		If !Empty(aNFItem[nItem][IT_RECORI])
			If ( aNFCab[NF_CLIFOR] == "C" )
				dbSelectArea("SD1")
				MsGoto( aNFItem[nItem][IT_RECORI] )
				If nPsAlPisEt > 0
					nAliquota  := SD1->( FieldGet( nPsAlPisEt ) )
				Endif
			Else
				dbSelectArea("SD2")
				MsGoto( aNFItem[nItem][IT_RECORI] )
				If nPsAlPisSa > 0
					nAliquota  := SD2->( FieldGet( nPsAlPisSa ) )
				Endif
			EndIf
		EndIf
	EndIf
Endif

If !( Empty(aNFitem[nItem,IT_EXCECAO]))
	If aNFItem[nItem,IT_EXCECAO,12] <> 0
		nAliquota := aNFItem[nItem,IT_EXCECAO,12]
	Endif
Endif

aNfItem[nItem][IT_ALIQPS2]	:= nAliquota

If (lMaCalcPIS .AND. aMaCalcPIS[1]=="S") .OR. (!Empty(aNfCab[NF_NATUREZA]) .AND. SED->ED_CALCPIS=="S")
	If ( Empty(nAliqProd) .AND. !Empty(If(lMaCalcPIS,aMaCalcPIS[2],SED->ED_PERCPIS)) ) .OR. GetNewPar( "MV_TPALPIS", "2" ) == "1"
		nAliquota := If(lMaCalcPIS,aMaCalcPIS[2],SED->ED_PERCPIS)
	EndIf
	aNfItem[nItem][IT_ALIQPIS]	:= nAliquota
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do PIS de Subst. Tributaria³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aTES[TS_PSCFST] == "1"
	aNfItem[nItem][IT_ALIQPS3] := nAliquota
Else
	aNfItem[nItem][IT_ALIQPS3] := 0
Endif

RestArea(aArea)
Return(nAliquota)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisBsCOF³ Autor ³ Edson Maricate        ³ Data ³04.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o base de Caluculo do COFINS .                      ³±±
±±³          ³ExpC1: Tipo : 1-Apuracao / 2-Retencao / 3-Ambos ( padrao )  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisBSCOF(nItem,cTipo)

Local cDebSTCOF     := GetNewPar("MV_DBSTCOF","1")

Local nBaseCOF	  := 0
Local nRedBsCOF	  := MaSBCampo("REDCOF")
Local nFatRedCOF  := 1
Local nDesconto   := aNfItem[nItem][IT_DESCONTO]

Local lMaCalcCOF := ExistBlock("MaCalcCOF")
Local aMaCalcCOF := {}

Local cCofBru	 := GetNewPar("MV_COFBRU","2")

DEFAULT cTipo      := "3"

If lMaCalcCOF
	aMaCalcCOF := ExecBlock("MaCalcCOF")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso retorne corretamente a reducao, calcula o fator       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT nRedBsCOF := 0
If nRedBsCOF <> 0
	nFatRedCOF	:= If( nRedBsCOF>0,1-nRedBsCOF/100,1)
EndIf
nRedBsCOF := aTES[TS_BASECOF]/100
If nRedBsCOF <> 0
	nFatRedCOF	*= If( nRedBsCOF>0,1-nRedBsCOF,1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe reducao na base de calculo pela excecao fiscal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aNFitem[nItem][IT_EXCECAO])
	If aNfItem[nItem,IT_EXCECAO,19] > 0
		nRedBsCOF	:= 0
		nFatRedCOF	:= 1
		nRedBsCOF := aNfItem[nItem,IT_EXCECAO,19] / 100
		If nRedBsCOF <> 0
			nFatRedCOF	*= If( nRedBsCOF>0,1-nRedBsCOF,1)
		EndIf
	Endif
Endif

If cTipo $ "13"
	If aTES[TS_PISCRED] <> "3" .AND. aTES[TS_PISCOF]$"23" .AND. !( aNfItem[nItem][IT_TIPONF] $ "I|P" )
		If Empty( aNfItem[nItem][IT_ALIQCF2] )
			nBaseCOF := 0
			aNfItem[nItem][IT_BASECF2] := nBaseCOF
		Else
			If MaSbCampo("VLR_COF")==Nil .Or. MaSbCampo("VLR_COF")==0 .Or. (!Empty(aNFitem[nItem][IT_EXCECAO]) .And. Empty(aNfItem[nItem][IT_EXCECAO][11])) .Or.;
				aNfItem[nItem,IT_QUANT]==0 .Or. GetNewPar("MV_COFPAUT",.T.)

				If aTes[TS_COFBRUT] == "1"
					nDesconto := 0
				Endif

				nBaseCOF := aNfItem[nItem][IT_VALMERC]-IIf(aTes[TS_AGREG]$"D",aNfItem[nItem][IT_DEDICM],0)

				If aTes[TS_AGREG] == "I"
					nBaseCOF += If(aNFitem[nItem][IT_TIPONF ]<>"I",aNfItem[nItem][IT_VALICM],0)
				EndIf
				nBaseCOF := ( nBaseCOF - nDesconto + aNfItem[nItem][IT_DESCZFCOF] + aNfItem[nItem][IT_DESCZFPIS] + IIf(aNfItem[nItem][IT_DESCZFCOF]<>0,0,aNfItem[nitem][IT_VALSOL]) )

				If !(aNfCab[NF_CLIFOR]=='C'.AND.aNfCab[NF_CALCSUF]$'SI'.AND.!aNFitem[nItem][IT_TIPONF ]$'BD'.AND.;
					 aTes[TS_ISS]<>"S" .AND. GetNewPar("MV_DESCZF",.T.) .AND. GetNewPar("MV_DESZFPC",.F.)) .OR.;
  				     GetNewPar("MV_FRTBASE",.F.)
					nBaseCOF += aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO] + aNfItem[nItem][IT_FRETE]
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso seja comerciante atacadista, o valor do IPI deve ser retirado da base de calculo do COFINS ³
				//³ pois esta embutido no valor da mercadoria                                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				If aTes[TS_CREDICM] == "S" .AND. SuperGetMV("MV_DEDBCOF") $ "S,I"
					nBaseCOF -= aNfItem[nItem][IT_VALICM]
				EndIf
				If aTes[TS_CREDIPI] == "N" .AND. SuperGetMV("MV_DEDBCOF") $ "S,P" .AND. aTes[TS_IPI] <> "R"
					nBaseCOF += aNfItem[nItem][IT_VALIPI]
				EndIf
				If aTes[TS_CREDIPI] == "S" .AND. SuperGetMV("MV_DEDBCOF") $ "S,P" .AND. aTes[TS_IPI] == "R"
					nBaseCOF -= aNfItem[nItem][IT_VALIPI]
				EndIf


				If aTes[TS_COFDSZF] == "2"
					nBaseCOF += aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFCOF] + aNfItem[nItem][IT_DESCZFPIS])
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Indica o tratamento para retirada do valor do ICMS solidario na base do PIS apurado    ³
				//³ 1 - Nunca retira                                                                       ³
				//³ 2 - Retira se houver credito do ICMS ST                                                ³
				//³ 3 - Retira se nao houver credito do ICMS ST                                            ³
				//³ 4 - Retira se houver credito do ICMS normal                                            ³
				//³ 5 - Retira se nao houver credito do ICMS normal                                        ³
				//³ 6 - Sempre retira                                                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cDebSTCOF == "6" .OR. ;
					( aTes[TS_CREDST]  == "1" .AND. cDebSTCOF == "2" ) .OR. ;
					( aTes[TS_CREDST]  == "2" .AND. cDebSTCOF == "3" ) .OR. ;
					( aTes[TS_CREDICM] == "S" .AND. cDebSTCOF == "4" ) .OR. ;
					( aTes[TS_CREDICM] == "N" .AND. cDebSTCOF == "5" ) ) .AND. aNfItem[nItem][IT_DESCZFCOF] == 0
					nBaseCof -= aNfItem[nitem][IT_VALSOL]
				Endif

				nBaseCOF *= nFatRedCOF
				aNfItem[nItem][IT_BASECF2] := nBaseCOF
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula o valor da pauta pela base                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (Empty(aNFitem[nItem,IT_EXCECAO]) .Or. Empty(aNFItem[nItem,IT_EXCECAO,11]))
					nBaseCOF := aNfItem[nItem,IT_QUANT] * MaSBCampo( "VLR_COF" )
				Else
					nBaseCOF := aNfItem[nItem,IT_QUANT] * aNFItem[nItem,IT_EXCECAO,11]
				EndIf
				aNfItem[nItem][IT_BASECF2] := nBaseCOF
			EndIf
		EndIf
	Else
		nBaseCOF := 0
		aNfItem[nItem][IT_BASECF2] := nBaseCOF
	EndIf

EndIf

If cTipo $ "23"
	If (lMaCalcCof .AND. aMaCalcCOF[1]=="S") .OR. (!Empty(aNfCab[NF_NATUREZA]) .AND. SED->ED_CALCCOF=="S" .AND. aNfCab[NF_RECCOFI] $ "S|P" .AND. ( MaSBCampo("COFINS")==Nil .OR. MaSBCampo("COFINS")=="1" .OR. aNfCab[NF_RECCOFI] == "P" )	)
		nBaseCOF := aNfItem[nItem,IT_BASEDUP]+IIf(cCofBru=="1",nDesconto,0)
		nBaseCOF *= nFatRedCOF


		//Tratamento extraido da funcao MaFisVTot para saber se foi contemplado o VALOR DE IPI na base da duplicata para que eu possa subtrair
		If (aTes[TS_IPIPC]=="2") .AND. (aNFitem[nItem][IT_TIPONF]=="P" .OR. aTes[TS_IPI]<>'R')
			nBaseCOF -= aNfItem[nItem][IT_VALIPI]
		EndIf

		aNfItem[nItem][IT_BASECOF] := nBaseCOF
	Else
		aNfItem[nItem][IT_BASECOF] := 0
	EndIf

EndIf

Return( nBaseCOF )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisBsCSL³ Autor ³ Edson Maricate        ³ Data ³04.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o base de Calculo do CSL .                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisBSCSL(nItem)

Local lMaCalcCSL := ExistBlock("MaCalcCSL")
Local aMaCalcCSL := {}
Local nDesconto  := aNfItem[nItem][IT_DESCONTO]
Local cCSLLBru	 := GetNewPar("MV_CSLLBRU","2")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso o parametro indique a base de calculo pelo valor bruto da nota fiscal,³
//³somar o valor do desconto concedido ao total da duplicata.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCSLLBru <> "1"
	nDesconto := 0
Endif

If lMaCalcCSL
	aMaCAlcCSL := ExecBlock("MaCalcCSL")
EndIf

If ((lMaCalcCSL .AND. aMaCalcCSL[1]=="S") .OR. (!Empty(aNfCab[NF_NATUREZA]) .AND. SED->ED_CALCCSL=="S")) .AND. aNfItem[nItem][IT_TIPONF]<>"D" .AND.;
		( aNfCab[NF_RECCSLL] $ "S|P" ) .AND. ( MaSBCampo("CSLL")==Nil .OR. MaSBCampo("CSLL")=="1" .OR. aNfCab[NF_RECCSLL] == "P" )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A base de calculo da retencao eh o valor da duplicata      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aNfItem[nItem][IT_BASECSL] := aNfItem[nItem,IT_BASEDUP] + Iif(aNfItem[nItem,IT_BASEDUP] > 0,nDesconto,0)
Else
	aNfItem[nItem][IT_BASECSL] := 0
EndIf

Return(aNfItem[nItem][IT_BASECSL])

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisBsPIS³ Autor ³ Edson Maricate        ³ Data ³04.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o base de Caluculo do PIS .                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±³          ³ExpC1: Tipo : 1-Apuracao / 2-Retencao / 3-Ambos ( padrao )  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MaFisBSPIS(nItem,cTipo)

Local cDebSTPIS     := GetNewPar("MV_DBSTPIS","1")

Local nBasePis	 := 0
Local nRedBsPis	 := MaSBCampo("REDPIS")
Local nFatRedPis := 1
Local nDesconto  := aNfItem[nItem][IT_DESCONTO]

Local lMaCalcPIS := ExistBlock("MaCalcPIS")
Local aMaCalcPIS := {}

Local cPisBru	:= GetNewPar("MV_PISBRU","2")

DEFAULT cTipo    := "3"

If lMaCalcPIS
	aMaCalcPIS := ExecBlock("MaCalcPIS")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso retorne corretamente a reducao, calcula o fator       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT nRedBsPIS := 0
If nRedBsPIS <> 0
	nFatRedPis	:= If( nRedBsPis>0,1-nRedBsPis/100,1)
EndIf
nRedBsPis := aTES[TS_BASEPIS]/100
If nRedBsPIS <> 0
	nFatRedPis	*= If( nRedBsPis>0,1-nRedBsPis,1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe reducao na base de calculo pela excecao fiscal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aNFitem[nItem][IT_EXCECAO])
	If aNfItem[nItem,IT_EXCECAO,18] > 0
		nRedBsPis	:= 0
		nFatRedPis	:= 1
		nRedBsPis	:= aNfItem[nItem,IT_EXCECAO,18] / 100
		If nRedBsPIS <> 0
			nFatRedPis	*= If( nRedBsPis>0,1-nRedBsPis,1)
		EndIf
	Endif
Endif

If cTipo $ "13"
	If aTES[TS_PISCRED] <> "3" .AND. aTES[TS_PISCOF]$"13" .AND. !( aNfItem[nItem][IT_TIPONF] $ "I|P" )
		If Empty( aNfItem[nItem][IT_ALIQPS2] )
			nBasePis := 0
			aNfItem[nItem][IT_BASEPS2] := nBasePis
		Else
			If MaSbCampo("VLR_PIS")==Nil .Or. MaSbCampo("VLR_PIS")==0 .Or. (!Empty(aNFitem[nItem][IT_EXCECAO]) .And. Empty(aNfItem[nItem][IT_EXCECAO][10])) .Or.;
				aNfItem[nItem,IT_QUANT]==0 .Or. GetNewPar("MV_PISPAUT",.T.)

				If aTes[TS_PISBRUT] == "1"
					nDesconto := 0
				Endif

				nBasePIS := aNfItem[nItem][IT_VALMERC]-IIf(aTes[TS_AGREG]$"D",aNfItem[nItem][IT_DEDICM],0)

				If aTes[TS_AGREG] == "I"
					nBasePIS += If(aNFitem[nItem][IT_TIPONF ]<>"I",aNfItem[nItem][IT_VALICM],0)
				EndIf
				nBasePis := ( nBasePIS - nDesconto + IIf(aNfItem[nItem][IT_DESCZFPIS]<>0,0,aNfItem[nitem][IT_VALSOL]) + aNfItem[nItem][IT_DESCZFCOF] + aNfItem[nItem][IT_DESCZFPIS] )
				If !(aNfCab[NF_CLIFOR]=='C'.AND.aNfCab[NF_CALCSUF]$'SI'.AND.!aNFitem[nItem][IT_TIPONF ]$'BD'.AND.;
				   aTes[TS_ISS]<>"S" .AND. GetNewPar("MV_DESCZF",.T.) .AND. GetNewPar("MV_DESZFPC",.F.)) .OR.;
				   GetNewPar("MV_FRTBASE",.F.)
					nBasePis += aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO] + aNfItem[nItem][IT_FRETE]
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso seja comerciante atacadista, o valor do IPI deve ser retirado da base de calculo do PIS ³
				//³ pois esta embutido no valor da mercadoria                                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aTes[TS_CREDICM] == "S" .AND. SuperGetMV("MV_DEDBPIS") $ "S,I"
					nBasePis -= aNfItem[nItem][IT_VALICM]
				EndIf
				If aTes[TS_CREDIPI] == "N" .AND. SuperGetMV("MV_DEDBPIS") $ "S,P" .AND. aTes[TS_IPI]<>"R"
					nBasePis += aNfItem[nItem][IT_VALIPI]
				EndIf
				If aTes[TS_CREDIPI] == "S" .AND. SuperGetMV("MV_DEDBPIS") $ "S,P" .AND. aTes[TS_IPI]=="R"
					nBasePis -= aNfItem[nItem][IT_VALIPI]
				EndIf

				If aTes[TS_PISDSZF] == "2"
					nBasePis += aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFCOF] + aNfItem[nItem][IT_DESCZFPIS])
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Indica o tratamento para retirada do valor do ICMS solidario na base do PIS apurado    ³
				//³ 1 - Nunca retira                                                                       ³
				//³ 2 - Retira se houver credito do ICMS ST                                                ³
				//³ 3 - Retira se nao houver credito do ICMS ST                                            ³
				//³ 4 - Retira se houver credito do ICMS normal                                            ³
				//³ 5 - Retira se nao houver credito do ICMS normal                                        ³
				//³ 6 - Sempre retira                                                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cDebSTPIS == "6" .OR. ;
					( aTes[TS_CREDST]  == "1" .AND. cDebSTPIS == "2" ) .OR. ;
					( aTes[TS_CREDST]  == "2" .AND. cDebSTPIS == "3" ) .OR. ;
					( aTes[TS_CREDICM] == "S" .AND. cDebSTPIS == "4" ) .OR. ;
					( aTes[TS_CREDICM] == "N" .AND. cDebSTPIS == "5" )) .AND. aNfItem[nItem][IT_DESCZFPIS] == 0
					nBasePis -= aNfItem[nitem][IT_VALSOL]
				Endif
				nBasePis *= nFatRedPis
				aNfItem[nItem][IT_BASEPS2] := nBasePis
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula o valor do PIS de pauta pela base                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( Empty(aNFitem[nItem,IT_EXCECAO]).OR.Empty(aNFItem[nItem,IT_EXCECAO,10]))
					nBasePIS := aNfItem[nItem,IT_QUANT] * MaSBCampo( "VLR_PIS" )
				Else
					nBasePIS := aNfItem[nItem,IT_QUANT] * aNFItem[nItem,IT_EXCECAO,10]
				EndIf
				aNfItem[nItem][IT_BASEPS2] := nBasePis
			EndIf
		EndIf
	Else
		nBasePIS := 0
		aNfItem[nItem][IT_BASEPS2] := nBasePis
	EndIf
EndIf

If cTipo $ "23"
	If ((lMaCalcPIS .AND. aMaCalcPIS[1]=="S") .OR. (!Empty(aNfCab[NF_NATUREZA]) .AND. SED->ED_CALCPIS=="S")) .AND. aNfCab[NF_RECPIS]$"S|P" .AND. ( MaSBCampo("PIS")==Nil .OR. MaSBCampo("PIS")=="1" .OR. aNfCab[NF_RECPIS]=="P" )
		nBasePis := aNfItem[nItem,IT_BASEDUP]+IIf(cPisBru=="1",nDesconto,0)
		nBasePis *= nFatRedPis

		//Tratamento extraido da funcao MaFisVTot para saber se foi contemplado o VALOR DE IPI na base da duplicata para que eu possa subtrair
		If (aTes[TS_IPIPC]=="2") .AND. (aNFitem[nItem][IT_TIPONF]=="P" .OR. aTes[TS_IPI]<>'R')
			nBasePis -= aNfItem[nItem][IT_VALIPI]
		EndIf

		aNfItem[nItem][IT_BASEPIS] := nBasePis
	Else
		aNfItem[nItem][IT_BASEPIS] := 0
	EndIf

EndIf

Return( nBasePIS )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisVlCOF³ Autor ³ Edson Maricate        ³ Data ³04.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o valor  do COFINS                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±³          ³ExpC1: Tipo : 1-Apuracao / 2-Retencao / 3-Ambos ( padrao )  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisVLCOF(nItem,cTipo)

Local nVlCOF   := 0
Local aRelImp  := {}
Local aRelImp2 := {}
Local nVlCOFEt := 0
Local nVlCOFSa := 0

Local lMaCalcCOF := ExistBlock("MaCalcCOF")
Local aMaCalcCOF := {}

DEFAULT cTipo  := "3"

If lMaCalcCOF
	aMaCalcCOF := ExecBlock("MaCalcCOF")
EndIf

If cTipo $ "13"
	If MaSbCampo("VLR_COF")==Nil .Or. MaSbCampo("VLR_COF")==0 .Or. (!Empty(aNFitem[nItem][IT_EXCECAO]) .And. Empty(aNfItem[nItem][IT_EXCECAO][11])) .Or.;
		aNfItem[nItem,IT_QUANT]==0 .Or. !GetNewPar("MV_PISPAUT",.T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o valor do PIS apurado                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlCof := aNfItem[nItem][IT_BASECF2]*aNfItem[nItem][IT_ALIQCF2]/100
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o valor do PIS apurado de pauta                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aNfItem[nItem][IT_BASECF2]<>0
			If ( Empty(aNFitem[nItem,IT_EXCECAO]).OR.Empty(aNFItem[nItem,IT_EXCECAO,11]))
				nVlCof := aNfItem[nItem,IT_QUANT] * MaSBCampo( "VLR_COF" )
			Else
				nVlCof := aNfItem[nItem,IT_QUANT] * aNFItem[nItem,IT_EXCECAO,11]
			EndIf
		EndIf
	EndIf
	aNfItem[nItem][IT_VALCF2] := nVlCOF
	If aNFCab[NF_TIPONF] $ "DB"
		aRelImp  := MaFisRelImp("MT100",{ "SD1" })
		aRelImp2 := MaFisRelImp("MT100",{ "SD2" })

		If !Empty(aNFItem[nItem][IT_RECORI]) .And. aTES[TS_PISCRED] <> "3" .AND. aTES[TS_PISCOF]$"13" .AND. !( aNfItem[nItem][IT_TIPONF] $ "I|P" )
			If ( aNFCab[NF_CLIFOR] == "C")
				dbSelectArea("SD2")
				MsGoto(aNFItem[nItem][IT_RECORI])
				If !Empty( nScanCOF := aScan(aRelImp2,{|x| x[1]=="SD2" .AND. x[3]=="IT_VALCF2"} ) )
					nVlCOFSa := SD2->( FieldGet(FieldPos( aRelImp2[nScanCOF,2] ) ))
				EndIf
				If ((nVlCOFSa > 0 .AND. aNfItem[nItem][IT_VALCF2] = 0) .OR. Abs(aNfItem[nItem][IT_VALCF2]-nVlCOFSa)<=1) .AND. aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT .AND. SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0
					aNfItem[nItem][IT_VALCF2] := nVlCOFSa
				EndIf
			Else
				dbSelectArea("SD1")
				MsGoto(aNFItem[nItem][IT_RECORI])
				If !Empty( nScanCOF := aScan(aRelImp ,{|x| x[1]=="SD1" .AND. x[3]=="IT_VALCF2"} ) )
					nVlCOFEt := SD1->( FieldGet(FieldPos( aRelImp[nScanCOF,2] ) ) )
				EndIf
				If ((nVlCOFEt > 0 .AND. aNfItem[nItem][IT_VALCF2] = 0) .OR. Abs(aNfItem[nItem][IT_VALCF2]-nVlCOFEt)<=1) .AND. aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT .AND. SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0
					aNfItem[nItem][IT_VALCF2] := nVlCOFEt
				EndIf
			EndIf
		EndIf
		nVlCOF := aNfItem[nItem][IT_VALCF2]
	EndIf
	If aNfCab[NF_CLIFOR]=='C'.AND.!aNfCab[NF_CALCSUF]$'IN '.AND.!aNFitem[nItem][IT_TIPONF ]$'BD'.AND. aTes[TS_ISS]<>"S" .AND. GetNewPar("MV_DESCZF",.T.) .AND. GetNewPar("MV_DESZFPC",.F.)
		aNfItem[nItem][IT_DESCZF] -= aNfItem[nItem][IT_DESCZFCOF]
		If !GetNewPar("MV_RNDCF2",.F.)
			aNfItem[nItem][IT_VALCF2] := NoRound(aNfItem[nItem][IT_VALCF2],2)
		Else
			aNfItem[nItem][IT_VALCF2] := Round(aNfItem[nItem][IT_VALCF2],2)
		EndIf
		If aNfCab[NF_ROTINA] == 'MATA461'
			aNfItem[nItem][IT_VALMERC]+= aNfItem[nItem][IT_DESCZFCOF]
			aNfItem[nItem][IT_VALMERC]-= aNfItem[nItem][IT_VALCF2]
			aNfItem[nItem][IT_PRCUNI] := (aNfItem[nItem][IT_VALMERC]-aNfItem[nItem][IT_DESCONTO])/aNfItem[nItem][IT_QUANT]
		EndIf
		aNfItem[nItem][IT_DESCZFCOF]:= aNfItem[nItem][IT_VALCF2]
		aNfItem[nItem][IT_DESCZF]   += aNfItem[nItem][IT_DESCZFCOF]
		aNfItem[nItem][IT_VALCF2]   := 0
		aNfItem[nItem][IT_BASECF2]  := 0
	EndIf
EndIf

If cTipo $ "23"

	If (lMaCalcCof .AND. aMaCalcCOF[1]=="S") .OR. (!Empty(aNfCab[NF_NATUREZA]) .AND. SED->ED_CALCCOF=="S")
		nVlCOF := aNfItem[nItem][IT_BASECOF]*aNfItem[nItem][IT_ALIQCOF]/100
		aNfItem[nItem][IT_VALCOF] := nVlCOF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item esta classificado na Medida Provisoria 252 de Junho de 2005³
		//³Os itens de autopecas constantes na medida devem reter PIS/COFINS aquisicao   ³
		//³a aquisicao e nao aguardar o limite imposto pela Lei 10.925 (R$ 5.000,00).    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If MaSBCampo("RETOPER") == "1"
			aNfItem[nItem][IT_COF252] := nVlCOF
		Endif
	Else
		aNfItem[nItem][IT_VALCOF] := 0
	EndIf
EndIf

Return(nVlCOF)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisVLCSL³ Autor ³ Edson Maricate        ³ Data ³04.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o valor do CSLL.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisVLCSL(nItem)

Local lMaCalcCSL := ExistBlock("MaCalcCSL")
Local aMaCalcCSL := {}

If lMaCalcCSL
	aMaCAlcCSL := ExecBlock("MaCalcCSL")
EndIf

If ((lMaCalcCSL .AND. aMaCalcCSL[1]=="S") .OR. (!Empty(aNfCab[NF_NATUREZA]) .AND. SED->ED_CALCCSL=="S")) .AND.aNfItem[nItem][IT_TIPONF]<>"D"
	aNfItem[nItem][IT_VALCSL] := aNfItem[nItem][IT_BASECSL]*aNfItem[nItem][IT_ALIQCSL]/100
Else
	aNfItem[nItem][IT_VALCSL] := 0
EndIf
Return(aNfItem[nItem][IT_VALCSL])


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisVLPIS³ Autor ³ Edson Maricate        ³ Data ³04.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o valor do PIS .                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±³          ³ExpC1: Tipo : 1-Apuracao / 2-Retencao / 3-Ambos ( padrao )  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MaFisVLPIS(nItem,cTipo)

LOCAL nVlPis   := 0
Local aRelImp  := {}
Local aRelImp2 := {}
Local nVlPisEt := 0
Local nVlPisSa := 0

Local lMaCalcPIS := ExistBlock("MaCalcPIS")
Local aMaCalcPIS := {}

DEFAULT cTipo  := "3"

If lMaCalcPIS
	aMaCalcPIS := ExecBlock("MaCalcPIS")
EndIf

If cTipo $ "13"
	If MaSbCampo("VLR_PIS")==Nil .Or. MaSbCampo("VLR_PIS")==0 .Or. (!Empty(aNFitem[nItem][IT_EXCECAO]) .And. Empty(aNfItem[nItem][IT_EXCECAO][10])) .Or.;
		aNfItem[nItem,IT_QUANT]==0 .Or. !GetNewPar("MV_PISPAUT",.T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o valor do PIS apurado                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlPis := aNfItem[nItem][IT_BASEPS2]*aNfItem[nItem][IT_ALIQPS2]/100
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o valor do PIS de pauta                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aNfItem[nItem][IT_BASEPS2] <> 0
			If ( Empty(aNFitem[nItem,IT_EXCECAO]).OR.Empty(aNFItem[nItem,IT_EXCECAO,10]))
				nVlPis := aNfItem[nItem,IT_QUANT] * MaSBCampo( "VLR_PIS" )
			Else
				nVlPis := aNfItem[nItem,IT_QUANT] * aNFItem[nItem,IT_EXCECAO,10]
			EndIf
		EndIf
	EndIf

	aNfItem[nItem][IT_VALPS2] := nVlPis
	If aNFCab[NF_TIPONF] $ "DB"
		aRelImp  := MaFisRelImp("MT100",{ "SD1" })
		aRelImp2 := MaFisRelImp("MT100",{ "SD2" })
		If !Empty(aNFItem[nItem][IT_RECORI]) .And. aTES[TS_PISCRED] <> "3" .AND. aTES[TS_PISCOF]$"13" .AND. !( aNfItem[nItem][IT_TIPONF] $ "I|P" )
			If ( aNFCab[NF_CLIFOR] == "C")
				dbSelectArea("SD2")
				MsGoto(aNFItem[nItem][IT_RECORI])
				If !Empty( nScanPis := aScan(aRelImp2,{|x| x[1]=="SD2" .AND. x[3]=="IT_VALPS2"} ) )
					nVlPisSa := SD2->( FieldGet(FieldPos( aRelImp2[nScanPis,2] ) ))
				EndIf
				If ((nVlPisSa > 0 .AND. aNfItem[nItem][IT_VALPS2] = 0) .OR. Abs(aNfItem[nItem][IT_VALPS2]-nVlPisSa)<=1) .AND. aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT .AND. SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0
					aNfItem[nItem][IT_VALPS2] := nVlPisSa
				EndIf
			Else
				dbSelectArea("SD1")
				MsGoto(aNFItem[nItem][IT_RECORI])
				If !Empty( nScanPis := aScan(aRelImp ,{|x| x[1]=="SD1" .AND. x[3]=="IT_VALPS2"} ) )
					nVlPisEt := SD1->( FieldGet(FieldPos( aRelImp[nScanPis,2] ) ) )
				EndIf
				If ((nVlPisEt > 0 .AND. aNfItem[nItem][IT_VALPS2] = 0) .OR. Abs(aNfItem[nItem][IT_VALPS2]-nVlPisEt)<=1) .AND. aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT .AND. SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0
					aNfItem[nItem][IT_VALPS2] := nVlPisEt
				EndIf
			EndIf
		EndIf
		nVlPis := aNfItem[nItem][IT_VALPS2]
	EndIf
	If aNfCab[NF_CLIFOR]=='C'.AND.!aNfCab[NF_CALCSUF]$'IN '.AND.!aNFitem[nItem][IT_TIPONF ]$'BD'.AND. aTes[TS_ISS]<>"S" .AND. GetNewPar("MV_DESCZF",.T.) .AND. GetNewPar("MV_DESZFPC",.F.)
		aNfItem[nItem][IT_DESCZF]    -= aNfItem[nItem][IT_DESCZFPIS]
		If !GetNewPar("MV_RNDPS2",.F.)
			aNfItem[nItem][IT_VALPS2] := NoRound(aNfItem[nItem][IT_VALPS2],2)
		Else
			aNfItem[nItem][IT_VALPS2] := Round(aNfItem[nItem][IT_VALPS2],2)
		EndIf
		If aNfCab[NF_ROTINA] == 'MATA461'
			aNfItem[nItem][IT_VALMERC] += aNfItem[nItem][IT_DESCZFPIS]
			aNfItem[nItem][IT_VALMERC] -= NoRound(aNfItem[nItem][IT_VALPS2],2)
			aNfItem[nItem][IT_PRCUNI]  := (aNfItem[nItem][IT_VALMERC]-aNfItem[nItem][IT_DESCONTO])/aNfItem[nItem][IT_QUANT]
		EndIf
		aNfItem[nItem][IT_DESCZFPIS] := aNfItem[nItem][IT_VALPS2]
		aNfItem[nItem][IT_DESCZF]    += aNfItem[nItem][IT_DESCZFPIS]
		aNfItem[nItem][IT_VALPS2]    := 0
		aNfItem[nItem][IT_BASEPS2]   := 0
	EndIf
EndIf

If cTipo $ "23"

	If (lMaCalcPIS .AND. aMaCalcPIS[1]=="S") .OR. (!Empty(aNfCab[NF_NATUREZA]) .AND. SED->ED_CALCPIS=="S")
		nVlPis := aNfItem[nItem][IT_BASEPIS]*aNfItem[nItem][IT_ALIQPIS]/100
		aNfItem[nItem][IT_VALPIS] := nVlPis
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item esta classificado na Medida Provisoria 252 de Junho de 2005³
		//³Os itens de autopecas constantes na medida devem reter PIS/COFINS aquisicao   ³
		//³a aquisicao e nao aguardar o limite imposto pela Lei 10.925 (R$ 5.000,00).    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If MaSBCampo("RETOPER") == "1"
			aNfItem[nItem][IT_PIS252] := nVlPis
		Endif
	Else
		aNfItem[nItem][IT_VALPIS] := 0
	EndIf
EndIf

Return(nVlPis)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaItArred³ Autor ³ Edson Maricate         ³ Data ³12.04.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a correcao dos arredondamentos do item             ³±±
±±³          ³ Utiliza o Array aSaveDec para armazenar os centesimos      ³±±
±±³          ³ que foram truncados. ( aSaveDec deve estar inicializado    ³±±
±±³          ³ obrigatoriamente pela MaFisIni() )                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaItArred(nX,aRefs)
Local nY        := 0
Local nDec      := 2
Local nDif      := 0
Local nValor 	:= 0
Local nDifItem	:= 0
Local nRndPrec  := Iif (GetNewPar("MV_RNDPREC", 10)<3, 10, GetNewPar("MV_RNDPREC", 10))	//Precisao para o arredondamento
Local nDecSoma	:=	0

If aItemRef == Nil
	MaIniRef()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a correcao nos arredondamentos.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nY := 1 to Len(aItemRef)
	If aRefs == Nil .OR. Ascan( aRefs, aItemRef[nY][1] )<>0
		If aItemRef[nY][4]
			nDifItem	:= 0
			If cPaisLoc<>"BRA"
				If FunName()=="MATA121" .AND. Type("nMoedaPed")=="N"
					nDec:=MsDecimais(nMoedaPed)
				ElseIf FunName()=="MATA150" .AND. Type("nMoedaCot")=="N"
					nDec:=MsDecimais(nMoedaCot)
				ElseIf Type("nMoedaNF")=="N"
					nDec:=MsDecimais(nMoedaNF)
				ElseIf Type("nMoedaCor")=="N"
					nDec:=MsDecimais(nMoedaCor)
				ElseIf Type("M->F1_MOEDA")=="N"
					nDec:=MsDecimais(M->F1_MOEDA)
				ElseIf Type("M->F2_MOEDA")=="N"
					nDec:=MsDecimais(M->F2_MOEDA)
				Else
					nDec:=MsDecimais(1)
				Endif
				nDif:=10**(-nDec)
			Endif
			If ValType(aItemRef[nY][2]) == "A"
				nValor := aNfItem[nX][aItemRef[nY][2][1]][aItemRef[nY][2][2]]
				If nValor <> 0
					aNfItem[nX][aItemRef[nY][2][1]][aItemRef[nY][2][2]] := NoRound(NoRound(nValor,nRndPrec),nDec,@nDifItem,10)
                    If nDifItem <> 0

					   If cPaisLoc=="BRA"
						   If (nDecSoma := Len(SubStr(AllTrim(Str(nDifItem)),At(".",AllTrim(Str(nDifItem)))+1))-nDec)>0
						      nDecSoma	+=	nDec
						   Else
						      nDecSoma	:=	4
						   EndIf
					   Else
					       nDecSoma		:=	nDec
					   EndIf

 					   If !aItemRef[nY][5]
   						  aSaveDec[nY] -= aItemDec[nX][2][nY]
						  aItemDec[nX][2][nY]	:= nDifItem
						  aSaveDec[nY]			+= nDifItem
						  If NoRound(aSaveDec[nY],nDec) >= 1/10**nDec
							 aItemDec[nX][1][nY]	:= (1/10**nDec) - nDifItem
							 aItemDec[nX][2][nY]	:= 0
							 aSaveDec[nY] -= (1/10**nDec)
						 	 aNfItem[nX][aItemRef[nY][2][1]][aItemRef[nY][2][2]] += (1/10**nDec)
						  EndIf
					   ElseIf nDifItem > 0 .AND. aNfItem[nX][aItemRef[nY][2][1]][aItemRef[nY][2][2]] > 0
   						  aSaveDec[nY] -= aItemDec[nX][2][nY]
						  aItemDec[nX][2][nY]	:= nDifItem
						  aSaveDec[nY]			+= nDifItem
  						  If aSaveDec[nY] >= (49/(10**(Iif(nDec==0,2,nDecSoma))))
							 aItemDec[nX][1][nY]	:= (1/10**nDec) - nDifItem
							 aItemDec[nX][2][nY]	:= 0
							 aSaveDec[nY] -= (1/10**nDec)
							 aNfItem[nX][aItemRef[nY][2][1]][aItemRef[nY][2][2]] += (1/10**nDec)
						  EndIf
					   EndIf
					EndIf
				EndIf
			Else
				nValor := aNfItem[nX][Val(aItemRef[nY][2])]
				If nValor <> 0
					aNfItem[nX][Val(aItemRef[nY][2])] := NoRound(NoRound(nValor,nRndPrec),nDec,@nDifItem,10)
					If nDifItem <> 0

					   If cPaisLoc=="BRA"
						   If (nDecSoma := Len(SubStr(AllTrim(Str(nDifItem)),At(".",AllTrim(Str(nDifItem)))+1))-nDec)>0
						      nDecSoma	:=	nDec+(Len(SubStr(AllTrim(Str(nDifItem)),At(".",AllTrim(Str(nDifItem)))+1))-nDec)
						   Else
						      nDecSoma	:=	4
						   EndIf
					   Else
					       nDecSoma		:=	nDec
					   EndIf

					   If !aItemRef[nY][5]
   						  aSaveDec[nY] -= aItemDec[nX][2][nY]
						  aItemDec[nX][2][nY]	:= nDifItem
						  aSaveDec[nY]		    += nDifItem
						  If NoRound(aSaveDec[nY],nDec) >= 1/10**nDec
							 aItemDec[nX][1][nY]	:= (1/10**nDec) - nDifItem
							 aItemDec[nX][2][nY]	:= 0
							 aSaveDec[nY]           -= (1/10**nDec)
							 aNfItem[nX][Val(aItemRef[nY][2])] += (1/10**nDec)
						  EndIf
   						   ElseIf nDifItem > 0 .AND. aNfItem[nX][Val(aItemRef[nY][2])] > 0
   						  aSaveDec[nY] -= aItemDec[nX][2][nY]
						  aItemDec[nX][2][nY]	:= nDifItem
						  aSaveDec[nY]			+= nDifItem
						  If aSaveDec[nY] >= (49/(10**(Iif(nDec==0,2,nDecSoma))))
							 aItemDec[nX][1][nY]	:= (1/10**nDec) - nDifItem
 								 aItemDec[nX][2][nY]	:= 0
							 aSaveDec[nY] -= (1/10**nDec)
							 aNfItem[nX][Val(aItemRef[nY][2])] += (1/10**nDec)
						  EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Next nY

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisTpCon³ Autor ³ Sergio Silveira       ³ Data ³04/07/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Converte o tipo do fornecedor                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpC1 := MaFisTpCon( ExpC2 )                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC1 -> Tipo convertido                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC2 : Tipo                                               ³±±
±±³          ³ ExpC2 : Loja do Cliente / Fornecedor                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MaFisTpCon( cCodOri )

LOCAL cCodRet := ""

If cCodOri == "J" .OR. cCodOri == " "
	cCodRet := "R"
Else
	cCodRet := cCodOri
EndIf

Return( cCodRet )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaFisIniNF³ Rev.  ³ Eduardo Riera         ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de Inicializacao da funcao fiscal com base nas Notas  ³±±
±±³          ³Fiscais                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Tipo de Nota Fiscal                                   ³±±
±±³          ³       [1] Nota Fiscal de Entrada                            ³±±
±±³          ³       [2] Nota Fiscal de Saida                              ³±±
±±³          ³ExpX2: Numero do Registro do Cabecalho da Nota Fiscal, ou    ³±±
±±³          ³       o Alias da Tabela a ser considerada.                  ³±±
±±³          ³ExpA3: Array para Otimizacao ( Uso Interno deve-se apenas    ³±±
±±³          ³       assegurar que seu valor foi amazenado externamente a  ³±±
±±³          ³       esta rotina)                                          ³±±
±±³          ³ExpC4: Alias da tabela de notas fiscais de entrada      (OPC)³±±
±±³          ³ExpL5: Indica se deve ser recalculada a base dos impostos    ³±±
±±³          ³       Fiscais                                          (OPC)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo atualizar a funcao fiscal com  ³±±
±±³          ³base em uma nota fiscal de entrada ou saida. A Funcao Fiscal ³±±
±±³          ³eh atualizada com base nas referencias do dicionario de dados³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisIniNF(nTipoNF,nRecSF,aOtimizacao,cAlias,lReprocess)

Local aArea		 := GetArea()
Local aAreaSD1	 := SD1->(GetArea())
Local aAreaSF1	 := SF1->(GetArea())
Local aAreaSD2	 := SD2->(GetArea())
Local aAreaSF2	 := SF2->(GetArea())

Local cAlias2    := ""

Local lQuery     := .F.
Local lISS       := .F.
Local lGravou    := .F.
Local nX         := 0
Local nY		 := 0
Local nValor     := 0
Local cCliEnt	 :=	Space(TamSx3("F3_CLIEFOR")[1])
Local cLojEnt	 :=	Space(TamSx3("F3_LOJA")[1])
Local lTMSUFPAG  := SuperGetMv("MV_TMSUFPG",.F.,.F.) //-- Define se grava o estado do pagador do frete.

#IFDEF TOP
	Local aStru     := {}
	Local cQuery    := ""
#ENDIF

DEFAULT lReprocess := .F.

Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializacao das Notas Fiscais de Entrada                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case nTipoNF == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o Array de otimizacao esta disponivel                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aOtimizacao)
		aOtimizacao := {MaFisSXRef("SF1"),MaFisSxRef("SD1")}
	EndIf
	cAlias2 := "SD1"
	If Empty(cAlias)
		cAlias := "SF1"
		dbSelectArea(cAlias)
		MsGoto(nRecSF)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa cabecalho da funcao fiscal                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisEnd()
	MaFisIni((cAlias)->F1_FORNECE,(cAlias)->F1_LOJA,IIF((cAlias)->F1_TIPO$'DB',"C","F"),(cAlias)->F1_TIPO,"R",,If((cAlias)->F1_TIPO=="C",AllTrim((cAlias)->F1_ORIGLAN),Nil))
	If (cAlias)->F1_TIPO$"DB" .AND. !lReprocess
		MaFisAlt("NF_UFDEST",(cAlias)->F1_EST)
	Else
		MaFisAlt("NF_UFORIGEM",(cAlias)->F1_EST)
	EndIf
	MaFisAlt("NF_ESPECIE",(cAlias)->F1_ESPECIE)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a query para otimizacao.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAlias2)
	dbSetOrder(1)
	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			aStru   := SD1->(dbStruct())
			lQuery  := .T.
			cAlias2 := "MaFisIniNF"
			cQuery  := "SELECT SD1.*,SD1.R_E_C_N_O_ SD1RECNO FROM "+RetSqlName("SD1")+" SD1 "
			cQuery  += "WHERE "
			cQuery  += "SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "
			cQuery  += "SD1.D1_DOC = '"+(cAlias)->F1_DOC+"' AND "
			cQuery  += "SD1.D1_SERIE = '"+(cAlias)->F1_SERIE+"' AND "
			cQuery  += "SD1.D1_FORNECE = '"+(cAlias)->F1_FORNECE+"' AND "
			cQuery  += "SD1.D1_LOJA = '"+(cAlias)->F1_LOJA+"' AND "
			cQuery  += "SD1.D1_TIPO= '"+(cAlias)->F1_TIPO+"' AND "
			cQuery  += "SD1.D_E_L_E_T_=' ' "
			cQuery  += "ORDER BY "+SqlOrder(IndexKey())

			cQuery  := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias2,.T.,.T.)
			For nX := 1 To Len(aStru)
				If aStru[nX][2] <> "C"
					TcSetField(cAlias2,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				EndIf
			Next nX
		Else
	#ENDIF
		MsSeek(xFilial("SD1")+(cAlias)->F1_DOC+(cAlias)->F1_SERIE+(cAlias)->F1_FORNECE+(cAlias)->F1_LOJA)
		#IFDEF TOP
		EndIf
		#ENDIF
	dbSelectArea(cAlias2)
	While ( !Eof() .AND. (cAlias2)->D1_FILIAL == xFilial("SD1") .AND.;
			(cAlias2)->D1_DOC == (cAlias)->F1_DOC .AND.;
			(cAlias2)->D1_SERIE == (cAlias)->F1_SERIE .AND.;
			(cAlias2)->D1_FORNECE == (cAlias)->F1_FORNECE .AND.;
			(cAlias2)->D1_LOJA == (cAlias)->F1_LOJA )
		If (cAlias2)->D1_TIPO == (cAlias)->F1_TIPO
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicializa os itens da funcao fiscal                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nY++
			MaFisIniLoad(nY)
			If lReprocess
				MaFisAlt ("IT_ITEM", (cAlias2)->D1_ITEM, nY)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca o codigo do ISS na tabela de produtos. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			(cAliasProd)->(dbSetOrder(1))
			If (cAliasProd)->(dbSeek(xFilial(cAliasProd)+(cAlias2)->D1_COD))
				aNFitem[nY][IT_CODISS]	:=	MaSBCampo("CODISS")
			Endif

			For nX := 1 To Len(aOtimizacao[2])
				MaFisLoad(aOtimizacao[2][nX][2],FieldGet(FieldPos(aOtimizacao[2][nX][1])),nY)
			Next nX
			MaFisEndLoad(nY,2)
			If lReprocess
				MaFisBSIPI(nY,.T.)	// Calcula a Base de IPI Original
				MaFisBSICM(nY,.T.)	// Calcula a Base de ICMS Original
				MaFisVICMS(nY,.T.) 	// Calcula o Valor do ICMS / Diferido
				MaFisLF(nY)			// Atualiza os valores do Livro Fiscal
				MaFisLF2(nY)		// Verifica se a TES possui RdMake para complemento/geracao dos Livros
				MaFisLF3(nY)
			EndIf
		EndIf
		If (cAlias2)->D1_ORIGLAN<>(cAlias)->F1_ORIGLAN
			If lQuery
				SD1->(MsGoto((cAlias2)->SD1RECNO))
			EndIf
			RecLock("SD1",.F.)
			SD1->D1_ORIGLAN := (cAlias)->F1_ORIGLAN
			MsUnlock()
		EndIf
		dbSelectArea(cAlias2)
		dbSkip()
	End
	If lQuery
		dbSelectArea(cAlias2)
		dbCloseArea()
		dbSelectArea("SD1")
	EndIf

	If (cAlias)->F1_IMPORT <> "S"
		MaFisAlt("NF_FRETE"    ,(cAlias)->F1_FRETE)
		MaFisAlt("NF_SEGURO"   ,(cAlias)->F1_SEGURO)
		MaFisAlt("NF_DESPESA"  ,(cAlias)->F1_DESPESA)
	EndIf

	// Fundo Social - Sera recalculado para apresentar nas observacoes do documento
	MaFisAlt("NF_FUNRURAL" ,(cAlias)->F1_CONTSOC,)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializacao das Notas Fiscais de Saida                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case nTipoNF == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o Array de otimizacao esta disponivel                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aOtimizacao)
		aOtimizacao := {MaFisSXRef("SF2"),MaFisSxRef("SD2")}
	EndIf
	cAlias2 := "SD2"
	If Empty(cAlias)
		cAlias := "SF2"
		dbSelectArea(cAlias)
		MsGoto(nRecSF)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa cabecalho da funcao fiscal                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisEnd()
	MaFisIni((cAlias)->F2_CLIENTE,(cAlias)->F2_LOJA,IIF((cAlias)->F2_TIPO$'DB',"F","C"),(cAlias)->F2_TIPO,(cAlias)->F2_TIPOCLI,{},,,,,,,,,Iif((cAlias)->(FieldPos("F2_RECISS"))>0,(cAlias)->F2_RECISS,""),(cAlias)->F2_CLIENT, (cAlias)->F2_LOJENT)

	If (cAlias)->F2_TIPO$"DB" .AND. !lReprocess
		MaFisAlt("NF_UFORIGEM",(cAlias)->F2_EST)
	Else
		MaFisAlt("NF_UFDEST",(cAlias)->F2_EST)
	EndIf
	MaFisAlt("NF_ESPECIE",(cAlias)->F2_ESPECIE)

	cCliEnt	:=	MaFisRet(,"NF_CLIENT")
	cLojEnt	:=	MaFisRet(,"NF_LOJENT")

	dbSelectArea("SD2")
	dbSetOrder(3)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a query para otimizacao.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			aStru   := SD2->(dbStruct())
			lQuery  := .T.
			cAlias2 := "MaFisIniNF"
			cQuery  := "SELECT SD2.*,SD2.R_E_C_N_O_ SD2RECNO FROM "+RetSqlName("SD2")+" SD2 "
			cQuery  += "WHERE "
			cQuery  += "SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "
			cQuery  += "SD2.D2_DOC = '"+(cAlias)->F2_DOC+"' AND "
			cQuery  += "SD2.D2_SERIE = '"+(cAlias)->F2_SERIE+"' AND "
			cQuery  += "SD2.D2_CLIENTE = '"+(cAlias)->F2_CLIENTE+"' AND "
			cQuery  += "SD2.D2_LOJA = '"+(cAlias)->F2_LOJA+"' AND "
			cQuery  += "SD2.D_E_L_E_T_=' ' "
			cQuery  += "ORDER BY "+SqlOrder(SD2->(IndexKey()))

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias2,.T.,.T.)

			For nX := 1 To Len(aStru)
				If aStru[nX][2]<>"C"
					TcSetField(cAlias2,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				EndIf
			Next nX
		Else
	#ENDIF
		MsSeek(xFilial("SD2")+(cAlias)->F2_DOC+(cAlias)->F2_SERIE+(cAlias)->F2_CLIENTE+(cAlias)->F2_LOJA)
		#IFDEF TOP
		EndIf
		#ENDIF
	dbSelectArea(cAlias)
	While !Eof().AND. (cAlias2)->D2_FILIAL == xFilial("SD2") .AND.;
			(cAlias2)->D2_DOC == (cAlias)->F2_DOC .AND.;
			(cAlias2)->D2_SERIE == (cAlias)->F2_SERIE .AND.;
			(cAlias2)->D2_CLIENTE == (cAlias)->F2_CLIENTE .AND.;
			(cAlias2)->D2_LOJA == (cAlias)->F2_LOJA

		If Empty(cCliEnt) .And. Empty(cLojEnt)
			SC5->(dbSetOrder(1))
			If SC5->(dbSeek(xFilial("SC5")+(cAlias2)->D2_PEDIDO))

				cCliEnt	:=	SC5->C5_CLIENT
				cLojEnt	:=	SC5->C5_LOJAENT

				MaFisAlt("NF_CLIENT", SC5->C5_CLIENT)
				MaFisAlt("NF_LOJENT", SC5->C5_LOJAENT)

				If cAlias<>"SF2"
					SF2->(dbSetOrder(1))
						If SF2->(dbSeek(xFilial("SF2")+(cAlias)->F2_DOC+(cAlias)->F2_SERIE+(cAlias)->F2_CLIENTE+(cAlias)->F2_LOJA))
						RecLock("SF2",.F.)
						SF2->F2_CLIENT	:=	MaFisRet(,"NF_CLIENT")
						SF2->F2_LOJENT	:=	MaFisRet(,"NF_LOJENT")
						MsUnLock()
					EndIf
				Else
					RecLock(cAlias,.F.)
					(cAlias)->F2_CLIENT	:=	MaFisRet(,"NF_CLIENT")
					(cAlias)->F2_LOJENT	:=	MaFisRet(,"NF_LOJENT")
					MsUnLock()
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa os itens da funcao fiscal                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nY++
		MaFisIniLoad(nY)
		If lReprocess
			MaFisAlt ("IT_ITEM", (cAlias2)->D2_ITEM, nY)
		EndIf
		If !Empty((cAlias2)->D2_CODISS) .OR. (cAlias2)->D2_VALISS > 0
			lISS := .T.
			If !Empty((cAlias2)->D2_CODISS)
				aNFItem[nY][IT_RATEIOISS] := "S"
			EndIf

		EndIf
		For nX := 1 To Len(aOtimizacao[2])
			Do Case
			Case aOtimizacao[2][nX][2] == "IT_VALMERC"
				If cPaisLoc<>"BRA" .AND. GetNewPar('MV_DESCSAI','1') =='1'
					nValor := (cAlias2)->D2_TOTAL
				Else
					nValor := (cAlias2)->D2_TOTAL+(cAlias2)->D2_DESCON
				Endif
			Case aOtimizacao[2][nX][2] == "IT_VALISS"
				nValor := IIF(lISS.AND.Empty((cAlias2)->D2_VALISS),(cAlias2)->D2_VALICM,(cAlias2)->D2_VALISS)
			Case aOtimizacao[2][nX][2] == "IT_BASEISS"
				nValor := IIF(lISS.AND.Empty((cAlias2)->D2_BASEISS),(cAlias2)->D2_BASEICM,(cAlias2)->D2_BASEISS)
			Case aOtimizacao[2][nX][2] == "IT_ALIQISS"
				nValor := IIF(lISS.AND.Empty((cAlias2)->D2_ALIQISS),(cAlias2)->D2_PICM,(cAlias2)->D2_ALIQISS)
			OtherWise
				nValor := (cAlias2)->(FieldGet(FieldPos(aOtimizacao[2][nX][1])))
			EndCase
			MaFisLoad(aOtimizacao[2][nX][2],nValor,nY)
		Next nX
		MaFisLoad("IT_DESCZF",(cAlias2)->D2_DESCZFR,nY)
		MaFisEndLoad(nY,2)
		If lReprocess
			MaFisBSIPI(nY,.T.)	// Calcula a Base de IPI Original
			MaFisBSICM(nY,.T.)	// Calcula a Base de ICMS Original
			MaFisVICMS(nY,.T.) 	// Calcula o Valor do ICMS / Diferido
 			If (cAlias2)->D2_TIPO == "D"
				MaALIQCMP(nY)
				MaFisVComp(nY)
			EndIf
			//Acerto de erro de gravacao ocorrida em 31/05/2003 - Retirar apos 1 ano
			If ((cAlias2)->D2_VALISS==0 .AND. (cAlias2)->D2_VALICM==0 ) .AND. !Empty((cAlias2)->D2_CODISS)
				nValor := MaAliqIss(nY)
				MaFisBSISS(nY)
				MaFisAlt("IT_ALIQISS",0,nY)
				MaFisAlt("IT_ALIQISS",nValor,nY)
				nValor := MaFisRet(nY,"IT_BASEISS")
				MaFisAlt("IT_BASEISS",0,nY)
				MaFisAlt("IT_BASEISS",nValor,nY)
				If lQuery
					SD2->(MsGoto((cAlias2)->SD2RECNO))
				EndIf
				If ((cAlias2)->D2_VALISS<>MaFisRet(nY,"IT_VALISS"))
					RecLock("SD2")
					SD2->D2_VALICM   := MaFisRet(nY,'IT_VALISS')
					SD2->D2_BASEICM  := MaFisRet(nY,'IT_BASEISS')
					SD2->D2_PICM     := MaFisRet(nY,'IT_ALIQISS')
					SD2->D2_VALISS   := MaFisRet(nY,'IT_VALISS')
					SD2->D2_BASEISS  := MaFisRet(nY,'IT_BASEISS')
					SD2->D2_ALIQISS  := MaFisRet(nY,'IT_ALIQISS')
					lGravou := .T.
					MsUnLock()
				EndIf
			EndIf

			MaFisAlt("NF_VALPIS"   ,(cAlias)->F2_VALPIS)
			MaFisAlt("NF_VALCOF"   ,(cAlias)->F2_VALCOFI)
			MaFisAlt("NF_VALCSL"   ,(cAlias)->F2_VALCSLL)

			MaFisLF(nY)			// Atualiza os valores do Livro Fiscal
			MaFisLF2(nY)		// Verifica se a TES possui RdMake para complemento/geracao dos Livros
			MaFisLF3(nY)
		EndIf
		dbSelectArea(cAlias2)
		dbSkip()
	End
	If lQuery
		dbSelectArea(cAlias2)
		dbCloseArea()
		dbSelectArea("SD2")
	EndIf
	MaFisAlt("NF_FRETE"    ,(cAlias)->F2_FRETE)
	If (cAlias)->(FieldPos("F2_VLR_FRT")) > 0
		MaFisAlt("NF_VLR_FRT"  ,(cAlias)->F2_VLR_FRT)
	EndIf
	MaFisAlt("NF_SEGURO"   ,(cAlias)->F2_SEGURO)
	MaFisAlt("NF_DESPESA"  ,(cAlias)->F2_DESPESA)
	MaFisLoad("NF_AUTONOMO" ,(cAlias)->F2_FRETAUT)
	If !lISS
		MaFisAlt("NF_BASEICM"  ,(cAlias)->F2_BASEICM,)
		MaFisAlt("NF_VALICM"   ,(cAlias)->F2_VALICM,)
		MaFisAlt("NF_BASEIPI"  ,(cAlias)->F2_BASEIPI,)
		MaFisAlt("NF_VALIPI"   ,(cAlias)->F2_VALIPI,)
	EndIf
	MaFisAlt("NF_VALICA"   ,(cAlias)->F2_ICMAUTO,)
	MaFisAlt("NF_FUNRURAL" ,(cAlias)->F2_CONTSOC,)

	//-- Tratamento para o ambiente Gestao de Transporte (SIGATMS)
	If "CTR"$AllTrim((cAlias)->F2_ESPECIE) .OR. "NFST"$AllTrim((cAlias)->F2_ESPECIE)
		MaFisAlt("NF_PNF_COD" ,(cAlias)->F2_CLIENTE,)
		MaFisAlt("NF_PNF_LOJ" ,(cAlias)->F2_LOJA,)
		MaFisAlt("NF_PNF_UF"  ,(cAlias)->F2_EST,)
		//--Quando existe um valor de ICMS Retido o Tipo do Cliente
		//--deve ser o do Cliente Devedor do Frete
		If (cAlias)->F2_ICMSRET > 0
			MaFisAlt("NF_PNF_TPCLIFOR",Posicione('SA1',1,xFilial('SA1')+(cAlias)->F2_CLIENTE+(cAlias)->F2_LOJA,'A1_TIPO'))
		Else
			MaFisAlt("NF_PNF_TPCLIFOR",(cAlias)->F2_TIPOCLI,)
		EndIf
		If IntTms() .And. lReprocess .And. lTMSUFPAG
			DT6->(dbSetOrder(1))
			If DT6->(DbSeek(Iif(!Empty(xFilial('DT6')),(cAlias)->F2_FILIAL,xFilial('DT6'))+(cAlias)->F2_FILIAL+(cAlias)->F2_DOC+(cAlias)->F2_SERIE))
				MaFisAlt("NF_UFORIGEM",Posicione('DUY',1,xFilial('DUY')+DT6->DT6_CDRORI,'DUY_EST'))
				MaFisAlt("NF_UFDEST"  ,Posicione('DUY',1,xFilial('DUY')+DT6->DT6_CDRCAL,'DUY_EST'))
			EndIf
		EndIf
	EndIf

	If !lReprocess
		For nX := 1 To Len(aOtimizacao[1])
			If Empty(MaFisRet(,aOtimizacao[1][nX][2]))
				nValor := (cAlias)->(FieldGet(FieldPos(aOtimizacao[1][nX][1])))
				MaFisAlt(aOtimizacao[1][nX][2],nValor)
			ElseIf !lReprocess
				nValor := (cAlias)->(FieldGet(FieldPos(aOtimizacao[1][nX][1])))
				MaFisLoad(aOtimizacao[1][nX][2],nValor)
			EndIf
		Next nX
	EndIf
EndCase
RestArea(aAreaSD2)
RestArea(aAreaSF2)
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aArea)
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaFisAtuSF³ Autor ³ Edson Maricate        ³ Data ³21.02.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de atualizacao dos livros fiscais                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Tipo de Operacao                                     ³±±
±±³          ³        [1] Inclusao                                         ³±±
±±³          ³        [2] Exclusao                                         ³±±
±±³          ³ExpC2 : Tipo de Movimento                                    ³±±
±±³          ³        [E] Entrada                                          ³±±
±±³          ³        [S] Saida                                            ³±±
±±³          ³ExpN3 : RecNo do cabecalho da nota fiscal                    ³±±
±±³          ³ExpC4 : Alias do cabecalho da nota fiscal                    ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo atualizar os livros fiscais com³±±
±±³          ³base em uma nota fiscal de entrada ou saida.                 ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisAtuSF3(nCaso,cTpOper,nRecNF,cAlias,cPDV)

Local aArea		:= GetArea()
Local aAreaSF1	:= SF1->(GetArea())
Local aAreaSF2	:= SF2->(GetArea())
Local aLivro	:= {}
Local aFixos 	:= {}
Local aRecSF3	:= {}
Local aRecSFT   := {}
Local aSF3      := {}
Local aSFT      := {}
Local aWriteSFT := {}
Local nVlrTotal	:= 0
Local nY        := 0
Local nX        := 0
Local nZ        := 0
Local nA        := 0
Local cCliFor	:= ""
Local cLoja		:= ""
Local cNumNF	:= ""
Local cSerie	:= ""
Local dDEmissao	:= ""
Local cEspecie	:= ""
Local cFormul	:= ""
Local cQuery    := ""
Local cAliasSF3 := "SF3"
Local cAliasSFT := "SFT"
Local cAliasCD2 := "CD2"
Local dEntrada	:= Ctod("")
Local lObserv	:= .F.
Local lQuery    := .F.
Local lTMSUFPAG := SuperGetMv("MV_TMSUFPG",.F.,.F.) //-- Define se grava o estado do pagador do frete.
Local aNFEletr	:= {"",cTod(""),"","",0,""}
Local lNFEntr	:= .F.

DEFAULT cPDV := ""

Do Case
Case cTpOper=="E"
	If Empty(cAlias)
		cAlias := "SF1"
		dbSelectArea("SF1")
		MsGoto(nRecNF)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o cabecalho da NF de Entrada                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCliFor		:= (cAlias)->F1_FORNECE
	cLoja		:= (cAlias)->F1_LOJA
	cNumNF		:= (cAlias)->F1_DOC
	cSerie		:= (cAlias)->F1_SERIE
	dDEmissao	:= (cAlias)->F1_EMISSAO
	cEspecie	:= (cAlias)->F1_ESPECIE
	cFormul		:= (cAlias)->F1_FORMUL
	dEntrada	:= (cAlias)->F1_DTDIGIT
	If cPaisLoc<>"BRA"
		cTipo:=(cAlias)->F1_TIPO
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a NF esta carregada nas Funcoes Fiscais.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nCaso == 1 .AND. !MaFisFound("NF")
		MaFisIniNF(1,nRecNF)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravar Livro Fiscal da NF refrente ao Despacho.         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "ARG"
		If nCaso == 1 .AND. (cAlias)->F1_TIPO_NF == "9"
			MaFisF3Eic(nCaso)
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Campos da Nota Fiscal Eletronica³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lNFEletr	:= 	SF1->(FieldPos("F1_NFELETR")) > 0 .And.;
					SF1->(FieldPos("F1_EMINFE")) > 0 .And.;
					SF1->(FieldPos("F1_HORNFE")) > 0 .And.;
					SF1->(FieldPos("F1_CODNFE")) > 0 .And.;
					SF1->(FieldPos("F1_CREDNFE")) > 0 .And.;
					SF3->(FieldPos("F3_NFELETR")) > 0 .And.;
					SF3->(FieldPos("F3_EMINFE")) > 0 .And.;
					SF3->(FieldPos("F3_HORNFE")) > 0 .And.;
					SF3->(FieldPos("F3_CODNFE")) > 0 .And.;
					SF3->(FieldPos("F3_CREDNFE")) > 0
	If lNFEletr
		aNFEletr[01] := (cAlias)->F1_NFELETR
		aNFEletr[02] := (cAlias)->F1_EMINFE
		aNFEletr[03] := (cAlias)->F1_HORNFE
		aNFEletr[04] := (cAlias)->F1_CODNFE
		aNFEletr[05] := (cAlias)->F1_CREDNFE
		If SF1->(FieldPos("F1_NUMRPS")) > 0
			aNFEletr[06] := (cAlias)->F1_NUMRPS
		Endif
	Endif
OtherWise
	If Empty(cAlias)
		cAlias := "SF2"
		dbSelectArea("SF2")
		MsGoto(nRecNF)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o cabecalho da NF de Saida                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCliFor		:= (cAlias)->F2_CLIENTE
	cLoja			:= (cAlias)->F2_LOJA
	cNumNF		:= (cAlias)->F2_DOC
	cSerie		:= (cAlias)->F2_SERIE
	dDEmissao	:= (cAlias)->F2_EMISSAO
	cEspecie		:= (cAlias)->F2_ESPECIE
	cFormul		:= IIf(cPaisLoc=="BRA"," ",(cAlias)->F2_FORMUL)
	If cPaisLoc <> "BRA"
		If (cAlias)->(FieldPos('F2_DTDIGIT')) > 0
			dEntrada		:= (cAlias)->F2_DTDIGIT
		Else
			dEntrada		:= dDataBase
		EndIf
	Else
		dEntrada		:= (cAlias)->F2_EMISSAO
	Endif
	If cPaisLoc<>"BRA"
		cTipo:=(cAlias)->F2_TIPO
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a NF esta carregada nas Funcoes Fiscais.( Inclusao )  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nCaso == 1 .AND. !MaFisFound("NF")
		MaFisIniNF(2,nRecNF)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Campos da Nota Fiscal Eletronica³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lNFEletr	:= 	SF2->(FieldPos("F2_NFELETR")) > 0 .And.;
					SF2->(FieldPos("F2_EMINFE")) > 0 .And.;
					SF2->(FieldPos("F2_HORNFE")) > 0 .And.;
					SF2->(FieldPos("F2_CODNFE")) > 0 .And.;
					SF2->(FieldPos("F2_CREDNFE")) > 0 .And.;
					SF3->(FieldPos("F3_NFELETR")) > 0 .And.;
					SF3->(FieldPos("F3_EMINFE")) > 0 .And.;
					SF3->(FieldPos("F3_HORNFE")) > 0 .And.;
					SF3->(FieldPos("F3_CODNFE")) > 0 .And.;
					SF3->(FieldPos("F3_CREDNFE")) > 0
	If lNFEletr
		aNFEletr[01] := (cAlias)->F2_NFELETR
		aNFEletr[02] := (cAlias)->F2_EMINFE
		aNFEletr[03] := (cAlias)->F2_HORNFE
		aNFEletr[04] := (cAlias)->F2_CODNFE
		aNFEletr[05] := (cAlias)->F2_CREDNFE
	Endif
EndCase
Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclusao dos movimentos fiscais - Cabecalho e Item                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case nCaso == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclusao dos movimentos fiscais                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento de recuperacao de registros deletados do SF3                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF3")
	dbSetOrder(If(cTpOper == "S".OR.cFormul=="S",5,4))
	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			cAliasSF3 := "MaFisAtuSF3"
			lQuery    := .T.

			cQuery := "SELECT F3_FILIAL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,"
			cQuery += "F3_LOJA,F3_CFO,F3_FORMUL,F3_DTCANC, R_E_C_N_O_ SF3RECNO "
			cQuery += "FROM "+RetSqlName("SF3")+" SF3 "
			cQuery += "WHERE SF3.F3_FILIAL='"+xFilial("SF3")+"' AND "
			cQuery += "SF3.F3_SERIE='"+cSerie+"' AND "
			cQuery += "SF3.F3_NFISCAL='"+cNumNF+"' AND "
			If !(cTpOper=="S".OR.cFormul=="S")
				cQuery += "SF3.F3_CLIEFOR='"+cCliFor+"' AND "
				cQuery += "SF3.F3_LOJA='"+cLoja+"' AND "
			EndIf
			cQuery += "SF3.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY "+SqlOrder(SF3->(IndexKey()))

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3)

			TcSetField(cAliasSF3,"F3_DTCANC","D",8,0)
		Else
	#ENDIF
		dbSeek(xFilial("SF3")+IIf(cTpOper=="S".OR.cFormul=="S",cSerie+cNumNF,cCliFor+cLoja+cNumNF+cSerie))
		#IFDEF TOP
		EndIf
		#ENDIF
	While (!Eof().AND. (cAliasSF3)->F3_FILIAL == xFilial("SF3") .AND.;
			(cAliasSF3)->F3_NFISCAL == cNumNF .AND.;
			(cAliasSF3)->F3_SERIE == cSerie .AND.;
			IIf(cTpOper=="S".OR.cFormul=="S",.T.,(cAliasSF3)->F3_CLIEFOR == cCliFor .AND.;
			(cAliasSF3)->F3_LOJA == cLoja) )
		If 	((Substr((cAliasSF3)->F3_CFO,1,1) < "5" .AND. (cAliasSF3)->F3_FORMUL == "S") .OR.;
				Substr((cAliasSF3)->F3_CFO,1,1) > "4").AND.!Empty((cAliasSF3)->F3_DTCANC)
			If lQuery
				aadd(aRecSF3,(cAliasSF3)->SF3RECNO)
			Else
				aadd(aRecSF3,RecNo())
			EndIf
		EndIf
		dbSelectArea(cAliasSF3)
		dbSkip()
	End
	If lQuery
		dbSelectArea(cAliasSF3)
		dbCloseArea()
		dbSelectArea("SF3")
	EndIf
	If (cPaisLoc=="BRA" .AND. AliasInDic ("SFT"))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento de recuperacao de registros deletados do SFT                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SFT")
		dbSetOrder(1)
		#IFDEF TOP
			cAliasSFT := "MaFisAtuSFT"
			lQuery    := .T.

			cQuery := "SELECT FT_FILIAL, FT_TIPOMOV,FT_NFISCAL,FT_SERIE,FT_CLIEFOR,FT_LOJA,"
			cQuery += "FT_CFOP,FT_FORMUL,FT_DTCANC, R_E_C_N_O_ SFTRECNO "
			cQuery += "FROM "+RetSqlName("SFT")+" SFT "
			cQuery += "WHERE SFT.FT_FILIAL='"+xFilial("SFT")+"' AND "
			cQuery += "SFT.FT_SERIE='"+cSerie+"' AND "
			cQuery += "SFT.FT_NFISCAL='"+cNumNF+"' AND "
			If !(cTpOper=="S".OR.cFormul=="S")
				cQuery += "SFT.FT_CLIEFOR='"+cCliFor+"' AND "
				cQuery += "SFT.FT_LOJA='"+cLoja+"' AND "
			EndIf
			cQuery += "SFT.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY "+SqlOrder(SFT->(IndexKey()))

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFT)

			TcSetField(cAliasSFT,"FT_DTCANC","D",8,0)
		#ELSE
			MsSeek(xFilial("SFT")+cTpOper+cSerie+cNumNF+IIf(!(cTpOper=="S".OR.cFormul=="S"),cCliFor+cLoja,""))
		#ENDIF
		While (!Eof().AND. (cAliasSFT)->FT_FILIAL == xFilial("SFT") .AND.;
			(cAliasSFT)->FT_NFISCAL == cNumNF .AND.;
			(cAliasSFT)->FT_SERIE == cSerie .AND.;
			IIf(cTpOper=="S".OR.cFormul=="S",.T.,(cAliasSFT)->FT_CLIEFOR == cCliFor .AND.;
			(cAliasSFT)->FT_LOJA == cLoja) )

			If 	(((cAliasSFT)->FT_TIPOMOV=="E" .AND. (cAliasSFT)->FT_FORMUL == "S") .OR.;
			    (cAliasSFT)->FT_TIPOMOV=="S") .AND. !Empty((cAliasSFT)->FT_DTCANC)
				If lQuery
					aadd(aRecSFT,(cAliasSFT)->SFTRECNO)
				Else
					aadd(aRecSFT,RecNo())
				EndIf
			EndIf
			dbSelectArea(cAliasSFT)
			dbSkip()
		End
		If lQuery
			dbSelectArea(cAliasSFT)
			dbCloseArea()
			dbSelectArea("SFT")
		EndIf
	EndIf
	If (cPaisLoc=="BRA" .AND. AliasInDic ("CD2"))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento de recuperacao de registros deletados do CD2                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("CD2")
		dbSetOrder(2)
		#IFDEF TOP
			cAliasCD2 := "MaFisAtuCD2"
			lQuery    := .T.

			cQuery := "SELECT CD2_FILIAL,CD2_TPMOV,CD2_DOC,CD2_SERIE,CD2_CODCLI,CD2_LOJCLI,CD2_CODFOR,CD2_LOJFOR,R_E_C_N_O_ CD2RECNO "
			cQuery += "FROM "+RetSqlName("CD2")+" CD2 "
			cQuery += "WHERE CD2.CD2_FILIAL='"+xFilial("CD2")+"' AND "
			cQuery += "CD2.CD2_SERIE='"+cSerie+"' AND "
			cQuery += "CD2.CD2_DOC='"+cNumNF+"' AND "
			If !(cTpOper=="S".OR.cFormul=="S")
				cQuery += "CD2.CD2_CODFOR='"+cCliFor+"' AND "
				cQuery += "CD2.CD2_LOJFOR='"+cLoja+"' AND "
			EndIf
			cQuery += "CD2.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY "+SqlOrder(CD2->(IndexKey()))

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCD2)
		#ELSE
			MsSeek(xFilial("CD2")+cTpOper+cSerie+cNumNF+IIf(!(cTpOper=="S".OR.cFormul=="S"),cCliFor+cLoja,""))
		#ENDIF
		While (!Eof().AND. (cAliasCD2)->CD2_FILIAL == xFilial("CD2") .AND.;
			(cAliasCD2)->CD2_TPMOV == cTpOper .And.;
			(cAliasCD2)->CD2_DOC == cNumNF .AND.;
			(cAliasCD2)->CD2_SERIE == cSerie .AND.;
			IIf(cTpOper=="S".OR.cFormul=="S",.T.,(cAliasCD2)->CD2_CODFOR == cCliFor .AND.;
			(cAliasCD2)->CD2_LOJFOR == cLoja) )

			If lQuery
				CD2->(dbGoto((cAliasCD2)->CD2RECNO))
			EndIf

			RecLock("CD2")
			dbdelete()
			MsUnLock()

			dbSelectArea(cAliasCD2)
			dbSkip()
		End
		If lQuery
			dbSelectArea(cAliasCD2)
			dbCloseArea()
			dbSelectArea("CD2")
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava arquivo de Livros Fiscais (SF3)                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aLivro	    := MaFisRet(,"NF_LIVRO")
	aFixos		:= MatxAfixos()
	lObserv		:= .F.
	If cPaisLoc=="BRA"
		AEval(aLivro,{ |x| (nVlrTotal+=IIf(x[3]+x[4]+x[5]+x[6]+x[7]+x[9]+x[10]+x[11]>0,x[3]+x[4]+x[5]+x[6]+x[7]+x[9]+x[10]+x[11],0)),((lObserv  := IIf(!Empty(x[24]),.T.,lObserv)))})
	Else
		If Len(aLivro) > 0
			aLivro:=Adel(aLivro,1)
			aLivro:=aSize(aLivro,Len(aLivro)-1)
			nVlrTotal:=Len(aLivro)
		Endif
	Endif
	If nVlrTotal > 0.00 .OR. lObserv
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exclui os registros cancelados que serao reaproveitados em outro³
		//³documento fiscal.                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nZ := 1 To Len(aRecSFT)
			SFT->(MsGoto(aRecSFT[nZ]))
			RecLock("SFT",.F.)
			SFT->(dbDelete())
			MsUnLock()
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Coloca os lancamentos fiscais em ordem de CFO e CFO Extendido          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc=="BRA"
			Asort(aLivro,,,{|x,y| (x[1]+x[31])<(y[1]+y[31])})
		Endif
		For nX := 1 To Len(aLivro)
			If !Empty(aLivro[nX][1]) .OR. cPaisLoc<>"BRA"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Recupera os registros cancelados                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nX <= Len(aRecSF3)
					SF3->(MsGoto(aRecSF3[nX]))
					RecLock("SF3",.F.)
				Else
					RecLock("SF3",.T.)
				EndIf
				For nY := 1 to Len(aFixos)
					If SF3->(FieldPos(aFixos[nY][1])) > 0
                        If cPaisLoc <>  "BRA" .AND. ValType(aLivro[nX][nY]) == "N" .AND. Subs(aFixos[nY][1],1,6) $ "F3_VAL|F3_BAS|F3_RET|F3_DES"
							FieldPut(FieldPos(aFixos[nY][1]),Round(aLivro[nX][nY],MsDecimais(1)))
						Else
							FieldPut(FieldPos(aFixos[nY][1]),aLivro[nX][nY])
						EndIf
					EndIf
				Next nY
				SF3->F3_FILIAL	:= xFilial("SF3")
				SF3->F3_ENTRADA	:= IIF(Empty(dEntrada),dDatabase,dEntrada)
				SF3->F3_NFISCAL	:= cNumNF
				SF3->F3_SERIE  	:= cSerie
				SF3->F3_CLIEFOR	:= cCliFor
				SF3->F3_LOJA	:= cLoja
				SF3->F3_CLIENT 	:= MaFisRet(,"NF_CLIENT")
				SF3->F3_LOJENT	:= MaFisRet(,"NF_LOJENT")
				SF3->F3_PDV     := cPDV
				If lTMSUFPAG .AND. !Empty(MaFisRet(,"NF_PNF_UF")) .AND. ("CTR"$AllTrim(aNFCab[NF_ESPECIE]).OR."NFST"$AllTrim(aNFCab[NF_ESPECIE]))
					SF3->F3_ESTADO	:= MaFisRet(,"NF_PNF_UF")
				Else
					SF3->F3_ESTADO	:= IIF(cTpOper=="E",MaFisRet(,"NF_UFORIGEM"),MaFisRet(,"NF_UFDEST"))
				EndIf
				SF3->F3_EMISSAO	:= dDEmissao
				SF3->F3_FORMUL	:= IIF(cTpOper=="E".OR.cPaisLoc<>"BRA",cFormul," ")
				SF3->F3_ESPECIE	:= cEspecie
				SF3->F3_DTCANC	:= CTOD("")
				//
				If Type("l920Auto") == "L" .AND. !l920Auto
					SF3->F3_DOCOR := If(lLote,c920NfFim,SF3->F3_DOCOR)
					SF3->F3_TIPO  := If(lLote,"L",SF3->F3_TIPO)
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Campos da Nota Fiscal Eletronica de Sao Paulo³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lNFEletr
					SF3->F3_NFELETR	:= aNFEletr[01]
					SF3->F3_EMINFE	:= aNFEletr[02]
					SF3->F3_HORNFE	:= aNFEletr[03]
					SF3->F3_CODNFE	:= aNFEletr[04]
					SF3->F3_CREDNFE	:= aNFEletr[05]
					If SF3->(FieldPos("F3_NUMRPS")) > 0
						SF3->F3_NUMRPS	:= aNFEletr[06]
					Endif
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada para atualizar o livro fiscal   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("MTA920L")
					ExecBlock("MTA920L",.F.,.F.)
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Livro de ICMS - Ajuste SINEF 03/04 - DOU 08.04.04         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cPaisLoc=="BRA"
					If !Empty(aLivro[nX][35]) .AND. (aLivro[nX][LF_ISS_ISENICM]<>0 .OR. aLivro[nX][LF_ISS_OUTRICM]<>0)
						aSF3 := {}
					    For nY := 1 To SF3->(FCount())
					    	aadd(aSF3,SF3->(FieldGet(nY)))
					    Next nY
						RecLock("SF3",.T.)
						For nY := 1 To Len(aSF3)
							If !"_MSIDENT"$SF3->(FieldName(nY))
								FieldPut(nY,aSF3[nY])
							EndIf
						Next nY
						SF3->F3_TIPO    := "N"
						SF3->F3_ALIQICM := aLivro[nX][LF_ISS_ALIQICMS]
						SF3->F3_BASEICM := 0
						SF3->F3_VALICM  := 0
						SF3->F3_ISENICM := aLivro[nX][LF_ISS_ISENICM]
						SF3->F3_OUTRICM := aLivro[nX][LF_ISS_OUTRICM]
						SF3->F3_BASEIPI := 0
						SF3->F3_VALIPI  := 0
						SF3->F3_ISENIPI := aLivro[nX][LF_ISS_ISENIPI]
						SF3->F3_OUTRIPI := aLivro[nX][LF_ISS_OUTRIPI]
						SF3->F3_CODISS  := ""
						SF3->F3_OBSERV  := "NOTA FISCAL DE SERVICO"
						//
						//Desconto Zona Franca de Manaus
						//
						If (SF3->(FieldPos("F3_DESCZFR"))>0)
					 		SF3->F3_DESCZFR := aLivro[nX][LF_DESCZFR]
				 		EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Nota Fiscal Eletronica de Sao Paulo³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lNFEletr
							SF3->F3_NFELETR	:= aNFEletr[01]
							SF3->F3_EMINFE	:= aNFEletr[02]
							SF3->F3_HORNFE	:= aNFEletr[03]
							SF3->F3_CODNFE	:= aNFEletr[04]
							SF3->F3_CREDNFE	:= aNFEletr[05]
							If SF3->(FieldPos("F3_NUMRPS")) > 0
								SF3->F3_NUMRPS	:= aNFEletr[06]
							Endif
						Endif
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Ponto de entrada para atualizar o livro fiscal   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ExistBlock("MTA920L")
							ExecBlock("MTA920L",.F.,.F.)
						EndIf
					EndIf
				EndIf
				If (cPaisLoc=="BRA" .AND. AliasInDic("SFT"))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava arquivo de Livros Fiscais (SFT)                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aWriteSFT := MaFisRelImp("MT100",{"SFT"})
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Recupera os registros cancelados                                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nZ := 1 To Len(aNfItem)
						If (aNfItem[nZ][IT_LIVRO][LF_IDENT]==aLivro[nX][LF_IDENT])
							RecLock("SFT",.T.)
							SFT->FT_FILIAL	:= xFilial("SFT")
							SFT->FT_TIPOMOV := cTpOper
							SFT->FT_EMISSAO	:= dDEmissao
							SFT->FT_ENTRADA	:= IIF(Empty(dEntrada),dDatabase,dEntrada)
							SFT->FT_NFISCAL	:= cNumNF
							SFT->FT_SERIE  	:= cSerie
							SFT->FT_CLIEFOR	:= cCliFor
							SFT->FT_LOJA	:= cLoja
							SFT->FT_CLIENT 	:= MaFisRet(,"NF_CLIENT")
							SFT->FT_LOJENT	:= MaFisRet(,"NF_LOJENT")
							SFT->FT_PDV     := cPDV
							SFT->FT_IDENTF3	:=	aNfItem[nZ][IT_LIVRO][LF_IDENT]
							If lTMSUFPAG .AND. !Empty(MaFisRet(,"NF_PNF_UF")) .AND. ("CTR"$AllTrim(aNFCab[NF_ESPECIE]).OR."NFST"$AllTrim(aNFCab[NF_ESPECIE]))
								SFT->FT_ESTADO	:= MaFisRet(,"NF_PNF_UF")
							Else
								SFT->FT_ESTADO	:= IIF(cTpOper=="E",MaFisRet(,"NF_UFORIGEM"),MaFisRet(,"NF_UFDEST"))
							EndIf
							SFT->FT_FORMUL	:= IIF(cTpOper=="E".OR.cPaisLoc<>"BRA",cFormul," ")
							SFT->FT_ESPECIE	:= cEspecie
							SFT->FT_DTCANC	:= CTOD("")
							SFT->FT_TIPO  	:=  aNfItem[nZ][IT_LIVRO][LF_TIPO]
							SFT->FT_POSIPI	:=	aNfItem[nZ][IT_LIVRO][LF_POSIPI]
							SFT->FT_CLASFIS	:=	aNfItem[nZ][IT_LIVRO][LF_CLASFIS]
							SFT->FT_CTIPI	:=	aNfItem[nZ][IT_LIVRO][LF_CTIPI]
							SFT->FT_ESTOQUE	:=	aNfItem[nZ][IT_LIVRO][LF_ESTOQUE]
							SFT->FT_DESPIPI	:=	aNfItem[nZ][IT_LIVRO][LF_DESPIPI]
							SFT->FT_ISENICM	:=	aNfItem[nZ][IT_LIVRO][LF_ISENICM]-aNfItem[nZ][IT_LIVRO][LF_ISENRET]
							SFT->FT_OUTRICM	:=	aNfItem[nZ][IT_LIVRO][LF_OUTRICM]-aNfItem[nZ][IT_LIVRO][LF_OUTRRET]
							SFT->FT_ICMSRET	:=	aNfItem[nZ][IT_LIVRO][LF_ICMSRET]-(aNfItem[nZ][IT_LIVRO][LF_ISENRET]+aNfItem[nZ][IT_LIVRO][LF_OUTRRET])
							SFT->FT_ITEMORI	:=	aNfItem[nZ][IT_LIVRO][LF_ITEMORI]
							SFT->FT_ALIQIPI	:=	aNfItem[nZ][IT_LIVRO][LF_ALIQIPI]

							SFT->FT_VALINS	:=	aNfItem[nZ][IT_VALINS]
							SFT->FT_ALIQINS	:=	aNfItem[nZ][IT_ALIQINS]
							SFT->FT_BASEINS	:=	aNfItem[nZ][IT_BASEINS]
							SFT->FT_VALINS	:=	aNfItem[nZ][IT_VALINS]
							SFT->FT_ALIQIRR	:=	aNfItem[nZ][IT_ALIQIRR]
							SFT->FT_BASEIRR	:=	aNfItem[nZ][IT_BASEIRR]
							SFT->FT_SEGURO	:=	aNfItem[nZ][IT_SEGURO]
							SFT->FT_FRETE	:=	aNfItem[nZ][IT_FRETE]
							SFT->FT_PRODUTO	:=	aNfItem[nZ][IT_PRODUTO]
							SFT->FT_BASEIRR	:=	aNfItem[nZ][IT_BASEIRR]
							SFT->FT_ALIQIRR	:=	aNfItem[nZ][IT_ALIQIRR]
							SFT->FT_VALIRR	:=	aNfItem[nZ][IT_VALIRR]
							SFT->FT_BASEINS	:=	aNfItem[nZ][IT_BASEINS]
							SFT->FT_ALIQINS	:=	aNfItem[nZ][IT_ALIQINS]
							SFT->FT_VALINS	:=	aNfItem[nZ][IT_VALINS]
							SFT->FT_ITEM	:=	aNfItem[nZ][IT_ITEM]
							SFT->FT_QUANT	:=	aNfItem[nZ][IT_QUANT]
							SFT->FT_PRCUNIT	:=	aNfItem[nZ][IT_PRCUNI]
							SFT->FT_TOTAL	:=	aNfItem[nZ][IT_VALMERC]
							SFT->FT_DESCONT	:=	aNfItem[nZ][IT_DESCONTO]
							SFT->FT_NFORI	:=	aNfItem[nZ][IT_NFORI]
							SFT->FT_SERORI	:=	aNfItem[nZ][IT_SERORI]
							SFT->FT_PESO	:=	aNfItem[nZ][IT_PESO]
							//
							//PIS/PASEP Apuracao
							SFT->FT_BASEPIS:=	aNfItem[nZ][IT_BASEPS2]
							SFT->FT_ALIQPIS:=	aNfItem[nZ][IT_ALIQPS2]
							SFT->FT_VALPIS	:=	aNfItem[nZ][IT_VALPS2]
							//
							//COFINS Apuracao
							SFT->FT_BASECOF	:=	aNfItem[nZ][IT_BASECF2]
							SFT->FT_ALIQCOF	:=	aNfItem[nZ][IT_ALIQCF2]
							SFT->FT_VALCOF	:=	aNfItem[nZ][IT_VALCF2]
							//
							//CSLL Apuracao
							SFT->FT_BASECSL	:=	0
							SFT->FT_ALIQCSL	:=	0
							SFT->FT_VALCSL	:=	0
							//
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Nota Fiscal Eletronica de Sao Paulo³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lNFEletr .And. ;
								SFT->(FieldPos("FT_NFELETR")) > 0 .And.;
								SFT->(FieldPos("FT_EMINFE")) > 0 .And.;
								SFT->(FieldPos("FT_HORNFE")) > 0 .And.;
								SFT->(FieldPos("FT_CODNFE")) > 0 .And.;
								SFT->(FieldPos("FT_CREDNFE")) > 0
								SFT->FT_NFELETR	:= aNFEletr[01]
								SFT->FT_EMINFE	:= aNFEletr[02]
								SFT->FT_HORNFE	:= aNFEletr[03]
								SFT->FT_CODNFE	:= aNFEletr[04]
								SFT->FT_CREDNFE	:= aNFEletr[05]
								If SFT->(FieldPos("FT_NUMRPS")) > 0
									SFT->FT_NUMRPS	:= aNFEletr[06]
								Endif
							Endif
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Regime Especial de Substituicao Tributaria - MG³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If SFT->(FieldPos("FT_RGESPST")) >0
								SFT->FT_RGESPST := aNfItem[nZ][IT_RGESPST]
							Endif
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Fundersul - Mato Grosso do Sul³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If SFT->(FieldPos("FT_VALFDS")) > 0
								SFT->FT_VALFDS := aNfItem[nZ][IT_VALFDS]
							Endif
							If SFT->(FieldPos("FT_PRFDSUL")) > 0
								SFT->FT_PRFDSUL := aNfItem[nZ][IT_PRFDSUL]
							Endif
							If SFT->(FieldPos("FT_UFERMS")) > 0
								SFT->FT_UFERMS := aNfItem[nZ][IT_UFERMS]
							Endif
							For nY := 1 to Len(aWriteSFT)
								If !(AllTrim (aWriteSFT[nY][2])$"FT_ISENICM/FT_OUTRICM/FT_ICMSRET/FT_FORMUL")	//SAO GRAVADOS ACIMA
									FieldPut(FieldPos(aWriteSFT[nY][2]),MaFisRet(nZ,aWriteSFT[nY][3]))
								EndIf
							Next nY
						EndIf
						If AliasInDic("CD2")
							For nA := 1 To Len(aNfItem[nZ][IT_SPED])
								RecLock("CD2",.T.)
								CD2->CD2_FILIAL := xFilial("CD2")
								CD2->CD2_TPMOV  := cTpOper
								CD2->CD2_SERIE  := cSerie
								CD2->CD2_DOC    := cNumNF
								If (cTpOper == "S" .And. !aNfItem[nZ][IT_LIVRO][LF_TIPO]$"DB") .Or.;
									(cTpOper == "E" .And. aNfItem[nZ][IT_LIVRO][LF_TIPO]$"DB")
									CD2->CD2_CODCLI := cCliFor
									CD2->CD2_LOJCLI := cLoja
								Else
									CD2->CD2_CODFOR := cCliFor
									CD2->CD2_LOJFOR	:= cLoja
								EndIf
								CD2->CD2_ITEM   := aNfItem[nZ][IT_SPED][nA][SP_ITEM]
								CD2->CD2_CODPRO := aNfItem[nZ][IT_SPED][nA][SP_CODPRO]
								CD2->CD2_IMP    := aNfItem[nZ][IT_SPED][nA][SP_IMP]
								CD2->CD2_ORIGEM := aNfItem[nZ][IT_SPED][nA][SP_ORIGEM]
								CD2->CD2_CST    := aNfItem[nZ][IT_SPED][nA][SP_CST]
								CD2->CD2_MODBC  := aNfItem[nZ][IT_SPED][nA][SP_MODBC]
								CD2->CD2_MVA    := aNfItem[nZ][IT_SPED][nA][SP_MVA]
								CD2->CD2_PREDBC := aNfItem[nZ][IT_SPED][nA][SP_PREDBC]
								CD2->CD2_BC     := aNfItem[nZ][IT_SPED][nA][SP_BC]
								CD2->CD2_ALIQ   := aNfItem[nZ][IT_SPED][nA][SP_ALIQ]
								CD2->CD2_VLTRIB := aNfItem[nZ][IT_SPED][nA][SP_VLTRIB]
								CD2->CD2_QTRIB  := aNfItem[nZ][IT_SPED][nA][SP_QTRIB]
								CD2->CD2_PAUTA  := aNfItem[nZ][IT_SPED][nA][SP_PAUTA]
								CD2->CD2_COD_MN := aNfItem[nZ][IT_SPED][nA][SP_COD_MN]
								MsUnLock()
            				Next nA
						EndIf
					Next nZ
				EndIf
			EndIf
		Next nX
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta os registros fiscais cancelados.      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aRecSF3) > Len(aLivro)
		For nX := (Len(aLivro)+1) To Len(aRecSF3)
			SF3->(MsGoto(aRecSF3[nX]))
			RecLock("SF3",.F.)
			SF3->(dbDelete())
		Next nX
	EndIf
	If (cPaisLoc=="BRA" .AND. AliasInDic ("SFT"))
		If Len(aRecSFT) > Len(aNfItem)
			For nX := (Len(aNfItem)+1) To Len(aRecSFT)
				SFT->(MsGoto(aRecSFT[nX]))
				RecLock("SFT",.F.)
				SFT->(dbDelete())
			Next nX
		EndIf
	EndIf
OtherWise
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carega o Array contendo os Registros Fiscais (SF3)      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF3")
	dbSetOrder(If(cTpOper == "S".OR.cFormul=="S",5,4))
	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			cAliasSF3 := "MaFisAtuSF3"
			lQuery    := .T.

			cQuery := "SELECT F3_FILIAL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,"
			cQuery += "F3_LOJA,F3_CFO,F3_FORMUL,R_E_C_N_O_ SF3RECNO "
			cQuery += "FROM "+RetSqlName("SF3")+" SF3 "
			cQuery += "WHERE SF3.F3_FILIAL='"+xFilial("SF3")+"' AND "
			cQuery += "SF3.F3_SERIE='"+cSerie+"' AND "
			cQuery += "SF3.F3_NFISCAL='"+cNumNF+"' AND "
			If !(cTpOper=="S".OR.cFormul=="S")
				cQuery += "SF3.F3_CLIEFOR='"+cCliFor+"' AND "
				cQuery += "SF3.F3_LOJA='"+cLoja+"' AND "
			EndIf
			cQuery += "SF3.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY "+SqlOrder(SF3->(IndexKey()))

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
		Else
	#ENDIF
		dbSeek(xFilial("SF3")+IIf(cTpOper=="S".OR.cFormul=="S",cSerie+cNumNF,cCliFor+cLoja+cNumNF+cSerie))
		#IFDEF TOP
		EndIf
		#ENDIF
	While (!Eof().AND. (cAliasSF3)->F3_FILIAL == xFilial("SF3") .AND.;
			(cAliasSF3)->F3_NFISCAL == cNumNF .AND.;
			(cAliasSF3)->F3_SERIE == cSerie .AND.;
			IIf(cTpOper=="S".OR.cFormul=="S",.T.,(cAliasSF3)->F3_CLIEFOR == cCliFor .AND.;
			(cAliasSF3)->F3_LOJA == cLoja) )
		If ((cTpOper == "E" .AND. Substr((cAliasSF3)->F3_CFO,1,1) < "5" .AND. (cAliasSF3)->F3_FORMUL == cFormul) .OR.;
				(cTpOper == "S" .AND. Substr((cAliasSF3)->F3_CFO,1,1) > "4"))
			If lQuery
				aadd(aRecSF3,(cAliasSF3)->SF3RECNO)
			Else
				aadd(aRecSF3,RecNo())
			EndIf
		EndIf
		dbSelectArea(cAliasSF3)
		dbSkip()
	End
	If lQuery
		dbSelectArea(cAliasSF3)
		dbCloseArea()
		dbSelectArea("SF3")
	EndIf
	If (cPaisLoc=="BRA" .AND. AliasInDic ("SFT"))
		dbSelectArea("SFT")
		dbSetOrder(1)
		#IFDEF TOP
			cAliasSFT := "MaFisAtuSFT"
			lQuery    := .T.

			cQuery := "SELECT FT_FILIAL, FT_TIPOMOV, FT_NFISCAL,FT_SERIE,FT_CLIEFOR,FT_LOJA,"
			cQuery += "FT_CFOP,FT_FORMUL,FT_DTCANC, R_E_C_N_O_ SFTRECNO "
			cQuery += "FROM "+RetSqlName("SFT")+" SFT "
			cQuery += "WHERE SFT.FT_FILIAL='"+xFilial("SFT")+"' AND "
			cQuery += "SFT.FT_SERIE='"+cSerie+"' AND "
			cQuery += "SFT.FT_NFISCAL='"+cNumNF+"' AND "
			If !(cTpOper=="S".OR.cFormul=="S")
				cQuery += "SFT.FT_CLIEFOR='"+cCliFor+"' AND "
				cQuery += "SFT.FT_LOJA='"+cLoja+"' AND "
			EndIf
			cQuery += "SFT.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY "+SqlOrder(SFT->(IndexKey()))

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFT)

			TcSetField(cAliasSFT,"FT_DTCANC","D",8,0)
		#ELSE
			MsSeek(xFilial("SFT")+cTpOper+cSerie+cNumNF+IIf(!(cTpOper=="S".OR.cFormul=="S"),cCliFor+cLoja,""))
		#ENDIF
		While (!Eof().AND. (cAliasSFT)->FT_FILIAL == xFilial("SFT") .AND.;
			(cAliasSFT)->FT_NFISCAL == cNumNF .AND.;
			(cAliasSFT)->FT_SERIE == cSerie .AND.;
			IIf(cTpOper=="S".OR.cFormul=="S",.T.,(cAliasSFT)->FT_CLIEFOR == cCliFor .AND.;
			(cAliasSFT)->FT_LOJA == cLoja) )

			If 	(((cAliasSFT)->FT_TIPOMOV=="E" .AND. (cAliasSFT)->FT_FORMUL==cFormul).OR.(cAliasSFT)->FT_TIPOMOV=="S")
				If lQuery
					aadd(aRecSFT,(cAliasSFT)->SFTRECNO)
				Else
					aadd(aRecSFT,RecNo())
				EndIf
			EndIf
			dbSelectArea(cAliasSFT)
			dbSkip()
		End
		If lQuery
			dbSelectArea(cAliasSFT)
			dbCloseArea()
			dbSelectArea("SFT")
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cancelamento dos Livros Fiscais.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SF3')
	For nX := 1 to Len(aRecSF3)
		If cFormul == "S" .OR. cTpOper == "S"
			MsGoto(aRecSF3[nX])
			RecLock("SF3",.F.)
			If IIf(cPaisLoc<>"BRA",lAnulaSF3,.T.)
				SF3->F3_DTCANC := dDataBase
				SF3->F3_OBSERV := STR0008 //"NF CANCELADA"
			Else
				dbDelete()
			EndIf
			MsUnlock()
			If cTpOper == "S"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pto de Entrada utilizado na Argentina                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("M520SF3") // LUCAS 18/08/99 ARGENTINA
					ExecBlock("M520SF3",.F.,.F.)
				Endif
			EndIf
		Else
			MsGoto(aRecSF3[nX])
			RecLock("SF3",.F.,.T.)
			dbDelete()
		EndIf
	Next nX
	If (cPaisLoc=="BRA" .AND. AliasInDic ("SFT"))
		dbSelectArea("SFT")
		For nX := 1 to Len(aRecSFT)
			If cFormul == "S" .OR. cTpOper == "S"
				MsGoto(aRecSFT[nX])
				RecLock("SFT",.F.)
				If IIf(cPaisLoc<>"BRA",lAnulaSF3,.T.)
					SFT->FT_DTCANC := dDataBase
					SFT->FT_OBSERV := STR0008 //"NF CANCELADA"
				Else
					dbDelete()
				EndIf
				MsUnlock()
				If cTpOper == "S"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Pto de Entrada utilizado na Argentina                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ExistBlock("M520SFT")
						ExecBlock("M520SFT",.F.,.F.)
					Endif
				EndIf
			Else
				MsGoto(aRecSFT[nX])
				RecLock("SFT",.F.)
				dbDelete()
			EndIf
		Next nX
	EndIf
EndCase
RestArea(aAreaSF1)
RestArea(aAreaSF2)
RestArea(aArea)
Return(.T.)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaFisSXRef³ Autor ³ Eduardo Riera         ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de avalicao das referencias existentes para um deter- ³±±
±±³          ³minada tabela no dicionario de dados                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Tabela do Dicionario de dados                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array com as referencias da funcao fiscal             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo verificar e retornar as referen³±±
±±³          ³cias da funcao fiscal com base no dicionario de dados, para  ³±±
±±³          ³recuperar os valores da funcao fiscal                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisSXRef(cAlias)

Local aArea    := GetArea()
Local aRefer   := {}
Local nScan    := 0
Local nX       := 0

DEFAULT aRefSX3 := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o alias solicitado esta no cache de memoria  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nScan := aScan(aRefSx3,{|x| x[1] == cAlias})
If nScan == 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o Cache                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisRelImp("",{cAlias})
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem os dados do cache                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aRefSX3)
	If aRefSX3[nX][1] == cAlias
		aadd(aRefer,{aRefSX3[nX][2],aRefSX3[nX][3]})
	EndIf
Next nX

RestArea(aArea)

Return(aRefer)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaFisGetRf³ Autor ³ Eduardo Riera         ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de avalicao das referencias existentes em uma         ³±±
±±³          ³expressao string.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Expressao contendo as referencias.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array com a seguinte estrutura                        ³±±
±±³          ³       [1] Codigo da Referencia                              ³±±
±±³          ³       [2] Nome do programa vinculado a referencia           ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo verificar e retornar as referen³±±
±±³          ³cias da funcao fiscal com base numa expressao string.        ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisGetRF(cValid)

Local nPRefer := 0
Local cRefer  := ""
Local cProg   := ""

cValid	:= Upper(StrTran(cValid," ",""))

Do Case
Case ( "MAFISREF"$cValid )
	nPRefer := AT('MAFISREF("',cValid) + 10
	cValid  := SubStr(cValid,nPRefer)
	cRefer  := SubStr(cValid,1,AT(',',cValid)-2)
	cValid  := SubStr(cValid,AT(',',cValid)+1)
	cProg   := SubStr(cValid,2,AT(',',cValid)-3)
Case ( "MAFISGET"$cValid )
	nPRefer := AT('MAFISGET("',cValid) + 10
	cValid  := SubStr(cValid,nPRefer)
	cRefer  := SubStr(cValid,1,AT(')',cValid)-2)
EndCase
Return({cRefer,cProg})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MaFisEnd ³ Autor ³ Edson Maricate        ³ Data ³10.01.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Finaliza o uso das funcoes Fiscais.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1: Indica se deve reinicializar o codeblock da funcao  ³±±
±±³          ³        MaFisRodape ( bFisRefresh )                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisEnd(lRodape)

DEFAULT lRodape := .T.
aNfCab	:= Nil
aNfItem	:= Nil
aItemDec:= Nil
aSaveDec:= Nil
aAuxOri	:= Nil
aTes    := Array(MAX_TS)
bLivroRefresh := Nil
If lRodape
	bFisRefresh := Nil
EndIf
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaRateio  ³ Autor ³Edson Maricate         ³ Data ³20.12.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de rateio das despesas acessorias.                    ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Nome da Referencia da despesas acessoria              ³±±
±±³          ³ExpN2: Valor atual da despesa acessoria                      ³±±
±±³          ³ExpN3: Novo valor da despesa acessoria                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar o rateio das despesas  ³±±
±±³          ³acessorias sobre todos os itens da nota fiscal, exceto os    ³±±
±±³          ³que possuirem a referencia ISS.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaRateio(cReferencia,nAnterior,nAtual,lDupl)

Local aRateio   := {}
Local nX		 := 0
Local nDiferenca := 0
Local nY		 := 0
Local nSoma 	 := 0
Local nValMISS   := 0
Local nValDISS   := 0
Local nPesoMISS  := 0
Local aPosCpo	 := MaFisScan(cReferencia)
Local cTpRatDesp 	:= Substr(MV_RATDESP,AT("DESP=",MV_RATDESP)+5,1)
Local cTpRatFrete	:= Substr(MV_RATDESP,AT("FR=",MV_RATDESP)+3,1)
Local cTpRatSeg	:= Substr(MV_RATDESP,AT("SEG=",MV_RATDESP)+4,1)
Local lRatDesc		:=	(cReferencia=="IT_DESCONTO".AND.cPaisLoc<>"BRA".AND.aNfCab[NF_OPERNF]=="S".AND.SuperGetMV('MV_DESCSAI')=='1')

DEFAULT lDupl := .F.

If ExistBlock("MARATEIO")
	aRateio := ExecBlock("MARATEIO",.F.,.F.,{cTpRatDesp,cTpRatFrete,cTpRatSeg})
	cTpRatDesp  := aRateio[1]
	cTpRatFrete := aRateio[2]
	cTpRatSeg   := aRateio[3]
EndIf

If ( "FRETE"$cReferencia .OR. "SEGURO"$cReferencia .OR. "DESPESA"$cReferencia .OR. "VLR_FRT"$cReferencia )
	If aNfCab[NF_PESO]<>0.AND.((cReferencia=="IT_FRETE".AND.cTpRatFrete=="2").OR.;
			(cReferencia=="IT_DESPESA".AND.cTpRatDesp=="2").OR.;
			(cReferencia=="IT_SEGURO".AND.cTpRatSeg=="2").OR.;
			(cReferencia=="IT_VLR_FRT".AND.cTpRatFrete=="2"))
		aEval(aNfItem,{|x| nPesoMISS += If(!x[IT_DELETED] .AND. x[IT_RATEIOISS]=="S" .AND. (!lDupl .OR. x[IT_BASEDUP]>0),x[IT_PESO],0)})
	Else
		aEval(aNfItem,{|x| nValMISS += If(!x[IT_DELETED] .AND. x[IT_RATEIOISS]=="S" .AND. (!lDupl .OR. x[IT_BASEDUP]>0),(x[IT_VALMERC]+x[IT_VNAGREG]),0)})
		aEval(aNfItem,{|x| nValDISS += If(!x[IT_DELETED] .AND. x[IT_RATEIOISS]=="S" .AND. (!lDupl .OR. x[IT_BASEDUP]>0),((x[IT_VALMERC]-x[IT_DESCONTO])+x[IT_VNAGREG]),0)})
	EndIf
EndIf

If nAnterior > 0
	nDiferenca := (nAtual-nAnterior) / nAnterior
	For nX	:= 1 to Len(aNfItem)
		If !aNfItem[nX][IT_DELETED] .AND.;
			!( aNfItem[nX][IT_RATEIOISS]=="S" .AND. ("FRETE"$cReferencia .OR. "SEGURO"$cReferencia .OR. "DESPESA"$cReferencia .OR. "VLR_FRT"$cReferencia) ) .And.;
			(!lDupl .Or. aNfItem[nX][IT_BASEDUP]>0)
			nY := nX
			If ValType(aPosCpo) == "A"
				aNfItem[nX][aPosCpo[1]][aPosCpo[2]]	:= (1+nDiferenca)*aNfItem[nX][aPosCpo[1]][aPosCpo[2]]
				nSoma += aNfItem[nX][aPosCpo[1]][aPosCpo[2]]
			Else
				If lRatDesc
					aNFitem[nX][IT_VALMERC] +=	 aNfItem[nX][Val(aPosCpo)]
					aNfItem[nX][Val(aPosCpo)] := (1+nDiferenca)*aNfItem[nX][Val(aPosCpo)]
					nSoma += aNfItem[nX][Val(aPosCpo)]
				Else
					aNfItem[nX][Val(aPosCpo)] := (1+nDiferenca)*aNfItem[nX][Val(aPosCpo)]
					nSoma += aNfItem[nX][Val(aPosCpo)]
				Endif
			EndIf
		EndIf
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua a correcao da dizima no primeiro item.          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nY <> 0
		If ValType(aPosCpo) == "A"
			aNfItem[nY][aPosCpo[1]][aPosCpo[2]] += nAtual-nSoma
		Else
			aNfItem[nY][Val(aPosCpo)] += nAtual-nSoma
		EndIf
	EndIf
Else
	For nX	:= 1 to Len(aNfItem)
		If !aNfItem[nX][IT_DELETED] .AND.;
			!( aNfItem[nX][IT_RATEIOISS]=="S" .AND. ("FRETE"$cReferencia .OR. "SEGURO"$cReferencia .OR. "DESPESA"$cReferencia .OR. "VLR_FRT"$cReferencia) ).And.;
			(!lDupl .Or. aNfItem[nX][IT_BASEDUP]>0)
			nY := nX
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Efetua o rateio do valor informado nos itens da NF     ³
			//³ O rateio das despesas ( frete/seguro/despesas ) podera ³
			//³ ser efetuado por valor ou peso, de acordo com a config.³
			//³ do parametro MV_RATDESP.                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aNfCab[NF_PESO]<>0.AND.((cReferencia=="IT_FRETE".AND.cTpRatFrete=="2").OR.;
					(cReferencia=="IT_DESPESA".AND.cTpRatDesp=="2").OR.;
					(cReferencia=="IT_SEGURO".AND.cTpRatSeg=="2").OR.;
					(cReferencia=="IT_VLR_FRT".AND.cTpRatFrete=="2"))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Rateio por Peso.    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ValType(aPosCpo) == "A"
					aNfItem[nX][aPosCpo[1]][aPosCpo[2]]	+= (nAtual-nAnterior)*(aNfItem[nX][IT_PESO]/(aNfCab[NF_PESO]-nPesoMISS))
					nSoma += aNfItem[nX][aPosCpo[1]][aPosCpo[2]]
				Else
					aNfItem[nX][Val(aPosCpo)] += (nAtual-nAnterior)*(aNfItem[nX][IT_PESO]/(aNfCab[NF_PESO]-nPesoMISS))
					nSoma += aNfItem[nX][Val(aPosCpo)]
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Rateio por Valor.   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ValType(aPosCpo) == "A"
					aNfItem[nX][aPosCpo[1]][aPosCpo[2]] += NoRound((nAtual-nAnterior)*(aNfItem[nX][IT_VALMERC]/((aNfCab[NF_VALMERC]+aNfCab[NF_VNAGREG])-nValMISS)),MsDecimais(aNfCab[NF_MOEDA]))
					nSoma += aNfItem[nX][aPosCpo[1]][aPosCpo[2]]
				Else
					If lRatDesc
						aNFitem[nX][IT_VALMERC] +=	NoRound(aNfItem[nX][Val(aPosCpo)],MsDecimais(aNfCab[NF_MOEDA]))
						aNfItem[nX][Val(aPosCpo)] 	+= NoRound((nAtual-nAnterior)*(aNfItem[nX][IT_VALMERC]/((aNfCab[NF_VALMERC]+aNfCab[NF_VNAGREG])-nValMISS)),MsDecimais(aNfCab[NF_MOEDA]))
						nSoma += aNfItem[nX][Val(aPosCpo)]
					Else
						If aNfCab[NF_ROTINA] == 'MATA461'
							aNfItem[nX][Val(aPosCpo)] += Round((nAtual-nAnterior)*((aNfItem[nX][IT_VALMERC]-aNfItem[nX][IT_DESCONTO])/(((aNfCab[NF_VALMERC]-aNfCab[NF_DESCONTO])+aNfCab[NF_VNAGREG])-nValDISS)),MsDecimais(aNfCab[NF_MOEDA]))
						Else
							aNfItem[nX][Val(aPosCpo)] += Round((nAtual-nAnterior)*(aNfItem[nX][IT_VALMERC]/((aNfCab[NF_VALMERC]+aNfCab[NF_VNAGREG])-nValMISS)),MsDecimais(aNfCab[NF_MOEDA]))
						EndIf
						nSoma += aNfItem[nX][Val(aPosCpo)]
					Endif
				EndIf
			EndIf
		EndIf
	Next nX
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua a correcao da dizima no primeiro item.          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nY <> 0
		If ValType(aPosCpo) == "A"
			aNfItem[nY][aPosCpo[1]][aPosCpo[2]] += nAtual-nSoma
		Else
			aNfItem[nY][Val(aPosCpo)]	+= nAtual-nSoma
		EndIf
	EndIf
EndIf
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaFisBrwLF³ Autor ³Edson Maricate         ³ Data ³13.12.1999 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Browse demonstrativo dos livros fiscais                      ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto ListBox a ser montado                          ³±±
±±³          ³ExpA2: Array com as coordenadas do Objeto                    ³±±
±±³          ³ExpL3: Flag de edicao do livro                               ³±±
±±³          ³       .F. - Editavel                                        ³±±
±±³          ³       .T. - Nao Editavel                                    ³±±
±±³          ³ExpA4: Array contendo os registros do Livro Fiscal           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo criar o objeto de exibicao dos ³±±
±±³          ³livros fiscais                                               ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisBrwLivro(oWnd,aPosWnd,lVisual,aRecSF3)

Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())
Local aItensLF	:= {}
Local aHeadLF	:= {}
Local aTamHead	:= {}
Local nX        := 0	//controle de loop
Local nY        := 0	//controle de loop
Local oLivro
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os campos fixos do Livro Fiscal                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aBrwLF == Nil
	aBrwLF	:= MaFisHdLF()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o cabecalho com os titulos do SF3.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX	:= 1 To Len(aBrwLF)
	aadd(aHeadLF,aBrwLF[nX][4])
	If aBrwLF[nX][5] > Len(aBrwLF[nX][4])
		aadd(aTamHead,aBrwLF[nX][5]*3)
	Else
		aadd(aTamHead,Len(aBrwLF[nX][4])*3)
	EndIf
Next nX
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os itens de visualizacao da ListBox.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
Case !Empty(aRecSF3)
	For nX	:= 1 To Len(aRecSF3)
		dbSelectArea("SF3")
		MsGoto(aRecSF3[nX])
		aadd(aItensLF,Array(Len(aBrwLF)))
		For nY := 1 to Len(aBrwLF)
			aItensLF[nX][nY] := &(aBrwLF[nY][1])
		Next nY
	Next nX
Case !Empty(aNFCab)
	aItensLF := aClone(aNFCab[NF_LIVRO])
	If cPaisLoc<>"BRA"
		If !Empty(aItensLF)
			aItensLF:=Adel(aItensLF,1)
			aItensLF:=aSize(aItensLF,Len(aItensLF)-1)
		Endif
	EndIf
EndCase
If Empty(aItensLF)
	aadd(aItensLF,Array(Len(aBrwLF)))
	For nX	:= 1 To Len(aBrwLF)
		aItensLF[1][nX] := aBrwLF[nX][2]
	Next nX
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o CodeBlock  bLivroRefresh para executar o Refresh do Objeto.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bLivroRefresh   := {|| MaFisLFNew(oLivro)}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o objeto listbox com os dados                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oLivro := TWBrowse():New( aPosWnd[1],aPosWnd[2],aPosWnd[3],aPosWnd[4],,aHeadLF,aTamHead,oWnd,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLivro:SetArray(aItensLF)
If Len(aItensLF) > 0
	oLivro:bLine 		:= {||MaFisLFLine(oLivro,aItensLF)}
EndIf
oLivro:lAutoEdit	:= !lVisual

RestArea(aAreaSX3)
RestArea(aArea)

Return ( oLivro )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaFisLFLin³ Autor ³Edson Maricate         ³ Data ³13.12.1999 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Browse demonstrativo dos livros fiscais                      ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto ListBox do Livro Fiscal                        ³±±
±±³          ³ExpA2: Array com os itens do listbox                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array com a linha do demonstrativo fiscal             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo preparar a montagem da linha a ³±±
±±³          ³ser exibida no browse do demonstrativo fiscal                ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisLFLine(oLivro,aItensLF)

Local aLinha := aItensLF[oLivro:nAt]
Local aFixos := MatXAFixos()
Local nX     := 0	//controle de loop
Local nY     := 0
Local nMax   := Len(aFixos)

For nX := 1 To nMax
	nY := aScan(aBrwLF,{|x| x[1]==aFixos[nX][1]})
	If nY <> 0 .AND. ValType(aLinha[nY]) == "N"
		If cPaisLoc == "BRA"
			aLinha[nY]:= TransForm(aLinha[nY],aBrwLF[nY][3])
		Else
			If SUBS(aBrwLF[nY][1],1,6) $ "F3_VAL|F3_BAS|F3_RET|F3_DES"
    	    	aLinha[nY] := Round(aLinha[nY],MsDecimais(1))
 	       	EndIf
			aLinha[nY]:= TransForm(aLinha[nY],aBrwLF[nY][3])
		EndIf
	EndIf
Next nX

Return( aLinha )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaFisLFNew³ Autor ³Edson Maricate         ³ Data ³13.12.1999 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Browse demonstrativo dos livros fiscais                      ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto ListBox dos livros fiscais                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo atualizar o array com o demons ³±±
±±³          ³trativo fiscal.                                              ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisLFNew(oLivro)

Local aTemp      := {}
Local aFixos     := MatXAFixos()
Local aLinha     := {}
Local nMaxBrw    := Len(aBrwLF)
Local nX         := 0	//controle de loop
Local nY         := 0	//controle de loop
Local nZ         := 0
Local nMax1      := 0
Local nMax2      := 0

If Empty(aNFCab)
	aadd(aLinha,Array(nMaxBrw))
	For nX  := 1 To nMaxBrw
		aLinha[1][nX] := aBrwLF[nX][2]
	Next nX
Else
	aTemp	:= aClone(aNFCab[NF_LIVRO])
	If cPaisLoc<>"BRA"
		If !Empty(aTemp)
			aTemp:=Adel(aTemp,1)
			aTemp:=aSize(aTemp,Len(aTemp)-1)
		Endif
	Endif
	nMax1 := Len(aTemp)
	For nX := 1 To nMax1
		nMax2 := Min(Len(aTemp[nX]),Len(aFixos))
		aadd(aLinha,Array(nMaxBrw))
		For nY := 1 To nMax2
			nZ := aScan(aBrwLF,{|x| x[1]==aFixos[nY][1]})
			If nZ <> 0
				aLinha[nX][nZ]:= aTemp[nX][nY]
			EndIf
		Next nY
	Next nX
EndIf

If ValType(oLivro)<>"U"
	oLivro:SetArray(aLinha)
	oLivro:bLine := {|| MaFisLFLine(oLivro,aLinha) }
	oLivro:Refresh()
EndIf

Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaFisHdLF ³ Autor ³Edson Maricate         ³ Data ³13.12.1999 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstrativo dos Livros Fiscais                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array com a seguinte estrutura:                       ³±±
±±³          ³       [1] Nome do Campo da tabela de livros fiscais         ³±±
±±³          ³       [2] Inicializador padrao do campo                     ³±±
±±³          ³       [3] Picture do campo                                  ³±±
±±³          ³       [4] Titulo do campo                                   ³±±
±±³          ³       [5] Tamanho do campo                                  ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo atualizar o array com a estrutu³±±
±±³          ³ra do SF3 necessaria para o calculo dos livros fiscais       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisHdLF()

Local aArea     := GetArea()
Local aAreaSX3  := SX3->(GetArea())
Local aFixos	:= MatXAFixos()
Local aRetorno  := {}
Local nX        := 0	//controle de loop

DbSelectArea("SX3")
DbSetOrder(2)
For nX := 1 To Len(aFixos)
	If SX3->(DbSeek(aFixos[nX][1]))
		//		If  X3USO(SX3->X3_USADO)
		aadd(aRetorno,{aFixos[nX][1],CriaVar(aFixos[nX][1],.F.),PesqPict("SF3",aFixos[nX][1]),X3Titulo(),SX3->X3_TAMANHO})
		//		EndIf
	EndIf
Next nX

RestArea(aAreaSX3)
RestArea(aArea)
Return (aRetorno)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaFisRatRe³ Autor ³Edson Maricate         ³ Data ³20.12.1999 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rateio do resumo de impostos                                 ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Nome da Referencia do imposto                         ³±±
±±³          ³ExpN2: Valor atual da referencia                             ³±±
±±³          ³ExpN3: Aliquota da referencia alterada                       ³±±
±±³          ³ExpN4: Nome da Referencia Aliquota para este imposto         ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo distribuir o valor da referenci³±±
±±³          ³a alterada, entre os itens de mesma referencia.              ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisRatRes(cReferencia,nAtual,nAliquota,cCpoAliq,cCpoBase,nItemNao)
Local nX        := 0	//controle de loop
Local nTotAcum	:= 0
Local nAuxItem	:= 0
Local lAuxItem	:= .T.
Local aPosCpo 	:= MaFisScan(cReferencia)
Local nCpoAliq	:= MaFisScan(cCpoAliq)
Local nCpoBase	:= MaFisScan(cCpoBase,.F.)
Local nAliqItem	:= 0
Local nBaseTot	:=	0
Local nVlrTot   := 0
Local nFator    := 0
Local nPosItRef := 0

DEFAULT nItemNao	:=	0

For nX := 1 To Len(aNFItem)
	If !Empty(nCpoBase) // so se existir a base, no caso de Dif. de Aliquota nao existe
		//Soh somar as bases da mesma aliquota, porque o rateio eh soh para os itens da mesma aliquota
		If (MaFisRet(nX,cCpoAliq)==nAliquota .AND.(IIf(ValType(aPosCpo) == "A",aNfItem[nX][aPosCpo[1]][aPosCpo[2]],aNfItem[nX][Val(aPosCpo)])>0))
			nBaseTot+=IIf(!aNfItem[nX][IT_DELETED],MaFisRet(nX,cCpoBase),0)
		EndIf
	Else
		If nBaseTot <= 0
			nVlrTot+=IIf(!aNfItem[nX][IT_DELETED],MaFisRet(nX,cReferencia),0)
		EndIf
	EndIf
Next nX

For nX	:= 1 to Len(aNfItem)
	If !aNfItem[nX][IT_DELETED]
		If nAtual <> 0 .AND. nAtual == nTotAcum .AND. cPaisLoc == "BRA"
			Exit
		Endif
		If !Empty(nCpoBase) // so se existir a base, no caso de Dif. de Aliquota nao existe
			//O rateio de impostos eh feito com base na base calculada para cada item
			nFator	:=	MaFisRet(nX,cCpoBase)/nBaseTot
        Else
			If nBaseTot <= 0
				nFator	:=	MaFisRet(nX,cReferencia)/nVlrTot
         	EndIf
		EndIf
		If ValType(nCpoAliq) == "A"
			nAliqItem := aNfItem[nX][nCpoAliq[1]][nCpoAliq[2]]
		Else
			nAliqItem := aNfItem[nX][Val(nCpoAliq)]
		EndIf
		If nAliqItem == nAliquota
			If nX	<>	nItemNao
				MaFisSomaIt(nX,.F.)
			Endif
			If lAuxItem
				nAuxItem	:= nX
				lAuxItem	:= .F.
			EndIf

			nPosItRef := Ascan(aItemRef,{|x| x[1] == cReferencia})

			If nPosItRef > 0
				If aItemRef[nPosItRef][4] .AND. aItemRef[nPosItRef][5]
					If ValType(aPosCpo) == "A"
						nTotAcum += aNfItem[nX][aPosCpo[1]][aPosCpo[2]]	:=  NoRound(nFator*nAtual,2)
					Else
						nTotAcum += aNfItem[nX][Val(aPosCpo)] := NoRound(nFator*nAtual,2)
					EndIf
				Else
					If ValType(aPosCpo) == "A"
						nTotAcum += aNfItem[nX][aPosCpo[1]][aPosCpo[2]]	:=  nFator*nAtual
					Else
						nTotAcum += aNfItem[nX][Val(aPosCpo)] := nFator*nAtual
					EndIf
				EndIf
			Else
				If ValType(aPosCpo) == "A"
					nTotAcum += aNfItem[nX][aPosCpo[1]][aPosCpo[2]]	:=  nFator*nAtual
				Else
					nTotAcum += aNfItem[nX][Val(aPosCpo)] := nFator*nAtual
				EndIf
			Endif
		EndIf
	EndIf
Next nX
If !lAuxItem .AND. nAtual <> nTotAcum
	If ValType(aPosCpo) == "A"
		aNfItem[nAuxItem][aPosCpo[1]][aPosCpo[2]] += (nAtual-nTotAcum)
	Else
		aNfItem[nAuxItem][Val(aPosCpo)] += (nAtual-nTotAcum)
	EndIf
EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisImpIV³ Autor ³                        ³ Data ³06.09.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa o calculo dos Impostos Variaveis                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Numero do Imposto ( 1 a 6 )                           ³±±
±±³          ³ExpN2: Item a ser calculado                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisImpIV(nItem)
Local nImpAte
Local nX		 := 0 	//controle de loop
Local nY
Local nG
Local nAliq
Local nImposto
Local nBase
Local cNumImp
Local nPosImp
Local nImpAnt
Local aImpsTotAnt := {}
Local aImpsTot	  := {}

Private aImposEIC := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula os impostos por total e por item                               ³
//³Os impóstos por item devem ser calculados antes dos impostos           ³
//³por total na seguinte sequencia :                                      ³
//³BASE IMPOSTO ITEM                                                      ³
//³ALIQUOTA IMPOSTO ITEM                                                  ³
//³VALOR IMPOSTO ITEM                                                     ³
//³                                                                       ³
//³E os impostos por total devem ser calculados na sequencia :            ³
//³BASE IMPOSTO TOTAL (Todos os itens ate o atual)                        ³
//³ALIQUOTA IMPOSTO TOTAL (Todos os itens ate o atual)                    ³
//³VALOR IMPOSTO TOTAL (Todos os itens ate o atual)                       ³
//³                                                                       ³
//³Isto e porque os impostos por total geralmente sao definidos em base a ³
//³valor minimo de base para poder calcular                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nImpAte := Len(aTes[TS_SFC])
For nX := 1 to NMAXIV
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificar se com o tes anterior foi calculado algum imposto por total³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aNfItem[nItem][IT_DESCIV][nX][3] == "T"
		Aadd(aImpsTotAnt,{nX,aNfItem[nItem][IT_DESCIV][nX],aNFItem[nItem][IT_ALIQIMP][nX]})
	Endif
	aNFItem[nItem][IT_BASEIMP][nX]	:=	0
	aNfItem[nItem][IT_DESCIV][nX]		:=	{"","",""}
	aNFItem[nItem][IT_VALIMP][nX]		:=	0
	aNFItem[nItem][IT_ALIQIMP][nX]	:=	0
Next nX
For nX := 1 To nImpAte
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificar que impostos por total deverao ser calculados com este TES ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	aTes[TS_SFC][nX][SFC_CALCULO] == "T"
		Aadd(aImpsTot,nX)
		nPosAtu	:=	Ascan(aImpsTotAnt,{|x| x[1]==NumCpoImpVar(RIGHT(Alltrim(aTes[TS_SFC][nX][SFB_CPOVREI]),1)) })
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Eliminar do array com o impostos por total calculados com o TES ante-³
		//³rior, se com o novo TES tambem deve ser calculado o imposto.         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPosAtu >0
			aDel(aImpsTotAnt,nPosAtu)
			Asize(aImpsTotAnt,Len(aImpsTotAnt)-1)
		Endif
	Endif
Next nX
If (Type("lFacImport")=="L" .AND. lFacImport)
	SD1->(MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+aNfItem[nItem][IT_PRODUTO]+StrZero(nItem,TamSx3("D1_ITEM")[1])))
	A100IniImp(SD1->D1_SERIE,SD1->D1_DOC,SD1->D1_TEC,,,,,,,nItem)
	If Len(aImposEic)>0
		For nX := 1 To Len(aImposEIC)
			nG := NumCpoImpVar(Right(aImposEIC[nX,6],1))
			If nG > 0
				SFB->(MsSeek(xFilial("SFB")+aImposEIC[nX,4]))
				aNFItem[nItem][IT_BASEIMP][nG]	:=	aImposEIC[nX,7]
				aNfItem[nItem][IT_DESCIV][nG]	:=	{aImposEIC[nX,4],SFB->FB_DESCR,Posicione('SFC',1,xFilial("SFC")+aImposEIC[nX][2]+aImposEIC[nX][3]+aImposEIC[nX][4],"FC_CALCULO")}
				aNFItem[nItem][IT_VALIMP][nG]	:=	aImposEIC[nX,9]
				aNFItem[nItem][IT_ALIQIMP][nG]	:=	aImposEIC[nX,5]
			Endif
		Next nX
	Endif
Else
	If nImpAte > 0
		For nX := 1 to nImpAte
			//Calcula os impostos por item
			MaFisBSIV(nX,nItem)		// Executa o calculo da Base dos IVs
			MaFisAliqIV(nX,nItem)	// Executa o calculo da Aliquota dos IVs
			If Ascan(aImpsTot,nX) == 0
				MaFisVLIV(nX,nItem)		// Executa o calculo do Valor dos IVs que nao sao por total
			Endif
		Next nX
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a base de impostos por total que nao sao    ³
//³mais calculados e menor que o minimo, se for, zera o    ³
//³valor do imposto no total e rateia.                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aImpsTotAnt)
	cNumImp	:=	NumCpoImpVar(aImpsTotAnt[nX][1],1)
	If MaFisRet(,'NF_BASEIV'+cNumImp) < MaFisRet(,'NF_MINIV'+cNumImp)
		nImposto	:= 0
		nBase		:=	0
	Else
		nImposto	:=	MaFisRet(,'NF_VALIV'	+cNumImp)
		nBase		:=	MaFisRet(,'NF_BASEIV'+cNumImp)
	Endif
	nAliq		:=	aImpsTotAnt[nX][3]
	aDesc		:=	aClone(aImpsTotAnt[nX][2])
	If nBase > 0
		//Garantir que o imposto exista no array de impostos
		If  (nPosImp	:=	aScan(aNfCab[NF_IMPOSTOS],{|x| x[IMP_COD] ==aDesc[1] .AND.	x[IMP_ALIQ]==nAliq })) == 0
			MaFisResumo(0,nAliq,0,aDesc[1],aDesc[2],"IV"+cNumImp,,,.T.)
			nPosImp	:=	aScan(aNfCab[NF_IMPOSTOS],{|x| x[IMP_COD] ==aDesc[1] .AND.	x[IMP_ALIQ]==nAliq })
		Endif
		MaFisAlt('IMP_BASEIV'+cNumImp,nBase		,nPosImp,.T.,nItem)
	Endif
	//Garantir que o imposto exista no array de impostos
	If  (nPosImp	:=	aScan(aNfCab[NF_IMPOSTOS],{|x| x[IMP_COD] ==aDesc[1] .AND.	x[IMP_ALIQ]==nAliq })) == 0
		MaFisResumo(0,nAliq,0,aDesc[1],aDesc[2],"IV"+cNumImp,,,.T.)
		nPosImp	:=	aScan(aNfCab[NF_IMPOSTOS],{|x| x[IMP_COD] ==aDesc[1] .AND.	x[IMP_ALIQ]==nAliq })
	Endif
	MaFisAlt('IMP_VALIV'+cNumImp,nImposto,nPosImp,,nItem)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura o TES utilizado no calculo de impostos quando ³
	//³ quando houve calculo de impostos por total, dado que   ³
	//³ foram recalculados os valores para todos os itens.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisTes(aNfItem[nItem][IT_TES],aNfItem[nItem][IT_RECNOSF4],nItem)
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo os impostos por total e rateia em todos os itens³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !aNfItem[nItem][IT_DELETED]
	For nX := 1 To Len(aImpsTot)
		cNumImp	:=	RIGHT(Alltrim(aTes[TS_SFC][aImpsTot[nX]][SFB_CPOVREI]),1)
		nImpAnt 	:=	MaFisRet(nItem,'IT_VALIV'	+cNumImp)
		MaFisVLIV(aImpsTot[nX],nItem)			// Executa o calculo do valor dos IVs dos impostos.
		nImposto	:=	MaFisRet(nItem,'IT_VALIV'	+cNumImp)

		If Round(nImposto,3) > 0 .OR. (nImpAnt > 0 .AND. Round(nImposto,3) == 0)
			nAliq		:=	MaFisRet(nItem,'IT_ALIQIV'	+cNumImp)
			aDesc		:=	aNfItem[nItem][IT_DESCIV][Val(cNumImp)]
			nBase		:=	MaRetBasT(cNumImp,nItem,nAliq)
			//Garantir que o imposto exista no array de impostos
			If  (nPosImp	:=	aScan(aNfCab[NF_IMPOSTOS],{|x| x[IMP_COD] ==aDesc[1] .AND.	x[IMP_ALIQ]==nAliq })) == 0
				MaFisResumo(0,nAliq,0,aDesc[1],aDesc[2],"IV"+cNumImp,,,.T.)
				nPosImp	:=	aScan(aNfCab[NF_IMPOSTOS],{|x| x[IMP_COD] ==aDesc[1] .AND.	x[IMP_ALIQ]==nAliq })
			Endif
			MaFisAlt('IMP_BASEIV'+cNumImp,nBase		,nPosImp,.T.,nItem)
			//Garantir que o imposto exista no array de impostos
			If  (nPosImp	:=	aScan(aNfCab[NF_IMPOSTOS],{|x| x[IMP_COD] ==aDesc[1] .AND.	x[IMP_ALIQ]==nAliq })) == 0
				MaFisResumo(0,nAliq,0,aDesc[1],aDesc[2],"IV"+cNumImp,,,.T.)
				nPosImp	:=	aScan(aNfCab[NF_IMPOSTOS],{|x| x[IMP_COD] ==aDesc[1] .AND.	x[IMP_ALIQ]==nAliq })
			Endif
			MaFisAlt('IMP_VALIV'	+cNumImp,nImposto	,nPosImp,,nItem)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Restaura o TES utilizado no calculo de impostos quando ³
			//³ quando houve calculo de impostos por total, dado que   ³
			//³ foram recalculados os valores para todos os itens.     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaFisTes(aNfItem[nItem][IT_TES],aNfItem[nItem][IT_RECNOSF4],nItem)
		Endif
	Next nX
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaFisReprocess³ Autor ³ Edson Maricate    ³ Data ³20.05.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua o reprocessamento e gera o livro da Nota Fiscal.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MaFisReprocess()                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function MaFisReprocess(nOpc)
Local nItem := 	0	//controle de loop

nOpc := IIF(nOpc==Nil,1,nOpc)

Do Case
Case nOpc == 1
	If MaFisFound('NF')
		For nItem := 1 to len(aNfItem)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona os registros necessarios                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(cAliasPROD)
			If aNfItem[nItem][IT_RECNOSB1] <> 0 .AND. cAliasPROD=="SB1"
				MsGoto(aNfItem[nItem][IT_RECNOSB1])
			Else
				dbSetOrder(1)
				MsSeek(xFilial(cAliasPROD)+aNfItem[nItem][IT_PRODUTO])
			EndIf
			MaFisTes(aNfItem[nItem][IT_TES],aNfItem[nItem][IT_RECNOSF4],nItem)
			MaFisBSIPI(nItem,.T.)	// Calcula a Base de IPI Original
			MaFisBSICM(nItem,.T.)	// Calcula a Base de ICMS Original
			MaFisLF(nItem)			// Atualiza os valores do Livro Fiscal
			MaFisLF2(nItem)			// Verifica se a TES possui RdMake para complemento/geracao dos Livros
			MaFisLF3(nItem)
		Next nItem
		MaIt2Cab()
	EndIf
Case nOpc == 2
	If MaFisFound('NF')
		For nItem := 1 to len(aNfItem)
			MaFisRecal(,nItem)
		Next nItem
		MaIt2Cab()
	EndIf
EndCase
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisRetSFC³ Autor ³ Leandro Coelho       ³ Data ³14.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna as caracteristiscas definidas no SFC para cada um  ³±±
±±³          ³ dos impostos calculados para o item informado.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array com a seguinte estrutura                       ³±±
±±³          ³   A1[n][01] : Sequencia                                    ³±±
±±³          ³   A1[n][02] : Imposto                                      ³±±
±±³          ³   A1[n][03] :                                              ³±±
±±³          ³   A1[n][04] :                                              ³±±
±±³          ³   A1[n][05] : Se credita ou nao no custo                   ³±±
±±³          ³   A1[n][06] :                                              ³±±
±±³          ³   A1[n][07] :                                              ³±±
±±³          ³   A1[n][08] :                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisRetSFC(nItem)
Local aRetorno

MaFisTes(aNfItem[nItem][IT_TES],aNfItem[nItem][IT_RECNOSF4],nItem)

aRetorno:=aClone(aTes[TS_SFC])

Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MaRetIncIV    º Leandro C.G. ³Microsiga º Data ³  14/01/02  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna valores de impostos referentes a um item de NF que º±±
±±º          ³ incidem no custo, Duplicata, ou Nota                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*Parametros
nItem		- Numero do item da Nota Fiscal
cOpc		- 1- Custo
2- Nota
3- Duplicata

Obs.: Considera que o arquivo de itens da Nota Fiscal ja esta posicionado no registro correto e que
as variaveis de calculo de impostos do programa MatxFis ja estao inicializadas
*/

Function MaRetIncIV(nItem,cOpc)

Local aDescImp 	:=	{}	//Descricao/Codigo de todos os impostos que incidem no item
Local aValImp	:=	{}	//Array com os valores de todos os impostos que incidem no item
Local nImposVar	:=	0	//Valor dos impostos variaveis que incidem no custo
Local aSFC		:=	{} //Array com as propriedades dos impostos do item
Local aRet 		:= {} //Array com os impostos e valores que sao somados ou subtraidos no custo
/*						[1] - Codigo do imposto
[2] - Valor positivio (quando imposto e creditado) e negativo (+/-)
*/
Local nI		:=	0	//controle de loop
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Consistindo parametros³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(nItem)
	Return( 0 )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca array com todos os impostos que incidem no item item³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSFC	 :=	MaFisRetSFC(nItem)
aDescImp :=	MaFisRet(nItem,"IT_DESCIV")		//Descricao/Codigo dos impostos
aValImp  :=	MaFisRet(nItem,"IT_VALIMP")		//Valor dos Impostos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Buscando valores referentes aos impostos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len(aSFC)
	nPosImp	:=	Ascan(aDescImp,{|x| x[1] == aSFC[nI][SFC_IMPOSTO]})
	If nPosImp > 0
		Do Case
		Case cOpc == '1'
			If aSFC[nI][SFC_CREDITA] <> '3'
				nImposVar	:=	aValImp[nPosImp] * If(aSFC[nI][SFC_CREDITA] == '1', 1 , -1)
				Aadd(aRet, {aSFC[nI][SFC_IMPOSTO], nImposVar})
			Endif
		Case cOpc == '2'
			If aSFC[nI][SFC_INCNOTA] <> '3'
				nImposVar	+=	aValImp[nPosImp] * If(aSFC[nI][SFC_INCNOTA] == '1', 1 , -1)
			Endif
		Case cOpc == '3'
			If aSFC[nI][SFC_INCDUPL] <> '3'
				nImposVar	+=	aValImp[nPosImp] * If(aSFC[nI][SFC_INCDUPL] == '1', 1 , -1)
			Endif
		EndCase
	Endif
Next nI

Return(IIf(cOpc=="1",aRet,nImposVar))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MaRetIncIV    º Leandro C.G. ³Microsiga º Data ³  14/01/02  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna valores de impostos referentes a um item de NF que º±±
±±º          ³ incidem no custo, Duplicata, ou Nota                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NumCpoImpVar(xCpoLiv)
Local cCpo,xRet
cCpo:="123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
xRet:=0
If !Empty(xCpoLiv)
	If ValType(xCpoLiv)=="C"
		xRet:=At(xCpoLiv,cCpo)
	ElseIf ValType(xCpoLiv)=="N"
		If xCpoLiv>0
			xRet:=Substr(cCpo,xCpoLiv,1)
		Endif
	Endif
Endif
Return(xRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisImpLd³ Autor ³ Eduardo Riera         ³ Data ³11.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carregar os valores de impostos gravados em um arquivo      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array com os impostos no formato:                    ³±±
±±³          ³       [1] Codigo do imposto                                ³±±
±±³          ³       [2] Base do imposto                                  ³±±
±±³          ³       [3] Aliquota do imposto                              ³±±
±±³          ³       [4] Valor do imposto                                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do arquivo                                     ³±±
±±³          ³ExpC2: Tipo de Imposto                                      ³±±
±±³          ³       "IT" - Por item                                      ³±±
±±³          ³       "NF" - Por documento                                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisImpLd(cAlias,cTipo,cCursor)

Local aArea       := GetArea()
Local aReferencia := MaFisSXRef(cAlias)
Local aImposto    := {}
Local aCodImp     := {}
Local nX          := 0	//controle de loop
Local nY          := 0

DEFAULT cTipo := "IT"
DEFAULT cCursor := cAlias

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os codigos de impostos                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aCodImp,"ICM")
aadd(aCodImp,"IPI")
aadd(aCodImp,"ICA")
aadd(aCodImp,"SOL")
aadd(aCodImp,"CMP")
aadd(aCodImp,"ISS")
aadd(aCodImp,"IRR")
aadd(aCodImp,"INS")
aadd(aCodImp,"COF")
aadd(aCodImp,"CSL")
aadd(aCodImp,"PIS")
aadd(aCodImp,"PS2")
aadd(aCodImp,"CF2")
aadd(aCodImp,"RUR")

For nX := 1 To NMAXIV
	aadd(aCodImp,"IV"+StrZero(nX,1))
Next nX
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os codigos de impostos                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aCodImp)
	aadd(aImposto,{aCodImp[nX],0,0,0})
	nY := aScan(aReferencia,{|x| x[2]=cTipo+"_BASE"+aCodImp[nX]})
	If nY <> 0
		aImposto[nX][2] := (cCursor)->(FieldGet(FieldPos(aReferencia[nY][1])))
	EndIf
	nY := aScan(aReferencia,{|x| x[2]=cTipo+"_ALIQ"+aCodImp[nX]})
	If nY <> 0
		aImposto[nX][3] := (cCursor)->(FieldGet(FieldPos(aReferencia[nY][1])))
	EndIf
	nY := aScan(aReferencia,{|x| x[2]=cTipo+"_VAL"+aCodImp[nX]})
	If nY <> 0
		aImposto[nX][4] := (cCursor)->(FieldGet(FieldPos(aReferencia[nY][1])))
	EndIf
Next nX
nY := 0
For nX := 1 To Len(aImposto)
	If !Empty(aImposto[nX])
		If aImposto[nX][4] == 0
			aImposto := aDel(aImposto,nX)
		Else
			nY++
		EndIf
	EndIf
Next nX
aImposto := aSize(aImposto,nY)
RestArea(aArea)
Return(aImposto)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisRefLd³ Autor ³ Eduardo Riera         ³ Data ³20.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Demonstra as referencias dos impostos de uma tabela         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array com os impostos no formato:                    ³±±
±±³          ³       [1] Codigo do imposto                                ³±±
±±³          ³       [2] Campo da Base do imposto                         ³±±
±±³          ³       [3] Campo da Aliquota do imposto                     ³±±
±±³          ³       [4] Campo do Valor do imposto                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do arquivo                                     ³±±
±±³          ³ExpC2: Tipo de Imposto                                      ³±±
±±³          ³       "IT" - Por item                                      ³±±
±±³          ³       "NF" - Por documento                                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisRefLd(cAlias,cTipo)

Local aArea       := GetArea()
Local aReferencia := MaFisSXRef(cAlias)
Local aImposto    := {}
Local aCodImp     := {}
Local nX          := 0	//controle de loop
Local nY          := 0

DEFAULT cTipo := "IT"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os codigos de impostos                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aCodImp,"ICM")
aadd(aCodImp,"IPI")
aadd(aCodImp,"ICA")
aadd(aCodImp,"SOL")
aadd(aCodImp,"CMP")
aadd(aCodImp,"ISS")
aadd(aCodImp,"IRR")
aadd(aCodImp,"INS")
aadd(aCodImp,"COF")
aadd(aCodImp,"CSL")
aadd(aCodImp,"PIS")
aadd(aCodImp,"PS2")
aadd(aCodImp,"CF2")
aadd(aCodImp,"RUR")

For nX := 1 To NMAXIV
	aadd(aCodImp,"IV"+StrZero(nX,1))
Next nX
aadd(aCodImp,"PS3")
aadd(aCodImp,"CF3")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os codigos de impostos                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aCodImp)
	aadd(aImposto,{aCodImp[nX],0,0,0})
	nY := aScan(aReferencia,{|x| x[2]=cTipo+"_BASE"+aCodImp[nX]})
	If nY <> 0
		aImposto[nX][2] := aReferencia[nY][1]
	EndIf
	nY := aScan(aReferencia,{|x| x[2]=cTipo+"_ALIQ"+aCodImp[nX]})
	If nY <> 0
		aImposto[nX][3] := aReferencia[nY][1]
	EndIf
	nY := aScan(aReferencia,{|x| x[2]=cTipo+"_VAL"+aCodImp[nX]})
	If nY <> 0
		aImposto[nX][4] := aReferencia[nY][1]
	EndIf
Next nX
RestArea(aArea)
Return(aImposto)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisCalAl ³ Autor ³ Bruno Sobieski       ³ Data ³29.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa o calculo da Aliquota dos Impostos Variaveis        ³±±
±±³          ³Esta funcao foi criada para nao tirar a propriedade de      ³±±
±±³          ³STATIC da funcao MAFISAliqIV                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Numero do Imposto ( 1 a 6 )                          ³±±
±±³          ³ExpN2: Item a ser calculado                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisCalAl(nImposto,nItem)

MaFisAliqIV(nImposto,nItem)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MaVldForn     º Nereu H. Jr. ³Microsiga º Data ³  12/09/03  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida fornecedor no momento da transferencia de fornecedorº±±
±±º          ³ na implantacao do titulo de ISS                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MaVldForn(cFornIss,cLojaIss,oDescri,cDescri,oLojaISS,oFornIss,nTipo)

Local lRet := .F.

If Empty(cFornIss)
	cLojaISS := Space(Len(cLojaIss))
	lRet := .T.
	cDescri := ""
	oDescri:Refresh()
Else
	dbSelectArea("SA2")
	dbSetOrder(1)
	If MsSeek(xFilial("SA2")+cFornIss+cLojaIss)
		cDescri := SA2->A2_NREDUZ
		lRet := .T.
		oDescri:Refresh()
	Else
		If nTipo == 1
			lRet := .T.
		Else
			lRet := .F.
		Endif
		cDescri := ""
	Endif
EndIf

If nTipo == 2 .AND. Empty(cLojaIss) .AND. !Empty(cFornIss)
	cFornISS := Space(Len(cFornIss))
	lRet := .T.
	cDescri := ""
	oDescri:Refresh()
	oFornIss:Refresh()
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MaPrcVen ³ Autor ³ Bruno Sobieski        ³ Data ³08.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Aplica o desconto no campo de preco de venda, quando estamos³±±
±±³          ³usando a tabelas SD2.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Item                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function MaPrcVen(nItem)

// Indica se o preco unitario sera arredondado em 0 casas decimais ou nao. Se .T. respeita MV_CENT (Apenas Chile).
Local lPrcDec   := SuperGetMV("MV_PRCDEC",,.T.)
If cPaisLoc <> "BRA" .AND. aNfCab[NF_OPERNF] =='S' .AND. SuperGetMV('MV_DESCSAI') =='1'
	If cPaisLoc=="CHI" .and. lPrcdec
		aNFitem[nItem][IT_VALMERC] := Round(aNFitem[nItem][IT_VALMERC] - aNFitem[nItem][IT_DESCONTO],MsDecimais(aNFCab[NF_MOEDA]))
	Else
		aNFitem[nItem][IT_VALMERC] -= aNFitem[nItem][IT_DESCONTO]
	Endif
	aNFitem[nItem][IT_PRCUNI]  :=	aNFitem[nItem][IT_VALMERC]/Max(aNFitem[nItem][IT_QUANT],1)
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisLdImp³ Autor ³ Eduardo Riera         ³ Data ³20.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Demonstra os impostos tratados pelo sistema                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array com os impostos no formato:                    ³±±
±±³          ³       [1] Codigo do imposto                                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisLdImp()

Local aCodImp     := {}
Local nX          := 0	//controle de loop

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os codigos de impostos                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aCodImp,"ICM")
aadd(aCodImp,"IPI")
aadd(aCodImp,"ICA")
aadd(aCodImp,"SOL")
aadd(aCodImp,"CMP")
aadd(aCodImp,"ISS")
aadd(aCodImp,"IRR")
aadd(aCodImp,"INS")
aadd(aCodImp,"COF")
aadd(aCodImp,"CSL")
aadd(aCodImp,"PIS")
aadd(aCodImp,"PS2")
aadd(aCodImp,"CF2")
aadd(aCodImp,"RUR")

For nX := 1 To NMAXIV
	aadd(aCodImp,"IV"+StrZero(nX,1))
Next nX
Return(aCodImp)

Static Function MAFisZero()
Return 0.0001
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MaRetBasT³ Autor ³ Bruno Sobieski        ³ Data ³21.10.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a base total de um imposto, dependendo da aliquota  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function MaRetBasT(cNumImp,nItem,nAliq)
Local nBase	:=	0
Local nX	:=	0	//controle de loop
//Local nPosImp	:=	aScan(aNfCab[NF_IMPOSTOS],{|x| x[IMP_COD] ==aDesc[1] .AND.	x[IMP_ALIQ]==nAliq })

//nBase		:=	MaFisRet(nItem,'IT_BASEIV'	+cNumImp)
For nX := 1 To Len(aNFItem)
	If !aNfItem[nX][IT_DELETED]
		If MaFisRet(nX,'IT_ALIQIV'+cNumImp) == nAliq
			nBase += MaFisRet(nX,'IT_BASEIV'+cNumImp)
		Endif
	Endif
Next nX
Return nBase

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaTbIrfPF ³ Autor ³Eduardo/Edson          ³ Data ³31.01.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializa o Calculo das operacoes Fiscais                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA: [1] Valor do IRPF                                     ³±±
±±³          ³      [2] Aliquota do IRPF                                  ³±±
±±³          ³      [3] Dedução  do IRPF                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 : Valor do IRPF                                      ³±±
±±³          ³ ExpN2 : Valor acumulado do IRPF                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaTbIrfPF(nBaseIRF,nTotIrf,lSE2,cFornece,cLoja)

Local aArea   := GetArea()
Local aAreaSD1:= SD1->(GetArea())
Local aTabela := {}
Local cBuffer := ""
Local nX      := 0	//controle de loop
Local nBase   := 0
Local nAliq   := 0
Local nValor  := 0
Local nDed    := 0
Local nIsento := 0
Local lContrRet := !Empty( SE2->( FieldPos( "E2_VRETPIS" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_VRETCOF" ) ) ) .And. ;
	!Empty( SE2->( FieldPos( "E2_VRETCSL" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_PRETPIS" ) ) ) .And. ;
	!Empty( SE2->( FieldPos( "E2_PRETCOF" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_PRETCSL" ) ) )
Local lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"  .and. (!Empty( SE5->( FieldPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_VRETCOF" ) ) ) .And. ;
	!Empty( SE5->( FieldPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETPIS" ) ) ) .And. ;
	!Empty( SE5->( FieldPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETCSL" ) ) ) .And. ;
	!Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( FieldPos( "FQ_SEQDES"  ) ) ) )
Local nTotTit := 0
Local nTotInss:= 0
Local nTotIrrf:= 0
Local nVenctoPF := SuperGetMv("MV_ACMIRPF",.T.,"1")
#IFNDEF TOP
	Local nLastDay:= Day(LastDay(dDataBase))
	Local dDtSeek
	Local bDataImp
#ELSE
	Local cWhere    := ""
	Local cSepNeg   := If("|"$MV_CPNEG,"|",",")
	Local cSepProv  := If("|"$MVPROVIS,"|",",")
	Local cSepRec   := If("|"$MVPAGANT,"|",",")
#ENDIF

If aUltPesq == Nil
	STATIC aUltPesq := {ctod(""),"","",0,0}
EndIf

DEFAULT nTotIrf := 0
DEFAULT lSE2    := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o valor do IRF ocorrido no mes                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lSE2 .And. ( !(aUltPesq[1] == dDataBase .And. aUltPesq[2] == cFornece .And. aUltPesq[3] == cLoja))
	#IFDEF TOP
			cWhere := ""
			If nVenctoPF == "2"
				cWhere += "%SE2.E2_VENCREA  BETWEEN '"+Dtos(FirstDay(dDataBase))+"' AND '"+Dtos(LastDay(dDataBase))+"' AND "
			ElseIf nVenctoPF == "1"
				cWhere += "%SE2.E2_EMISSAO  BETWEEN '"+Dtos(FirstDay(dDataBase))+"' AND '"+Dtos(LastDay(dDataBase))+"' AND "
			Else
				cWhere += "%SE2.E2_EMIS1  BETWEEN '"+Dtos(FirstDay(dDataBase))+"' AND '"+Dtos(LastDay(dDataBase))+"' AND "
			EndIf
			cWhere += "SE2.E2_TIPO NOT IN "+FormatIn(MVABATIM,"|")+" AND "
			cWhere += "SE2.E2_TIPO NOT IN "+FormatIn(MV_CPNEG,cSepNeg)+" AND "
			cWhere += "SE2.E2_TIPO NOT IN "+FormatIn(MVPROVIS,cSepProv)+" AND "
			cWhere += "SE2.E2_TIPO NOT IN "+FormatIn(MVPAGANT,cSepRec)+" AND %"


		BeginSql Alias "MaTbIrfPF"
			SELECT	E2_VALOR,E2_IRRF,E2_INSS,E2_ISS,E2_SEST,E2_PRETPIS,E2_PRETCOF,E2_PRETCSL,E2_VRETPIS,E2_VRETCOF,E2_VRETCSL,
			E2_TIPO,E2_NUM,E2_PREFIXO,E2_FORNECE,E2_LOJA
			FROM %Table:SE2% SE2,%Table:SED% SED
			WHERE
			SE2.E2_FILIAL = %xFilial:SE2% AND
			SE2.E2_FORNECE = %Exp:cFornece% AND
			SE2.E2_LOJA = %Exp:cLoja% AND
			%exp:cWhere%
			SE2.E2_NATUREZ = SED.ED_CODIGO AND
			SED.ED_CALCIRF = 'S' AND
			SE2.%notdel% AND
			SED.%notdel%
		EndSql
		dbSelectArea("MaTbIrfPF")
		While !(MaTbIrfPF->(Eof()))
			If 	MaTbIrfPF->(E2_TIPO) == MVNOTAFIS
				BeginSql Alias "TMPSD1"
					SELECT SUM(D1_BASEIRR) BASEIRR, SUM(D1_VALINS) VALINS
					FROM %Table:SD1% SD1
					WHERE
					SD1.D1_FILIAL = %xFilial:SD1% AND
					SD1.D1_DOC = %Exp:MaTbIrfPF->(E2_NUM)% AND
					SD1.D1_SERIE = %Exp:MaTbIrfPF->(E2_PREFIXO)% AND
					SD1.D1_FORNECE = %Exp:MaTbIrfPF->(E2_FORNECE)% AND
					SD1.D1_LOJA = %Exp:MaTbIrfPF->(E2_LOJA)% AND
					SD1.%notdel%
				EndSql
				nTotTit	+= (BASEIRR + VALINS)
				dbCloseArea()
			Else
				nTotTit	+= E2_VALOR+E2_IRRF+E2_INSS+E2_ISS+E2_SEST
			EndIf
			dbSelectArea("MaTbIrfPF")
			If lContrRet .And. !lPccBaixa .And. (E2_PRETPIS == " " .And. E2_PRETCOF == " " .And. E2_PRETCSL == " ")
				nTotTit	+= E2_VRETPIS+E2_VRETCOF+E2_VRETCSL
			Endif
			nTotInss += E2_INSS
			nTotIrrf += E2_IRRF
			dbSkip()
		EndDo
		MaTbIrfPF->(dbCloseArea())
		dbSelectArea("SA2")
	#ELSE
		dbSelectArea("SA2")
		dbSetOrder(1)
		MsSeek(xFilial("SA2")+cFornece+cLoja)

		dbSelectArea("SE2")
		If nVenctoPF == "2"
			bDataImp := {||SE2->E2_VENCREA}
			dbSetOrder(3)
		ElseIf nVenctoPF == "1"
			bDataImp := {||SE2->E2_EMISSAO}
			dbSetOrder(5)
		Else// nVenctoPF == "3"
			bDataImp := {||SE2->E2_EMIS1}
			dbSetOrder(5)
		EndIf

		nStart:= 1
		For nX := nStart to nLastDay
			dDtSeek := Dtos(Ctod(StrZero(nX)+"/"+SubStr(Dtoc(dDataBase),4,Iif(Len(Dtoc(dDataBase)) == 10, 7, 5))))
			If MsSeek(xFilial("SE2")+dDtSeek+SA2->A2_NREDUZ,.T.)
				While !Eof() .And. xFilial("SE2") == E2_FILIAL .And. Dtos(Eval(bDataImp))==dDtSeek .And. E2_NOMFOR == SA2->A2_NREDUZ
					SED->(MsSeek(xFilial("SED")+SE2->E2_NATUREZ))
					If E2_FORNECE+E2_LOJA == SA2->A2_COD+SA2->A2_LOJA .and. !(E2_TIPO $ MVABATIM+"/"+MV_CPNEG+"/"+MVPAGANT+"/"+MVPROVIS) .And. SED->ED_CALCIRF=="S"
						nTotTit	+= E2_VALOR+E2_IRRF+E2_INSS+E2_ISS+E2_SEST
						If lContrRet .And. !lPccBaixa .And. (E2_PRETPIS == " " .And. E2_PRETCOF == " " .And. E2_PRETCSL == " ")
							nTotTit	+= E2_VRETPIS+E2_VRETCOF+E2_VRETCSL
						Endif
						nTotInss += E2_INSS
						nTotIrrf += E2_IRRF
					Endif
					dbSkip()
				EndDo
			EndIf
		Next nX
	#ENDIF
	aUltPesq:= {dDataBase,cFornece,cLoja,IIF((SuperGetMv("MV_INSIRF",.F.,"2") == "1"), nTotTit - nTotInss , nTotTit ),nTotIRRF}
EndIf
nBaseIRF += aUltPesq[4]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aplica a tabela progressiva                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File("SIGAADV.IRF")
	FT_FUse("SIGAADV.IRF")
	FT_FGotop()

	While ( !FT_FEof() )

		cBuffer := FT_FReadLn()
		aadd(aTabela,{Val(SubStr(cBuffer,1,15)),Val(SubStr(cBuffer,17,6)),Val(SubStr(cBuffer,24,15))})
		FT_FSkip()

	EndDo
	FT_FUse()

	For nX := 1 To Len(aTabela)
		nBase := aTabela[nX,1]
		nAliq := aTabela[nX,2]
		nDed  := aTabela[nX,3]
		If nAliq == 0
			nIsento := nBase
		EndIf
		If nBaseIRF+nTotIrf <= aTabela[nX][1]
			Exit
		EndIf
	Next nX

	nValor := NoRound(((nBaseIRF+nTotIrf)*nAliq/100),2)-nDed-aUltPesq[5]
	nValor := Max(nValor,0)

EndIf

RestArea(aArea)
Return({nValor,nAliq,nDed,nIsento})


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MyNoRound ³ Autor ³Eduardo/Wilson         ³ Data ³28.07.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializa o Calculo das operacoes Fiscais                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ExpN1: Valor de partida                                     ³±±
±±³          ³ExpN2: Numero de casas decimais                             ³±±
±±³          ³ExpN3: Resto                                                ³±±
±±³          ³ExpN4: Precisão                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Valor truncado                                             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MyNoRound(nPartida,nCasas,nDiferenca,nPrecisao)

Local cString := ""
Local nAt     := 0
Local nValor  := 0

DEFAULT nPrecisao := 10
DEFAULT nDiferenca:= 0

cString    := Strzero(nPartida,20,nPrecisao)
nAt        := At(".",cString)
nAt        += nCasas
nValor     := Round(Val(SubStr(cString,1,nAt)), nCasas)

nAt++

cString    := SubStr(cString,nAt)
nDiferenca := Round(Val(cString) / (10 ** 8), 8)

Return(nValor)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisBsAFRMM³ Autor ³ Sergio S. Fuzinaka    ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a Base de Calculo do AFRMM                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisBsAFRMM(nItem)

Local nBaseAFRMM := 0

If aTes[TS_AFRMM] == "S" .AND. !Empty( aNfItem[nItem][IT_VALMERC] )
	nBaseAFRMM := aNfItem[nItem][IT_VALMERC]
	aNfItem[nItem][IT_BASEAFRMM] := nBaseAFRMM
Else
	aNfItem[nItem][IT_BASEAFRMM] := nBaseAFRMM
EndIf

Return( nBaseAFRMM )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaAliqAFRMM³ Autor ³ Sergio S. Fuzinaka     ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a Aliquota para o Calculo do AFRMM                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaAliqAFRMM(nItem)

Local aArea		 := GetArea()
Local nAliqAFRMM := GetNewPar("MV_TXAFRMM",0)

If aTes[TS_AFRMM] == "S" .AND. !Empty( nAliqAFRMM )
	aNfItem[nItem][IT_ALIQAFRMM] := nAliqAFRMM
Else
	nAliqAFRMM := 0
	aNfItem[nItem][IT_ALIQAFRMM] := nAliqAFRMM
Endif
RestArea(aArea)

Return( nAliqAFRMM )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisVlAFRMM³ Autor ³ Sergio S. Fuzinaka    ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna o Valor do AFRMM                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisVLAFRMM(nItem)

Local nVlAFRMM	:= 0
Local lMaAFRMM	:= ExistBlock( "MAAFRMM" )

If aTes[TS_AFRMM] == "S" .AND. !Empty( aNfItem[nItem][IT_BASEAFRMM] ) .AND. !Empty( aNfItem[nItem][IT_ALIQAFRMM] )
	nVlAFRMM := (( aNfItem[nItem][IT_BASEAFRMM] * aNfItem[nItem][IT_ALIQAFRMM] ) / 100 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para tratamento do Valor Calculado do AFRMM com o Adicional ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMaAFRMM
		nVlAFRMM := ExecBlock("MAAFRMM",.F.,.F.,{nVlAFRMM})
	Endif

	aNfItem[nItem][IT_VALAFRMM] := nVlAFRMM
Else
	aNfItem[nItem][IT_VALAFRMM] := nVlAFRMM
EndIf

Return( nVlAFRMM )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisBsSEST³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 20.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna o Base de Calculo do SEST do item                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisBsSEST(nItem)

Local aArea		:= GetArea()
Local aAreaSED	:= SED->(GetArea())
Local nBaseCalc	:= 0

If !Empty(aNfCab[NF_NATUREZA]) .AND. SED->(FieldPos("ED_BASESES")) > 0
	dbSelectArea("SED")
	dbSetOrder(1)
	If MsSeek(xFilial("SED")+aNfCab[NF_NATUREZA])
		If aNfCab[NF_RECSEST]=="1" .AND. aTES[TS_DUPLIC]=="S"
			If SED->ED_BASESES > 0
				nBaseCalc := ((aNfItem[nItem][IT_TOTAL] * SED->ED_BASESES) / 100)
			Else
				nBaseCalc := aNfItem[nItem][IT_TOTAL]
			Endif
		EndIf
	Endif
Endif
aNfItem[nItem][IT_BASESES] := nBaseCalc

RestArea(aAreaSED)
RestArea(aArea)

Return(nBaseCalc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaAliqSEST³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 20.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a aliquota para calculo do SEST                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaAliqSEST(nItem)

Local aArea		:= GetArea()
Local aAreaSED	:= SED->(GetArea())
Local nAliquota	:= 0

If !Empty(aNfCab[NF_NATUREZA]) .AND. SED->(FieldPos("ED_PERCSES")) > 0
	dbSelectArea("SED")
	dbSetOrder(1)
	If MsSeek(xFilial("SED")+aNfCab[NF_NATUREZA])
		nAliquota := SED->ED_PERCSES
	EndIf
EndIf
aNfItem[nItem][IT_ALIQSES]	:= nAliquota

RestArea(aAreaSED)
RestArea(aArea)

Return(nAliquota)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisVlSEST³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 20.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o valor do SEST do item.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisVlSEST(nItem)

aNfItem[nItem][IT_VALSES] := (aNfItem[nItem][IT_BASESES] * (aNfItem[nItem][IT_ALIQSES]/100))

Return(aNfItem[nItem][IT_VALSES])

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisBSPS3 ³ Autor ³ Mary C. Hergert       ³ Data ³ 12.04.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a base do PIS Subst. Tributaria do item              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisBSPS3(nItem)

Local nBasePis		:= 0
Local nRedBsPis		:= MaSBCampo("REDPIS")
Local nFatRedPis	:= 1

DEFAULT nRedBsPIS 	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Reducao na base de calculo calculada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRedBsPIS <> 0
	nFatRedPis	:= If( nRedBsPis>0,1-nRedBsPis/100,1)
EndIf
nRedBsPis := aTES[TS_BASEPIS] / 100
If nRedBsPIS <> 0
	nFatRedPis	*= If( nRedBsPis>0,1-nRedBsPis,1)
EndIf

If aTES[TS_PSCFST] == "1"

	If Empty( aNfItem[nItem][IT_ALIQPS3] )
		nBasePis := 0
		aNfItem[nItem][IT_BASEPS3] := nBasePis
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Conforme IN SRF 594 de 2005, nao devem integrar a base de calculo do PIS/COFINS ST:³
		//³- Receitas isentas e as decorrentes de vendas a aliquota 0                         ³
		//³- Vendas canceladas                                                                ³
		//³- Descontos incondicionais                                                         ³
		//³- IPI                                                                              ³
		//³- ICMS ST                                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nBasePis := aNfItem[nItem][IT_TOTAL] - (aNfItem[nItem][IT_VALPS3] + aNfItem[nItem][IT_VALCF3])
		nBasePis -= aNfItem[nItem][IT_VALIPI]
		// Verifica se o valor do ICMS Solidario esta agregado ao valor total
		If !(aTes[TS_INCSOL]$"A,N,D")
			nBasePis -= aNfItem[nitem][IT_VALSOL]
		Endif
		// Ha previsao na Legislacao de reducao na base de calculo
		nBasePis *= nFatRedPis
	EndIf
EndIf

aNfItem[nItem][IT_BASEPS3] := nBasePis

Return( nBasePIS )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisVLPS3 ³ Autor ³ Mary C. Hergert       ³ Data ³04.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o valor do PIS Subst. Tributaria do item             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisVLPS3(nItem)

Local nVlPis	:= 0

If aTES[TS_PSCFST] == "1"
	If !Empty( aNfItem[nItem,IT_BASEPS3] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o valor do PIS apurado                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlPis := aNfItem[nItem][IT_BASEPS3]*aNfItem[nItem][IT_ALIQPS3]/100
	Endif
EndIf

aNfItem[nItem][IT_VALPS3] := nVlPis

Return(nVlPis)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisBSCF3 ³ Autor ³ Mary C. Hergert       ³ Data ³ 12.04.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a base da COFINS Subst. Tributaria do item           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisBSCF3(nItem)

Local nBaseCOF		:= 0
Local nRedBsCOF		:= MaSBCampo("REDCOF")
Local nFatRedCOF	:= 1

DEFAULT nRedBsCOF 	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Reducao na base de calculo calculada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRedBsCOF <> 0
	nFatRedCOF	:= If( nRedBsCOF>0,1-nRedBsCOF/100,1)
EndIf

nRedBsCOF := aTES[TS_BASECOF]/100
If nRedBsCOF <> 0
	nFatRedCOF	*= If( nRedBsCOF>0,1-nRedBsCOF,1)
EndIf

If aTES[TS_PSCFST] == "1"

	If Empty( aNfItem[nItem][IT_ALIQCF3] )
		nBaseCOF := 0
		aNfItem[nItem][IT_BASECF3] := nBaseCOF
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Conforme IN SRF 594 de 2005, nao devem integrar a base de calculo do PIS/COFINS ST:³
		//³- Receitas isentas e as decorrentes de vendas a aliquota 0                         ³
		//³- Vendas canceladas                                                                ³
		//³- Descontos incondicionais                                                         ³
		//³- IPI                                                                              ³
		//³- ICMS ST                                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nBaseCOF := aNfItem[nItem][IT_TOTAL] - ((aNfItem[nItem][IT_VALPS3]) + aNfItem[nItem][IT_VALCF3])
		nBaseCOF -= aNfItem[nItem][IT_VALIPI]
		// Verifica se o valor do ICMS Solidario esta agregado ao valor total
		If !(aTes[TS_INCSOL]$"A,N,D")
			nBaseCOF -= aNfItem[nItem][IT_VALSOL]
		Endif
		// Ha previsao na Legislacao de reducao na base de calculo
		nBaseCOF *= nFatRedCOF
	EndIf
EndIf

aNfItem[nItem][IT_BASECF3] := nBaseCOF

Return( nBaseCOF )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisVLCF3 ³ Autor ³ Mary C. Hergert       ³ Data ³ 12.04.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o valor da COFINS Subst. Tributaria do item          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisVLCF3(nItem)

Local nVlCOF   	:= 0

If aTES[TS_PSCFST] == "1"
	If !Empty( aNfItem[nItem,IT_BASECF3] )
		nVlCof := aNfItem[nItem][IT_BASECF3]*aNfItem[nItem][IT_ALIQCF3]/100
	EndIf
Endif

aNfItem[nItem][IT_VALCF3] := nVlCOF

Return(nVlCOF)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaCalcFet ³ Autor ³ Henry Fila            ³ Data ³ 19.07.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se o sistema esta preparado para o calculo do impos³±±
±±³          ³to fethab                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Implementado por Sergio Fuzinaka          | Data | 11.08.06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaCalcFet()

Local lRet :=	(SB1->(FieldPos("B1_CALCFET")) > 0 .And. SB1->(FieldPos("B1_PAUTFET")) > 0 .And. SE1->(FieldPos("E1_PARCFET")) > 0 .And.;
				SE1->(FieldPos("E1_FETHAB")) > 0  .And. SED->(FieldPos("ED_CALCFET")) > 0 .And. SE2->(FieldPos("E2_PARCFET")) > 0 .And. ;
				SE2->(FieldPos("E2_FETHAB")) > 0  .And. SA1->(FieldPos("A1_RECFET")) > 0 .And. SA2->(FieldPos("A2_RECFET")) > 0 .And. ;
				SF4->(FieldPos("F4_CALCFET")) > 0)

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisBSFet³ Autor ³ Henry Fila            ³ Data ³ 19.07.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Executa o calculo da Base do Fethab                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Implementado por Sergio Fuzinaka          | Data | 11.08.06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisBSFet(nItem)

If MaCalcFet()
	If MaSbCampo("CALCFET") == "1" .And. MaSbCampo("PAUTFET") > 0 .And. aTes[TS_CALCFET] == "1" .And. aNfCab[NF_RECFET] == "1"
		aNfItem[nItem][IT_BASEFET] := ( aNfItem[nItem][IT_VALMERC] - aNfItem[nItem][IT_DESCONTO] + ;
		  											aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO] + ;
		  											aNfItem[nItem][IT_FRETE]  + aNfItem[nitem][IT_VALSOL]  )
	Else
		aNfItem[nItem][IT_BASEFET] := 0
	Endif
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisAlqFet³ Autor ³ Henry Fila           ³ Data ³19.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Executa o calculo da aliquota do Fethab                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Implementado por Sergio Fuzinaka          | Data | 11.08.06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisAlqFet(nItem)

aNfItem[nItem][IT_ALIQFET] := 0

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisValFet³ Autor ³ Henry Fila           ³ Data ³19.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa o calculo da aliquota do Fethab                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Implementado por Sergio Fuzinaka          | Data | 11.08.06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisValFet(nItem)

If MaCalcFet()
	If MaSbCampo("CALCFET") == "1" .And. MaSbCampo("PAUTFET") > 0 .And. aTes[TS_CALCFET] == "1" .And. aNfCab[NF_RECFET] == "1"
		aNfItem[nItem][IT_VALFET] := aNfItem[nItem][IT_QUANT] * MaSbCampo("PAUTFET")
	Else
		aNfItem[nItem][IT_VALFET] := 0
	Endif
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RoundRNE  ³ Autor ³Mary C. Hergert        ³ Data ³07/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Padrao de arredondamento "Round to nearst even"             ³±±
±±³          ³"Arredondamento para o numero par mais proximo"             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ExpN1: Valor de partida                                     ³±±
±±³          ³ExpN2: Numero de casas decimais                             ³±±
±±³          ³ExpN3: Precisão                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Valor arredondado.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observ.   ³A diferenca ocorre quando a terceira casa decimal e 5,      ³±±
±±³          ³precedida de um numero par. Nos outros casos, o arredonda-  ³±±
±±³          ³mento permanece o mesmo.                                    ³±±
±±³          ³Ex.: 1,521 = 1,52 / 1,524 = 1,52 / 1,525 = 1,52             ³±±
±±³          ³     1,526 = 1,53 / 1,529 = 1,53 / 1,535 = 1,54             ³±±
±±³          ³Quando o numero anterior ao 5 for par, ele mesmo e o par    ³±±
±±³          ³proximo. Quando for impar, deve arredondar para o par mais  ³±±
±±³          ³proximo (1 = 2, 3 = 4, 5 = 6, 7 = 8 ...)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RoundRNE(nPartida,nCasas,nPrecisao)

Local cString 	:= ""
Local cDecimais	:= ""
Local cAux		:= ""
Local cAntes	:= ""

Local lInteiro	:= .F.

Local nAt     	:= 0
Local nValor  	:= 0
Local nDecimais	:= 0
Local nX		:= 0
Local nResto	:= 0
Local nCalcDec	:= "1"

DEFAULT nPrecisao := 10

cString    := Strzero(nPartida,20,nPrecisao)
nAt        := At(".",cString)
cDecimais  := SubStr(cString,nAt+1,Len(cString))

nX := Len(cDecimais)
Do While nX >= nCasas .Or. nResto == 1

	If nResto == 1
		If SubStr(cDecimais,nX,1) == "9"
			nResto	:= 1
		Else
			nResto	:= 0
		Endif

		If Val(cAntes) + 1 <= 9
			cDecimais 	:= SubStr(cDecimais,1,nX-1) + Alltrim(Str(Val(cAntes)+ 1))
		Else
			cDecimais 	:= SubStr(cDecimais,1,nX-1) + "0"
		Endif

	Endif

	If nX == nCasas .And. nResto == 0
		Exit
	Endif

    cAux 	:= SubStr(cDecimais,nX,1)
    cAntes 	:= SubStr(cDecimais,nX-1,1)

    If cAux $ "01234" .And. (nX > nCasas .Or. nResto == 1)
         cDecimais := SubStr(cDecimais,1,nX-1)
    Endif

    If cAux == "5" .And. (nX > nCasas .Or. nResto == 1)
    	If cAntes $ "13579"
    		nResto := 1
    	Endif
    	cDecimais := SubStr(cDecimais,1,nX-1)
    Endif

    If cAux > "5" .And. (nX > nCasas .Or. nResto == 1)
    	cDecimais 	:= SubStr(cDecimais,1,nX-1)
    	nResto 		:= 1
    Endif

	nX := Len(cDecimais)

	If Empty(cDecimais)
		lInteiro := .T.
	Endif

Enddo

For nX := 1 to Len(cDecimais)
    nCalcDec := nCalcDec + "0"
Next

nCalcDec 	:= Val(nCalcDec)
nValor		:= Val(SubStr(cString,1,nAt-1))

If cDecimais == "1" .And. lInteiro
	nDecimais	:= 1
Else
	nDecimais 	:= Val(cDecimais) / nCalcDec
Endif

nValor		:= nValor + nDecimais

Return(nValor)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MaFisSImp³ Autor ³ Marco Bianchi         ³ Data ³30/08/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula valor total do item sem impostos.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaFisSImp(cAlias1,cAlias2,cTes)

Local nImp := 0,nValImp:=0
Local lDescInc
Local nImposto   :=  0
Local nAgrPisPas :=	0
Local nFretAut   :=  0
Local nPisCofST  :=	0
Local cNF_OPERNF
Local nIT_VALPS2
Local nIT_VALCF2
Local cNF_RECISS
Local nIT_VALICA
Local nIT_VALPS3
Local nIT_VALCF3
Local cIT_TIPONF
Local nIT_TOTAL
Local nIT_VALIPI
Local nIT_VALSOL
Local nIT_VALEMB
Local nIT_VNAGREG
Local nIT_VALMERC
Local nIT_DESCONTO
Local nIT_VALICM
Local nIT_DEDICM
Local nIT_BASEDUP
Local nIT_ICMSDIF
Local nIT_VALISS
Local nIT_VALIMP

Local aRef1 		:= {}
Local aRef2 		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva Area e preenche array com referencias fiscais          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aArea := GetArea()
aRef1 := MaFisSXRef(cAlias1)
aRef2 := MaFisSXRef(cAlias2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega referencias do cabecalho                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias1)
If cAlias1 == "SF2"
	cNF_RECISS := &(aRef1[(aScan(aRef1,{|x| x[2] == "NF_RECISS"}))][1])
	cNF_OPERNF := "S"
Else
	cNF_OPERNF := "N"
    If !Empty(SA1->A1_RECISS)
		cNF_RECISS := SA1->A1_RECISS
	Else
		cNF_RECISS := "2"
	EndIf
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega referencias dos itens                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias2)
nIT_VALPS2 := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALPS2"}))][1])
nIT_VALCF2 := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALCF2"}))][1])
nIT_VALICA := 0
nIT_VALPS3 := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALPS3"}))][1])
nIT_VALCF3 := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALCF3"}))][1])
cIT_TIPONF := SD2->D2_TIPO
If cAlias2 == "SD2"
	nIT_TOTAL := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_TOTAL"}))][1])
	nIT_DEDICM := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_DEDICM"}))][1])
Else
	nIT_TOTAL := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALMERC"}))][1])
	nIT_DEDICM := 0
EndIf
nIT_VALIPI := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALIPI"}))][1])
nIT_VALSOL := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALSOL"}))][1])
nIT_VALEMB := 0
nIT_VNAGREG := 0
nIT_VALMERC := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALMERC"}))][1])
nIT_DESCONTO := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_DESCONTO"}))][1])
nIT_VALICM := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALICM"}))][1])
nIT_BASEDUP := 0
nIT_ICMSDIF := 0
nIT_VALISS := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALISS"}))][1])
nIT_VALIMP := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega referencias da TES                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaFisTes(cTes)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura area salva                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)

lDescInc   :=	(cPaisLoc<>"BRA".AND. cNF_OPERNF =="S".AND.SuperGetMV('MV_DESCSAI')=='1')
nAgrPisPas :=	If( aTes[TS_AGRPIS]=="1" .AND. aTes[TS_PSCFST] <> "1",nIT_VALPS2,0) + If( aTes[TS_AGRCOF]=="1" .AND. aTes[TS_PSCFST] <> "1",nIT_VALCF2,0)
nFretAut   := nIT_VALICA
If !GetNewPar("MV_FRETAUT",.T.)
	nFretAut := 0
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula valor sem impostos                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Pis/Cofins Substituicao Tributaria - sera somado ao total do documento
If aTes[TS_PSCFST] == "1"
	nPisCofST := nIT_VALPS3 + nIT_VALCF3
Endif

Do Case
Case cIT_TIPONF == "P"
		nIT_TOTAL	:= 	nIT_VALIPI+IIf(aTes[TS_INCSOL]$"A,N,D",0,nIT_VALSOL)+;
		nIT_VALEMB+nFretAut+nAgrPisPas+nPisCofST
OtherWise
	Do Case
	Case aTes[TS_AGREG] == "N"
		nIT_TOTAL	:= IIf(aTes[TS_IPI] == 'R',0,nIT_VALIPI) + IIf(aTes[TS_INCSOL]$"A,N,D",0,nIT_VALSOL)+;
		nIT_VALEMB+nAgrPisPas+nPisCofST
		nIT_VNAGREG := nIT_VALMERC-nIT_DESCONTO
	Case aTes[TS_AGREG] == "I" .OR. aTes[TS_AGREG] == "B"
		nIT_TOTAL	:= nIT_VALMERC - ;
			IIf(aTes[TS_IPI] == 'R',0,nIT_VALIPI)- IIf(aTes[TS_INCSOL]$"A,N,D".AND.aTes[TS_ICM]<>"N",0,nIT_VALSOL) - IIf(lDescInc,0,nIT_DESCONTO)-;
			If(cIT_TIPONF <>"I",nIT_VALICM,0) - nIT_VALEMB-nFretAut-nAgrPisPas-nPisCofST
			nIT_VNAGREG := 0
	OtherWise
		nIT_TOTAL	:= nIT_VALMERC - ;
			IIf(aTes[TS_INCSOL]$"A,N,D",0,nIT_VALSOL) - IIf(lDescInc,0,nIT_DESCONTO)-;
			nIT_VALEMB+nFretAut - nAgrPisPas - nPisCofST - IIf(aTes[TS_AGREG]$"D",nIT_DEDICM,0)
			nIT_VNAGREG := 0
	EndCase
EndCase

// ICMS Diferido Incentivo abate de gado - o valor diferido sera somado ao total da NF e a duplicata
If aTES[TS_PICMDIF]<>0 .AND. aTes[TS_ICMSDIF]=="4"
	nIT_TOTAL += nIT_ICMSDIF
EndIf

nIT_BASEDUP := 0
If aTes[TS_DUPLIC] <>"N"
	nIT_BASEDUP := nIT_TOTAL
	If SuperGetMV("MV_DPAGREG") .AND. aTes[TS_AGREG] == "N"
		nIT_BASEDUP += nIT_VALMERC
	EndIf
	If aTes[TS_AGREG]=="F"
		nIT_BASEDUP -= nIT_VALMERC
	EndIf
	If cIT_TIPONF =='I'
		nIT_BASEDUP	-= nIT_VALICM
	EndIf
	If aTES[TS_PICMDIF]<>0 .AND. aTes[TS_ICMSDIF]$" ,1,2"
		nIT_BASEDUP	-= nIT_ICMSDIF
	EndIf
	If (cNF_RECISS == "1".AND.SuperGetMV("MV_DESCISS").AND. cNF_OPERNF =="S".AND.GetNewPar("MV_TPABISS","1")=="1")
		nIT_BASEDUP	-= nIT_VALISS
	EndIf
	If aTes[TS_INCSOL]=="D"
		nIT_BASEDUP	-= nIT_VALSOL
	EndIf
	If aTes[TS_AGREG]=="E"
		nIT_BASEDUP	-= nIT_DEDICM
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a TES possui tratamento para Impostos Variaveis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aTes[TS_SFC])
	For nImposto := 1 to Len(aTes[TS_SFC])
		nImp := NumCpoImpVar(RIGHT(Alltrim(aTes[TS_SFC][nImposto][SFB_CPOVREI]),1))
		If  aTes[TS_DUPLIC] <> "N" .AND. cIT_TIPONF <>'B'
			Do Case
			Case aTes[TS_SFC][nImposto][SFC_INCDUPL]=="1"
				nValImp := nIT_VALIMP
			Case aTes[TS_SFC][nImposto][SFC_INCDUPL]=="2"
				nValImp:=- nIT_VALIMP
			Case aTes[TS_SFC][nImposto][SFC_INCDUPL]=="3"
				nValImp:=0
			EndCase
			nIT_BASEDUP += nValImp
		Endif

		Do Case
		Case aTes[TS_SFC][nImposto][SFC_INCNOTA]=="1"
			nValImp:= nIT_VALIMP
		Case aTes[TS_SFC][nImposto][SFC_INCNOTA]=="2"
			nValImp:=- nIT_VALIMP
		Case aTes[TS_SFC][nImposto][SFC_INCNOTA]=="3"
			nValImp:=0
		EndCase
		nIT_TOTAL -= nValImp
	Next nImposto
EndIf

Return(nIT_TOTAL)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaFisVsul ³ Autor ³ Mary C. Hergert       ³ Data ³20/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o valor do Fundersul do item - Mato Grosso do Sul   ³±±
±±³          ³Este valor sera calculado apenas nas entradas do estado,    ³±±
±±³          ³sendo que o resultado sera deduzido da duplicata a pagar.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaFisVSul(nItem)

Local cUferms	:= Alltrim(GetNewPar("MV_UFERMS",""))
Local nUferms	:= 0

If MaSBCampo("PRFDSUL") <> Nil .And. MaSBCampo("PRFDSUL") > 0 .And. aTes[TS_DUPLIC] == "S" .And. aNfCab[NF_TPCLIFOR] <> "X" .And.;
	aTes[TS_CLFDSUL] == "1" .And. (SubStr(aNfItem[nItem][IT_CF],1,1) == "1" .Or. ;
	(SubStr(aNfItem[nItem][IT_CF],1,1) == "5" .And. aNFitem[nItem][IT_TIPONF] == "D"))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a moeda utilizada como UFERMS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SM2->(FieldPos("M2_MOEDA"+cUferms)) > 0
		SM2->(dbSetOrder(1))
		If SM2->(dbSeek(dDataBase))
			nUferms := SM2->&("M2_MOEDA"+cUferms)
		Endif
	Endif

	If nUferms > 0
		aNfItem[nItem][IT_VALFDS] 	:= aNfItem[nItem][IT_QUANT] * (nUferms * MaSBCampo("PRFDSUL") / 100)
		aNfItem[nItem][IT_PRFDSUL] 	:= MaSBCampo("PRFDSUL")
		aNfItem[nItem][IT_UFERMS]  	:= nUferms
	Endif
Endif

Return .T.
