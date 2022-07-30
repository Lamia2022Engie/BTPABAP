@EndUserText.label: 'Root view for data base table ZISU_SU_FLUX_LOG'
@Metadata.allowExtensions: true
 define abstract entity  ZRISU_SU_FLUX_CHECK_CS  {

 
  flow_type                  : zisu_flow_type ;
  idmessage                  : zisu_message_id;
  idcorrelation              : zisu_correlation_id ;
  raisonko                       : zisu_msg_ko;
  raisonok                       : zisu_msg_ok;
  status                     : zisu_flow_status;
  referencesocietepayeuse               : zisu_srvprvref;
  referencesocietecontractante            : zisu_srvprvref;
  referencecontratsite           : zisu_flux_refcs;
  referencepointdeconsommation :  zisu_flux_pdl;
  datedebutprestation            : zisu_flux_date_debut;
  
 
}
