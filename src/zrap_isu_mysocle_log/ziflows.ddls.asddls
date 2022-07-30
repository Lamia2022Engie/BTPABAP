/********** GENERATED on 05/18/2022 at 18:04:38 by CB9980000000**************/
 @OData.entitySet.name: 'iflows' 
 @OData.entityType.name: 'iflowsType' 
 define root abstract entity ZIFLOWS { 
 key flow_id : abap.char( 255 ) ; 
 key flow_type : abap.char( 255 ) ; 
 key status : abap.char( 255 ) ; 
 @Odata.property.valueControl: 'flow_failed_vc' 
 flow_failed : abap.char( 255 ) ; 
 flow_failed_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'flow_waited_vc' 
 flow_waited : abap.char( 255 ) ; 
 flow_waited_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'flow_progress_vc' 
 flow_progress : abap.char( 255 ) ; 
 flow_progress_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'prm_id_vc' 
 prm_id : abap.char( 10 ) ; 
 prm_id_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'cont_partner_id_vc' 
 cont_partner_id : abap.char( 20 ) ; 
 cont_partner_id_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'pai_partner_id_vc' 
 pai_partner_id : abap.char( 20 ) ; 
 pai_partner_id_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'ref_cs_vc' 
 ref_cs : abap.char( 30 ) ; 
 ref_cs_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'createdby_vc' 
 createdby : abap.char( 12 ) ; 
 createdby_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'createdat_vc' 
 createdat : tzntstmpl ; 
 createdat_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'last_changed_by_vc' 
 last_changed_by : abap.char( 12 ) ; 
 last_changed_by_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'last_changed_at_vc' 
 last_changed_at : tzntstmpl ; 
 last_changed_at_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 
 } 
