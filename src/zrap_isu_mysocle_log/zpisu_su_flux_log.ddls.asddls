@EndUserText.label: 'Projection view on iflow log table'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@UI: {

 headerInfo: { typeName: 'Flow ID', typeNamePlural: 'iFlowss', title: { type: #STANDARD, value: 'idmessage' } },
  presentationVariant: [{
        sortOrder: [{
            by: 'datecreation',
            direction: #DESC
        }],
        visualizations: [{
            type: #AS_LINEITEM
        }]
    }]
 }

@Search.searchable: true
define root view entity ZPISU_SU_FLUX_LOG as projection on ZRISU_SU_FLUX_LOG 

{

 @UI.facet: [ { id:              'idmessage',
                     purpose:         #STANDARD,
                     type:            #IDENTIFICATION_REFERENCE,
                     label:           'Message ID',
                     position:        10 } ]
@UI.lineItem: [{position: 10, label: 'Message ID '  }] 
@UI.identification: [{ position: 10, label: 'Message ID ' ,cssDefault.width: '5' }]
@UI.selectionField: [{ position: 10 }]
@Search.defaultSearchElement: true
key idmessage,
@UI.lineItem: [{position: 20, label: 'Correlation ID' }] 
@UI.identification: [{ position: 20, label: 'Correlation ID ' }]
@UI.selectionField: [{ position: 20 }]
key idcorrelation,
@UI.lineItem: [{position: 30, label: 'Flow Type'  }] 
@UI.identification: [{ position: 30, label: 'Flow Type' }]
@UI.selectionField: [{ position: 30 }]
key flow_type,
@UI.lineItem: [{position: 40, label: 'Status' }] 
@UI.identification: [{ position: 40, label: 'Status' }]
@UI.selectionField: [{ position: 40 }]
key status,
@UI.lineItem: [{position: 30, label: 'Context ID'  }] 
@UI.identification: [{ position: 30, label: 'Context ID' }]
@UI.selectionField: [{ position: 30 }]
key context_id , 
@UI.lineItem: [{position: 50, label: 'Vesrion'}] 
@UI.identification: [{ position: 50, label: 'Version ' }]
version, 
@UI.lineItem: [{position: 50, label: 'Statut Ordonnancement'}] 
@UI.identification: [{ position: 50, label: 'Statut Ordonnancement ' }]
statutordo, 
@UI.lineItem: [{position: 60, label: 'Statut Bloc'}] 
@UI.identification: [{ position: 60, label: 'Statut Bloc' }]
statutbloc,
@UI.lineItem: [{position: 70, label: 'reference Societe'}] 
@UI.identification: [{ position: 70, label: 'reference Societe' }]
referencesociete,
@UI.lineItem: [{position: 80, label: 'reference Point De Consommation'}] 
@UI.identification: [{ position: 80, label: 'reference Point De Consommation' }]
referencepointdeconsommation, 
@UI.lineItem: [{position: 90, label: 'reference Societe Payeuse'}] 
@UI.identification: [{ position: 90, label: 'reference Societe Payeuse' }]
referencesocietepayeuse,
@UI.lineItem: [{position: 100, label: 'Reference Contrat Site'}] 
@UI.identification: [{ position: 100, label: 'Reference Contrat Site' }]
referencecontratsite, 
@UI.lineItem: [{position: 110, label: 'Reference Proposition Commercial'}] 
@UI.identification: [{ position: 110, label: 'Reference Proposition Commercial' }]
referencepropositioncommercial, 
@UI.lineItem: [{position: 120, label: 'date Debut Prestation'}] 
@UI.identification: [{ position: 120, label: 'date Debut Prestation' }]
datedebutprestation,
@UI.lineItem: [{position: 130, label: 'date de creation'}] 
@UI.identification: [{ position: 130, label: 'date de creation' }]
datecreation,
@UI.lineItem: [{position: 140, label: 'Raison KO' }] 
@UI.identification: [{ position: 130, label: 'Raison KO' }]
raisonko,
@UI.lineItem: [{position: 150, label: 'Raison OK'}] 
@UI.identification: [{ position: 150, label: 'Raison OK' }]
raisonok,
@UI.lineItem: [{position: 150, label: 'Created By'}] 
@UI.identification: [{ position: 150, label: 'Created By' }]
createdby ,
@UI.lineItem: [{position: 150, label: 'Created At'}] 
@UI.identification: [{ position: 150, label: 'Created At' }]
createdat,
@UI.lineItem: [{position: 150, label: 'Last Changed by'}] 
@UI.identification: [{ position: 150, label: 'Last Changed by' }]
last_changed_by ,
@UI.lineItem: [{position: 150, label: 'Last Changed at'}] 
@UI.identification: [{ position: 150, label: 'Last Changed at' }]
last_changed_at 

}
