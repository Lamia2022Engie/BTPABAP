CLASS lhc_ZRISU_SU_FLUX_LOG DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_flows,
             flow_type TYPE    zisu_flow_type.
    TYPES: END OF ty_flows.
    DATA it_flow_create TYPE zrisu_su_flux_log.
    DATA bp_flows TYPE TABLE OF ty_flows .


    DATA flow_ranges TYPE RANGE OF zisu_flow_type .
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zrisu_su_flux_log RESULT result.
    METHODS synchronise_bp FOR READ
      IMPORTING keys FOR FUNCTION zrisu_su_flux_log~synchronise_bp RESULT result.
    METHODS execute_ordonnoncement FOR READ
      IMPORTING keys FOR FUNCTION zrisu_su_flux_log~execute_ordonnoncement RESULT result.
    METHODS create_entries FOR READ
      IMPORTING keys FOR FUNCTION zrisu_su_flux_log~create_entries RESULT result.

    METHODS get_flux_ordo FOR READ
      IMPORTING keys FOR FUNCTION zrisu_su_flux_log~get_flux_ordo RESULT result.
    METHODS set_flux_cs FOR READ
      IMPORTING keys FOR FUNCTION zrisu_su_flux_log~set_flux_cs RESULT result.

    METHODS execute_bp_ordo FOR READ
      IMPORTING keys FOR FUNCTION zrisu_su_flux_log~execute_bp_ordo RESULT result.
    METHODS get_bp_prisencompte FOR READ
      IMPORTING keys FOR FUNCTION zrisu_su_flux_log~get_bp_prisencompte RESULT result.
    METHODS execute_cs_ordo FOR READ
      IMPORTING keys FOR FUNCTION zrisu_su_flux_log~execute_cs_ordo RESULT result.
    METHODS handle_cs_crea_function FOR READ
      IMPORTING keys FOR FUNCTION zrisu_su_flux_log~handle_cs_crea_function RESULT result.
    METHODS check_cs_info FOR READ
      IMPORTING keys FOR FUNCTION zrisu_su_flux_log~check_cs_info RESULT result.
    METHODS check_cs_bp FOR READ
      IMPORTING keys FOR FUNCTION zrisu_su_flux_log~check_cs_bp RESULT result.
    METHODS execute_other_bp FOR READ
      IMPORTING keys FOR FUNCTION zrisu_su_flux_log~execute_other_bp RESULT result.
    METHODS check_cs_to FOR READ
      IMPORTING keys FOR FUNCTION zrisu_su_flux_log~check_cs_to RESULT result.
ENDCLASS.

