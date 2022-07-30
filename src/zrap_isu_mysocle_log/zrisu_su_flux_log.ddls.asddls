@AbapCatalog.sqlViewName: 'ZRISUSUFLUXLOG'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Root view for data base table ZISU_SU_FLUX_LOG'
@Metadata.allowExtensions: true
define root view  ZRISU_SU_FLUX_LOG as select from zisu_su_flux_log as iflows  {
key iflows.idmessage ,
key iflows.idcorrelation ,
key iflows.flow_type ,
key iflows.status ,
key iflows.context_id,
iflows.version ,
iflows.statutordo ,
iflows.statutbloc ,
iflows.referencepointdeconsommation, 
iflows.referencesocietepayeuse, 
iflows.referencesociete ,
iflows.referencecontratsite, 
iflows.referencepropositioncommercial,
iflows.raisonko ,
iflows.raisonok,
iflows.raisonabandon ,
iflows.datedebutprestation ,
iflows.referenceobjetattente ,
iflows.typeobjetattente ,
@Semantics.businessDate.at 
iflows.datecreation,
 @Semantics.user.createdBy : true
iflows.createdby ,
@Semantics.systemDateTime.createdAt: true  
iflows.createdat,
@Semantics.user.lastChangedBy: true
iflows.last_changed_by ,
@Semantics.systemDateTime.localInstanceLastChangedAt
iflows.last_changed_at 
  
}
