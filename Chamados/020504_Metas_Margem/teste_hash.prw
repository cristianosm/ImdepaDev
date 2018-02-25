#include 'protheus.ch'
#include 'parmtype.ch'


#Define _CGER_  1
#Define _TIPO_  2
#Define _VALO_  2
#Define _PERC_  2

#Define _TRIM_ 3

User function teste_hash()

  Local oVal := nil
  
  aGerente := {}
  
  AAdd(aGerente, {"999999",'01','P'})
  AAdd(aGerente, {"999999",'01','V'})
  AAdd(aGerente, {"999999",'02','P'})
  AAdd(aGerente, {"999999",'02','V'})
  AAdd(aGerente, {"999999",'03','P'})
  AAdd(aGerente, {"999999",'03','V'})
  AAdd(aGerente, {"999999",'04','P'})
  AAdd(aGerente, {"999999",'04','V'})
  AAdd(aGerente, {"999999",'05','P'})
  AAdd(aGerente, {"999999",'05','V'})
  AAdd(aGerente, {"999999",'06','P'})
  AAdd(aGerente, {"999999",'06','V'})
  AAdd(aGerente, {"999999",'07','P'})
  AAdd(aGerente, {"999999",'07','V'})
  AAdd(aGerente, {"999999",'08','P'})
  AAdd(aGerente, {"999999",'08','V'})
  AAdd(aGerente, {"999999",'09','P'})
  AAdd(aGerente, {"999999",'09','V'})
  AAdd(aGerente, {"999999",'10','P'})
  AAdd(aGerente, {"999999",'10','V'})
  AAdd(aGerente, {"999999",'11','P'})
  AAdd(aGerente, {"999999",'11','V'})
  AAdd(aGerente, {"999999",'12','P'})
  AAdd(aGerente, {"999999",'12','V'})
  AAdd(aGerente, {"999999",'13','P'})
  AAdd(aGerente, {"999999",'13','V'})
  AAdd(aGerente, {"999999",'14','P'})
  AAdd(aGerente, {"999999",'14','V'})
  AAdd(aGerente, {"999999",'15','P'})
  AAdd(aGerente, {"999999",'15','V'})
  AAdd(aGerente, {"999999",'16','P'})
  AAdd(aGerente, {"999999",'16','V'})
  AAdd(aGerente, {"999999",'17','P'})
  AAdd(aGerente, {"999999",'17','V'})
  
   //HMGet(oHash,"99999915",oVal)
   
   
  oHash := AToHM(aGerente,_CGER_,_TRIM_,_TIPO_,_TRIM_)
   
  HMSet( oHash,"99999915V", 100 )
  HMSet( oHash,"99999915P", 9 )
  HMSet( oHash,"99999913V", 100 )
  HMSet( oHash,"99999913P", 9 )
  HMSet( oHash,"99999911V", 100 )
  HMSet( oHash,"99999911P", 9 )
  
  //Atualiza ou cria valor correspondente a chave em um objeto da classe tHashMap.
  //HMSetN( oHash , nKey , nVal )
  
  //cKey := HMAdd(oHash,{"item10",5},1,3,2,3)
  aList := {}
  
  HMList(oHash,aList)
  
  HMGet( oHash,"99999915V",@oVal)
  
  //conout('cKey'+cKey)
  
  varinfo("",oVal)
  
  HMSet( oHash,"99999911V", oVal+100 )
  
   HMGet( oHash,"99999911V",@oVal)
   
  varinfo("",oVal)
  
  //Alert()
Return	