CLASS lhc_ZRISU_SU_FLUX_LOG IMPLEMENTATION .

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD synchronise_bp.
    DATA(flow_type) = keys[ 1 ]-%param.
    DATA counter TYPE int2.
    SELECT *  FROM zrisu_su_flux_log
    WHERE statutordo = 'PrisEnCompte' AND flow_type = @flow_type-flow_type INTO TABLE @DATA(lt_flow).
    SORT   lt_flow BY referenceSociete datedebutprestation ASCENDING .
    IF lt_flow IS NOT INITIAL .
      READ TABLE lt_flow INDEX 1 INTO DATA(oldest_flow).
    ENDIF .
    LOOP AT lt_flow INTO DATA(ls_flow) WHERE datedebutprestation = oldest_flow-datedebutprestation .
      ls_flow-statutbloc = 'EnCours'.
      MODIFY lt_flow FROM ls_flow .
      counter = counter + 1  .
    ENDLOOP .
    UPDATE zisu_su_flux_log FROM TABLE  @lt_flow.
    DATA ls_result LIKE LINE OF result.
    ls_result-%param = counter.
    APPEND ls_result TO result .

  ENDMETHOD.

  METHOD execute_ordonnoncement.
    "Rechercher dans la table de toutes les entrées au STATUTORDO "PrisEnCompte" ou "EnCours",
    DATA counter TYPE int2.

    SELECT * FROM zisu_su_flux_log WHERE statutordo = 'PrisEnCompte' OR statutordo = 'EnCours'
    INTO TABLE @DATA(flow_inter) .
    IF flow_inter IS NOT INITIAL .
      "Si au moins une entrée trouvée, on passe toutes ces entrées au STATUTORDO "ATraiter" et le STATUTBLOC A vide, et on passe à l'étape 1.
      LOOP AT flow_inter INTO DATA(ls_flux_iter).
        ls_flux_iter-statutordo  = 'ATraiter'.
        ls_flux_iter-statutbloc = ''.
        UPDATE zisu_su_flux_log FROM    @ls_flux_iter.
      ENDLOOP.

      CLEAR flow_inter .
    ENDIF .
    "Etape 1 : Recherche de l'ensemble des flux à traiter par le programme.
    "Rechercher dans la table de toutes les entrées avec STATUT in {"Réceptionné";"EnRejeu"}, au STATUTORDO = "ATraiter"
    SELECT * FROM zisu_su_flux_log WHERE  (  status = 'Receptionne' OR status = 'EnRejeu' ) AND statutordo  = 'ATraiter'
    INTO TABLE @flow_inter .
    "Si au moins une entrée trouvée, on passe toutes ces entrées au STATUTORDO "PrisEnCompte", et on passe à l'étape 2.
    IF flow_inter IS NOT INITIAL .
    counter = 1 .
      LOOP AT flow_inter INTO ls_flux_iter .
        ls_flux_iter-statutordo = 'PrisEnCompte'.
        UPDATE zisu_su_flux_log FROM @ls_flux_iter.
        " modify flow_inter from ls_flux_iter .

      ENDLOOP .

    ELSE .
      "Si aucune entrée trouvée, on arrête le programme BTP 2 et on le relancer dans X temps.

    ENDIF .
    DATA ls_result LIKE LINE OF result.
    ls_result-%param = counter.
    APPEND ls_result TO result .
  ENDMETHOD.



  METHOD create_entries.
    DATA:itab TYPE TABLE OF zisu_su_flux_log.


*   delete existing entries in the database table
    DELETE  FROM zisu_su_flux_log .

    itab = VALUE #(
   ( idmessage = 'b3ba53bd-6112-4cb4-867d-89565eb3d6d1'    idcorrelation = 'c3f3dfd3-2c1f-443c-af27-fa6f68134e62' flow_type = 'BPCREA' status = 'OK'
   statutordo = 'PrisEnCompte' referencesociete = 'Test123'  )
    ( idmessage = 'b3ba53bd-6211-4cb4-867d-89565eb3e6F1'    idcorrelation = 'c3f3dfd2-2c1f-443c-af27-fa6f68134e62' flow_type = 'BPCREA' status = 'OK'
   statutordo = 'PrisEnCompte' referencesociete = 'Test124'  ) ) .

