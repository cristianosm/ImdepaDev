#include 'topconn.ch'
#include 'rwmake.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMDA1000  ºAutor  ³Edivaldo Goncalves  º Data ³  21/05/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação do Saldo a Distribuir                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Imdepa                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/      
User Function IMDA1000()
Local lReturn:=.T.
Local cCodPro:=SDA->DA_PRODUTO
  
If SB1->( DbSeek( xFilial("SB1") + cCodPro,.F. ) )
  If SB1->B1_TIPO $'PA/PP/MP'
     If (M->DB_QUANT <> Int(M->DB_QUANT))      
      Iw_MsgBox("A quantidade informada "+Alltrim(Str(M->DB_QUANT))+" não é valida para este endereçamemto !"+CHR(10)+CHR(13)+"Para continuar ,informe um valor inteiro ","Endereçamento Manual","ALERT")
      lReturn:=.F.
     EndIf
  EndIf
EndIf

IMDA100A()
 
Return(lReturn)  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMDA100A  ºAutor  ³Edivaldo Goncalves  º Data ³  21/05/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação do Saldo a Distribuir                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Imdepa                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/      
Static Function IMDA100A()
Local lReturn  :=.T.
Local cArmazem :=SDA->DA_LOCAL    
Local cEndereco:=gdFieldGet("DB_LOCALIZ",n) 
Local cCodPro  :=SDA->DA_PRODUTO
Local nQtdNorma:=0    
Local nSaldoSBF:=0  
Local nPorCentOcupado:=0
Local  aArea   :=GetArea()

Private nQtdNorma   :=0
Private  nSaldoSBF  :=0 
Private  nQuantoCabe:=0
 

 DbSelectArea("SBE")
 SBE->(dbSetorder(1)) 

IMDSALDOBF(cCodPro,cArmazem,cEndereco) 
  
 If SBE->(MsSeek(xFilial('SBE')+cArmazem+cEndereco, .F.))
     
	
	nPorCentOcupado += Round((nSaldoSBF/ nQtdNorma)*100 , 2 ) //Obtenho o Percentual de Ocupação do Endereço
	
	If nSaldoSBF > nQtdNorma   
	 Iw_MsgBox("O endereço "+Alltrim(SBE->BE_LOCALIZ)+" está com a capacidade superior a Norma"+CHR(10)+CHR(13)+"Para continuar , remaneja o saldo neste endereço ","Endereçamento Manual","ALERT")    
	 lReturn:=.F.   
	  ElseIf nSaldoSBF +M->DB_QUANT > nQtdNorma  
	  Iw_MsgBox("O endereço "+Alltrim(SBE->BE_LOCALIZ)+" considerando o saldo já endereçado + a quantidade digitada de "+Str(M->DB_QUANT)+" supera a capacidade da Norma"+CHR(10)+CHR(13)+"Para continuar ,informe outra quantidade ","Endereçamento Manual","ALERT")     
	  lReturn:=.F.  
	Endif
    
      //Iw_MsgBox("O endereço "+Alltrim(SBE->BE_LOCALIZ)+" é um Picking Fixo e somente poderá ser endereçado o produto "+Alltrim(SBE->BE_CODPRO)+" - "+Alltrim(cDescPro)+CHR(10)+CHR(13)+"Para continuar ,informe um outro Endereço ","Endereçamento Manual","ALERT")    
    
 EndIf
  

RestArea(aArea)

Return(lReturn)  

Static Function IMDSALDOBF(cProduto,cArmazem,cLocaliz)

 //Consulta os produtos no Armazém para sugerir no Enderecamento 
  cSql :=" SELECT BF_FILIAL,BF_PRODUTO,SUM(BF_QUANT) AS SALDO_BF,BF_LOCALIZ, BF_ESTFIS,SUM((DC2_LASTRO*DC2_CAMADA)) AS CAPACIDADE"
  cSql +=" FROM "+RetSqlName("SBF")+" SBF, "
  cSql += RetSqlName("SBE")+" SBE, "
  cSql += RetSqlName("DC8")+" DC8, "
  cSql += RetSqlName("DC3")+" DC3, "  
  cSql += RetSqlName("DC2")+" DC2  "   
  
  cSql +=" WHERE BF_FILIAL = '" + xFilial("SBF") + "'"
  cSql +=" AND  DC3_FILIAL = BF_FILIAL"
  cSql +=" AND  DC2_FILIAL = DC3_FILIAL"
  cSql +=" AND  DC2_CODNOR = DC3_CODNOR"
      
  cSql +=" AND BF_PRODUTO = '"+cProduto+"'"
  cSql +=" AND DC3_CODPRO = BF_PRODUTO"
  cSql +=" AND BF_LOCAL   = '"+cArmazem+"'"  
  cSql +=" AND BF_LOCALIZ = '"+cLocaliz+"'"  
  
  cSql +=" AND DC3_LOCAL  = BF_LOCAL  "
  cSql +=" AND BE_FILIAL  = BF_FILIAL "
  cSql +=" AND BE_LOCALIZ = BF_LOCALIZ"

// Desconsidera Endereço Bloqueado
  cSql +=" AND BE_STATUS <>'3'" 
  
  cSql +=" AND DC8_CODEST = BF_ESTFIS " 
  cSql +=" AND BE_ESTFIS  = BF_ESTFIS " 
  cSql +=" AND DC3_TPESTR = BF_ESTFIS "
  

  // Desconsidera o Endereço tipo DOCA
  cSql+=" AND DC8_FILIAL = '" + xFilial("DC8") + "' "  
  cSql+=" AND DC8_TPESTR <> '5'"  
    
  cSql+=" AND SBF.D_E_L_E_T_=' '"
  cSql+=" AND SBE.D_E_L_E_T_=' '"
  cSql+=" AND DC8.D_E_L_E_T_=' '"
  cSql+=" AND DC3.D_E_L_E_T_=' '"
  cSql+=" AND DC2.D_E_L_E_T_=' '"  
  
  cSql+=" GROUP BY BF_FILIAL,BF_PRODUTO,BF_LOCALIZ,BF_ESTFIS,DC2_LASTRO,DC2_CAMADA"
//  cSql+=" ORDER BY bf_LOCALIZ"  
  
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

If TRB->( !Eof() )
       
  //³ Calcula a quantidade da Norma no Armazem 1 ³
  nQtdNorma      := TRB->CAPACIDADE //DLQtdNorma(TRB->BF_PRODUTO,TRB->BF_LOCAL,TRB->BF_ESTFIS)

  //³ Calcula a quantidade no Endereco ³
  nSaldoSBF      := TRB->SALDO_BF//SaldoSBF(TRB->BF_LOCAL,TRB->BF_LOCALIZ,TRB->BF_PRODUTO) 
  
   //³ Calcula o percentual de ocupação no Endereco ³
  nQuantoCabe:= nQtdNorma //Round((nSaldoSBF/ nQtdNorma)*100 , 2 ) //Obtenho o Percentual de Ocupação do Endereço
 
  //³ Se o saldo no endereço for superior a norma , sinaliza o endereço para análise da Logística ³ 
 //  If TRB->SALDO_BF > nQtdNorma
  //   cLegenda:="*"+Space(2)
  // Endif    
   

EndIf

TRB->( dbCloseArea() )

Return
                
