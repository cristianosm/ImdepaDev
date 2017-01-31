#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "Tbiconn.ch"


User Function TestTimeFor()
	
	Local aCols := {}
	Local aLins := {}
	
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '05' FUNNAME "TestFor" TABLES 'SX6'
	
	
	For nI := 1 To 1000

		For nF := 1 To 50 
	
			aAdd( aLins , nI * 3,14 )
		
		Next
		
		aAdd( aCols , aLins  )
		
		aLins := {}
		
	Next


	Conout('Inicio: ' + time())
	For nI := 1 To Len(aCols)
		
		Conout( cValToChar(nI) + ' ' +  cValToChar(Acols[nI][1])  )
	
	
	Next
	
	Conout('Fim: ' + time())
	
	Reset Environment
	
return