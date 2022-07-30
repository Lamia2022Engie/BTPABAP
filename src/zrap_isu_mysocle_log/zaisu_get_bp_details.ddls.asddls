@EndUserText.label: 'Business Part details from RV'
@Metadata.allowExtensions: true
 define abstract entity  ZAISU_GET_BP_Details  {

BP_PARTNER_CONTR : zisu_bp_part; 
BP_PARTNER_PAY : zisu_bp_part; 
BP_CONT_AUGPR : zisu_bu_augrp;
BP_CONT_NAME_ORG1 : zisu_bp_cont_name_org1 ;
BP_CONT_MUSTER_KUN : zisu_muster_kun ;
BP_CONT_KTOKLASSE : zisu_ktoklasse ;
BP_CONT_IND_SECTOR : zisu_bu_ind_sector ; 
}