*   insert the new table entries
    INSERT zisu_su_flux_log FROM TABLE @itab.
  ENDMETHOD.


  METHOD get_flux_ordo.

    DATA counter TYPE int2.
    DATA ls_result LIKE LINE OF result.
    DATA(reference_soc) = keys[ 1 ]-%param.
    bp_flows = VALUE #(
    ( flow_type =  'BPCREA'   )
    ( flow_type = 'BPMODIF')
    ( flow_type = 'BPREP' ) ).
    "write the column carrid of your internal table in your range
    flow_ranges = VALUE #( FOR <fs_range> IN bp_flows
                        (
                          sign = 'I'
                          option = 'EQ'
                          low = <fs_range>-flow_type
                          high = ''
                         ) ).
    SELECT * FROM zisu_su_flux_log WHERE flow_type IN @flow_ranges AND statutbloc  = 'EnCours'
     AND referencesociete = @reference_soc-referencesociete INTO TABLE @DATA(progess_flow) .
    LOOP AT progess_flow INTO DATA(ls_failed).
      counter = counter + 1.
    ENDLOOP .

    ls_result-%param = counter.
    APPEND ls_result TO result .
    IF counter > 1 .
      SELECT * FROM zisu_su_flux_log WHERE flow_type IN @flow_ranges  AND statutbloc  = 'EnCours' AND
       statutordo = 'PrisEnCompte'
      AND referencesociete = @reference_soc-referencesociete INTO TABLE @DATA(ab_flow) .
      LOOP AT ab_flow INTO ls_failed.
        ls_failed-raisonabandon = 'Reprise' + ls_failed-idmessage .
        ls_failed-statutordo = 'Traité'.
        ls_failed-statutbloc = 'Traité'.
        MODIFY zisu_su_flux_log FROM @ls_failed .
      ENDLOOP .
    ENDIF .

  ENDMETHOD.

  METHOD set_flux_cs.
    bp_flows = VALUE #(
  ( flow_type =  'BPCREA'   )
  ( flow_type = 'BPMODIF')
  ( flow_type = 'BPREP' ) ).
    "write the column carrid of your internal table in your range
    flow_ranges = VALUE #( FOR <fs_range> IN bp_flows
                        (
                          sign = 'I'
                          option = 'EQ'
                          low = <fs_range>-flow_type
                          high = ''
                         ) ).
    DATA(reference_soc) = keys[ 1 ]-%param.
    SELECT  SINGLE *   FROM   zisu_su_flux_log WHERE  referencesociete = @reference_soc-referencesociete
  AND idmessage = @reference_soc-idmessage AND idcorrelation = @reference_soc-idcorrelation AND
  flow_type IN @flow_ranges  INTO @DATA(current_flow).
    IF  reference_soc-status = 'ok'.

      "Delete the current flow
      DELETE zisu_su_flux_log FROM @current_flow.
      current_flow-status = 'ok' .
      current_flow-raisonok = reference_soc-raisonok .
      current_flow-statutordo = 'traite'.
      current_flow-statutbloc = 'traite'.
      INSERT zisu_su_flux_log FROM @current_flow.

      SELECT * FROM zisu_su_flux_log WHERE flow_type = 'CSCREA' AND status = 'Attente' AND
      statutordo = 'ATraiter' AND referenceobjetattente =  @reference_soc-referencesociete INTO TABLE @DATA(cs_attente).
      LOOP AT cs_attente INTO DATA(ls_attente).
        ls_attente-status = 'ARejouer'.
        MODIFY  zisu_su_flux_log FROM @ls_attente .
      ENDLOOP .
    ELSE .

      DELETE zisu_su_flux_log FROM @current_flow.
      current_flow-status = 'ko' .
      current_flow-raisonko = reference_soc-raisonko .
      current_flow-statutordo = 'traite'.
      current_flow-statutbloc = 'traite'.
      INSERT zisu_su_flux_log FROM @current_flow.

      SELECT * FROM zisu_su_flux_log WHERE flow_type = 'CSCREA' AND ( status = 'Receptionne' OR status = 'ARejouer' )
       AND
        statutordo = 'PrisEnCompte' AND  ( referencesociete =  @reference_soc-referencesociete OR
        referencesocietepayeuse =  @reference_soc-referencesociete )
          INTO TABLE @DATA(cs_attente_ko).
      LOOP AT cs_attente INTO DATA(ls_attente_ko).
        DELETE   zisu_su_flux_log FROM @ls_attente_ko .
        ls_attente_ko-status = 'EnAttente'.
        ls_attente_ko-statutordo = 'ATraiter'.
        ls_attente_ko-statutbloc = ' '.
        ls_attente_ko-referenceobjetattente = reference_soc-referencesociete.
        ls_attente_ko-typeobjetattente = 'societé'.
        INSERT   zisu_su_flux_log FROM @ls_attente_ko .
      ENDLOOP .
    ENDIF .
  ENDMETHOD.



  METHOD execute_bp_ordo.


    bp_flows = VALUE #(
       ( flow_type =  'BPCREA'   )
       ( flow_type = 'BPMODIF')
       ( flow_type = 'BPREP' ) ).
    "write the column carrid of your internal table in your range
    flow_ranges = VALUE #( FOR <fs_range> IN bp_flows
                        (
                          sign = 'I'
                          option = 'EQ'
                          low = <fs_range>-flow_type
                          high = ''
                         ) ).
    DATA(reference_soc) = keys[ 1 ]-%param.
    DATA ls_result LIKE LINE OF result.
    DATA counter TYPE int2.
    SELECT * FROM zisu_su_flux_log WHERE flow_type IN  @flow_ranges  AND statutordo = 'PrisEnCompte'
    INTO TABLE @DATA(lt_flow_table).
    SORT lt_flow_table BY referencesociete datecreation ASCENDING .
    DELETE ADJACENT DUPLICATES FROM  lt_flow_table COMPARING  referencesociete .
    LOOP AT lt_flow_table INTO DATA(ls_flow_table) WHERE referencesociete = reference_soc-referencesociete.

      counter = counter + 1.

    ENDLOOP .

    ls_result-%param = counter.
    APPEND ls_result TO result .
    "if counter = 1 .
    READ TABLE  lt_flow_table WITH KEY  referencesociete = reference_soc-referencesociete  INTO DATA(ls_flow_first)  .
    ls_flow_first-statutbloc = 'EnCours'.
    ls_flow_first-statutordo = 'EnCours'.
    IF counter > 1 .
      ls_flow_first-flow_type = 'BPREP' .
    ENDIF .
    MODIFY zisu_su_flux_log FROM @ls_flow_table .
    "endif .
    IF counter > 1 .
      LOOP AT lt_flow_table INTO ls_flow_table WHERE referencesociete = reference_soc-referencesociete AND
       statutbloc <> 'EnCours'.
        ls_flow_table-status = 'Abandon' .
        ls_flow_table-statutordo = 'Traité'.
        ls_flow_table-statutbloc = 'Traité'.
        ls_flow_table-raisonabandon = 'Reprise ' +  ls_flow_first-idmessage .
        MODIFY  zisu_su_flux_log FROM @ls_flow_table .

      ENDLOOP .
    ENDIF .

    "Handle the failed BP flows
    SELECT * FROM zisu_su_flux_log WHERE flow_type IN  @flow_ranges  AND status = 'ko'
    AND referencesociete = @reference_soc-referencesociete INTO TABLE @DATA(failed_flow) .

    LOOP AT failed_flow INTO DATA(ls_failed).
      counter = counter + 1.
      ls_failed-status = 'Abandon'.
      ls_failed-statutordo = 'Traité' .
      ls_failed-statutbloc = 'Traité'.
      CONCATENATE 'Reprise' reference_soc-idmessage  INTO ls_failed-raisonabandon SEPARATED BY space.

    ENDLOOP .
    IF counter >= 1 .
      SELECT  SINGLE *   FROM   zisu_su_flux_log WHERE  referencesociete = @reference_soc-referencesociete
      AND idmessage = @reference_soc-idmessage AND idcorrelation = @reference_soc-idcorrelation AND
      flow_type IN  @flow_ranges  INTO @DATA(current_flow).
      IF current_flow IS NOT INITIAL .
        current_flow-flow_type = 'BPREP'.
        MODIFY zisu_su_flux_log FROM @current_flow.
      ENDIF .

    ENDIF .
    ls_result-%param = counter.
    APPEND ls_result TO result .
  ENDMETHOD.

  METHOD get_bp_PrisenCompte.
    TYPES: BEGIN OF ty_flows,
             flow_type TYPE    zisu_flow_type.
    TYPES: END OF ty_flows.
    DATA bp_flows TYPE TABLE OF ty_flows .

    bp_flows = VALUE #(
     ( flow_type =  'BPCREA'   )
     ( flow_type = 'BPMODIF')
     ( flow_type = 'BPREP' ) ).
    DATA flow_ranges TYPE RANGE OF zisu_flow_type .
    "write the column carrid of your internal table in your range
    flow_ranges = VALUE #( FOR <fs_range> IN bp_flows
                        (
                          sign = 'I'
                          option = 'EQ'
                          low = <fs_range>-flow_type
                          high = ''
                         ) ).
    DATA counter TYPE int2.

    DATA ls_result LIKE LINE OF result.
    SELECT * FROM zisu_su_flux_log WHERE statutordo = 'PrisEnCompte' AND flow_type IN  @flow_ranges   INTO TABLE @DATA(flows_encompte) .

    IF flows_encompte IS INITIAL .
      counter = 1.
    ENDIF .
    ls_result-%param = counter.
    APPEND ls_result TO result .
  ENDMETHOD.

  METHOD execute_cs_ordo.
    DATA(input_param) = keys[ 1 ]-%param.
    "Step 0 : get all CS crea flow that are to be launched by CS flow orechestrator
    " select * from zisu_su_flux_log where   ( flow_type ='CSCREA' or flow_type = 'CSCREAREP' )
    "and statutordo = 'EnCours' and statutbloc = 'EnCours'
    "and (   status = 'Receptionne'  or status = 'ARejouer' ) into @data(csflow_encours).

    SELECT * FROM zisu_su_flux_log WHERE  flow_type > 'CSCREA'
    AND  status <> 'ok'
    AND referencepointdeconsommation = @input_param-referencepointdeconsommation
    AND datedebutprestation < @input_param-datedebutprestation  AND statutordo = 'EnCours'
     INTO  TABLE @DATA(lt_cs_flows).
    IF lt_cs_flows IS NOT INITIAL .

      LOOP AT lt_cs_flows INTO DATA(ls_cs_flows) WHERE statutbloc = 'EnCours'.
        DELETE zisu_su_flux_log FROM @ls_cs_flows .
        ls_cs_flows-status = 'EnAttente'.
        ls_cs_flows-statutordo = 'ATraiter'.
        ls_cs_flows-statutbloc = ' '.
        ls_cs_flows-referenceobjetattente = input_param-referencepointdeconsommation .
        ls_cs_flows-typeobjetattente = 'contrat site' .
        INSERT  zisu_su_flux_log FROM @ls_cs_flows .

      ENDLOOP .

      SELECT * FROM zisu_su_flux_log WHERE flow_type  = 'CSAUTRE' AND statutordo = 'PrisEnCompte'
      AND statutbloc = 'EnCours ' INTO TABLE @DATA(cs_other_flows).
      IF sy-subrc = 0 .
        CLEAR ls_cs_flows .
        LOOP AT cs_other_flows INTO ls_cs_flows .
          DELETE zisu_su_flux_log FROM @ls_cs_flows .
          ls_cs_flows-status = 'EnAttente'.
          ls_cs_flows-statutordo = 'ATraiter'.
          ls_cs_flows-statutbloc = ' '.
          ls_cs_flows-referenceobjetattente = input_param-referencepointdeconsommation .
          ls_cs_flows-typeobjetattente = 'contrat site' .

        ENDLOOP .
      ENDIF .
      "fin de traitement et passage à l'étape 3.6
    ELSE .
      " Combien de fichier pour ce CS de type création (TYPEFLUX in {"CSCREA"; "CSCREAREP"})
      " en cours de l'ordonnancement (STATUTBLOC = "EnCours")?

      SELECT * FROM zisu_su_flux_log WHERE   ( flow_type ='CSCREA' OR flow_type = 'CSCREAREP' )
      AND referencepointdeconsommation = @input_param-referencepointdeconsommation AND statutbloc = 'EnCours'
      INTO TABLE @DATA(cs_flow_inprogress).
      READ TABLE cs_flow_inprogress INTO ls_cs_flows INDEX 2 .
      IF cs_flow_inprogress IS INITIAL . "only one entry exist for that flow
        READ TABLE cs_flow_inprogress INTO ls_cs_flows INDEX 1 .
        IF ls_cs_flows-statutbloc = 'ARejouer' .
          SELECT * FROM zisu_su_flux_log WHERE flow_type = 'CS*'
          AND referencepointdeconsommation = @input_param-referencepointdeconsommation AND ( status = 'ko'
          OR status = 'Enattente' ) INTO TABLE @DATA(cs_failed_flows).
          IF sy-subrc = 0 .
            "Orchestration spé à définir en séquentiel sans flux de reprise

          ELSE .

            "Traitement BTP>RV du flux au STATUTORDO = "EnCours"
          ENDIF .
        ELSE .

        ENDIF .
      ENDIF .
    ENDIF .


  ENDMETHOD.

  METHOD handle_cs_crea_function.
    DATA l_s_range TYPE zisu_flow_status.

    TYPES: BEGIN OF ty_status,
             status TYPE    zisu_flow_status.
    TYPES: END OF ty_status.
    DATA failurerange TYPE TABLE OF ty_status .

    failurerange = VALUE #(
     ( status =  'KO'   )
     ( status = 'Enattente')
     ( status = 'EnCours' ) ).
    DATA flow_ranges TYPE RANGE OF zisu_flow_status .
    "write the column carrid of your internal table in your range
    flow_ranges = VALUE #( FOR <fs_range> IN failurerange
                        (
                          sign = 'I'
                          option = 'EQ'
                          low = <fs_range>-status
                          high = ''
                         ) ).
    DATA(input_param) = keys[ 1 ]-%param.
    SELECT SINGLE * FROM zisu_su_flux_log WHERE flow_type = 'OTCREA'
    AND referencepointdeconsommation  = @input_param-referencepointdeconsommation
    AND status IN @flow_ranges INTO @DATA(ls_flow).
    IF sy-subrc = 0 .
      CLEAR ls_flow .
      MOVE-CORRESPONDING input_param TO ls_flow .
      ls_flow-status = 'Enattente'.
      """Check what other entrie required
      INSERT zisu_su_flux_log FROM @ls_flow .
    ELSE .
    ENDIF .


  ENDMETHOD.

  METHOD check_cs_info.
    DATA(lo_rfc_dest) = cl_rfc_destination_provider=>create_by_cloud_destination(
                                i_name = |SU1-RFC|
                                i_service_instance_name = |CA_EXTERNAL_API_SIN| ).

    DATA(lv_rfc_dest) = lo_rfc_dest->get_destination_name( ).
    DATA(input_param) = keys[ 1 ]-%param.

    .
    CALL FUNCTION 'ZISU_MEPMEF_GETINFO_CS' DESTINATION lv_rfc_dest
      EXPORTING
        bp_ref_crm = input_param-referencesocietecontractante
        ct_ref_crm = input_param-referencecontratsite
        ct_dt_fin  = input_param-datedebutprestation
        ct_dt_deb  = input_param-datedebutprestation
        ref_pdl    = input_param-referencepointdeconsommation.
*   IMPORTING
*     TYPE_TRAIT_GENERAL           =
*     BP_CONT                      =
*     BP_CONT_MUSTER_KUN           =
*     VKONT_A                      =
*     VERTRAG                      =
*     PRED_VKONT                   =
*     PRED_VERTRAG                 =
*     PRED_CONT_BPEXT              =
*     ISU_MEPMEF_RETOUR_BAPI       =
  ENDMETHOD.

  METHOD check_cs_bp.
    DATA ls_result LIKE LINE OF result.
    " ls_result-%param = counter.

    DATA(lo_rfc_dest) = cl_rfc_destination_provider=>create_by_cloud_destination(
                                i_name = |SU1-RFC|
                                i_service_instance_name = |CA_EXTERNAL_API_SIN| ).

    DATA(lv_rfc_dest) = lo_rfc_dest->get_destination_name( ).
    DATA(input_param) = keys[ 1 ]-%param.

    CALL FUNCTION 'ZISU_MEPMEF_GETINFO_BP' DESTINATION lv_rfc_dest
      EXPORTING
        bu_bpext           = input_param-referencesocietecontractante
      IMPORTING
*       ISU_MEPMEF_RETOUR_BAPI       =
        bp_cont_partner    = ls_result-%param-bp_partner_contr
        bp_cont_augpr      = ls_result-%param-bp_cont_augpr
        bp_cont_name_org1  = ls_result-%param-bp_cont_name_org1
        bp_cont_muster_kun = ls_result-%param-bp_cont_muster_kun
        bp_cont_ktoklasse  = ls_result-%param-bp_cont_ktoklasse
        bp_cont_ind_sector = ls_result-%param-bp_cont_ind_sector.
    IF ls_result-%param-bp_partner_contr IS INITIAL .  "BP does not exist yet
      "Mettre le flux en attente .
      SELECT  SINGLE *   FROM   zisu_su_flux_log WHERE  flow_type = @input_param-flow_type
     AND referencecontratsite = @input_param-referencecontratsite INTO @DATA(ls_cs_flow).
      IF sy-subrc = 0 .
        ls_cs_flow-status = 'enattente'.
        ls_cs_flow-referenceobjetattente = input_param-referencesocietecontractante .
        ls_cs_flow-typeobjetattente = 'societe'.
        DELETE  zisu_su_flux_log FROM @ls_cs_flow .
        INSERT zisu_su_flux_log FROM @ls_cs_flow .
      ENDIF . "endif sy-subrc = 0 .

    ENDIF .
    IF input_param-referencesocietepayeuse <> input_param-referencesocietecontractante .
      IF input_param-referencesocietepayeuse IS NOT INITIAL .
        CALL FUNCTION 'ZISU_MEPMEF_GETINFO_BP' DESTINATION lv_rfc_dest
          EXPORTING
            bu_bpext           = input_param-referencesocietepayeuse
          IMPORTING
*           ISU_MEPMEF_RETOUR_BAPI       =
            bp_cont_partner    = ls_result-%param-bp_partner_pay
            bp_cont_augpr      = ls_result-%param-bp_cont_augpr
            bp_cont_name_org1  = ls_result-%param-bp_cont_name_org1
            bp_cont_muster_kun = ls_result-%param-bp_cont_muster_kun
            bp_cont_ktoklasse  = ls_result-%param-bp_cont_ktoklasse
            bp_cont_ind_sector = ls_result-%param-bp_cont_ind_sector.
        IF ls_result-%param-bp_partner_pay IS INITIAL .
          CLEAR  ls_cs_flow .
          SELECT  SINGLE *   FROM   zisu_su_flux_log WHERE  flow_type = @input_param-flow_type
         AND referencecontratsite = @input_param-referencecontratsite INTO @ls_cs_flow.
          IF sy-subrc = 0 .
            ls_cs_flow-status = 'enattente'.
            ls_cs_flow-referenceobjetattente = input_param-referencesocietepayeuse .
            ls_cs_flow-typeobjetattente = 'societe'.
            DELETE  zisu_su_flux_log FROM @ls_cs_flow .
            INSERT zisu_su_flux_log FROM @ls_cs_flow .
          ENDIF . " endif sy-subrc = 0 .
        ENDIF . "endif bp_partner_pay is initial
      ENDIF . "endif referencesocietepayeuse is not initial

    ELSE . " societé contractante = societé payeuse .
      ls_result-%param-bp_partner_pay = ls_result-%param-bp_partner_contr .
    ENDIF . " endif referencesocietepayeuse <> referencesocietecontractante

    APPEND ls_result TO result .
  ENDMETHOD.

  METHOD execute_other_bp.
    DATA ls_result LIKE LINE OF result.
    bp_flows = VALUE #(
     ( flow_type =  'BPCREA'   )
     ( flow_type = 'BPMODIF')
     ( flow_type = 'BPREP' ) ).
    "write the column carrid of your internal table in your range
    flow_ranges = VALUE #( FOR <fs_range> IN bp_flows
                        (
                          sign = 'I'
                          option = 'EQ'
                          low = <fs_range>-flow_type
                          high = ''
                         ) ).
    "Get all the flows in status prise en compte
    SELECT * FROM zisu_su_flux_log WHERE statutordo = 'PrisEnCompte' AND flow_type NOT IN
    @flow_ranges INTO TABLE @DATA(lt_flows_not_bp).
    SORT lt_flows_not_bp BY referencepointdeconsommation referencepropositioncommercial .
    LOOP AT lt_flows_not_bp INTO DATA(ls_flw).
      MOVE-CORRESPONDING ls_flw TO ls_result-%param.
      APPEND ls_result TO result .
    ENDLOOP .

  ENDMETHOD.

  METHOD check_cs_to.

    DATA(lo_rfc_dest) = cl_rfc_destination_provider=>create_by_cloud_destination(
                                 i_name = |SU1-RFC|
                                 i_service_instance_name = |CA_EXTERNAL_API_SIN| ).

    DATA(lv_rfc_dest) = lo_rfc_dest->get_destination_name( ).
    DATA(input_param) = keys[ 1 ]-%param.
    DATA ls_result LIKE LINE OF result.
    CALL FUNCTION 'ZISU_MEPMEF_GETINFO_POD' DESTINATION lv_rfc_dest
      EXPORTING
        pod                 = input_param-referencepointdeconsommation
        application_date    = input_param-datedebutprestation
      IMPORTING
        anlage              = ls_result-%param-anlage
        premise             = ls_result-%param-premise
        or                  = ls_result-%param-ort
        energie             = ls_result-%param-energie
        type_comptage       = ls_result-%param-type_comptage
        freq_releve         = ls_result-%param-freq_releve
        cal_fournisseur_ref = ls_result-%param-cal_fournisseur_ref
        or_designation      = ls_result-%param-or_designation
        inst_grpa_a         = ls_result-%param-inst_grpa_a
        lc_grpa_a           = ls_result-%param-lc_grpa_a
        or_grpa_a           = ls_result-%param-or_grpa_a
        chgtapp             = ls_result-%param-chgtapp.

    IF ls_result-%param-anlage IS INITIAL .
      "on met le flux en attendte
    ELSE .
      APPEND ls_result TO result .
    ENDIF .

  ENDMETHOD.

ENDCLASS.
